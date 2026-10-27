/*
  Always-visible horizontal scrollbar for tables.

  Wide tables keep their native horizontal scrollbar at the bottom of the table, so a
  mouse user has to scroll the page down until it comes into view before they can drag
  sideways (trackpad users just swipe, which is why this is easy to miss). This renders
  a scrollbar pinned to the bottom edge of the table's *visible* area and keeps it in
  sync with the real scroll container.

  The thumb is drawn by hand rather than delegating to a native overflow scrollbar:
  macOS overlay scrollbars fade out until hovered, and Chrome ignores
  ::-webkit-scrollbar styling once scrollbar-width/color is set, so a native bar can't
  be kept permanently visible.
*/

type rect = {left: float, right: float, top: float, bottom: float}
type overflowStyle = {overflowX: string, overflowY: string}
type pointer = {clientX: float}

type layout = {
  left: float,
  top: float,
  width: float,
  thumbLeft: float,
  thumbWidth: float,
  progress: float,
}

@send external getRect: Dom.element => rect = "getBoundingClientRect"
@get external parentElement: Dom.element => Nullable.t<Dom.element> = "parentElement"
@send external querySelector: (Dom.element, string) => Nullable.t<Dom.element> = "querySelector"
@val external getComputedStyle: Dom.element => overflowStyle = "getComputedStyle"
@get external scrollLeft: Dom.element => float = "scrollLeft"
@set external setScrollLeft: (Dom.element, float) => unit = "scrollLeft"
@scope("window") @val external innerHeight: float = "innerHeight"
@scope("window") @val external innerWidth: float = "innerWidth"
@scope("document") @val external body: Dom.element = "body"
@scope("window") @val external requestFrame: (float => unit) => int = "requestAnimationFrame"
@scope("window") @val external cancelFrame: int => unit = "cancelAnimationFrame"
@scope("window") @val
external addListener: (string, unit => unit, bool) => unit = "addEventListener"
@scope("window") @val
external removeListener: (string, unit => unit, bool) => unit = "removeEventListener"
@scope("window") @val
external addPointerListener: (string, pointer => unit, bool) => unit = "addEventListener"
@scope("window") @val
external removePointerListener: (string, pointer => unit, bool) => unit = "removeEventListener"

let barHeight = 14.
let thumbHeight = 8.
let minThumbWidth = 28.

let isScrollable = style => style.overflowX === "auto" || style.overflowX === "scroll"

