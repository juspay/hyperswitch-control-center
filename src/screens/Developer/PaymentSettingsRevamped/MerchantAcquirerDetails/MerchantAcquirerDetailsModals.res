open LogicUtils
open APIUtilsTypes
open MerchantAcquirerDetailsTypes
open MerchantAcquirerDetailsUtils
open Typography
open APIUtils

module AddAcquirerModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    open FormRenderer
    let showToast = ToastState.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let requiredKeys = ["merchant_name", "acquirer_assigned_merchant_id", "network", "acquirer_bin"]

    let onSubmit = async (values, _) => {
      try {
        let body =
          values->getDictFromJsonObject->normalizeNumericStringFields->stampProfileId(~profileId)
        let url = getURL(~entityName=V1(ACQUIRER_CONFIG_SETTINGS), ~methodType=Post)
        let _ = await updateDetails(url, body->JSON.Encode.object, Post)
        showToast(~message="Acquirer created", ~toastType=ToastState.ToastSuccess)
        setShowModal(_ => false)
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      } catch {
      | _ => showToast(~message="Failed to create acquirer", ~toastType=ToastState.ToastError)
      }
      Nullable.null
    }

    <Modal
      showModal
      setShowModal
      closeOnOutsideClick=true
      modalHeading="Add Acquirer Configuration"
      modalClass="flex flex-col justify-start h-screen w-[420px] float-right overflow-hidden !bg-white"
      childClass="">
      <Form
        onSubmit
        initialValues={JSON.Encode.null}
        validate={values => validateForm(~requiredKeys, values)}
        formClass="flex flex-col gap-4 p-6">
        <FieldRenderer field=merchantNameField />
        <FieldRenderer field=merchantIdField />
        <hr className="my-2 border-nd_gray-200" />
        <FieldRenderer field={networkField(~options=AcquirerConfigUtils.networkDropDownOptions)} />
        <FieldRenderer field=binField />
        <FieldRenderer field=icaField />
        <FieldRenderer field=fraudRateField />
        <FieldRenderer field=countryField />
        <div className="flex justify-end gap-2 pt-4 border-t border-nd_gray-200 mt-4">
          <Button
            buttonType=Button.Secondary text="Cancel" onClick={_ => setShowModal(_ => false)}
          />
          <SubmitButton text="Save" buttonType=Button.Primary />
        </div>
      </Form>
    </Modal>
  }
}

module AddNetworkModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~bucket: acquirerBucket) => {
    open FormRenderer
    let showToast = ToastState.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

    let usedNetworks = bucket.networks->Array.map(n => n.network)
    let availableNetworks =
      AcquirerConfigUtils.networkDropDownOptions->Array.filter(opt =>
        !(usedNetworks->Array.includes(opt.value))
      )
    let allNetworksUsed = availableNetworks->Array.length === 0
    let requiredKeys = ["network", "acquirer_bin"]

    let onSubmit = async (values, _) => {
      try {
        let body = values->getDictFromJsonObject->normalizeNumericStringFields
        let url = getURL(
          ~entityName=V1(ACQUIRER_CONFIG_SETTINGS),
          ~methodType=Post,
          ~id=Some(bucket.id),
        )
        let _ = await updateDetails(url, body->JSON.Encode.object, Post)
        showToast(~message="Network added", ~toastType=ToastState.ToastSuccess)
        setShowModal(_ => false)
        let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      } catch {
      | _ => showToast(~message="Failed to add network", ~toastType=ToastState.ToastError)
      }
      Nullable.null
    }

    <Modal
      showModal
      setShowModal
      closeOnOutsideClick=true
      modalHeading="Add Network Configuration"
      modalHeadingDescription={`Acquirer: ${bucket.merchant_name} - ID: ${bucket.id}`}
      modalClass="flex flex-col justify-start h-screen w-[420px] float-right overflow-hidden !bg-white"
      childClass="">
      <RenderIf condition={allNetworksUsed}>
        <div className="p-6 flex flex-col gap-4">
          <div className={`${body.md.regular} text-nd_gray-500`}>
            {"All supported networks are already configured for this acquirer."->React.string}
          </div>
          <div className="flex justify-end">
            <Button
              buttonType=Button.Secondary text="Close" onClick={_ => setShowModal(_ => false)}
            />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={!allNetworksUsed}>
        <Form
          onSubmit
          initialValues={JSON.Encode.null}
          validate={values => validateForm(~requiredKeys, values)}
          formClass="flex flex-col gap-4 p-6">
          <FieldRenderer field={networkField(~options=availableNetworks)} />
          <FieldRenderer field=binField />
          <FieldRenderer field=icaField />
          <FieldRenderer field=fraudRateField />
          <FieldRenderer field=countryField />
          <div className="flex justify-end gap-2 pt-4 border-t border-nd_gray-200 mt-4">
            <Button
              buttonType=Button.Secondary text="Cancel" onClick={_ => setShowModal(_ => false)}
            />
            <SubmitButton text="Save" buttonType=Button.Primary />
          </div>
        </Form>
      </RenderIf>
    </Modal>
  }
}

