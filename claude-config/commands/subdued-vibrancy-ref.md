---
name: subdued-vibrancy-ref
description: MADZINE 配色系統完整技術參考。涵蓋 Subdued Vibrancy（OKLCH 四層 Token、5 套調色盤、語義映射、互動狀態衍生、Tailwind v4 整合）與 HUE 單色相系統（SwiftUI 灰階背景 + 粉彩強調色、ViewModel 模式、PastelHueWheel）。
---

# Subdued Vibrancy 配色系統技術參考

## 1. 架構總覽

```
Layer 0: 原始調色盤 (--p-*)     ← 每主題 7-8 個 OKLCH 原色
Layer 1: 語義別名 (--surface-*, --text-*, --border-*, --color-*)  ← Light/Dark 兩套
Layer 2: 互動狀態 (--state-*)   ← Hover/Active/Focus/Disabled/Selected
Layer 3: 排版間距 (--text-*, --space-*, --radius-*, --shadow-*)
```

來源檔案：
- Token 定義：`/Users/madzine/Documents/Research/subdued-vibrancy-tokens.css`
- Tailwind 映射：`/Users/madzine/Documents/Research/tailwind-theme.css`

---

## 2. Layer 0：原始調色盤（5 套主題）

### 命名規則
`--p-{role}`：light | warm-mid | warm-mid-2 | cool-mid | warm-accent | cool-bridge | dark | neutral

### 主題切換
HTML class：`theme-morandi` | `theme-edo` | `theme-nordic` | `theme-venetian` | `theme-ceramic`

### Morandi Afternoon（莫蘭迪午後）
| Token | OKLCH | 色名 |
|-------|-------|------|
| --p-light | oklch(0.94 0.01 75) | — |
| --p-warm-mid | oklch(0.73 0.04 20) | Dusty Rose |
| --p-warm-mid-2 | oklch(0.72 0.05 90) | Sage Ochre |
| --p-cool-mid | oklch(0.66 0.04 250) | Muted Slate |
| --p-warm-accent | oklch(0.70 0.06 65) | Terracotta Whisper |
| --p-cool-bridge | oklch(0.66 0.04 355) | Soft Mauve |
| --p-dark | oklch(0.33 0.03 55) | Deep Umber |
| --p-neutral | oklch(0.60 0.01 60) | — |
| 主色相 65° | 對比色相 250° | |

### Edo Twilight（江戶暮色）
| Token | OKLCH | 色名 |
|-------|-------|------|
| --p-light | oklch(0.95 0.01 80) | — |
| --p-warm-mid | oklch(0.60 0.04 50) | 鼠色 Nezumi |
| --p-warm-mid-2 | oklch(0.64 0.09 70) | 狐色 Kitsune |
| --p-cool-mid | oklch(0.61 0.07 135) | 鶯色 Uguisu |
| --p-warm-accent | oklch(0.64 0.09 70) | 狐色 Kitsune |
| --p-cool-bridge | oklch(0.65 0.06 295) | 藤色 Fuji |
| --p-dark | oklch(0.27 0.01 55) | 墨色 Sumi |
| --p-neutral | oklch(0.55 0.04 235) | 藍鼠 Ai-Nezumi |
| 主色相 70° | 對比色相 295° | |

### Nordic Heather（北歐石楠）
| Token | OKLCH | 色名 |
|-------|-------|------|
| --p-light | oklch(0.96 0.01 70) | — |
| --p-warm-mid | oklch(0.87 0.02 80) | Birch |
| --p-warm-mid-2 | oklch(0.60 0.05 18) | Lingonberry |
| --p-cool-mid | oklch(0.70 0.03 200) | Sea Fog |
| --p-warm-accent | oklch(0.74 0.08 85) | Dried Mustard |
| --p-cool-bridge | oklch(0.62 0.06 320) | Heather |
| --p-dark | oklch(0.32 0.01 60) | Charcoal Warm |
| --p-neutral | oklch(0.58 0.01 50) | — |
| 主色相 85° | 對比色相 320° | |

### Venetian Dusk（威尼斯暮光）
| Token | OKLCH | 色名 |
|-------|-------|------|
| --p-light | oklch(0.91 0.02 80) | — |
| --p-warm-mid | oklch(0.64 0.05 18) | Venetian Rose |
| --p-warm-mid-2 | oklch(0.69 0.07 75) | Raw Sienna |
| --p-cool-mid | oklch(0.62 0.06 145) | Terre Verte |
| --p-warm-accent | oklch(0.69 0.07 75) | Raw Sienna |
| --p-cool-bridge | oklch(0.58 0.04 240) | Azurite |
| --p-dark | oklch(0.28 0.01 40) | Bone Black |
| --p-neutral | oklch(0.41 0.04 265) | Deep Lapis |
| 主色相 75° | 對比色相 145° | |

