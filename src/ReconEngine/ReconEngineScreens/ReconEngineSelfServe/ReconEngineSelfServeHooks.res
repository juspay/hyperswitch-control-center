open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

let useCreateAccount = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (~accountName: string, ~accountType: string, ~currency: string, ~initialBalance: float) => {
    if accountName->String.trim->String.length === 0 {
      showToast(~message="Account name is required", ~toastType=ToastError)
      None
    } else {
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
          let err = Exn.message(e)->Option.getOr("Failed to create account")
          showToast(~message=err, ~toastType=ToastError)
          None
        }
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
  ) => {
    if name->String.trim->String.length === 0 || accountId->String.trim->String.length === 0 {
      showToast(~message="Ingestion name and account are required", ~toastType=ToastError)
      None
    } else {
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
          let err = Exn.message(e)->Option.getOr("Failed to create data source")
          showToast(~message=err, ~toastType=ToastError)
          None
        }
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
    if (
      form.name->String.trim->String.length === 0 ||
      form.accountId->String.length === 0 ||
      form.ingestionId->String.length === 0
    ) {
      showToast(~message="Name, account, and ingestion source are required", ~toastType=ToastError)
      None
    } else if (
      form.currencyIdentifier->String.trim->String.length === 0 ||
      form.amountIdentifier->String.trim->String.length === 0 ||
      form.effectiveAtIdentifier->String.trim->String.length === 0 ||
      form.orderIdIdentifier->String.trim->String.length === 0 ||
      form.balanceDirectionIdentifier->String.trim->String.length === 0
    ) {
      showToast(
        ~message="All column mappings are required (currency, amount, date, order ID, balance direction)",
        ~toastType=ToastError,
      )
      None
    } else {
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
        }
        showToast(
          ~message=`Column mapping "${form.name}" created successfully`,
          ~toastType=ToastSuccess,
        )
        Some(created)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Failed to create column mapping")
          showToast(~message=err, ~toastType=ToastError)
          None
        }
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
    if (
      form.ruleName->String.trim->String.length === 0 ||
      form.sourceAccountId->String.length === 0 ||
      form.targetAccountId->String.length === 0
    ) {
      showToast(
        ~message="Rule name, source account, and target account are required",
        ~toastType=ToastError,
      )
      None
    } else if form.triggerValue->String.trim->String.length === 0 {
      showToast(~message="Trigger value is required", ~toastType=ToastError)
      None
    } else {
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
          let err = Exn.message(e)->Option.getOr("Failed to create recon rule")
          showToast(~message=err, ~toastType=ToastError)
          None
        }
      }
    }
  }
}
