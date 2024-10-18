@react.component
let make = (
  ~isFromSettings=true,
  ~showModalFromOtherScreen=false,
  ~setShowModalFromOtherScreen=_ => (),
) => {
  open APIUtils
  // open OrganizationMappingUtils
  open OrganizationMappingEntity
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod()
  let (offset, setOffset) = React.useState(_ => 0)
  // let (modalState, setModalState) = React.useState(_ => Edit)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  // let (updatedProfileId, setUpdatedProfileId) = React.useState(_ => "")

  let organizationValues = HyperswitchAtom.orgListAtom->Recoil.useRecoilValueFromAtom

  let fetchBusinessProfiles = BusinessProfileHook.useFetchBusinessProfiles()

  // let updateMerchantDetails = async body => {
  //   try {
  //     setScreenState(_ => PageLoaderWrapper.Loading)
  //     let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Post)
  //     let response = await updateDetails(url, body, Post)
  //     setUpdatedProfileId(_ =>
  //       response->LogicUtils.getDictFromJsonObject->LogicUtils.getString("profile_id", "")
  //     )
  //     fetchBusinessProfiles()->ignore
  //     showToast(~message="Your Entry added successfully", ~toastType=ToastState.ToastSuccess)
  //     setScreenState(_ => PageLoaderWrapper.Success)
  //   } catch {
  //   | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
  //   }

  //   if !isFromSettings {
  //     setShowModalFromOtherScreen(_ => false)
  //   }
  //   setModalState(_ => Successful)

  //   Nullable.null
  // }

  <PageLoaderWrapper screenState>
    <RenderIf condition=isFromSettings>
      <div className="relative h-full">
        <div className="flex flex-col-reverse md:flex-col gap-2">
          <PageUtils.PageHeading
            title="Organizations"
            subTitle="Add and manage organizations to represent different businesses across countries."
          />
          // <RenderIf condition={organizationValues->Array.length > 1}>
          //   <HSwitchUtils.WarningArea
          //     warningText="Warning! Now that you've configured more than one profile, you must mandatorily pass 'profile_id' in payments API request every time"
          //   />
          // </RenderIf>
          <LoadedTable
            title="Organizations"
            hideTitle=true
            resultsPerPage=7
            visibleColumns
            entity={businessProfileTableEntity}
            showSerialNumber=true
            actualData={organizationValues->Array.map(Nullable.make)}
            totalResults={organizationValues->Array.length}
            offset
            setOffset
            currrentFetchCount={organizationValues->Array.length}
          />
        </div>
      </div>
    </RenderIf>
  </PageLoaderWrapper>
}
