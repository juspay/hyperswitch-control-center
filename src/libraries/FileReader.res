type arg = ReactEvent.Form.t

type file

type read = {
  mutable onload: arg => unit,
  readAsText: (. string) => unit,
  readAsBinaryString: (. string) => unit,
  readAsDataURL: (. file) => unit,
  result: string,
  onerror: string => unit,
}

@new external reader: read = "FileReader"
