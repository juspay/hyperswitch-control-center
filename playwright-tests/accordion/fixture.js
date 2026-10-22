import React from "react";
import { createRoot } from "react-dom/client";
import {
  ThemeProvider,
  AccordionV2,
  AccordionV2Item,
} from "@juspay/blend-design-system";
import { make as AccordionAdapter } from "../../src/blend/adapters/AccordionAdapter.res.js";
import { blendEnabledContext } from "../../src/context/BlendContext.res.js";

const params = new URLSearchParams(location.search);
const events = [];
window.accordionEvents = events;
const accordion = ["First", "Second"].map((title) => ({
  title,
  renderContentOnTop: params.has("custom")
    ? () => React.createElement("span", null, `${title} custom`)
    : undefined,
  onItemExpandClick: () => events.push(`${title}:expand`),
  onItemCollapseClick: () => events.push(`${title}:collapse`),
  renderContent: (_isOpen, closeAccordionFn) =>
    React.createElement(
      "button",
      { onClick: closeAccordionFn },
      `Close ${title}`,
    ),
}));
createRoot(document.getElementById("root")).render(
  React.createElement(
    ThemeProvider,
    null,
    React.createElement(
      blendEnabledContext.Provider,
      { value: !params.has("legacy") },
      React.createElement(AccordionAdapter, {
        accordion,
        singleOpen: params.has("single"),
        initialOpenIndex: 0,
        initialExpandedArray: [0],
      }),
    ),
    React.createElement(
      AccordionV2,
      null,
      React.createElement(
        AccordionV2Item,
        { value: "disabled", title: "Disabled item", isDisabled: true },
        "Must stay hidden",
      ),
    ),
  ),
);
