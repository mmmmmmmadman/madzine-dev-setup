---
name: multichannel-audio-ref
description: Apple 多聲道音訊開發快速參考。涵蓋 CoreAudio HAL、AVAudioSession、AVAudioEngine 聲道映射、即時安全規則、中斷恢復、macOS 26 變動。
---

# Apple 多聲道音訊介面開發快速參考

基於研究文件：/Users/madzine/Documents/Research/Apple_Multichannel_Audio_Research_v2.2_2026.md

---

## CoreAudio 架構分層

- macOS：HAL 直接存取硬體 -> AUHAL（Audio Unit 封裝 HAL）-> 應用層
- iOS：AVAudioSession 管理硬體 -> RemoteIO -> 應用層
- 跨平台：AVAudioEngine 建構在 Audio Unit 之上

---

## macOS CoreAudio HAL 裝置列舉

```
AudioObjectGetPropertyData + AudioObjectPropertyAddress
根節點：kAudioObjectSystemObject
```

| 屬性 | 用途 |
|------|------|
| kAudioHardwarePropertyDevices | 列舉所有裝置 |
| kAudioDevicePropertyStreamConfiguration | 查詢聲道配置（返回 AudioBufferList）|
| kAudioDevicePropertyStreams | 查詢串流 ID |
| kAudioDevicePropertyNominalSampleRate | 查詢/設定硬體採樣率 |
| kAudioDevicePropertyAvailableNominalSampleRates | 查詢支援的採樣率範圍 |
| kAudioDevicePropertyBufferFrameSize | 設定 buffer 大小 |

---

## AUHAL Element 慣例

- Element 0 = 輸出端（到喇叭）
- Element 1 = 輸入端（從麥克風）
- C API 和 AUAudioUnit 一致

---

## 聲道映射：kAudioOutputUnitProperty_ChannelMap

SInt32 陣列，長度 = 目標端聲道數，-1 = 靜音

**輸入端（從 8ch 介面讀取聲道 3-4）：**
```swift
var inputChannelMap: [SInt32] = [2, 3]
// 設在 kAudioUnitScope_Output, element 1
```

**輸出端（立體聲路由到 8ch 裝置聲道 3-4）：**
```swift
var outputChannelMap: [SInt32] = [-1, -1, 0, 1, -1, -1, -1, -1]
// 設在 kAudioUnitScope_Output, element 0
```

---

## iOS AURemoteIO 多聲道 USB（直接 render callback）

AVAudioEngine 的 channelMap 在 iOS USB 場景下無效（被內部 mixer 覆蓋）。直接 AURemoteIO 才有效。

**正確設定順序：**
1. AVAudioSession: setCategory → setActive → setPreferred → 讀取 actual
2. ASBD: non-interleaved float, mChannelsPerFrame = actual（回讀驗證，CoreAudio 靜默降級不報錯）
3. Channel Layout: `kAudioChannelLayoutTag_Unknown | chCount`（DiscreteInOrder 導致 ch1-2 靜音）
4. Channel Map（必要）: 1:1 identity, `kAudioUnitScope_Output, element 0`。沒有它系統對未宣告 channel 保留舊 buffer
5. Channel 切換: 斷開變更選項 → flush 30ms → Stop+Reset+Start → 套用新值

---

## AudioChannelLayout 空間語義

- Channel Map = 資料流向（哪條管道接哪個硬體聲道）
- Channel Layout = 空間語義（聲道在三維空間中的方位）
- 兩者需協同使用
- AVAudioEngine 中：AVAudioFormat init(standardFormatWithSampleRate:channelLayout:)

---

## Aggregate Device 時鐘同步

| 項目 | 軟體補償（HAL ASRC）| 硬體 Word Clock |
|------|---------------------|-----------------|
| 機制 | 取樣點丟棄/插入 | 外部基準時鐘鎖定 |
| 相位完整性 | 被破壞 | 完全對齊 |
| 延遲 | 額外約一個 buffer | 無額外延遲 |
| 32 frames 下限制 | 約 10-15 分鐘出現相位異常 | 無限制 |
| 適用場景 | 一般多聲道錄音/監聽 | 相位關鍵應用（多喇叭陣列）|

建立後需 CFRunLoopRunInMode 約 0.1 秒等待初始化。

---

## iOS AVAudioSession 多聲道

**關鍵 API：**
- setCategory(_:mode:options:)
- setPreferredIOBufferDuration(_:)（僅提示）
- setPreferredInputNumberOfChannels / setPreferredOutputNumberOfChannels
- maximumInputNumberOfChannels / maximumOutputNumberOfChannels

**重要限制：**
- 沒有 availableOutputs 或 setPreferredOutput API
- 輸出選擇僅能透過 .multiRoute category 間接管理

**USB 供電：**
- Lightning：必須用帶充電埠的轉接器（MK0W2）
- USB-C：建議供電式 Hub
- 供電不足症狀：裝置不出現、間歇斷線、聲道不足、隨機爆音

---

## AVAudioEngine 三種聲道映射方法

### 方法 A：auAudioUnit.channelMap（推薦）
```swift
let outputFormat = engine.outputNode.outputFormat(forBus: 0)
engine.connect(engine.mainMixerNode, to: engine.outputNode, format: outputFormat)
engine.connect(sourceNode, to: engine.mainMixerNode, format: outputFormat)
sourceNode.auAudioUnit.channelMap = [0, 1, -1, -1] as [NSNumber]
```
前提：必須明確連接 mainMixerNode -> outputNode。channelMap 不適用於 AVAudioMixerNode。

