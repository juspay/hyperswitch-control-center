let reportConfigAPI = (~configName, ~base, ~connectionId, ~source) => {
  let url = `http://localhost:8000/recon-rest-api/recon/v1/configs/create?config_name=${configName}&system_a=${base}&config_type=reports`
  let body = {
    "connection_id": connectionId,
    "source": source,
    "base": base,
    "config_name": configName,
    "configs": ConfigUtils.reportConfig,
  }->Identity.genericTypeToJson

  (url, body)
}

let baseConfigAPI = (~userName, ~merchantId) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/create/configuration`
  let body = {
    "username": userName,
    "merchant_id": merchantId,
    "config_type": "BASE",
    "config": ConfigUtils.baseHyperswitchConfig(merchantId),
  }->Identity.genericTypeToJson

  (url, body)
}

let pspConfigAPI = (~merchantId, ~paymentEntity) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/create/configuration`
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
  (url, body)
}

let useStepConfig = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let _getAPIHook = useGetMethod(~showErrorToast=false)

  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  async _ => {
    try {
      let (url, body) = reportConfigAPI(
        ~configName="Hyperswitch",
        ~base=merchantId,
        ~connectionId="JP_RECON",
        ~source="SFTP",
      )

      let (baseUrl, baseBody) = baseConfigAPI(~merchantId, ~userName="")
      let (pspUrl, pspBody) = pspConfigAPI(~merchantId, ~paymentEntity="FIUU")

      let _ = await updateAPIHook(url, body, Post)

      let _ = await updateAPIHook(baseUrl, baseBody, Post)
      let _ = await updateAPIHook(pspUrl, pspBody, Post)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