module EditNetworkModal = {
  let requiredKeys = ["network", "acquirer_bin"]

  @react.component
  let make = (
    ~entry: option<BusinessProfileInterfaceTypes.acquirerNetworkEntry>,
    ~bucket: acquirerBucket,
    ~setEntry,
  ) => {
    open FormRenderer
    let showToast = ToastState.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

    switch entry {
    | None => React.null
    | Some(n) =>
      let setShowModal: (bool => bool) => unit = _ => setEntry(_ => None)
      let lockedNetworkOptions: array<SelectBox.dropdownOption> = [
        {value: n.network, label: n.network},
      ]
      let initialValues = {
        let initialValuesDict = Dict.make()
        initialValuesDict->Dict.set("network", n.network->JSON.Encode.string)
        initialValuesDict->Dict.set("acquirer_bin", n.acquirer_bin->JSON.Encode.string)
        n.acquirer_ica->Option.forEach(s =>
          initialValuesDict->Dict.set("acquirer_ica", s->JSON.Encode.string)
        )
        n.acquirer_fraud_rate->Option.forEach(f =>
          initialValuesDict->Dict.set("acquirer_fraud_rate", f->JSON.Encode.float)
        )
        n.acquirer_country_code->Option.forEach(c =>
          initialValuesDict->Dict.set("acquirer_country_code", c->JSON.Encode.string)
        )
        initialValuesDict->JSON.Encode.object
      }

      let onSubmit = async (values, _) => {
        try {
          let body = values->getDictFromJsonObject->normalizeNumericStringFields
          body->Dict.set("network", n.network->JSON.Encode.string)
          let url = getURL(
            ~entityName=V1(ACQUIRER_CONFIG_SETTINGS),
            ~methodType=Post,
            ~id=Some(bucket.id),
          )
          let _ = await updateDetails(url, body->JSON.Encode.object, Post)
          showToast(~message="Network updated", ~toastType=ToastState.ToastSuccess)
          setEntry(_ => None)
          let _ = await fetchBusinessProfileFromId(~profileId=Some(profileId))
        } catch {
        | _ => showToast(~message="Failed to update network", ~toastType=ToastState.ToastError)
        }
        Nullable.null
      }

      let lockedNetworkField = makeFieldInfo(
        ~label="Card Network",
        ~name="network",
        ~placeholder=n.network,
        ~customInput=InputFields.selectInput(
          ~options=lockedNetworkOptions,
          ~buttonText=n.network,
          ~deselectDisable=true,
        ),
        ~disabled=true,
      )

      <Modal
        showModal=true
        setShowModal
        closeOnOutsideClick=true
        modalHeading="Edit Network Configuration"
        modalHeadingDescription={`Editing ${n.network} entry`}
        modalClass="flex flex-col justify-start h-screen w-[420px] float-right overflow-hidden !bg-white"
        childClass="">
        <Form
          onSubmit
          initialValues
          validate={values => validateForm(~requiredKeys, values)}
          formClass="flex flex-col gap-4 p-6">
          <FieldRenderer field=lockedNetworkField />
          <FieldRenderer field=binField />
          <FieldRenderer field=icaField />
          <FieldRenderer field=fraudRateField />
          <FieldRenderer field=countryField />
          <div className="flex justify-end gap-2 pt-4 border-t border-nd_gray-200 mt-4">
            <Button buttonType=Button.Secondary text="Cancel" onClick={_ => setEntry(_ => None)} />
            <SubmitButton text="Update" buttonType=Button.Primary />
          </div>
        </Form>
      </Modal>
    }
  }
}
