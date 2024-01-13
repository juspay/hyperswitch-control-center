open UserTimeZoneTypes
let getTimeZoneData = timeZoneType => {
  switch timeZoneType {
  | GMT => {
      offset: "+00:00",
      region: "Africa/Abidjan",
      title: "GMT",
    }
  | EAT => {
      offset: "+03:00",
      region: "Africa/Addis_Ababa",
      title: "EAT",
    }
  | CET => {
      offset: "+01:00",
      region: "Africa/Algiers",
      title: "CET",
    }
  | WAT => {
      offset: "+01:00",
      region: "Africa/Bangui",
      title: "WAT",
    }
  | CAT => {
      offset: "+02:00",
      region: "Africa/Blantyre",
      title: "CAT",
    }
  | EET => {
      offset: "+02:00",
      region: "Africa/Cairo",
      title: "EET",
    }
  | CEST => {
      offset: "+02:00",
      region: "Africa/Ceuta",
      title: "CEST",
    }
  | SAST => {
      offset: "+02:00",
      region: "Africa/Johannesburg",
      title: "SAST",
    }
  | HDT => {
      offset: "-09:00",
      region: "America/Adak",
      title: "HDT",
    }
  | AKDT => {
      offset: "-08:00",
      region: "America/Anchorage",
      title: "AKDT",
    }
  | AST => {
      offset: "-04:00",
      region: "America/Anguilla",
      title: "AST",
    }
  | EST => {
      offset: "-05:00",
      region: "America/Atikokan",
      title: "EST",
    }
  | CDT => {
      offset: "-05:00",
      region: "America/Bahia_Banderas",
      title: "CDT",
    }
  | CST => {
      offset: "-06:00",
      region: "America/Belize",
      title: "CST",
    }
  | MDT => {
      offset: "-06:00",
      region: "America/Boise",
      title: "MDT",
    }
  | MST => {
      offset: "-07:00",
      region: "America/Creston",
      title: "MST",
    }
  | EDT => {
      offset: "-04:00",
      region: "America/Detroit",
      title: "EDT",
    }
  | ADT => {
      offset: "-03:00",
      region: "America/Glace_Bay",
      title: "ADT",
    }
  | PDT => {
      offset: "-07:00",
      region: "America/Los_Angeles",
      title: "PDT",
    }
  | NDT => {
      offset: "-02:30",
      region: "America/St_Johns",
      title: "NDT",
    }
  | AEST => {
      offset: "+10:00",
      region: "Antarctica/Macquarie",
      title: "AEST",
    }
  | NZST => {
      offset: "+12:00",
      region: "Antarctica/McMurdo",
      title: "NZST",
    }
  | EEST => {
      offset: "+03:00",
      region: "Asia/Amman",
      title: "EEST",
    }
  | HKT => {
      offset: "+08:00",
      region: "Asia/Hong_Kong",
      title: "HKT",
    }
  | WIB => {
      offset: "+07:00",
      region: "Asia/Jakarta",
      title: "WIB",
    }
  | WIT => {
      offset: "+09:00",
      region: "Asia/Jayapura",
      title: "WIT",
    }
  | IDT => {
      offset: "+03:00",
      region: "Asia/Jerusalem",
      title: "IDT",
    }
  | PKT => {
      offset: "+05:00",
      region: "Asia/Karachi",
      title: "PKT",
    }
  | IST => {
      offset: "+05:30",
      region: "Asia/Kolkata",
      title: "IST",
    }
  | WITA => {
      offset: "+08:00",
      region: "Asia/Makassar",
      title: "WITA",
    }
  | PST => {
      offset: "+08:00",
      region: "Asia/Manila",
      title: "PST",
    }
  | KST => {
      offset: "+09:00",
      region: "Asia/Pyongyang",
      title: "KST",
    }
  | JST => {
      offset: "+09:00",
      region: "Asia/Tokyo",
      title: "JST",
    }
  | WEST => {
      offset: "+01:00",
      region: "Atlantic/Canary",
      title: "WEST",
    }
  | ACST => {
      offset: "+09:30",
      region: "Australia/Adelaide",
      title: "ACST",
    }
  | AWST => {
      offset: "+08:00",
      region: "Australia/Perth",
      title: "AWST",
    }
  | BST => {
      offset: "+01:00",
      region: "Europe/Guernsey",
      title: "BST",
    }
  | MSK => {
      offset: "+03:00",
      region: "Europe/Moscow",
      title: "MSK",
    }
  | ChST => {
      offset: "+10:00",
      region: "Pacific/Guam",
      title: "ChST",
    }
  | HST => {
      offset: "-10:00",
      region: "Pacific/Honolulu",
      title: "HST",
    }
  | SST => {
      offset: "-11:00",
      region: "Pacific/Midway",
      title: "SST",
    }
  | UTC => {
      offset: "+00:00",
      region: "UTC",
      title: "UTC",
    }
  }
}
