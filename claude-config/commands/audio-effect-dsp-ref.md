---
name: audio-effect-dsp-ref
description: 音訊效果器 DSP 開發快速參考。涵蓋 TCC/Sandbox 權限、AVAudioSession 配置、AVAudioEngine 節點連接、即時安全規則、Ring Buffer、AUv3 封裝、參數平滑、延遲補償、無縫繞道、vDSP 向量化、CI/CD 測試。
---

# macOS/iOS 音訊效果器 DSP 開發參考

## 1. 問題診斷框架

| 問題類型 | 典型症狀 | 可能原因 |
|----------|----------|---------|
| A: 完全無聲 | buffer 全零 | TCC 權限、Sandbox Entitlements、AVAudioSession 未啟用、Engine 未啟動、Background Mode 缺失 |
| B: 效果器無作用 | dry signal 通過 | 節點連接順序錯誤、DSP 未插入處理鏈、格式不匹配、installTap 誤用、AUv3 bus 配置錯誤 |
| C: 爆音/卡頓 | CPU 尖峰 | Render callback 超時、採樣率不匹配、buffer 過小、執行緒優先級不足、跨裝置時鐘漂移 |
| D: 間歇性失效 | 拔插後失效 | 中斷恢復邏輯缺失、配置變更未重建、Background Mode 未開啟 |
| E: EXC_BAD_ACCESS | 頁面切換崩潰 | AVAudioEngine 銷毀順序錯誤、render callback 中存取已釋放物件 |

### 排查流程 A：完全無聲
1. Info.plist 包含 NSMicrophoneUsageDescription？
2. [macOS] Sandbox entitlements 包含 com.apple.security.device.audio-input？
3. 已呼叫 requestAccess(for: .audio) 且使用者授權？
4. AVAudioSession category 為 .playAndRecord？
5. setActive(true) 成功？
6. engine.start() 成功？
7. inputNode.outputFormat channelCount > 0？
8. render callback 中 buffer 是否全零？（TCC 問題）
9. [iOS] Background Modes 開啟 Audio？

### 排查流程 B：效果器無作用
1. 效果器節點已 attach？
2. 效果器節點已 connect 到處理鏈？（input -> effect -> mixer）
3. 是否在 installTap 中修改 buffer？（installTap 不影響輸出）
4. wetDryMix 是否為 0？
5. format 一致（sampleRate、channelCount）？
6. DSP render callback 是否違反即時安全規則？
7. [AUv3] pullInputBlock 被呼叫且返回 noErr？

---

## 2. 權限與沙盒

### TCC 權限
```xml
<key>NSMicrophoneUsageDescription</key>
<string>本 App 需要存取麥克風以進行音訊效果處理</string>
```

```swift
AVCaptureDevice.requestAccess(for: .audio) { granted in
    if granted { /* 可安全啟動 AVAudioEngine 輸入 */ }
}
```

重置權限：`tccutil reset Microphone`

### macOS App Sandbox Entitlements
```xml
<!-- 音訊輸入 — 缺少 = 全零 buffer -->
<key>com.apple.security.device.audio-input</key>
<true/>
<!-- USB 裝置 — 缺少 = 外接介面不可見 -->
<key>com.apple.security.device.usb</key>
<true/>
```

除錯：暫時關閉 App Sandbox 測試是否恢復。

### iOS Background Modes
Target -> Signing & Capabilities -> Background Modes -> Audio, AirPlay, and Picture in Picture

```xml
<key>UIBackgroundModes</key>
<array><string>audio</string></array>
```

缺失 = 進入後台約 3 秒後 AVAudioEngine 暫停。

---

## 3. AVAudioSession 配置（iOS）

```swift
let session = AVAudioSession.sharedInstance()
try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
try session.setPreferredIOBufferDuration(0.005)  // ~5ms
try session.setActive(true)

// 驗證實際採樣率
let actualSR = session.sampleRate
```

- category 必須是 .playAndRecord（效果器需要輸入+輸出）
- setCategory 必須在 setActive(true) 之前
- .defaultToSpeaker 將輸出從聽筒切到揚聲器
- setActive(true) 不要用 try? 忽略錯誤

---

## 4. AVAudioEngine 節點連接

