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
      "inter-style": '"Inter"',
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
        "30-vh": "30vh",
        "40-vh": "40vh",
        "75-vh": "75vh",
        onBordingSupplier: "calc(100vh - 300px)",
      },
      maxHeight: {
        "25-rem": "25rem",
      },
      width: {
        100: "25rem",
        133: "35rem",
        200: "58rem",
        150: "9.375rem",
        "1.1-rem": "1.125rem",
        "77-rem": "77rem",
        "30-rem": "30rem",

        pageWidth11: "75rem",
        fixedPageWidth: "75.5rem",
        standardPageWidth: "67.5rem",
      },
      maxWidth: {
        fixedPageWidth: "82.75rem",
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
      },
      fontSize: {
        "fs-10": "10px",
        "fs-11": "11px",
        "fs-13": "13px",
        "fs-14": "14px",
        "fs-16": "16px",
        "fs-18": "18px",
        "fs-20": "20px",
        "fs-24": "24px",
        "fs-28": "28px",
      },
      colors: {
        primary: {
          DEFAULT: withOpacity("--color-primary"), // Default primary color
          hover: withOpacity("--color-hover"),
          sidebar: withOpacity("--color-sidebar"),
          custom: "#006DF9", // Custom primary color
        },
        blue: {
          100: "#F1F2F4",
          200: "#DAECFF",
          300: "#BED4F0",
          400: "#006DF9CC",
          500: "#006DF9",
          600: "#005ED6",
          700: "#66A9FF",
          800: "#F5F9FF",
          810: "#B9D3F8",
          811: "#0069FD",
          background_blue: "#EAEEF9",
          info_blue_background: "#F6F8FA",
        },
        grey: {
          0: "#FEFEFE",
          200: "#B9BABC",
          300: "#CCCCCC",
          700: "#151A1F",
          900: "#333333",
        },
        green: {
          50: "#EFF4EF",
          600: "#B8D1B4",
          700: "#6CB851",
          950: "#79A779",
          960: "#3A833A",
          success_page_bg: "#E8FDF2",
          accepted_green_800: "#39934F",
        },
        orange: {
          100: "#FEF2E9",
          600: "#FDD4B6",
          950: "#D88B54",
          960: "#E89519",
          border_orange: "#eea23640",
          warning_background_orange: "#eea2361a",
          warning_text_orange: "#EEA236",
        },
        red: {
          DEFAULT: "#FF0000",
          100: "#F9EDED",
          800: "#C04141",
          900: "#DA0E0F",
          950: "#F04849",
          960: "#EF6969",
          980: "#FC5454",
          failed_page_bg: "#FDEDE8",
        },
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
        hyperswitch_background: "#F7F8FB",
        pdf_background: "#F5F5F5",
        offset_white: "#FEFEFE",
        light_white: "#FFFFFF0D",
        unselected_white: "#9197A3",
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
  ],
};

// clean jp-gray
// refactor colors object
// use Primar and seconday color for button
// we should use UIConfigs value as placeholder in the button
