import { defineConfig } from "vite";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { resolve } from "node:path";

const root = fileURLToPath(new URL(".", import.meta.url));

/**
 * 
 * @returns {import("vite").Plugin}
 */
function themeOutput() {
  return {
    enforce: "post",
    generateBundle(_, bundle) {
      this.emitFile({
        fileName: "manifest.json",
        source: readFileSync(resolve(root, "manifest.json")),
        type: "asset"
      });

      for (const [fileName, file] of Object.entries(bundle)) {
        if (file.type === "chunk" && file.isEntry && file.code.trim() === "") {
          delete bundle[fileName];
        }
      }
    },
    name: "theme-output"
  };
}

export default defineConfig({
  build: {
    assetsInlineLimit: () => true,
    cssMinify: false,
    cssCodeSplit: true,
    emptyOutDir: false,
    outDir: "dist",
    rollupOptions: {
      input: "src/theme-entry.mjs",
      output: {
        assetFileNames: (asset) => asset.name?.endsWith(".css")
          ? "theme.css"
          : "assets/[name]-[hash][extname]"
      }
    }
  },
  resolve: {
    alias: {
      "assets/fonts": resolve(root, "assets/fonts")
    }
  },
  plugins: [themeOutput()]
});
