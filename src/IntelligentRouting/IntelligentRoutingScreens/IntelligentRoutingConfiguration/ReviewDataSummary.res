@react.component
let make = (~reviewFields, ~isUpload=false, ~fileUInt8Array) => {
  open IntelligentRoutingReviewFieldsEntity
  open APIUtils
  open LogicUtils
  open FormDataUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (showLoading, setShowLoading) = React.useState(() => false)
  let loaderLottieFile = LottieFiles.useLottieJson("spinner.json")

  let uploadData = async () => {
    try {
      setShowLoading(_ => true)
      let queryParamerters = `upload_data=${isUpload ? "true" : "false"}`
      let url = getURL(
        ~entityName=V1(SIMULATE_INTELLIGENT_ROUTING),
        ~methodType=Post,
        ~queryParamerters=Some(queryParamerters),
      )
      let formData = formData()

      let getblob = blob([fileUInt8Array], {"type": "text/csv"})
      appendBlob(formData, "csv_data", getblob, "data.csv")

      let jsonData = "{\"algo_type\": \"window_based\"}"
      append(formData, "json", jsonData)

      let response = await updateDetails(
        ~bodyFormData=formData,
        ~headers=Dict.make(),
        url,
        Dict.make()->JSON.Encode.object,
        Post,
        ~contentType=AuthHooks.Unknown,
      )

      let msg = response->getDictFromJsonObject->getString("message", "")->String.toLowerCase
      if msg === "simulation successful" {
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url="v2/dynamic-routing/dashboard"),
        )
      }
      setShowLoading(_ => false)
    } catch {
    | _ =>
      setShowLoading(_ => false)
      showToast(~message="Upload data failed", ~toastType=ToastError)
    }
  }

  let handleNext = _ => {
    uploadData()->ignore
    mixpanelEvent(~eventName="intelligent_routing_upload_data")
  }

  let modalBody =
    <div className="">
      <div className="text-xl p-3 m-3 font-semibold text-nd_gray-700">
        {"Running Intelligence Routing "->React.string}
      </div>
      <hr />
      <div className="flex flex-col gap-12 items-center pt-10 pb-6 px-6">
        <div className="w-8">
          <span className="px-3">
            <span className={`flex items-center`}>
              <div className="scale-400 pt-px">
                <Lottie animationData={loaderLottieFile} autoplay=true loop=true />
              </div>
            </span>
          </span>
        </div>
        <p className="text-center text-nd_gray-600">
          {"Please wait while we are analyzing data. Our intelligent models are working to determine the potential authentication rate uplift."->React.string}
        </p>
      </div>
    </div>

  <div>
    <div className="w-500-px">
      {IntelligentRoutingHelper.stepperHeading(
        ~title="Review Data Summary",
        ~subTitle="Explore insights in the dashboard",
      )}
      <div className="mt-6">
        <VaultCustomerSummary.Details
          data=reviewFields
          getHeading
          getCell
          detailsFields=allColumns
          widthClass=""
          justifyClassName="grid grid-cols-none"
        />
      </div>
      <Button
        text="Explore Insights"
        customButtonStyle={`w-full mt-6 hover:opacity-80 ${showLoading ? "cursor-wait" : ""}`}
        buttonType=Primary
        onClick={_ => handleNext()}
        rightIcon={showLoading
          ? CustomIcon(
              <span className="px-3">
                <span className={`flex items-center mx-2 animate-spin`}>
                  <Loadericon size=14 iconColor="text-white" />
                </span>
              </span>,
            )
          : NoIcon}
      />
    </div>
    <Modal
      showModal=showLoading
      closeOnOutsideClick=false
      setShowModal=setShowLoading
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      {modalBody}
    </Modal>
  </div>
}
