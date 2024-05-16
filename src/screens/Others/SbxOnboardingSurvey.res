module OtherfieldRender = {
  @react.component
  let make = (~field_name) => {
    open LogicUtils
    let valueField = ReactFinalForm.useField(field_name).input
    let textField = ReactFinalForm.useField(`${field_name}_otherstring`).input

    let textInput: ReactFinalForm.fieldRenderPropsInput = {
      name: `${field_name}_otherstring`,
      onBlur: _ev => {
        let textFieldValue = textField.value->getStringFromJson("")
        let valueFieldValue = valueField.value->getArrayFromJson([])->getStrArrayFromJsonArray
        if textFieldValue->isNonEmptyString {
          valueFieldValue->Array.push(textFieldValue)
        }
        valueField.onChange(valueFieldValue->Identity.anyTypeToReactEvent)
      },
      onChange: ev => {
        let target = ReactEvent.Form.target(ev)
        let value = target["value"]
        textField.onChange(value->Identity.anyTypeToReactEvent)
      },
      onFocus: _ev => (),
      value: textField.value,
      checked: false,
    }

    <div className="flex gap-2 items-center">
      <CheckBoxIcon
        key={`${field_name}_otherstring`}
        isSelected={textField.value->getStringFromJson("")->isNonEmptyString}
      />
      <TextInput placeholder={"Others"} input=textInput />
    </div>
  }
}

