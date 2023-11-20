@react.component
let make = (
  ~selectedStage: 'a,
  ~setSelectedStage,
  ~enableStage,
  ~setEnableStage,
  ~list: array<'a>,
  ~mapper: 'a => string,
  ~isSubmit=true,
  ~customNextClick=_ => (),
  ~buttonText="Submit",
  ~submitButton=?,
  ~showBackButton=true,
) => {
  let selectedIdx = list->Js.Array2.indexOf(selectedStage)
  let setSelectedIdx = offset => {
    let newStageIndex = selectedIdx + offset
    switch list[0] {
    | Some(ele) => {
        let newStage = list->Belt.Array.get(newStageIndex)->Belt.Option.getWithDefault(ele)
        setSelectedStage(_ => newStage)
      }
    | None => ()
    }
  }

  let backButton = if selectedIdx > 0 && showBackButton {
    <div className="mr-2">
      <Button
        text="Back"
        buttonType={isSubmit ? Secondary : Primary}
        leftIcon={CustomIcon(
          <Icon
            name="back"
            size=15
            className="mr-1 jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
          />,
        )}
        buttonSize=Small
        onClick={_ =>
          if selectedIdx > -1 {
            setSelectedIdx(-1)
            setEnableStage(_ => false)
          }}
      />
    </div>
  } else {
    React.null
  }

  let nextButton = if selectedIdx !== Js.Array2.length(list) - 1 {
    <Button
      text={"Next Step"}
      rightIcon={CustomIcon(
        <Icon
          name="arrow_right"
          size=15
          className="ml-1 jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
        />,
      )}
      buttonType=Primary
      buttonSize=Small
      onClick={_ => {
        customNextClick()
        if selectedIdx != Js.Array2.length(list) - 1 {
          setSelectedIdx(1)
          setEnableStage(_ => false)
        }
      }}
      buttonState={if enableStage {
        Normal
      } else {
        Disabled
      }}
    />
  } else if isSubmit {
    switch submitButton {
    | Some(btn) => btn
    | None =>
      <FormRenderer.SubmitButton
        text=buttonText
        customSumbitButtonStyle="w-30 !h-10"
        toolTipPosition={TopLeft}
        icon={Button.FontAwesome("save")}
      />
    }
  } else {
    React.null
  }
  let marginClass = "p-2 mb-3"
  <div
    className={`flex flex-row bg-white border dark:bg-jp-gray-lightgray_background border-jp-gray-lightmode_steelgray border-opacity-75 dark:border-jp-gray-960 rounded dark:shadow-generic_shadow_dark justify-between ${marginClass}`}>
    <div className="flex flex-row items-center gap-10">
      {list
      ->Js.Array2.map(mapper)
      ->Js.Array2.mapi((item, index) => {
        let font_highlight = if selectedIdx > index {
          "font-semibold text-black"
        } else {
          "font-regular text-jp-gray-900 text-opacity-50"
        }
        let textColor = if selectedIdx === index {
          "text-blue-800"
        } else {
          ""
        }
        <div
          key={index->string_of_int}
          className={`flex ${font_highlight} flex-row   dark:text-jp-gray-text_darktheme md:mr-5 mr-0 items-center `}>
          <div
            className={`mr-2
               ${index <= selectedIdx && index != selectedIdx
                ? "bg-green-800 text-white "
                : selectedIdx === index
                ? "bg-blue-800 text-white "
                : "bg-jp-gray-600 dark:bg-jp-gray-800 text-jp-gray-200 dark:text-gray-300"}  rounded-full h-7 w-7 flex items-center justify-center`}>
            {index <= selectedIdx && index != selectedIdx
              ? <Icon className="align-middle" name="check" size=12 />
              : React.string((index + 1)->string_of_int)}
          </div>
          <div className={`text-small px-2 ${textColor} dark:text-gray-400`}>
            {React.string(item)}
          </div>
          <div className="md:pl-12 pl-2">
            {if index == list->Js.Array2.length - 1 {
              React.null
            } else {
              <Icon
                className="align-middle text-gray-300 dark:text-gray-600"
                size=14
                name="chevron-right"
              />
            }}
          </div>
        </div>
      })
      ->React.array}
    </div>
    <div className="flex flex-row  text-semibold">
      <div className="flex flex-row gap-2">
        backButton
        nextButton
      </div>
    </div>
  </div>
}
