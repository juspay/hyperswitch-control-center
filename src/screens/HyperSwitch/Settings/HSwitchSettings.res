open HSwitchSettingTypes

let businessSettings = {
  heading: "Business Settings",
  subHeading: "Add and manage primary or secondary contact and general details about your business.",
  redirect: "business",
  cardName: #BUSINESS_SETTINGS,
}

let businessUnits = {
  heading: "Business Profile Configuration",
  subHeading: "Add and manage labels to represent different businesses across countries.",
  redirect: "units",
  buttonText: "Add Configuration",
  cardName: #BUSINESS_UNITS,
}

let deleteSampleData = {
  heading: "Delete Sample Data",
  subHeading: "Delete all the generated sample data.",
  buttonText: "Delete All",
  isApiCall: true,
  cardName: #DELETE_SAMPLE_DATA,
}

let moduleLevelSettings = [
  {
    heading: "Mandate Settings",
    subHeading: "Add and manage mandate related details for all connector configurations.",
    redirect: "mandate",
    isComingSoon: true,
    cardName: #MANDATE_SETTINGS,
  },
]

module TileComponent = {
  @react.component
  let make = (
    ~heading,
    ~subHeading,
    ~redirect=?,
    ~isComingSoon=false,
    ~buttonText="Add Details",
    ~redirectUrl,
    ~isApiCall=true,
    ~cardName,
  ) => {
    open APIUtils
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    let showPopUp = PopUpState.useShowPopUp()
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()

    let deleteSampleData = async () => {
      try {
        let generateSampleDataUrl = getURL(~entityName=GENERATE_SAMPLE_DATA, ~methodType=Delete, ())
        let _generateSampleData = await updateDetails(
          generateSampleDataUrl,
          Js.Dict.empty()->Js.Json.object_,
          Delete,
        )
        showToast(~message="Sample data deleted successfully", ~toastType=ToastSuccess, ())
      } catch {
      | _ => ()
      }
    }
    let openPopUpModal = _ =>
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Are you sure?",
        description: {
          "This action cannot be undone. This will permanently delete all the sample payments and refunds data. To confirm, click the 'Delete All' button below."->React.string
        },
        handleConfirm: {
          text: "Delete All",
          onClick: {
            _ => {
              if HSwitchGlobalVars.isHyperSwitchDashboard {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName=heading->Js.String2.replace(" ", "_"),
                  ~actionName="delete_sample_data_confirm",
                  (),
                )
              }
              deleteSampleData()->ignore
            }
          },
        },
        handleCancel: {
          text: "Cancel",
          onClick: {
            _ => {
              if HSwitchGlobalVars.isHyperSwitchDashboard {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName=heading->Js.String2.replace(" ", "_"),
                  ~actionName="delete_sample_data_cancel",
                  (),
                )
              }
            }
          },
        },
      })

    let onClickHandler = _ => {
      if isApiCall {
        switch cardName {
        | #DELETE_SAMPLE_DATA => openPopUpModal()
        | _ => ()
        }
      } else {
        switch redirectUrl {
        | Some(url) => RescriptReactRouter.push(`/${url}`)
        | None =>
          switch redirect {
          | Some(redirect) => RescriptReactRouter.push(`settings?type=${redirect}`)
          | None => RescriptReactRouter.push(`settings`)
          }
        }
      }
      hyperswitchMixPanel(
        ~pageName=url.path->LogicUtils.getListHead,
        ~contextName=heading->Js.String2.replace(" ", "_"),
        ~actionName=buttonText->Js.String2.replace(" ", "_"),
        (),
      )
    }
    <div
      className="flex flex-col bg-white pt-6 pl-6 pr-8 pb-8 justify-between gap-10 border border-jp-gray-border_gray rounded ">
      <div>
        <div className="flex justify-between">
          <p className="text-fs-16 font-semibold m-2"> {heading->React.string} </p>
          {isComingSoon ? <Icon className="w-36" name="comingSoon" size=25 /> : React.null}
        </div>
        <p className="text-fs-14 font-medium m-2 text-black opacity-50">
          {subHeading->React.string}
        </p>
      </div>
      <Button
        text=buttonText
        buttonType=Secondary
        customButtonStyle="w-2/3"
        buttonSize={Small}
        onClick={onClickHandler}
        buttonState={isComingSoon ? Disabled : Normal}
      />
    </div>
  }
}
module PersonalSettings = {
  @react.component
  let make = () => {
    let featureFlagDetails =
      HyperswitchAtom.featureFlagAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->FeatureFlagUtils.featureFlagType
    let personalSettings = if featureFlagDetails.sampleData {
      [businessSettings, businessUnits, deleteSampleData]
    } else {
      [businessSettings]
    }

    <div className="flex flex-col gap-5 ">
      <div className={HSwitchUtils.getTextClass(~textVariant=H3, ~h3TextVariant=Leading_1, ())}>
        {React.string("Personal Settings ")}
        <p className="font-medium text-fs-14 text-black opacity-50">
          {"Set your defaults on module level, profile level, and platform level. This module is editable only by admins and view only for other members."->React.string}
        </p>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-8">
        {personalSettings
        ->Array.mapWithIndex((sections, index) =>
          <TileComponent
            key={string_of_int(index)}
            heading={sections.heading}
            subHeading={sections.subHeading}
            redirect={sections.redirect->Belt.Option.getWithDefault("")}
            isComingSoon={sections.isComingSoon->Belt.Option.getWithDefault(false)}
            buttonText={sections.buttonText->Belt.Option.getWithDefault("Add Details")}
            redirectUrl={sections.redirectUrl}
            isApiCall={sections.isApiCall->Belt.Option.getWithDefault(false)}
            cardName={sections.cardName}
          />
        )
        ->React.array}
      </div>
    </div>
  }
}
module ModuleSettings = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-5">
      <div className={HSwitchUtils.getTextClass(~textVariant=H3, ~h3TextVariant=Leading_1, ())}>
        {React.string("Module Level Settings")}
        <p className=" font-medium text-fs-14 text-black opacity-50">
          {"Set your defaults on module level, profile level, and platform level. This module is editable only by admins and view only for other members."->React.string}
        </p>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-8">
        {moduleLevelSettings
        ->Array.mapWithIndex((sections, index) =>
          <TileComponent
            key={string_of_int(index)}
            heading={sections.heading}
            subHeading={sections.subHeading}
            redirect={sections.redirect->Belt.Option.getWithDefault("")}
            isComingSoon={sections.isComingSoon->Belt.Option.getWithDefault(false)}
            redirectUrl={sections.redirectUrl}
            cardName={sections.cardName}
          />
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let (currentPage, setCurrentPage) = React.useState(() => LandingPage)

  let url = RescriptReactRouter.useUrl()
  React.useEffect1(() => {
    let searchParams = url.search
    let filtersFromUrl =
      LogicUtils.getDictFromUrlSearchParams(searchParams)
      ->Js.Dict.get("type")
      ->Belt.Option.getWithDefault("")
    setCurrentPage(_ => filtersFromUrl->typeMapper)
    None
  }, [url.search])

  <div className="h-full overflow-scroll flex flex-col gap-10">
    {switch currentPage {
    | Business =>
      <History.BreadCrumbWrapper
        pageTitle={currentPage->headingTypeMapper} baseLink={"/settings"} title="Settings">
        <BusinessSettings />
      </History.BreadCrumbWrapper>
    | Units =>
      <History.BreadCrumbWrapper
        pageTitle={currentPage->headingTypeMapper} baseLink={"/settings"} title="Settings">
        <BusinessMapping />
      </History.BreadCrumbWrapper>
    | LandingPage => <PersonalSettings />
    | _ => React.null
    }}
  </div>
}
