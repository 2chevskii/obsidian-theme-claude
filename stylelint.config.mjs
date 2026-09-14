export default {
  extends: ["stylelint-config-obsidianmd"],
  rules: {
    // Obsidian and CodeMirror expose mixed-case and BEM-like class names.
    "selector-class-pattern": null,

    // The theme deliberately layers component overrides after shared rules.
    "no-descending-specificity": null,

    // Font family names, Electron prefixes, and compatibility declarations are intentional.
    "value-keyword-case": null,
    "font-family-name-quotes": null,
    "property-no-vendor-prefix": null,
    "plugin/no-unsupported-browser-features": null,

    // Existing pixel-tuned declarations are kept stable during repository extraction.
    "custom-property-empty-line-before": null,
    "declaration-empty-line-before": null,
    "color-hex-length": null,
    "color-named": null,
    "declaration-no-important": null,
    "keyframe-selector-notation": null,
    "selector-not-notation": null,
    "media-feature-range-notation": null
  }
};
