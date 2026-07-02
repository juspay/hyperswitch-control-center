open LogicUtils
open APIUtilsTypes
open MerchantAcquirerDetailsTypes
open MerchantAcquirerDetailsUtils
open Typography
open APIUtils

let acquirerIdHeading = (~bucket: acquirerBucket) =>
  <div className="flex items-center gap-2 mt-2">
    <div className="flex items-center h-6 px-2.5 rounded-md border border-nd_br_gray-150 gap-1">
      <span className={`${body.md.medium} text-nd_gray-500`}> {"Acquirer: "->React.string} </span>
      <span className={`${body.md.medium} text-nd_gray-950`}>
        {bucket.merchant_name->React.string}
      </span>
    </div>
    <div className="w-px h-4 bg-nd_gray-200" />
    <div className="flex items-center text-nd_gray-500 gap-1">
      <span className={`${body.md.medium}`}> {"ID: "->React.string} </span>
      <span className={`${body.md.medium}`}> {bucket.id->React.string} </span>
    </div>
  </div>

module AddAcquirerModal = {
  @react.component
  let make = (~showModal, ~setShowModal) => {
    open FormRenderer
    let showToast = ToastAdapter.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let requiredKeys: array<acquirerField> = [
      MerchantName,
      AcquirerAssignedMerchantId,
      Network,
      AcquirerBin,
    ]

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
      modalClass="flex flex-col justify-start h-screen w-420-px float-right overflow-hidden !bg-white"
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
    let showToast = ToastAdapter.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()

    let usedNetworks = bucket.networks->Array.map(n => n.network)
    let availableNetworks =
      AcquirerConfigUtils.networkDropDownOptions->Array.filter(opt =>
        !(usedNetworks->Array.includes(opt.value))
      )
    let allNetworksUsed = availableNetworks->isEmptyArray
    let requiredKeys: array<acquirerField> = [Network, AcquirerBin]

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
      modalHeadingDescriptionElement={acquirerIdHeading(~bucket)}
      modalClass="flex flex-col justify-start h-screen w-420-px float-right overflow-hidden !bg-white"
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
  @react.component
  let make = (
    ~entry: option<BusinessProfileInterfaceTypes.acquirerNetworkEntry>,
    ~bucket: acquirerBucket,
    ~setEntry,
  ) => {
    open FormRenderer
    let showToast = ToastAdapter.useShowToast()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let setShowModal: (bool => bool) => unit = _ => setEntry(_ => None)
    let networkEntry = entry->Option.getOr({
      network: "",
      acquirer_bin: "",
      acquirer_ica: None,
      acquirer_fraud_rate: None,
      acquirer_country_code: None,
      acquirer_assigned_merchant_id: None,
      merchant_name: None,
    })

    let lockedNetworkOptions: array<SelectBox.dropdownOption> = [
      {value: networkEntry.network, label: networkEntry.network},
    ]
    let initialValues = {
      let initialValuesDict = Dict.make()
      initialValuesDict->Dict.set("network", networkEntry.network->JSON.Encode.string)
      initialValuesDict->Dict.set("acquirer_bin", networkEntry.acquirer_bin->JSON.Encode.string)
      initialValuesDict->setOptionString("acquirer_ica", networkEntry.acquirer_ica)
      initialValuesDict->setOptionFloat("acquirer_fraud_rate", networkEntry.acquirer_fraud_rate)
      initialValuesDict->setOptionString(
        "acquirer_country_code",
        networkEntry.acquirer_country_code,
      )
      initialValuesDict->JSON.Encode.object
    }
    let requiredKeys: array<acquirerField> = [Network, AcquirerBin]
    let onSubmit = async (values, _) => {
      try {
        let body = values->getDictFromJsonObject->normalizeNumericStringFields
        body->Dict.set("network", networkEntry.network->JSON.Encode.string)
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
      ~placeholder=networkEntry.network,
      ~customInput=InputFields.selectInput(
        ~options=lockedNetworkOptions,
        ~buttonText=networkEntry.network,
        ~deselectDisable=true,
        ~disableSelect=true,
      ),
      ~disabled=true,
    )
    <Modal
      showModal=true
      setShowModal
      closeOnOutsideClick=true
      modalHeading="Edit Network Configuration"
      modalHeadingDescriptionElement={acquirerIdHeading(~bucket)}
      modalClass="flex flex-col justify-start h-screen w-420-px float-right overflow-hidden !bg-white"
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
