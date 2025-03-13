///////////////////////////////////////////////////////////////////////////////

///  ***Reference***  ///
/// https://github.com/fbrill/dynamic-colors-in-tailwind/blob/main/utils/index.js///

///////////////////////////////////////////////////////////////////////////////
function withOpacity(variableName) {
  return ({ opacityValue }) => {
    if (opacityValue !== undefined) {
      return `rgba(var(${variableName}), ${opacityValue})`;
    }
    return `rgb(var(${variableName}))`;
  };
}
const plugin = require("tailwindcss/plugin");

module.exports = {
  darkMode: "class",
  content: ["./src/**/*.js"],
  theme: {
    fontFamily: {
      "inter-style": '"InterDisplay"',
    },
    extend: {
      screens: {
        mobile: "28.125rem",
        tablet: "93.75rem",
        laptop: "67.5rem",
        desktop: "118.75rem",
      },
      scale: {
        400: "4",
      },
      height: {
        "1.1-rem": "1.125rem",
        "5-rem": "5rem",
        "6-rem": "6rem",
        "7-rem": "7rem",
        "8-rem": "8rem",
        "12.5-rem": "12.5rem",
        "25-rem": "25rem",
        "30-rem": "30rem",
        "35-rem": "35rem",
        "40-rem": "40rem",
        "45-rem": "45rem",
        "48-rem": "48rem",
        "50-rem": "50rem",
        "93-per": "93%",
        "80-vh": "80vh",
        "85-vh": "85vh",
        "30-vh": "30vh",
        "40-vh": "40vh",
        "75-vh": "75vh",
        "32-px": "32px",
        "36-px": "36px",
        "40-px": "40px",
        "68-px": "68px",
        "120-px": "120px",
        "130-px": "130px",
        "195-px": "195px",
        "774-px": "774px",
        "923-px": "923px",
        "12.5-rem": "12.5rem",
        onBordingSupplier: "calc(100vh - 300px)",
      },
      padding: {
        "10-px": "10px",
      },
      maxHeight: {
        "25-rem": "25rem",
      },
      inset: {
        "76-px": "76px",
      },
      width: {
        "90-px": "90px",
        100: "25rem",
        133: "35rem",
        200: "58rem",
        150: "9.375rem",
        "1.1-rem": "1.125rem",
        "18-rem": "18rem",
        "22-rem": "22rem",
        "77-rem": "77rem",
        "30-rem": "30rem",
        "10.25-rem": "10.25rem",
        "89.5-per": "89.5%",
        "104-px": "104px",
        "137-px": "137px",
        "145-px": "145px",
        "147-px": "147px",
        "298-px": "298px",
        "334-px": "334px",
        "499-px": "499px",
        "540-px": "540px",
        "500-px": "500px",
        "1034-px": "1034px",
        modalOverlay: "calc(100vw + 7rem)",
        pageWidth11: "75rem",
        fixedPageWidth: "75.5rem",
        standardPageWidth: "67.5rem",
      },
      gap: {
        "0.5-rem": "0.5rem",
      },
      maxWidth: {
        fixedPageWidth: "82.75rem",
        860: "860px",
        600: "600px",
        700: "700px",
        800: "800px",
      },
      lineHeight: {
        18: "18px",
        20: "20px",
        21: "21px",
        24: "24px",
        38: "38px",
        60: "60px",
      },
      blur: {
        xs: "0.2px",
      },
      borderWidth: {
        1.5: "1.5px",
        "20-px": "20px",
      },
      boxShadow: {
        generic_shadow: "0 2px 5px 0 rgba(0, 0, 0, 0.12)",
        generic_shadow_dark: "0px 2px 5px 0 rgba(0, 0, 0, 0.78)",
        side_shadow: "0 4px 4px rgba(0, 0, 0, 0.25)",
        hyperswitch_box_shadow: "0 2px 8px 0px rgba(0,0,0,0.08)",
        checklistShadow: "-2px -4px 12px 0px rgba(0,0,0,0.11)",
        sidebarShadow: "0 -2px 12px 0 rgba(0, 0, 0, 0.06)",
        connectorTagShadow: "0px 1px 4px 2px rgba(0, 0, 0, 0.06)",
        boxShadowMultiple:
          "2px -2px 24px 0px rgba(0, 0, 0, 0.04), -2px 2px 24px 0px rgba(0, 0, 0, 0.02)",
        homePageBoxShadow: "0px 2px 16px 2px rgba(51, 51, 51, 0.16)",
        focusBoxShadow:
          "0px 1px 2px 0px rgba(0, 0, 0, 0.05), 0px 0px 0px 4px rgba(232, 243, 255, 1)",
        cardShadow: "0px 2px 2px 0px rgba(0, 0, 0, 0.04)",
      },
      fontSize: {
        base: "var(--base-font-size)",
        heading: "var(--base-heading-font-size)",
        "fs-10": "10px",
        "fs-11": "11px",
        "fs-13": "13px",
        "fs-14": "14px",
        "fs-15": "15px",
        "fs-16": "16px",
        "fs-18": "18px",
        "fs-20": "20px",
        "fs-24": "24px",
        "fs-28": "28px",
        "fs-32": "32px",
        "fs-48": "48px",
      },
      colors: {
        primary: {
          DEFAULT: withOpacity("--colors-primary"),
          custom: "#006DF9",
        },
        secondary: {
          DEFAULT: withOpacity("--colors-secondary"),
          hover: withOpacity("--btn-secondary-hover-background-color"),
        },
        sidebar: {
          DEFAULT: withOpacity("--sidebar-primary"),
          primary: withOpacity("--sidebar-primary"),
          secondary: withOpacity("--sidebar-secondary"),
          hoverColor: withOpacity("--sidebar-hover-color"),
          primaryTextColor: withOpacity("--sidebar-primary-text-color"),
          secondaryTextColor: withOpacity("--sidebar-secondary-text-color"),
          borderColor: withOpacity("--sidebar-border-color"),
        },

        background: {
          DEFAULT: withOpacity("--colors-background"),
        },
        typography: {
          DEFAULT: withOpacity("--base-text-color"),
          link: withOpacity("--base-link-color"),
          link_hover: withOpacity("--base-link-hover-color"),
        },
        button: {
          primary: {
            bg: withOpacity("--btn-primary-background-color"),
            text: withOpacity("--btn-primary-text-color"),
            hoverbg: withOpacity("--btn-primary-hover-background-color"),
          },
          secondary: {
            bg: withOpacity("--btn-secondary-background-color"),
            text: withOpacity("--btn-secondary-text-color"),
            hoverbg: withOpacity("--btn-secondary-hover-background-color"),
          },
        },
        outline: withOpacity("--borders-border-color"),
        blue: {
          100: "#F1F2F4",
          150: "#E6F7FF",
          200: "#DAECFF",
          300: "#BED4F0",
          400: "#006DF9CC",
          500: "#006DF9",
          600: "#005ED6",
          700: "#66A9FF",
          800: "#F5F9FF",
          810: "#B9D3F8",
          811: "#0069FD",
          812: "#1B85FF",
          820: "#37476C",
          830: "#465B8B",
          840: "#303E5F",
          background_blue: "#EAEEF9",
          info_blue_background: "#F6F8FA",
        },
        grey: {
          0: "#FEFEFE",
          100: "#666666",
          200: "#B9BABC",
          300: "#CCCCCC",
          400: "#D1D5DB",
          700: "#151A1F",
          800: "#383838",
          900: "#333333",
          dark: "#1E1E1E",
          light: "#F6F6F6",
          medium: "#A0A0A0",
          outline: "#E5E5E5",
          text: "#474D59",
        },
        green: {
          50: "#EFF4EF",
          100: "#F6FFED",
          500: "#108548",
          600: "#B8D1B4",
          700: "#6CB851",
          950: "#79A779",
          960: "#3A833A",
          success_page_bg: "#E8FDF2",
          accepted_green_800: "#39934F",
          dark: "#12B76A",
          light: "#0E92551A",
          status: "#2DA160",
        },
        orange: {
          100: "#FFFBE6",
          500: "#E07E41",
          600: "#FDD4B6",
          950: "#D88B54",
          960: "#E89519",
          border_orange: "#eea23640",
          warning_background_orange: "#eea2361a",
          warning_text_orange: "#EEA236",
          status: "#D99530",
        },
        red: {
          DEFAULT: "#FF0000",
          100: "#FFF1F0",
          800: "#C04141",
          900: "#DA0E0F",
          950: "#F04849",
          960: "#EF6969",
          980: "#FC5454",
          failed_page_bg: "#FDEDE8",
          dark: "#F04E42",
          light: "#FEEDEC",
          status: "#DD2B0E",
        },
        "yellow-bg": "#F7D59B4D",
        "profile-sidebar-blue": "#16488F",
        "status-green": "#36AF47",
        "popover-background": "#334264",
        "popover-background-hover": "#2E3B58",
        "status-text-orange": "#E9AA0A",
        "status-blue": "#0585DD",
        "border-light-grey": "#E6E6E6",
        light_blue_bg: "#F8FAFF",
        "light-grey": "#DFDFDF",
        "extra-light-grey": "#F0F2F4",
        "jp-gray": {
          50: "#FAFBFD",
          100: "#F7F8FA",
          200: "#F1F5FA",
          250: "#FDFEFF",
          300: "#E7EAF1",
          400: "#D1D4D8",
          500: "#D8DDE9",
          600: "#CCCFD4",
          700: "#666666",
          800: "#67707D",
          850: "#31333A",
          900: "#333333",
          950: "#202124",
          960: "#2C2D2F",
          970: "#1B1B1D",
          930: "#989AA5",
          940: "#CCD2E2",
          980: "#ACADB8",
          dark_table_border_color: "#2e2f39",
          tabset_gray: "#f6f8f9",
          disabled_border: "#262626",
          table_hover: "#F9FBFF",
          darkgray_background: "#151A1F",
          lightgray_background: "#151A1F",
          text_darktheme: "#F6F8F9",
          lightmode_steelgray: "#CCD2E2",
          tooltip_bg_dark: "#F7F7FA",
          tooltip_bg_light: "#23211D",
          dark_disable_border_color: "#8d8f9a",
          light_table_border_color: "#CDD4EB",
          no_data_border: "#6E727A",
          border_gray: "#354052", // need to check this
          sankey_labels: "#7e828f",
          dark_black: "#0E0E0E",
          banner_black: "#333333",
          light_gray_bg: "#FAFAFA",
          button_gray: "#F7F7F7",
          border_gray: "#E8E8E8", // need to check this
          secondary_hover: "#EEEEEE",
          test_credentials_bg: "#D9D9D959",
        },
        hyperswitch_dark_bg: "#212E46",
        light_blue: "#006DF966",
        light_grey: "#454545",
        hyperswitch_green: "#71B44B",
        light_green: "#32AA52",
        hyperswitch_green_trans: "#71B44B20",
        hyperswitch_red: "#D7625B",
        hyperswitch_background: "#FFFFFF",
        pdf_background: "#F5F5F5",
        offset_white: "#FEFEFE",
        light_white: "#FFFFFF0D",
        unselected_white: "#9197A3",

        /* NEW DESIGN COLORS */
        nd_gray: {
          25: "#FCFCFD",
          50: "#F5F7FA",
          100: "FBFBFB",
          150: "#ECEFF3",
          200: "#E1E4EA",
          300: "#CACFD8",
          500: "#606B85",
          400: "#99A0AE",
          600: "#525866",
          700: "#2B303B",
          800: "#222530",
        },
        nd_primary_blue: {
          50: "#E4F1FD",
          100: "#BCD7FA",
          200: "#93BCF6",
          300: "#6AA1F2",
          400: "#4287EF",
          500: "#1C6DEA",
        },
        //borders gray
        nd_br_gray: {
          150: "#ECEFF3",
          200: "#E1E4EA",
          400: "#E1E1E1",
          500: "#E1E3EA",
        },
        nd_br_red: {
          subtle: "#FCDAD7",
        },
        nd_green: {
          50: "#ECF4EE",
          200: "#52B87A",
          400: "#2DA160",
          600: "#217645",
        },
        nd_red: {
          50: "#FCF1EF",
          400: "#EC5941",
        },
      },
      borderRadius: {
        DEFAULT: "var(--borders-default-radius)",
        "10-px": "10px",
      },
      spacing: {
        DEFAULT: "var(--spacing-padding)",
      },
    },
  },
  plugins: [
    plugin(function ({ addUtilities }) {
      const newUtilities = {
        "*::-webkit-scrollbar": {
          display: "none", // chrome and other
        },
        "*": {
          scrollbarWidth: "none", // firefox
        },
        ".show-scrollbar::-webkit-scrollbar": {
          display: "block",
          overflow: "scroll",
          height: "4px",
          width: "8px",
        },
        ".show-scrollbar::-webkit-scrollbar-thumb": {
          display: "block",
          borderRadius: "20rem",
          backgroundColor: "#8A8C8F",
        },
        ".show-scrollbar::-webkit-scrollbar-track": {
          backgroundColor: "#FFFFFFF",
        },
      };
      addUtilities(newUtilities);
    }),
    plugin(function ({ addVariant, addUtilities, e }) {
      addVariant("red", ({ modifySelectors, separator }) => {
        modifySelectors(({ className }) => {
          return `.red${separator}${className}`;
        });
      });
      const newUtilities = {
        ".red .red\\:bg-red": {
          "--tw-bg-opacity": "1",
          "background-color": "rgb(255 0 0 / var(--tw-bg-opacity))",
        },
      };

      addUtilities(newUtilities, ["responsive", "hover"]);
    }),
    plugin(function ({ addUtilities }) {
      const newUtilities = {
        ".primary-gradient-button": {
          boxShadow:
            "0px 0px 0px 1px hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 1) calc(l + 2) / 1)",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 1) calc(l - 7) / 1) -5%, rgb(var(--btn-primary-background-color)) 107.5%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 2) calc(l + 10) / 1) -6.25%, rgb(var(--btn-primary-hover-background-color)) 100%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".primary-gradient-button:hover": {
          boxShadow:
            "0px 0px 0px 1px hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 1) calc(l + 2) / 1)",
          backgroundImage: `linear-gradient(180deg, rgb(var(--btn-primary-background-color)) 0%, hsl(from rgb(var(--btn-primary-background-color)) h s calc(l + 4) / 1) 100%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 2) calc(l + 10) / 1) -6.25%, rgb(var(--btn-primary-hover-background-color)) 100%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".primary-gradient-button:active": {
          boxShadow: "0px 3px 4px 0px #00000026 inset",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 1) calc(l - 13) / 1) -5%, rgb(var(--btn-primary-background-color)) 107.5%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) calc(h - 1) calc(s + 1) calc(l - 18) / 1) -6.25%, rgb(var(--btn-primary-hover-background-color)) 100%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".primary-gradient-button:focus-visible": {
          boxShadow:
            "0px 0px 0px 3px hsl(from rgb(var(--btn-primary-hover-background-color)) calc(h - 1) calc(s + 3) calc(l + 45) / 1)",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 1) calc(l - 7) / 1) -5%, rgb(var(--btn-primary-background-color)) 107.5%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s + 2) calc(l + 10) / 1) -6.25%, rgb(var(--btn-primary-hover-background-color)) 100%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".primary-gradient-button:disabled": {
          boxShadow:
            "0px 0px 0px 1px hsl(from rgb(var(--btn-primary-hover-background-color)) h calc(s + 3) calc(l + 35) / 1)",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-primary-background-color)) h calc(s - 10) calc(l + 25) / 1) 0%, hsl(from rgb(var(--btn-primary-background-color)) h calc(s - 10) calc(l + 25) / 1) 100%)`,
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".secondary-gradient-button": {
          boxShadow: "0px 0px 0px 1px #bfbfc380",
          backgroundImage: `linear-gradient(180deg, rgb(var(--btn-secondary-background-color)) 0%, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 5) / 1) 100%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 5) / 1) 0%, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 1) / 1) 97.5%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".secondary-gradient-button:hover": {
          boxShadow: "0px 0px 0px 1px #bfbfc380",
          backgroundImage: `linear-gradient(180deg, rgb(var(--btn-secondary-hover-background-color)) 0%, rgb(var(--btn-secondary-hover-background-color)) 100%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 5) / 1) 0%, hsl(from rgb(var(--btn-secondary-hover-background-color)) h calc(s - 11) calc(l - 6) / 0.75) 97.5%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".secondary-gradient-button:active": {
          boxShadow: "0px 3px 4px 0px #0000001a inset",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-hover-background-color)) h calc(s - 11) calc(l - 6) / 1) 0%, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 3) / 1) 100%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-hover-background-color)) h calc(s - 11) calc(l - 6) / 0.75) 0%, hsl(from rgb(var(--btn-secondary-hover-background-color)) h calc(s - 11) calc(l - 6) / 1) 97.5%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
        ".secondary-gradient-button:focus-visible": {
          boxShadow: "0px 0px 0px 3px #bfbfc354",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-hover-background-color)) calc(h + 20) calc(s + 23) l / 1) 0%, hsl(from rgb(var(--btn-secondary-hover-background-color)) calc(h + 20) calc(s + 23) l / 1) 100%),
            linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-background-color)) h s calc(l + 3) / 1) 0%, hsl(from rgb(var(--btn-secondary-hover-background-color)) h calc(s - 11) calc(l - 6) / 0.75) 97.5%)`,
          transition: "ease-out 120ms",
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
          outline: "none",
        },
        ".secondary-gradient-button:disabled": {
          boxShadow: "0px 0px 0px 1px #bfbfc354",
          backgroundImage: `linear-gradient(180deg, hsl(from rgb(var(--btn-secondary-hover-background-color)) calc(h - 20) calc(s + 10) calc(l - 3) / 1) 0%, hsl(from rgb(var(--btn-secondary-hover-background-color)) calc(h - 20) calc(s + 10) calc(l - 3) / 1) 100%)`,
          backgroundOrigin: "border-box",
          backgroundClip: "content-box, border-box",
        },
      };

      addUtilities(newUtilities, ["responsive", "hover"]);
    }),
  ],
};

// clean jp-gray
// refactor colors object
// use Primar and seconday color for button
// we should use UIConfigs value as placeholder in the button