@react.component
let make = (~showModal, ~setShowModal) => {
  open APIUtils
  open LogicUtils
  open OnboardingSurveyModalUtils
  open CommonAuthHooks
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let {merchant_id: merchantId, email: userEmail} =
    useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState
  let fetchSwitchMerchantList = SwitchMerchantListHook.useFetchSwitchMerchantList()

  let getMerchantNameFromJson = values =>
    values->getDictFromJsonObject->getString("merchant_name", "")

  let updateUserName = async values => {
    try {
      let userName = values->getDictFromJsonObject->getString("user_name", "")
      let url = getURL(~entityName=USERS, ~userType=#USER_UPDATE, ~methodType=Post, ())
      let body = values->constructUserUpdateBody
      let _ = await updateDetails(url, body, Post, ())
      HSwitchUtils.setUserDetails("name", userName->JSON.Encode.string)
    } catch {
    | _ => {
        showToast(~message=`Failed to update onboarding survey`, ~toastType=ToastError, ())
        setShowModal(_ => true)
      }
    }
  }

  let updateOnboardingSurveyDetails = async values => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#USER_DATA, ~methodType=Post, ())
      let bodyValues = values->constructOnboardingSurveyBody->JSON.Encode.object
      let body = [("OnboardingSurvey", bodyValues)]->getJsonFromArrayOfJson
      let _ = await updateDetails(url, body, Post, ())
    } catch {
    | _ => {
        showToast(~message=`Failed to update onboarding survey`, ~toastType=ToastError, ())
        setShowModal(_ => true)
      }
    }
  }

  let udpateMerchantDetails = async values => {
    try {
      let accountUrl = getURL(
        ~entityName=MERCHANT_ACCOUNT,
        ~methodType=Post,
        ~id=Some(merchantId),
        (),
      )
      let body =
        [
          ("merchant_id", merchantId->JSON.Encode.string),
          ("merchant_name", values->getMerchantNameFromJson->JSON.Encode.string),
        ]->getJsonFromArrayOfJson
      let merchantDetails = await updateDetails(accountUrl, body, Post, ())
      let _ = fetchSwitchMerchantList()
      setMerchantDetailsValue(._ =>
        merchantDetails->MerchantAccountDetailsMapper.getMerchantDetails
      )
    } catch {
    | _ => {
        showToast(~message=`Failed to update onboarding survey`, ~toastType=ToastError, ())
        setShowModal(_ => true)
      }
    }
  }

  let onSubmit = async (values, _) => {
    try {
      let _ = values->udpateMerchantDetails
      let _ = values->updateOnboardingSurveyDetails
      let _ = values->updateUserName
      showToast(~message=`Successfully updated onboarding survey`, ~toastType=ToastSuccess, ())
      setShowModal(_ => false)
    } catch {
    | _ => {
        showToast(~message=`Please try again!`, ~toastType=ToastError, ())
        setShowModal(_ => true)
      }
    }
    Nullable.null
  }

  let validateForm = values => {
    let errors = Dict.make()
    let valueDict = values->getDictFromJsonObject
    let dictKeys = valueDict->Dict.keysToArray
    let hyperswitchDict = valueDict->getDictfromDict("hyperswitch")

    if dictKeys->Array.length === 0 || hyperswitchDict->Dict.keysToArray->Array.length == 0 {
      Dict.set(errors, "Required", "Please fill the details"->JSON.Encode.string)
    } else if valueDict->getString("merchant_name", "")->isEmptyString {
      Dict.set(errors, "Required", "Business name required"->JSON.Encode.string)
    } else if valueDict->getString("user_name", "")->isEmptyString {
      Dict.set(errors, "Required", "User name required"->JSON.Encode.string)
    } else {
      keysToValidateForHyperswitch->Array.forEach(key => {
        switch hyperswitchDict->getJsonObjectFromDict(key)->JSON.Classify.classify {
        | String(strValue) =>
          if strValue->isEmptyString {
            Dict.set(errors, key, "Required"->JSON.Encode.string)
          }
        | Array(arrayValue) =>
          if arrayValue->Array.length === 0 {
            Dict.set(errors, key, "Required"->JSON.Encode.string)
          }
        | _ => Dict.set(errors, key, "Required"->JSON.Encode.string)
        }
      })
    }
    errors->JSON.Encode.object
  }

  <Modal
    showModal
    paddingClass=""
    modalHeading="Welcome aboard! Let's get started"
    setShowModal
    showCloseIcon=false
    modalHeadingDescription=userEmail
    modalClass="!w-1/3 !min-w-1/3 !bg-white m-auto dark:!bg-jp-gray-lightgray_background">
    <Form
      key="merchant_name-validation"
      initialValues={Dict.make()->JSON.Encode.object}
      onSubmit
      validate=validateForm>
      <div className="flex flex-col gap-4 h-full w-full ">
        <div className="!max-h-96 !overflow-y-scroll flex flex-col gap-4 h-full">
          <Accordion
            initialExpandedArray=[0]
            accordion={[
              {
                title: "User details ",
                renderContent: () => {
                  <div>
                    <FormRenderer.DesktopRow>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-full"
                        field={userName}
                        labelClass="!text-black font-medium !-ml-[0.5px]"
                      />
                    </FormRenderer.DesktopRow>
                    <FormRenderer.DesktopRow>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-full"
                        field={designation}
                        labelClass="!text-black font-medium !-ml-[0.5px]"
                      />
                    </FormRenderer.DesktopRow>
                  </div>
                },
                renderContentOnTop: None,
              },
              {
                title: "Business details ",
                renderContent: () => {
                  <div>
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={businessName}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={businessWebsite}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={aboutBusiness}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={majorMarkets}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={businessSize}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
              {
                title: "Hyperswitch details ",
                renderContent: () => {
                  <div>
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={hyperswitchUsage}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <div>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-full"
                        field={hyperswitchFeatures}
                        labelClass="!text-black font-medium !-ml-[0.5px]"
                      />
                      <OtherfieldRender field_name="hyperswitch.required_features" />
                    </div>
                    <div>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-full"
                        field={processorRequired}
                        labelClass="!text-black font-medium !-ml-[0.5px]"
                      />
                      <OtherfieldRender field_name="hyperswitch.required_processors" />
                    </div>
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={plannedGoLiveDate}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={miscellaneousTextField}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
            accordianTopContainerCss="rounded-md"
            contentExpandCss="p-4"
            gapClass="flex flex-col gap-4"
            titleStyle="font-semibold text-bold text-md"
          />
        </div>
        <div className="flex justify-end w-full pr-5 pb-3">
          <FormRenderer.SubmitButton text="Start Exploring" buttonSize={Small} />
        </div>
        <FormValuesSpy />
      </div>
    </Form>
  </Modal>
}
