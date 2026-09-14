---
aliases:
  - Claude theme showcase
category: design-system
status: active
tags:
  - obsidian/theme
  - design/claude
updated: 2026-09-14
---

# Claude for Obsidian

The calm, focused surface of Claude adapted for a local knowledge base.

> [!note] Theme companion
> Modal exits, search-result transitions, live-preview heading markers, and the expanded status-bar hit area are powered by Claude Theme Companion.

## Typography and rich content

Lora gives notes an editorial rhythm while **Geist Sans** keeps the interface quiet. Headings use Literata, and inline code such as `const answer = 42` uses Source Code Pro.

- Clear hierarchy with restrained contrast
- Rounded controls and floating tabs
- Responsive sidebars with compact action groups

### A small code sample

```typescript
interface ThemeFeature {
  name: string;
  available: boolean;
}

const features: ThemeFeature[] = [
  { name: "Light and dark modes", available: true },
  { name: "Companion animations", available: true }
];
```

| Surface | Treatment | State |
| --- | --- | --- |
| Editor | Warm white | Focused |
| Sidebars | Recessed neutral | Supporting |
| Accent | Claude coral | Interactive |

> Thoughtful defaults should disappear into the work.

## Tasks and links

- [x] Match the Claude color system
- [x] Bundle OFL-licensed typography
- [ ] Keep refining the smallest details

Explore the [[README|project documentation]] or visit [Obsidian](https://obsidian.md).
