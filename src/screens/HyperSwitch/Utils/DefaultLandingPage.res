@react.component
let make = (
  ~width="98%",
  ~height="100%",
  ~title="",
  ~subtitle="",
  ~customStyle="",
  ~isButton=false,
  ~buttonText="Home",
  ~onClickHandler=_ => (),
  ~overriddingStylesTitle="",
  ~overriddingStylesSubtitle="",
) => {
  let appliedWidth = width === "98%" ? "98%" : width
  let appliedHeight = height === "100%" ? "100%" : height
  <div
    style={ReactDOMStyle.make(~width=appliedWidth, ~height=appliedHeight, ())}
    className={`m-5 bg-white dark:bg-jp-gray-lightgray_background dark:border-jp-gray-850 flex flex-col p-5 items-center justify-center ${customStyle}`}>
    <img src={`/assets/WorkInProgress.svg`} />
    <UIUtils.RenderIf condition={title->String.length !== 0}>
      <div className={`font-bold mt-5 ${overriddingStylesTitle}`}> {title->React.string} </div>
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={subtitle->String.length !== 0}>
      <div
        className={`mt-5 text-center text-semibold text-xl text-[#0E0E0E] ${overriddingStylesSubtitle}`}>
        {subtitle->React.string}
      </div>
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={isButton}>
      <div className="mt-7">
        <Button
          text={buttonText}
          buttonSize={Large}
          onClick={_ => onClickHandler()}
          buttonType=Secondary
          customButtonStyle={`!bg-blue-800`}
          textStyle={`!text-[#FFFFFF]`}
        />
      </div>
    </UIUtils.RenderIf>
  </div>
}
