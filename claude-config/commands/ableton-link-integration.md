---
name: ableton-link-integration
description: Ableton Link 整合快速參考。架構分層、關鍵規則、Build Settings、Entitlements。
---

# Ableton Link 整合快速參考

## 架構分層

1. **Link SDK**：header-only C++，git submodule `vendor/link/`
2. **C++ Wrapper**：封裝 `ableton::Link`，提供 `processAudioBlock()` per-block 呼叫
3. **C API**：`mz_synth_link_*` 系列函數，橋接 Swift
4. **Swift AudioEngine**：提供 Link 控制方法
5. **SwiftUI ViewModel**：30Hz Timer 輪詢 peer count、BPM、start/stop 旗標

## 7 條關鍵規則

1. **單一 capture-commit**：每個 audio block 只做一次 capture → modify → commit
2. **requestBeatAtStartPlayingTime**：play 狀態轉換時呼叫，否則拍點錯位
3. **mutex try_lock**：UI→Audio 用 lock_guard 寫入，Audio thread 用 try_lock 讀取（非阻塞）
4. **playing=false 持續處理**：processAudioBlock 放在 playing 檢查之前
5. **Timer 不能停**：linkActive 時 stopPlayback() 不 invalidate timer
6. **區分本地/遠端**：避免 start→flag→timer→start 無限迴圈
7. **雙向 BPM**：mLastEngineBPM 判斷改變方向，不需 requestTempo API

## Build Settings

```yaml
HEADER_SEARCH_PATHS:
  - $(SRCROOT)/vendor/link/include
  - $(SRCROOT)/vendor/link/modules/asio-standalone/asio/include
GCC_PREPROCESSOR_DEFINITIONS:
  - LINK_PLATFORM_MACOSX=1
  - ASIO_STANDALONE=1
OTHER_CPLUSPLUSFLAGS:
  - -std=c++17
```

## Entitlements

- **macOS**: `com.apple.security.network.client` + `com.apple.security.network.server`
- **iOS**: NSLocalNetworkUsageDescription + NSBonjourServices `_link-v1._udp`（不需 multicast entitlement）

## 參考實作

- Link Wrapper: `MADAZUKit/Sources/Core/MADAZULink.hpp`
- C API: `MADAZUKit/include/MADAZUSynth.h`（mz_synth_link_* 系列）
- Swift Bridge: `MADAZUKit/Sources/Bridge/AudioEngine.swift`（Link 控制方法）
- ViewModel: `MADAZUKit/Sources/ViewModels/MADAZUViewModel.swift`（30Hz 輪詢）
- 官方範例: `vendor/link/examples/linkaudio/AudioEngine.ipp`
