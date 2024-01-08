open AnalyticsTypesUtils

type filterConfig = {
  source: string, // source can be BATCH, KVLOGS basically which DB to fetch
  modeValue: string, // modeValue can be ORDERS, TXN so here is the mode is orders we see data aggregated by the order_id and if mode is txn the data is aggregated by txn id simmilarly more mode can be added
  filterValues?: Js.Json.t, // which all filters will be applicable for the single stats (those keys i.e merchant_id, payment_gateway etc.)
  startTime: string, // start time from when data will fetch   (later can be moved to the parent level)
  endTime: string, // end time till when data should be fetched (later can be moved to the parent level)
  customFilterValue: string, // custome filter key is the key by which stores the value of the applied customfilter in the url
  granularity?: (int, string),
}

type dataFetcherObj<'a> = {
  metrics: 'a, // metrics are the stats i.e total volume, success rate etc.
  bodyMaker: (string, filterConfig) => string, // to make the single stat body
  timeSeriedBodyMaker: (string, filterConfig) => string, // to make the single stat timeseries body
  transaformer: (string, Js.Json.t) => Dict.t<Js.Json.t>, // just in case if we are getting data from multiple places and we wanted to change the key or something so that we can identify it differently
  url: string, // url from where data need to be fetched
  domain: string,
  timeColumn: string,
}
type singleStatDataWidgetData = {
  title: string, // title of the single stat
  tooltipText: string, // tooltip of the single stat
  // deltaTooltipComponent: string => React.element, // delta tooltip hover compoment of the single stat
  statType: AnalyticsTypesUtils.metricsType, // wheather the metric which we are showing  is a Rate, Volume, Latency
  showDelta: bool, // wheather to show the delta or not
}

type singleStatEntity<'a> = {
  dataFetcherObj: array<dataFetcherObj<'a>>,
  source: string, // from which source data has to be fetched
  modeKey: string, // the key of mode dropdown i.e by order mode or by txn mode
  filterKeys: array<string>, // filter keys the keys of filter which is stored in the url
  startTimeFilterKey: string, // end time filter key which we store in url(can be moved to parent level)
  endTimeFilterKey: string, // end time filter key which we store in url (can be moved to parent level)
  moduleName: string, // just the string module name which should be same across one module (later can be moved to the parent level)
  customFilterKey: string, // customFilterKey the key which is used in url for the customfilter
  metrixMapper: 'a => string, // it will map the current key with the the key which get from the api
  getStatDetails: (
    'a,
    'a => string,
    dataState<Js.Json.t>,
    dataState<Js.Json.t>,
    dataState<Js.Json.t>,
  ) => singleStatDataWidgetData,
  jsonTransformer?: (string, array<Js.Json.t>) => array<Js.Json.t>,
}