@react.component
let make = (~containerRef: React.ref<Nullable.t<Dom.element>>) => {
  let theme = ThemeProvider.useTheme()
  let targetRef = React.useRef(Nullable.null)
  let (layout, setLayout) = React.useState(() => None)
  let (isDragging, setIsDragging) = React.useState(() => false)

  // The element that actually owns horizontal scrolling: either the table wrapper
  // itself or, when the table delegates scrolling, its closest scrollable ancestor.
  let findTarget = container => {
    let rec find = element =>
      if element->getComputedStyle->isScrollable {
        DOMUtils.scrollWidth(element) > DOMUtils.clientWidth(element) ? Some(element) : None
      } else {
        element->parentElement->Nullable.toOption->Option.flatMap(find)
      }
    find(container)
  }

  let measure = (container, target) => {
    let bounds = getRect(container)
    let targetBounds = getRect(target)
    let left = ref(Math.max(0., targetBounds.left))
    let right = ref(Math.min(innerWidth, targetBounds.right))
    let top = ref(Math.max(0., bounds.top))
    let bottom = ref(Math.min(innerHeight, bounds.bottom))

    // Clip against every scrolling ancestor, not just the viewport, so the bar never
    // escapes the panel or drawer the table sits in.
    let rec clip = element => {
      let style = element->getComputedStyle
      let rect = getRect(element)
      if style.overflowY !== "visible" {
        top := Math.max(top.contents, rect.top)
        bottom := Math.min(bottom.contents, rect.bottom)
      }
      if style.overflowX !== "visible" {
        left := Math.max(left.contents, rect.left)
        right := Math.min(right.contents, rect.right)
      }
      element->parentElement->Nullable.toOption->Option.forEach(clip)
    }
    target->parentElement->Nullable.toOption->Option.forEach(clip)

    let width = right.contents -. left.contents
    let scrollWidth = DOMUtils.scrollWidth(target)->Int.toFloat
    let clientWidth = DOMUtils.clientWidth(target)->Int.toFloat

    // Nothing worth showing when the table is scrolled out of view or too narrow.
    if bottom.contents -. top.contents > barHeight *. 2. && width > minThumbWidth *. 2. {
      let thumbWidth = Math.max(width *. clientWidth /. scrollWidth, minThumbWidth)
      let maxScroll = scrollWidth -. clientWidth
      let progress = maxScroll > 0. ? Math.min(scrollLeft(target) /. maxScroll, 1.) : 0.
      Some({
        left: left.contents,
        top: bottom.contents -. barHeight,
        width,
        thumbLeft: (width -. thumbWidth) *. progress,
        thumbWidth,
        progress,
      })
    } else {
      None
    }
  }

  let update = () => {
    let next = switch containerRef.current->Nullable.toOption {
    | None => None
    | Some(container) =>
      targetRef.current = container->findTarget->Nullable.fromOption
      targetRef.current->Nullable.toOption->Option.flatMap(measure(container, ...))
    }
    setLayout(previous =>
      switch (previous, next) {
      | (Some(a), Some(b)) if a == b => previous
      | (None, None) => previous
      | _ => next
      }
    )
  }

  let frameRef = React.useRef(0)
  let endDragRef = React.useRef(() => ())
  let schedule = () =>
    if frameRef.current === 0 {
      frameRef.current = requestFrame(_ => {
        frameRef.current = 0
        update()
      })
    }

  React.useEffect0(() => {
    let observer = ref(None)

    // Deferred by a frame so the container ref is attached no matter where this is
    // mounted in the table's tree.
    let setupFrame = requestFrame(_ => {
      containerRef.current
      ->Nullable.toOption
      ->Option.forEach(
        container => {
          let resizeObserver = DOMUtils.createResizeObserver(_ => schedule())
          resizeObserver->DOMUtils.observeElement(container)
          container
          ->querySelector("table")
          ->Nullable.toOption
          ->Option.forEach(table => resizeObserver->DOMUtils.observeElement(table))
          // The wrapper matters too: collapsing the sidebar changes the scroll range.
          container
          ->parentElement
          ->Nullable.toOption
          ->Option.forEach(parent => resizeObserver->DOMUtils.observeElement(parent))
          observer := Some(resizeObserver)
        },
      )
      update()
    })

    addListener("scroll", schedule, true)
    addListener("resize", schedule, false)

    Some(
      () => {
        observer.contents->Option.forEach(DOMUtils.disconnectObserver)
        removeListener("scroll", schedule, true)
        removeListener("resize", schedule, false)
        cancelFrame(setupFrame)
        cancelFrame(frameRef.current)
        // A drag in flight keeps window listeners alive, so drop them on unmount too.
        endDragRef.current()
      },
    )
  })

  let scrollTo = (~progress) =>
    targetRef.current
    ->Nullable.toOption
    ->Option.forEach(target => {
      let maxScroll = (DOMUtils.scrollWidth(target) - DOMUtils.clientWidth(target))->Int.toFloat
      setScrollLeft(target, Math.max(Math.min(progress, 1.), 0.) *. maxScroll)
      schedule()
    })

  let scrollBy = delta =>
    targetRef.current
    ->Nullable.toOption
    ->Option.forEach(target => {
      setScrollLeft(target, scrollLeft(target) +. delta)
      schedule()
    })

  let startDrag = (~pointerX, ~layout: layout) => {
    setIsDragging(_ => true)
    let originX = ref(pointerX)
    let originThumbLeft = ref(layout.thumbLeft)
    let travel = layout.width -. layout.thumbWidth

    let onMove = ref(_ => ())
    let onUp = ref(_ => ())
    onMove :=
      (
        event => {
          let thumbLeft = originThumbLeft.contents +. (event.clientX -. originX.contents)
          scrollTo(~progress=travel > 0. ? thumbLeft /. travel : 0.)
        }
      )

    onUp :=
      (
        _ => {
          setIsDragging(_ => false)
          removePointerListener("pointermove", onMove.contents, true)
          removePointerListener("pointerup", onUp.contents, true)
          removePointerListener("pointercancel", onUp.contents, true)
          endDragRef.current = () => ()
        }
      )

    addPointerListener("pointermove", onMove.contents, true)
    addPointerListener("pointerup", onUp.contents, true)
    addPointerListener("pointercancel", onUp.contents, true)
    endDragRef.current = () => onUp.contents({clientX: 0.})
  }

  switch layout {
  | None => React.null
  | Some(layout) =>
    // Same thumb colour the app's native scrollbars use (see tailwind.config.js).
    let (trackColor, thumbColor) = switch theme {
    | ThemeProvider.Dark => ("#151A1F", "#8A8C8F")
    | Light => ("#FFFFFF", "#8A8C8F")
    }
    let thumbOpacity = isDragging ? "opacity-100" : "opacity-70 hover:opacity-100"
    ReactDOM.createPortal(
      <div
        role="scrollbar"
        ariaLabel="Scroll table horizontally"
        ariaOrientation=#horizontal
        ariaValuemin=0.
        ariaValuemax=100.
        ariaValuenow={layout.progress *. 100.}
        tabIndex=0
        // Only the thumb takes pointer input, so the track never swallows clicks on the
        // table row underneath it.
        className="fixed z-20 select-none outline-none pointer-events-none"
        style={
          left: `${layout.left->Float.toString}px`,
          top: `${layout.top->Float.toString}px`,
          width: `${layout.width->Float.toString}px`,
          height: `${barHeight->Float.toString}px`,
          backgroundColor: trackColor,
        }
        onKeyDown={event =>
          switch event->ReactEvent.Keyboard.key {
          | "ArrowLeft" =>
            event->ReactEvent.Keyboard.preventDefault
            scrollBy(-80.)
          | "ArrowRight" =>
            event->ReactEvent.Keyboard.preventDefault
            scrollBy(80.)
          | "Home" =>
            event->ReactEvent.Keyboard.preventDefault
            scrollTo(~progress=0.)
          | "End" =>
            event->ReactEvent.Keyboard.preventDefault
            scrollTo(~progress=1.)
          | _ => ()
          }}>
        <div
          className={`absolute rounded-full cursor-pointer pointer-events-auto transition-opacity ${thumbOpacity}`}
          style={
            left: `${layout.thumbLeft->Float.toString}px`,
            top: `${((barHeight -. thumbHeight) /. 2.)->Float.toString}px`,
            width: `${layout.thumbWidth->Float.toString}px`,
            height: `${thumbHeight->Float.toString}px`,
            backgroundColor: thumbColor,
          }
          onPointerDown={event =>
            // Primary button only, so a right-click doesn't start a drag.
            if event->ReactEvent.Pointer.button === 0 {
              event->ReactEvent.Pointer.preventDefault
              startDrag(~pointerX=event->ReactEvent.Pointer.clientX->Int.toFloat, ~layout)
            }}
        />
      </div>,
      body,
    )
  }
}
