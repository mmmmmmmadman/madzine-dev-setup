---
name: ios-audio-engine
description: iOS AVAudioEngine 即時參數更新、VU Meter 實作、render block 安全模式的參考
---

# iOS AVAudioEngine 即時參數更新

## 核心原則：參數變更 vs 路由變更

AudioEngine 的 stop/start 成本極高（50ms+，中斷音訊）。必須區分：

| 變更類型 | 做法 | 範例 |
|---------|------|------|
| 參數變更 | 直接更新 atomic pointer | volume, mute, solo, test tone |
| 路由變更 | 完整 restart | input/output device, channel pair |

### 反模式（會導致聲音斷裂）
```swift
// 錯誤：每次 volume 變更都重建 engine
func updateTrack(_ index: Int, _ update: (inout TrackConfig) -> Void) {
    update(&config.tracks[index])
    if isRunning { restartEngine() }  // stop + start = 音訊中斷
}
```

### 正確模式
```swift
func updateTrack(_ index: Int, _ update: (inout TrackConfig) -> Void) {
    let oldTrack = config.tracks[index]
    update(&config.tracks[index])
    config.save()

    if isRunning {
        let newTrack = config.tracks[index]
        let routingChanged = oldTrack.inputDeviceUID != newTrack.inputDeviceUID
            || oldTrack.inputChannel != newTrack.inputChannel
            || oldTrack.outputDeviceUID != newTrack.outputDeviceUID
            || oldTrack.outputChannel != newTrack.outputChannel

        if routingChanged {
            restartEngine()
        } else {
            engine?.updateParameters(config: config)
        }
    }
}
```

## Atomic Pointer 模式

### 宣告（main thread 擁有）
```swift
private let volumePtr: UnsafeMutablePointer<Float> = {
    let p = UnsafeMutablePointer<Float>.allocate(capacity: 1)
    p.initialize(to: 1.0)
    return p
}()
```

### Main thread 寫入（engine 運行中安全）
```swift
func updateParameters(config: MixerConfig) {
    volumePtr.pointee = config.tracks.first?.volume ?? 1.0
    testTonePtr.pointee = config.testToneTrack == 0 ? 1.0 : 0.0
    if config.tracks.first?.mute == true {
        volumePtr.pointee = 0.0
    }
}
```

### Audio thread 讀取（render block 內）
```swift
let capturedVolumePtr = volumePtr  // closure capture
sourceNode = AVAudioSourceNode(format: fmt) { _, _, frameCount, abl -> OSStatus in
    let volume = capturedVolumePtr.pointee  // lock-free read
    // ... apply volume per sample ...
}
```

### 常用 atomic pointer 清單

| Pointer | 用途 | 寫入方 | 讀取方 |
|---------|------|--------|--------|
| volumePtr | 音量 0.0-1.0 | Main | Audio render |
| testTonePtr | 測試音開關 | Main | Audio render |
| inputLevelPtr | 輸入峰值計量 | Audio tap | Main (meter) |
| outputLevelPtr | 輸出峰值計量 | Audio render | Main (meter) |
| phasePtr | 振盪器相位 | Audio only | Audio only |
| fadeInPtr | 淡入計數器 | Audio only | Audio only |

## Render Block 安全規則

- 禁止：malloc, objc_msgSend, Swift ARC, lock/mutex, dispatch, I/O
- 允許：pointer read/write, C math (tanhf, sinf), SPSCRingBuffer
- Fade-in：前 4 個 callback 漸進音量（0.25 → 0.5 → 0.75 → 1.0）防 pop/click
- Soft clipping：tanhf(sample) 防混音超出 [-1,1]

---

# VU Meter：TimelineView + Canvas 模式

## 核心陷阱

TimelineView + Canvas 不會自動重繪，因為 SwiftUI diff 機制認為 Canvas 沒有變化。

### 反模式（meter 不顯示）
```swift
TimelineView(.periodic(from: .now, by: 1.0 / 20.0)) { _ in  // 忽略 context
    Canvas { context, size in
        let level = meter.trackLevel(0)  // 每次都讀，但 SwiftUI 不知道值變了
        // ... draw ...
    }
}
```

