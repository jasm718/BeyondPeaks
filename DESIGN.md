---
name: Stone & Slate
colors:
  surface: '#f4faff'
  surface-dim: '#d2dbe1'
  surface-bright: '#f4faff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#ecf5fb'
  surface-container: '#e6eff5'
  surface-container-high: '#e0e9ef'
  surface-container-highest: '#dbe4ea'
  on-surface: '#141d21'
  on-surface-variant: '#42484a'
  inverse-surface: '#293236'
  inverse-on-surface: '#e9f2f8'
  outline: '#72787b'
  outline-variant: '#c2c7ca'
  surface-tint: '#47636c'
  primary: '#324e58'
  on-primary: '#ffffff'
  primary-container: '#4a6670'
  on-primary-container: '#c5e3ef'
  inverse-primary: '#aecbd7'
  secondary: '#506168'
  on-secondary: '#ffffff'
  secondary-container: '#d1e2eb'
  on-secondary-container: '#55656c'
  tertiary: '#62442d'
  on-tertiary: '#ffffff'
  tertiary-container: '#7c5b43'
  on-tertiary-container: '#ffd6bb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c9e7f3'
  primary-fixed-dim: '#aecbd7'
  on-primary-fixed: '#001f27'
  on-primary-fixed-variant: '#2f4b54'
  secondary-fixed: '#d4e5ee'
  secondary-fixed-dim: '#b8c9d2'
  on-secondary-fixed: '#0d1e24'
  on-secondary-fixed-variant: '#394950'
  tertiary-fixed: '#ffdcc5'
  tertiary-fixed-dim: '#e9bea1'
  on-tertiary-fixed: '#2c1604'
  on-tertiary-fixed-variant: '#5e402a'
  background: '#f4faff'
  on-background: '#141d21'
  surface-variant: '#dbe4ea'
typography:
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 40px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 28px
    fontWeight: '500'
    lineHeight: '1.3'
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
    letterSpacing: '0'
  label-md:
    fontFamily: Hanken Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Hanken Grotesk
    fontSize: 12px
    fontWeight: '600'
    lineHeight: '1.4'
    letterSpacing: 0.02em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  max-width: 1200px
---

## Brand & Style

The design system is built upon a philosophy of "Atmospheric Minimalism." It evokes the quiet, solitary stillness of high-altitude landscapes—think granite peaks against a pale morning sky. The visual language is calm, professional, and intentionally restrained, prioritizing clarity and mental breathing room over visual noise.

The target audience consists of professionals who value focus and precision. The emotional response should be one of "composed efficiency." We achieve this through a strictly low-saturation palette, expansive white space (using sophisticated greys instead of pure white), and a systematic elimination of non-essential decorative elements. The style draws from **Modern Minimalism**, using subtle tonal shifts instead of heavy borders to define structure.

## Colors

The palette is a study in desaturated cool tones. We avoid pure blacks and pure whites to reduce visual fatigue and maintain a "stone-like" tactile quality.

- **Primary (Glacier Blue):** #4A6670 serves as the single point of intent. It is used for primary actions, active states, and critical information markers.
- **Secondary (Mist):** #8A9BA3 provides a softer alternative for secondary icons or subtle UI accents.
- **Neutral (Slate):** #60696E is used for body text and icon outlines to ensure legibility without the harshness of pure black.
- **Surface & Container:** We utilize #F5F7F8 as the base canvas. Components and cards sit on #E1E5E8 to create a natural, receding depth that feels architectural rather than digital.

## Typography

This design system utilizes **Hanken Grotesk** exclusively. Its precise, geometric construction maintains a professional edge while its open counters provide the "high-altitude" airy feel required for the brand.

- **Headlines:** Use tight letter spacing (-0.02em) and medium weights to feel grounded.
- **Body:** Prioritize readability with a generous 1.6 line height. The high-altitude aesthetic is reinforced by giving text blocks plenty of room to breathe.
- **Labels:** Small labels use a slight increase in letter spacing and a slightly heavier weight to ensure they remain legible against grey backgrounds.

## Layout & Spacing

The layout philosophy follows a **Fixed Grid** model to provide a sense of stability and permanence. 

- **Grid:** A 12-column grid is used for desktop (max-width 1200px), centered in the viewport to emphasize the "solitary" focus of the content.
- **No Top App Bar:** To maintain a minimalist environment, navigation is pushed to the bottom or integrated into the canvas as floating elements. The top of the screen is reserved for "Sky" space—generous padding that houses only the most essential page titles or status indicators.
- **Rhythm:** All spacing is derived from an 8px base unit. Margins are intentionally wide (64px on desktop) to prevent the UI from feeling "cramped" or "cluttered."

## Elevation & Depth

Elevation is conveyed through **Tonal Layering** rather than traditional shadows. This maintains the "Stone" metaphor—depth is created by carving out or stacking surfaces.

- **Level 0 (Base):** #F5F7F8 (The ground).
- **Level 1 (Containers):** #E1E5E8. These are used for cards and main content sections. They do not use shadows; they are defined by the subtle color shift.
- **Level 2 (Interactions):** Very soft, diffused ambient shadows (0px 4px 20px, 5% opacity of #4A6670) are used only when an element is "picked up" or floating (e.g., a modal or a floating action button).
- **Outlines:** Use low-contrast outlines (1px solid #D1D5D8) for input fields to keep them grounded without adding visual weight.

## Shapes

The shape language is **Soft**. We use a 0.25rem (4px) base radius for standard components like buttons and inputs. This provides a professional, architectural feel that is slightly approachable but remains disciplined. 

Larger containers (Cards) use a 0.5rem (8px) radius to distinguish them as structural blocks. We avoid "Pill" shapes entirely to maintain the structured, professional aesthetic of the system.

## Components

- **Buttons:** Primary buttons are solid #4A6670 with white text. Secondary buttons use a ghost style with a #8A9BA3 border and text. There are no heavy drop shadows on buttons; they rely on color contrast for visibility.
- **Cards:** Cards should not have borders. They are defined solely by the #E1E5E8 surface color against the #F5F7F8 background.
- **Input Fields:** Inputs use the background color #F5F7F8 with a subtle #D1D5D8 border. Focus states transition the border to #4A6670.
- **Chips/Badges:** Small, rectangular with a 2px radius. Use #E1E5E8 as the background with #60696E text for a neutral, non-distracting look.
- **Lists:** List items are separated by whitespace or thin tonal lines (#E1E5E8) rather than heavy dividers.
- **Navigation:** Since there is no top app bar, navigation is handled through a bottom-docked bar or a minimal side-rail on desktop, using the primary color only for the active state icon.