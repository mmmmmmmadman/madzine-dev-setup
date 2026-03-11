# Icon Design Templates

## ImageMagick 生成指令

### 單色文字 Icon

```bash
magick -size 1024x1024 xc:transparent \
  -fill none -stroke 'rgb(255,180,180)' -strokewidth 3 \
  -draw "circle 512,512 512,30" \
  -stroke none -fill 'rgb(107,91,149)' \
  -font Avenir-Light -pointsize 130 -kerning 20 \
  -gravity center -annotate +0-75 "TEXT1" \
  -annotate +0+75 "TEXT2" \
  output.png
```

### 漸層文字 Icon（五步驟）

```bash
# Step 1: 建立透明底粉色圓框
magick -size 1024x1024 xc:transparent \
  -fill none -stroke 'rgb(255,180,180)' -strokewidth 3 \
  -draw "circle 512,512 512,30" \
  base.png

# Step 2: 建立對角線漸層
magick -size 1024x1024 gradient:'#4A90D9-#9B59B6' \
  -rotate 45 -gravity center -extent 1024x1024 \
  gradient.png

# Step 3: 建立文字遮罩
magick -size 1024x1024 xc:black \
  -fill white -font Avenir-Light -pointsize 130 -kerning 20 \
  -gravity center -annotate +0-75 "TEXT1" \
  -annotate +0+75 "TEXT2" \
  mask.png

# Step 4: 用遮罩裁切漸層
magick gradient.png mask.png \
  -alpha off -compose CopyOpacity -composite \
  gradient_text.png

# Step 5: 合成最終圖像
magick base.png gradient_text.png -composite icon_1024.png

# 清理暫存檔
rm base.png gradient.png mask.png gradient_text.png
```

## icns 轉換

### 轉換為 macOS icns 格式

```bash
magick icon_1024.png \
  -define icon:auto-resize=1024,512,256,128,64,32,16 \
  AppIcon.icns
```

### 整合到 App Bundle

```bash
cp AppIcon.icns YourApp.app/Contents/Resources/
```

## 已完成的 Icon 設計記錄

### JazzArchitect (2026-01-22)

| 項目 | 值 |
|------|-----|
| 應用名稱 | Jazz Architect |
| 文字 | JAZZ / ARCHITECT（兩行）|
| 字體 | Avenir-Light 130pt |
| 字間距 | kerning 20 |
| 文字顏色 | 藍紫對角線漸層 (#4A90D9 → #9B59B6) |
| 圓框 | 珊瑚粉 rgb(255,180,180), strokewidth 3 |
| 背景 | 透明 |
| 檔案位置 | JazzArchitect-Swift/icon_1024.png |

### Watch Next（參考設計）

| 項目 | 值 |
|------|-----|
| 應用名稱 | Watch Next |
| 文字 | WATCH / NEXT（兩行）|
| 字體 | Avenir-Light |
| 文字顏色 | 黑色 |
| 圓框 | 珊瑚粉 |
| 背景 | 白色 |

## 常見問題

1. **文字超出圓框**：縮小 pointsize
2. **文字太小**：增大 pointsize
3. **漸層方向錯誤**：調整 -rotate 角度
4. **圓框太粗**：減小 strokewidth
5. **顏色不對**：確認 RGB 值正確
