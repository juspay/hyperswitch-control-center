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
    open LogicUtils
    let {optionalSearchFieldsList, requiredSearchFieldsList, detailsKey} = entity
    let fetchApi = AuthHooks.useApiFetcher()
    let initialValueJson = JSON.Encode.object(Dict.make())
    let showToast = ToastState.useShowToast()

    let onSubmit = (values, _) => {
      let otherQueries = switch values->JSON.Decode.object {
      | Some(dict) =>
        dict
        ->Dict.toArray
        ->Belt.Array.keepMap(entry => {
          let (key, value) = entry
          let stringVal = getStringFromJson(value, "")
          if stringVal->isNonEmptyString {
            Some(`${key}=${stringVal}`)
          } else {
            None
          }
        })
        ->Array.joinWith("&")
      | _ => ""
      }
      let finalUrl = otherQueries->isNonEmptyString ? `${url}?${otherQueries}` : url

      open Promise
      fetchApi(finalUrl, ~bodyStr=JSON.stringify(initialValueJson), ~method_=Fetch.Get, ())
      ->then(Fetch.Response.json)
      ->then(json => {
        switch JSON.Classify.classify(json) {
        | Object(jsonDict) => {
            let statusStr = getString(jsonDict, "status", "FAILURE")

            if statusStr === "SUCCESS" {
              let payloadDict = jsonDict->Dict.get(detailsKey)->Option.flatMap(JSON.Decode.object)

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
        json->Nullable.make->resolve
      })
      ->catch(_err => {
        showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())

        Nullable.null->resolve
      })
    }

    let validateForm = (values: JSON.t) => {
      let valuesDict = switch values->JSON.Decode.object {
      | Some(dict) => dict->Dict.toArray->Dict.fromArray
      | None => Dict.make()
      }
      let errors = Dict.make()
      requiredSearchFieldsList->Array.forEach(key => {
        if Dict.get(valuesDict, key)->Option.isNone {
          Dict.set(errors, key, "Required"->JSON.Encode.string)
        }
      })
      let isSubmitEnabled = optionalSearchFieldsList->Array.some(key => {
        Dict.get(valuesDict, key)->Option.isSome
      })

      if !isSubmitEnabled {
        Dict.set(
          errors,
          optionalSearchFieldsList->Array.joinWith(","),
          "Atleast One of Optional fields is Required"->JSON.Encode.string,
        )
      }

      errors->JSON.Encode.object
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
