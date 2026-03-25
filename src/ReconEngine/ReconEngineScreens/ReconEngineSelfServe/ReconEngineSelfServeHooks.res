open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

let useCreateAccount = () => {
  open APIUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (req: accountCreateRequest) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#CREATE_ACCOUNT,
      )
      let body = req->encodeAccountCreateRequest
      let res = await updateDetails(url, body, Post)
      let dict = res->LogicUtils.getDictFromJsonObject
      let account: createdAccount = {
        account_id: dict->LogicUtils.getString("account_id", ""),
        account_name: dict->LogicUtils.getString("account_name", ""),
        account_type: dict->LogicUtils.getString("account_type", ""),
        currency: req.currency,
      }
      showToast(~message=`Account "${req.account_name}" created successfully`, ~toastType=ToastSuccess)
      Some(account)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to create account")
        showToast(~message=err, ~toastType=ToastError)
        None
      }
    }
  }
}

let useCreateIngestionConfig = () => {
  open APIUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (req: ingestionConfigCreateRequest) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#CREATE_INGESTION_CONFIG,
      )
      let body = req->encodeIngestionConfigCreateRequest
      let res = await updateDetails(url, body, Post)
      let dict = res->LogicUtils.getDictFromJsonObject
      let configType = switch req.config {
      | Manual => "Manual"
      | Adyen(_) => "Adyen"
      | SftpInternal(_) => "SFTP"
      }
      let ingestion: createdIngestion = {
        ingestion_id: dict->LogicUtils.getString("ingestion_id", ""),
        account_id: req.account_id,
        name: req.name,
        config_type: configType,
      }
      showToast(
        ~message=`Ingestion "${req.name}" created successfully`,
        ~toastType=ToastSuccess,
      )
      Some(ingestion)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to create ingestion config")
        showToast(~message=err, ~toastType=ToastError)
        None
      }
    }
  }
}

let useCreateTransformationConfig = () => {
  open APIUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (req: createTransformationConfigRequest) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#CREATE_TRANSFORMATION_CONFIG_V2,
      )
      let body = req->encodeCreateTransformationConfigRequest
      let res = await updateDetails(url, body, Post)
      let dict = res->LogicUtils.getDictFromJsonObject
      let metadataFieldNames =
        req.metadata_schema_data.fields.metadata_fields->Array.map(f => {
          // Extract the key from "metadata.xxx" -> "xxx"
          let parts = f.field_name->String.split(".")
          parts->Array.get(1)->Option.getOr(f.field_name)
        })
      let transformation: createdTransformation = {
        transformation_id: dict->LogicUtils.getString("transformation_id", ""),
        ingestion_id: req.ingestion_id,
        account_id: req.account_id,
        name: req.name,
        metadata_fields: metadataFieldNames,
      }
      showToast(
        ~message=`Transformation "${req.name}" created successfully`,
        ~toastType=ToastSuccess,
      )
      Some(transformation)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to create transformation config")
        showToast(~message=err, ~toastType=ToastError)
        None
      }
    }
  }
}

let useCreateReconRule = () => {
  open APIUtils

  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  async (req: reconRuleCreateRequest) => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Post,
        ~hyperswitchReconType=#CREATE_RECON_RULE,
      )
      let body = req->encodeReconRuleCreateRequest
      let res = await updateDetails(url, body, Post)
      let dict = res->LogicUtils.getDictFromJsonObject
      let ruleId = dict->LogicUtils.getString("rule_id", "")
      showToast(
        ~message=`Rule "${req.rule_name}" created successfully`,
        ~toastType=ToastSuccess,
      )
      Some(ruleId)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to create recon rule")
        showToast(~message=err, ~toastType=ToastError)
        None
      }
    }
  }
}