### 四大原則
1. 先 attach，再 connect，最後 start
2. 所有連接在 engine.start() 前完成
3. connect 時明確指定 format
4. 效果器必須插入 inputNode 和 outputNode 之間

### 正確連接模式
```swift
engine.attach(effectNode)
let inputFormat = engine.inputNode.outputFormat(forBus: 0)
engine.connect(engine.inputNode, to: effectNode, format: inputFormat)
engine.connect(effectNode, to: engine.mainMixerNode, format: inputFormat)
engine.prepare()
try engine.start()
```

### installTap 不是效果器插入點
installTap 是觀察/分析用 API，在 tap block 中修改 buffer 不影響輸出。效果器必須用 AVAudioUnitEffect 子類或 AVAudioSourceNode。

### 聲道映射

場景 A：單聲道 -> 立體聲（mainMixerNode 自動處理 1ch -> 2ch）
```swift
let monoFormat = inputFormat  // 1ch
engine.connect(engine.inputNode, to: effectNode, format: monoFormat)
engine.connect(effectNode, to: engine.mainMixerNode, format: monoFormat)
engine.connect(engine.mainMixerNode, to: engine.outputNode, format: outputFormat)  // 2ch
```

場景 B：多聲道精確路由（kAudioOutputUnitProperty_ChannelMap）
```swift
// 輸入端：讀取裝置聲道 3, 4
if let inputUnit = engine.inputNode.audioUnit {
    var inputMap: [SInt32] = [2, 3]
    AudioUnitSetProperty(inputUnit, kAudioOutputUnitProperty_ChannelMap,
        kAudioUnitScope_Output, 1, &inputMap,
        UInt32(inputMap.count * MemoryLayout<SInt32>.size))
}

// 輸出端：來源 ch0 -> 裝置 ch5, 來源 ch1 -> 裝置 ch6
if let outputUnit = engine.outputNode.audioUnit {
    var outputMap = [SInt32](repeating: -1, count: 18)
    outputMap[4] = 0; outputMap[5] = 1
    AudioUnitSetProperty(outputUnit, kAudioOutputUnitProperty_ChannelMap,
        kAudioUnitScope_Output, 0, &outputMap,
        UInt32(outputMap.count * MemoryLayout<SInt32>.size))
}
```

場景 C：per-node 路由（auAudioUnit.channelMap，僅適用 source 節點）
```swift
sourceNodeA.auAudioUnit.channelMap = [0, 1, -1, -1, -1, -1, -1, -1] as [NSNumber]
sourceNodeB.auAudioUnit.channelMap = [-1, -1, 0, 1, -1, -1, -1, -1] as [NSNumber]
```

---

## 5. DSP Render Callback 即時安全

### 四條鐵律
1. 禁止記憶體分配：malloc、new、Swift Array append、ObjC alloc
2. 禁止鎖/互斥：pthread_mutex_lock、os_unfair_lock、NSLock、DispatchQueue.sync
3. 禁止 ObjC 訊息傳遞：ObjC runtime 內部會獲取鎖，Swift ARC 亦然
4. 禁止阻塞 I/O：檔案讀取、網路、print/NSLog

DSP 核心應使用 C/C++ 編寫，管理層和 UI 使用 Swift。

### 常見違規
- render callback 中呼叫 print()/NSLog()
- render callback 中建立 Swift Array/String
- render callback 中存取 @Published/@ObservableObject
- render callback 中使用 DispatchQueue.main.async（應改用 ring buffer）

### 安全的參數傳遞：原子操作
```swift
import Atomics
let wetDryMix = ManagedAtomic<Float>(0.5)

// UI 執行緒寫入
func setWetDryMix(_ value: Float) {
    wetDryMix.store(value, ordering: .relaxed)
}

// render callback 讀取
func getCurrentMix() -> Float {
    wetDryMix.load(ordering: .relaxed)
}
```

### C++ 記憶體屏障

單一值：
```cpp
std::atomic<float> gain{1.0f};
// UI: gain.store(g, std::memory_order_relaxed);
// Render: gain.load(std::memory_order_relaxed);
```

