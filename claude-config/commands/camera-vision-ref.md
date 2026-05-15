---
name: camera-vision-ref
description: 相機 TCC 權限、AVCaptureSession pipeline、Vision 去背的詳細參考
---

# 相機 TCC 權限完整參考

## macOS TCC 權限 Checklist

### 必要條件（缺一不可）

1. Info.plist:
   - `NSCameraUsageDescription` — 描述字串，必須非空

2. Entitlements:
   - `com.apple.security.device.camera` = true
   - `com.apple.security.app-sandbox` 必須存在（true 或 false 皆可，但不能省略此 key）

3. Code Signing:
   - Hardened Runtime 啟用
   - 穩定簽名身分（Apple Development certificate，非 ad-hoc）
   - DEVELOPMENT_TEAM 設定正確

### 常見失敗模式

| 症狀 | 原因 | 解法 |
|------|------|------|
| auth status 直接回傳 3 (denied)，無對話框 | ad-hoc signing 無 Hardened Runtime | 用 Apple Development certificate + ENABLE_HARDENED_RUNTIME=YES |
| tccutil reset Camera 無效 | 部分 reset 不完整 | 用 `tccutil reset All <bundleID>` |
| entitlements 正確但仍 denied | app-sandbox key 缺失 | 明確加入 `com.apple.security.app-sandbox`（true 或 false） |
| Xcode Run 正常但 xcodebuild 失敗 | xcodebuild 未指定 signing | 加 `CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=<teamID>` |
| permission granted 但 session 不啟動 | onReceive race condition | 在 requestAccess callback 中直接呼叫 startSession() |

### xcodebuild CLI 正確指令

```bash
# 使用 Automatic signing（推薦）
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=macOS' \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=W89J6VDBML \
  build

# 驗證簽名
codesign -dvvv MyApp.app 2>&1 | grep -E "(Authority|TeamIdentifier|Runtime)"

# 驗證 entitlements
codesign -d --entitlements - MyApp.app

# 重置 TCC（必須用 All，Camera 單項可能無效）
tccutil reset All com.your.bundleid
```

### 權限請求正確模式

錯誤模式（race condition）：
```
onAppear → requestPermission()（非同步）
onReceive($permissionGranted) → startSession()
問題：onReceive 可能在 permissionGranted 更新前就觸發過了
```

正確模式：
```
requestPermission() 內部：
  .authorized → 直接 startSession()
  .notDetermined → requestAccess callback 中 startSession()
  .denied → 不啟動，顯示提示
```

### Entitlements 範本

