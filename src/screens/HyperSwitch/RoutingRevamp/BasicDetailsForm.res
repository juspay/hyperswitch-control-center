open FormRenderer
open AdvancedRoutingTypes
open LogicUtils

let configurationNameInput = makeFieldInfo(
  ~label="Configuration Name",
  ~name="name",
  ~isRequired=true,
  ~placeholder="Enter Configuration Name",
  ~customInput=InputFields.textInput(~autoFocus=true, ()),
  (),
)
let descriptionInput = makeFieldInfo(
  ~label="Description",
  ~name="description",
  ~isRequired=true,
  ~placeholder="Add a description for your configuration",
  ~customInput=InputFields.multiLineTextInput(
    ~isDisabled=false,
    ~rows=Some(3),
    ~cols=None,
    ~customClass="text-sm",
    (),
  ),
  (),
)

module BusinessProfileInp = {
  @react.component
  let make = (~setProfile, ~profile, ~options, ~label="", ~routingType=ADVANCED) => {
    let selectedConnectorsInput = ReactFinalForm.useField("algorithm.data").input

    <FormRenderer.FieldRenderer
      field={FormRenderer.makeFieldInfo(
        ~label,
        ~isRequired=true,
        ~name="profile_id",
        ~customInput=(~input, ~placeholder as _) =>
          InputFields.selectInput(
            ~input={
              ...input,
              value: profile->Js.Json.string,
              onChange: {
                ev => {
                  setProfile(_ => ev->Identity.formReactEventToString)
                  input.onChange(ev)
                  let defaultAlgorithm = if routingType == VOLUME_SPLIT {
                    []->Identity.anyTypeToReactEvent
                  } else {
                    AdvancedRoutingUtils.defaultAlgorithmData->Identity.anyTypeToReactEvent
                  }
                  selectedConnectorsInput.onChange(defaultAlgorithm)
                }
              },
            },
            ~deselectDisable=true,
            ~options,
            ~buttonText="",
            ~placeholder="",
            (),
          ),
        (),
      )}
    />
  }
}

@react.component
let make = (
  ~currentTabName="",
  ~formState=CreateConfig,
  ~setInitialValues=_ => (),
  ~isThreeDs=false,
  ~profile=?,
  ~setProfile=?,
  ~routingType=ADVANCED,
) => {
  open MerchantAccountUtils
  let ip1 = ReactFinalForm.useField(`name`).input
  let ip2 = ReactFinalForm.useField(`description`).input
  let ip3 = ReactFinalForm.useField(`profile_id`).input

  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->getValueFromBusinessProfile
  let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile

  //Need to check if necessary
  let form = ReactFinalForm.useForm()
  React.useEffect0(() => {
    form.change(
      "profile_id",
      profile->Option.getWithDefault(defaultBusinessProfile.profile_id)->Js.Json.string,
    )
    None
  })

  <div
    className={` mb-6 p-4 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850`}>
    {if formState === ViewConfig {
      <div>
        <div className="flex flex-row justify-between gap-4">
          <div className="flex flex-row gap-40">
            <AddDataAttributes attributes=[("data-field", "Configuration Name")]>
              <div className="flex flex-col gap-2 items-start justify-between py-2">
                <span className="text-gray-500 dark:text-gray-400">
                  {React.string("Configuration Name")}
                </span>
                <AddDataAttributes attributes=[("data-text", getStringFromJson(ip1.value, ""))]>
                  <span className="font-semibold">
                    {React.string(getStringFromJson(ip1.value, ""))}
                  </span>
                </AddDataAttributes>
              </div>
            </AddDataAttributes>
            <AddDataAttributes attributes=[("data-field", "Description")]>
              <div className="flex flex-col gap-2 items-start justify-between py-2">
                <span className="text-gray-500 dark:text-gray-400">
                  {React.string("Description")}
                </span>
                <AddDataAttributes attributes=[("data-text", getStringFromJson(ip2.value, ""))]>
                  <span className="font-semibold">
                    {React.string(getStringFromJson(ip2.value, ""))}
                  </span>
                </AddDataAttributes>
              </div>
            </AddDataAttributes>
          </div>
        </div>
        <div className="flex flex-row justify-between gap-4">
          <div className="flex flex-row gap-48">
            <AddDataAttributes attributes=[("data-field", "Profile Id")]>
              <div className="flex flex-col gap-2 items-start justify-between py-2">
                <span className="text-gray-500 dark:text-gray-400">
                  {React.string("Profile")}
                </span>
                <AddDataAttributes attributes=[("data-text", getStringFromJson(ip3.value, ""))]>
                  <span className="font-semibold">
                    <MerchantAccountUtils.BusinessProfile
                      profile_id={profile->Option.getWithDefault(defaultBusinessProfile.profile_id)}
                    />
                  </span>
                </AddDataAttributes>
              </div>
            </AddDataAttributes>
          </div>
        </div>
      </div>
    } else {
      <>
        <div className="flex">
          <div className="w-full md:w-1/2 lg:w-1/3">
            <UIUtils.RenderIf condition={!isThreeDs}>
              <BusinessProfileInp
                setProfile={setProfile->Option.getWithDefault(_ => ())}
                profile={profile->Option.getWithDefault(defaultBusinessProfile.profile_id)}
                options={arrayOfBusinessProfile->businessProfileNameDropDownOption}
                label="Profile"
                routingType
              />
            </UIUtils.RenderIf>
            <FieldRenderer field=configurationNameInput />
            <FieldRenderer field=descriptionInput />
          </div>
        </div>
      </>
    }}
  </div>
}
