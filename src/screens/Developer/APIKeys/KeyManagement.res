module ApiEditModal = {
  open DeveloperUtils
  open HSwitchUtils
  open HSwitchSettingTypes
  @react.component
  let make = (
    ~setShowModal,
    ~getAPIKeyDetails: unit => promise<unit>,
    ~initialValues,
    ~showModal,
    ~action=Create,
    ~keyId=?,
  ) => {
    let getURL = APIUtils.useGetURL()
    let (apiKey, setApiKey) = React.useState(_ => "")
    let (showCustomDate, setShowCustomDate) = React.useState(_ => false)
    let (modalState, setModalState) = React.useState(_ => action)
    let showToast = ToastState.useShowToast()
    let updateDetails = APIUtils.useUpdateMethod()
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
        let valuesDict = values->LogicUtils.getDictFromJsonObject

        let body = Dict.make()
        Dict.set(body, "name", valuesDict->LogicUtils.getString("name", "")->JSON.Encode.string)
        let description = valuesDict->LogicUtils.getString("description", "")
        Dict.set(body, "description", description->JSON.Encode.string)

        let expirationDate = valuesDict->LogicUtils.getString("expiration_date", "")

        let expriryValue = switch valuesDict
        ->LogicUtils.getString("expiration", "")
        ->getRecordTypeFromString {
        | Custom => expirationDate
        | _ => Never->getStringFromRecordType
        }

        Dict.set(body, "expiration", expriryValue->JSON.Encode.string)

        setModalState(_ => Loading)

        let url = switch action {
        | Update => {
            let key_id = keyId->Option.getOr("")
            getURL(~entityName=V1(API_KEYS), ~methodType=Post, ~id=Some(key_id))
          }

        | _ => getURL(~entityName=V1(API_KEYS), ~methodType=Post)
        }

        let json = await updateDetails(url, body->JSON.Encode.object, Post)
        let keyDict = json->LogicUtils.getDictFromJsonObject

        setApiKey(_ => keyDict->LogicUtils.getString("api_key", ""))
        switch action {
        | Update => setShowModal(_ => false)
        | _ => {
            Clipboard.writeText(keyDict->LogicUtils.getString("api_key", ""))
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
  open DeveloperUtils
  @react.component
  let make = (~getAPIKeyDetails) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let (showModal, setShowModal) = React.useState(_ => false)
    let initialValues = Dict.make()
    initialValues->Dict.set("expiration", Never->getStringFromRecordType->JSON.Encode.string)
    let isMobileView = MatchMedia.useMobileChecker()

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
  open DeveloperUtils
  open HSwitchSettingTypes
  @react.component
  let make = (~keyId, ~getAPIKeyDetails: unit => promise<unit>, ~data: apiKey) => {
    let getURL = APIUtils.useGetURL()
    let showToast = ToastState.useShowToast()
    let (showModal, setShowModal) = React.useState(_ => false)
    let showPopUp = PopUpState.useShowPopUp()
    let deleteDetails = APIUtils.useUpdateMethod()
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

        let deleteUrl = getURL(~entityName=V1(API_KEYS), ~methodType=Delete, ~id=Some(keyId))
        (await deleteDetails(deleteUrl, body->JSON.Encode.object, Delete))->ignore
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
  open DeveloperUtils
  open HSwitchSettingTypes
  @react.component
  let make = () => {
    let getURL = APIUtils.useGetURL()
    let fetchDetails = APIUtils.useGetMethod()
    let (offset, setOffset) = React.useState(_ => 0)
    let (data, setData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAPIKeyDetails = async () => {
      try {
        let apiKeyListUrl = getURL(~entityName=V1(API_KEYS), ~methodType=Get)
        let apiKeys = await fetchDetails(apiKeyListUrl)
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

    let getCell = (item: apiKey, colType): Table.cell => {
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

    let visibleColumns = Recoil.useRecoilValueFromAtom(TableAtoms.apiDefaultCols)

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
          {"API Keys"->React.string}
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

module KeysManagement = {
  open Typography
  @react.component
  let make = () => {
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    let (isCurrentMerchantPlatform, isCurrentOrganizationPlatform) = OMPSwitchHooks.useOMPType()
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let redirectToDocs = _ => {
      let docsUrl = "https://docs.hyperswitch.io/use-cases/for-marketplace-platforms"
      mixpanelEvent(~eventName="api_keys_banner_learn_more")
      Window._open(docsUrl)
    }
    let bannerText = {
      DeveloperUtils.bannerText(
        ~isPlatformMerchant=isCurrentMerchantPlatform,
        ~hasCreateApiKeyAccess=hasAnyGroupAccess(
          userHasAccess(~groupAccess=MerchantDetailsManage),
          userHasAccess(~groupAccess=AccountManage),
        ),
      )
    }

    <div>
      <PageUtils.PageHeading
        title="Keys" subTitle="Manage API keys and credentials for integrated payment services"
      />
      <RenderIf condition={isCurrentOrganizationPlatform}>
        <div className="py-4">
          <HSwitchUtils.AlertBanner
            bannerContent={<p>
              <RenderIf condition={isCurrentMerchantPlatform}>
                <span className={`text-nd_gray-800 ${body.md.semibold}`}>
                  {"Platform Merchant Account: "->React.string}
                </span>
              </RenderIf>
              <span className={`text-nd_gray-600 ${body.md.regular}`}>
                {bannerText->React.string}
              </span>
              <span
                onClick={redirectToDocs}
                className={`text-nd_primary_blue-500 hover:cursor-pointer ${body.md.regular}`}>
                {" Learn More"->React.string}
              </span>
            </p>}
            bannerType=Warning
          />
        </div>
      </RenderIf>
      <ApiKeysTable />
      <PublishableAndHashKeySection />
    </div>
  }
}
