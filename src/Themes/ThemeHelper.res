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
open ThemeFeatureUtils

module RadioButtons = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
    open HeadlessUI
    let {orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let value = input.value->LogicUtils.getStringFromJson("")

    <RadioGroup
      value={value}
      onChange={val => {
        input.onChange(val->Identity.stringToFormReactEvent)
      }}>
      <div className="flex flex-col gap-4">
        <div
          className="flex flex-row gap-2 items-start flex-1 border border-nd_yellow-500 bg-nd_yellow-50 p-4 rounded-lg">
          <Icon name="nd-info-circle" size=20 />
          <span className={`text-nd_gray-600 ${body.md.regular}`}>
            {`You can only create theme for ${orgId} here. To create theme to another organisation, please switch the organisation.`->React.string}
          </span>
        </div>
        {entities
        ->Array.map(option =>
          <RadioGroup.Option \"as"="div" key=option.value value=option.value>
            {checked => {
              let borderClass = checked["checked"] ? "border-primary" : "border-nd_gray-200"
              <div
                className={`flex items-center justify-between border rounded-lg p-4 cursor-pointer transition ${borderClass}`}>
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
              </div>
            }}
          </RadioGroup.Option>
        )
        ->React.array}
      </div>
    </RadioGroup>
  }
}

let entityTypeField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="lineage.entity_type",
  ~customInput=(~input, ~placeholder as _) => {
    <RadioButtons input />
  },
)