### 正確模式
```swift
TimelineView(.periodic(from: .now, by: 1.0 / 20.0)) { timeline in  // 取得 context
    Canvas { context, size in
        let level = meter.trackLevel(0)
        // ... draw ...
    }
    .id(timeline.date)  // 強制每次 tick 視為新 view → 重繪
}
```

### MeterState 設計

```swift
@MainActor
final class MeterState {
    private(set) var engine: AudioRouterEngine?
    func setEngine(_ e: AudioRouterEngine?) { engine = e }

    func trackLevel(_ index: Int) -> Float {
        guard let levels = engine?.trackLevels, index < levels.count else { return 0 }
        return levels[index]  // 直接讀 atomic pointer
    }
}
```

- 用 `@ObservationIgnored` 排除 MeterState，避免 @Observable macro 與 actor isolation 衝突
- TimelineView 以固定頻率（20-30Hz）讀取，不觸發 SwiftUI 標準變更追蹤
- 計量值在 audio thread 寫入 atomic pointer，main thread 讀取（benign race）

---

# SPSCRingBuffer 橋接模式

用於 inputNode.installTap() callback 與 sourceNode render block 之間：

```
Audio Input Thread          Audio Render Thread
installTap callback  ──→  SPSCRingBuffer  ──→  sourceNode render block
  rb.write(data)                                 rb.read(scratch)
```

- Power-of-2 capacity
- OSMemoryBarrier 確保跨線程可見性
- Prefill 2 buffers 防初始 underrun

---

# iOS titleBar / Safe Area 注意事項（已驗證 2026-03-13，AudioRouter 專案）

- titleBar 的 background 不要用 `.background { Color.ignoresSafeArea(.container, edges:) }` closure 寫法
- 這種寫法在 iPad 橫式模式下可能導致 titleBar 消失（高度歸零或被推到 safe area 外）
- 正確做法：直接用 `.background(Theme.bgPanel)`，與 macOS 一致

---

# iOS 多通道外接音訊介面（已驗證：Edgy v1.2.4 + ES-8）

## 核心原則

iOS 外接 USB Class Compliant 音訊介面時，系統自動使用全部通道，不需要手動請求。

### 正確做法
```swift
// 1. Session 設定不需要額外通道請求
try session.setCategory(.playAndRecord, mode: .measurement,
                        options: [.defaultToSpeaker, .mixWithOthers])
try session.setActive(true)

// 2. 從 currentRoute 取得實際通道數
let channelCount = session.currentRoute.outputs.first?.channels?.count ?? 2

// 3. 用 DiscreteInOrder layout 建立多通道格式
let layout = AVAudioChannelLayout(
    layoutTag: kAudioChannelLayoutTag_DiscreteInOrder | UInt32(channelCount))!
let format = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: sampleRate,
    interleaved: false,
    channelLayout: layout)
```

### 反模式（不要使用）
```swift
// 錯誤：手動請求通道數 — iOS 外接介面不需要
try session.setPreferredOutputNumberOfChannels(session.maximumOutputNumberOfChannels)

// 錯誤：standardFormat 會假設 stereo layout，多通道介面會出問題
AVAudioFormat(standardFormatWithSampleRate: sr, channels: 16)

// 錯誤：直接用 outputNode.outputFormat — 路由切換時可能返回無效格式
engine.outputNode.outputFormat(forBus: 0)
```

## Route Change 處理

外接介面插拔時必須完整重建：
1. engine.stop()
2. teardownAudio()（移除 tap、detach node）
3. configureSession()（重新 setActive）
4. 重新查詢 currentRoute.outputs channel count
5. 用新 channel count 重建格式 + setupAudio()
6. engine.start()

## 參考專案補充

| 模式 | 來源 |
|------|------|
| DiscreteInOrder 多通道 | Edgy CVService |
| ES-8 route change | Edgy OutputViewModel |

---

# 參考專案

| 模式 | 來源 |
|------|------|
| Atomic pointer volume | AudioRouter AVAudioRouterEngine |
| TimelineView + Canvas meter | AudioRouter ContentView |
| iOS fullRebuild | AZUMADO AudioEngine |
| SPSCRingBuffer | KousatenMixer RtOutputStream |
| 自動啟動 + Reset Clock | AudioRouter ViewModel |
| DiscreteInOrder 多通道 ES-8 | Edgy CVService |
