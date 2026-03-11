---
name: audio-device-init
description: Audio Device 初始化、枚舉、選擇、持久化的詳細參考
---

# Audio Device 初始化/枚舉/選擇

## JUCE 初始化模式

### initialise vs initialiseWithDefaultDevices
- initialiseWithDefaultDevices(numIn, numOut)：簡單場景，自動選擇預設設備
- initialise(numIn, numOut, savedState, selectDefault, preferredSetup, listener)：需要持久化或自訂配置時使用
- 多通道介面用 32ch（KousatenMixer）、純播放用 2ch（JazzArchitect-JUCE）

### 設備枚舉
- getAvailableDeviceTypes() 取得設備類型列表
- 每個 type 的 getDeviceNames(false) 取得輸出設備名稱
- 通道數查詢：臨時建立設備 createDevice() -> getInputChannelNames().size()
- 已知坑：多通道介面常報告比實際少的通道數
- 解法：硬編碼已知品牌（ES-、Focusrite、MOTU、RME、Aggregate）fallback 到 16ch

### 設備切換
- getAudioDeviceSetup(setup) 取得當前配置
- setup.outputDeviceName = 新設備名
- setAudioDeviceSetup(setup, true) 套用（true = 重啟設備）
- 返回非空字串表示錯誤

### audioDeviceAboutToStart 回調
- 從 device 取得 sampleRate、bufferSize、channelNames
- 預分配所有 buffer（此時知道確切大小）
- buffer 通道數用 max(16, actualChannels) 預留空間
- 呼叫 engine.prepareToPlay()

### 來源參考
- KousatenMixer: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/MainComponent.cpp
- KousatenMixer: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/Core/AudioDeviceHandler.cpp
- JazzArchitect-JUCE: /Users/madzine/Documents/OpenSource/JazzArchitect-JUCE/Source/MainComponent.cpp
- Techno_Machine: /Users/madzine/Documents/OpenSource/Techno_Machine/Source/MainComponent.cpp

---

## cpal/RtAudio 初始化模式 (Rust)

### cpal 標準流程
- default_host() -> default_output_device() / output_devices()
- device.default_output_config() 取得支援的格式
- 失敗 fallback: (2ch, 48000Hz)
- build_output_stream(config, data_callback, error_callback, None)
- stream.play() 啟動
- BufferSize::Fixed(256) 低延遲，BufferSize::Fixed(512) 標準

### cpal 的 macOS 限制
- host.output_devices() 漏掉部分裝置（External Headphones、HDMI）
- 補救方案 1: coreaudio-sys 直接枚舉，但這些裝置標記 supported=false
- 補救方案 2: 完全改用 RtAudio（WAAASAABIII 最終方案）

### RtAudio FFI 替代方案
- C++ wrapper 用 extern "C" 匯出函式
- Rust 端用 #[repr(C)] struct 對應
- 每個 stream 需要獨立的 RtAudio 實例（一個實例只管一個 stream）
- RtAudio 6.x API: getDeviceIds() 返回 ID 列表（非索引遍歷）
- StreamOptions: flags=RTAUDIO_SCHEDULE_REALTIME, numberOfBuffers=2
- output_params.nChannels = device_channels（開啟設備所有通道）
- output_params.firstChannel = 0（從通道 0 開始）

### 設備枚舉 (RtAudio)
- rtaudio.getDeviceIds() 取得所有設備 ID
- rtaudio.getDeviceInfo(id) 取得名稱、通道數、支援的 sample rate
- 過濾 outputChannels > 0 的設備

### 音訊素材統一格式
- 所有素材在解碼階段 resample 到 48000Hz stereo
- 使用 ffmpeg resampler 或 symphonia
- 避免運行時 resampling 的效能開銷

### 來源參考
- WAAASAABIII (cpal): /Users/madzine/Documents/OpenSource/WAAASAABIII/src/audio.rs
- WAAASAABIII (RtAudio Rust): /Users/madzine/Documents/OpenSource/WAAASAABIII/src/audio_rtaudio.rs
- WAAASAABIII (RtAudio C++): /Users/madzine/Documents/OpenSource/WAAASAABIII/rtaudio_wrapper.cpp
- WAAASAABIII (FFI): /Users/madzine/Documents/OpenSource/WAAASAABIII/src/rtaudio_ffi.rs
- VideoMixerRust: /Users/madzine/Documents/Commercial/VideoMixerRust/src/audio.rs

---

## AVAudioEngine 初始化模式 (Swift)

### 標準初始化流程
1. 建立 AVAudioEngine()
2. iOS: configureAudioSession()
3. macOS: selectDevice(deviceID) 透過 AudioUnit API
4. 讀取 engine.outputNode.outputFormat(forBus: 0)
5. 防禦檢查：guard sampleRate > 0, channelCount > 0
6. 建立 AVAudioSourceNode(format:) 自訂音源
7. engine.attach(source) -> engine.connect(source, to: mainMixerNode, format:)
8. engine.prepare()
9. usleep(50000) 讓 AUHAL 完成配置
10. try engine.start()

### 關鍵限制
- 同一裝置只能有一個 AVAudioEngine（兩個會導致 AUHAL 競爭，第二個靜默失敗）
- inputNode 和 outputNode 共享同一 AUAudioUnit，設定一次設備即可雙向
- prepare() 後的 50ms 延遲是必要的，否則 inputNode tap 可能收不到資料

### macOS 設備選擇
- engine.outputNode.audioUnit 取得底層 AudioUnit
- AudioUnitSetProperty(unit, kAudioOutputUnitProperty_CurrentDevice, kAudioUnitScope_Global, 0, &deviceID, size)
- 設備 ID 透過 CoreAudio API 枚舉：kAudioHardwarePropertyDevices -> 過濾有 output channel 的設備
- 通道數計算：kAudioDevicePropertyStreamConfiguration -> AudioBufferList -> 加總 mNumberChannels

### iOS AVAudioSession 設定
- 純播放：.playback, mode: .default, options: [.duckOthers]
- 錄放音：.playAndRecord, mode: .default, options: [.defaultToSpeaker]
- CV 精確輸出：.playback, mode: .measurement, options: [.mixWithOthers]
- measurement mode 減少系統對音訊的處理（自動增益等）
- mixWithOthers 讓 CV 不中斷其他 App

### 完整清理流程
- engine.stop()
- engine.detach(sourceNode)
- sourceNode = nil
- engine = nil（不能只 stop，需要完整釋放）

### 來源參考
- Edgy CVService: /Users/madzine/Documents/Commercial/Edgy/Services/CVService.swift
- JazzArchitect AudioEngine: /Users/madzine/Documents/Commercial/JazzArchitect/JazzArchitect-AU/JazzArchitectKit/Sources/Bridge/AudioEngine.swift
- V1 AppDelegate: /Users/madzine/Documents/Commercial/V1/App/Sources/AppDelegate.swift

---

## 設備持久化

### JUCE
- 儲存：deviceManager.createStateXml() -> PropertiesFile.setValue()
- 載入：PropertiesFile.getXmlValue() -> deviceManager.initialise(savedState)
- 儲存位置：~/Library/Application Support/MADZINE/AppName.settings
- 來源：Techno_Machine MainComponent.cpp

### Swift
- CVConfig: Codable struct，UserDefaults + JSONEncoder/Decoder
- 儲存 key 命名：AppName.ConfigName（如 "Edgy.OutputConfig"）
- 來源：Edgy OutputViewModel.swift

### Rust
- 目前無持久化（每次啟動使用 default_output_device）
- 如需實作：serde + JSON 序列化設備名稱到設定檔
