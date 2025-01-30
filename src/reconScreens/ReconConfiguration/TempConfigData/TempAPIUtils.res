open LogicUtils
open FormDataUtils

let date = ConfigUtils.getTodayDate()
let tomorrow = ConfigUtils.getTomorrowDate()

let reportConfigAPI = (
  ~configName: string,
  ~base: string,
  ~connectionId: string,
  ~source: string,
) => {
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

let baseConfigAPI = (~userName: string, ~merchantId: string) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/create/configuration`
  let body = {
    "username": userName,
    "merchant_id": merchantId,
    "payment_entity": "null",
    "sub_entity": "NULL",
    "payment_sub_entity": "NULL",
    "settlement_entity": "NULL",
    "config_type": "BASE",
    "config": ConfigUtils.baseFIUUConfig(merchantId),
  }->Identity.genericTypeToJson

  (url, body)
}

let pspConfigAPI = (~merchantId: string, ~paymentEntity: option<string>) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/create/configuration`
  switch paymentEntity {
  | None => Exn.raiseError("Please provide paymentEntity")
  | Some(paymentEntity) => {
      let body = {
        "username": "",
        "merchant_id": merchantId,
        "payment_entity": paymentEntity,
        "sub_entity": "NULL",
        "payment_sub_entity": "NULL",
        "settlement_entity": "NULL",
        "config_type": "PSP",
        "config": ConfigUtils.pspConfig(merchantId, paymentEntity),
      }->Identity.genericTypeToJson
      (url, body)
    }
  }
}

