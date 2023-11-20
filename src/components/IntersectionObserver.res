type interSectionObserver

type observer<'t> = {observe: (. 't) => unit}

type entries = {isIntersecting: bool}
type intersectionobserverfunc = array<entries> => unit
@new
external interSectionObserver: intersectionobserverfunc => option<observer<'t>> =
  "IntersectionObserver"

// class: class will be the class of that specific element it should be unique
// children: wrap any component inside it
// setIsVisible: function will will setState if the element is visible in the viewport or not
@react.component
let make = (~class: string, ~children: React.element, ~setIsVisible: (bool => bool) => unit) => {
  let allUI = Document.document.querySelectorAll(. `.${class}`)
  React.useEffect2(() => {
    let observer = interSectionObserver(entries => {
      entries->Js.Array2.forEach(
        item => {
          setIsVisible(_ => item.isIntersecting)
        },
      )
    })
    if allUI->Belt.Array.get(0)->Belt.Option.isSome {
      switch observer {
      | Some(observer) => observer.observe(. allUI->Belt.Array.get(0))
      | None => setIsVisible(_ => true)
      }
    }
    None
  }, (setIsVisible, allUI))

  <div className=class> children </div>
}
