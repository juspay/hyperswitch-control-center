let useFetchEnumDetails = () => {
  open APIUtils
  open HomeUtils
  let fetchDetails = useGetMethod()
  let setEnumVariantValues = Recoil.useSetRecoilState(HyperswitchAtom.enumVariantAtom)

  async (enumArray: array<QuickStartTypes.sectionHeadingVariant>) => {
    try {
      let url = `${getURL(
          ~entityName=USERS,
          ~userType=#USER_DATA,
          ~methodType=Get,
          (),
        )}?keys=${enumArray->Array.joinWith(",")}`
      let res = await fetchDetails(url)
      let responseDict = res->responseDataMapper
      setEnumVariantValues(._ => responseDict->Js.Json.object_->Js.Json.stringify)
      Js.Nullable.return(responseDict)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }
}

let useUpdateEnumInRecoil = () => {
  let (enumVariantValues, setEnumVariantValues) = Recoil.useRecoilState(
    HyperswitchAtom.enumVariantAtom,
  )
  open LogicUtils
  (
    enumVariantsAndBodies: array<(
      QuickStartTypes.requestObjectType,
      QuickStartTypes.sectionHeadingVariant,
    )>,
  ) => {
    let enumValueDict = enumVariantValues->safeParse->getDictFromJsonObject
    let enumDictsArray = [enumValueDict]

    enumVariantsAndBodies->Array.forEach(item => {
      let (body, enumVariant) = item
      let bodyValForApi = enumVariant->QuickStartUtils.generateBodyBasedOnType(body)

      switch body {
      | Boolean(_) => {
          let booleanDict = [((enumVariant :> string), true->Js.Json.boolean)]->Dict.fromArray
          enumDictsArray->Array.push(booleanDict)
        }
      | String(str) => {
          let stringDict = [((enumVariant :> string), str->Js.Json.string)]->Dict.fromArray
          enumDictsArray->Array.push(stringDict)
        }
      | _ => enumDictsArray->Array.push(bodyValForApi->getDictFromJsonObject)
      }
    })

    let updatedRecoilValueDict = DictionaryUtils.mergeDicts(enumDictsArray)
    setEnumVariantValues(._ => updatedRecoilValueDict->Js.Json.object_->Js.Json.stringify)
    updatedRecoilValueDict
  }
}

let usePostEnumDetails = () => {
  open APIUtils
  let updateDetails = useUpdateMethod()
  let updateEnumInRecoil = useUpdateEnumInRecoil()

  async (body, enumVariant) => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#MERCHANT_DATA, ~methodType=Post, ())
      let bodyValForApi = enumVariant->QuickStartUtils.generateBodyBasedOnType(body)
      let _ = await updateDetails(url, bodyValForApi, Post)

      let updatedRecoilValueDict = updateEnumInRecoil([(body, enumVariant)])
      Js.Nullable.return(updatedRecoilValueDict)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        Js.Exn.raiseError(err)
      }
    }
  }
}
