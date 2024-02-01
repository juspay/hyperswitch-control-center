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
        )}?keys=${enumArray->Array.joinWithUnsafe(",")}`
      let res = await fetchDetails(url)
      let responseDict = res->responseDataMapper
      setEnumVariantValues(._ => responseDict->JSON.Encode.object->JSON.stringify)
      Nullable.make(responseDict)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
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
          let booleanDict = [((enumVariant :> string), true->JSON.Encode.bool)]->Dict.fromArray
          enumDictsArray->Array.push(booleanDict)
        }
      | String(str) => {
          let stringDict = [((enumVariant :> string), str->JSON.Encode.string)]->Dict.fromArray
          enumDictsArray->Array.push(stringDict)
        }
      | _ => enumDictsArray->Array.push(bodyValForApi->getDictFromJsonObject)
      }
    })

    let updatedRecoilValueDict = DictionaryUtils.mergeDicts(enumDictsArray)
    setEnumVariantValues(._ => updatedRecoilValueDict->JSON.Encode.object->JSON.stringify)
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
      let _ = await updateDetails(url, bodyValForApi, Post, ())

      let updatedRecoilValueDict = updateEnumInRecoil([(body, enumVariant)])
      Nullable.make(updatedRecoilValueDict)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