複合結構（雙緩衝 flag-guarded swap）：
```cpp
struct FilterParams { float cutoff; float resonance; int type; };
FilterParams params[2];
std::atomic<int> activeIndex{0};

// UI 寫入
void setFilterParams(float cutoff, float resonance, int type) {
    int writeIdx = 1 - activeIndex.load(std::memory_order_relaxed);
    params[writeIdx] = {cutoff, resonance, type};
    std::atomic_thread_fence(std::memory_order_release);
    activeIndex.store(writeIdx, std::memory_order_relaxed);
}

// Render 讀取
FilterParams getFilterParams() const {
    int readIdx = activeIndex.load(std::memory_order_relaxed);
    std::atomic_thread_fence(std::memory_order_acquire);
    return params[readIdx];
}
```

---

## 6. 無鎖環形緩衝區（Ring Buffer）

SPSC（Single Producer Single Consumer），音訊執行緒寫入、UI 執行緒讀取。

```swift
import Atomics

final class RingBuffer<T> {
    private let buffer: UnsafeMutableBufferPointer<T>
    private let capacity: Int
    private let writeIndex = ManagedAtomic<Int>(0)
    private let readIndex = ManagedAtomic<Int>(0)

    init(capacity: Int, defaultValue: T) {
        self.capacity = capacity
        self.buffer = .allocate(capacity: capacity)
        buffer.initialize(repeating: defaultValue)
    }

    @inline(__always)
    func write(_ value: T) -> Bool {
        let w = writeIndex.load(ordering: .relaxed)
        let r = readIndex.load(ordering: .acquiring)
        guard (w - r) < capacity else { return false }
        buffer[w % capacity] = value
        writeIndex.store(w + 1, ordering: .releasing)
        return true
    }

    @inline(__always)
    func read() -> T? {
        let r = readIndex.load(ordering: .relaxed)
        let w = writeIndex.load(ordering: .acquiring)
        guard r < w else { return nil }
        let value = buffer[r % capacity]
        readIndex.store(r + 1, ordering: .releasing)
        return value
    }
}
```

記憶體順序：releasing（寫入端）確保資料可見，acquiring（讀取端）確保讀到最新資料。

---

## 7. AUv3 App Extension 封裝

### 專案結構
```
MyEffectApp/
├── MyEffectApp/           <- 容器 app
├── MyEffectExtension/     <- AUv3 extension target
│   ├── Info.plist         <- NSExtension 配置
│   ├── AudioUnit.swift    <- AUAudioUnit 子類
│   ├── DSP.cpp            <- C++ DSP 核心
│   └── ViewController.swift
└── Shared/
```

### Info.plist NSExtension 配置
```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.AudioUnit-UI</string>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>AudioComponents</key>
        <array><dict>
            <key>type</key><string>aufx</string>
            <key>subtype</key><string>myFX</string>
            <key>manufacturer</key><string>MyMf</string>
            <key>sandboxSafe</key><true/>
            <key>tags</key><array><string>Effects</string></array>
        </dict></array>
    </dict>
</dict>
```

- type: aufx (effect), aumu (instrument), aumf (MIDI effect)
- sandboxSafe 必須為 true（否則 Logic Pro 不載入）
- 驗證：auval -v aufx myFX MyMf

### internalRenderBlock 關鍵
```swift
public override var internalRenderBlock: AUInternalRenderBlock {
    let kernel = dspKernel  // 捕獲指標，避免捕獲 self
    return { [kernel] actionFlags, timestamp, frameCount,
              outputBusNumber, outputData, renderEvent, pullInputBlock in
        var pullFlags: AudioUnitRenderActionFlags = []
        let status = pullInputBlock?(&pullFlags, timestamp,
            frameCount, 0, outputData) ?? kAudioUnitErr_NoConnection
        guard status == noErr else { return status }
        kernel.process(outputData, frameCount: frameCount)
        return noErr
    }
}
```

### channelCapabilities（AUv3 宣告支援的聲道配置）
```swift
public override var channelCapabilities: [NSNumber]? {
    return [1, 1, 2, 2, 6, 6, -1, -1]
    // mono->mono, stereo->stereo, 5.1->5.1, any->same
}
```

---

## 8. 參數平滑與 Zipper Noise 消除

