open APIUtils
open LogicUtils
open SavedViewTypes

let useFetchSavedViews = (~entity, ~version) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()

  async (~setSavedViews) => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParameters=Some(SavedViewsUtils.savedViewsQueryParam(entity)),
      )
      let response = await fetchDetails(url, ~version)
      let parsedResponse = response->SavedViewsUtils.savedViewsResponseMapper(entity)
      setSavedViews(_ => parsedResponse.views)
      parsedResponse.views
    } catch {
    | err =>
      Js.log2("FAILED TO LOAD SAVED VIEWS", err)
      showToast(
        ~message="Failed to load saved views. Please try again.",
        ~toastType=ToastState.ToastError,
      )
      []
    }
  }
}

let useDeleteSavedView = (~entity, ~fetchSavedViews) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()

  async (view_id, viewName, ~onSuccess=?) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let _ = await updateDetails(url, SavedViewsUtils.buildDeletePayload(entity, view_id), Post)
      showToast(~message=`'${viewName}' has been deleted successfully!`, ~toastType=ToastSuccess)

      switch onSuccess {
      | Some(callback) => callback()
      | None => ()
      }

      fetchSavedViews()->ignore
    } catch {
    | err =>
      Js.log2("FAILED TO DELETE SAVED VIEW", err)
      showToast(
        ~message=`Failed to delete view '${viewName}'. Please try again.`,
        ~toastType=ToastState.ToastError,
      )
    }
  }
}

let useRenameSavedView = (~entity, ~savedViewDataVersion, ~fetchSavedViews) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()

  async (view: SavedViewTypes.savedView, newName, ~onSuccess=?) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let _ = await updateDetails(
        url,
        SavedViewsUtils.buildRenamePayload(entity, view, newName, ~savedViewDataVersion),
        Post,
      )
      showToast(~message=`View renamed to '${newName}' successfully!`, ~toastType=ToastSuccess)

      switch onSuccess {
      | Some(callback) => callback()
      | None => ()
      }

      fetchSavedViews()->ignore
    } catch {
    | err =>
      Js.log2("FAILED TO RENAME SAVED VIEW", err)
      showToast(
        ~message=`Failed to rename view '${newName}'. Please try again.`,
        ~toastType=ToastState.ToastError,
      )
    }
  }
}

let useCreateSavedView = (~entity, ~savedViewDataVersion, ~onViewsUpdated, ~setShowModal) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()

  async (trimmedName, filters) => {
    try {
      let payload = SavedViewsUtils.buildSavePayload(
        entity,
        Create,
        trimmedName,
        filters,
        None,
        ~savedViewDataVersion,
      )
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let response = await updateDetails(url, payload, Post)
      onViewsUpdated(response, Some(trimmedName))
      showToast(~message=`New View '${trimmedName}' created successfully!`, ~toastType=ToastSuccess)
      setShowModal(_ => false)
    } catch {
    | err =>
      Js.log2("FAILED TO CREATE SAVED VIEW", err)
      showToast(
        ~message=`Failed to create view '${trimmedName}'. Please try again.`,
        ~toastType=ToastState.ToastError,
      )
    }
  }
}

let useOverwriteSavedView = (
  ~entity,
  ~savedViewDataVersion,
  ~onViewsUpdated,
  ~setShowModal,
  ~savedViews,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastAdapter.useShowToast()

  async (viewToOverwrite, filters) => {
    try {
      if viewToOverwrite->isNonEmptyString {
        let viewId =
          savedViews
          ->Array.find(view => view.view_name === viewToOverwrite)
          ->Option.map(v => v.view_id)

        let payload = SavedViewsUtils.buildSavePayload(
          entity,
          Update,
          viewToOverwrite,
          filters,
          viewId,
          ~savedViewDataVersion,
        )
        let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
        let response = await updateDetails(url, payload, Post)
        onViewsUpdated(response, Some(viewToOverwrite))
        showToast(
          ~message=`'${viewToOverwrite}' has been overwritten successfully!`,
          ~toastType=ToastSuccess,
        )
        setShowModal(_ => false)
      }
    } catch {
    | err =>
      Js.log2("FAILED TO OVERWRITE SAVED VIEW", err)
      showToast(~message="Failed to overwrite view. Please try again.", ~toastType=ToastError)
    }
  }
}
