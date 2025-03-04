module MetadataAuthenticationInput = {
  @react.component
  let make = (~index, ~allowEdit, ~isDisabled) => {
    open LogicUtils
    open FormRenderer
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let (key, setKey) = React.useState(_ => "")
    let (metaValue, setValue) = React.useState(_ => "")
    let getMetadatKeyValues = () => {
      let metadataKeyValueDict =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
      let key = metadataKeyValueDict->Dict.keysToArray->LogicUtils.getValueFromArray(index, "")
      let customMetadataVal = metadataKeyValueDict->getOptionString(key)
      switch customMetadataVal {
      | Some(value) => (key, value)
      | _ => ("", "")
      }
    }

    React.useEffect(() => {
      let (metadataKey, customMetadataVal) = getMetadatKeyValues()
      setValue(_ => customMetadataVal)
      setKey(_ => metadataKey)
      None
    }, [])

    React.useEffect(() => {
      if allowEdit {
        setValue(_ => "")
      }
      None
    }, [allowEdit])
    let form = ReactFinalForm.useForm()
    let keyInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => (),
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        let regexForProfileName = "^([a-z]|[A-Z]|[0-9]|_|-)+$"
        let isValid = if value->String.length <= 2 {
          true
        } else if (
          value->isEmptyString ||
          value->String.length > 64 ||
          !RegExp.test(RegExp.fromString(regexForProfileName), value)
        ) {
          false
        } else {
          true
        }
        if value->String.length <= 0 {
          let name = `metadata.${key}`
          form.change(name, JSON.Encode.null)
        }
        switch (value->getOptionIntFromString->Option.isNone, isValid) {
        | (true, true) => setKey(_ => value)
        | _ => ()
        }
      },
      onFocus: _ => (),
      value: key->JSON.Encode.string,
      checked: true,
    }
    let valueInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => {
        if key->String.length > 0 {
          let name = `metadata.${key}`
          form.change(name, metaValue->JSON.Encode.string)
        }
      },
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        setValue(_ => value)
      },
      onFocus: _ => (),
      value: metaValue->JSON.Encode.string,
      checked: true,
    }

    <DesktopRow wrapperClass="flex-1">
      <div className="mt-5">
        <TextInput
          input={keyInput} placeholder={"Enter key"} isDisabled={isDisabled && !allowEdit}
        />
      </div>
      <div className="mt-5">
        <TextInput
          input={valueInput} placeholder={"Enter value"} isDisabled={isDisabled && !allowEdit}
        />
      </div>
    </DesktopRow>
  }
}
module MetadataHeaders = {
  @react.component
  let make = (~setAllowEdit, ~allowEdit) => {
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let metadataKeyValueDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
    let (showModal, setShowModal) = React.useState(_ => false)
    let (isDisabled, setDisabled) = React.useState(_ => true)

    let allowEditConfiguration = () => {
      form.change(`metadata`, JSON.Encode.null)
      setAllowEdit(_ => true)
      setShowModal(_ => false)
    }
    React.useEffect(() => {
      let isEmpty = metadataKeyValueDict->LogicUtils.isEmptyDict
      setDisabled(_ => !isEmpty)
      setAllowEdit(_ => isEmpty)
      None
    }, [])
    <div className="flex-1">
      <div className="flex flex-row items-center gap-4 ">
        <p
          className={`ml-4 text-xl dark:text-jp-gray-text_darktheme dark:text-opacity-50 !text-grey-700 font-semibold `}>
          {"Custom Metadata Headers"->React.string}
        </p>
        <RenderIf
          condition={!(metadataKeyValueDict->LogicUtils.isEmptyDict) && isDisabled && !allowEdit}>
          <Button
            text=""
            customButtonStyle="bg-none !border-none cursor-pointer !p-0"
            customBackColor="bg-transparent"
            rightIcon={FontAwesome("edit")}
            customIconSize={18}
            buttonSize=Small
            onClick={_ => setShowModal(_ => true)}
          />
        </RenderIf>
      </div>
      <div className="grid grid-cols-5 gap-2">
        {Array.fromInitializer(~length=2, i => i)
        ->Array.mapWithIndex((_, index) =>
          <div key={index->Int.toString} className="col-span-4">
            <MetadataAuthenticationInput index={index} allowEdit isDisabled />
          </div>
        )
        ->React.array}
      </div>
      <Modal
        showModal
        setShowModal
        modalClass="w-full md:w-4/12 mx-auto my-40 border-t-8 border-t-orange-960 rounded-xl">
        <div className="relative flex items-start px-4 pb-10 pt-8 gap-4">
          <Icon
            name="warning-outlined" size=25 className="w-8" onClick={_ => setShowModal(_ => false)}
          />
          <div className="flex flex-col gap-5">
            <p className="font-bold text-2xl"> {"Edit the Current Configuration"->React.string} </p>
            <p className=" text-hyperswitch_black opacity-50 font-medium">
              {"Editing the current configuration will override the current active configuration."->React.string}
            </p>
          </div>
          <Icon
            className="absolute top-2 right-2"
            name="hswitch-close"
            size=22
            onClick={_ => setShowModal(_ => false)}
          />
        </div>
        <div className="flex items-end justify-end gap-4">
          <Button
            buttonType=Button.Primary onClick={_ => allowEditConfiguration()} text="Proceed"
          />
          <Button
            buttonType=Button.Secondary onClick={_ => setShowModal(_ => false)} text="Cancel"
          />
        </div>
      </Modal>
    </div>
  }
}

@react.component
let make = (~busiProfieDetails, ~setBusiProfie, ~setScreenState, ~profileId="") => {
  open APIUtils
  open LogicUtils
  open FormRenderer
  open MerchantAccountUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let id = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, profileId)
  let showToast = ToastState.useShowToast()
  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()
  let (allowEdit, setAllowEdit) = React.useState(_ => false)
  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(id))
      let body = valuesDict->JSON.Encode.object->getMetdataKeyValuePayload->JSON.Encode.object
      let res = await updateDetails(url, body, Post)
      setBusiProfie(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
      setAllowEdit(_ => false)
      fetchBusinessProfiles()->ignore
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }
  <ReactFinalForm.Form
    key="auth"
    initialValues={busiProfieDetails->parseBussinessProfileJson->JSON.Encode.object}
    subscription=ReactFinalForm.subscribeToValues
    onSubmit
    render={({handleSubmit}) => {
      <form onSubmit={handleSubmit} className="flex flex-col gap-8 h-full w-full py-6 px-4">
        <MetadataHeaders setAllowEdit allowEdit />
        <DesktopRow>
          <div className="flex justify-end w-full gap-2">
            <SubmitButton
              text="Update"
              buttonType=Button.Primary
              buttonSize=Button.Medium
              disabledParamter={!allowEdit}
            />
            <Button
              buttonType=Button.Secondary
              onClick={_ =>
                RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/payment-settings"))}
              text="Cancel"
            />
          </div>
        </DesktopRow>
        // <FormValuesSpy />
      </form>
    }}
  />
}
