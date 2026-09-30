open MonitoringTypes
open LogicUtils

let statusToState = (status, embedUrl) =>
  switch status {
  | 200 => Ready(embedUrl)
  | 401 => Failed("Your session has expired. Please sign in again.", false)
  | 403 => Failed("You do not have access to Monitoring.", false)
  | 404 => Failed("This monitoring view has not been configured yet.", true)
  | _ => Failed("Monitoring is temporarily unavailable. Please try again.", true)
  }

let useGrafanaDocument = () => {
  let {setAuthStateToLogout} = React.useContext(AuthInfoProvider.authStatusContext)
  async (~embedUrl, ~signal) => {
    // A frame load event also fires for error pages. Probe HTTP status using only the cookie.
    let response = await Fetch.fetchWithInit(
      embedUrl,
      Fetch.RequestInit.make(
        ~method_=Get,
        ~credentials=SameOrigin,
        ~cache=NoStore,
        ~redirect=Error,
        ~signal,
      ),
    )
    let status = response->Fetch.Response.status
    if status === 401 {
      setAuthStateToLogout()
      AuthUtils.redirectToLogin()
    }
    statusToState(status, embedUrl)
  }
}

let useGrafanaSession = () => {
  let getURL = APIUtils.useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()
  let checkDocument = useGrafanaDocument()

  async (~destination, ~signal) => {
    let url = getURL(
      ~entityName=V1(MONITORING),
      ~methodType=Post,
      ~id=Some(destination->MonitoringUtils.getId),
    )
    let response = await fetchApi(
      url,
      ~method_=Post,
      ~omitBody=true,
      ~forceCookies=true,
      ~xFeatureRoute=false,
      ~signal,
    )
    switch response->Fetch.Response.status {
    | 200 =>
      let json = await response->Fetch.Response.json
      let embedUrl = json->getDictFromJsonObject->getString("embed_url", "")
      switch MonitoringUtils.getEmbedUrl(~embedUrl, ~theme="light") {
      | Some(url) =>
        let result = await checkDocument(~embedUrl=url, ~signal)
        switch result {
        | Ready(_) => Ready(embedUrl)
        | _ => result
        }
      | None => Failed("Monitoring returned a URL outside the approved gateway.", true)
      }
    | status => statusToState(status, "")
    }
  }
}