### 方法 B：C API 設定 outputNode channel map
```swift
AudioUnitSetProperty(au, kAudioOutputUnitProperty_ChannelMap,
    kAudioUnitScope_Global, 0, &channelMap, size)
```
適用於全域路由。

### 方法 C：輸入端聲道分離
```swift
leftInputMixer.auAudioUnit.channelMap = [0] as [NSNumber]   // 只取聲道 1
rightInputMixer.auAudioUnit.channelMap = [1] as [NSNumber]  // 只取聲道 2
```

### macOS 設定特定裝置
```swift
AudioUnitSetProperty(unit, kAudioOutputUnitProperty_CurrentDevice,
    kAudioUnitScope_Global, 0, &deviceID, size)
```

---

## 即時音訊執行緒安全四條鐵律

1. 禁止記憶體分配（malloc、new、Swift Array append、ObjC alloc）
2. 禁止鎖定/互斥（pthread_mutex_lock、os_unfair_lock、NSLock、DispatchQueue.sync）
3. 禁止 ObjC 訊息傳遞（ObjC runtime 內部會獲取鎖，Swift ARC 亦然）
4. 禁止阻塞 I/O（檔案讀取、網路呼叫）

DSP 核心用 C/C++，管理層用 Swift。Swift 5.9+ 支援 -cxx-interoperability-mode=default。

---

## 低延遲參考

| 平台 | Buffer | 估計往返延遲 |
|------|--------|-------------|
| macOS 32 frames @ 48kHz | 0.67ms/buffer | ~3ms |
| macOS 128 frames @ 48kHz | 2.67ms/buffer | ~6ms |
| iOS 最低 ~256 frames | ~5.3ms/buffer | ~10ms |
| iOS 預設 ~1024 frames | ~21ms/buffer | ~30ms |

- 直接連接法：inputNode -> mainMixerNode（最低延遲）
- installTap 用於觀察/分析，不應作為 pass-through
- 採樣率不匹配時 HAL 靜默啟動 ASRC（無錯誤/警告），多聲道 SRC CPU 開銷與聲道數成正比

---

## 容錯與中斷恢復

### 熱插拔
- AVAudioEngineConfigurationChangeNotification：收到時引擎已停止
- 必須重建整個音訊圖形再啟動
- 重建時聲道數可能已改變，所有 channel map 須重算

### iOS 中斷恢復流程
1. 重新啟用 session（setCategory + setActive）
2. 驗證 maximumOutputNumberOfChannels 是否恢復
3. 若不足則重新 setPreferredOutputNumberOfChannels
4. 驗證 outputNumberOfChannels 實際值
5. 根據實際聲道數重建 channel map
6. 重建並啟動 AVAudioEngine

### Category Options 注意
- .mixWithOthers + 多聲道 USB：可能觸發 route change，聲道配置重置
- .multiRoute 不支援 .mixWithOthers

---

## macOS 26 變動

- usbaudiod：USB 音訊驅動從 kernel extension 遷移至 userspace daemon
- AppleUSBAudioEngine IOService 不再建立
- CoreAudio HAL API 仍正常運作，應以 HAL API 為唯一硬體存取路徑
- 廣泛音訊穩定性問題（HDMI、Thunderbolt、USB）
- RME FireWire 支援終止

### 系統級除錯
```bash
# 即時監控
log stream --predicate 'process == "coreaudiod" || process == "usbaudiod"' --level debug

# HAL overload（爆音指標）
log stream --predicate 'process == "coreaudiod" && eventMessage CONTAINS "HALS_OverloadMessage"'

# 過去 5 分鐘錯誤
log show --last 5m --predicate 'subsystem == "com.apple.coreaudio" && messageType == error'
```

除錯順序：log stream 確認錯誤類型 -> Instruments Audio System Trace -> 增大 buffer 測試 -> 換 USB 埠測試

---

## iOS 26 新功能
- AVInputPickerInteraction：app 內音訊輸入選擇 UI
- bluetoothHighQualityRecording：AirPods 高品質錄音
- AVAssetWriter FOA 空間音訊擷取（4ch Ambisonics）

---

## MIDI 2.0 與音訊時間戳

- CoreMIDI 和 CoreAudio 共用 mach_absolute_time()
- USB MIDI 精度：約 100 微秒（~5 samples @ 48kHz）
- 藍牙 MIDI（BLE-MIDI）：典型 3-20ms，視裝置與 BLE 版本而定
- macOS 11 / iOS 14 起支援 UMP（32-bit 控制器解析度）

---

## 跨平台差異速查

| 功能 | macOS | iOS |
|------|-------|-----|
| 裝置列舉 | AudioObjectGetPropertyData | AVAudioSession.availableInputs |
| 裝置選擇 | kAudioOutputUnitProperty_CurrentDevice | setPreferredInput |
| Buffer 大小 | kAudioDevicePropertyBufferFrameSize | setPreferredIOBufferDuration |
| AVAudioSession | 不存在 | 必需 |

---

## 參考文獻來源
完整研究文件：/Users/madzine/Documents/Research/Apple_Multichannel_Audio_Research_v2.2_2026.md
