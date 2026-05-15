---
name: audio-device-errors
description: 音訊設備錯誤處理、中斷恢復、Thread Safety 的詳細參考
---

# Audio Device 錯誤處理 / 中斷恢復 / Thread Safety

## JUCE 錯誤處理

### 初始化錯誤
- initialise() / initialiseWithDefaultDevices() 返回 juce::String
- 空字串 = 成功，非空 = 錯誤訊息
- 錯誤時應顯示給使用者（StatusLabel 或 AlertWindow）
- 不要只 DBG 就忽略

### 設備切換錯誤
- setAudioDeviceSetup(setup, true) 返回非空字串 = 失敗
- 失敗原因：設備已斷開、格式不支援、被其他程式佔用
- 切換失敗時應保留原設備設定

### audioDeviceStopped 回調
- 設備斷開或被系統回收時觸發
- 必須釋放 buffer：setSize(0, 0) 或至少 clear()
- 呼叫 engine.releaseResources()
- 不要留空實作（JazzArchitect-JUCE 和 Techno_Machine 的空實作是反模式）
- KousatenMixer 的正確做法：釋放 inputBuffer + outputBuffer + engine.releaseResources()

### 未使用通道清零
- audioDeviceIOCallbackWithContext 中，outputChannelData 的未使用通道必須清零
- for (ch = usedChannels; ch < totalChannels; ++ch) clear(outputChannelData[ch])
- 不清零會產生雜訊或殘留音訊

### 來源參考
- KousatenMixer: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/MainComponent.cpp
- Techno_Machine: /Users/madzine/Documents/OpenSource/Techno_Machine/Source/MainComponent.cpp

---

## cpal/RtAudio 錯誤處理 (Rust)

### Stream Error Callback
- build_output_stream 的第三個參數是 error callback
- 目前做法：log::error 但不復原
- 已知不足：沒有自動重連機制
- 改進方向：error callback 中標記需要重建 stream，主線程定期檢查

### RtAudio C++ 錯誤包覆
- 所有 RtAudio 呼叫用 try/catch(...) 包覆
- 失敗返回 nullptr 或 -1
- Rust 端檢查返回值決定是否成功
- 析構函式中的錯誤一律忽略（catch(...) {}）

### default_output_config 失敗
- Fallback 到 (2ch, 48000Hz)
- 這不保證設備支援此格式，但是合理的預設
- 更好的做法：嘗試 supported_output_configs 取得範圍

### Mutex unwrap 在 callback 中的風險
- mutex.lock().unwrap() 如果 Mutex 被 poisoned 會 panic
- Panic 在 audio callback 中 = 整個程式 crash
- 改用 mutex.lock().ok() 或 try_lock() 更安全
- 最佳實踐：完全避免 Mutex，使用 atomic + lock-free 結構

### 來源參考
- WAAASAABIII: /Users/madzine/Documents/OpenSource/WAAASAABIII/src/audio.rs
- WAAASAABIII: /Users/madzine/Documents/OpenSource/WAAASAABIII/src/audio_rtaudio.rs
- VideoMixerRust: /Users/madzine/Documents/Commercial/VideoMixerRust/src/audio.rs

---

## AVAudioEngine 錯誤處理 (Swift)

### AVAudioSession 中斷處理
- 監聽 AVAudioSession.interruptionNotification
- 中斷開始（began）：記錄狀態，停止需要的處理
- 中斷結束（ended）兩種策略：
  - 音訊工具（節拍器、合成器、路由器）：用 wasRunningBeforeInterruption 旗標，中斷前在跑就恢復。使用者意圖比系統提示更可靠
  - 媒體播放器（串流、Podcast）：檢查 InterruptionOptions.shouldResume，尊重 Siri 等系統級暫停指令
- 恢復步驟：setCategory -> setActive(true) -> engine.start()，失敗則 fullRebuild
- 使用 @MainActor 確保線程安全
- observer 儲存為 NSObjectProtocol，在 teardown 時 removeObserver
- 來源：AZUMADO/ComplexRhythmer AudioEngine（wasRunning 模式）、V1 SystemInterruptionHandler（shouldResume 模式）

### Route Change 處理
- 監聽 AVAudioSession.routeChangeNotification（僅 iOS）
- 收到通知後：
  1. refreshDevices() 重新枚舉設備
  2. 如果當前設備仍可用：不做事
  3. 如果當前設備已斷開：重新 setup() + start()
- 來源：Edgy CVService + OutputViewModel

