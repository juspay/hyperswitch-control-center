open LogicUtils
open APIUtilsTypes
open AcquirerConfigUtils
open AcquirerConfigEntity
open AcquirerConfigTypes
open FormRenderer
open FramerMotion

module FieldRendererWithStyles = {
  @react.component
  let make = (~field, ~containerClass=?) => {
    let styles = AcquirerConfigUtils.fieldStyles
    let errorClass = styles["errorClass"]
    let labelClass = styles["labelClass"]
    let fieldWrapperClass = styles["fieldWrapperClass"]
    let defaultContainerClass = styles["containerClass"]

    let finalContainerClass = containerClass->Option.getOr(defaultContainerClass)

    <div className=finalContainerClass>
      <FieldRenderer field errorClass labelClass fieldWrapperClass />
    </div>
  }
}

module SettingsForm = {
  @react.component
  let make = (~isAcquirerConfigArrEmpty, ~handleCloseForm, ~editingConfig=None) => {
    open Fetch
    let showToast = ToastState.useShowToast()
    let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let validateForm = values => validateAcquirerConfigForm(values, formKeys)

    let isUpdateMode = editingConfig->Option.isSome
    let initialValues =
      editingConfig
      ->Option.map(getInitialValuesFromConfig)
      ->Option.getOr(JSON.Encode.null)

    let (submitButtonTitle, cancelButtonTitle) = isUpdateMode
      ? ("Update", "Exit Update Mode")
      : ("Save", "Close")

    let prepareFormData = values => {
      let valuesDict = values->getDictFromJsonObject
      let acquirerBinValue = valuesDict->getFloat("acquirer_bin", 0.0)
      if acquirerBinValue > 0.0 {
        valuesDict->Dict.set(
          "acquirer_bin",
          acquirerBinValue->Float.toInt->Int.toString->JSON.Encode.string,
        )
      }
      valuesDict
    }

    let handleApiError = e => {
      let defaultErrorMessage = "Failed to process acquirer config"
      let errorMessage = switch Exn.message(e) {
      | Some(err) => {
          let errorCode =
            err->JSON.parseExn->getDictFromJsonObject->LogicUtils.getString("code", "")
          switch errorCode {
          | "IR_38" => "Duplicate entry found"
          | _ => defaultErrorMessage
          }
        }
      | None => defaultErrorMessage
      }
      showToast(~message=errorMessage, ~toastType=ToastState.ToastError)
    }

    let createAcquirerConfig = async values => {
      try {
        showToast(~message="Creating acquirer config...", ~toastType=ToastState.ToastInfo)

        let valuesDict = prepareFormData(values)
        valuesDict->Dict.set("profile_id", profileId->JSON.Encode.string)

        let (entityName, methodType) = (V1(ACQUIRER_CONFIG_SETTINGS), Post)
        let url = getURL(~entityName, ~methodType)

        let _ = await updateDetails(url, valuesDict->JSON.Encode.object, Post)

        handleCloseForm()
        showToast(~message="Acquirer config created", ~toastType=ToastState.ToastSuccess)
        fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore
      } catch {
      | Exn.Error(e) => handleApiError(e)
      }
    }

    let updateAcquirerConfig = async (values, configId) => {
      try {
        showToast(~message="Updating acquirer config...", ~toastType=ToastState.ToastInfo)

        let valuesDict = prepareFormData(values)

        let (entityName, methodType) = (V1(ACQUIRER_CONFIG_SETTINGS), Post)
        let url = getURL(~entityName, ~methodType, ~id=Some(configId))

        let _ = await updateDetails(url, valuesDict->JSON.Encode.object, Post)

        handleCloseForm()
        showToast(~message="Acquirer config updated", ~toastType=ToastState.ToastSuccess)
        fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore
      } catch {
      | Exn.Error(e) => handleApiError(e)
      }
    }

    let onSubmit = async (values, _) => {
      switch (isUpdateMode, editingConfig) {
      | (true, Some({id})) => await updateAcquirerConfig(values, id)
      | (false, _) => await createAcquirerConfig(values)
      | (true, None) =>
        showToast(~message="No config selected for update", ~toastType=ToastState.ToastError)
      }
      Nullable.null
    }

    <Motion.Div
      key="config-form"
      initial={{height: isAcquirerConfigArrEmpty ? "0px" : "90px"}}
      animate={{height: "auto"}}
      exit={{
        height: isAcquirerConfigArrEmpty ? "0px" : "90px",
        opacity: 0.0,
      }}
      transition={{duration: 0.3, ease: "easeInOut"}}>
      <AddDataAttributes attributes=[("data-section", "Acquirer Config Settings")]>
        <ReactFinalForm.Form
          key="acquirer-config"
          subscription=ReactFinalForm.subscribeToValues
          validate=validateForm
          onSubmit
          initialValues
          render={({handleSubmit}) => {
            <form
              onSubmit={handleSubmit}
              className={`flex flex-col gap-8 h-full w-full py-6 px-4 ${isAcquirerConfigArrEmpty
                  ? "pt-0"
                  : ""}`}>
              <div className="flex-1">
                <div className="grid grid-cols-5 gap-2">
                  <div className="col-span-4">
                    <div>
                      <DesktopRow>
                        <FieldRendererWithStyles field={merchantName} />
                        <FieldRendererWithStyles field={merchantCountryCode} />
                      </DesktopRow>
                      <DesktopRow>
                        <FieldRendererWithStyles field={acquirerBin} />
                        <FieldRendererWithStyles field={acquirerAssignedMerchantId} />
                      </DesktopRow>
                      <DesktopRow>
                        <FieldRendererWithStyles field={acquirerFraudRate} />
                        <FieldRendererWithStyles field={network} />
                      </DesktopRow>
                    </div>
                  </div>
                </div>
              </div>
              <DesktopRow>
                <div className="flex justify-end w-full gap-2">
                  <SubmitButton
                    text=submitButtonTitle buttonType=Button.Primary buttonSize=Button.Medium
                  />
                  <RenderIf condition={!isAcquirerConfigArrEmpty}>
                    <Button
                      buttonType=Button.Secondary
                      onClick={_ => handleCloseForm()}
                      text=cancelButtonTitle
                    />
                  </RenderIf>
                </div>
              </DesktopRow>
            </form>
          }}
        />
      </AddDataAttributes>
    </Motion.Div>
  }
}

