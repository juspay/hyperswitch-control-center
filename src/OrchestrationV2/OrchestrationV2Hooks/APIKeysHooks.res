open APIUtils

let useGetApiKeysHook = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async () => {
    try {
      let url = getURL(~entityName=V2(V2_API_KEYS), ~methodType=Get)
      let res = await fetchDetails(url)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch API Keys list!")
        Exn.raiseError(err)
      }
    }
  }
}

let useDeleteApiKeyHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~apiKeyId, ~payload) => {
    try {
      let url = getURL(~entityName=V2(V2_API_KEYS), ~methodType=Delete, ~id=Some(apiKeyId))
      let res = await updateDetails(url, payload, Delete)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to delete API Key!")
        Exn.raiseError(err)
      }
    }
  }
}

let useCreateApiKeyHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~payload) => {
    try {
      let url = getURL(~entityName=V2(V2_API_KEYS), ~methodType=Post)
      Js.log2("url in api hooks create api", url)
      let res = await updateDetails(url, payload, Post)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to create API Key!")
        Exn.raiseError(err)
      }
    }
  }
}

let useUpdateApiKeyHook = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  async (~payload, ~apiKeyId=None) => {
    try {
      let url = getURL(~entityName=V2(V2_API_KEYS), ~methodType=Put, ~id=apiKeyId)
      let res = await updateDetails(url, payload, Put)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update API Key!")
        Exn.raiseError(err)
      }
    }
  }
}