### 單極低通濾波器（即時安全）
```cpp
class ParameterSmoother {
    float current, target, coeff;
public:
    void init(float initialValue, float smoothTimeMs, float sampleRate) {
        current = target = initialValue;
        float tau = smoothTimeMs * 0.001f * sampleRate;
        coeff = expf(-1.0f / tau);
    }
    void setTarget(float t) { target = t; }
    float getNext() {
        current = target + coeff * (current - target);
        return current;
    }
    bool isSettled() const { return fabsf(current - target) < 1e-6f; }
};
```

### 平滑時間指引
| 參數類型 | 建議平滑時間 | 原因 |
|----------|------------|------|
| Gain/Volume | 5-10ms | 太短有 zipper noise，太長遲鈍 |
| Pan | 5-10ms | 空間位置需平滑 |
| Filter cutoff | 1-5ms | 太長使 sweep 失去銳度 |
| Wet/Dry mix | 10-20ms | 較長的交叉淡入淡出 |
| 開關型（bypass） | crossfade 5-20ms | 不適合單極平滑 |

isSettled() 優化：收斂後跳過計算可減少 >99% 運算量。

---

## 9. 無縫繞道（Seamless Bypass）

```cpp
class SeamlessBypass {
    float bypassMix = 0.0f;   // 0 = 全效果，1 = 全 bypass
    float targetMix = 0.0f;
    float fadeStep;
public:
    void init(float sampleRate, float fadeTimeMs) {
        fadeStep = 1.0f / (fadeTimeMs * 0.001f * sampleRate);
    }
    void setBypass(bool bypass) { targetMix = bypass ? 1.0f : 0.0f; }
    float process(float dryInput, float wetInput) {
        if (bypassMix < targetMix) bypassMix = fminf(bypassMix + fadeStep, targetMix);
        else if (bypassMix > targetMix) bypassMix = fmaxf(bypassMix - fadeStep, targetMix);
        return wetInput * (1.0f - bypassMix) + dryInput * bypassMix;
    }
    bool isFullyBypassed() const { return bypassMix >= 0.999f; }
};
```

等功率 crossfade 版本：dryGain = cosf(bypassMix * M_PI * 0.5)

---

## 10. 延遲補償

### 常見延遲來源
| 算法 | 典型延遲 | 原因 |
|------|---------|------|
| FFT 處理 | N/2 samples | 需累積一整個 FFT window |
| Look-ahead Limiter | 1-10ms | 需預讀訊號 |
| Linear-phase EQ | 數百 samples | FIR 群延遲 |
| IIR filter / gain | 0 samples | 即時逐 sample |

### AUv3 回報延遲
```swift
public override var latency: TimeInterval {
    return Double(fftSize / 2) / inputBus.format.sampleRate
}

// 延遲動態改變時通知 host
func updateLatency() {
    willChangeValue(forKey: "latency")
    didChangeValue(forKey: "latency")
}
```

### 獨立 app 並聯對齊（CompensationDelay）
```swift
class CompensationDelay {
    private var buffer: [Float]
    private var writePos = 0
    private let delaySamples: Int
    init(delaySamples: Int) {
        self.delaySamples = delaySamples
        buffer = [Float](repeating: 0.0, count: delaySamples)
    }
    func process(_ input: Float) -> Float {
        let output = buffer[writePos]
        buffer[writePos] = input
        writePos = (writePos + 1) % delaySamples
        return output
    }
}
```

---

## 11. 離線渲染

```swift
func offlineRender(inputFile: AVAudioFile, outputFile: AVAudioFile) throws {
    let engine = AVAudioEngine()
    let inputFormat = inputFile.processingFormat

    try engine.enableManualRenderingMode(.offline, format: inputFormat, maximumFrameCount: 4096)

    // 建立效果器鏈（與即時模式相同）
    let player = AVAudioPlayerNode()
    engine.attach(player); engine.attach(effect)
    engine.connect(player, to: effect, format: inputFormat)
    engine.connect(effect, to: engine.mainMixerNode, format: inputFormat)
    engine.connect(engine.mainMixerNode, to: engine.outputNode, format: inputFormat)
    engine.prepare(); try engine.start()

    player.scheduleFile(inputFile, at: nil); player.play()

    let outputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: 4096)!
    while engine.manualRenderingSampleTime < inputFile.length {
        let status = try engine.renderOffline(4096, to: outputBuffer)
        if status == .success { try outputFile.write(from: outputBuffer) }
    }
    engine.stop(); engine.disableManualRenderingMode()
}
```

