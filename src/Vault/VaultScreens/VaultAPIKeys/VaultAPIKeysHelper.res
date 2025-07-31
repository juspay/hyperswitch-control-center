open VaultAPIKeysUtils
open VaultAPITypes
open Typography

module ErrorUI = {
  @react.component
  let make = (~text) => {
    <div className="flex p-5">
      <img className="w-12 h-12 my-auto border-gray-100" src={`/icons/warning.svg`} alt="warning" />
      <div className="text-jp-gray-900">
        <div
          className="font-bold ml-4 text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
          {React.string(`API ${text} Failed`)}
        </div>
        <div
          className="whitespace-pre-line flex flex-col gap-1 p-2 ml-4 text-fs-13 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
          {`Unable to ${text} a API key. Please try again later.`->React.string}
        </div>
      </div>
    </div>
  }
}

module SuccessUI = {
  @react.component
  let make = (~downloadFun, ~apiKey) => {
    <div>
      <div className="flex p-5">
        <Icon className="align-middle fill-blue-600 self-center" size=40 name="info-circle" />
        <div className="text-jp-gray-900 ml-4">
          <div
            className="font-bold text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
            {React.string("Download the API Key")}
          </div>
          <div className="bg-gray-100 p-3 m-2">
            <HelperComponents.CopyTextCustomComp
              displayValue={Some(apiKey)}
              copyValue={Some(apiKey)}
              customTextCss="break-all text-sm font-semibold text-jp-gray-800 text-opacity-75"
              customParentClass="flex items-center gap-5"
            />
          </div>
          <HSwitchUtils.AlertBanner
            bannerType=Info
            bannerContent={<p>
              {"Please note down the API key for your future use as you won't be able to view it later."->React.string}
            </p>}
          />
        </div>
      </div>
      <div className="flex justify-end gap-5 mt-5 mb-1 mr-1">
        <Button
          leftIcon={CustomIcon(<Icon name="download" size=17 className="ml-3 mr-2" />)}
          text="Download the key"
          onClick={_ => {
            downloadFun()
          }}
          buttonType={Primary}
          buttonSize={Small}
        />
      </div>
    </div>
  }
}

