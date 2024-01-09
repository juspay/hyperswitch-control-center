module Tag = {
  @react.component
  let make = (~text, ~remove, ~customButtonStyle=?, ~disabled=false) => {
    let handleOnRemove = e => {
      e->ReactEvent.Mouse.stopPropagation
      remove(text)
    }

    let buttonStyle = switch customButtonStyle {
    | Some(buttonStyle) => buttonStyle
    | None => ""
    }

    if !disabled {
      <Button
        customButtonStyle={`h-8 ${buttonStyle}`}
        text
        textWeight="font-bold"
        disableRipple=true
        textStyle="text-inherit dark:text-white"
        rightIcon={CustomIcon(
          <Icon name="close" size=10 className="mr-1" onClick={handleOnRemove} />,
        )}
      />
    } else {
      React.null
    }
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~name="tag_value",
  ~disabled=false,
  ~seperateByComma=false,
  ~seperateBySpace=false,
  ~customStyle=?,
  ~placeholder="",
  ~autoComplete=?,
  ~customButtonStyle=?,
) => {
  let showPopUp = PopUpState.useShowPopUp()
  let currentTags = React.useMemo1(() => {
    input.value
    ->Js.Json.decodeArray
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(Js.Json.decodeString)
  }, [input.value])

  let setTags = tags => {
    tags->Identity.arrayOfGenericTypeToFormReactEvent->input.onChange
  }

  let (text, setText) = React.useState(_ => "")
  let customStyleClass = customStyle->Belt.Option.getWithDefault("gap-2 w-full px-1 py-1")
  let onTagRemove = text => {
    setTags(currentTags->Array.filter(tag => tag !== text))
  }
  let keyDownCondition = React.useMemo0(() => {
    open ReactEvent.Keyboard
    ev => {
      if ev->keyCode === 13 {
        ev->preventDefault
        ev->stopPropagation
      }
      ev->keyCode === 9
    }
  })
  let handleKeyDown = e => {
    open ReactEvent.Keyboard
    let isEmpty = text->String.length === 0

    if isEmpty && (e->key === "Backspace" || e->keyCode === 8) && currentTags->Array.length > 0 {
      setText(_ => currentTags[currentTags->Array.length - 1]->Belt.Option.getWithDefault(""))
      setTags(currentTags->Array.slice(~start=0, ~end=-1))
    } else if text->String.length !== 0 {
      if e->key === "Enter" || e->keyCode === 13 || e->key === "Tab" || e->keyCode === 9 {
        if seperateByComma {
          let arr = text->String.split(",")
          let newArr = []
          arr->Array.forEach(ele => {
            if (
              !(newArr->Array.includes(ele->String.trim)) &&
              !(currentTags->Array.includes(ele->String.trim))
            ) {
              if ele->String.trim != "" {
                newArr->Array.push(ele->String.trim)->ignore
              }
            }
          })

          setTags(currentTags->Array.concat(newArr))
        } else if seperateBySpace {
          let arr = text->String.split(" ")
          let newArr = []
          arr->Array.forEach(ele => {
            if (
              !(newArr->Array.includes(ele->String.trim)) &&
              !(currentTags->Array.includes(ele->String.trim))
            ) {
              if ele->String.trim != "" {
                newArr->Array.push(ele->String.trim)->ignore
              }
            }
          })

          setTags(currentTags->Array.concat(newArr))
        } else if !(currentTags->Array.includes(text->String.trim)) {
          setTags(currentTags->Array.concat([text->String.trim]))
        }
        setText(_ => "")
      }
    }
  }
  let input1: ReactFinalForm.fieldRenderPropsInput = {
    {
      name,
      onBlur: _ev => (),
      onChange: ev => {
        let value = {ev->ReactEvent.Form.target}["value"]
        if value->String.includes("<script>") || value->String.includes("</script>") {
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: `Script Tags are not allowed`,
            description: React.string(`Input cannot contain <script>, </script> tags`),
            handleConfirm: {text: "OK"},
          })
        }
        let val = value->String.replace("<script>", "")->String.replace("</script>", "")
        setText(_ => val)
      },
      onFocus: _ev => (),
      value: Js.Json.string(text),
      checked: false,
    }
  }

  let className = `flex flex-wrap items-center  ${customStyleClass} bg-transparent
                  text-jp-gray-900 text-opacity-75 dark:text-jp-gray-text_darktheme dark:text-opacity-75 text-sm font-semibold 
                  placeholder-jp-gray-900 placeholder-opacity-25 dark:placeholder-jp-gray-text_darktheme dark:placeholder-opacity-25
                  border rounded border-opacity-75 border-jp-gray-lightmode_steelgray hover:border-jp-gray-600 dark:border-jp-gray-960 dark:hover:border-jp-gray-900`
  <div className>
    {currentTags
    ->Array.map(tag => {
      if tag != "" && tag !== "<script>" && tag !== "</script>" {
        <Tag key=tag text=tag remove=onTagRemove disabled ?customButtonStyle />
      } else {
        React.null
      }
    })
    ->React.array}
    <TextInput
      input=input1
      focusOnKeyPress={keyDownCondition}
      placeholder
      ?autoComplete
      onKeyUp=handleKeyDown
      isDisabled=disabled
      customStyle="dark:bg-jp-gray-970 border-none"
    />
  </div>
}
