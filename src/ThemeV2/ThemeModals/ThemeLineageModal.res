open ThemeModalTypes
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
    open ThemeV2Types
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let {userInfo: {merchantId, profileId, themeId}} = React.useContext(
      UserInfoProvider.defaultContext,
    )
    let (_, getNameForId) = OMPSwitchHooks.useOMPData()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
    let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
    let formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
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
          ~entityName=V1(THEME_BY_LINEAGE),
          ~methodType=Get,
          ~queryParamerters=Some(`entity_type=${entityType}`),
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
        <FormRenderer.FieldRenderer
          fieldWrapperClass="w-full"
          field={merchantField}
          showErrorOnChange=true
          errorClass={ProdVerifyModalUtils.errorClass}
          labelClass="!text-black font-medium"
        />
      | 2 =>
        <>
          <FormRenderer.FieldRenderer
            fieldWrapperClass="w-full"
            field={merchantField}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass="!text-black font-medium"
          />
          <FormRenderer.FieldRenderer
            fieldWrapperClass="w-full"
            field={profileField}
            showErrorOnChange=true
            errorClass={ProdVerifyModalUtils.errorClass}
            labelClass="!text-black font-medium"
          />
        </>
      | _ => React.null
      }
    }
    let handleNext = () => {
      sessionStorage.removeItem("themeLineageModal")
      sessionStorage.removeItem("themeModalStep")
      if themeExists {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`/themev2/${updateThemeID}`))
      } else {
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/themev2/new"))
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
      <div className="flex flex-col h-full w-full p-4 gap-4">
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
    </>
  }
}

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
      modalClass="w-1/3 m-auto"
      childClass="p-0"
      onCloseClickCustomFun=handleModalClose
      modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
        {"Select the level you want to create theme."->React.string}
      </div>}>
      <LineageFormContent showModal setShowModal step setStep />
    </Modal>
  </Form>
}