module ActionButtons = {
  @react.component
  let make = (~setIsShowAcquirerConfigSettings) => {
    <Motion.Div
      key="add-button"
      initial={{y: 10, opacity: 0.0}}
      animate={{y: 0, opacity: 1.0}}
      exit={{y: -10, opacity: 0.0}}
      transition={{duration: 0.2}}
      className="p-6">
      <Button
        buttonType=PrimaryOutline
        onClick={_ => setIsShowAcquirerConfigSettings(_ => true)}
        text="Add acquirer configurations"
        leftIcon={FontAwesome("plus")}
        customIconSize=20
        customIconMargin="!pr-0"
        customButtonStyle="border-none"
      />
    </Motion.Div>
  }
}

module AcquirerConfigContent = {
  @react.component
  let make = () => {
    let (offset, setOffset) = React.useState(_ => 0)
    let resultsPerPage = 10
    let (isShowAcquirerConfigSettings, setIsShowAcquirerConfigSettings) = React.useState(_ => false)
    let (editingConfig, setEditingConfig) = React.useState(_ => None)
    let {acquirer_configs: acquirerConfig} =
      HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom

    let acquirerConfigArr = React.useMemo(
      () => acquirerConfig->Option.mapOr([], data => data->Array.map(acquirerConfigTypeMapper)),
      [acquirerConfig],
    )
    let actualData = acquirerConfigArr->Array.map(Nullable.make)
    let totalResults = acquirerConfigArr->Array.length
    let isAcquirerConfigArrEmpty = acquirerConfigArr->Array.length == 0

    let handleEdit = (config: acquirerConfig) => {
      setEditingConfig(_ => Some(config))
      setIsShowAcquirerConfigSettings(_ => true)
    }

    let handleCloseForm = _ => {
      setIsShowAcquirerConfigSettings(_ => false)
      setEditingConfig(_ => None)
    }

    let entityWithEditHandler = React.useMemo(
      () => makeEntityWithEditHandler(~onEdit=Some(handleEdit)),
      [handleEdit],
    )

    <div className="border-t-2 dark:border-jp-gray-950 md:border-0 w-full">
      <RenderIf condition={!isAcquirerConfigArrEmpty}>
        <LoadedTable
          title="Acquirer Configurations"
          hideTitle=true
          actualData
          totalResults
          resultsPerPage
          offset
          setOffset
          entity=entityWithEditHandler
          currrentFetchCount=totalResults
          showPagination={totalResults > resultsPerPage}
          tableLocalFilter=false
          showSerialNumber=false
          customBorderClass="rounded-none"
          tableheadingClass="bg-transparent"
          nonFrozenTableParentClass="rounded-none"
        />
      </RenderIf>
      <AnimatePresence mode="wait">
        {!isShowAcquirerConfigSettings && !isAcquirerConfigArrEmpty
          ? <ActionButtons setIsShowAcquirerConfigSettings />
          : <SettingsForm isAcquirerConfigArrEmpty handleCloseForm editingConfig />}
      </AnimatePresence>
    </div>
  }
}

@react.component
let make = () => {
  let accordionData: array<Accordion.accordion> = [
    {
      title: "Acquirer Config Settings",
      renderContent: () => <AcquirerConfigContent />,
      renderContentOnTop: None,
    },
  ]

  <div className="py-4 md:py-10 gap-10 h-full flex flex-col">
    <Accordion
      accordion=accordionData
      accordianTopContainerCss="border overflow-visible border-jp-gray-500 rounded-md dark:border-jp-gray-960"
      accordianBottomContainerCss="px-4 py-3 md:bg-jp-gray-100 dark:bg-jp-gray-lightgray_background"
      contentExpandCss="!bg-jp-gray-100 dark:!bg-jp-gray-lightgray_background p-0 rounded-md"
      arrowFillColor="#6B7280"
      titleStyle="md:font-bold font-semibold md:text-fs-16 text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-white dark:text-opacity-75 rounded-md"
    />
  </div>
}
