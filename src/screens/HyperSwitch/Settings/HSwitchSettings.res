open HSwitchSettingTypes

let deleteSampleData = {
  heading: "Delete Sample Data",
  subHeading: "Delete all the generated sample data.",
  buttonText: "Delete All",
  isApiCall: true,
  cardName: #DELETE_SAMPLE_DATA,
}

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
    let showPopUp = PopUpState.useShowPopUp()
    let showToast = ToastState.useShowToast()
    let updateDetails = useUpdateMethod()
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

    let deleteSampleData = async () => {
      try {
        let generateSampleDataUrl = getURL(~entityName=GENERATE_SAMPLE_DATA, ~methodType=Delete, ())
        let _ = await updateDetails(
          generateSampleDataUrl,
          Dict.make()->JSON.Encode.object,
          Delete,
          (),
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
              deleteSampleData()->ignore
            }
          },
        },
        handleCancel: {
          text: "Cancel",
          onClick: {
            _ => ()
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
    }
    let accessBasedOnCardName = switch cardName {
    | #DELETE_SAMPLE_DATA => userPermissionJson.paymentWrite
    | _ => Access
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
      <ACLButton
        access=accessBasedOnCardName
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
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let personalSettings = if featureFlagDetails.sampleData {
      [deleteSampleData]
    } else {
      []
    }

    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4 md:gap-8">
      {personalSettings
      ->Array.mapWithIndex((sections, index) =>
        <TileComponent
          key={string_of_int(index)}
          heading={sections.heading}
          subHeading={sections.subHeading}
          redirect={sections.redirect->Option.getOr("")}
          isComingSoon={sections.isComingSoon->Option.getOr(false)}
          buttonText={sections.buttonText->Option.getOr("Add Details")}
          redirectUrl={sections.redirectUrl}
          isApiCall={sections.isApiCall->Option.getOr(false)}
          cardName={sections.cardName}
        />
      )
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  <>
    <PageUtils.PageHeading
      title="Account Settings"
      subTitle="Manage payment account configuration and dashboard settings"
    />
    <PersonalSettings />
  </>
}
