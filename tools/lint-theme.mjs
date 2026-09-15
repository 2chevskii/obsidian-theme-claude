import { resolve } from "node:path";
import process from "node:process";
import { compile } from "sass";
import stylelint from "stylelint";
import config from "../stylelint.config.mjs";

const root = resolve(import.meta.dirname, "..");
const result = await stylelint.lint({
  code: compile(resolve(root, "src/theme.scss"), {
    sourceMap: false,
    style: "expanded"
  }).css,
  codeFilename: resolve(root, "dist/theme/theme.css"),
  config,
  formatter: "string"
});

if (result.report) process.stdout.write(result.report);
if (result.errored) process.exitCode = 1;
