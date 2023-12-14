open Promise
type encKeyProp = {
  modulusLength: int,
  extractable: bool,
}

type encodedString
type decodedString

type key
type localStorage = {
  getItem: (. string) => Js.Nullable.t<string>,
  setItem: (. string, string) => unit,
}
@val
external localStorage: localStorage = "localStorage"
module CompactSign = {
  type compactSign
  type algo = {
    alg: string,
    kid: string,
  }

  @new @module("jose")
  external newCompactSign: 'a => compactSign = "CompactSign"

  @send
  external setProtectedHeader: (compactSign, algo) => compactSign = "setProtectedHeader"

  @send
  external sign: (compactSign, key) => string = "sign"
}

module CompactEncrypt = {
  type compactEncrypt
  type algo = {
    enc: string,
    alg: string,
    kid: string,
  }

  @new @module("jose")
  external newCompactEncrypt: encodedString => compactEncrypt = "CompactEncrypt"

  @send
  external setProtectedHeader: (compactEncrypt, algo) => compactEncrypt = "setProtectedHeader"

  @send
  external encrypt: (compactEncrypt, key) => string = "encrypt"
}

module TextEncoder = {
  type encoder
  @new
  external newTextEncoder: unit => encoder = "TextEncoder"

  @send
  external encode: (encoder, string) => encodedString = "encode"
}

module TextDecoder = {
  type decoder
  @new
  external newTextDecoder: unit => decoder = "TextDecoder"

  @send
  external decode: (decoder, Js.Json.t) => string = "decode"
}

@module("jose")
external generateKeyPairs: 'a = "generateKeyPair"
@module("jose") external exportPKCS8: 'a => Js.Promise.t<'a> = "exportPKCS8"
@module("jose") external exportSPKI: 'a => Js.Promise.t<'a> = "exportSPKI"
@module("jose") external importSPKI: ('a, string) => Js.Promise.t<key> = "importSPKI"
@module("jose") external importPKCS8: ('a, string) => Js.Promise.t<key> = "importPKCS8"
@module("jose") external compactDecrypt: ('a, key) => Js.Promise.t<Js.Json.t> = "compactDecrypt"
@module("jose") external compactVerify: ('a, key) => Js.Promise.t<bool> = "compactVerify"

let getKey = keyType => {
  switch LocalStorage.getItem(keyType)->Js.Nullable.toOption {
  | Some(str) => str
  | None => "__failed"
  }
}
let keyExport = (key, keyType, ~setLocalStorage: bool) => {
  if keyType === "public" {
    if getKey("k1") == "__failed" || setLocalStorage == false {
      exportSPKI(key)->then(json => {
        let keywithoutPem =
          json
          ->Js.Json.decodeString
          ->Belt.Option.getWithDefault("")
          ->Js.String2.replace("-----BEGIN PUBLIC KEY-----\n", "")
          ->Js.String2.replace("\n-----END PUBLIC KEY-----", "")
        if setLocalStorage {
          localStorage.setItem(. "k1", keywithoutPem)
        }
        resolve(keywithoutPem)
      })
    } else {
      resolve(getKey("k1"))
    }
  } else if getKey("k2") == "__failed" || setLocalStorage == false {
    exportPKCS8(key)->then(json => {
      let keywithoutPem =
        json
        ->Js.Json.decodeString
        ->Belt.Option.getWithDefault("")
        ->Js.String2.replace("-----BEGIN PRIVATE KEY-----\n", "")
        ->Js.String2.replace("\n-----END PRIVATE KEY-----", "")
      if setLocalStorage {
        localStorage.setItem(. "k2", keywithoutPem)
      }
      resolve(keywithoutPem)
    })
  } else {
    resolve(getKey("k2"))
  }
}

let generateKeyPair = (~calledFrom="root", ~setLocalStorage=true, ()) => {
  Js.log2("genrateKeyPair called", calledFrom)
  generateKeyPairs("RSA-OAEP", {modulusLength: 2048, extractable: true})->then(resp => {
    let dict = LogicUtils.getDictFromJsonObject(resp)
    keyExport(
      LogicUtils.getObj(dict, "publicKey", Js.Dict.empty())->Js.Json.object_,
      "public",
      ~setLocalStorage,
    )->then(pubKey => {
      keyExport(
        LogicUtils.getObj(dict, "privateKey", Js.Dict.empty())->Js.Json.object_,
        "private",
        ~setLocalStorage,
      )->then(
        privKey => {
          let newDict = Js.Dict.empty()
          Js.Dict.set(newDict, "publicKey", pubKey)
          Js.Dict.set(newDict, "privateKey", privKey)
          resolve(newDict)
        },
      )
    })
  })
}

let jwsSign = (payload, algo, id, key) => {
  resolve(
    CompactSign.newCompactSign(TextEncoder.newTextEncoder()->TextEncoder.encode(payload))
    ->CompactSign.setProtectedHeader({alg: algo, kid: id})
    ->CompactSign.sign(key),
  )
}

let jweEncrypt = (payload, enc, algo, id, key) => {
  resolve(
    CompactEncrypt.newCompactEncrypt(TextEncoder.newTextEncoder()->TextEncoder.encode(payload))
    ->CompactEncrypt.setProtectedHeader({enc, alg: algo, kid: id})
    ->CompactEncrypt.encrypt(key),
  )
}
