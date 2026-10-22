import React, { useLayoutEffect, useRef } from "react";

export function useAccessibleTrigger(child, style, onClick) {
  const anchorRef = useRef(null);
  useLayoutEffect(() => {
    const anchor = anchorRef.current;
    if (!anchor) return;
    const control = Array.from(
      anchor.querySelectorAll(
        "button, input, select, textarea, a[href], [tabindex], [contenteditable=true]",
      ),
    ).find((element) => element.tabIndex >= 0 && !element.disabled);
    // Native actions remain Radix's direct child; custom slots retain a native
    // anchor, with only their actual enabled control in the keyboard sequence.
    anchor.tabIndex = anchor.disabled
      ? -1
      : control
        ? -1
        : Math.max(0, anchor.tabIndex);
    if (!control) return;
    const previous = control.getAttribute("aria-describedby");
    const sync = () => {
      const description = [previous, anchor.getAttribute("aria-describedby")]
        .filter(Boolean)
        .join(" ");
      if (description) control.setAttribute("aria-describedby", description);
      else control.removeAttribute("aria-describedby");
    };
    sync();
    const observer = new MutationObserver(sync);
    observer.observe(anchor, {
      attributes: true,
      attributeFilter: ["aria-describedby"],
    });
    return () => {
      observer.disconnect();
      if (previous === null) control.removeAttribute("aria-describedby");
      else control.setAttribute("aria-describedby", previous);
    };
  });
  const native =
    React.isValidElement(child) &&
    typeof child.type === "string" &&
    !child.props.disabled;
  const originalRef = native ? child.ref : undefined;
  const props = {
    ref: (element) => {
      anchorRef.current = element;
      if (typeof originalRef === "function") originalRef(element);
      else if (originalRef) originalRef.current = element;
    },
    onClick: (event) => {
      if (native) child.props.onClick?.(event);
      if (!event.defaultPrevented) onClick(event);
    },
  };
  return native
    ? React.cloneElement(child, props)
    : React.createElement("span", { ...props, style }, child);
}