module ApiEditModal = {
  open HSwitchUtils
  open LogicUtils
  @react.component
  let make = (
    ~setShowModal,
    ~getAPIKeyDetails: unit => promise<unit>,
    ~initialValues,
    ~showModal,
    ~action=Create,
    ~keyId=?,
  ) => {
    let showToast = ToastState.useShowToast()
    let updateApiKey = APIKeysHooks.useUpdateApiKeyHook()
    let createApiKey = APIKeysHooks.useCreateApiKeyHook()
    let (apiKey, setApiKey) = React.useState(_ => "")
    let (showCustomDate, setShowCustomDate) = React.useState(_ => false)
    let (modalState, setModalState) = React.useState(_ => action)

    let setShowCustomDate = val => {
      setShowCustomDate(_ => val)
    }

    React.useEffect(() => {
      setShowCustomDate(false)
      setModalState(_ => action)
      None
    }, [showModal])

    let downloadKey = _ => {
      DownloadUtils.downloadOld(~fileName=`apiKey.txt`, ~content=apiKey)
    }

    let primaryBtnText = switch action {
    | Update => "Update"
    | _ => "Create"
    }

    let modalheader = switch action {
    | Update => "Update API Key"
    | _ => "Create API Key"
    }

    let onSubmit = async (values, _) => {
      try {
        let valuesDict = values->getDictFromJsonObject

        let body = Dict.make()
        let name = valuesDict->getString("name", "")->JSON.Encode.string
        let description = valuesDict->getString("description", "")->JSON.Encode.string
        let expirationDate = valuesDict->getString("expiration_date", "")

        Dict.set(body, "name", name)
        Dict.set(body, "description", description)

        let expiryValue = switch valuesDict
        ->getString("expiration", "")
        ->getRecordTypeFromString {
        | Custom => expirationDate
        | _ => Never->getStringFromRecordType
        }

        Dict.set(body, "expiration", expiryValue->JSON.Encode.string)

        setModalState(_ => Loading)

        let apiKeyId = switch action {
        | Update => Some(keyId->Option.getOr(""))
        | _ => None
        }

        let json = switch action {
        | Update => await updateApiKey(~payload=body->JSON.Encode.object, ~apiKeyId)
        | _ => await createApiKey(~payload=body->JSON.Encode.object)
        }
        let keyDict = json->getDictFromJsonObject

        setApiKey(_ => keyDict->getString("api_key", ""))
        switch action {
        | Update => setShowModal(_ => false)
        | _ => {
            Clipboard.writeText(keyDict->getString("api_key", ""))
            setModalState(_ => Success)
          }
        }

        let _ = getAPIKeyDetails()
      } catch {
      | Exn.Error(e) =>
        switch Exn.message(e) {
        | Some(_error) =>
          showToast(~message="Api Key Generation Failed", ~toastType=ToastState.ToastError)
        | None => ()
        }
        setModalState(_ => SettingApiModalError)
      }
      Nullable.null
    }

    let modalBody =
      <div>
        {switch modalState {
        | Loading => <Loader />
        | Update
        | Create =>
          <ReactFinalForm.Form
            key="API-key"
            initialValues={initialValues->JSON.Encode.object}
            subscription=ReactFinalForm.subscribeToPristine
            validate={values =>
              validateAPIKeyForm(values, ["name", "expiration", "description"], ~setShowCustomDate)}
            onSubmit
            render={({handleSubmit}) => {
              <LabelVisibilityContext showLabel=false>
                <form onSubmit={handleSubmit} className="flex flex-col gap-3 h-full w-full">
                  <FormRenderer.DesktopRow>
                    <TextFieldRow label={apiName.label} labelWidth="w-48" isRequired=false>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-96" field=apiName errorClass
                      />
                    </TextFieldRow>
                    <TextFieldRow label={apiDescription.label} labelWidth="w-48" isRequired=false>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-96" field=apiDescription errorClass
                      />
                    </TextFieldRow>
                    <TextFieldRow label={keyExpiry.label} labelWidth="w-48" isRequired=false>
                      <FormRenderer.FieldRenderer
                        fieldWrapperClass="w-96" field=keyExpiry errorClass
                      />
                    </TextFieldRow>
                    {if showCustomDate {
                      <TextFieldRow
                        label={keyExpiryCustomDate.label} labelWidth="w-48" isRequired=false>
                        <FormRenderer.FieldRenderer
                          fieldWrapperClass="w-96" field=keyExpiryCustomDate errorClass
                        />
                      </TextFieldRow>
                    } else {
                      React.null
                    }}
                  </FormRenderer.DesktopRow>
                  <FormRenderer.DesktopRow>
                    <div className="flex justify-end gap-5 mt-5 mb-1 -mr-2">
                      <Button
                        text="Cancel"
                        onClick={_ => setShowModal(_ => false)}
                        buttonType={Secondary}
                        buttonSize={Small}
                      />
                      <FormRenderer.SubmitButton text=primaryBtnText buttonSize={Small} />
                    </div>
                  </FormRenderer.DesktopRow>
                </form>
              </LabelVisibilityContext>
            }}
          />
        | SettingApiModalError => <ErrorUI text=primaryBtnText />
        | Success => <SuccessUI apiKey downloadFun=downloadKey />
        }}
      </div>

    <Modal
      showModal
      modalHeading={modalheader}
      setShowModal
      closeOnOutsideClick=true
      modalClass="w-full max-w-2xl m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

module ApiKeyAddBtn = {
  @react.component
  let make = (~getAPIKeyDetails) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let isMobileView = MatchMedia.useMobileChecker()
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let (showModal, setShowModal) = React.useState(_ => false)

    let initialValues = Dict.make()
    initialValues->Dict.set("expiration", Never->getStringFromRecordType->JSON.Encode.string)

    <>
      <ApiEditModal showModal setShowModal initialValues getAPIKeyDetails />
      <ACLButton
        text="Create New API Key"
        leftIcon={CustomIcon(
          <Icon
            name="plus" size=12 className="jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
          />,
        )}
        // TODO: Remove `MerchantDetailsManage` permission in future
        authorization={hasAnyGroupAccess(
          userHasAccess(~groupAccess=MerchantDetailsManage),
          userHasAccess(~groupAccess=AccountManage),
        )}
        buttonType=Secondary
        buttonSize={isMobileView ? XSmall : Small}
        customTextSize={isMobileView ? "text-xs" : ""}
        onClick={_ => {
          mixpanelEvent(~eventName="create_new_api_key")
          setShowModal(_ => true)
        }}
      />
    </>
  }
}

module TableActionsCell = {
  @react.component
  let make = (~keyId, ~getAPIKeyDetails: unit => promise<unit>, ~data: VaultAPITypes.apiKey) => {
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(_ => false)
    let showPopUp = PopUpState.useShowPopUp()
    let deleteApiKey = APIKeysHooks.useDeleteApiKeyHook()
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let showButtons = hasAnyGroupAccess(
      userHasAccess(~groupAccess=MerchantDetailsManage),
      userHasAccess(~groupAccess=AccountManage),
    )

    let deleteKey = async () => {
      try {
        let body = Dict.make()
        Dict.set(body, "key_id", keyId->JSON.Encode.string)
        Dict.set(body, "revoked", true->JSON.Encode.bool)

        let _ = await deleteApiKey(~payload=body->JSON.Encode.object, ~apiKeyId=keyId)
        getAPIKeyDetails()->ignore
      } catch {
      | Exn.Error(e) =>
        switch Exn.message(e) {
        | Some(_error) =>
          showToast(~message="Failed to delete API key", ~toastType=ToastState.ToastError)
        | None => ()
        }
      }
    }

    let openPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Delete API Key`,
        description: React.string(`Are you sure you want to DELETE the API Key?`),
        handleConfirm: {
          text: `Yes, delete it`,
          onClick: _ => {
            deleteKey()->ignore
          },
        },
        handleCancel: {text: `No, don't delete`, onClick: _ => ()},
      })
    }
    let initialValues = Dict.fromArray([
      ("name", data.name->JSON.Encode.string),
      ("description", data.description->JSON.Encode.string),
    ])

    if data.expiration == Never {
      initialValues->Dict.set("expiration", Never->getStringFromRecordType->JSON.Encode.string)
    } else {
      initialValues->Dict.set("expiration", Custom->getStringFromRecordType->JSON.Encode.string)
      initialValues->Dict.set("expiration_date", data.expiration_date->JSON.Encode.string)
    }

    <div>
      <ApiEditModal
        showModal setShowModal initialValues={initialValues} getAPIKeyDetails keyId action={Update}
      />
      <div className="invisible cursor-pointer group-hover:visible flex ">
        <ACLDiv
          showTooltip={showButtons == Access}
          authorization={showButtons}
          onClick={_ => {
            setShowModal(_ => true)
          }}>
          <Icon
            name="edit"
            size=14
            className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white mr-4 mb-1"
          />
        </ACLDiv>
        <ACLDiv
          authorization={showButtons}
          showTooltip={showButtons == Access}
          onClick={_ => {
            openPopUp()
          }}>
          <Icon
            name="delete"
            size=14
            className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white mr-3 mb-1"
          />
        </ACLDiv>
      </div>
    </div>
  }
}

