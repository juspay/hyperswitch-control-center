module SearchActions = {
  @react.component
  let make = (~detailsKeyList, ~dictData, ~entity: EntityType.entityType<'colType, 't>) => {
    <ShowDetails.EntityData dictData detailsKeyList entity />
  }
}

module AdvanceSearch = {
  @react.component
  let make = (
    ~searchFields,
    ~url,
    ~entity: EntityType.entityType<'colType, 't>,
    ~setShowModal,
    ~setSearchDataDict,
    ~setShowSearchDetailsModal,
  ) => {
    let {optionalSearchFieldsList, requiredSearchFieldsList, detailsKey} = entity
    let fetchApi = AuthHooks.useApiFetcher()
    let initialValueJson = Js.Json.object_(Js.Dict.empty())
    let showToast = ToastState.useShowToast()

    let onSubmit = (values, _) => {
      let otherQueries = switch values->Js.Json.decodeObject {
      | Some(dict) =>
        dict
        ->Js.Dict.entries
        ->Belt.Array.keepMap(entry => {
          let (key, value) = entry
          let stringVal = LogicUtils.getStringFromJson(value, "")
          if stringVal !== "" {
            Some(`${key}=${stringVal}`)
          } else {
            None
          }
        })
        ->Js.Array2.joinWith("&")
      | _ => ""
      }
      let finalUrl = otherQueries->Js.String2.length > 0 ? `${url}?${otherQueries}` : url

      open Promise
      open LogicUtils
      fetchApi(finalUrl, ~bodyStr=Js.Json.stringify(initialValueJson), ~method_=Fetch.Get, ())
      ->then(Fetch.Response.json)
      ->then(json => {
        switch Js.Json.classify(json) {
        | Js.Json.JSONObject(jsonDict) => {
            let statusStr = getString(jsonDict, "status", "FAILURE")

            if statusStr === "SUCCESS" {
              let payloadDict =
                jsonDict->Js.Dict.get(detailsKey)->Belt.Option.flatMap(Js.Json.decodeObject)

              switch payloadDict {
              | Some(dict) => {
                  setShowModal(_ => false)
                  setSearchDataDict(_ => Some(dict))
                  setShowSearchDetailsModal(_ => true)
                }

              | _ =>
                showToast(
                  ~message="Something went wrong. Please try again",
                  ~toastType=ToastError,
                  (),
                )
              }
            } else {
              showToast(~message="Data Not Found", ~toastType=ToastWarning, ())
            }
          }

        | _ =>
          showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())
        }
        json->Js.Nullable.return->resolve
      })
      ->catch(_err => {
        showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())

        Js.Nullable.null->resolve
      })
    }

    let validateForm = (values: Js.Json.t) => {
      let valuesDict = switch values->Js.Json.decodeObject {
      | Some(dict) => dict->Js.Dict.entries->Js.Dict.fromArray
      | None => Js.Dict.empty()
      }
      let errors = Js.Dict.empty()
      requiredSearchFieldsList->Js.Array2.forEach(key => {
        if Js.Dict.get(valuesDict, key)->Js.Option.isNone {
          Js.Dict.set(errors, key, "Required"->Js.Json.string)
        }
      })
      let isSubmitEnabled = optionalSearchFieldsList->Js.Array2.some(key => {
        Js.Dict.get(valuesDict, key)->Js.Option.isSome
      })

      if !isSubmitEnabled {
        Js.Dict.set(
          errors,
          optionalSearchFieldsList->Js.Array2.joinWith(","),
          "Atleast One of Optional fields is Required"->Js.Json.string,
        )
      }

      errors->Js.Json.object_
    }

    <FormRenderer
      initialValues={initialValueJson}
      onSubmit
      validate=validateForm
      formClass="md:justify-between p-2"
      fields={searchFields}
    />
  }
}

@react.component
let make = (~searchFields, ~url, ~entity) => {
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchDataDict, setSearchDataDict) = React.useState(_ => None)
  let (showSearchDetailsModal, setShowSearchDetailsModal) = React.useState(_ => false)
  <>
    <Button
      text={"Search"}
      leftIcon={FontAwesome("search")}
      buttonType=Primary
      onClick={_ => setShowModal(_ => true)}
    />
    <Modal modalHeading="Search" showModal setShowModal modalClass="w-full md:w-3/12 mx-auto">
      <AdvanceSearch
        searchFields url entity setShowModal setSearchDataDict setShowSearchDetailsModal
      />
    </Modal>
    {switch searchDataDict {
    | Some(dictData) =>
      <Modal
        modalHeading="Search Details"
        showModal=showSearchDetailsModal
        setShowModal=setShowSearchDetailsModal
        modalClass="w-full md:w-10/12  mx-auto">
        <SearchActions detailsKeyList={entity.searchKeyList} dictData entity />
      </Modal>
    | None => React.null
    }}
  </>
}
