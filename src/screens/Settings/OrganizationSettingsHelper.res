open Typography
open LogicUtils

module NewPlatformCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let fetchOrganizationList = OrganizationHooks.useFetchOrganizationList()

    let onSubmit = async (values, _) => {
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_PLATFORM, ~methodType=Post)

        let dict = values->getDictFromJsonObject
        let orgNameTrimmed = dict->getString("organization_name", "")->String.trim
        Dict.set(dict, "organization_name", orgNameTrimmed->JSON.Encode.string)

        let _ = await updateDetails(url, dict->JSON.Encode.object, Post)
        let _ = await fetchOrganizationList()
        showToast(
          ~toastType=ToastSuccess,
          ~message="Platform Organization Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ =>
        showToast(
          ~toastType=ToastError,
          ~message="Platform Organization Creation Failed",
          ~autoClose=true,
        )
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let organizationName = FormRenderer.makeFieldInfo(
      ~label="Organization Name",
      ~name="organization_name",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.textInput()(
          ~input={
            ...input,
            onChange: event =>
              ReactEvent.Form.target(event)["value"]
              ->String.trimStart
              ->Identity.stringToFormReactEvent
              ->input.onChange,
          },
          ~placeholder="Eg: My Platform Organization",
        ),
      ~isRequired=true,
    )

    let validateForm = (values: JSON.t) => {
      let errors = Dict.make()
      let valuesDict = values->getDictFromJsonObject
      let orgName = valuesDict->getString("organization_name", "")->String.trim
      let regexForOrgName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let errorMessage = if orgName->isEmptyString {
        "Organization name cannot be empty"
      } else if orgName->String.length > 64 {
        "Organization name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForOrgName), orgName) {
        "Organization name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "organization_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let modalBody = {
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Create New Platform Organization"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form key="new-platform-creation" onSubmit validate={validateForm}>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={organizationName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass={`!text-black font-medium !-ml-[0.5px] ${body.sm.medium}`}
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <FormRenderer.SubmitButton text="Create Platform" buttonSize=Small />
            </div>
          </div>
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

module PlatformInfoModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let modalBody = {
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="About Platform Organizations"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <div className="p-6 flex flex-col gap-6">
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}>
              {"What is a Platform Organization?"->React.string}
            </p>
            <p className={`text-nd_gray-600 ${body.md.regular}`}>
              {"A Platform Organisation is built for Vertical SaaS use cases, where a single platform manages payments for multiple merchants. It includes a Platform Merchant Account that centrally controls API keys, integrations, and payment flows on behalf of connected merchants. This setup enables scalable onboarding while keeping platform and merchant responsibilities clearly separated."->React.string}
            </p>
          </div>
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}>
              {"Key Features"->React.string}
            </p>
            <ul
              className={`list-disc list-inside text-nd_gray-600 flex flex-col gap-2 ${body.md.regular}`}>
              <li> {"Contains one Platform Merchant Account"->React.string} </li>
              <li> {"Onboard and manage multiple connected merchants"->React.string} </li>
              <li> {"Acts as the control layer for all connected merchants"->React.string} </li>
              <li> {"Generate and manage API keys"->React.string} </li>
              <li> {"Initiate payments on behalf of connected merchants"->React.string} </li>
              <li>
                {"Platform merchant holds permissions that standard merchants do not have"->React.string}
              </li>
            </ul>
          </div>
          <div className="flex flex-col gap-3">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}> {"Use Cases"->React.string} </p>
            <ul
              className={`list-disc list-inside text-nd_gray-600 flex flex-col gap-2 ${body.md.regular}`}>
              <li> {"Marketplaces managing multiple sellers"->React.string} </li>
              <li> {"SaaS platforms with serving businesses"->React.string} </li>
              <li> {"Payment facilitators (PayFacs)"->React.string} </li>
              <li> {"Franchise or multi-location businesses"->React.string} </li>
            </ul>
          </div>
          <HSwitchUtils.AlertBanner
            bannerContent={<p className={`${body.sm.regular}`}>
              {"Creating a new platform organization will set up a separate entity. Your existing organization will remain unchanged."->React.string}
            </p>}
            bannerType=Info
          />
        </div>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-2xl m-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}
