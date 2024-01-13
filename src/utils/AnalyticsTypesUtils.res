type dataState<'a> = Loaded('a) | Loading | LoadedError
type metricsType =
  | Latency
  | Volume
  | Rate
  | Amount
  | NegativeRate

type timeObj = {
  apiStartTime: float,
  apiEndTime: float,
}
