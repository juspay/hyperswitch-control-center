import js from "@eslint/js";
import globals from "globals";
import reactHooks from "eslint-plugin-react-hooks";
import tsPlugin from "@typescript-eslint/eslint-plugin";
import unusedImports from "eslint-plugin-unused-imports";

const tsFiles = ["**/*.ts", "**/*.tsx"];

const reactHooksRules = {
  "react-hooks/rules-of-hooks": "error",
  "react-hooks/exhaustive-deps": "warn",
};

export default [
  {
    ignores: [
      "**/*.res.js",
      "**/*.resi.js",
      "dist/",
      "coverage/",
      "public/",
      "node_modules/",
    ],
  },
  js.configs.recommended,
  {
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      parserOptions: { ecmaFeatures: { jsx: true } },
      globals: {
        ...globals.browser,
        ...globals.es2021,
        ...globals.node,
        ...globals.shelljs,
      },
    },
    plugins: { "react-hooks": reactHooks },
    rules: reactHooksRules,
  },
  ...tsPlugin.configs["flat/recommended"].map((config) => ({
    ...config,
    files: tsFiles,
  })),
  {
    files: tsFiles,
    plugins: { "unused-imports": unusedImports },
    rules: {
      "unused-imports/no-unused-imports": "error",
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
      ...reactHooksRules,
    },
  },
];
