# Decision Engine iframe themes

The routing workspace forwards the effective HS theme into the same-origin DE iframe. Theme selection and inheritance stay in `ThemeProvider`; DE does not fetch or persist another copy of merchant configuration.

`ThemeProvider.resolvedTheme` exposes the normalized settings and a revision after the existing fetch or `init_config` application path succeeds. Superseded requests cannot replace a newer theme. While a fetch is pending the snapshot is absent, and the workspace sends it when it resolves.

`DecisionEngineHooks.useDecisionEngineTheme` listens for `de:theme-ready` from the current iframe and sends a complete `de:theme-update` snapshot. The iframe's load event requests readiness again, so an in-frame reload works without another SSO exchange. Theme changes do not remint a code or replace the iframe. A changed iframe URL remounts the frame and gets a fresh handshake.

Both directions check the exact origin and window source. Use the existing same-origin proxy for development; arbitrary cross-origin embedding is not enabled. When a merchant portal embeds HS, its existing `init_config` message is resolved by HS and then forwarded to the immediate DE child.

The adapter maps primary color, page background, primary/secondary button colors, link colors, typography, and control radius. It keeps content surfaces white and DE's neutral foreground/border defaults; HS's sidebar, logo, semantic statuses, and categorical chart palettes are not copied into DE. DE validates supported values and falls back for invalid/missing fields.

The protocol and supported values are documented in DE's [embedded theme contract](https://github.com/juspay/decision-engine/blob/feat/embedded-merchant-theming/docs/embedded-theming.md). V1 is light mode; standalone DE remains unchanged. Deploy the backward-compatible DE receiver first, then the CC sender. An older DE ignores these messages; an older CC leaves DE on its light fallback.

The workspace Playwright spec includes a child-frame fixture that verifies live forwarding and reset without losing an unsaved value or reminting. Run it with the normal HS test backend and `dev_embed_decision_engine` enabled, alongside the ReScript build, formatting, and lint checks.
