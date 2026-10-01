open MonitoringTypes
open LogicUtils

let useGrafanaSession = () => {
  let getURL = APIUtils.useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()

  async (~destination) => {
    let url = getURL(
      ~entityName=V1(MONITORING_SESSION),
      ~methodType=Post,
      ~id=Some(destination->MonitoringUtils.getId),
    )
    let response = await fetchApi(url, ~method_=Post, ~forceCookies=true, ~xFeatureRoute=false)
    switch response->Fetch.Response.status {
    | 200 =>
      let json = await response->Fetch.Response.json
      Ready(json->getDictFromJsonObject->getString("embed_url", ""))
    | 401 => Failed("Unable to authenticate Monitoring.")
    | 403 => Failed("You do not have access to Monitoring.")
    | 404 => Failed("This monitoring view has not been configured yet.")
    | _ => Failed("Monitoring is temporarily unavailable.")
    }
  }
}
