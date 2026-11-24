type presetSelection = {
  startKey: string,
  endKey: string,
  preset: string,
  startTime: string,
  endTime: string,
}

type rollingPreset =
  | LastHours(float)
  | LastDays(float)
  | SinceMidnight(int)
  | ThisMonth
  | LastSixMonths
