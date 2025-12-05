open ThemeTypes
open Typography
module RadioButtons = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
    open HeadlessUI
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let entities = [
      {
        label: "Organization",
        value: "organization",
        icon: <Icon name="organization-entity" size=20 />,
        desc: "Change themes to all merchants and profiles",
      },
      {
        label: "Merchant",
        value: "merchant",
        icon: <Icon name="merchant-entity" size=20 />,
        desc: "Change themes to specific merchant and its profiles",
      },
      {
        label: "Profile",
        value: "profile",
        icon: <Icon name="profile-entity" size=20 />,
        desc: "Change themes to specific profile only",
      },
    ]
    let value = input.value->LogicUtils.getStringFromJson("")

    <RadioGroup
      name="theme-create"
      value={value}
      onChange={val => input.onChange(val->Identity.stringToFormReactEvent)}>
      <div className="flex flex-col gap-4">
        <div
          className="flex flex-row gap-2 items-start flex-1 border border-yellow-500 bg-yellow-50 p-4 rounded-lg">
          <Icon name="nd-info-circle" size=20 />
          <span className={`text-nd_gray-600 ${body.md.regular}`}>
            {`You can only create theme for ${orgId} here. To create theme to another organisation, please switch the organisation.`->React.string}
          </span>
        </div>
        {entities
        ->Array.map(option =>
          <RadioGroup.Option \"as"="div" key=option.value value=option.value>
            {checked =>
              <div
                className={"flex items-center justify-between border rounded-lg p-4 cursor-pointer transition " ++ (
                  checked["checked"] ? "border-primary" : "border-gray-200 bg-white"
                )}>
                <div className="flex items-center gap-4 w-full">
                  <div>
                    <div
                      className="w-8 h-8 border border-nd_br_gray-50 flex items-center justify-center rounded-md">
                      {option.icon}
                    </div>
                  </div>
                  <div className="flex flex-col flex-1">
                    <span className={`text-nd_gray-600 ${body.md.semibold}`}>
                      {option.label->React.string}
                    </span>
                    <span className={`text-nd_gray-400 ${body.md.medium}`}>
                      {option.desc->React.string}
                    </span>
                  </div>
                  <div>
                    <input type_="radio" checked={checked["checked"]} className="accent-primary" />
                  </div>
                </div>
              </div>}
          </RadioGroup.Option>
        )
        ->React.array}
      </div>
    </RadioGroup>
  }
}

module LineageFormContent = {
  @react.component
  let make = (~showModal=false, ~setShowModal, ~step, ~setStep) => {
    open LogicUtils
    open SessionStorage
    open UserUtils
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let {userInfo: {merchantId, profileId, themeId}} = React.useContext(
      UserInfoProvider.defaultContext,
    )

    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()
    let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
    let formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let orgName = getNameForId(#Organization)
    Js.log2("orgName", orgName)
    let (themeExists, setThemeExists) = React.useState(() => false)
    let (updateThemeID, setUpdateThemeID) = React.useState(() => themeId)
    let entityType =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("lineage")
      ->getString("entity_type", "")

    React.useEffect(() => {
      if entityType->isNonEmptyString {
        sessionStorage.setItem("entity_type", entityType)
      }
      None
    }, [entityType])

    let checkThemeExists = async (~entityType) => {
      try {
        let url = getURL(
          ~entityName=V1(USERS),
          ~methodType=Get,
          ~userType=#THEME_BY_LINEAGE,
          ~queryParameters=Some(`entity_type=${entityType}`),
        )
        let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
        let themeID = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("theme_id", "")
        setUpdateThemeID(_ => themeID)
        setThemeExists(_ => true)
      } catch {
      | _ => setThemeExists(_ => false)
      }
    }

    React.useEffect(() => {
      let checkTheme = async () => {
        switch step {
        | 1 =>
          let _ = await checkThemeExists(~entityType="merchant")
        | 2 =>
          let _ = await checkThemeExists(~entityType="profile")
        | _ => ()
        }
      }
      let _ = checkTheme()
      None
    }, [step])

    let onMerchantSelect = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      let merchantValue = event->Identity.formReactEventToString
      if merchantValue !== merchantId {
        try {
          let merchantData = merchantList->Array.find(m => m.id == merchantValue)
          switch merchantData {
          | Some(merchant) => {
              let version = merchant.version->Option.getOr(UserInfoTypes.V1)
              let productType = merchant.productType->Option.getOr(Orchestration(V1))
              let _ = await internalSwitch(~expectedMerchantId=Some(merchantValue), ~version)
              setActiveProductValue(productType)
            }
          | None => {
              let _ = await internalSwitch(~expectedMerchantId=Some(merchantValue))
            }
          }
          input.onChange(event)
        } catch {
        | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
        }
      }
    }

    let onProfileSelect = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      let profileValue = event->Identity.formReactEventToString
      if profileValue !== profileId {
        try {
          let _ = await internalSwitch(~expectedProfileId=Some(profileValue))
          input.onChange(event)
        } catch {
        | _ => showToast(~message="Failed to switch profile", ~toastType=ToastError)
        }
      }
    }

