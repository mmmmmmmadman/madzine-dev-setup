---
name: vcv-layout
description: VCV Rack 模組標籤偏移規則與邊界檢查
---

# VCV Rack 標籤偏移規則與邊界檢查

---

## 標籤類型定義

MADZINE VCV 模組只使用以下三種標籤類型，不可發明新類型。

### 類型 A: 功能標籤

- **用途**: 暗色區域（Y < 330）的功能說明
- **字體大小**: 8.f
- **Bold**: true
- **顏色**: 白色 nvgRGB(255, 255, 255)
- **範例**: INPUT, LEVEL, DUCK, MUTE, SOLO, DECAY, SHAPE, FREQ, TIMELINE, FOUNDATION, GROOVE, LEAD, SendA, SendB, L, R

### 類型 B: 輸出區域標籤

- **用途**: 白色區域（Y >= 330）的輸出/IO 說明
- **字體大小**: 7.f
- **Bold**: true
- **顏色**: 粉紅色 nvgRGB(255, 133, 133) 或黑色 nvgRGB(0, 0, 0)
- **範例**: QUTQ, OUT, CHAIN, MIX

### 類型 C: 背景裝飾文字

- **用途**: 大型背景裝飾（如 Pyramid 的 X/Y/Z）
- **字體大小**: 32.f（Pyramid）或 80.f（DECAPyramid）
- **Bold**: true
- **顏色**: 淡灰色 nvgRGB(160, 160, 160)
- **添加順序**: 必須在旋鈕之前添加，讓旋鈕渲染在上層
- **DECAPyramid 特殊**: 使用 OutlinedTextLabel，帶黑色外框 2px

---

## 標籤偏移計算表

### 類型 A 標籤偏移（功能標籤 8.f）

| 元件類型 | 元件半徑 | 偏移量 | 標籤 Y 公式 |
|---------|---------|--------|------------|
| PJ301MPort | 12px | 24px | 元件Y - 24 |
| StandardBlackKnob (30px) | 15px | 28px | 元件Y - 28 |
| StandardBlackKnob26 (26px) | 13px | 26px | 元件Y - 26 |
| LargeWhiteKnob (37px) | 18.5px | 32px | 元件Y - 32 |
| WhiteKnob (30px) | 15px | 28px | 元件Y - 28 |
| MediumGrayKnob (26px) | 13px | 26px | 元件Y - 26 |
| SmallGrayKnob (21px) | 10.5px | 24px | 元件Y - 24 |
| MicrotuneKnob (20px) | 10px | 23px | 元件Y - 23 |

注意: 上表的「偏移量」是標籤 pos.y（box 頂部）到元件中心的距離。實際標籤 box 通常有 10~20px 高度，文字渲染在 box 中心。因此:

```
標籤 box pos.y = 元件Y - 偏移量（簡化寫法）
實際參考模組常用: 標籤 pos.y = 元件Y - 24（統一用 24px）
```

### 類型 B 標籤偏移（輸出區域標籤 7.f）

白色區域標籤通常不直接偏移於元件上方，而是放置在固定位置。參考:
```
QQ: Vec(5, 335) 標籤 "QUTQ"，Port 在 Vec(45, 343)
```

---

## 邊界檢查規則

### X 軸邊界

```
面板寬度 = HP * RACK_GRID_WIDTH (15.24px)

4HP:  60.96px  -> X: 15 ~ 45
8HP:  121.92px -> X: 15 ~ 105
12HP: 182.88px -> X: 15 ~ 165（或 30 ~ 150）
16HP: 243.84px -> X: 15 ~ 228
32HP: 487.68px -> X: 15 ~ 472
40HP: 609.6px  -> X: 15 ~ 594
```

元件中心 X 必須滿足:
```
centerX >= 15
centerX <= panel_width - 15
```

標籤可以超出面板邊界（如 U8 的 LEVEL 標籤使用 Vec(-5, 89), size=Vec(box.size.x+10, 10)），因為文字置中渲染，視覺上仍在面板內。

### Y 軸邊界

```
模組高度 = 380px

標題區:    Y = 0~30
控制區:    Y = 30~330
白色 I/O 區: Y = 330~380
```

控制元件不可進入白色區域（Y >= 330），I/O 元件不可在暗色區域（Y < 330）。

### 顏色邊界

```
Y < 330:
  標題/品牌 -> 橘色 (255, 200, 0)
  功能標籤 -> 白色 (255, 255, 255)
  背景裝飾 -> 淡灰色 (160, 160, 160)

Y >= 330:
  輸出標籤 -> 粉紅色 (255, 133, 133)
  其他標籤 -> 黑色 (0, 0, 0)
```

---

## 標籤水平置中規則

### 單元件對應標籤

標籤框的中心 X 應與元件中心 X 對齊:

```
label_pos_x = component_centerX - label_size_x / 2
```

### 多元件共用標籤

標籤跨越多個元件時，可使用較大的 size.x:

```
// U8: MUTE/SOLO 標籤跨越兩個按鈕
addChild(new TextLabel(Vec(-5, 270), Vec(box.size.x + 10, 10), "MUTE     SOLO", ...));
```

### 全寬標籤

某些標籤使用面板全寬:

```
addChild(new TextLabel(Vec(0, 28), Vec(box.size.x, 16), "INPUT", ...));
```
