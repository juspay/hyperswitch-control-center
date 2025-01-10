let reportConfigAPI = (~configName, ~base, ~connectionId, ~source) => {
  let url = `https://sandbox.hyperswitch.io/recon-rest-api/recon/v1/configs/create?config_name=${configName}&system_a=${base}&config_type=reports`
  let body = {
    "connection_id": connectionId,
    "source": source,
    "base": base,
    "config_name": configName,
    "configs": ConfigUtils.reportConfig,
  }->Identity.genericTypeToJson
  (url, body)
}

let baseConfigAPI = async (~userName, ~merchantId) => {
  let url = `https://sandbox.hyperswitch.io/recon-settlement-api/recon/settlements/v1/create/configuration`
  let body = {
    "username": userName,
    "merchant_id": merchantId,
    "payment_entity": null,
    "sub_entity": null,
    "payment_sub_entity": null,
    "settlement_entity": null,
    "config_type": "BASE",
    "config": ConfigUtils.baseHyperswitchConfig(merchantId),
  }->Identity.genericTypeToJson
}

let pspConfigAPI = async (~merchantId, ~paymentEntity) => {
  let url = `https://sandbox.hyperswitch.io/recon-settlement-api/recon/settlements/v1/create/configuration`
  let body = {
    "username": "",
    "merchant_id": merchantId,
    "payment_entity": paymentEntity,
    "sub_entity": null,
    "payment_sub_entity": null,
    "settlement_entity": null,
    "config_type": "PSP",
    "config": ConfigUtils.pspConfig(merchantId, "PAYU"),
  }->Identity.genericTypeToJson
}

// let confirmAPI = async () => {}

// let step1Config = async () => {}

let useStepConfig = () => {
  open APIUtils
  //   open CommonAuthHooks
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  //   let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

  async _ => {
    try {
      let (url, body) = reportConfigAPI(
        ~configName="Hyperswitch",
        ~base="BASE",
        ~connectionId="JP_RECON",
        ~source="SFTP",
      )
      let _ = await updateAPIHook(url, body, Post)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
