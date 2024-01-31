let getSummary: JSON.t => EntityType.summary = json => {
  switch json->JSON.Decode.object {
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
  let initialValueJson = JSON.Encode.object(Dict.make())
  let showToast = ToastState.useShowToast()
  let (showModal, setShowModal) = React.useState(_ => false)

  let onSubmit = (values, form: ReactFinalForm.formApi) => {
    open Promise

    fetchApi(url, ~bodyStr=JSON.stringify(values), ~method_=Fetch.Post, ())
    ->then(Fetch.Response.json)
    ->then(json => {
      let jsonData = json->JSON.Decode.object->Option.flatMap(dict => dict->Dict.get("rows"))
      let newData = switch jsonData {
      | Some(actualJson) => actualJson->getObjects->Array.map(obj => obj->Nullable.make)
      | None => []
      }

      let summaryData = json->JSON.Decode.object->Option.flatMap(dict => dict->Dict.get("summary"))

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
      form.reset(JSON.Encode.object(Dict.make())->Nullable.make)
      json->Nullable.make->resolve
    })
    ->catch(_err => {
      showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())

      Nullable.null->resolve
    })
  }

  let validateForm = (values: JSON.t) => {
    let finalValuesDict = switch values->JSON.Decode.object {
    | Some(dict) => dict
    | None => Dict.make()
    }
    let keys = Dict.keysToArray(finalValuesDict)
    let errors = Dict.make()
    if keys->Array.length === 0 {
      Dict.set(errors, "Please Choose One of the fields", ""->JSON.Encode.string)
    }
    errors->JSON.Encode.object
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
