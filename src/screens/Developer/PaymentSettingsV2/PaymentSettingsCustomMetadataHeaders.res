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
    let originalKeyRef = React.useRef("")
    let getMetadatKeyValues = () => {
      let metadataKeyValueDict =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("metadata")
      let key = metadataKeyValueDict->Dict.keysToArray->getValueFromArray(index, "")
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
      originalKeyRef.current = metadataKey
      None
    }, [])

    let form = ReactFinalForm.useForm()
    let keyInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ => {
        if (
          key->isNonEmptyString &&
          originalKeyRef.current->isNonEmptyString &&
          originalKeyRef.current !== key
        ) {
          let oldName = `metadata.${originalKeyRef.current}`
          form.change(oldName, JSON.Encode.null)
          let newName = `metadata.${key}`
          form.change(newName, metaValue->JSON.Encode.string)
          originalKeyRef.current = key
        }
      },
      onChange: ev => {
        let value = ReactEvent.Form.target(ev)["value"]
        let regexForProfileName = "^[a-zA-Z0-9_\\-!#$%&'*+.^`|~]+$"
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
          let name = `metadata.${originalKeyRef.current}`
          form.change(name, JSON.Encode.null)
        }
        //Not allow users to enter just integers
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
        if key->isNonEmptyString {
          if originalKeyRef.current->isNonEmptyString && originalKeyRef.current !== key {
            let oldName = `metadata.${originalKeyRef.current}`
            form.change(oldName, JSON.Encode.null)
          }
          let name = `metadata.${key}`
          form.change(name, metaValue->JSON.Encode.string)
          originalKeyRef.current = key
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
          input={keyInput}
          placeholder={"Enter key"}
          isDisabled={isDisabled && !allowEdit}
          customStyle="rounded-xl"
        />
      </div>
      <div className="mt-5">
        <TextInput
          input={valueInput}
          placeholder={"Enter value"}
          isDisabled={isDisabled && !allowEdit}
          customStyle="rounded-xl"
        />
      </div>
    </DesktopRow>
  }
}
module MetadataHeaders = {
  @react.component
  let make = (~setAllowEdit, ~allowEdit) => {
    open LogicUtils
    open Typography

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let metadataKeyValueDict =
      formState.values
      ->getDictFromJsonObject
      ->getDictfromDict("metadata")
    let (showModal, setShowModal) = React.useState(_ => false)
    let (isDisabled, setDisabled) = React.useState(_ => true)

    let allowEditConfiguration = () => {
      setAllowEdit(_ => true)
      setShowModal(_ => false)
    }
    React.useEffect(() => {
      let isEmpty = metadataKeyValueDict->isEmptyDict
      setDisabled(_ => !isEmpty)
      setAllowEdit(_ => isEmpty)
      None
    }, [])

    <div className="flex-1">
      <div className="flex flex-row justify-between items-center gap-4 ">
        <p
          className={`ml-1 ${body.lg.semibold} dark:text-jp-gray-text_darktheme dark:text-opacity-50 !text-nd_gray-700 mt-6 `}>
          {"Custom Metadata Headers"->React.string}
        </p>
        <RenderIf condition={!(metadataKeyValueDict->isEmptyDict) && isDisabled && !allowEdit}>
          <div
            className="flex gap-2 items-center cursor-pointer"
            onClick={_ => setShowModal(_ => true)}>
            <Icon name="nd-edit" size=14 />
            <a className="text-primary cursor-pointer"> {"Edit"->React.string} </a>
          </div>
        </RenderIf>
      </div>
      <div className="grid grid-cols-5 gap-2">
        {Array.fromInitializer(~length=2, i => i)
        ->Array.mapWithIndex((_, index) =>
          <div key={index->Int.toString} className="-ml-3 col-span-4">
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
            <p className={`${heading.lg.bold}`}>
              {"Edit the Current Configuration"->React.string}
            </p>
            <p className={`${body.md.medium} text-hyperswitch_black opacity-50`}>
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
let make = () => {
  open FormRenderer
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let showToast = ToastState.useShowToast()
  let (allowEdit, setAllowEdit) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let (initialValues, setInitialValues) = React.useState(_ =>
    businessProfileRecoilVal->Identity.genericTypeToJson
  )
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let onSubmit = async (values, _) => {
    open BusinessProfileInterface
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = await updateBusinessProfile(~body=values, ~shouldTransform=true)
      let updatedInitialValues = switch version {
      | V1 => mapJsonToCommonType(businessProfileInterfaceV1, response)->Identity.genericTypeToJson
      | V2 => mapJsonToCommonType(businessProfileInterfaceV2, response)->Identity.genericTypeToJson
      }

      setInitialValues(_ => updatedInitialValues)
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
      setAllowEdit(_ => false)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to updated`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }
  <PageLoaderWrapper screenState>
    <Form initialValues onSubmit>
      <MetadataHeaders setAllowEdit allowEdit />
      <DesktopRow>
        <div className="flex justify-end w-full gap-2">
          <SubmitButton
            text="Update"
            buttonType=Button.Primary
            buttonSize=Button.Medium
            disabledParamter={!allowEdit}
          />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
