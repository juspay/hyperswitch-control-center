@react.component
let make = (
  ~modalHeading="Select Options",
  ~modalHeadingDescription="",
  ~showModal,
  ~setShowModal,
  ~onSubmit,
  ~initialValues,
  ~options,
  ~revealFrom=Reveal.Right,
  ~closeOnOutsideClick=true,
  ~title="Columns",
  ~submitButtonText=?,
  ~disableSelect=false,
  ~showDeSelectAll=false,
  ~maxSelection=-1,
  ~enableSelect=false,
  ~buttonClickable=true,
  ~addCheckboxButton=false,
  ~checkboxButtonText="",
  ~setIsCheckboxSelected=?,
  ~isCheckboxSelected=false,
  ~totalVolume=0,
) => {
  let maxLengthArray = (arr, setValues) => {
    switch maxSelection {
    | -1 => setValues(_ => arr)
    | _ =>
      if arr->Js.Array.length > maxSelection {
        let temp = arr->Js.Array2.sliceFrom(arr->Js.Array.length - maxSelection)
        setValues(_ => temp)
      } else {
        setValues(_ => arr)
      }
    }
  }

  let (values, setValues) = React.useState(_ => initialValues)
  let onClick = _ => values->onSubmit

  let disableSelectBtn = React.useMemo2(
    () =>
      (initialValues->Js.Array.toString === values->Js.Array.toString && !enableSelect) ||
        values->Js.Array2.length === 0,
    (values, initialValues),
  )

  let len = values->Js.Array2.length
  let allowCompressed = len * totalVolume > 1310720
  let disableCheckbox = React.useMemo2(
    () => disableSelectBtn || !allowCompressed,
    (disableSelectBtn, allowCompressed),
  )
  let buttonText =
    submitButtonText->Belt.Option.getWithDefault(
      len > 0 ? `${len->Belt.Int.toString} ${title} Selected` : "Select",
    )
  let buttonUi = (disableSelectBtn, buttonClickable, onClick, buttonText) => {
    <Button
      text=buttonText
      buttonType=Primary
      onClick
      buttonState={disableSelectBtn || !buttonClickable ? Disabled : Normal}
    />
  }

  React.useEffect2(() => {
    if !showModal {
      setValues(_ => initialValues)
    }
    None
  }, (showModal, initialValues))

  <Modal
    modalHeading
    modalHeadingDescription
    paddingClass=""
    showModal
    setShowModal
    closeOnOutsideClick
    revealFrom
    modalClass="w-full h-screen md:w-96 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
    headingClass="py-6 px-2.5 h-24 border-b border-solid flex flex-col justify-center !bg-white dark:!bg-black border-slate-300"
    headerTextClass="text-3xl font-semibold tracking-tight"
    childClass="p-0 m-0">
    <div
      className="overflow-auto p-6 border-b border-solid  border-slate-300 dark:border-slate-500"
      style={ReactDOMStyle.make(~height="calc(100vh - 12rem)", ())}>
      <SelectBox.BaseSelect
        isDropDown=false
        options
        onSelect={arr => maxLengthArray(arr, setValues)}
        value={values->Js.Json.stringArray}
        showSelectAll=false
        showSerialNumber=true
        maxHeight="max-h-full"
        searchable=true
        searchInputPlaceHolder={`Search in ${options->Js.Array2.length->string_of_int} options`}
        customStyle="px-2 py-1"
        customSearchStyle="bg-white dark:bg-jp-gray-lightgray_background"
        disableSelect
      />
    </div>
    <div
      className="flex flex-row items-center overflow-hidden justify-center mt-1.5 mb-1 h-20 gap-2 relative">
      {if showDeSelectAll && values->Js.Array2.length > 0 {
        <Button
          text="DESELECT ALL"
          buttonState={disableSelect ? Disabled : Normal}
          onClick={_ => setValues(_ => [])}
        />
      } else {
        React.null
      }}
      {if addCheckboxButton {
        <div className="flex flex-col place-items-start mt-1.5 mb-1 h-20 gap-y-4 ">
          <div
            className={disableSelectBtn || !allowCompressed
              ? "flex flex-row my-2 absolute left-7 gap-4 items-center cursor-not-allowed disabled:opacity-55"
              : "flex flex-row my-2 absolute left-7 gap-4 items-center"}>
            <CheckBoxIcon
              isSelected=isCheckboxSelected
              isDisabled=disableCheckbox
              setIsSelected=?setIsCheckboxSelected
            />
            <b> {React.string(checkboxButtonText)} </b>
          </div>
          <div className="mt-10">
            {buttonUi(disableSelectBtn, buttonClickable, onClick, buttonText)}
          </div>
        </div>
      } else {
        buttonUi(disableSelectBtn, buttonClickable, onClick, buttonText)
      }}
    </div>
  </Modal>
}
