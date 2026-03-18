type accordion = Accordion.accordion
type arrowPosition = Accordion.arrowPosition

@react.component
let make = (
  ~accordion: array<accordion>,
  ~arrowFillColor: string="#CED0DA",
  ~accordianTopContainerCss: string="mt-5 rounded-lg",
  ~accordianBottomContainerCss: string="p-4",
  ~contentExpandCss="px-8 font-bold",
  ~arrowPosition=Accordion.Left,
  ~initialExpandedArray=[],
  ~gapClass="",
  ~titleStyle="font-bold text-lg text-jp-gray-700 dark:text-jp-gray-text_darktheme dark:text-opacity-50 hover:text-jp-gray-800 dark:hover:text-opacity-100",
  ~accordionHeaderTextClass="",
  ~expandedTitleStyle="",
  ~singleOpen=false,
  ~initialOpenIndex=-1,
) => {
  let isBlendEnabled = React.useContext(BlendContext.blendEnabledContext)

  // Hoisted above conditional to satisfy React hook rules
  let initialOpen = if initialExpandedArray->Array.length > 0 {
    initialExpandedArray->Array.map(Int.toString)
  } else if initialOpenIndex >= 0 {
    [initialOpenIndex->Int.toString]
  } else {
    []
  }
  let (openValues, setOpenValues) = React.useState(_ => initialOpen)

  if isBlendEnabled {
    let mapChevronPosition = pos =>
      switch pos {
      | Accordion.Left => AccordionBinding.Left
      | Accordion.Right => AccordionBinding.Right
      }

    // Blend passes string when isMultiple=false, array<string> when isMultiple=true
    let normalizeValue = (v: AccordionBinding.Value.t): array<string> => {
      if Js.Array.isArray(v) {
        v->AccordionBinding.Value.toArray
      } else {
        let s = v->AccordionBinding.Value.toString
        s->String.length === 0 ? [] : [s]
      }
    }

    let handleValueChange = newVal => {
      let newValues = normalizeValue(newVal)

      // Fire onItemExpandClick for newly opened items
      newValues->Array.forEach(v => {
        if !(openValues->Array.includes(v)) {
          let idx = v->Int.fromString->Option.getOr(-1)
          accordion->Array.get(idx)->Option.forEach(item => {
            item.onItemExpandClick->Option.forEach(fn => fn())
          })
        }
      })

      // Fire onItemCollapseClick for newly closed items
      openValues->Array.forEach(v => {
        if !(newValues->Array.includes(v)) {
          let idx = v->Int.fromString->Option.getOr(-1)
          accordion->Array.get(idx)->Option.forEach(item => {
            item.onItemCollapseClick->Option.forEach(fn => fn())
          })
        }
      })

      setOpenValues(_ => newValues)
    }

    // Allows renderContent to close its own item programmatically
    let makeCloseAccordionFn = (i: int) => () => {
      setOpenValues(prev => prev->Array.filter(v => v !== i->Int.toString))
    }

    // Blend expects string for single mode, array for multi mode
    let blendValue = if singleOpen {
      openValues->Array.get(0)->Option.getOr("")->AccordionBinding.Value.fromString
    } else {
      openValues->AccordionBinding.Value.fromArray
    }

    <AccordionBinding
      accordionType=AccordionBinding.Border
      value={blendValue}
      onValueChange={handleValueChange}
      isCollapsible=true
      isMultiple={!singleOpen}
      className=gapClass
    >
      {accordion
      ->Array.mapWithIndex((item, i) => {
        let isOpen = openValues->Array.includes(i->Int.toString)

        // Use renderContentOnTop as the Blend title element if present
        let titleElem = switch item.renderContentOnTop {
        | Some(fn) => fn()
        | None => React.string(item.title)
        }

        <AccordionBinding.Item
          key={i->Int.toString}
          value={i->Int.toString}
          title={titleElem}
          chevronPosition={mapChevronPosition(arrowPosition)}
        >
          {item.renderContent(
            ~currentAccordianState=isOpen,
            ~closeAccordionFn=makeCloseAccordionFn(i),
          )}
        </AccordionBinding.Item>
      })
      ->React.array}
    </AccordionBinding>
  } else {
    <Accordion
      accordion
      arrowFillColor
      accordianTopContainerCss
      accordianBottomContainerCss
      contentExpandCss
      arrowPosition
      initialExpandedArray
      gapClass
      titleStyle
      accordionHeaderTextClass
      expandedTitleStyle
      singleOpen
      initialOpenIndex
    />
  }
}