let orgDisplayField = (~getNameForId) =>
  FormRenderer.makeFieldInfo(
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

let merchantField = (~getNameForId, ~merchantList, ~merchantId, ~onMerchantSelect) =>
  FormRenderer.makeFieldInfo(~label="Select Merchant", ~name="lineage.merchant_id", ~customInput=(
    ~input,
    ~placeholder as _,
  ) =>
    InputFields.selectInput(
      ~options=UserUtils.getMerchantSelectBoxOption(
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
    )
  )

let profileField = (~getNameForId, ~profileList, ~profileId, ~onProfileSelect) =>
  FormRenderer.makeFieldInfo(~label="Select Profile", ~name="lineage.profile_id", ~customInput=(
    ~input,
    ~placeholder as _,
  ) =>
    InputFields.selectInput(
      ~options=UserUtils.getMerchantSelectBoxOption(
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
    )
  )

module LineageFormContent = {
  @react.component
  let make = (
    ~showModal=false,
    ~setShowModal,
    ~step: ThemeTypes.lineageSelectionSteps,
    ~setStep,
    ~themeExists,
    ~setThemeExists,
  ) => {
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

    let renderStep = () => {
      switch step {
      | EntitySelection =>
        <FormRenderer.FieldRenderer
          field={entityTypeField}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
        />
      | OrgView =>
        <FormRenderer.FieldRenderer
          field={orgDisplayField(~getNameForId)}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
          labelClass={`${body.sm.semibold} `}
        />
      | MerchantLevelConfig =>
        <>
          <FormRenderer.FieldRenderer
            field={orgDisplayField(~getNameForId)}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass={`${body.sm.semibold}`}
          />
          <div className="relative pl-8">
            <div
              className="absolute left-4 top-0 bottom-0 h-50-px w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-4 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={merchantField(~getNameForId, ~merchantList, ~merchantId, ~onMerchantSelect)}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass={`${body.sm.semibold} `}
            />
          </div>
        </>
      | ProfileLevelConfig =>
        <>
          <FormRenderer.FieldRenderer
            field={orgDisplayField(~getNameForId)}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass={`${body.sm.semibold} `}
          />
          <div className="relative pl-8">
            <div
              className="absolute left-4 top-0 bottom-0 h-50-px w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-4 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={merchantField(~getNameForId, ~merchantList, ~merchantId, ~onMerchantSelect)}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass={`${body.sm.semibold} `}
            />
          </div>
          <div className="relative pl-16">
            <div
              className="absolute left-12 top-0 bottom-0 h-50-px w-px border-l-2 border-dashed border-gray-300"
            />
            <div
              className="absolute left-12 top-12 w-4 h-px border-t-2 border-dashed border-gray-300"
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full"
              field={profileField(~getNameForId, ~profileList, ~profileId, ~onProfileSelect)}
              showErrorOnChange=true
              errorClass={ProdVerifyModalUtils.errorClass}
              labelClass={`${body.sm.semibold} `}
            />
          </div>
        </>
      }
    }

    let handleCancel = () => {
      setShowModal(_ => false)
      setThemeExists(_ => false)
      setStep(_ => EntitySelection)
    }

    <>
      <div className="flex flex-col h-full w-full p-4 gap-2 ">
        {renderStep()}
        <RenderIf condition={themeExists}>
          <div
            className="flex flex-row gap-2 items-center flex-1 border border-nd_yellow-500 bg-nd_yellow-50 p-2 rounded-lg">
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
      sessionStorage.getItem("themeModalStep")
      ->getOptionalFromNullable
      ->Option.getOr("entityselection")
    let (step, setStep) = React.useState(() => sessionStepValue->getStepVariantfromString)
    let {themeId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
    let showToast = ToastState.useShowToast()
    let {orgId, merchantId, profileId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getCommonSessionDetails()

    let (themeExists, setThemeExists) = React.useState(() => false)

    let entityType =
      sessionStorage.getItem("entity_type")->getOptionalFromNullable->Option.getOr("")

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
        let _ = await fetchDetails(url, ~version=UserInfoTypes.V1)
        setThemeExists(_ => true)
      } catch {
      | _ => setThemeExists(_ => false)
      }
    }

    let handleNext = () => {
      sessionStorage.removeItem("themeLineageModal")
      sessionStorage.removeItem("themeModalStep")

      if themeExists {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/theme/${themeId}`))
      } else {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/theme/new"))
      }
    }

    let handleModalClose = _ => {
      setShowModal(_ => false)
      setThemeExists(_ => false)
      sessionStorage.removeItem("entity_type")
      sessionStorage.removeItem("themeModalStep")
      setStep(_ => EntitySelection)
    }

    let onSubmit = async (values, _) => {
      try {
        let entityType =
          values
          ->getDictFromJsonObject
          ->getDictfromDict("lineage")
          ->getString("entity_type", "")

        if entityType->isNonEmptyString {
          sessionStorage.setItem("entity_type", entityType)
        }

        switch step {
        | EntitySelection =>
          switch entityType->UserInfoUtils.entityMapper {
          | #Organization => {
              sessionStorage.setItem("themeModalStep", "orgview")
              let _ = await checkThemeExists(~entityType="organization")
              setStep(_ => OrgView)
            }
          | #Merchant => {
              sessionStorage.setItem("themeModalStep", "merchantlevelconfig")
              let _ = await checkThemeExists(~entityType="merchant")
              setStep(_ => MerchantLevelConfig)
            }
          | #Profile => {
              sessionStorage.setItem("themeModalStep", "profilelevelconfig")
              let _ = await checkThemeExists(~entityType="profile")
              setStep(_ => ProfileLevelConfig)
            }
          | _ => ()
          }
        | OrgView
        | MerchantLevelConfig
        | ProfileLevelConfig =>
          handleNext()
        }
      } catch {
      | _ => showToast(~message="Something went wrong. Please try again.", ~toastType=ToastError)
      }
      Nullable.null
    }

    React.useEffect(() => {
      let savedEntityType = sessionStorage.getItem("entity_type")->Nullable.toOption
      let savedStep = sessionStorage.getItem("themeModalStep")->Nullable.toOption

      switch (savedEntityType, savedStep, entityType->isNonEmptyString) {
      | (Some(_), Some(stepStr), true) =>
        setShowModal(_ => true)
        let stepVariant = stepStr->getStepVariantfromString

        setStep(_ => stepVariant)

        if stepVariant !== EntitySelection {
          let checkEntityType = getEntityTypeFromStep(stepVariant)
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
