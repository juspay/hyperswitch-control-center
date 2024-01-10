let getSummary: Js.Json.t => EntityType.summary = json => {
  switch json->Js.Json.decodeObject {
  | Some(dict) => {
      let rowsCount = LogicUtils.getArrayFromDict(dict, "rows", [])->Array.length
      let totalCount = LogicUtils.getInt(dict, "entries", 0)
      {totalCount, count: rowsCount}
    }

  | None => {totalCount: 0, count: 0}
  }
}

@react.component
let make = (
  ~children,
  ~setData=?,
  ~entity: EntityType.entityType<'colType, 't>,
  ~setSummary=?,
  (),
) => {
  let {getObjects, searchUrl: url} = entity
  let fetchApi = AuthHooks.useApiFetcher()
  let initialValueJson = Js.Json.object_(Js.Dict.empty())
  let showToast = ToastState.useShowToast()
  let (showModal, setShowModal) = React.useState(_ => false)

  let onSubmit = (values, form: ReactFinalForm.formApi) => {
    open Promise

    fetchApi(url, ~bodyStr=Js.Json.stringify(values), ~method_=Fetch.Post, ())
    ->then(Fetch.Response.json)
    ->then(json => {
      let jsonData = json->Js.Json.decodeObject->Belt.Option.flatMap(dict => dict->Dict.get("rows"))
      let newData = switch jsonData {
      | Some(actualJson) => actualJson->getObjects->Array.map(obj => obj->Js.Nullable.return)
      | None => []
      }

      let summaryData =
        json->Js.Json.decodeObject->Belt.Option.flatMap(dict => dict->Dict.get("summary"))

      let summary = switch summaryData {
      | Some(x) => x->getSummary
      | None => {totalCount: 0, count: 0}
      }
      switch setSummary {
      | Some(fn) => fn(_ => summary)
      | None => ()
      }
      switch setData {
      | Some(fn) => fn(_ => Some(newData))
      | None => ()
      }
      setShowModal(_ => false)
      form.reset(Js.Json.object_(Dict.make())->Js.Nullable.return)
      json->Js.Nullable.return->resolve
    })
    ->catch(_err => {
      showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())

      Js.Nullable.null->resolve
    })
  }

  let validateForm = (values: Js.Json.t) => {
    let finalValuesDict = switch values->Js.Json.decodeObject {
    | Some(dict) => dict
    | None => Dict.make()
    }
    let keys = Dict.keysToArray(finalValuesDict)
    let errors = Dict.make()
    if keys->Array.length === 0 {
      Dict.set(errors, "Please Choose One of the fields", ""->Js.Json.string)
    }
    errors->Js.Json.object_
  }
  <div className="mr-2">
    <Button
      leftIcon={FontAwesome("search")}
      text={"Search"}
      buttonType=Primary
      onClick={_ => setShowModal(_ => true)}
    />
    <Modal modalHeading="Search" showModal setShowModal modalClass="w-full md:w-5/12 mx-auto">
      <Form onSubmit validate=validateForm initialValues=initialValueJson>
        {children}
        <div className="flex justify-center mb-2">
          <div className="flex justify-between p-1">
            <FormRenderer.SubmitButton text="Submit" />
          </div>
        </div>
      </Form>
    </Modal>
  </div>
}
