@val @scope(("window", "location")) external urlOrigin: string = "origin"
open LogicUtils
type saveView = {
  username: string,
  url: string,
  tab: string,
  name: string,
  lastModified: string,
  isDefault: bool,
  includeDateRange: bool,
  id: string,
  entityId: string,
  description: string,
  dateCreated: string,
}

let defaultSaveView = {
  username: "",
  url: "",
  tab: "",
  name: "Default View",
  lastModified: "",
  isDefault: true,
  includeDateRange: false,
  id: "",
  entityId: "",
  description: "",
  dateCreated: "",
}

type colType =
  | Name
  | Description
  | Timestamp
  | Default
  | Actions

let filterBySearchText = (actualData, value) => {
  let searchText = getStringFromJson(value, "")->Js.String2.toLowerCase

  actualData
  ->Belt.Array.keepMap(Js.Nullable.toOption)
  ->Belt.Array.keepMap((data: saveView) => {
    let dict = Js.Dict.empty()
    dict->Js.Dict.set("name", data.name)
    dict->Js.Dict.set("description", data.description)

    let isMatched =
      dict
      ->Js.Dict.values
      ->Js.Array2.find(val => {
        val->Js.String2.toLowerCase->Js.String2.includes(searchText)
      })
      ->Belt.Option.isSome

    if isMatched {
      data->Js.Nullable.return->Some
    } else {
      None
    }
  })
}

let getFilterDict = (~url, ~prefix, ~excludeKeys=[], ~includeKeys=[], ()) => {
  if url !== "" {
    url
    ->Js.Global.decodeURI
    ->Js.String2.split("&")
    ->Js.Array2.map(str => {
      let arr = str->Js.String2.split("=")
      let key = arr->Belt.Array.get(0)->Belt.Option.getWithDefault("-")
      let val = arr->Belt.Array.sliceToEnd(1)->Js.Array2.joinWith("=")
      (key, val->UrlFetchUtils.getFilterValue) // it will return the Json string, Json array
    })
    ->Belt.Array.keepMap(entry => {
      let (key, val) = entry
      let val = switch val->Js.Json.classify {
      | JSONFalse => "false"
      | JSONTrue => "true"
      | JSONNull => ""
      | JSONString(string) => string
      | JSONNumber(float) => float->Belt.Float.toString
      | JSONObject(_) => ""
      | JSONArray(array) => `[${array->Js.Array2.toString}]`
      }
      if (
        (prefix === "" && !(excludeKeys->Js.Array2.includes(key))) ||
          includeKeys->Js.Array2.includes(key)
      ) {
        (key, val)->Some
      } else if (
        key->Js.String2.indexOf(`${prefix}.`) === 0 && !(excludeKeys->Js.Array2.includes(key))
      ) {
        let transformedKey = key->Js.String2.replace(`${prefix}.`, "")
        (transformedKey, val)->Some
      } else {
        None
      }
    })
    ->Js.Dict.fromArray
  } else {
    Js.Dict.empty()
  }
}

module DefaultView = {
  open Promise
  @react.component
  let make = (
    ~saveView: saveView,
    ~setRefetchCounter,
    ~isDefaultSaveViewPresent,
    ~defaultSaveView,
    ~setShowModal,
  ) => {
    let updateSaveView = AnalyticsHooks.useUpdateSaveView()
    let showToast = ToastState.useShowToast()
    let isMobileView = MatchMedia.useMobileChecker()

    let update = id => {
      let bodyStr =
        [("isDefault", true->Js.Json.boolean)]
        ->Js.Dict.fromArray
        ->Js.Json.object_
        ->Js.Json.stringify

      updateSaveView(~bodyStr, ~id)
      ->then(response => {
        switch response {
        | Success => {
            showToast(~message="Updated Successfully", ~toastType=ToastSuccess, ())
            setRefetchCounter(prev => prev + 1)
            setShowModal(_ => false)
          }

        | Error(errorMessage) => {
            let errorMessage = errorMessage->Belt.Option.getWithDefault("")
            showToast(~message=errorMessage, ~toastType=ToastError, ())
          }
        }
        Js.Nullable.null->resolve
      })
      ->catch(_err => {
        Js.Nullable.null->resolve
      })
      ->ignore
    }

    let updateDefaultView = id => {
      if isDefaultSaveViewPresent {
        let bodyStr =
          [("isDefault", false->Js.Json.boolean)]
          ->Js.Dict.fromArray
          ->Js.Json.object_
          ->Js.Json.stringify
        updateSaveView(~bodyStr, ~id=defaultSaveView.id)
        ->then(response => {
          switch response {
          | Success => update(id)
          | Error(errorMessage) => {
              let errorMessage = errorMessage->Belt.Option.getWithDefault("")
              showToast(~message=errorMessage, ~toastType=ToastError, ())
            }
          }
          Js.Nullable.null->resolve
        })
        ->catch(_err => {
          Js.Nullable.null->resolve
        })
        ->ignore
      } else {
        update(id)
      }
    }

    <div
      className={`flex ${isMobileView ? "justify-start" : "justify-center"} items-center w-full`}>
      {if saveView.isDefault {
        React.string(saveView.name)
      } else {
        <Button
          text="Make Default"
          buttonType=Pagination
          onClick={_ => updateDefaultView(saveView.id)}
          buttonSize={isMobileView ? XSmall : Small}
        />
      }}
    </div>
  }
}

