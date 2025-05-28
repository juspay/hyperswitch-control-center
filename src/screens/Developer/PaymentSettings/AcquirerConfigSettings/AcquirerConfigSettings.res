open LogicUtils
open APIUtilsTypes
open AcquirerConfigHelpers
open AcquirerConfigEntity
open FormRenderer

@react.component
let make = (~profileId="", ~isDisabled=false, ~fetchAcquirerConfig, ~acquirerConfigData) => {
  let updateDetails = APIUtils.useUpdateMethod()
  let getURL = APIUtils.useGetURL()
  let showToast = ToastState.useShowToast()
  let {userInfo: {profileId: userProfileId}} = React.useContext(UserInfoProvider.defaultContext)
  let (isAcquirerConfigExpanded, setIsAcquirerConfigExpanded) = React.useState(_ => false)
  let titleClass = "md:font-bold font-semibold md:text-fs-16 text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-white dark:text-opacity-75"

  let finalProfileId = profileId->LogicUtils.isEmptyString ? userProfileId : profileId
  let (isShowAcquirerConfigSettings, setIsShowAcquirerConfigSettings) = React.useState(_ => false)

  let onSubmit = async (values, _) => {
    showToast(~message="Updating acquirer config...", ~toastType=ToastState.ToastInfo)

    try {
      let valuesDict = values->getDictFromJsonObject

      let acquirerConfig = formKeys->Array.reduce(Dict.make(), (acc, key) => {
        let value = if key == "acquirer_fraud_rate" {
          valuesDict->getFloat(key, 0.0)->JSON.Encode.float
        } else {
          valuesDict->getString(key, "")->JSON.Encode.string
        }
        Dict.set(acc, key, value)
        acc
      })

      Dict.set(acquirerConfig, "profile_id", finalProfileId->JSON.Encode.string)

      let url = getURL(~entityName=V1(ACQUIRER_CONFIG_SETTINGS), ~methodType=Fetch.Post)
      let body = acquirerConfig->JSON.Encode.object

      let _ = await updateDetails(url, body, Fetch.Post)
      let _ = await fetchAcquirerConfig()

      setIsShowAcquirerConfigSettings(_ => false)
      showToast(~message="Acquirer config updated", ~toastType=ToastState.ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to update acquirer config", ~toastType=ToastState.ToastError)
    }

    Nullable.null
  }

  let validateForm = values => validateAcquirerConfigForm(values, formKeys, ~isDisabled)

  React.useEffect0(() => {
    fetchAcquirerConfig()->ignore
    None
  })

  <div className={`border border-jp-gray-500 rounded-md dark:border-jp-gray-960"`}>
    {<AddDataAttributes attributes=[("data-section", "Acquirer Config Settings")]>
      <div className="md:bg-jp-gray-100 dark:bg-transparent">
        <div
          className={`flex items-center justify-between px-4 py-3 cursor-pointer ${titleClass} dark:bg-jp-gray-lightgray_background`}
          onClick={_ => {
            setIsAcquirerConfigExpanded(prev => !prev)
            setIsShowAcquirerConfigSettings(_ => false)
          }}>
          <h3 className="text-base"> {"Acquirer Config Settings"->React.string} </h3>
          <div
            className="flex justify-center items-center text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-auto">
            <Icon name={isAcquirerConfigExpanded ? "angle-down" : "angle-right"} size=15 />
          </div>
        </div>
        <div
          className={`${!isAcquirerConfigExpanded
              ? "hidden"
              : ""} border-t-2 dark:border-jp-gray-950 md:border-0`}>
          <AddDataAttributes attributes=[("data-section", "Acquirer Config Settings")]>
            {<>
              <div className="overflow-x-auto">
                {acquirerConfigData->Array.length == 0
                  ? <div className="p-6 text-center text-gray-500">
                      {"No acquirer configurations found"->React.string}
                    </div>
                  : <AcquirerConfigTable acquirerConfigData />}
              </div>
              {!isShowAcquirerConfigSettings
                ? <div className="p-6">
                    <Button
                      buttonType=PrimaryOutline
                      onClick={_ => setIsShowAcquirerConfigSettings(_ => true)}
                      text="Add acquirer configurations"
                      leftIcon={FontAwesome("plus")}
                      customIconSize=20
                      customIconMargin="!pr-0"
                      customButtonStyle="border-none"
                    />
                  </div>
                : <AddDataAttributes attributes=[("data-section", "Acquirer Config Settings")]>
                    <ReactFinalForm.Form
                      key="acquirer-config"
                      subscription=ReactFinalForm.subscribeToValues
                      validate=validateForm
                      onSubmit
                      render={({handleSubmit}) => {
                        <form
                          onSubmit={handleSubmit}
                          className="flex flex-col gap-8 h-full w-full py-6 px-4">
                          <div className="flex-1">
                            <div className="grid grid-cols-5 gap-2">
                              <div className="col-span-4">
                                <AcquirerConfigInputs isDisabled />
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
                              <Button
                                buttonType=Button.Secondary
                                onClick={_ => setIsShowAcquirerConfigSettings(_ => false)}
                                text="Cancel"
                              />
                            </div>
                          </DesktopRow>
                        </form>
                      }}
                    />
                  </AddDataAttributes>}
            </>}
          </AddDataAttributes>
        </div>
      </div>
    </AddDataAttributes>}
  </div>
}
