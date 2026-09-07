# Nias Heritage Design System

This document outlines the design system for the **Nias Heritage** project, based on the **Nias Heritage System** theme. The design implements a **Tactile / Skeuomorphic-Hybrid** aesthetic, evoking a curated digital museum with traditional wood grain and megalithic stone textures.

---

## 🎨 Theme Overview

- **Theme Name**: Nias Heritage System
- **Color Mode**: Adaptive (Dark Mode & Light Mode)
- **Roundness**: Soft-Weathered (`ROUND_FOUR` / `0.25rem` or `4px` corner radius)
- **Core Font Families**:
  - **Headlines**: `Newsreader` (Editorial, authoritative serif)
  - **Body / Labels**: `Inter` (Utilitarian, clean sans-serif)

---

## 🌈 Color Palette

### 🌙 Dark Mode (Default)
The dark palette evokes the interior of an *Omo Hada* (traditional house), using deep, desaturated charcoal with stone and gold highlights.

| Token | Hex Value | Usage / Description |
| :--- | :--- | :--- |
| `background` | `#131313` | Deep stone grey base canvas |
| `primary` | `#F2CA50` | Vibrant Gold for active state, royal heritage markers |
| `primary_container` | `#D4AF37` | Metallic Gold for container headers |
| `secondary` | `#FFB68C` | Peach/Clay accent |
| `secondary_container`| `#753401` | Muted Dark Wood container |
| `tertiary` | `#D0CECB` | Stone grey for secondary details |
| `tertiary_container`| `#B4B3B0` | Muted stone grey details |
| `surface` | `#131313` | Base structural background |
| `surface_dim` | `#131313` | Dark base surface |
| `surface_bright` | `#393938` | Highlighted surface |
| `surface_container`| `#1F201F` | Standard card/wooden container |
| `on_background` | `#E4E2E0` | Cream-white text on dark background |
| `on_surface` | `#E4E2E0` | Text on surfaces |
| `on_surface_variant`| `#D0C5AF` | Muted text for descriptions |
| `outline` | `#99907C` | Muted borders representing carved stone |

### ☀️ Light Mode (Complementary)
A light parchment/cream scheme for bright environments.

| Token | Hex Value | Usage / Description |
| :--- | :--- | :--- |
| `background` | `#FAF8F5` | Light warm stone base background |
| `primary` | `#996515` | Polished Ochre/Gold for active links and titles |
| `primary_container` | `#D4AF37` | Highlight container header |
| `secondary` | `#753401` | Clay/Wood brown accent |
| `secondary_container`| `#FFDBC9` | Soft clay container |
| `tertiary` | `#4A4A48` | Muted charcoal for details |
| `surface` | `#FFFDFB` | Clean white surface |
| `surface_container`| `#F0ECE6` | Muted paper container background |
| `on_background` | `#2C2C2B` | Dark charcoal text on background |
| `on_surface` | `#2C2C2B` | Dark charcoal text on surface |
| `on_surface_variant`| `#5C5850` | Muted descriptive text |
| `outline` | `#99907C` | Borders |

---

## 🔤 Typography

- **Headline Font Family**: `Newsreader`
- **Body Font Family**: `Inter`
- **Label Font Family**: `Inter`

### Typography Scale
| Token | Font Family | Size | Weight | Line Height | Letter Spacing |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `display-lg` | Newsreader | 48px | 700 (Bold) | 56px | -0.02em |
| `headline-lg` | Newsreader | 32px | 600 (Semibold) | 40px | - |
| `headline-md` | Newsreader | 24px | 500 (Medium) | 32px | - |
| `body-lg` | Inter | 18px | 400 (Regular) | 28px | - |
| `body-md` | Inter | 16px | 400 (Regular) | 24px | - |
| `label-sm` | Inter | 12px | 600 (Semibold) | 16px | 0.05em |

---

## 📏 Layout & Spacing

- **Base Unit**: 8px
- **Gutter**: 24px
- **Mobile Margins**: 16px
- **Desktop/Tablet Margins**: 64px
- **Specialty Spacing Scales**:
  - `xs`: 4px | `sm`: 12px | `md`: 24px | `lg`: 48px | `xl`: 80px

### Responsive Breakpoints
- **Mobile**: < 600px (1 column)
- **Tablet**: 600px - 1024px (2 columns)
- **Desktop**: > 1024px (12-column grid, wide screens)

---

## 🪵 Material & Structural Details

### Elevation & Depth
Depth is created through **Tonal Layers** and **Physical Textures** instead of heavy drop shadows:
1. **Base Layer (Level 0)**: Deep stone grey with a subtle granite texture.
2. **Surface Layer (Level 1)**: Cards mimic dark wood grain texture with a 1px inner carved highlight (a light-colored top border at 10% opacity) to simulate physical depth.
3. **Floating Layer (Level 2)**: Modals/pop-overs feature soft, low-opacity ambient gold-tinted shadows.

### Shapes & Corner Radius
- **sm**: `0.125rem` (2px)
- **DEFAULT**: `0.25rem` (4px) — weathered corner radius mimicking hand-hewn wood and stone.
- **md**: `0.375rem` (6px)
- **lg**: `0.5rem` (8px)
- **xl**: `0.75rem` (12px)
- **full**: `9999px`

### Components Styling
- **Buttons**: Primary buttons are solid Terracotta with white text. Secondary buttons are "ghost" style with a Gold border and serif text.
- **Timeline**: A vertical central gold line with "stone" nodes that expand into "wood" cards.
- **Image Hotspots**: Pulsating gold rings triggering glassmorphic overlays for artifact details.
- **Dividers**: Incorporate geometric Nias "Ni'o" triangular/diamond patterns instead of raw flat lines.
