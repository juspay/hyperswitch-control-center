open LogicUtils
open APIUtilsTypes
open AcquirerConfigHelpers
open AcquirerConfigEntity
open FormRenderer
open FramerMotion

module FieldRendererWithStyles = {
  @react.component
  let make = (~field, ~containerClass=?) => {
    let styles = AcquirerConfigHelpers.fieldStyles
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
  let make = (~isAcquirerConfigArrEmpty, ~setIsShowAcquirerConfigSettings, ~isDisabled) => {
    let showToast = ToastState.useShowToast()
    let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
    let getURL = APIUtils.useGetURL()
    let updateDetails = APIUtils.useUpdateMethod()
    let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
    let validateForm = values => validateAcquirerConfigForm(values, formKeys)

    let onSubmit = async (values, _) => {
      try {
        showToast(~message="Updating acquirer config...", ~toastType=ToastState.ToastInfo)
        let valuesDict = values->getDictFromJsonObject
        valuesDict->Dict.set("profile_id", profileId->JSON.Encode.string)

        let url = getURL(~entityName=V1(ACQUIRER_CONFIG_SETTINGS), ~methodType=Fetch.Post)
        let _ = await updateDetails(url, valuesDict->JSON.Encode.object, Fetch.Post)

        setIsShowAcquirerConfigSettings(_ => false)
        showToast(~message="Acquirer config updated", ~toastType=ToastState.ToastSuccess)

        fetchBusinessProfileFromId(~profileId=Some(profileId))->ignore
      } catch {
      | _ =>
        showToast(~message="Failed to update acquirer config", ~toastType=ToastState.ToastError)
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
                        <FieldRendererWithStyles field={merchantName(~isDisabled)} />
                        <FieldRendererWithStyles field={merchantCountryCode(~isDisabled)} />
                      </DesktopRow>
                      <DesktopRow>
                        <FieldRendererWithStyles field={acquirerBin(~isDisabled)} />
                        <FieldRendererWithStyles field={acquirerAssignedMerchantId(~isDisabled)} />
                      </DesktopRow>
                      <DesktopRow>
                        <FieldRendererWithStyles field={acquirerFraudRate(~isDisabled)} />
                        <FieldRendererWithStyles field={network(~isDisabled)} />
                      </DesktopRow>
                    </div>
                  </div>
                </div>
              </div>
              <DesktopRow>
                <div className="flex justify-end w-full gap-2">
                  <SubmitButton
                    text="Save"
                    buttonType=Button.Primary
                    buttonSize=Button.Medium
                    disabledParamter=isDisabled
                  />
                  <RenderIf condition={!isAcquirerConfigArrEmpty}>
                    <Button
                      buttonType=Button.Secondary
                      onClick={_ => setIsShowAcquirerConfigSettings(_ => false)}
                      text="Cancel"
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
  let make = (
    ~acquirerConfigArr=[],
    ~setIsShowAcquirerConfigSettings=_ => (),
    ~isDisabled=false,
  ) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let resultsPerPage = 10
    let (isShowAcquirerConfigSettings, setIsShowAcquirerConfigSettings) = React.useState(_ => false)
    let isAcquirerConfigArrEmpty = acquirerConfigArr->Array.length == 0
    let actualData = acquirerConfigArr->Array.map(Nullable.make)
    let totalResults = acquirerConfigArr->Array.length

    <div className="border-t-2 dark:border-jp-gray-950 md:border-0 w-full overflow-scroll">
      <RenderIf condition={!isAcquirerConfigArrEmpty}>
        <LoadedTable
          title="Acquirer Configurations"
          hideTitle=true
          actualData
          totalResults
          resultsPerPage
          offset
          setOffset
          entity
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
          : <SettingsForm isAcquirerConfigArrEmpty setIsShowAcquirerConfigSettings isDisabled />}
      </AnimatePresence>
    </div>
  }
}

@react.component
let make = (~isDisabled=false, ~acquirerConfigData) => {
  let acquirerConfigArr = React.useMemo(
    () => acquirerConfigData->Option.mapOr([], data => data->Array.map(acquirerConfigTypeMapper)),
    [acquirerConfigData],
  )

  let accordionData: array<Accordion.accordion> = [
    {
      title: "Acquirer Config Settings",
      renderContent: () => <AcquirerConfigContent acquirerConfigArr isDisabled />,
      renderContentOnTop: None,
    },
  ]

  <div className="py-4 md:py-10 gap-10 h-full flex flex-col">
    <Accordion
      accordion=accordionData
      accordianTopContainerCss="border overflow-hidden border-jp-gray-500 rounded-md dark:border-jp-gray-960"
      accordianBottomContainerCss="px-4 py-3 md:bg-jp-gray-100 dark:bg-jp-gray-lightgray_background"
      contentExpandCss="!bg-jp-gray-100 dark:!bg-jp-gray-lightgray_background p-0"
      arrowFillColor="#6B7280"
      titleStyle="md:font-bold font-semibold md:text-fs-16 text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-white dark:text-opacity-75"
    />
  </div>
}
