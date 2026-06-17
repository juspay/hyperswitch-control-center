type reconStatusType =
  | Running
  | Stopped

type reconStatusResponse = {status: reconStatusType}
