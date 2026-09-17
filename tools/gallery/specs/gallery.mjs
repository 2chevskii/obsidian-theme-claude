import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import { promisify } from "node:util";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { browser } from "@wdio/globals";

const root = resolve(fileURLToPath(new URL("../../..", import.meta.url)));
const lock = JSON.parse(await readFile(resolve(root, "tools/gallery/renderer-lock.json")));
const staged = "/gallery/staged";
const poc = process.env.GALLERY_POC === "1";
const runFile = promisify(execFile);

async function openNote(path, mode = "preview") {
  await browser.execute(async (notePath, viewMode) => {
    const file = app.vault.getAbstractFileByPath(notePath);
    if (!file) throw new Error(`Fixture missing: ${notePath}`);
    const leaf = app.workspace.getLeaf(false);
    await leaf.openFile(file);
    await leaf.setViewState({ type: "markdown", state: { file: notePath, mode: viewMode } });
  }, path, mode);
  await browser.pause(600);
}

async function setPalette(mode, warm = false) {
  await browser.execute((nextMode, useWarm) => {
    document.body.classList.toggle("theme-dark", nextMode === "dark");
    document.body.classList.toggle("theme-light", nextMode !== "dark");
    document.body.classList.toggle("claude-light-palette-warm", useWarm);
  }, mode, warm);
  await browser.pause(250);
}

async function capture(name) {
  await browser.saveScreenshot(`${staged}/${name}.png`);
}

async function captureThumbnail() {
  await runFile("convert", [
    `${staged}/overview-light.png`,
    "-resize",
    "512x288!",
    `${staged}/theme-thumbnail.png`
  ]);
}

async function setViewportBounds() {
  const { stdout } = await runFile("xdotool", ["search", "--onlyvisible", "--name", "Obsidian"]);
  const windowId = stdout.trim().split(/\s+/).at(-1);
  assert.ok(windowId, "Xvfb must expose the Obsidian X11 window");
  await runFile("xdotool", ["windowsize", windowId, `${lock.viewport.width}`, `${lock.viewport.height}`]);
  await runFile("xdotool", ["windowmove", windowId, "0", "0"]);
  await browser.pause(250);
  const viewport = await browser.execute(() => ({ height: window.innerHeight, width: window.innerWidth }));
  assert.equal(viewport.width, lock.viewport.width, "X11 must set the locked viewport width");
  assert.equal(viewport.height, lock.viewport.height, "X11 must set the locked viewport height");
}

describe("Claude.md real Obsidian gallery", () => {
  before(async () => {
    await setViewportBounds();
    await browser.execute(() => app.customCss.setTheme("Claude.md"));
    await browser.pause(1200);
    const evidence = await browser.execute(() => ({
      styleSettingsLoaded: Boolean(app.plugins.plugins["obsidian-style-settings"]),
      themeLoaded: getComputedStyle(document.body).getPropertyValue("--claude-surface-raised").trim()
    }));
    assert.equal(evidence.styleSettingsLoaded, true, "Style Settings must load from pinned local assets");
    assert.notEqual(evidence.themeLoaded, "", "Claude.md CSS must be active");
  });

  it("captures the deterministic gallery", async () => {
    await openNote("Showcase.md");
    await setPalette("light");
    await capture("overview-light");

    if (poc) return;

    await setPalette("light", true);
    await capture("overview-warm");

    await setPalette("dark");
    await capture("overview-dark");

    await setPalette("light");
    await capture("rich-markdown-light");

    await openNote("Properties.md");
    await capture("properties-light");

    await openNote("Showcase.md", "source");
    await capture("live-preview-headings-light");

    await browser.executeObsidianCommand("switcher:open");
    await browser.pause(300);
    await capture("quick-switcher-light");
    await browser.keys("Escape");

    await setPalette("dark");
    await browser.executeObsidianCommand("command-palette:open");
    await browser.pause(300);
    await capture("command-palette-dark");
    await browser.keys("Escape");

    await setPalette("light");
    await browser.execute(() => app.workspace.trigger("parse-style-settings"));
    await browser.pause(250);
    await browser.execute(async () => {
      await app.setting.open();
      await app.setting.openTabById("obsidian-style-settings");
    });
    const themeSection = await browser.$('.style-settings-heading[data-id="claude-theme"]');
    if ((await themeSection.getAttribute("class"))?.includes("is-collapsed")) {
      await themeSection.click();
    }
    await browser.waitUntil(
      async () => browser.execute(() => document.body.innerText.includes("Светлая палитра")),
      { timeout: 5000, timeoutMsg: "Style Settings must expose the Claude.md controls" }
    );
    await capture("style-settings-light");
    await browser.execute(() => app.setting.close());
    await browser.pause(300);

    await browser.execute(() => document.body.classList.add("claude-auto-hide-status-bar"));
    const status = await browser.$(".status-bar");
    await status.moveTo();
    await browser.pause(500);
    await capture("status-bar-light");

    await captureThumbnail();
  });
});
