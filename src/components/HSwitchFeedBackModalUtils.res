type modalType = FeedBackModal | RequestConnectorModal

let makeFieldInfo = FormRenderer.makeFieldInfo

let feedbackTextBox = makeFieldInfo(
  ~label="",
  ~name="feedbacks",
  ~placeholder="Tell us in words...",
  ~customInput=InputFields.multiLineTextInput(~isDisabled=false, ~rows=Some(6), ~cols=Some(4), ()),
  (),
)

type feedbackType = Suggestion | Bugs | RequestConnector | Other

let feedbackTypeList = [Suggestion, Bugs, Other]

let getFeedBackStringFromVariant = feedbackType => {
  switch feedbackType {
  | Suggestion => "Suggestion"
  | Bugs => "Bugs"
  | RequestConnector => "Request A Connector"
  | Other => "Other"
  }
}

let selectFeedbackType = makeFieldInfo(
  ~name="category",
  ~label="",
  ~customInput=InputFields.radioInput(
    ~options=feedbackTypeList->Array.map(getFeedBackStringFromVariant)->SelectBox.makeOptions,
    ~buttonText="options",
    ~isHorizontal=true,
    (),
  ),
  (),
)

let connectorNameField = makeFieldInfo(
  ~label="Connector Name",
  ~name="connector_name",
  ~placeholder="Enter a connector name",
  ~customInput=InputFields.textInput(),
  (),
)

let connectorDescription = makeFieldInfo(
  ~label="Description",
  ~name="description",
  ~placeholder="Write here...",
  ~customInput=InputFields.multiLineTextInput(~isDisabled=false, ~rows=Some(6), ~cols=Some(4), ()),
  (),
)

let validateFields = (values, ~modalType) => {
  open LogicUtils
  let errors = Dict.make()
  let values = values->getDictFromJsonObject

  switch modalType {
  | FeedBackModal => {
      if values->getInt("rating", -1) === -1 {
        errors->Dict.set("rating", "Please rate"->Js.Json.string)
      }

      if values->getString("category", "") !== "" && values->getString("feedbacks", "") === "" {
        errors->Dict.set("feedbacks", "Please give the feedback"->Js.Json.string)
      }
    }
  | RequestConnectorModal =>
    if values->getString("connector_name", "")->String.length <= 0 {
      errors->Dict.set("connector_name", "Please enter a connector name"->Js.Json.string)
    }
  }

  errors->Js.Json.object_
}
