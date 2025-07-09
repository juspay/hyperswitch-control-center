open ThemeV2Types
open HyperSwitchConfigTypes

type emailConfig = {
  entity_name: string,
  entity_logo_url: string,
  primary_color: string,
  foreground_color: string,
  background_color: string,
}
type themeCreate = {
  lineage: lineage,
  theme_name: string,
  theme_data: customStylesTheme,
  email_config: option<emailConfig>,
}

let createLineage = (~orgId, ~merchantId, ~profileId) => {
  let entityType = SessionStorage.sessionStorage.getItem("entity_type")->Nullable.toOption
  switch entityType {
  | Some("tenant") => {
      entity_type: "tenant",
      tenant_id: "public",
      org_id: None,
      merchant_id: None,
      profile_id: None,
    }
  | Some("organization") => {
      entity_type: "organization",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: None,
      profile_id: None,
    }
  | Some("merchant") => {
      entity_type: "merchant",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: None,
    }
  | Some("profile") => {
      entity_type: "profile",
      tenant_id: "public",
      org_id: Some(orgId),
      merchant_id: Some(merchantId),
      profile_id: Some(profileId),
    }
  | _ => {
      entity_type: "",
      tenant_id: "",
      org_id: None,
      merchant_id: None,
      profile_id: None,
    }
  }
}

let defaultCreate = (~lineage) => {
  lineage,
  theme_name: "Default Theme",
  theme_data: {
    settings: {
      colors: {
        primary: "#006DF9",
        secondary: "#303E5F",
        background: "#006df9",
      },
      sidebar: {
        primary: "#FCFCFD",
        textColor: "#525866",
        textColorPrimary: "#1C6DEA",
      },
      typography: {
        fontFamily: "Roboto, sans-serif",
        fontSize: "14px",
        headingFontSize: "24px",
        textColor: "#006DF9",
        linkColor: "#3498db",
        linkHoverColor: "#005ED6",
      },
      buttons: {
        primary: {
          backgroundColor: "#1272f9",
          textColor: "#ffffff",
          hoverBackgroundColor: "#0860dd",
        },
        secondary: {
          backgroundColor: "#f3f3f3",
          textColor: "#626168",
          hoverBackgroundColor: "#fcfcfd",
        },
      },
      borders: {
        defaultRadius: "4px",
        borderColor: "#1272F9",
      },
      spacing: {
        padding: "16px",
        margin: "16px",
      },
    },
    urls: {
      faviconUrl: Some("/HyperswitchFavicon.png"),
      logoUrl: Some(""),
    },
  },
  email_config: None,
}
