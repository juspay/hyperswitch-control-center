open LogicUtils
type accordion = Accordion.accordion
type arrowPosition = Accordion.arrowPosition

module BlendAccordion = {
  @react.component
  let make = (
    ~accordion: array<accordion>,
    ~arrowPosition=Accordion.Left,
    ~gapClass="",
    ~singleOpen=false,
    ~initialOpenIndex=-1,
    ~initialExpandedArray=[],
    ~hasCustomHeaders=false,
  ) => {
    let initialOpen = if singleOpen {
      initialOpenIndex >= 0 ? [initialOpenIndex->Int.toString] : []
    } else {
      initialExpandedArray->getNonEmptyArray->Option.mapOr([], arr => arr->Array.map(Int.toString))
    }
    let (openValues, setOpenValues) = React.useState(_ => initialOpen)

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
        s->getNonEmptyString->Option.mapOr([], s => [s])
      }
    }

    let handleValueChange = newVal => {
      let newValues = normalizeValue(newVal)

      // Fire onItemExpandClick for newly opened items
      newValues->Array.forEach(v => {
        if !(openValues->Array.includes(v)) {
          let idx = v->getIntFromString(-1)
          accordion
          ->Array.get(idx)
          ->Option.forEach(item => {
            item.onItemExpandClick->Option.forEach(fn => fn())
          })
        }
      })

      let isSwitch = singleOpen && newValues->isNonEmptyArray
      if !isSwitch {
        openValues->Array.forEach(v => {
          if !(newValues->Array.includes(v)) {
            let idx = v->getIntFromString(-1)
            accordion
            ->Array.get(idx)
            ->Option.forEach(item => {
              item.onItemCollapseClick->Option.forEach(fn => fn())
            })
          }
        })
      }

      setOpenValues(_ => newValues)
    }

    // Allows renderContent to close its own item programmatically
    let makeCloseAccordionFn = (i: int) => () => {
      setOpenValues(prev => prev->Array.filter(v => v !== i->Int.toString))
    }

    let blendValue = if singleOpen {
      openValues->getValueFromArray(0, "")->AccordionBinding.Value.fromString
    } else {
      openValues->AccordionBinding.Value.fromArray
    }

    let renderAccordion = children => {
      if hasCustomHeaders {
        <AccordionBinding.Legacy
          value=blendValue
          onValueChange=handleValueChange
          isMultiple={!singleOpen}
          isCollapsible=true
          accordionType=AccordionBinding.Border>
          children
        </AccordionBinding.Legacy>
      } else {
        <AccordionBinding
          value=blendValue
          onValueChange=handleValueChange
          isMultiple={!singleOpen}
          accordionType=AccordionBinding.Border>
          children
        </AccordionBinding>
      }
    }

    // Form listens for Enter on window; accordion triggers must not submit the form.
    <div
      className={`w-full ${gapClass}`}
      onKeyDown={event => {
        if (
          event->ReactEvent.Keyboard.key == "Enter" &&
            Document.activeElement
            ->Webapi.Dom.Element.getAttribute("data-radix-collection-item")
            ->Option.isSome
        ) {
          event->ReactEvent.Keyboard.stopPropagation
        }
      }}>
      {accordion
      ->Array.mapWithIndex((item, i) => {
        let isOpen = openValues->Array.includes(i->Int.toString)

        let children = item.renderContent(
          ~currentAccordionState=isOpen,
          ~closeAccordionFn=makeCloseAccordionFn(i),
        )
        if hasCustomHeaders {
          <AccordionBinding.LegacyItem
            key={i->Int.toString}
            value={i->Int.toString}
            title={item.renderContentOnTop->Option.mapOr(React.string(item.title), fn => fn())}
            chevronPosition={mapChevronPosition(arrowPosition)}>
            children
          </AccordionBinding.LegacyItem>
        } else {
          <AccordionBinding.Item
            key={i->Int.toString}
            value={i->Int.toString}
            title={item.title}
            chevronPosition={mapChevronPosition(arrowPosition)}>
            children
          </AccordionBinding.Item>
        }
      })
      ->React.array
      ->renderAccordion}
    </div>
  }
}

@react.component
let make = (
  ~accordion: array<accordion>,
  ~arrowFillColor: string="#CED0DA",
  ~accordionTopContainerCss: string="mt-5 rounded-lg",
  ~accordionBottomContainerCss: string="p-4",
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
  let isBlendEnabled = BlendContext.useBlendEnabled()
  // V2 accepts only string titles; retain Blend V1 semantics for interactive headers.
  let hasCustomHeaders = accordion->Array.some(item => item.renderContentOnTop->Option.isSome)

  <>
    <RenderIf condition=isBlendEnabled>
      <BlendAccordion
        accordion
        arrowPosition
        gapClass
        singleOpen
        initialOpenIndex
        initialExpandedArray
        hasCustomHeaders
      />
    </RenderIf>
    <RenderIf condition={!isBlendEnabled}>
      <Accordion
        accordion
        arrowFillColor
        accordionTopContainerCss
        accordionBottomContainerCss
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
    </RenderIf>
  </>
}
