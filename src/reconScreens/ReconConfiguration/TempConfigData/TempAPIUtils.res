open LogicUtils
open FormDataUtils

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

let baseFileUploadAPI = (
  ~fileUploadedDict: option<RescriptCore.Dict.t<Core__JSON.t>>,
  ~merchantId,
) => {
  let url = `http://localhost:8000/fileUploader/file/upload/uploadBaseFile`
  switch fileUploadedDict {
  | None => Exn.raiseError("Please upload a file")
  | Some(fileUploadedDict) => {
      let fileValue =
        fileUploadedDict
        ->getJsonObjectFromDict("basefile")
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("uploadedFile")

      let metaDict = Dict.make()
      metaDict->Dict.set(
        "file_dates",
        JSON.Encode.array(["2025-01-13"]->Array.map(JSON.Encode.string)),
      )
      metaDict->Dict.set("mid", JSON.Encode.array([merchantId]->Array.map(JSON.Encode.string)))
      metaDict->Dict.set("token", JSON.Encode.string(""))
      let formData = formData()
      append(formData, "file1", fileValue)
      append(formData, "meta", metaDict->JSON.Encode.object->JSON.stringify)
      (url, formData)
    }
  }
}

let pspFileUploadAPI = (
  ~fileUploadedDict: option<RescriptCore.Dict.t<Core__JSON.t>>,
  ~merchantId,
  ~pspType,
) => {
  let url = `http://localhost:8000/fileUploader/file/upload/uploadPSPFile`
  switch fileUploadedDict {
  | None => Exn.raiseError("Please upload a file")
  | Some(fileUploadedDict) => {
      let fileValue =
        fileUploadedDict
        ->getJsonObjectFromDict("pspfile")
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("uploadedFile")

      let metaDict = Dict.make()
      metaDict->Dict.set(
        "file_dates",
        JSON.Encode.array(["2025-01-13"]->Array.map(JSON.Encode.string)),
      )
      metaDict->Dict.set("mid", JSON.Encode.array([merchantId]->Array.map(JSON.Encode.string)))
      metaDict->Dict.set("token", JSON.Encode.string(""))
      metaDict->Dict.set("gateways", JSON.Encode.array([pspType]->Array.map(JSON.Encode.string)))
      let formData = formData()
      append(formData, "file1", fileValue)
      append(formData, "meta", metaDict->JSON.Encode.object->JSON.stringify)
      (url, formData)
    }
  }
}

let reconConfigAPI = (~base, ~connectionId, ~source, ~pspType) => {
  let url = `http://localhost:8000/recon-rest-api/recon/v1/configs/create?config_name=&system_a=${base}&config_type=recon&system_b=${pspType}`
  let body = {
    "connection_id": connectionId,
    "source": source,
    "base": base,
    "psp": pspType,
    "configs": ConfigUtils.reconConfig(base, pspType),
  }->Identity.genericTypeToJson

  (url, body)
}

let transformBaseFileAPI = (~merchantId) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/process_info`
  let body = {
    "entity": merchantId,
    "payment_entity": null,
    "sub_entity": null,
    "payment_sub_entity": null,
    "process_type": "BASE",
    "process_metadata": ConfigUtils.baseProcessMetadata,
  }->Identity.genericTypeToJson
  (url, body)
}

let transformPSPFileAPI = (~merchantId, ~paymentEntity) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/process_info`
  let body = {
    "entity": merchantId,
    "payment_entity": paymentEntity,
    "sub_entity": null,
    "payment_sub_entity": null,
    "process_type": "PSP",
    "process_metadata": ConfigUtils.baseProcessMetadata,
  }->Identity.genericTypeToJson
  (url, body)
}

let approveBaseConfigAPI = (~merchantId, ~configUUID) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/approve/configuration`
  let body = {
    "config_uuid": configUUID,
    "is_approved": true,
    "is_active": true,
    "approved_by": "",
    "merchant_id": merchantId,
    "config_type": "BASE",
  }->Identity.genericTypeToJson
  (url, body)
}

let approvePSPConfigAPI = (~merchantId, ~configUUID) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/approve/configuration`
  let body = {
    "config_uuid": configUUID,
    "is_approved": true,
    "is_active": true,
    "approved_by": "",
    "merchant_id": merchantId,
    "config_type": "PSP",
  }->Identity.genericTypeToJson
  (url, body)
}