### Studio Ceramic（工房陶器）
| Token | OKLCH | 色名 |
|-------|-------|------|
| --p-light | oklch(0.95 0.01 50) | — |
| --p-warm-mid | oklch(0.73 0.04 25) | Slip Pink |
| --p-warm-mid-2 | oklch(0.77 0.06 90) | Straw |
| --p-cool-mid | oklch(0.70 0.05 155) | Celadon |
| --p-warm-accent | oklch(0.64 0.06 300) | Dry Lavender |
| --p-cool-bridge | oklch(0.62 0.04 235) | Storm Blue |
| --p-dark | oklch(0.37 0.03 50) | Iron Oxide |
| --p-neutral | oklch(0.60 0.01 70) | Ash |
| 主色相 155° | 對比色相 300° | |

---

## 3. Layer 1：語義映射

### Light Mode 映射
```css
/* Surfaces */
--surface-base:    var(--p-light)
--surface-raised:  oklch(from var(--p-light) calc(l - 0.03) c h)
--surface-sunken:  oklch(from var(--p-light) calc(l - 0.06) c h)
--surface-overlay: oklch(from var(--p-dark) l c h / 0.04)

/* Text */
--text-primary:    var(--p-dark)
--text-secondary:  oklch(from var(--p-dark) calc(l + 0.20) c h)
--text-tertiary:   oklch(from var(--p-dark) calc(l + 0.35) 0.01 h)
--text-inverse:    var(--p-light)
--text-on-accent:  oklch(0.98 0.005 0)

/* Borders */
--border-default:  oklch(from var(--p-neutral) calc(l + 0.15) 0.01 h)
--border-strong:   oklch(from var(--p-neutral) l 0.02 h)
--border-focus:    oklch(from var(--p-warm-accent) l calc(c + 0.04) h)

/* Functional Colors */
--color-primary:   var(--p-warm-accent)
--color-secondary: var(--p-cool-mid)
--color-tertiary:  var(--p-cool-bridge)
--color-warm:      var(--p-warm-mid)
--color-warm-2:    var(--p-warm-mid-2)
--color-neutral:   var(--p-neutral)
```

### Dark Mode 映射（關鍵差異）
```css
/* Surfaces — 暗底 + 微暖 */
--surface-base:    oklch(from var(--p-dark) calc(l + 0.02) calc(c + 0.005) h)
--surface-raised:  oklch(from var(--p-dark) calc(l + 0.08) calc(c + 0.005) h)

/* Text — 提亮確保對比 */
--text-primary:    oklch(from var(--p-light) calc(l - 0.02) c h)
--text-secondary:  oklch(from var(--p-light) calc(l - 0.12) 0.015 h)
--text-on-accent:  oklch(0.18 0.01 0)

/* Palette — 微幅提升彩度補償暗背景知覺衰減 */
--color-primary:   oklch(from var(--p-warm-accent) calc(l + 0.08) calc(c + 0.02) h)
--color-secondary: oklch(from var(--p-cool-mid) calc(l + 0.08) calc(c + 0.015) h)
```

Dark 模式啟用方式：`[data-mode="dark"]` 或 `@media (prefers-color-scheme: dark)`

---

## 4. Layer 2：互動狀態衍生

### Light Mode
| 狀態 | 背景公式 | 邊框公式 | 非色彩線索 |
|------|---------|---------|-----------|
| Hover | L-0.07, C+0.01 | L-0.12, C+0.01 | box-shadow |
| Active | L-0.12, C+0.02 | L-0.16, C+0.02 | scale(0.98) |
| Focus | — | — | 2px outline, offset 2px |
| Disabled | L+0.15, C×0.4 | transparent | opacity 0.5 |
| Selected | L-0.04, C+0.03 | L-0.10, C+0.04 | — |

### Dark Mode（方向反轉）
| 狀態 | 背景公式 | 邊框公式 |
|------|---------|---------|
| Hover | L+0.06, C+0.01 | L+0.10, C+0.01 |
| Active | L+0.10, C+0.02 | L+0.14, C+0.02 |
| Disabled | L-0.15, C×0.3 | — |
| Selected | L+0.04, C+0.03 | L+0.08, C+0.04 |

### Surface 狀態（卡片/列表項目）
- Light hover: L-0.04, C+0.005
- Light active: L-0.08, C+0.01
- Dark hover: L+0.04, C+0.005
- Dark active: L+0.07, C+0.01

---

## 5. 語義色彩

