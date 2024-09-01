open UserUtils

let organizationSelection = orgList =>
  FormRenderer.makeFieldInfo(
    ~label="Select an organization",
    ~name="org_value",
    ~customInput=InputFields.selectInput(
      ~options=getMerchantSelectBoxOption(
        ~label="All organizations",
        ~value="all_organizations",
        ~dropdownList=orgList,
      ),
      ~buttonText="Select an organization",
      ~fullLength=true,
      ~customButtonStyle="!rounded-lg",
      ~dropdownCustomWidth="!w-full",
      ~textStyle="!text-gray-500",
    ),
  )

let merchantSelection = merchList =>
  FormRenderer.makeFieldInfo(
    ~label="Merchants for access",
    ~name="merchant_value",
    ~customInput=InputFields.selectInput(
      ~options=getMerchantSelectBoxOption(
        ~label="All merchants",
        ~value="all_merchants",
        ~dropdownList=merchList,
      ),
      ~buttonText="Select a Merchant",
      ~fullLength=true,
      ~customButtonStyle="!rounded-lg",
      ~dropdownCustomWidth="!w-full",
      ~textStyle="!text-gray-500",
    ),
  )
let profileSelection = profileList =>
  FormRenderer.makeFieldInfo(
    ~label="Profiles for access",
    ~name="profile_value",
    ~customInput=InputFields.selectInput(
      ~options=getMerchantSelectBoxOption(
        ~label="All profiles",
        ~value="all_profiles",
        ~dropdownList=profileList,
      ),
      ~buttonText="Select a Profile",
      ~fullLength=true,
      ~customButtonStyle="!rounded-lg",
      ~dropdownCustomWidth="!w-full",
      ~textStyle="!text-gray-500",
    ),
  )
