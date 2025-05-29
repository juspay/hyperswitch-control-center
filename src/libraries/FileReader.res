type arg = ReactEvent.Form.t

type file

type read = {
  mutable onload: arg => unit,
  readAsText: string => unit,
  readAsBinaryString: string => unit,
  readAsArrayBuffer: file => unit,
  readAsDataURL: file => unit,
  result: string,
  mutable onerror: string => unit,
}

@new external reader: read = "FileReader"

@new
external makeUint8Array: Js.TypedArray2.ArrayBuffer.t => Js.TypedArray2.Uint8Array.t = "Uint8Array"