### AVAudioEngineConfigurationChange 處理（AZUMADO 實證 2026-03-07）
- 裝置切換（AudioUnitSetProperty kAudioOutputUnitProperty_CurrentDevice）後 ~10ms AVAudioEngine auto-stop（正常行為）
- **只做 prepare() + start() 不夠**：Apple 範例（AVAEGamingExample）要求重新 connect 所有 nodes
- **最穩健做法：fullRebuild**（detach sourceNode → setupAudio 重建 format → connect → start）
- **selectDevice 不應立即 start**：會被 auto-stop 殺死。設好裝置後讓 configChange notification → debounce → fullRebuild
- **多 IOProc 共用裝置**：CVAudioOutput 的 IOProc destroy/create 可能觸發 AVAudioEngine config change。用 suspend/resume flag 在 IOProc 操作期間靜默 configChange handler
- **防連鎖**：fullRebuild 前移除 observer，完成後延遲 0.5s 再註冊
- 參考：Apple AVAEGamingExample `makeEngineConnections()` 模式
- 來源：AZUMADO AudioEngine.swift handleConfigChange / selectDevice / suspendConfigChangeHandling

### engine.outputNode format 無效
- outputNode.outputFormat(forBus: 0) 可能返回 sampleRate=0 或 channelCount=0
- 必須加 guard 檢查，失敗時清理並返回
- 這在設備剛插入或系統音訊服務重啟時可能發生

### AVAudioEngine 完整清理
- engine.stop() 不夠，必須完整釋放
- 正確順序：engine.stop() -> engine.detach(node) -> node=nil -> engine=nil
- 只 stop 不 detach 會導致下次 setup 時 node 衝突

### AVAudioSession Category 切換
- 錄音前：.playAndRecord + .defaultToSpeaker
- 錄音後：.playback + .duckOthers
- 切換時需要 do { try setCategory... } catch
- 來源：V1 AppDelegate

### AlarmKit 已知 Bug
- Library/Sounds 的自訂音訊在 AlarmKit 中靜默降級為預設音效
- Apple Feedback: FB19779004
- 降級方案：鬧鐘用預設音效，App 前景時再播放實際音訊

---

## AUv3 特定錯誤

### 常見錯誤碼
- -10874 (TooManyFramesToProcess): maximumFramesToRender 太小
  - 解法：self.maximumFramesToRender = 1024（Logic Pro 非選中軌道用 1024）
- -10867 (Uninitialized): 未呼叫 allocateRenderResources
  - 解法：確保 allocateRenderResourcesAndReturnError 中完成所有初始化
- -66745 (RenderTimeout): render block 中有 real-time violation
  - 解法：檢查是否有 malloc、ObjC dispatch、mutex lock

### MIDIOutputEventBlock 為 nil
- 原因：缺少 MIDIOutputNames override
- 解法：必須 override MIDIOutputNames 並返回名稱陣列
- 取得方式：必須從 self.MIDIOutputEventBlock property 讀取（非 ivar）
- 在 allocateRenderResourcesAndReturnError 中快取

### Logic Pro 特定問題
- 非選中軌道不渲染（正常行為，非 bug）
- Sample rate 要從 output bus format 讀取（非 input）
- AUv3 MIDI FX 需要 Logic 10.7.3+

### 來源參考
- JazzArchitectAU: /Users/madzine/Documents/Commercial/JazzArchitect/JazzArchitect-AU/JazzArchitectAU/Shared/JazzArchitectAU.mm

---

## Audio Thread Safety Checklist

### 絕對禁止（所有語言通用）
- 記憶體分配：malloc、new、ARC retain/release、Vec::push、String::new
- 鎖：mutex.lock()、pthread_mutex_lock、@synchronized
- ObjC message dispatch（任何 [obj method] 呼叫）
- Swift 函式呼叫（Swift runtime 可能分配記憶體）
- 檔案 I/O：open、read、write、fopen
- 網路 I/O
- NSLog / print（可能加鎖）
- Render block 中 capture self（ARC 操作）

### 安全的替代方案
- atomic ops（std::atomic、AtomicBool、Atomic*）
- juce::SpinLock（短期鎖定，不被 OS 排程阻塞）
- try_lock / try_read（非阻塞，失敗就放棄）
- Pre-allocated buffer（在 prepareToPlay / allocateRenderResources 中分配）
- Lock-free ring buffer（SPSC 模式）
- 固定大小陣列（constexpr kMaxNotes = 16）
- __unsafe_unretained block capture（替代 ARC 的 self capture）
- UnsafeMutablePointer<Float> 直接讀寫（Float 寫入的原子性）

### AUv3 Render Block 特殊規則
- 不 capture self：使用 RenderBlockHolder C struct
- MIDIOutputEventBlock / transportStateBlock 在 allocateRenderResources 中快取
- double buffering：兩個 CachedData buffer，main thread 寫一個，render 讀另一個
- 固定大小陣列替代動態容器