### Light Mode
| 類別 | 主色 | 微底色 | 文字 | 邊框 |
|------|------|--------|------|------|
| Success | oklch(0.62 0.08 150) | oklch(0.92 0.02 150) | oklch(0.35 0.06 150) | oklch(0.72 0.06 150) |
| Warning | oklch(0.72 0.10 75) | oklch(0.93 0.03 75) | oklch(0.40 0.08 75) | oklch(0.78 0.07 75) |
| Error | oklch(0.60 0.10 20) | oklch(0.93 0.02 20) | oklch(0.38 0.08 20) | oklch(0.70 0.07 20) |
| Info | oklch(0.62 0.06 245) | oklch(0.93 0.015 245) | oklch(0.38 0.05 245) | oklch(0.72 0.04 245) |

### Dark Mode
| 類別 | 主色 | 微底色 | 文字 | 邊框 |
|------|------|--------|------|------|
| Success | oklch(0.70 0.08 150) | oklch(0.30 0.03 150) | oklch(0.80 0.06 150) | oklch(0.50 0.05 150) |
| Warning | oklch(0.76 0.10 75) | oklch(0.32 0.04 75) | oklch(0.82 0.07 75) | oklch(0.55 0.06 75) |
| Error | oklch(0.68 0.10 20) | oklch(0.30 0.04 20) | oklch(0.82 0.07 20) | oklch(0.50 0.06 20) |
| Info | oklch(0.70 0.06 245) | oklch(0.30 0.025 245) | oklch(0.82 0.04 245) | oklch(0.50 0.04 245) |

---

## 6. Layer 3：排版與間距

### 字型堆疊
- Display: "DM Serif Display", "Noto Serif JP", Georgia, serif
- Body: "DM Sans", "Noto Sans JP", system-ui, sans-serif
- Mono: "JetBrains Mono", "SF Mono", "Fira Code", monospace

### 字級（Major Third 1.250）
| Token | 大小 |
|-------|------|
| --text-xs | 0.64rem (10.24px) |
| --text-sm | 0.8rem (12.8px) |
| --text-base | 1rem (16px) |
| --text-md | 1.25rem (20px) |
| --text-lg | 1.563rem (25px) |
| --text-xl | 1.953rem (31.25px) |
| --text-2xl | 2.441rem (39px) |
| --text-3xl | 3.052rem (48.83px) |
| --text-4xl | 3.815rem (61px) |

### 行高
tight 1.15 | snug 1.3 | normal 1.5 | relaxed 1.65 | loose 1.8

### 間距（4px 基準網格）
| Token | 值 | Token | 值 |
|-------|----|-------|----|
| --space-1 | 4px | --space-6 | 24px |
| --space-2 | 8px | --space-8 | 32px |
| --space-3 | 12px | --space-10 | 40px |
| --space-4 | 16px | --space-12 | 48px |
| --space-5 | 20px | --space-16 | 64px |

### 語義間距
- gap-inline: 8px（行內元素間）
- gap-stack: 16px（堆疊元素間）
- gap-section: 48px（頁面區塊間）
- padding-card: 20px
- padding-page: 24px

### 圓角
sm 4px | md 8px | lg 12px | xl 16px | full 9999px

### 陰影（暖色調，非純黑）
所有陰影使用 `oklch(from var(--p-dark) l c h / alpha)` 確保陰影與主題色調一致。
- sm: 0 1px 2px / 0.06
- md: 0 2px 8px / 0.08 + 0 1px 2px / 0.04
- lg: 0 4px 16px / 0.10 + 0 2px 4px / 0.05
- xl: 0 8px 32px / 0.12 + 0 4px 8px / 0.06

### 過渡
- fast: 80ms | normal: 150ms | slow: 300ms
- ease-default: cubic-bezier(0.4, 0, 0.2, 1)
- ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1)

---

## 7. Tailwind CSS v4 整合

### 設定方式
```css
@import "tailwindcss";
@import "./subdued-vibrancy-tokens.css";
@import "./tailwind-theme.css";
```

HTML 主題切換：`<html class="theme-edo" data-mode="dark">`

### 產生的 Utility Class 對應

| Tailwind Class | 映射到 |
|---------------|--------|
| bg-surface-base | --surface-base |
| bg-surface-raised | --surface-raised |
| text-text-primary | --text-primary |
| text-text-secondary | --text-secondary |
| border-default | --border-default |
| bg-primary | --color-primary |
| bg-state-hover | --state-hover-bg |
| bg-success-subtle | --semantic-success-subtle |
| text-error-text | --semantic-error-text |
| font-display | --font-display |
| font-body | --font-body |
| shadow-md | --shadow-md |
| rounded-md | --radius-md |

### 預組 Utility 元件

**interactive** — 互動元件基礎類別，自動處理 hover/active/focus/disabled 狀態
**surface-card** — 卡片元件（raised 背景 + 邊框 + 圓角 + padding + hover 效果）
**semantic-badge-{success|warning|error|info}** — 語義標籤（subtle 背景 + 文字 + 邊框 + pill 圓角）

### 使用範例

按鈕：`class="interactive bg-primary text-text-on-accent rounded-md px-4 py-2 border border-transparent font-body font-medium text-sm"`