- inputNode 不可用，必須用 AVAudioPlayerNode
- 不受硬體時鐘限制，可比即時快
- 不需要 AVAudioSession
- DSP 代碼不需修改

---

## 12. 採樣率與 Buffer 配置

### 查詢/設定硬體採樣率（macOS）
```swift
var address = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyNominalSampleRate,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain)
var sampleRate: Float64 = 0
var size = UInt32(MemoryLayout<Float64>.size)
AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &sampleRate)
```

### Buffer 大小與延遲
| 設定 | 每 Buffer 延遲 | 估計往返延遲 |
|------|---------------|-------------|
| macOS 32 frames @ 48kHz | 0.67ms | ~3ms |
| macOS 128 frames @ 48kHz | 2.67ms | ~6ms |
| iOS ~256 frames | ~5.3ms | ~10ms |
| iOS 預設 ~1024 | ~21ms | ~30ms |

開發初期用 512-1024 frames 確認功能，再逐步降低追求低延遲。

### 跨裝置時鐘漂移
症狀：長時間運行後（10-30 分鐘）週期性爆裂音。

方案 A：Aggregate Device + drift compensation（推薦）
```swift
let description: [String: Any] = [
    kAudioAggregateDeviceNameKey as String: "EffectProcessorAggregate",
    kAudioAggregateDeviceUIDKey as String: "com.myapp.aggregate",
    kAudioAggregateDeviceIsPrivateKey as String: true,
    kAudioAggregateDeviceMainSubDeviceKey as String: outputUID,
    kAudioAggregateDeviceSubDeviceListKey as String: [
        [kAudioSubDeviceUIDKey as String: outputUID],
        [kAudioSubDeviceUIDKey as String: inputUID,
         kAudioSubDeviceDriftCompensationKey as String: true]
    ]
]
var aggregateID: AudioDeviceID = 0
AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggregateID)
```

方案 B：AudioConverter 動態 SRC（僅在極高相位精度時）

---

## 13. 容錯與狀態管理

### AVAudioEngineConfigurationChangeNotification
```swift
NotificationCenter.default.addObserver(
    forName: .AVAudioEngineConfigurationChange, object: engine, queue: nil
) { [weak self] _ in
    self?.rewireAndRestart()  // 引擎已被系統停止
}
```

重建時 outputNode.outputFormat 聲道數可能已改變，channel map 必須重新計算。

### iOS 中斷處理
```swift
NotificationCenter.default.addObserver(
    forName: AVAudioSession.interruptionNotification,
    object: AVAudioSession.sharedInstance(), queue: nil
) { notification in
    guard let type = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
          let interruptionType = AVAudioSession.InterruptionType(rawValue: type) else { return }
    switch interruptionType {
    case .began: isSuspended = true
    case .ended: isSuspended = false
    }
}
```

中斷結束後可能額外觸發 configurationChange。

### 完整恢復流程
```swift
func restoreAfterInterruption() throws {
    try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
    try session.setActive(true)
    let actualSR = session.sampleRate
    try buildEffectChain(sampleRate: actualSR)
}
```

### 安全銷毀順序
```swift
func teardown() {
    engine.stop()
    engine.inputNode.removeTap(onBus: 0)
    engine.disconnectNodeOutput(engine.inputNode)
    if let node = effectNode {
        engine.disconnectNodeOutput(node)
        engine.detach(node)
    }
    effectNode = nil
    engine = nil
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
}
```

### render callback 避免捕獲 self
```swift
// 安全：只捕獲 C 指標
let dspPtr = UnsafeMutablePointer<CDSPEngine>.allocate(capacity: 1)
dspPtr.initialize(to: CDSPEngine())
let sourceNode = AVAudioSourceNode { _, _, frameCount, bufferList in
    dspPtr.pointee.process(bufferList, frameCount)
    return noErr
}
```

### SwiftUI 整合
```swift
struct EffectView: View {
    @StateObject private var manager = AudioEffectManager()
    var body: some View {
        VStack { /* UI */ }
            .onAppear { Task { try? await manager.setup() } }
            .onDisappear { manager.teardown() }
    }
}
```

