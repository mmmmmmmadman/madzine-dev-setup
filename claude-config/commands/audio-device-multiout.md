---
name: audio-device-multiout
description: 多設備輸出、Ring Buffer、Lock-free 設計的詳細參考
---

# 多設備輸出 / Ring Buffer / Lock-free 設計

## JUCE + RtAudio 雙引擎架構 (KousatenMixer)

### 架構概念
- JUCE AudioDeviceManager 管理主設備（透過 AudioIODeviceCallback）
- RtAudio 6.x 管理額外設備（每個 Aux Output 獨立設備）
- 主 audio callback 中產生音訊，透過 ring buffer 傳遞到 RtAudio 串流
- JUCE 只能管一個設備，所以額外設備必須用 RtAudio

### Ring Buffer 設計
- 大小：bufferSize * numChannels * 8（8 倍安全邊際，源自 VCV Rack 慣例）
- Pre-fill：writePos = bufferSize * numChannels * 2（預填 2 buffer 靜音）
- 讀取後清零：ringBuffer[pos] = 0.0f（防止殘留音訊被重複讀取）
- 原子操作：writePos 和 readPos 使用 std::atomic<size_t>
- 記憶體順序：寫入用 release，讀取用 acquire

### writeToStream 安全模式
- 先原子檢查 streamsActive（lock-free 快速路徑）
- 使用 try_to_lock 嘗試加鎖（不阻塞 audio thread）
- 如果鎖被佔用就跳過這次寫入（寧願靜音不卡頓）
- 取到鎖後寫入 ring buffer

### switchDeviceAsync 安全流程
- 在 MessageManager::callAsync 中執行（message thread）
- stopAll(): 原子標記 false -> sleep(10ms) -> 加鎖停止所有串流
- sleep(50ms) 等硬體穩定
- 執行切換操作（destroy + create）
- startAll(): 清空 buffer -> 重設 read/write pos -> 啟動 -> 原子標記 true

### SpinLock vs Mutex
- Audio thread 中用 juce::SpinLock（短期鎖定，不被 OS 排程阻塞）
- 非 audio thread 中用 std::mutex（長期操作）
- SpinLock 只用於保護集合操作（如 channel 列表遍歷）

### 來源參考
- RtAudioManager: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/Core/RtAudioManager.h (.cpp)
- AudioDeviceHandler: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/Core/AudioDeviceHandler.h (.cpp)
- AuxBus: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/Mixer/AuxBus.h (.cpp)
- MainComponent: /Users/madzine/Documents/OpenSource/KousatenMixer/Source/MainComponent.cpp

---

## Rust RtAudio FFI 多設備 (WAAASAABIII)

### Master/Secondary Stream 架構
- 第一個開啟的 stream 自動成為 master
- Master stream 的 callback 由 RtAudio 硬體驅動
- Master callback 中：
  1. 呼叫 Rust ProcessCallback(device_id=master, offset=N)
  2. 寫入 master 設備的 channel offset 位置
  3. 遍歷所有 secondary stream
  4. 對每個 secondary 呼叫 ProcessCallback(device_id=secondary, offset=M)
  5. 寫入 secondary 的 ring buffer
- Secondary callback 從 ring buffer 讀取並輸出

### ProcessCallback 設備過濾
- callback 簽名包含 device_id 和 channel_offset
- Rust 端遍歷所有 track，跳過 output_device_id != device_id 的 track
- 解決了「切換設備後舊設備繼續播放」的問題

### Lock-free Linked List（Secondary Stream 管理）
- 新增：compare_exchange_weak 原子 prepend 到 linked list 頭部
- 移除：mark-for-removal 模式（設定 atomic bool removed=true）
- Callback 中跳過 removed=true 的節點
- 實際記憶體清理在 stream close 時進行
- 避免在 callback 中 delete 節點（記憶體分配禁止）

### f64 -> AtomicU64 Bit Pattern 技巧
- 寫入：volume_bits.store(volume.to_bits(), Release)
- 讀取：f64::from_bits(volume_bits.load(Acquire)) as f32
- 因為 Rust 沒有 AtomicF64，用 u64 存 f64 的 bit pattern
- 應用於 volume、current_time 等需要跨線程的 f64 值

### try_read + spin_loop + 放棄模式
- 第一次 try_read() 失敗 -> spin_loop() 讓出 CPU
- 第二次 try_read() 失敗 -> return（輸出靜音）
- 永遠不阻塞 audio thread
- 比 VideoMixerRust 的 mutex.lock().unwrap() 安全

### C++ Wrapper 要點
- extern "C" 匯出所有函式
- 每個 stream 用獨立的 RtAudio 實例
- StreamData struct 包含 rtaudio 實例 + ring buffer + fade state
- 所有 RtAudio 呼叫用 try/catch(...) 包覆
- 析構函式中：stopStream -> closeStream -> delete rtaudio

### 來源參考
- audio_rtaudio.rs: /Users/madzine/Documents/OpenSource/WAAASAABIII/src/audio_rtaudio.rs
- rtaudio_wrapper.cpp: /Users/madzine/Documents/OpenSource/WAAASAABIII/rtaudio_wrapper.cpp
- rtaudio_ffi.rs: /Users/madzine/Documents/OpenSource/WAAASAABIII/src/rtaudio_ffi.rs

---

## 通道路由

### channel_offset 概念
- 多通道介面（如 ES-8 8ch）可分配多組立體聲
- offset=0: 通道 1-2、offset=2: 通道 3-4、以此類推
- output_params.nChannels 開啟設備全部通道
- 在 callback 中只寫入 offset 和 offset+1 的位置
- 其他通道保持靜音（先 memset 清零整個 buffer）

### JUCE 通道報告不準
- 已知問題：多通道介面常報告比實際少的通道數
- 解法：硬編碼已知品牌名稱 fallback
  - ES-、Focusrite、MOTU、RME、Aggregate、Multi-Output -> 16ch
  - 其他未知設備且報告 0ch -> 8ch
- 掃描時臨時建立設備查詢通道（createDevice -> getChannelNames -> delete）

### CV 輸出通道分配
- 通道 0-1: 音訊主輸出（立體聲）
- 通道 2+: CV/Gate/Trigger 輸出
- 每個 voice 佔 2 通道（pitch CV + gate）
- 來源：Techno_Machine CVOutputRouter

---

## Lock-free 通訊模式

### Atomic TrackState (Rust)
- 所有欄位使用 Atomic 類型
- AtomicBool: is_playing, muted, loop_enabled
- AtomicU64: current_time_bits, volume_bits (f64 bit pattern)
- has_seek_request + seek_request_bits: 原子 seek 機制
- UI thread 寫入，audio callback 讀取

### UnsafeMutablePointer<Float> (Swift CV)
- 為每個 CV 通道分配 UnsafeMutablePointer<Float>
- UI thread 直接寫入（Float 寫入在大多數平台上是 atomic 的）
- Render callback 直接讀取
- 不需要鎖或 atomic（Float 單次寫入的特性）
- 來源：Edgy CVService

### 已知反模式
- mutex.lock().unwrap() 在 audio callback 中（VideoMixerRust）
  - 阻塞式取鎖，UI 持鎖時音訊卡頓
  - unwrap() 可能 panic 導致 crash
- 改用 try_lock / try_read + 放棄模式
