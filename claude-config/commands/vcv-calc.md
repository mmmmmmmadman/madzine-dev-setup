---
name: vcv-calc
description: VCV Rack 模組空間計算與重疊預檢規則
---

# VCV Rack 空間計算與重疊預檢

本規則定義了在寫入程式碼前必須執行的預計算驗證步驟。

---

## 預計算驗證完整步驟

### 步驟 1: 建立元件配置表

列出所有元件，格式如下:

```
元件名 | 類型 | 中心X | 中心Y | X範圍(左~右) | Y範圍(上~下)
```

X/Y 範圍計算:
- Port: 中心 +/- 12px
- 30px 旋鈕: 中心 +/- 15px
- 26px 旋鈕: 中心 +/- 13px
- 標籤: pos.x + size.x/2 +/- textWidth/2, pos.y + size.y/2 +/- fontSize/2

### 步驟 2: 邊界檢查

對每個元件檢查:

```
X 邊界:
  元件左邊界 >= 0（理想 >= 3）
  元件右邊界 <= panel_width（理想 <= panel_width - 3）
  元件中心 X >= 15
  元件中心 X <= panel_width - 15

Y 邊界:
  元件上邊界 >= 0
  元件下邊界 <= 380
  暗色區域元件: Y < 330
  白色區域元件: Y >= 330
```

### 步驟 3: 重疊檢測

#### 3a. 標籤-元件重疊

對每個標籤，檢查它與所有在其之後加入的元件（z-order 更高）是否重疊:

```
標籤矩形:
  L_left   = pos.x + size.x/2 - textWidth/2
  L_right  = pos.x + size.x/2 + textWidth/2
  L_top    = pos.y + size.y/2 - fontSize/2
  L_bottom = pos.y + size.y/2 + fontSize/2

  textWidth = 字元數 x fontSize x 0.43

元件矩形:
  C_left   = centerX - radius
  C_right  = centerX + radius
  C_top    = centerY - radius
  C_bottom = centerY + radius

重疊條件:
  L_left < C_right AND L_right > C_left AND
  L_top < C_bottom AND L_bottom > C_top
```

若重疊，輸出:
```
[重疊] 標籤 "XXX" 與元件 YYY 重疊
  標籤範圍: (L_left, L_top) ~ (L_right, L_bottom)
  元件範圍: (C_left, C_top) ~ (C_right, C_bottom)
```

#### 3b. 元件-元件重疊

對相鄰元件檢查最小間距:

```
水平間距 = |centerX_A - centerX_B|
垂直間距 = |centerY_A - centerY_B|

Port-Port 最小水平間距: 26px
旋鈕-旋鈕 最小水平間距: 直徑 + 2px
Port-Port 最小垂直間距: 25px
```

#### 3c. 標籤-標籤重疊

對相鄰標籤檢查文字範圍是否重疊:

```
文字寬度 = 字元數 x fontSize x 0.43
兩標籤重疊條件同矩形重疊檢測
```

### 步驟 4: 輸出驗證結果

```
=== 預計算驗證結果 ===
邊界檢查: 通過 / 失敗（列出違規項）
標籤-元件重疊: 通過 / 失敗（列出違規項）
元件-元件間距: 通過 / 失敗（列出違規項）
標籤-標籤重疊: 通過 / 失敗（列出違規項）
```

### 步驟 5: 修正與重新驗證

若有任何失敗項:
1. 調整座標
2. 重新執行步驟 1-4
3. 重複直到全部通過

---

## 重複區塊特殊檢查

當模組有重複區塊時，額外檢查:

```
1. 計算單一區塊佔用高度:
   佔用高度 = 區塊最下方元素底部 - 區塊最上方元素頂部

2. 確認間距 > 佔用高度:
   間距 = rowHeight 或 blockSpacing
   間隙 = 間距 - 佔用高度
   要求: 間隙 >= 6px（建議）

3. 確認最後區塊不超出邊界:
   lastBlockBottom = startY + (count-1) * spacing + blockHeight
   要求: lastBlockBottom <= 330（或白色區域起始位置）
```
