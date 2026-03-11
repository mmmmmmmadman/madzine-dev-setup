# MADZINE Claude Code 規範 (Windows)

## 語言與風格

- 使用繁體中文
- 禁止使用表情符號
- 對話中不顯示程式碼內容，僅描述做法
- 程式碼只在實際編輯檔案時寫入
- 保持極簡風格，避免冗長解釋

## 禁止操作

- **絕對不要用 Read 工具讀取圖片檔案**（.img、.png、.jpg、.jpeg、.gif、.bmp、.webp、.svg、.ico 等）。讀取圖片會觸發 API 400 錯誤導致對話中斷。
- **絕對不要用 WebFetch 擷取含有圖片的網頁**（如 VCV Library 模組頁面）。網頁內嵌圖片同樣會觸發 API 錯誤。
- 需要處理圖片檔案時，一律使用 Bash 工具操作（如 file、wc、xxd 等），並確保輸出不包含圖片原始資料。

## 回應原則

- 當使用者提出問題（「可以嗎」「有沒有辦法」「能不能」），先回答問題本身，不要直接實作。等使用者明確指示後再動手。

## 工作模式

- 優先使用計劃模式 (EnterPlanMode)，先規劃再實作
- 多使用 AskUserQuestion 確認需求與方向
- 善用 Agent 處理複雜任務，特別是：
  - Explore Agent：探索程式碼庫結構
  - Plan Agent：設計實作方案
  - 各領域專用 Agent：依任務性質選用

## 參考專案原則

- 所有改動必須參考已完成專案的作法
- 修改前先搜尋相關專案中的類似實作
- 遵循專案內既有的程式風格與架構模式
- 不憑空發明新作法，優先複用已驗證的解決方案

## 參考專案一覽

路徑：%USERPROFILE%\Documents\MADZINE_Projects_Overview.md

### Windows 開發重點

| 語言 | 主要專案 |
|------|----------|
| Rust | WAAASAABIII、VideoMixerRust |
| C++17/20 | MADZINE-VCV（跨平台編譯）、JUCE 應用 |

### 常用框架參考

- VCV 模組：參考 MADZINE-VCV
- Rust 跨平台：參考 WAAASAABIII

## Windows 環境

- OS: Windows 10/11
- Shell: PowerShell
- Editor: VS Code + Claude Code
- C++ Toolchain: MSVC (Visual Studio Build Tools 2022)
- Rust Toolchain: rustup (stable-x86_64-pc-windows-msvc)
- Package Manager: vcpkg (%USERPROFILE%\Documents\Tools\vcpkg)
- 環境變數:
  - VCPKG_ROOT = %USERPROFILE%\Documents\Tools\vcpkg
  - VCPKG_DEFAULT_TRIPLET = x64-windows
  - FFMPEG_DIR = %VCPKG_ROOT%\installed\x64-windows

## 資料夾結構

```
%USERPROFILE%\Documents\
├── Commercial\          # 商業專案（僅 Windows 相容部分）
├── OpenSource\          # 開源專案
│   └── WAAASAABIII\     # Rust 多影片播放器
├── Research\
└── Tools\
    └── vcpkg\           # C/C++ 套件管理器
```

## 建置指令

### WAAASAABIII (Rust)

```powershell
cd $env:USERPROFILE\Documents\OpenSource\WAAASAABIII
cargo build --release
```

## 跨平台同步

- 所有程式碼透過 GitHub 同步 (github.com/mmmmmmmadman)
- macOS 為主要開發機
- Windows 負責 Windows 專屬建置與測試
- 禁止 force-push；工作前一律先 pull
