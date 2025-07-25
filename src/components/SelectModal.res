@react.component
let make = (
  ~modalHeading="Select Options",
  ~modalHeadingDescription="",
  ~showModal,
  ~setShowModal,
  ~isModalView=true,
  ~onSubmit,
  ~initialValues,
  ~options,
  ~revealFrom=Reveal.Right,
  ~closeOnOutsideClick=true,
  ~title="Columns",
  ~submitButtonText=?,
  ~disableSelect=false,
  ~showDeSelectAll=false,
  ~showSelectAll=true,
  ~maxSelection=-1,
  ~enableSelect=false,
  ~sortingBasedOnDisabled=true,
  ~showSerialNumber=true,
  ~showConversionRate=false,
  ~headerTextClass="text-3xl font-semibold tracking-tight",
  ~headerClass="",
  ~isDraggable=false,
) => {
  let maxLengthArray = (arr, setValues) => {
    switch maxSelection {
    | -1 => setValues(_ => arr)
    | _ =>
      if arr->Array.length > maxSelection {
        let temp = arr->Array.sliceToEnd(~start=arr->Array.length - maxSelection)
        setValues(_ => temp)
      } else {
        setValues(_ => arr)
      }
    }
  }

  let (values, setValues) = React.useState(_ => initialValues)
  let onClick = _ => values->onSubmit

  let disableSelectBtn = React.useMemo(
    () =>
      (initialValues->Array.toString === values->Array.toString && !enableSelect) ||
        values->Array.length === 0,
    (values, initialValues),
  )

  let len = values->Array.length
  let buttonText =
    submitButtonText->Option.getOr(len > 0 ? `${len->Int.toString} ${title} Selected` : "Select")

  React.useEffect(() => {
    if !showModal {
      setValues(_ => initialValues)
    }
    None
  }, (showModal, initialValues))

  let applyBtnStyle = "w-full mx-5"

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "cutomixedColumnsInput",
    onBlur: _ => (),
    onChange: ev => {
      let target = ev->Identity.formReactEventToArrayOfString
      maxLengthArray(target, setValues)
    },
    onFocus: _ => (),
    value: values->LogicUtils.getJsonFromArrayOfString,
    checked: false,
  }

  if isModalView {
    <Modal
      modalHeading
      modalHeadingDescription
      paddingClass=""
      showModal
      setShowModal
      closeOnOutsideClick
      revealFrom
      modalClass="w-full h-screen md:w-96 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
      headingClass={`${headerClass} py-6 px-2.5 h-24 border-b border-solid flex flex-col justify-center !bg-white dark:!bg-black border-slate-300`}
      headerTextClass
      childClass="p-0 m-0">
      <div
        className={`overflow-hidden p-6 pb-12 border-b border-solid  ${showConversionRate
            ? "border-slate-100"
            : "border-slate-300"} dark:border-slate-500`}
        style={
          height: `${showConversionRate ? "calc(100vh - 17rem)" : "calc(100vh - 12rem)"}`,
        }>
        <SelectBox.BaseSelect
          isDropDown=false
          options
          onSelect={arr => maxLengthArray(arr, setValues)}
          value={values->LogicUtils.getJsonFromArrayOfString}
          showSelectAll={showSelectAll}
          showSerialNumber
          maxHeight="max-h-full"
          searchable=true
          searchInputPlaceHolder={`Search in ${options->Array.length->Int.toString} options`}
          customStyle="px-2 py-1"
          customSearchStyle="bg-white dark:bg-jp-gray-lightgray_background"
          disableSelect
          isModalView
          sortingBasedOnDisabled
          isDraggable
        />
      </div>
      {showConversionRate
        ? <div className="bg-[#F6F6F6] p-4 border-b border-slate-300 text-center text-[#868686]">
            {React.string(
              `Conversion rate  = ${options
                ->Array.filter(itm => values->Array.get(0)->Option.getOr("") == itm.value)
                ->Array.map(item => item.label)
                ->Array.get(0)
                ->Option.getOr("Factor 1")} / ${options
                ->Array.filter(itm => values->Array.get(1)->Option.getOr("") == itm.value)
                ->Array.map(item => item.label)
                ->Array.get(0)
                ->Option.getOr("Factor 2")}`,
            )}
          </div>
        : React.null}
      <div
        className="flex flex-row items-center overflow-hidden justify-center mt-1.5 mb-1 h-20 gap-2">
        {if showDeSelectAll && values->Array.length > 0 {
          <Button
            text="DESELECT ALL"
            customButtonStyle=applyBtnStyle
            buttonState={disableSelect ? Disabled : Normal}
            onClick={_ => setValues(_ => [])}
          />
        } else {
          React.null
        }}
        <Button
          text=buttonText
          buttonType=Primary
          onClick
          customButtonStyle=applyBtnStyle
          buttonState={disableSelectBtn ? Disabled : Normal}
          buttonVariant={Fit}
        />
      </div>
    </Modal>
  } else {
    <SelectBox.BaseDropdown
      input
      options
      buttonText="Columns"
      showBorder=false
      allowMultiSelect=true
      hasApplyButton=true
      showSelectAll=false
      hideMultiSelectButtons=true
      onApply=onClick
    />
  }
}
