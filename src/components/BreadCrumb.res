type status = Active | Disabled | Completed

type breadCrumb_options = {
  status: status,
  position: int,
}

type breadCrumb = {
  key: string,
  status: status,
  position: int,
}
@react.component
let make = (
  ~breadCrumb: Js.Dict.t<breadCrumb_options>,
  ~containerStyle="",
  ~breadCrumbStyle="",
  ~container: React.element=<> </>,
) => {
  let (breadCrumbArray, setBreadcrumbArray) = React.useState(_ => [])
  let (arrayLength, setArrayLength) = React.useState(_ => 0)
  let sortByPosition = (a, b) => {
    if a.position < b.position {
      -1
    } else if a.position > b.position {
      1
    } else {
      0
    }
  }

  React.useEffect1(() => {
    let arr =
      breadCrumb
      ->Js.Dict.entries
      ->Belt.Array.keepMap(val => {
        let (key, obj) = val
        let breadObj: breadCrumb = {
          key,
          status: obj.status,
          position: obj.position,
        }
        Some(breadObj)
      })
      ->Js.Array2.sortInPlaceWith(sortByPosition)
    setArrayLength(_ => Js.Array2.length(arr))
    setBreadcrumbArray(_ => arr)
    None
  }, [breadCrumb])

  <div className={`px-2 pb-4 left-1/2 ${containerStyle}`}>
    <div className={` flex ${breadCrumbStyle}`}>
      {breadCrumbArray
      ->Js.Array2.mapi((val, index) => {
        let t = switch val.status {
        | Active => "blue-800"
        | Disabled => "gray-400"
        | Completed => "green-800"
        }
        <div key={string_of_int(index)}>
          <div className="flex">
            {if val.status == Completed {
              <div
                className={`ml-3 rounded-full w-8 text-white h-8 flex items-center justify-center text-sm bg-${t}`}>
                <Icon className="align-middle" name="check" size=12 />
              </div>
            } else {
              <div
                className={`ml-4 rounded-full w-8 text-white h-8 text-center flex items-center justify-center text-sm bg-${t}`}>
                {val.position->Belt.Int.toString->React.string}
              </div>
            }}
            <div className={`ml-3 font-semibold flex items-center text-${t}`}>
              {val.key->React.string}
            </div>
            {if val.position != arrayLength {
              <div className="flex items-center justify-center mx-6 text-gray-200">
                // {React.string(">")}
                <Icon className="" name="finops-rightarrow" size=15 />
              </div>
            } else {
              React.null
            }}
          </div>
        </div>
      })
      ->React.array}
      {container}
    </div>
  </div>
}