let baseFileUploadAPI = (
  ~fileUploadedDict: option<RescriptCore.Dict.t<Core__JSON.t>>,
  ~merchantId: string,
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
      metaDict->Dict.set("file_dates", JSON.Encode.array([date]->Array.map(JSON.Encode.string)))
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
  ~merchantId: string,
  ~pspType: option<string>,
) => {
  let url = `http://localhost:8000/fileUploader/file/upload/uploadPSPFile`
  switch fileUploadedDict {
  | None => Exn.raiseError("Please upload a file")
  | Some(fileUploadedDict) =>
    switch pspType {
    | None => Exn.raiseError("Please provide pspType")
    | Some(pspType) => {
        let fileValue =
          fileUploadedDict
          ->getJsonObjectFromDict("pspfile")
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("uploadedFile")

        let metaDict = Dict.make()
        metaDict->Dict.set("file_dates", JSON.Encode.array([date]->Array.map(JSON.Encode.string)))
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
}

let reconConfigAPI = (
  ~base: string,
  ~connectionId: string,
  ~source: string,
  ~pspType: option<string>,
) => {
  switch pspType {
  | None => Exn.raiseError("Please provide pspType")
  | Some(pspType) => {
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
  }
}

let transformBaseFileAPI = (~merchantId: string) => {
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

let transformPSPFileAPI = (~merchantId: string, ~paymentEntity: option<string>) => {
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

let approveBaseConfigAPI = (~merchantId: string, ~configUUID: option<string>) => {
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

let approvePSPConfigAPI = (~merchantId: string, ~configUUID: option<string>) => {
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

let getFileUUIDAPI = (~merchantId: string, ~fileType: string) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/run/files?limit=1&offset=0&start_date=${date}T00:00:00&end_date=${tomorrow}T00:00:00&merchant_id=${merchantId}&file_type=${fileType}`
  url
}

let runReconAPI = (
  ~merchantId: string,
  ~pspType: option<string>,
  ~baseFileUUID: option<string>,
  ~pspFileUUID: option<string>,
) => {
  let url = `http://localhost:8000/recon-settlement-api/recon/settlements/v1/runrecon`
  let body = {
    "system_a_name": merchantId,
    "system_a_uuid": [baseFileUUID],
    "system_b_name": pspType,
    "system_b_uuid": [pspFileUUID],
    "recon_started_by": "",
    "processing_date": date,
  }->Identity.genericTypeToJson
  (url, body)
}

let useStepConfig = (
  ~step: ReconConfigurationTypes.subSections,
  ~fileUploadedDict: option<Dict.t<Core__JSON.t>>=?,
  ~paymentEntity: option<string>=?,
) => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let getAPIHook = useGetMethod(~showErrorToast=false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let getUUID = (res, field: string) => {
    let arrayFromJson = res->getDictFromJsonObject->Dict.get("data")

    switch arrayFromJson {
    | Some(data) =>
      switch Js.Json.classify(data) {
      | Js.Json.JSONArray(dataArray) =>
        switch dataArray->Array.get(0) {
        | Some(firstElement) =>
          switch firstElement->getDictFromJsonObject->Dict.get(field) {
          | Some(uuid) => uuid->Js.Json.decodeString
          | None => Exn.raiseError("Failed to get uuid from the first element")
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
          let configUUID = getUUID(res, "config_uuid")
          let (approveBaseConfigUrl, approveBaseConfigBody) = approveBaseConfigAPI(
            ~merchantId,
            ~configUUID,
          )
          let _ = await updateAPIHook(approveBaseConfigUrl, approveBaseConfigBody, Put)
        }
      | SetupAPIConnection => {
          let (url, formData) = baseFileUploadAPI(~fileUploadedDict, ~merchantId)
          let (transformBaseFileUrl, transformBaseFileBody) = transformBaseFileAPI(~merchantId)

          let _ = await updateAPIHook(transformBaseFileUrl, transformBaseFileBody, Post)
          let _ = await updateAPIHook(
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            url,
            Dict.make()->JSON.Encode.object,
            Post,
            ~contentType=AuthHooks.Unknown,
          )
        }
      | APIKeysAndLiveEndpoints => {
          let (pspUrl, pspBody) = pspConfigAPI(~merchantId, ~paymentEntity)
          let _ = await updateAPIHook(pspUrl, pspBody, Post)

          let listAPI = getConfigUUIDAPI(~merchantId)
          let res = await getAPIHook(listAPI)
          let configUUID = getUUID(res, "config_uuid")
          let (approvePSPConfigUrl, approvePSPConfigBody) = approvePSPConfigAPI(
            ~merchantId,
            ~configUUID,
          )

          let _ = await updateAPIHook(approvePSPConfigUrl, approvePSPConfigBody, Put)
        }
      | WebHooks => {
          let (url, formData) = pspFileUploadAPI(
            ~fileUploadedDict,
            ~merchantId,
            ~pspType=paymentEntity,
          )
          let (transformPSPFileUrl, transformPSPFileBody) = transformPSPFileAPI(
            ~merchantId,
            ~paymentEntity,
          )

          let _ = await updateAPIHook(transformPSPFileUrl, transformPSPFileBody, Post)
          let _ = await updateAPIHook(
            ~bodyFormData=formData,
            ~headers=Dict.make(),
            url,
            Dict.make()->JSON.Encode.object,
            Post,
            ~contentType=AuthHooks.Unknown,
          )
        }
      | TestLivePayment => {
          let (reconUrl, reconBody) = reconConfigAPI(
            ~base=merchantId,
            ~connectionId="JP_RECON",
            ~source="SFTP",
            ~pspType=paymentEntity,
          )
          let _ = await updateAPIHook(reconUrl, reconBody, Post)

          let baseFileList = getFileUUIDAPI(~merchantId, ~fileType="BASE")
          let baseFileRes = await getAPIHook(baseFileList)
          let pspFileList = getFileUUIDAPI(~merchantId, ~fileType="PSP")
          let pspFileRes = await getAPIHook(pspFileList)

          let baseFileUUID = getUUID(baseFileRes, "file_uuid")
          let pspFileUUID = getUUID(pspFileRes, "file_uuid")

          let (runReconUrl, runReconBody) = runReconAPI(
            ~merchantId,
            ~pspType=paymentEntity,
            ~baseFileUUID,
            ~pspFileUUID,
          )
          let _ = await updateAPIHook(runReconUrl, runReconBody, Post)
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