module ApiKeysTable = {
  @react.component
  let make = () => {
    let fetchApiKeysHook = APIKeysHooks.useGetApiKeysHook()
    let (offset, setOffset) = React.useState(_ => 0)
    let (data, setData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAPIKeyDetails = async () => {
      try {
        let apiKeys = await fetchApiKeysHook()
        setData(_ => apiKeys->getItems)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(e) =>
        switch Exn.message(e) {
        | Some(msg) => setScreenState(_ => PageLoaderWrapper.Error(msg))
        | None => setScreenState(_ => PageLoaderWrapper.Error("Error"))
        }
      }
    }

    React.useEffect(() => {
      getAPIKeyDetails()->ignore
      None
    }, [])

    let getCell = (item: VaultAPITypes.apiKey, colType): Table.cell => {
      let appendString = str => str->String.concat(String.repeat("*", 10))

      switch colType {
      | Name => Text(item.name)
      | Description => Text(item.description)
      | Prefix => Text(item.prefix->appendString)
      | Created => Date(item.created)
      | Expiration =>
        if item.expiration == Never {
          Text(item.expiration_date->LogicUtils.getFirstLetterCaps)
        } else {
          Date(item.expiration_date)
        }
      | CustomCell =>
        Table.CustomCell(<TableActionsCell keyId={item.key_id} getAPIKeyDetails data=item />, "")
      }
    }

    let visibleColumns = Recoil.useRecoilValueFromAtom(TableAtoms.vaultApiDefaultCols)

    let apiKeysTableEntity = EntityType.makeEntity(
      ~uri="",
      ~getObjects=getItems,
      ~defaultColumns,
      ~allColumns,
      ~getHeading,
      ~dataKey="data",
      ~getCell,
    )

    <PageLoaderWrapper screenState>
      {<div className="relative mt-10 md:mt-0">
        <h2
          className="font-bold absolute top-2 md:top-6 left-0 text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {"Your Keys"->React.string}
        </h2>
        <LoadedTable
          title="Keys"
          hideTitle=true
          resultsPerPage=7
          visibleColumns
          entity=apiKeysTableEntity
          showSerialNumber=true
          actualData={data->Array.map(Nullable.make)}
          totalResults={data->Array.length}
          offset
          setOffset
          currrentFetchCount={data->Array.length}
          showAutoScroll=true
          tableActions={<div className="mt-0 md:mt-5">
            <ApiKeyAddBtn getAPIKeyDetails />
          </div>}
        />
      </div>}
    </PageLoaderWrapper>
  }
}

module PublishableAndHashKeySection = {
  @react.component
  let make = () => {
    let getURL = APIUtils.useGetURL()
    let fetchDetails = APIUtils.useGetMethod()
    let (merchantInfo, setMerchantInfo) = React.useState(() =>
      JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails
    )
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getMerchantDetails = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let accountUrl = getURL(~entityName=V2(MERCHANT_ACCOUNT), ~methodType=Get)
        let merchantDetails = await fetchDetails(accountUrl)
        let merchantInfo = merchantDetails->MerchantAccountDetailsMapper.getMerchantDetails
        setMerchantInfo(_ => merchantInfo)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(e) =>
        setScreenState(_ => PageLoaderWrapper.Error(Exn.message(e)->Option.getOr("Error")))
      }
    }