    let entityTypeField = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="lineage.entity_type",
      ~customInput=(~input, ~placeholder as _) => <RadioButtons input />,
    )

    let orgDisplayField = FormRenderer.makeFieldInfo(
      ~label="Current Organisation",
      ~name="display.organization_name",
      ~customInput=(~input as _, ~placeholder as _) =>
        <div
          className="w-full border border-gray-200 bg-gray-50 rounded-lg px-3 py-2 flex items-center">
          <span className="text-nd_gray-600 font-medium">
            {getNameForId(#Organization)->React.string}
          </span>
        </div>,
    )
    let merchantField = FormRenderer.makeFieldInfo(
      ~label="Select Merchant",
      ~name="lineage.merchant_id",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.selectInput(
          ~options=getMerchantSelectBoxOption(
            ~label="All merchants",
            ~value="all_merchants",
            ~dropdownList=merchantList,
          ),
          ~buttonText=`${getNameForId(#Merchant)}- ${merchantId}`,
          ~deselectDisable=true,
          ~fullLength=true,
        )(
          ~input={
            ...input,
            onChange: {
              event => {
                onMerchantSelect(event, input)->ignore
              }
            },
          },
          ~placeholder="Select a merchant",
        ),
    )

    let profileField = FormRenderer.makeFieldInfo(
      ~label="Select Profile",
      ~name="lineage.profile_id",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.selectInput(
          ~options=getMerchantSelectBoxOption(
            ~label="All profiles",
            ~value="all_profiles",
            ~dropdownList=profileList,
          ),
          ~buttonText=`${getNameForId(#Profile)}- ${profileId}`,
          ~deselectDisable=true,
          ~fullLength=true,
        )(
          ~input={
            ...input,
            onChange: event => {onProfileSelect(event, input)->ignore},
          },
          ~placeholder="Select a profile",
        ),
    )

    let renderStep = _values => {
      switch step {
      | 0 =>
        <FormRenderer.FieldRenderer
          field={entityTypeField}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
          labelClass="!text-black font-medium !-ml-[0.5px]"
        />
      | 1 =>
        <>
          <FormRenderer.FieldRenderer
            field={orgDisplayField}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass="!text-black font-medium"
          />
          <div className="relative pl-8">
            <div
              className="absolute left-4 top-0 bottom-0 h-[50px] w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-4 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={merchantField}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass="!text-black font-medium"
            />
          </div>
        </>
      | 2 =>
        <>
          <FormRenderer.FieldRenderer
            field={orgDisplayField}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass="!text-black font-medium"
          />
          <div className="relative pl-8">
            <div
              className="absolute left-4 top-0 bottom-0 h-[50px] w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-4 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={merchantField}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass="!text-black font-medium"
            />
          </div>
          <div className="relative pl-16">
            <div
              className="absolute left-12 top-0 bottom-0 h-[50px] w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-12 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={profileField}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass="!text-black font-medium"
            />
          </div>
        </>
      | _ => React.null
      }
    }
    let handleNext = () => {
      sessionStorage.removeItem("themeLineageModal")
      sessionStorage.removeItem("themeModalStep")
      if themeExists {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/theme/${updateThemeID}`))
      } else {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/theme/new"))
      }
    }
    let onNext = (values: JSON.t) => {
      let entityType =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("lineage")
        ->getString("entity_type", "")
      switch step {
      | 0 =>
        switch entityType->entityTypeToLevel {
        | ORGANIZATION => handleNext()
        | MERCHANT => setStep(_ => 1)
        | PROFILE => setStep(_ => 2)
        | _ => ()
        }
      | 1 => handleNext()
      | 2 => handleNext()
      | _ => ()
      }
    }

    let values = formState.values

    let handleCancel = () => {
      setShowModal(_ => false)
      setStep(_ => 0)
    }
    <>
      <div className="flex flex-col h-full w-full p-4 gap-2 ">
        {renderStep(values)}
        <RenderIf condition={themeExists}>
          <div
            className="flex flex-row gap-2 items-center flex-1 border border-yellow-500 bg-yellow-50 p-2 rounded-lg">
            <Icon name="nd-info-circle" size=14 className="text-nd_gray-500" />
            <span className={`text-nd_gray-600 ${body.sm.regular}`}>
              {"A theme already exists for this lineage entity level. Continue to override."->React.string}
            </span>
          </div>
        </RenderIf>
        <div className="flex justify-end gap-4 mt-4">
          <Button
            text="Cancel"
            buttonType=Secondary
            onClick={_ => handleCancel()}
            buttonSize=Small
            buttonState=Normal
          />
          <Button
            text={"Next"}
            buttonType=Primary
            buttonSize=Small
            buttonState=Normal
            onClick={_ => onNext(values)}
          />
        </div>
      </div>
      <FormValuesSpy />
    </>
  }
}
module ThemeLineageModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    open SessionStorage
    let sessionStepValue =
      sessionStorage.getItem("themeModalStep")->Nullable.toOption->Option.getOr("0")
    let (step, setStep) = React.useState(() => sessionStepValue->Int.fromString->Option.getOr(0))
    React.useEffect(() => {
      SessionStorage.sessionStorage.setItem("themeModalStep", step->Int.toString)
      None
    }, [step])
    React.useEffect(() => {
      sessionStorage.setItem("themeLineageModal", showModal ? "true" : "false")
      None
    }, [showModal])

    let handleModalClose = _ => {
      setShowModal(_ => false)
      setStep(_ => 0)
    }

    let onSubmit = async (values, _) => {
      try {
        switch values->JSON.Decode.object {
        | Some(dict) => Js.log2("dict", dict)
        | None => Js.log("No values submitted")
        }
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
      Nullable.null
    }

    <Form key="theme-create" onSubmit>
      <Modal
        showModal
        closeOnOutsideClick=false
        setShowModal
        modalHeading="Create Theme"
        modalHeadingClass={`${heading.sm.semibold}`}
        modalClass="w-1/2 m-auto"
        childClass="p-0"
        onCloseClickCustomFun=handleModalClose
        modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
          {"Select the level you want to create theme."->React.string}
        </div>}>
        <LineageFormContent showModal setShowModal step setStep />
      </Modal>
    </Form>
  }
}

module OverlappingCircles = {
  @react.component
  let make = (~colorA: string, ~colorB: string) => {
    <div className="relative w-9 h-6 flex items-center">
      <div
        className="absolute left-0 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md"
        style={ReactDOM.Style.make(~backgroundColor=colorA, ())}
      />
      <div
        className="absolute left-4 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md"
        style={ReactDOM.Style.make(~backgroundColor=colorB, ())}
      />
    </div>
  }
}

module CreateNewThemeButton = {
  @react.component
  let make = () => {
    open SessionStorage
    open LogicUtils

    let sessionModalValue =
      sessionStorage.getItem("themeLineageModal")
      ->Nullable.toOption
      ->Option.getOr("")
      ->getBoolFromString(false)
    let (showModal, setShowModal) = React.useState(_ => sessionModalValue)
    <>
      <Button
        text="Create Theme"
        buttonType=Primary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
        onClick={_ => {
          setShowModal(_ => true)
        }}
      />
      <ThemeLineageModal showModal setShowModal />
    </>
  }
}
module ThemeUploadAssetsModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~themeID, ~redirectToList) => {
    open APIUtils
    open LogicUtils
    let showToast = ToastState.useShowToast()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Loading)
    let fetchDetails = useGetMethod()
    let iconFileInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
      <MultipleFileUpload
        input
        fileType=".png,.jpg,.jpeg"
        allowMultiFileSelect=false
        showUploadtoast=false
        widthClass="w-full"
        heightClass="h-20"
      />
    }

    let faviconFileInput = (~input: ReactFinalForm.fieldRenderPropsInput, ~placeholder as _) => {
      <MultipleFileUpload
        input
        fileType=".ico,.png"
        allowMultiFileSelect=false
        showUploadtoast=false
        widthClass="w-full"
        heightClass="h-20"
      />
    }

    let iconField = FormRenderer.makeFieldInfo(
      ~label="Icon",
      ~name="icon",
      ~customInput=iconFileInput,
      ~isRequired=true,
    )

    let faviconField = FormRenderer.makeFieldInfo(
      ~label="Favicon",
      ~name="favicon",
      ~customInput=faviconFileInput,
      ~isRequired=true,
    )

    let uploadAsset = async (~assetFile, ~assetName) => {
      let formData = FormDataUtils.formData()
      FormDataUtils.append(formData, "asset_name", assetName)
      FormDataUtils.append(formData, "asset_data", assetFile)
      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Post,
        ~id=Some(themeID),
        ~userType=#THEME_UPLOAD_ASSET,
      )
      await updateDetails(
        ~bodyFormData=formData,
        ~headers=Dict.make(),
        url,
        Dict.make()->JSON.Encode.object,
        Post,
        ~contentType=AuthHooks.Unknown,
      )
    }
    let getThemeByThemeId = async () => {
      try {
        let url = getURL(
          ~entityName=V1(USERS),
          ~methodType=Get,
          ~id=Some(`${themeID}`),
          ~userType=#THEME,
        )
        let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
        res
      } catch {
      | _ => JSON.Encode.null
      }
    }
    let updateThemeWithAssetUrls = async (~iconName, ~faviconName) => {
      let currentThemeData = await getThemeByThemeId()
      let baseUrl = GlobalVars.getHostUrl
      let iconUrl = `${baseUrl}/themes/${themeID}/${iconName}`
      let faviconUrl = `${baseUrl}/themes/${themeID}/${faviconName}`

      let currentThemeDict = currentThemeData->getDictFromJsonObject
      let currentThemeDataDict = currentThemeDict->getDictfromDict("theme_data")

      let updatedUrls = Dict.make()
      updatedUrls->Dict.set("logoUrl", iconUrl->JSON.Encode.string)
      updatedUrls->Dict.set("faviconUrl", faviconUrl->JSON.Encode.string)

      currentThemeDataDict->Dict.set("urls", updatedUrls->JSON.Encode.object)
      currentThemeDict->Dict.set("theme_data", currentThemeDataDict->JSON.Encode.object)

      let updateUrl = getURL(
        ~entityName=V1(USERS),
        ~methodType=Put,
        ~id=Some(themeID),
        ~userType=#THEME,
      )
      await updateDetails(updateUrl, currentThemeDict->JSON.Encode.object, Put)
    }

    let onSubmit = async (values, _) => {
      try {
        setScreenState(_ => Loading)

        let valuesDict = values->getDictFromJsonObject
        let iconFiles = valuesDict->getArrayFromDict("icon", [])
        let faviconFiles = valuesDict->getArrayFromDict("favicon", [])

        if iconFiles->Array.length > 0 && faviconFiles->Array.length > 0 {
          let iconFile = iconFiles->Array.get(0)->Option.getOr(JSON.Encode.null)
          let faviconFile = faviconFiles->Array.get(0)->Option.getOr(JSON.Encode.null)

          if iconFile !== JSON.Encode.null && faviconFile !== JSON.Encode.null {
            let iconName = "logo.png"
            let faviconName = "favicon.png"

            let _ = await uploadAsset(~assetFile=iconFile, ~assetName=iconName)
            let _ = await uploadAsset(~assetFile=faviconFile, ~assetName=faviconName)

            let _ = await updateThemeWithAssetUrls(~iconName, ~faviconName)

            showToast(
              ~message="Theme has been created with assets",
              ~toastType=ToastState.ToastSuccess,
            )
            setShowModal(_ => false)
            redirectToList()
          } else {
            showToast(
              ~message="Please select valid files for both icon and favicon",
              ~toastType=ToastState.ToastError,
            )
          }
        } else {
          showToast(
            ~message="Please upload both icon and favicon files",
            ~toastType=ToastState.ToastError,
          )
        }

        setScreenState(_ => Success)
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to upload assets!")
        showToast(~message=err, ~toastType=ToastState.ToastError)
        setScreenState(_ => Error("Failed to Upload theme assets."))
      }
      Nullable.null
    }

    let handleCancel = () => {
      setShowModal(_ => false)
      showToast(
        ~message="Theme has been created. You can upload assets later",
        ~toastType=ToastState.ToastInfo,
      )
      redirectToList()
    }

    <Form key="theme-upload-assets" onSubmit>
      <Modal
        showModal
        closeOnOutsideClick=false
        setShowModal
        modalHeading="Upload Assets"
        modalHeadingClass={`${heading.sm.semibold}`}
        modalClass="w-1/2 m-auto"
        childClass="p-0"
        modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
          {"Upload icon and favicon files for your theme."->React.string}
        </div>}>
        <div className="p-6 space-y-6">
          <div className="space-y-4">
            <FormRenderer.FieldRenderer
              field=iconField labelClass={`${body.md.medium} text-gray-700`}
            />
            <div className={`${body.sm.regular} text-gray-500`}>
              {"Supported formats: PNG, JPG, JPEG. Recommended size: 32x32px"->React.string}
            </div>
          </div>
          <div className="space-y-4">
            <FormRenderer.FieldRenderer
              field=faviconField labelClass={`${body.md.medium} text-gray-700`}
            />
            <div className={`${body.sm.regular} text-gray-500`}>
              {"Supported formats: ICO, PNG. Recommended size: 16x16px or 32x32px"->React.string}
            </div>
          </div>
          <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
            <Button
              text="Cancel"
              buttonType=Secondary
              buttonState=Normal
              buttonSize=Small
              onClick={_ => handleCancel()}
              customButtonStyle={`${body.md.semibold} py-2 px-4`}
            />
            <FormRenderer.SubmitButton
              text="Save & Upload"
              buttonType=Primary
              loadingText="Uploading..."
              buttonSize=Small
              customSumbitButtonStyle={`${body.md.semibold} py-2 px-4`}
            />
          </div>
        </div>
      </Modal>
    </Form>
  }
}
