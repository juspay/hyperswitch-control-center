@val @scope("window")
external location: {..} = "location"
external toJson: exn => Js.Json.t = "%identity"
external toExn: string => exn = "%identity"

let useAddLogsAroundFetch = () => {
  let addLogsAroundFetch = (~setStatusDict=?, ~logTitle, fetchPromise) => {
    let setStatusDict = switch setStatusDict {
    | Some(fn) => fn
    | None => _ => ()
    }
    setStatusDict(prev => {
      let dict =
        prev
        ->Dict.toArray
        ->Array.filter(entry => {
          let (key, _value) = entry
          key !== logTitle
        })
        ->Dict.fromArray
      dict
    })
    open Promise

    fetchPromise
    ->then(resp => {
      let status = resp->Fetch.Response.status

      setStatusDict(prev => {
        prev->Dict.set(logTitle, status)
        prev
      })

      if status >= 400 {
        Js.Exn.raiseError("err")->reject
      } else {
        resolve(resp)
      }
    })
    ->then(Fetch.Response.json)
    ->thenResolve(json => {
      json
    })
    ->catch(err => {
      reject(err)
    })
  }

  addLogsAroundFetch
}
let useAddLogsAroundFetchNew = () => {
  let addLogsAroundFetch = (~setStatusDict=?, ~logTitle, fetchPromise) => {
    let setStatusDict = switch setStatusDict {
    | Some(fn) => fn
    | None => _ => ()
    }
    setStatusDict(prev => {
      let dict =
        prev
        ->Dict.toArray
        ->Array.filter(entry => {
          let (key, _value) = entry
          key !== logTitle
        })
        ->Dict.fromArray
      dict
    })
    open Promise

    fetchPromise
    ->then(resp => {
      let status = resp->Fetch.Response.status
      setStatusDict(prev => {
        prev->Dict.set(logTitle, status)
        prev
      })

      if status >= 400 {
        Js.Exn.raiseError("err")->reject
      } else {
        resolve(resp)
      }
    })
    ->then(Fetch.Response.text)
    ->thenResolve(text => {
      // will add the check for n line saperated is the length is 0 then no data
      // if (
      //   Belt.Array.length(
      //     json
      //     ->LogicUtils.getDictFromJsonObject
      //     ->LogicUtils.getJsonObjectFromDict("queryData")
      //     ->LogicUtils.getArrayFromJson([]),
      //   ) === 0
      // ) {
      //   addLogs(
      //     ~moduleName,
      //     ~event=`${logTitle} Fetch Ends with no data`,
      //     ~environment=GlobalVars.environment,
      //     (),
      //   )
      // }
      text
    })
    ->catch(err => {
      reject(err)
    })
  }

  addLogsAroundFetch
}