使用 @StateObject，在 .onDisappear 呼叫 teardown()，不依賴 deinit。

---

## 14. AudioChannelLayout 與環繞聲

| Tag | 聲道數 | 排列 |
|-----|--------|------|
| kAudioChannelLayoutTag_Mono | 1 | C |
| kAudioChannelLayoutTag_Stereo | 2 | L R |
| kAudioChannelLayoutTag_MPEG_5_1_A | 6 | L R C LFE Ls Rs |
| kAudioChannelLayoutTag_MPEG_7_1_A | 8 | L R C LFE Ls Rs Lc Rc |
| kAudioChannelLayoutTag_Quadraphonic | 4 | L R Ls Rs |

```swift
let channelLayout = AVAudioChannelLayout(layoutTag: kAudioChannelLayoutTag_MPEG_5_1_A)!
let surroundFormat = AVAudioFormat(standardFormatWithSampleRate: 48000, channelLayout: channelLayout)!
```

Channel Map + Channel Layout 協同：先用 AudioChannelLayout 設定空間語義，再用 Channel Map 映射到物理輸出。

---

## 15. vDSP/Accelerate 向量化

### 常用函數速查
| 運算 | 標量寫法 | vDSP 函數 |
|------|---------|-----------|
| 乘以常數 | buf[i] *= gain | vDSP_vsmul |
| 加常數 | buf[i] += offset | vDSP_vsadd |
| 兩 buffer 相加 | c[i] = a[i] + b[i] | vDSP_vadd |
| 兩 buffer 相乘 | c[i] = a[i] * b[i] | vDSP_vmul |
| 乘加 | d[i] = a[i]*b[i] + c[i] | vDSP_vma |
| 絕對值 | abs(buf[i]) | vDSP_vabs |
| RMS | rms(buf) | vDSP_rmsqv |
| 峰值絕對值 | max(abs(buf)) | vDSP_maxmgv |
| dB 轉換 | 20*log10(buf) | vDSP_vdbcon |
| Biquad IIR | direct form II | vDSP_biquad |
| FFT | DFT | vDSP_fft_zrip |
| Hann 窗 | manual | vDSP_hann_window |
| 線性內插 | lerp | vDSP_vintb |

### Wet/Dry Mix 向量化
```swift
func mixWetDry_vDSP(wet: UnsafePointer<Float>, dry: UnsafePointer<Float>,
                    output: UnsafeMutablePointer<Float>, mix: Float, count: Int) {
    let n = vDSP_Length(count)
    var wetGain = mix
    var dryGain = 1.0 - mix
    vDSP_vsmul(dry, 1, &dryGain, output, 1, n)
    vDSP_vsma(wet, 1, &wetGain, output, 1, output, 1, n)
}
```

### RMS / Peak
```swift
func rms(buffer: UnsafePointer<Float>, count: Int) -> Float {
    var result: Float = 0
    vDSP_rmsqv(buffer, 1, &result, vDSP_Length(count))
    return result
}
func peak(buffer: UnsafePointer<Float>, count: Int) -> Float {
    var result: Float = 0
    vDSP_maxmgv(buffer, 1, &result, vDSP_Length(count))
    return result
}
```

### 效能比較（M1, 128 frames）
| 運算 | 標量 | vDSP | 加速比 |
|------|------|------|--------|
| Gain | 82ns | 11ns | 7.5x |
| Wet/Dry Mix | 165ns | 24ns | 6.9x |
| RMS | 95ns | 8ns | 11.9x |
| Peak | 78ns | 7ns | 11.1x |
| Biquad IIR | 310ns | 45ns | 6.9x |
| FFT 1024 | 4200ns | 380ns | 11.1x |
| FFT 4096 | 19800ns | 1650ns | 12.0x |

### vDSP vs NEON intrinsics
| 場景 | 建議 |
|------|------|
| 標準信號處理 | vDSP（已高度優化，跨架構可攜）|
| 自訂非線性（tanh、waveshaping）| NEON intrinsics 或 vForce |
| 查表內插 | vDSP_vlint |
| 複雜控制流程 | 標量或 NEON with mask |

vDSP_biquad_CreateSetup 會分配記憶體，必須在初始化階段呼叫，不可在 render callback 中。