module NameCell = {
  @react.component
  let make = (~saveView, ~setShowModal, ~applySaveView) => {
    <div
      className="cursor-pointer w-fit flex flex-row gap-2 text-blue-700 hover:text-blue-800 hover:underline dark:text-blue-300"
      onClick={_ => {
        applySaveView(saveView)
        setShowModal(_ => false)
      }}>
      {saveView.name->React.string}
    </div>
  }
}

module Actions = {
  @react.component
  let make = (~saveView: saveView, ~setRefetchCounter, ~setShowModal) => {
    let url = RescriptReactRouter.useUrl()
    let showPopUp = PopUpState.useShowPopUp()
    let showToast = ToastState.useShowToast()
    let deleteSaveView = AnalyticsHooks.useDeleteSaveView()
    let handleDelete = _ => {
      open Promise
      deleteSaveView(~id=saveView.id)
      ->then(response => {
        switch response {
        | Success => {
            showToast(~message="Updated Successfully", ~toastType=ToastSuccess, ())
            setRefetchCounter(prev => prev + 1)
            setShowModal(_ => false)
          }

        | Error(errorMessage) => {
            let errorMessage = errorMessage->Belt.Option.getWithDefault("")
            showToast(~message=errorMessage, ~toastType=ToastError, ())
          }
        }
        Js.Nullable.null->resolve
      })
      ->catch(_err => {
        Js.Nullable.null->resolve
      })
      ->ignore
    }

    let deleteSave = _ =>
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Delete View ?",
        description: React.string("Are you sure you want to DELETE this view ?"),
        handleConfirm: {text: "Yes, delete it", onClick: handleDelete},
        handleCancel: {text: "No, don't delete"},
      })
    <div className="flex gap-5 items-center justify-center">
      <Clipboard.Copy
        data={`${urlOrigin}/${url.path
          ->Belt.List.toArray
          ->Js.Array2.joinWith("/")}?${saveView.url}`}
        iconSize=14
      />
      <Icon
        name="trash-alt" size=14 className="cursor-pointer hover:text-red-500" onClick={deleteSave}
      />
    </div>
  }
}

let itemToObjMapper = dict => {
  username: getString(dict, "username", ""),
  url: getString(dict, "url", ""),
  tab: getString(dict, "tab", ""),
  name: getString(dict, "name", "Default View"),
  lastModified: getString(dict, "lastModified", ""),
  isDefault: getBool(dict, "isDefault", false),
  includeDateRange: getBool(dict, "includeDateRange", false),
  id: getString(dict, "id", ""),
  entityId: getString(dict, "entityId", ""),
  description: getString(dict, "description", ""),
  dateCreated: getString(dict, "dateCreated", ""),
}

let getSaveDetials: Js.Json.t => array<saveView> = json => {
  getArrayDataFromJson(json, itemToObjMapper)
}

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name", ~showSort=true, ())
  | Description =>
    Table.makeHeaderInfo(~key="description", ~title="Description", ~showSort=true, ())
  | Timestamp => Table.makeHeaderInfo(~key="dateCreated", ~title="Timestamp", ~showSort=true, ())
  | Default =>
    Table.makeHeaderInfo(~key="isDefault", ~title="Default", ~dataType=DropDown, ~showSort=true, ())
  | Actions => Table.makeHeaderInfo(~key="actions", ~title="Actions", ~showSort=false, ())
  }
}

let getCell = (
  dateFilterUrl,
  setRefetchCounter,
  isDefaultSaveViewPresent,
  defaultSaveView,
  setShowModal,
  applySaveView,
  saveView,
  colType,
): Table.cell => {
  let saveView = if saveView.includeDateRange {
    saveView
  } else {
    {...saveView, url: `${saveView.url}${dateFilterUrl}`}
  }
  switch colType {
  | Name => CustomCell(<NameCell saveView setShowModal applySaveView />, saveView.name)
  | Description => Text(saveView.description)
  | Timestamp => Text(saveView.name)
  | Default =>
    CustomCell(
      <DefaultView
        saveView setRefetchCounter isDefaultSaveViewPresent defaultSaveView setShowModal
      />,
      saveView.isDefault ? "True" : "False",
    )
  | Actions => CustomCell(<Actions saveView setRefetchCounter setShowModal />, "")
  }
}

let saveFilterListEntity = EntityType.makeEntity(
  ~uri="/api/ec/v1/savedView/list",
  ~getObjects=getSaveDetials,
  ~defaultColumns=[Name, Description, Timestamp, Default, Actions],
  ~getHeading,
  ~getCell=(_, _) => Text(""),
  ~dataKey="rows",
  (),
)