卡片：`class="surface-card"`（內含 h3 用 font-display + text-text-primary，p 用 font-body + text-text-secondary）

語義警告：`class="bg-warning-subtle border border-warning-border rounded-md p-4"` + `class="text-warning-text font-body text-sm"`

---

## 8. HUE 單色相配色系統（SwiftUI 原生）

SwiftUI 專案使用的配色架構，以單一 hue 值（0-1）驅動所有強調色。

### 色彩層級

**背景層（灰階，hue 無關）：**

| Token | 值 | 用途 |
|-------|-----|------|
| Theme.bgDeep | Color(white: 0.08) | 最深背景，視窗/app 根層 |
| Theme.bgPanel | Color(white: 0.12) | 面板、卡片、側邊欄 |
| Theme.bgSurface | Color(white: 0.18) | 浮層：popover、sheet、輸入欄 |
| Theme.separator | Color(white: 0.25) | 分隔線 |

**強調色（由 accentHue 衍生）：**

| Token | Saturation | Brightness | 用途 |
|-------|-----------|-----------|------|
| Theme.accent(hue:) | 0.30 | 0.92 | 主強調色：按鈕、toggle、啟用狀態 |
| Theme.accentDim(hue:) | 0.15 | 0.60 | 弱化強調：非啟用項目、次要指示 |
| Theme.accentGlow(hue:) | 0.40 | 1.00 | 高亮強調：發光效果、重點標示 |

**文字層（固定白/灰）：**

| Token | 值 | 用途 |
|-------|-----|------|
| Theme.textPrimary | Color.white | 主內容、標題、數值 |
| Theme.textSecondary | Color(white: 0.6) | 標籤、描述、區段標題 |
| Theme.textDim | Color(white: 0.4) | 時間戳、placeholder、停用項目 |

**功能例外色（固定，不隨 hue 變化）：**

| Token | H | S | B |
|-------|---|---|---|
| Theme.error | 0.0 | 0.6 | 0.9 |
| Theme.warning | 0.12 | 0.6 | 0.95 |
| Theme.success | 0.38 | 0.5 | 0.85 |

### ViewModel 模式（強制）

```swift
// ThemeViewModel.swift — accentHue 必須在 @Observable 上
@Observable
final class ThemeViewModel {
    var accentHue: Double = Theme.accentHue {
        didSet { Theme.accentHue = accentHue }
    }
}
```

### 整合步驟

1. 複製 `Theme.swift`，修改 `hueKey` 和 `defaultHue`
2. 建立 ThemeViewModel（或加入現有 ViewModel）
3. App 入口注入：`.environment(themeVM)`
4. 頂層 View：`.tint(Color(hue: vm.accentHue, saturation: 0.30, brightness: 0.92))`
5. 自訂元件：參數接收 `hue: Double`，不讀 `Theme.accentHue`

### 強制規則

- accentHue 必須在 `@Observable` ViewModel 上（靜態 var 不觸發 SwiftUI 重繪）
- 禁止 `.id(accentHue)` 強制重繪（會重置 popover 等 UI 狀態）
- PastelHueWheel 用法：`PastelHueWheel(hue: $vm.accentHue)`

### 參考模板位置

`/Users/madzine/Documents/FeatureRef/HueThemeRef/HueThemeRefApp/`
- `Models/Theme.swift` — 配色架構（直接複製）
- `ViewModels/ThemeViewModel.swift` — ViewModel 範例
- `Views/PastelHueWheel.swift` — 色輪選色器（直接複製）
- `Views/ContentView.swift` — 所有元件整合展示

### 兩套系統對照

| | Subdued Vibrancy | HUE 系統 |
|--|-----------------|----------|
| 色彩空間 | OKLCH | HSB |
| 主題數 | 5 套固定調色盤 | 無限（連續色相） |
| 背景 | Light + Dark | 僅 Dark（灰階） |
| 適用框架 | CSS / Tailwind | SwiftUI |
| 適用場景 | Web UI、多主題 | 原生 App、單色相暗色介面 |

---

## 9. 設計決策速查

| 問題 | 答案 |
|------|------|
| 為什麼用 OKLCH？ | 感知均勻，L 偏移量直接對應視覺亮度變化 |
| 為什麼 chroma 這麼低？ | Subdued Vibrancy 哲學：含蓄的鮮活 |
| Dark mode 為什麼不是直接 swap？ | 暗背景上彩度知覺衰減，需微幅提升 chroma 補償 |
| 為什麼互動狀態要有非色彩線索？ | 色覺障礙者需要 border/shadow/scale 等替代反饋 |
| 語義色彩為什麼 chroma 也低？ | 與主調色盤和諧共存，避免「外掛感」 |
| 陰影為什麼用 oklch(from --p-dark)？ | 確保陰影色調與主題一致，避免純黑生硬感 |