### FFT Size 指引
| FFT Size | 解析度 @ 48kHz | 延遲 (N/2) | 適用場景 |
|----------|---------------|-----------|---------|
| 256 | 187.5 Hz | 2.67ms | 即時視覺化 |
| 512 | 93.75 Hz | 5.33ms | 一般頻譜顯示 |
| 1024 | 46.88 Hz | 10.67ms | pitch shift、spectral gate |
| 2048 | 23.44 Hz | 21.33ms | 卷積混響 |
| 4096 | 11.72 Hz | 42.67ms | mastering 工具 |

---

## 16. 除錯與量測

### 系統日誌
```bash
# coreaudiod 即時日誌
log stream --predicate 'process == "coreaudiod" || process == "usbaudiod"' --level debug

# HAL overload（爆音指標）
log stream --predicate 'process == "coreaudiod" && eventMessage CONTAINS "HALS_OverloadMessage"'

# 過去 5 分鐘音訊錯誤
log show --last 5m --predicate 'subsystem == "com.apple.coreaudio" && messageType == error'
```

### Render Callback 計時（只能用 mach_absolute_time）
```c
uint64_t startTick = mach_absolute_time();
// DSP 處理
uint64_t endTick = mach_absolute_time();
double elapsedNs = (double)(endTick - startTick) * ticksToNanos;
double bufferDurationNs = (double)inNumberFrames / 48000.0 * 1e9;
double loadPercent = elapsedNs / bufferDurationNs * 100.0;
```

不要用 CFAbsoluteTimeGetCurrent、Date、clock_gettime。

### CPU 負載閾值
| 負載 | 狀態 | 建議 |
|------|------|------|
| < 50% | 安全 | 充足餘量 |
| 50-70% | 注意 | 餘量有限 |
| 70-85% | 警告 | 高負載時偶發爆音 |
| > 85% | 危險 | 需降低 DSP 複雜度或增大 buffer |

### os_signpost（即時安全，開銷約 1us）
```swift
import os.signpost
let audioLog = OSLog(subsystem: "com.myapp.audioeffect", category: "DSP")
let renderSignpostID = OSSignpostID(log: audioLog)

// 在 render callback 中
os_signpost(.begin, log: audioLog, name: "DSP Render", signpostID: renderSignpostID)
// ... DSP ...
os_signpost(.end, log: audioLog, name: "DSP Render", signpostID: renderSignpostID)
```

搭配 Instruments: Points of Interest + Audio System Trace。

### 重啟音訊子系統
```bash
sudo killall -9 coreaudiod audiomxd audioclocksyncd audioanalyticsd audioaccessoryd AudioComponentRegistrar
```

---

## 17. CI/CD 音訊測試

### 測試矩陣
| 測試類型 | 依賴 | 耗時 | 頻率 |
|----------|------|------|------|
| C++ DSP 單元測試 | clang++ | <30s | 每次 push |
| Smoother 壓力測試 | clang++ | <10s | 每次 push |
| Bit-perfect 黃金參考 | clang++/Xcode | <60s | 每次 push |
| AVAudioEngine 離線渲染 | Xcode | ~2min | 每次 push |
| 延遲補償相位對齊 | Xcode | ~30s | 每次 push |
| AUv3 auval 驗證 | Xcode + build | ~3min | PR only |
| 效能回歸門檻 | Xcode | ~1min | 每次 push |

### CI 限制
- GitHub Actions macOS runner 無音訊硬體
- 所有測試必須用離線渲染或純 C++ 單元測試
- engine.inputNode 在無硬體時 format 可能為 0ch

### 黃金參考檔管理
```
Tests/DSPTests/golden/
├── smoother_44100_10ms_075.raw
├── delay_48000_300ms_50wet.raw
└── README.md
```

- .gitattributes: `Tests/DSPTests/golden/*.raw binary`
- 首次運行自動建立
- 日常 CI bit-for-bit 比對
- 修改演算法時刪除 .raw 重建，PR review 確認

### 效能回歸門檻
離線渲染 CPU 開銷不應超過即時 deadline 的 50%。

---

來源：macOS_iOS_Audio_Effect_DSP_Paper_v6.md 研究論文
