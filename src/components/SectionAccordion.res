open NewThemeUtils
type mobileRenderType = Modal | Accordion
@react.component
let make = (
  ~title="",
  ~titleSize: headingSize=Large,
  ~subtext="",
  ~children,
  ~mobileRenderType: mobileRenderType=Accordion,
  ~hideHeaderWeb=false,
  ~hideHeading=false,
  ~isMobileView=false,
  ~setShow=_ => (),
  ~show="",
) => {
  let titleClass = "md:font-bold font-medium md:text-fs-16 text-fs-13 text-jp-gray-900 text-opacity-75 dark:text-white  dark:text-opacity-75"

  let (isExpanded, setIsExpanded) = React.useState(_ => !isMobileView)

  let url = RescriptReactRouter.useUrl()
  let path =
    url.path->Belt.List.toArray->Js.Array2.joinWith("/")->Js.Global.decodeURI->Js.String2.split("/")
  let urlTitle = path[path->Js.Array2.length - 1]->Belt.Option.getWithDefault("")

  let bgCss = "bg-white dark:bg-jp-gray-lightgray_background"

  let checkTitle = isExpanded ? show === title ? "hidden" : "block" : "block"
  let noBorder =
    checkTitle === "hidden" ? "border-none" : "border-t-2 dark:border-jp-gray-950 md:border-0"
  let expandCondition = show !== "show" ? isExpanded ? "" : "hidden" : "hidden"

  React.useEffect1(_ => {
    if show !== "show" {
      setIsExpanded(_ => true)
    } else {
      setIsExpanded(_ => false)
    }
    None
  }, [show])
  let customBorder = Js.Array2.includes(["Configured Payment Methods"], show)
    ? "border m-4"
    : "border-none"
  let titleBorder = Js.Array2.includes(["Configured Payment Methods"], show) ? "border-b pb-4" : ""
  let borderCss = isExpanded ? customBorder : "border"

  <AddDataAttributes attributes=[("data-section", title)]>
    <div className={`${borderCss} md:border-0 dark:border-jp-gray-950 dark:bg-transparent`}>
      {if isMobileView {
        <div
          className={`${titleClass} ${bgCss} px-4 py-3 flex justify-start text-jp-gray-900 text-opacity-75 ${checkTitle}`}
          onClick={_ => {
            RescriptReactRouter.push(`/settings/${urlTitle}/${title}`)
            isMobileView
              ? {
                  setIsExpanded(prev => !prev)
                  setShow(title)
                }
              : ()
          }}>
          <div className={`py-1 !text-lg ${checkTitle}`}> {title->React.string} </div>
          <div
            className={`cursor-pointer flex justify-center align-center text-jp-gray-900 text-right text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-auto ${checkTitle}`}>
            <Icon name={isExpanded ? "angle-down" : "angle-right"} size=15 />
          </div>
        </div>
      } else if !hideHeaderWeb {
        <h3 className={`mt-7 text-fs-16 font-bold`}> {title->React.string} </h3>
      } else {
        React.null
      }}
      <DesktopView>
        <UIUtils.RenderIf condition={!hideHeaderWeb}>
          <p
            className="mt-2 text-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
            {subtext->React.string}
          </p>
        </UIUtils.RenderIf>
      </DesktopView>
      {if isMobileView {
        switch mobileRenderType {
        | Modal =>
          <Modal
            modalHeading=title
            showModal=isExpanded
            setShowModal=setIsExpanded
            borderBottom=true
            childClass="">
            <div className="mx-4 mb-4"> {children} </div>
          </Modal>
        | Accordion =>
          <div className={`${expandCondition} ${noBorder}`}>
            <div className={`${titleBorder}`}>
              <UIUtils.RenderIf condition={!hideHeading}>
                <div className={"text-fs-16 font-bold mt-4 ml-5"}> {title->React.string} </div>
              </UIUtils.RenderIf>
            </div>
            {children}
          </div>
        }
      } else {
        children
      }}
    </div>
  </AddDataAttributes>
}