App Store app（sandbox）：
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.network.client</key>
<true/>
```

FeatureRef / 測試 app（無 sandbox）：
```xml
<key>com.apple.security.app-sandbox</key>
<false/>
<key>com.apple.security.device.camera</key>
<true/>
```

---

# AVCaptureSession Pipeline 完整參考

## Session 配置 Checklist

1. 建立 AVCaptureSession()
2. session.beginConfiguration()
3. session.sessionPreset = .medium / .high / .photo
4. 建立 AVCaptureDeviceInput(device:) → session.canAddInput → session.addInput
5. 建立 AVCaptureVideoDataOutput()
   - alwaysDiscardsLateVideoFrames = true
   - videoSettings: kCVPixelFormatType_32BGRA
   - setSampleBufferDelegate(delegate, queue: dedicatedQueue)
6. session.canAddOutput → session.addOutput
7. 設定 video connection:
   - iOS: videoOrientation = .portrait
   - 前置鏡頭: isVideoMirrored = true
8. session.commitConfiguration()
9. sessionQueue.async { session.startRunning() }

## 相機枚舉

macOS:
```
deviceTypes: [.builtInWideAngleCamera, .external]  // macOS 14+
deviceTypes: [.builtInWideAngleCamera, .externalUnknown]  // macOS 13 以下
mediaType: .video
position: .unspecified
```

iOS:
```
deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera]
mediaType: .video
position: .unspecified  // 列出所有，或 .front/.back 篩選
```

## Frame Delegate 模式

模式 A — 獨立 Delegate class（ShapeVideo）：
- 建立 FrameDelegate class 遵循 AVCaptureVideoDataOutputSampleBufferDelegate
- 由 CameraManager 強引用保留
- 透過 closure 傳遞 sampleBuffer

模式 B — Service 本身作為 Delegate（MADGYM）：
- CameraService: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
- 直接在 captureOutput 中處理
- 外部消費者透過 frame callback + NSLock 安全存取

模式 C — ViewModel 作為 Delegate（Edgy）：
- CaptureViewModel 遵循 delegate
- 適合簡單的拍照 + 預覽場景

## 設備切換

1. guard device.uniqueID != currentCamera?.uniqueID
2. 更新 currentCamera
3. sessionQueue.async { configureSession() }
   - beginConfiguration
   - removeInput(currentInput)
   - 建立新 input → addInput
   - commitConfiguration

## Session Preset 選擇

| Preset | 用途 | 參考 |
|--------|------|------|
| .medium | 一般即時處理、動作偵測 | MADGYM |
| .high | 高品質即時去背、錄影 | ShapeVideo |
| .photo | 拍照為主、預覽為輔 | Edgy contour capture |

---

# Vision 去背完整參考

## VNGeneratePersonSegmentationRequest

### 品質等級比較

| 等級 | FPS (估) | 邊緣品質 | 用途 |
|------|----------|----------|------|
| .fast | 30+ | 粗糙 | 剪影顯示、動作回饋（MADGYM） |
| .balanced | 15-25 | 中等 | 即時去背錄影（ShapeVideo） |
| .accurate | <10 | 精細 | 離線處理、高品質輸出 |

### 初始化

```
segmentationRequest = VNGeneratePersonSegmentationRequest()
segmentationRequest.qualityLevel = .fast / .balanced
segmentationRequest.outputPixelFormat = kCVPixelFormatType_OneComponent8
```

### 幀率節流策略

每 N 幀執行 Vision，中間幀重用 cached mask：
```
frameCounter += 1
if frameCounter >= processEveryN {
    frameCounter = 0
    // 執行 Vision request
    // 更新 cachedMaskImage
}
// 用 cachedMaskImage 合成
```

推薦值：processEveryN = 2~4，視品質等級和目標 FPS 調整

### 去背合成 Pipeline（ShapeVideo 模式）

1. sourceImage = CIImage(cvPixelBuffer:)
2. handler = VNImageRequestHandler(ciImage: sourceImage)
3. handler.perform([segmentationRequest])
4. maskBuffer = segmentationRequest.results?.first?.pixelBuffer
5. maskImage = CIImage(cvPixelBuffer: maskBuffer)
6. scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX:y:))  // 縮放到 source 尺寸
7. backgroundImage = CIImage(color:).cropped(to: sourceImage.extent)
8. blendFilter = CIFilter.blendWithMask()
   - inputImage = sourceImage
   - backgroundImage = backgroundImage
   - maskImage = scaledMask
9. result = blendFilter.outputImage

### 剪影渲染 Pipeline（MADGYM 模式）

1. 同上取得 scaledMask
2. CIFilter(name: "CIColorMatrix") 將灰階 mask 轉為白色
   - inputRVector/inputGVector/inputBVector = (1, 0, 0, 0)  // 灰階值映射到 RGB
   - inputAVector = (0, 0, 0, 1)  // alpha 保持
3. CGContext 黑底 + draw 白色剪影
4. context.makeImage() → CGImage

---

# 即時預覽渲染參考

## CIImage → layer.contents 模式（適合需要 filter 處理的場景）

macOS (NSViewRepresentable):
- makeNSView: wantsLayer = true, layer.backgroundColor = black, layer.contentsGravity = .resizeAspect
- updateNSView: view.ciImage = image
- ciImage didSet: CIContext.createCGImage() → layer.contents = cgImage

iOS (UIViewRepresentable):
- makeUIView: backgroundColor = .black
- updateUIView: view.ciImage = image
- 同上 didSet 模式

CIContext 建立：
- CIContext(options: [.useSoftwareRenderer: false])  — 使用 GPU
- 每個 View 一個 CIContext（不要每幀建立）

## AVCaptureVideoPreviewLayer 模式（適合只需原始畫面的場景）

- AVCaptureVideoPreviewLayer(session:)
- videoGravity = .resizeAspectFill
- macOS 前置鏡頭鏡像：layer.transform = CATransform3DMakeScale(-1, 1, 1)
- iOS 17+ 旋轉支援：AVCaptureDevice.RotationCoordinator

---

# AVAssetWriter 錄製參考

## 配置

```
AVAssetWriter(outputURL:, fileType: .mp4)

