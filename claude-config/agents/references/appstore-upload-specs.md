# App Store Upload 詳細規格

## 截圖規格

### Mac
- 最小: 1280 x 800 pixels
- 建議: 2560 x 1600 或 2880 x 1800 pixels

### iOS
- 6.7" Display: 1290 x 2796 pixels
- 6.5" Display: 1284 x 2778 pixels
- 5.5" Display: 1242 x 2208 pixels（選用）

### iPad
- 12.9" Display: 2048 x 2732 pixels
- 11" Display: 1668 x 2388 pixels

### 建議截圖內容（5-10 張）
1. 主畫面
2. 核心功能
3. 設定頁面
4. 特色功能
5. 使用情境

## Archive 與上傳流程

### 準備工作
1. 確認 Bundle ID 與 Team ID
2. 設定 Version 和 Build Number
3. 確認 App Icons 完整
4. 檢查 Info.plist 權限說明
5. 移除 Debug 設定

### Archive 指令
```bash
# 清除並 Archive
xcodebuild clean archive \
  -scheme "SchemeName" \
  -configuration Release \
  -archivePath ./build/App.xcarchive

# 匯出 IPA
xcodebuild -exportArchive \
  -archivePath ./build/App.xcarchive \
  -exportPath ./build/export \
  -exportOptionsPlist ExportOptions.plist
```

### 上傳方式
1. Xcode Organizer（推薦）
2. Transporter App
3. altool 命令列

## 審核注意事項

### 常見拒絕原因
- 缺少權限說明（相機、麥克風等）
- 隱私權政策不完整
- 第三方 API 需要登入但未提供測試帳號
- 功能描述與實際不符
- 截圖與實際 App 不符

### 審核備註撰寫要點
- 說明 App 需要的特殊設定（如 API Key）
- 提供測試步驟
- 說明特殊硬體需求

## 授權聲明格式

針對每個第三方依賴：
- 名稱與版本
- 授權類型（MIT / Apache 2.0 / BSD 等）
- 版權聲明
- 授權全文或連結

常見授權：
- MIT: 需包含版權聲明和授權文本
- Apache 2.0: 需包含版權聲明、授權文本、NOTICE 檔案（如有）
- BSD: 需包含版權聲明
