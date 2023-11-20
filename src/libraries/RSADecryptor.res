@new external newArrayBuffer: int => Window.ArrayBuffer.t = "ArrayBuffer"
@new external newUint8Array: Window.ArrayBuffer.t => array<float> = "Uint8Array"

let str2ab = str => {
  let buf = newArrayBuffer(str->Js.String2.length)
  let bufView = newUint8Array(buf)

  str
  ->Js.String2.split("")
  ->Js.Array2.forEachi((_char, i) => {
    bufView[i] = str->Js.String2.charCodeAt(i)
  })

  buf
}

let arrayBufferToString = %raw(`function arrayBufferToString(buffer) {
  var arr = new Uint8Array(buffer);
  var str = String.fromCharCode.apply(String, arr);
  if (/[\u0080-\uffff]/.test(str)) {
    throw new Error("this string seems to contain (still encoded) multibytes");
  }
  return str;
}`)

@val
external atob: string => string = "atob"

let importPrivateKey = pem => {
  let pemHeader = "-----BEGIN PRIVATE KEY-----"
  let pemFooter = "-----END PRIVATE KEY-----"
  let pemContents =
    pem->Js.String2.substring(
      ~from=pemHeader->Js.String2.length,
      ~to_=pem->Js.String2.length - pemFooter->Js.String2.length,
    )
  let binaryDerString = atob(pemContents)
  let binaryDer = str2ab(binaryDerString)
  try {
    Window.Crypto.Subtle.importKey(
      "pkcs8",
      binaryDer,
      {
        "name": "RSA-OAEP",
        "hash": "SHA-1",
      },
      false,
      ["decrypt"],
    )
  } catch {
  | ex =>
    Js.Console.error2("111", ex)
    Promise.reject(ex)
  }
}

let decrypt = (privateKey, encrypted) => {
  importPrivateKey(privateKey)->Promise.then(key => {
    let binaryDerStringr = atob(encrypted)
    let binaryDerr = str2ab(binaryDerStringr)
    try {
      Window.Crypto.Subtle.decrypt(
        {
          "name": "RSA-OAEP",
        },
        key,
        binaryDerr,
      )
    } catch {
    | ex =>
      Js.Console.error2("Error1:  ", ex)
      Promise.reject(ex)
    }
  })
}
