module OverlappingCircles = {
  @react.component
  let make = (~colorA: string, ~colorB: string) => {
    <div className="relative w-9 h-6 flex items-center">
      <div
        className={`absolute left-0 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md `}
        style={ReactDOM.Style.make(~backgroundColor=colorA, ())}
      />
      <div
        className={`absolute left-4 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md `}
        style={ReactDOM.Style.make(~backgroundColor=colorB, ())}
      />
    </div>
  }
}

open ThemeTypes
open Typography
module RadioButtons = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
    open HeadlessUI
    let {orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
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
      value={value}
      onChange={val => {
        input.onChange(val->Identity.stringToFormReactEvent)
      }}>
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
  let make = (~showModal=false, ~setShowModal, ~step, ~setStep, ~themeExists, ~setThemeExists) => {
    open UserUtils

    let {merchantId, profileId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getResolvedUserInfo()

    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()
    let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)

    let (showLoaderSwitchModal, setShowLoaderSwitchModal) = React.useState(_ => false)

    let onMerchantSelect = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      let merchantValue = event->Identity.formReactEventToString
      if merchantValue !== merchantId {
        try {
          setShowLoaderSwitchModal(_ => true)
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
          setShowLoaderSwitchModal(_ => false)
        } catch {
        | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
        }
      }
    }

    let onProfileSelect = async (event, input: ReactFinalForm.fieldRenderPropsInput) => {
      let profileValue = event->Identity.formReactEventToString
      if profileValue !== profileId {
        try {
          setShowLoaderSwitchModal(_ => true)
          let _ = await internalSwitch(~expectedProfileId=Some(profileValue))
          setShowLoaderSwitchModal(_ => false)
          input.onChange(event)
        } catch {
        | _ => showToast(~message="Failed to switch profile", ~toastType=ToastError)
        }
      }
    }

    let entityTypeField = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="lineage.entity_type",
      ~customInput=(~input, ~placeholder as _) => {
        <RadioButtons input />
      },
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

    let renderStep = () => {
      switch step {
      | 0 =>
        <FormRenderer.FieldRenderer
          field={entityTypeField}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
          labelClass="!text-black font-medium !-ml-[0.5px]"
        />
      | 1 =>
        <FormRenderer.FieldRenderer
          field={orgDisplayField}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
          labelClass="!text-black font-medium"
        />
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
        </>
      | 3 =>
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

    let handleCancel = () => {
      setShowModal(_ => false)
      setThemeExists(_ => false)
      setStep(_ => 0)
    }

    <>
      <div className="flex flex-col h-full w-full p-4 gap-2 ">
        {renderStep()}
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
          <FormRenderer.SubmitButton text={"Next"} buttonType=Primary buttonSize=Small />
        </div>
      </div>
      <LoaderModal
        showModal={showLoaderSwitchModal} setShowModal={setShowLoaderSwitchModal} text="Switching"
      />
    </>
  }
}
module ThemeLineageModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    open SessionStorage
    open LogicUtils
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let sessionStepValue =
      sessionStorage.getItem("themeModalStep")->Nullable.toOption->Option.getOr("0")
    let (step, setStep) = React.useState(() => sessionStepValue->Int.fromString->Option.getOr(0))
    let {themeId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
    let {orgId, merchantId, profileId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getCommonSessionDetails()

    let (themeExists, setThemeExists) = React.useState(() => false)
    let (updateThemeID, setUpdateThemeID) = React.useState(() => themeId)

    let entityType = sessionStorage.getItem("entity_type")->Nullable.toOption->Option.getOr("")

    let lineageInitialValues =
      [
        (
          "lineage",
          [
            ("entity_type", entityType->JSON.Encode.string),
            ("org_id", orgId->JSON.Encode.string),
            ("merchant_id", merchantId->JSON.Encode.string),
            ("profile_id", profileId->JSON.Encode.string),
          ]->getJsonFromArrayOfJson,
        ),
      ]->getJsonFromArrayOfJson

    let validateLineageForm = values => {
      let errors = Dict.make()
      let valuesDict = values->getDictFromJsonObject
      let lineageDict = valuesDict->getDictfromDict("lineage")
      let entityType = lineageDict->getString("entity_type", "")

      if entityType->isEmptyString {
        Dict.set(errors, "lineage.entity_type", "Please select an entity type"->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }
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

    let handleNext = () => {
      sessionStorage.removeItem("themeLineageModal")
      sessionStorage.removeItem("themeModalStep")

      if themeExists {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/theme/${updateThemeID}`))
      } else {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/theme/new"))
      }
    }

    let handleModalClose = _ => {
      setShowModal(_ => false)
      setThemeExists(_ => false)
      sessionStorage.removeItem("entity_type")
      sessionStorage.removeItem("themeModalStep")
      setStep(_ => 0)
    }

    let onSubmit = async (values, _) => {
      let entityType =
        values
        ->getDictFromJsonObject
        ->getDictfromDict("lineage")
        ->getString("entity_type", "")

      if entityType->isNonEmptyString {
        sessionStorage.setItem("entity_type", entityType)
      }

      switch step {
      | 0 =>
        switch entityType->UserInfoUtils.entityMapper {
        | #Organization => {
            sessionStorage.setItem("themeModalStep", "1")
            let _ = await checkThemeExists(~entityType="organization")
            setStep(_ => 1)
          }
        | #Merchant => {
            sessionStorage.setItem("themeModalStep", "2")
            let _ = await checkThemeExists(~entityType="merchant")
            setStep(_ => 2)
          }
        | #Profile => {
            sessionStorage.setItem("themeModalStep", "3")
            let _ = await checkThemeExists(~entityType="profile")
            setStep(_ => 3)
          }
        | _ => ()
        }
      | 1 => handleNext()
      | 2 => handleNext()
      | 3 => handleNext()
      | _ => ()
      }
      Nullable.null
    }

    React.useEffect(() => {
      let savedEntityType = sessionStorage.getItem("entity_type")->Nullable.toOption
      let savedStep = sessionStorage.getItem("themeModalStep")->Nullable.toOption

      switch (savedEntityType, savedStep, entityType->isNonEmptyString) {
      | (Some(_), Some(stepStr), true) =>
        setShowModal(_ => true)
        let stepNum = stepStr->Int.fromString->Option.getOr(0)

        setStep(_ => stepNum)

        if stepNum !== 0 {
          let checkEntityType = switch stepNum {
          | 1 => "organization"
          | 2 => "merchant"
          | 3 => "profile"
          | _ => ""
          }
          if checkEntityType->isNonEmptyString {
            checkThemeExists(~entityType=checkEntityType)->ignore
          }
        }

      | _ => ()
      }
      None
    }, [])

    <Form
      key="theme-create"
      validate={validateLineageForm}
      onSubmit
      initialValues={lineageInitialValues}>
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
        <LineageFormContent showModal setShowModal step setStep themeExists setThemeExists />
      </Modal>
    </Form>
  }
}

module ThemeUploadAssetsModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~themeId, ~redirectToList, ~isUpdateFlow=false) => {
    open APIUtils
    open LogicUtils
    let showToast = ToastState.useShowToast()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Success)
    let fetchDetails = useGetMethod()
    let (selectedIcon, setSelectedIcon) = React.useState(_ => None)
    let (selectedFavicon, setSelectedFavicon) = React.useState(_ => None)
    let {getThemesJson} = React.useContext(ThemeProvider.themeContext)

    let {getUserInfo} = OMPSwitchHooks.useUserInfo()
    let {setApplicationState} = React.useContext(UserInfoProvider.defaultContext)
    let form = ReactFinalForm.useForm()
    let handleIconChange = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(file) => setSelectedIcon(_ => Some(file))
      | None => ()
      }
    }

    let handleFaviconChange = ev => {
      let files = ReactEvent.Form.target(ev)["files"]
      switch files[0] {
      | Some(file) => setSelectedFavicon(_ => Some(file))
      | None => ()
      }
    }

    let uploadAsset = async (~assetFile, ~assetName) => {
      let formData = FormDataUtils.formData()
      FormDataUtils.append(formData, "asset_name", assetName)
      FormDataUtils.append(formData, "asset_data", assetFile)
      let url = getURL(
        ~entityName=V1(USERS),
        ~methodType=Post,
        ~id=Some(themeId),
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
          ~id=Some(`${themeId}`),
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
      let iconUrl = `https://app.hyperswitch.io/themes/${themeId}/${iconName}`
      let faviconUrl = `https://app.hyperswitch.io/themes/${themeId}/${faviconName}`

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
        ~id=Some(themeId),
        ~userType=#THEME,
      )
      await updateDetails(updateUrl, currentThemeDict->JSON.Encode.object, Put)
    }

    let handleUpload = async (~isUpdateFlow=false) => {
      // switch (selectedIcon, selectedFavicon) {
      // | (Some(iconFile), Some(faviconFile)) =>
      try {
        setScreenState(_ => Loading)
        let iconName = "logo.png"
        let faviconName = "favicon.png"
        if selectedIcon->Option.isSome {
          let _ = await uploadAsset(~assetFile=selectedIcon, ~assetName=iconName)
        }
        if selectedFavicon->Option.isSome {
          let _ = await uploadAsset(~assetFile=selectedFavicon, ~assetName=faviconName)
        }
        if isUpdateFlow {
          form.change(
            "urls.logoUrl",
            `https://app.hyperswitch.io/themes/${themeId}/${iconName}`->Identity.genericTypeToJson,
          )
          form.change(
            "urls.faviconUrl",
            `https://app.hyperswitch.io/themes/${themeId}/${faviconName}`->Identity.genericTypeToJson,
          )
        }

        if !isUpdateFlow {
          let _ = await updateThemeWithAssetUrls(~iconName, ~faviconName)
          // let res = await getUserInfo()
          // let {themeId: themeIdFromUserInfo} = res
          // setApplicationState(_ => DashboardSession(res))
          // let _ = await getThemesJson(~themesID=Some(themeIdFromUserInfo))
        }

        showToast(~message="Theme has been created with assets", ~toastType=ToastState.ToastSuccess)
        setScreenState(_ => Success)
        setShowModal(_ => false)
        redirectToList()
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to upload assets!")
        showToast(~message=err, ~toastType=ToastState.ToastError)
        setScreenState(_ => Success)
      }
      // | _ =>
      //   showToast(
      //     ~message="Please upload both icon and favicon files",
      //     ~toastType=ToastState.ToastError,
      //   )
      // }
    }

    let handleCancel = async () => {
      // let {themeId: themeIdFromUserInfo} = await getUserInfo()
      // let _ = await getThemesJson(~themesID=Some(themeId))
      setShowModal(_ => false)
      showToast(
        ~message="Theme has been created. You can upload assets later",
        ~toastType=ToastState.ToastInfo,
      )
      redirectToList()
    }

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
      <div className="p-2">
        <div className="flex flex-col gap-4 p-4">
          <div className="flex justify-between gap-4">
            <div className={`flex ${body.md.medium} text-gray-700 gap-2 items-center`}>
              {"Icon"->React.string}
              <ToolTip
                toolTipFor={<Icon name="info-vacent" size=13 className="cursor-pointer" />}
                description="Supported formats: PNG, JPG, JPEG. Recommended size: 32x32px"
                toolTipPosition=Right
              />
            </div>
            <input
              type_="file"
              accept=".png,.jpg,.jpeg"
              hidden=true
              onChange={handleIconChange}
              id="iconInput"
            />
            <label
              htmlFor="iconInput"
              className="flex items-center justify-center gap-2 rounded-md border border-gray-300 cursor-pointer hover:border-gray-400 p-4 ">
              <Icon name="nd-upload-file" />
            </label>
            {switch selectedIcon {
            | Some(file) =>
              <div className="mt-2 flex items-center gap-2 text-sm text-gray-600">
                <Icon name="file-icon" size=16 />
                <span> {file["name"]->React.string} </span>
              </div>
            | None => React.null
            }}
          </div>
        </div>
        <div className="flex flex-col gap-4 p-4">
          <div className="flex justify-between gap-4">
            <div className={`flex ${body.md.medium} text-gray-700 gap-2 items-center`}>
              {"Favicon"->React.string}
              <ToolTip
                toolTipFor={<Icon name="info-vacent" size=13 className="cursor-pointer" />}
                description="Supported formats: ICO, PNG. Recommended size: 16x16px or 32x32px"
                toolTipPosition=Right
              />
            </div>
            <input
              type_="file"
              accept=".png,.jpg,.jpeg"
              hidden=true
              onChange={handleFaviconChange}
              id="faviconInput"
            />
            <label
              htmlFor="faviconInput"
              className="flex items-center justify-center gap-2 rounded-md border border-gray-300 cursor-pointer hover:border-gray-400 p-4">
              <Icon name="nd-upload-file" />
            </label>
            {switch selectedFavicon {
            | Some(file) =>
              <div className="mt-2 flex items-center gap-2 text-sm text-gray-600">
                <Icon name="file-icon" size=16 />
                <span> {file["name"]->React.string} </span>
              </div>
            | None => React.null
            }}
          </div>
        </div>
        <div className="flex justify-end gap-3 pt-4 border-t border-gray-200">
          <Button
            text="Skip for now"
            buttonType=Secondary
            buttonState=Normal
            buttonSize=Small
            onClick={_ => handleCancel()->ignore}
            customButtonStyle={`${body.md.semibold} py-2 px-4`}
          />
          <Button
            text="Save & Upload"
            buttonType=Primary
            buttonState={screenState == Loading ? Loading : Normal}
            buttonSize=Small
            onClick={_ => handleUpload()->ignore}
            customButtonStyle={`${body.md.semibold} py-2 px-4`}
          />
        </div>
      </div>
    </Modal>
  }
}
