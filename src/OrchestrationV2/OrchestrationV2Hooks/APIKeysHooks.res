open APIUtils

let useGetApiKeysHook = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  async () => {
    try {
      let url = getURL(~entityName=V2(V2_API_KEYS), ~methodType=Get)
      await fetchDetails(url)
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
      await updateDetails(url, payload, Delete)
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
      await updateDetails(url, payload, Post)
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
      await updateDetails(url, payload, Put)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to update API Key!")
        Exn.raiseError(err)
      }
    }
  }
}