    React.useEffect(() => {
      getMerchantDetails()->ignore
      None
    }, [])

    let paymentResponsHashKey = merchantInfo.payment_response_hash_key->Option.getOr("")

    <PageLoaderWrapper screenState sectionHeight="h-40-vh">
      <div className="mt-10">
        <div className="bg-white dark:bg-jp-gray-lightgray_background rounded-md">
          <FormRenderer.DesktopRow itemWrapperClass="">
            <div className="flex flex-col gap-1 md:gap-4 mb-4 md:mb-0">
              <div className="flex">
                <div className={`break-all text-md text-base text-nd_gray-400 ${body.md.medium}`}>
                  {"Publishable Key"->React.string}
                </div>
                <div className="ml-1 mt-0.5 h-5 w-5">
                  <ToolTip
                    tooltipWidthClass="w-fit"
                    description="Visit Dev Docs"
                    toolTipFor={<div
                      className="cursor-pointer"
                      onClick={_ => {
                        "https://hyperswitch.io/docs"->Window._open
                      }}>
                      <Icon name="nd_question_mark_circle" size=12 />
                    </div>}
                    toolTipPosition=ToolTip.Top
                  />
                </div>
              </div>
              <HelperComponents.CopyTextCustomComp
                displayValue={Some(merchantInfo.publishable_key)}
                customTextCss="break-all text-sm truncate md:whitespace-normal font-semibold text-nd_gray-600"
                customIconCss="text-jp-gray-700"
              />
            </div>
            <RenderIf condition={paymentResponsHashKey->String.length !== 0}>
              <div className="flex flex-col gap-2 md:gap-4">
                <div
                  className={`break-all text-md text-base text-nd_gray-400 font-semibold ${body.md.medium}`}>
                  {"Payment Response Hash Key"->React.string}
                </div>
                <HelperComponents.CopyTextCustomComp
                  displayValue={Some(paymentResponsHashKey)}
                  customTextCss="break-all truncate md:whitespace-normal text-sm font-semibold text-jp-gray-800 text-opacity-75"
                  customParentClass="flex items-center gap-5"
                  customIconCss="text-jp-gray-700"
                />
              </div>
            </RenderIf>
          </FormRenderer.DesktopRow>
        </div>
      </div>
    </PageLoaderWrapper>
  }
}
