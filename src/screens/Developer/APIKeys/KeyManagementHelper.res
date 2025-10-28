module ApiEditModal = {
  open DeveloperUtils
  open LogicUtils
  open HSwitchUtils
  open HSwitchSettingTypes
  open APIUtilsTypes
  open Fetch
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
    let updateDetails = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
    let (apiKey, setApiKey) = React.useState(_ => "")
    let (modalState, setModalState) = React.useState(_ => action)
    let (showCustomDate, setShowCustomDate) = React.useState(_ => false)

    React.useEffect(() => {
      setShowCustomDate(_ => false)
      setModalState(_ => action)
      None
    }, [showModal])

    let downloadKey = _ => {
      DownloadUtils.downloadOld(~fileName="apiKey.txt", ~content=apiKey)
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

        let name = valuesDict->getString("name", "")
        let description = valuesDict->getString("description", "")

        let body =
          [
            ("name", name->JSON.Encode.string),
            ("description", description->JSON.Encode.string),
          ]->Dict.fromArray

        let expirationDate = valuesDict->getString("expiration_date", "")

        let expriryValue = switch valuesDict
        ->getString("expiration", "")
        ->getRecordTypeFromString {
        | Custom => expirationDate
        | _ => Never->getStringFromRecordType
        }

        Dict.set(body, "expiration", expriryValue->JSON.Encode.string)

        setModalState(_ => Loading)

        let (entityName, methodType) = switch (version, action) {
        | (V1, Update) => (V1(API_KEYS), Post)
        | (V2, Update) => (V2(API_KEYS), Put)
        | (V2, _) => (V2(API_KEYS), Post)
        | (V1, _) => (V1(API_KEYS), Post)
        }

        let url = switch action {
        | Update => getURL(~entityName, ~methodType, ~id=Some(keyId->Option.getOr("")))
        | _ => getURL(~entityName, ~methodType=Post)
        }

        let json = await updateDetails(url, body->JSON.Encode.object, methodType)
        let keyDict = json->getDictFromJsonObject

        setApiKey(_ => keyDict->getString("api_key", ""))

        switch action {
        | Update => setShowModal(_ => false)
        | _ => {
            Clipboard.writeText(keyDict->getString("api_key", ""))
            setModalState(_ => Success)
          }
        }

        getAPIKeyDetails()->ignore
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
  open DeveloperUtils
  open HSwitchSettingTypes
  open APIUtilsTypes
  @react.component
  let make = (~keyId, ~getAPIKeyDetails: unit => promise<unit>, ~data: apiKey) => {
    let getURL = APIUtils.useGetURL()
    let deleteDetails = APIUtils.useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()
    let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
    let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
    // TODO: Remove `MerchantDetailsManage` permission in future
    let showButtons = hasAnyGroupAccess(
      userHasAccess(~groupAccess=MerchantDetailsManage),
      userHasAccess(~groupAccess=AccountManage),
    )
    let (showModal, setShowModal) = React.useState(_ => false)

    let deleteKey = async () => {
      try {
        let body = Dict.fromArray([
          ("key_id", keyId->JSON.Encode.string),
          ("revoked", true->JSON.Encode.bool),
        ])

        let entityName = switch version {
        | V1 => V1(API_KEYS)
        | V2 => V2(API_KEYS)
        }

        let deleteUrl = getURL(~entityName, ~methodType=Delete, ~id=Some(keyId))
        let _ = await deleteDetails(deleteUrl, body->JSON.Encode.object, Delete)
        getAPIKeyDetails()->ignore
      } catch {
      | Exn.Error(_) =>
        showToast(~message="Failed to delete API key", ~toastType=ToastState.ToastError)
      }
    }

    let openPopUp = _ => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Delete API Key",
        description: "Are you sure you want to DELETE the API Key?"->React.string,
        handleConfirm: {
          text: "Yes, delete it",
          onClick: {_ => deleteKey()->ignore},
        },
        handleCancel: {text: "No, don't delete", onClick: _ => ()},
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
      <div className="flex invisible cursor-pointer group-hover:visible">
        <ACLDiv
          showTooltip={showButtons == Access}
          authorization={showButtons}
          onClick={_ => setShowModal(_ => true)}>
          <Icon
            name="edit"
            size=14
            className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white mr-4 mb-1"
          />
        </ACLDiv>
        <ACLDiv
          authorization={showButtons}
          showTooltip={showButtons == Access}
          onClick={_ => openPopUp()}>
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
  open APIUtilsTypes
  open Typography
  @react.component
  let make = (~dataNotFoundComponent=?) => {
    let getURL = APIUtils.useGetURL()
    let fetchDetails = APIUtils.useGetMethod()
    let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
    let (offset, setOffset) = React.useState(_ => 0)
    let (data, setData) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAPIKeyDetails = async () => {
      try {
        let entityName = switch version {
        | V1 => V1(API_KEYS)
        | V2 => V2(API_KEYS)
        }

        let apiKeyListUrl = getURL(~entityName, ~methodType=Get)
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
        <h2 className={`absolute top-2 md:top-6 left-0 ${heading.sm.semibold}`}>
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
          ?dataNotFoundComponent
        />
      </div>}
    </PageLoaderWrapper>
  }
}
