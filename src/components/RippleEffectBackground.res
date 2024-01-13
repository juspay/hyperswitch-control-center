type styleObj
type event
type domObj = {
  clientWidth: int,
  clientHeight: int,
}
@get external style: Dom.element => styleObj = "style"
@send external setAttribute: (Dom.element, string, string) => unit = "setAttribute"
@val external document: 'a = "document"
@set external setWidth: (styleObj, string) => unit = "width"
@send external prepend: ('a, Dom.element) => unit = "prepend"
@set external setHeight: (styleObj, string) => unit = "height"
@send external removeChild: ('a, Dom.element) => unit = "removeChild"
@set external setOpacity: (styleObj, string) => unit = "opacity"
@set external setTransitionDuration: (styleObj, string) => unit = "transitionDuration"
@set external setaAnimationTimingFunction: (styleObj, string) => unit = "animationTimingFunction"
@send external addEventListener: (Dom.element, string, event => unit) => unit = "addEventListener"
@send
external removeEventListener: (Dom.element, string, event => unit) => unit = "removeEventListener"

let useLinearRippleHook = (ref: React.ref<Js.Nullable.t<Dom.element>>, shouldRipple) => {
  React.useEffect1(() => {
    let handleMouseOver = _ev => {
      switch ref.current->Js.Nullable.toOption {
      | Some(splash) => {
          let link = document->DOMUtils.createElement("div")
          link->setAttribute(
            "class",
            "absolute bg-[#0000000a] dark:bg-[#ffffff1f] w-0 h-0 animate-textTransitionSideBar ",
          )
          splash->prepend(link)
          link->style->setOpacity("60")
          link->style->setHeight(`70px`)
          link->style->setWidth(`400px`)
          link->style->setaAnimationTimingFunction("linear")
          Js.Global.setTimeout(() => {
            splash->removeChild(link)
          }, 300)->ignore
        }

      | None => ()
      }
    }

    switch ref.current->Js.Nullable.toOption {
    | Some(elem) =>
      if shouldRipple {
        elem->addEventListener("mousedown", handleMouseOver)

        Some(
          () => {
            elem->removeEventListener("mousedown", handleMouseOver)
          },
        )
      } else {
        None
      }
    | None => None
    }
  }, [ref])
}

let useHorizontalRippleHook = (ref: React.ref<Js.Nullable.t<Dom.element>>) => {
  React.useEffect1(() => {
    let handleMouseOver = _ev => {
      switch ref.current->Js.Nullable.toOption {
      | Some(splash) => {
          let link = document->DOMUtils.createElement("div")
          link->setAttribute(
            "class",
            "absolute bg-[#00000014] dark:bg-[#ffffff1f] top-1/2 left-1/2 -translate-x-2/4 -translate-y-2/4 rounded-full",
          )
          splash->prepend(link)

          link->style->setOpacity("20")
          link->style->setTransitionDuration(".4s")
          link->style->setHeight("70px")
          link->style->setWidth("70px")

          Js.Global.setTimeout(() => {
            link->style->setHeight("400px")
            link->style->setWidth("400px")
            link->style->setOpacity("20")
            link->style->setaAnimationTimingFunction("cubic-bezier(0.25, 0.1, 0.25, 1)")
          }, 0)->ignore

          Js.Global.setTimeout(() => {
            splash->removeChild(link)
          }, 400)->ignore
        }

      | None => ()
      }
    }

    switch ref.current->Js.Nullable.toOption {
    | Some(elem) =>
      elem->addEventListener("mousedown", handleMouseOver)

      Some(
        () => {
          elem->removeEventListener("mousedown", handleMouseOver)
        },
      )
    | None => None
    }
  }, [ref])
}