let getConfigUUIDAPI = (~merchantId) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/configuration/list?merchant_id=${merchantId}&limit=50&offset=0`
  url
}

let useStepConfig = (
  ~step: ReconConfigurationTypes.subSections,
  ~fileUploadedDict: option<Dict.t<Core__JSON.t>>=?,
) => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let getAPIHook = useGetMethod(~showErrorToast=false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let getConfigUUID = res => {
    let arrayFromJson = res->getDictFromJsonObject->Dict.get("data")

    switch arrayFromJson {
    | Some(data) =>
      switch Js.Json.classify(data) {
      | Js.Json.JSONArray(dataArray) =>
        switch dataArray->Array.get(0) {
        | Some(firstElement) =>
          switch firstElement->getDictFromJsonObject->Dict.get("config_uuid") {
          | Some(configUUID) => configUUID->Js.Json.decodeString
          | None => Exn.raiseError("Failed to get configUUID from the first element")
          }
        | None => Exn.raiseError("No elements in the 'data' array")
        }
      | _ => Exn.raiseError("'data' is not an array")
      }
    | None => Exn.raiseError("Failed to get 'data' from the response")
    }
  }

  async _ => {
    try {
      switch step {
      | SelectSource => {
          let (reportUrl, reportBody) = reportConfigAPI(
            ~configName="Hyperswitch",
            ~base=merchantId,
            ~connectionId="JP_RECON",
            ~source="SFTP",
          )
          let _ = await updateAPIHook(reportUrl, reportBody, Post)
          // Below API should return the configUUID to approve the base config
          let (baseUrl, baseBody) = baseConfigAPI(~merchantId, ~userName="")
          let _ = await updateAPIHook(baseUrl, baseBody, Post)

          let listAPI = getConfigUUIDAPI(~merchantId)
          let res = await getAPIHook(listAPI)
          let configUUID = getConfigUUID(res)
          let (approveBaseConfigUrl, approveBaseConfigBody) = approveBaseConfigAPI(
            ~merchantId,
            ~configUUID,
          )
          let _ = await updateAPIHook(approveBaseConfigUrl, approveBaseConfigBody, Put)
        }
      | SetupAPIConnection => {
          let (url, formData) = baseFileUploadAPI(~fileUploadedDict, ~merchantId)
          let (transformBaseFileUrl, transformBaseFileBody) = transformBaseFileAPI(~merchantId)

          let _ = await updateAPIHook(
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            url,
            Dict.make()->JSON.Encode.object,
            Post,
            ~contentType=AuthHooks.Unknown,
          )
          let _ = await updateAPIHook(transformBaseFileUrl, transformBaseFileBody, Post)
        }
      | APIKeysAndLiveEndpoints => {
          let (pspUrl, pspBody) = pspConfigAPI(~merchantId, ~paymentEntity="PAYU")
          let _ = await updateAPIHook(pspUrl, pspBody, Post)

          let listAPI = getConfigUUIDAPI(~merchantId)
          let res = await getAPIHook(listAPI)
          let configUUID = getConfigUUID(res)
          let (approvePSPConfigUrl, approvePSPConfigBody) = approvePSPConfigAPI(
            ~merchantId,
            ~configUUID,
          )

          let _ = await updateAPIHook(approvePSPConfigUrl, approvePSPConfigBody, Put)
        }
      | WebHooks => {
          let (url, formData) = pspFileUploadAPI(~fileUploadedDict, ~merchantId, ~pspType="PAYU")
          let (transformPSPFileUrl, transformPSPFileBody) = transformPSPFileAPI(
            ~merchantId,
            ~paymentEntity="PAYU",
          )
          let _ = await updateAPIHook(
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            url,
            Dict.make()->JSON.Encode.object,
            Post,
            ~contentType=AuthHooks.Unknown,
          )
          let _ = await updateAPIHook(transformPSPFileUrl, transformPSPFileBody, Post)
        }
      | TestLivePayment => {
          let (reconUrl, reconBody) = reconConfigAPI(
            ~base=merchantId,
            ~connectionId="JP_RECON",
            ~source="SFTP",
            ~pspType="PAYU",
          )
          let _ = await updateAPIHook(reconUrl, reconBody, Post)
        }
      | _ => Exn.raiseError("Something went wrong")
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update!")
        Exn.raiseError(err)
      }
    | _ => Exn.raiseError("Something went wrong")
    }
  }
}
