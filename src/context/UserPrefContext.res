// will be used in future
// docfor the user preference https://docs.google.com/document/d/1BM_UgHLuN0U-cXfRYqN6wWSq-5KUiqojinCfBrUEiVo/edit
open UserPrefUtils
external userPrefToJson: userPref => Js.Json.t = "%identity"
external dictUserPrefToStr: Js.Dict.t<userPref> => string = "%identity"
let userPrefSetter: (Js.Dict.t<userPref> => Js.Dict.t<userPref>) => unit = _ => ()
let defaultUserPref: Js.Dict.t<userPref> = Dict.make()
let defaultUserModuleWisePref: moduleVisePref = {}
type filter = {
  userPref: Js.Dict.t<userPref>,
  setUserPref: (Js.Dict.t<userPref> => Js.Dict.t<userPref>) => unit,
  lastVisitedTab: string,
  getSearchParamByLink: string => string,
  addConfig: (string, Js.Json.t) => unit,
  getConfig: string => option<Js.Json.t>,
}

let userPrefObj: filter = {
  userPref: defaultUserPref,
  setUserPref: userPrefSetter,
  lastVisitedTab: "",
  getSearchParamByLink: _str => "",
  addConfig: (_str, _json) => (),
  getConfig: _str => None,
}

let userPrefContext = React.createContext(userPrefObj)

module Provider = {
  let makeProps = (~value, ~children, ()) =>
    {
      "value": value,
      "children": children,
    }
  let make = React.Context.provider(userPrefContext)
}

@react.component
let make = (~children) => {
  // this fetch will only happen once after that context will be updated each time when url chnaged and it keep hitting the update api
  let userPrefInitialVal: Js.Dict.t<userPref> = UserPrefUtils.getUserPref()
  let (authStatus, _setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)

  let username = switch authStatus {
  | LoggedIn(authInfo) => authInfo.username
  | _ => ""
  }
  let (userPref, setUserPref) = React.useState(_ => userPrefInitialVal)
  let url = RescriptReactRouter.useUrl()
  let urlPathConcationation = `/${url.path
    ->LogicUtils.stripV4
    ->Belt.List.toArray
    ->Array.joinWith("/")}`
  // UPDATE THE LAST VISITED TAB
  React.useEffect2(() => {
    if urlPathConcationation !== "/" {
      setUserPref(prev => {
        let currentConfig = prev->Dict.get(username)->Belt.Option.getWithDefault({})
        let updatedPrev = currentConfig
        let updatedValue = if (
          urlPathConcationation !== updatedPrev.lastVisitedTab->Belt.Option.getWithDefault("")
        ) {
          {...updatedPrev, lastVisitedTab: urlPathConcationation}
        } else {
          updatedPrev
        }
        prev->Dict.set(username, updatedValue)
        UserPrefUtils.saveUserPref(prev)
        prev
      })
    }

    None
  }, (urlPathConcationation, username))

  // UPDATE THE searchParams IN LAST VISITED TAB
  React.useEffect2(() => {
    setUserPref(prev => {
      let currentConfig = prev->Dict.get(username)->Belt.Option.getWithDefault({})
      let updatedPrev = currentConfig
      let moduleWisePref = switch updatedPrev {
      | {moduleVisePref} => moduleVisePref
      | _ => Dict.make()
      }
      let currentModulePerf =
        moduleWisePref
        ->Dict.get(urlPathConcationation)
        ->Belt.Option.getWithDefault(defaultUserModuleWisePref)

      let filteredUrlSearch =
        url.search
        ->LogicUtils.getDictFromUrlSearchParams
        ->DictionaryUtils.deleteKeys([
          // all absolute datetime keys to be added here, to ensure absolute dateranges are not persisted
          "startTime",
          "endTime",
          "filters.dateCreated.lte",
          "filters.dateCreated.gte",
          "filters.dateCreated.opt", // to be fixed and removed from here
        ])
        ->Dict.toArray
        ->Array.map(
          item => {
            let (key, value) = item
            `${key}=${value}`
          },
        )
        ->Array.joinWith("&")
      let isMarketplaceApp = urlPathConcationation == "/marketplace"
      moduleWisePref->Dict.set(
        urlPathConcationation,
        {
          ...currentModulePerf,
          searchParams: isMarketplaceApp ? "" : filteredUrlSearch,
        },
      )
      let updatedCurrentConfig = {
        ...updatedPrev,
        moduleVisePref: moduleWisePref,
      }
      prev->Dict.set(username, updatedCurrentConfig)
      UserPrefUtils.saveUserPref(prev)
      prev
    })

    None
  }, (url.search, username))
  // UPDATE THE CURRENT PREF TO THE DATA SOURCE
  React.useEffect1(() => {
    UserPrefUtils.saveUserPref(userPref)
    None
  }, [userPref])

  let addConfig = (key, value) => {
    setUserPref(prev => {
      let currentConfig = prev->Dict.get(username)->Belt.Option.getWithDefault({})
      let updatedPrev = currentConfig
      let moduleWisePref = switch updatedPrev {
      | {moduleVisePref} => moduleVisePref
      | _ => Dict.make()
      }
      let currentModulePerf =
        moduleWisePref
        ->Dict.get(urlPathConcationation)
        ->Belt.Option.getWithDefault(defaultUserModuleWisePref)
      let moduleConfig = switch currentModulePerf {
      | {moduleConfig} => moduleConfig
      | _ => Dict.make()
      }
      moduleConfig->Dict.set(key, value)
      moduleWisePref->Dict.set(urlPathConcationation, {...currentModulePerf, moduleConfig})

      let updatedCurrentConfig = {
        ...updatedPrev,
        moduleVisePref: moduleWisePref,
      }
      prev->Dict.set(username, updatedCurrentConfig)
      UserPrefUtils.saveUserPref(prev)
      prev
    })
  }

  let getConfig = key => {
    let currentConfig = userPref->Dict.get(username)->Belt.Option.getWithDefault({})
    let updatedPrev = currentConfig
    switch updatedPrev {
    | {moduleVisePref} =>
      switch moduleVisePref
      ->Dict.get(urlPathConcationation)
      ->Belt.Option.getWithDefault(defaultUserModuleWisePref) {
      | {moduleConfig} => moduleConfig->Dict.get(key)
      | _ => None
      }
    | _ => None
    }
  }
  // not adding to useMemo as it doesn't triggers sometimes
  let userPrefString =
    userPref
    ->Dict.toArray
    ->Array.map(item => {
      let (key, value) = item
      (key, value->userPrefToJson)
    })
    ->Dict.fromArray
    ->Js.Json.object_
    ->Js.Json.stringify

  let value = React.useMemo4(() => {
    let currentConfig = userPref->Dict.get(username)->Belt.Option.getWithDefault({})
    let updatedPrev = currentConfig
    let lastVisitedTab = switch updatedPrev {
    | {lastVisitedTab} => lastVisitedTab
    | _ => ""
    }
    let moduleVisePref = switch updatedPrev {
    | {moduleVisePref} => moduleVisePref
    | _ => Dict.make()
    }
    let getSearchParamByLink = link => {
      let searchParam = UserPrefUtils.getSearchParams(moduleVisePref, ~key=link) // this is for removing the v4 from the link
      searchParam !== "" ? `?${searchParam}` : ""
    }

    {
      userPref,
      setUserPref,
      lastVisitedTab,
      getSearchParamByLink,
      addConfig,
      getConfig,
    }
  }, (userPrefString, setUserPref, addConfig, getConfig))
  <Provider value={value}> children </Provider>
}
