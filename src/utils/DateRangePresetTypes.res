// The preset that produced a date filter's current values, stored per `startKey:endKey`
type presetSelection = {
  startKey: string,
  endKey: string,
  preset: string,
  startTime: string,
  endTime: string,
}

// Presets whose range ends at "now", so a list refresh can recompute them
type rollingPreset =
  | LastHours(float)
  | LastDays(float) // calendar days back, keeping the wall-clock time
  | SinceMidnight(int) // local midnight N days ago, up to now
  | ThisMonth
  | LastSixMonths
