open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

let useCreateAccount = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (~accountName: string, ~accountType: string, ~currency: string, ~initialBalance: float) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#ACCOUNTS_CREATE,
      )
      let body = encodeAccountCreate(~accountName, ~accountType, ~currency, ~initialBalance)
      let res = await updateMethod(url, body, Post)
      let accountId = res->getDictFromJsonObject->getString("account_id", "")
      let created: createdAccount = {
        account_id: accountId,
        account_name: accountName,
        account_type: accountType,
      }
      showToast(~message=`Account "${accountName}" created successfully`, ~toastType=ToastSuccess)
      Some(created)
    } catch {
    | Exn.Error(e) => {
        showToast(
          ~message=extractApiErrorMessage(e, ~fallback="Failed to create account"),
          ~toastType=ToastError,
        )
        None
      }
    }
  }
}

let useCreateIngestionConfig = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (
    ~merchantId: string,
    ~profileId: string,
    ~name: string,
    ~accountId: string,
    ~configVariant: ingestionConfigVariant,
    ~hmacSecret: string="",
    ~webhookUsername: string="",
    ~webhookPassword: string="",
    ~reportUsername: string="",
    ~reportPassword: string="",
    ~sftpFilePath: string="",
  ) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#INGESTION_CONFIG_CREATE,
      )
      let body = encodeIngestionConfigCreate(
        ~merchantId,
        ~profileId,
        ~name,
        ~accountId,
        ~configVariant,
        ~hmacSecret,
        ~webhookUsername,
        ~webhookPassword,
        ~reportUsername,
        ~reportPassword,
        ~sftpFilePath,
      )
      let res = await updateMethod(url, body, Post)
      let ingestionId = res->getDictFromJsonObject->getString("ingestion_id", "")
      let created: createdIngestion = {
        ingestion_id: ingestionId,
        account_id: accountId,
        name,
      }
      showToast(~message=`Data source "${name}" created successfully`, ~toastType=ToastSuccess)
      Some(created)
    } catch {
    | Exn.Error(e) => {
        showToast(
          ~message=extractApiErrorMessage(e, ~fallback="Failed to create data source"),
          ~toastType=ToastError,
        )
        None
      }
    }
  }
}

let useCreateTransformationConfig = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (~form: transformationFormState, ~merchantId: string, ~profileId: string) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG_CREATE,
      )
      let body = encodeTransformationConfigCreate(~form, ~merchantId, ~profileId)
      let res = await updateMethod(url, body, Post)
      let transformationId = res->getDictFromJsonObject->getString("transformation_id", "")
      let created: createdTransformation = {
        transformation_id: transformationId,
        account_id: form.accountId,
        ingestion_id: form.ingestionId,
        name: form.name,
        metadataFieldNames: form.metadataFields->Array.map(f => f.fieldName),
      }
      showToast(
        ~message=`Column mapping "${form.name}" created successfully`,
        ~toastType=ToastSuccess,
      )
      Some(created)
    } catch {
    | Exn.Error(e) => {
        showToast(
          ~message=extractApiErrorMessage(e, ~fallback="Failed to create column mapping"),
          ~toastType=ToastError,
        )
        None
      }
    }
  }
}

let useCreateReconRule = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (~form: ruleFormState) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#RECON_RULES_CREATE,
      )
      let body = encodeReconRuleCreate(form)
      let res = await updateMethod(url, body, Post)
      let ruleId = res->getDictFromJsonObject->getString("rule_id", "")
      let created: createdRule = {
        rule_id: ruleId,
        rule_name: form.ruleName,
      }
      showToast(
        ~message=`Recon rule "${form.ruleName}" created successfully`,
        ~toastType=ToastSuccess,
      )
      Some(created)
    } catch {
    | Exn.Error(e) => {
        showToast(
          ~message=extractApiErrorMessage(e, ~fallback="Failed to create recon rule"),
          ~toastType=ToastError,
        )
        None
      }
    }
  }
}
