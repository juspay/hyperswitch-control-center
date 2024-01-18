open FormRenderer
open AdvancedRoutingTypes

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
  ~setInitialValues=_ => (),
  ~isThreeDs=false,
  ~profile=?,
  ~setProfile=?,
  ~routingType=ADVANCED,
) => {
  open MerchantAccountUtils

  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->getValueFromBusinessProfile
  let arrayOfBusinessProfile = businessProfiles->getArrayOfBusinessProfile

  //Need to check if necessary
  let form = ReactFinalForm.useForm()
  React.useEffect0(() => {
    form.change(
      "profile_id",
      profile->Belt.Option.getWithDefault(defaultBusinessProfile.profile_id)->Js.Json.string,
    )
    None
  })

  <div
    className={` mb-6 p-4 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850`}>
    {<div className="flex">
      <div className="w-full md:w-1/2 lg:w-1/3">
        <UIUtils.RenderIf condition={!isThreeDs}>
          <BusinessProfileInp
            setProfile={setProfile->Belt.Option.getWithDefault(_ => ())}
            profile={profile->Belt.Option.getWithDefault(defaultBusinessProfile.profile_id)}
            options={arrayOfBusinessProfile->businessProfileNameDropDownOption}
            label="Profile"
            routingType
          />
        </UIUtils.RenderIf>
        <FieldRenderer field=configurationNameInput />
        <FieldRenderer field=descriptionInput />
      </div>
    </div>}
  </div>
}