videoSettings:
  AVVideoCodecKey: .h264
  AVVideoWidthKey / AVVideoHeightKey: 來自相機解析度
  AVVideoCompressionPropertiesKey:
    AVVideoAverageBitRateKey: 6_000_000 (6Mbps)
    AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel

AVAssetWriterInput(mediaType: .video, outputSettings:)
  expectsMediaDataInRealTime = true

AVAssetWriterInputPixelBufferAdaptor(assetWriterInput:, sourcePixelBufferAttributes:)
```

## 錄製流程

1. writer.startWriting()
2. 第一幀時：writer.startSession(atSourceTime: firstFrameTime)
3. 每幀：guard input.isReadyForMoreMediaData → 從 pool 取 buffer → CIContext.render → adaptor.append
4. 停止：input.markAsFinished() → writer.finishWriting()

## 注意事項

- writerQueue 必須獨立於 frame delivery queue
- pixelBufferPool 在 startWriting 後才可用
- 時間戳用 CMSampleBufferGetPresentationTimeStamp

---

# 除錯指令參考

```bash
# 捕捉 app log（推薦直接啟動 binary）
AppBinary > /tmp/app_log.txt 2>&1 &
sleep 5; kill $!; cat /tmp/app_log.txt

# 或用 log stream
/usr/bin/log stream --predicate 'process == "AppName"' --level debug --style compact

# 檢查 TCC 狀態
codesign -dvvv App.app 2>&1 | grep -E "(Authority|TeamIdentifier|Runtime)"
codesign -d --entitlements - App.app

# 重置 TCC
tccutil reset All com.your.bundleid

# 確認 binary 包含你的程式碼（Swift debug build 用 .debug.dylib）
strings App.app/Contents/MacOS/App.debug.dylib | grep "YourLogTag"
```

---

# 參考實作位置

| 專案 | 路徑 | 重點 |
|------|------|------|
| MADGYM CameraService | /Users/madzine/Documents/Commercial/MADGYM/MADGYM/Core/Services/CameraService.swift | singleton、@Observable、設備持久化、motion detection |
| MADGYM SilhouetteRenderer | /Users/madzine/Documents/Commercial/MADGYM/MADGYM/Core/Services/SilhouetteRenderer.swift | VNGeneratePersonSegmentationRequest .fast、CIColorMatrix 剪影 |
| MADGYM HandTrackingService | /Users/madzine/Documents/Commercial/MADGYM/MADGYM/Games/BlockBreaker/Services/HandTrackingService.swift | VNDetectHumanHandPoseRequest、chirality、21-point |
| Edgy CaptureViewModel | /Users/madzine/Documents/Commercial/Edgy/ViewModels/CaptureViewModel.swift | 雙模式（photo + live）、AVCaptureVideoPreviewLayer、RotationCoordinator |
| Edgy CameraPreviewView | /Users/madzine/Documents/Commercial/Edgy/Views/Capture/CameraPreviewView.swift | NSViewRepresentable/UIViewRepresentable preview layer |
| ShapeVideo | /Users/madzine/Documents/FeatureRef/ShapeVideo/ShapeVideo/ | 即時去背錄影全流程、TCC 除錯經驗 |
| BodyProfile | /Users/madzine/Documents/FeatureRef/BodyProfile/BodyProfileKit/Services/ | 批次 Vision 分析（body + hand + face） |
