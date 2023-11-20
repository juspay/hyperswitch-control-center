type appType = UPI | EULER
let bgClass = "bg-white hover:bg-jp-gray-100"
@val @scope(("window", "location")) external pathName: string = "pathname"

module MenuOption = {
  @react.component
  let make = (~text=?, ~children=?, ~onClick=?) => {
    <button
      className={`px-4 py-3 flex text-sm w-full text-gray-700 cursor-pointer ${bgClass}`} ?onClick>
      {switch text {
      | Some(str) => React.string(str)
      | None => React.null
      }}
      {switch children {
      | Some(elem) => elem
      | None => React.null
      }}
    </button>
  }
}

module NameIcon = {
  @react.component
  let make = (~name, ~onClick=?) => {
    let words =
      name
      ->Js.String2.toUpperCase
      ->Js.String2.replaceByRe(%re("/_/g"), " ")
      ->Js.String2.split(" ")
      ->Js.Array2.filter(x => x !== "")
    let firstLetters =
      words->Js.Array2.map(word => Js.String2.charAt(word, 0))->Js.Array2.joinWith("")
    <div ?onClick className="flex items-center justify-center h-8 w-8 rounded-full bg-gray-200">
      {firstLetters->Js.String2.slice(~from=0, ~to_=2)->React.string}
    </div>
  }
}

module FeedbackModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let makeFieldInfo = FormRenderer.makeFieldInfo
    let field = makeFieldInfo(
      ~label="",
      ~name="feedbacks",
      ~placeholder="Please provide your feedback/suggestions here ...",
      ~customInput=InputFields.multiLineTextInput(
        ~isDisabled=false,
        ~rows=Some(6),
        ~cols=Some(4),
        (),
      ),
      (),
    )

    let selectBetween = makeFieldInfo(
      ~name="category",
      ~label="",
      ~customInput=InputFields.radioInput(
        ~options=["Suggestion", "Bugs", "Other"]->SelectBox.makeOptions,
        ~buttonText="options",
        ~isHorizontal=true,
        (),
      ),
      (),
    )

    let validate = values => {
      let errors = Js.Dict.empty()
      let values = values->LogicUtils.getDictFromJsonObject
      if values->LogicUtils.getString("feedbacks", "") === "" {
        errors->Js.Dict.set("feedbacks", "Please give the feedback"->Js.Json.string)
      }
      if values->LogicUtils.getString("category", "") === "" {
        errors->Js.Dict.set("category", "Please select the category"->Js.Json.string)
      }
      if values->LogicUtils.getInt("rating", -1) === -1 {
        errors->Js.Dict.set("rating", "Please rate"->Js.Json.string)
      }
      errors->Js.Json.object_
    }

    let onSubmit = (_, _) => {
      setShowModal(_ => false)
      Js.Nullable.null->Js.Promise.resolve
    }

    <Modal
      modalHeading="Send Us Your Feedback"
      modalHeadingDescription="Tell us what you liked most and if you have a suggestion or found some bug, let us know in the field below"
      headingClass="!bg-transparent"
      showModal
      setShowModal
      borderBottom=true
      closeOnOutsideClick=true
      modalClass="md:w-2/5 mx-auto my-8 p-4 pb-8">
      <ReactFinalForm.Form
        subscription=ReactFinalForm.subscribeToValues
        onSubmit
        validate
        render={({handleSubmit}) => {
          <form onSubmit={handleSubmit}>
            <div className="flex flex-col justify-center mb-2">
              <RatingOptions
                icons=["angry", "frown", "smile", "smile-beam", "grin-hearts"] size=45
              />
              <FormRenderer.FieldRenderer field />
              <FormRenderer.FieldRenderer field=selectBetween />
              <div className="flex justify-end p-1 mt-4">
                <FormRenderer.SubmitButton text="Send Feedback" />
              </div>
            </div>
          </form>
        }}
      />
    </Modal>
  }
}

@react.component
let make = (
  ~headerActions=?,
  ~midUiActions=?,
  ~notificationActions=?,
  ~faqsActions as _=?,
  ~outageActions=?,
  ~liveMode=?,
  ~customHeight="",
  ~portalStyle="",
  ~homeLink="/",
  ~popOverPanelCustomClass="",
) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (isAppearancePopupOpen, setIsAppearancePopupOpen) = React.useState(_ => false)
  let {setIsSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)
  let (authStatus, _setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)

  let mobileMargin = isMobileView ? "" : "mr-7"

  let leftPortalName = isMobileView ? "mobileNavbarTitle" : "desktopNavbarLeft"

  let ref = React.useRef(Js.Nullable.null)
  OutsideClick.useOutsideClick(
    ~refs=ArrayOfRef([ref]),
    ~isActive=isAppearancePopupOpen,
    ~callback=() => {
      setIsAppearancePopupOpen(_ => false)
    },
    (),
  )

  let leftMarginOnNav = "ml-0"
  switch authStatus {
  | LoggedIn(_info) =>
    <div id="navbar" className={`w-full mx-auto`}>
      <div
        className={`flex flex-row items-start justify-between min-h-16 items-center ${customHeight}`}>
        <div className={`flex flex-wrap ml-5 justify-between items-center w-full`}>
          <PortalCapture key=leftPortalName name=leftPortalName customStyle={`${portalStyle}`} />
          <div className="flex flex-row place-content-centerx">
            <PortalCapture key="desktopNavbarCenter" name="desktopNavbarCenter" />
          </div>
          <div className="flex flex-row items-center">
            <PortalCapture key="desktopNavbarRight" name="desktopNavbarRight" />
            <PortalCapture key="desktopNavYoutubeLink" name="desktopNavYoutubeLink" />
          </div>
        </div>
        <div className="flex-1 flex items-center justify-center sm:items-stretch sm:justify-start">
          <div className="flex-shrink-0 flex items-center" />
        </div>
        {switch midUiActions {
        | Some(actions) => actions
        | None => React.null
        }}
        <div
          className={` inset-y-0 right-0 flex items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0  ${mobileMargin}`}>
          {switch headerActions {
          | Some(actions) => actions
          | None => React.null
          }}
          {switch outageActions {
          | Some(actions) => actions
          | None => React.null
          }}
          {if isMobileView {
            switch liveMode {
            | Some(actions) => actions
            | None => React.null
            }
          } else {
            React.null
          }}
          {switch notificationActions {
          | Some(actions) => actions
          | None => React.null
          }}
          <div className={`mt-2 ${leftMarginOnNav}`}>
            <PortalCapture key="onboarding" name="onboarding" />
          </div>
          <div
            onClick={_ => {
              setIsSidebarExpanded(prev => !prev)
            }}
            className={`h-full px-1.5 flex items-center focus:outline-none cursor-pointer transform transition duration-500 ease-in-out md:hidden`}>
            <Icon className="align-middle" name="bars" />
          </div>
        </div>
      </div>
      <div className="ml-5">
        <PortalCapture key="navbarSecondRow" name="navbarSecondRow" />
      </div>
      <HSwitchFeedBackModal modalHeading="We'd love to hear from you!" setShowModal showModal />
    </div>
  // </div>

  | LoggedOut => React.null
  | CheckingAuthStatus => React.string("...")
  }
}
