open ExploreWorkflowsTypes
open ExploreWorkflowsUtils
open Typography

module InternalWorkflowDisplayCard = {
  open Button

  @react.component
  let make = (
    ~title: string,
    ~description: string,
    ~buttonText: string,
    ~onButtonClick: unit => unit,
    ~graphicComponent: React.element,
  ) => {
    <div
      className="border rounded-2xl p-6 bg-white dark:bg-jp-gray-950 flex flex-col justify-between h-full">
      <div>
        <div
          className="h-40 mb-4 bg-jp-gray-50 dark:bg-jp-gray-900 rounded-lg flex items-center justify-center">
          graphicComponent
        </div>
        <div className="flex flex-col gap-1 mb-4">
          <h3 className={`${body.lg.semibold} text-nd_gray-700 `}> {title->React.string} </h3>
          <p className={`${body.md.medium} text-nd_gray-400`}> {description->React.string} </p>
        </div>
      </div>
      <div className="mt-auto">
        <Button.make
          text=buttonText
          buttonType=Secondary
          buttonSize=Large
          buttonState=Normal
          onClick={_ => onButtonClick()}
        />
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let {setWorkflowDrawerState} = React.useContext(GlobalProvider.defaultContext)
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let renderGraphic = (cardData: cardDetails) => {
    <img
      src={"/assets/workflows/" ++ cardData.imageLink}
      alt=cardData.title
      className="object-contain h-full w-full"
    />
  }

  <div className="py-6">
    <div className="flex flex-col gap-2 mb-6">
      <p className={heading.md.semibold}> {"Explore Workflows"->React.string} </p>
      <p className={`${body.lg.medium} text-nd_gray-400`}>
        {"Discover and configure powerful workflows to optimize your payment operations."->React.string}
      </p>
    </div>
    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
      {workflowCardsData
      ->Array.mapWithIndex((cardData, index) =>
        <InternalWorkflowDisplayCard
          key={index->Int.toString}
          title={cardData.title}
          description={cardData.description}
          buttonText={cardData.buttonText}
          onButtonClick={() => {
            mixpanelEvent(~eventName=`${cardData.buttonText->LogicUtils.titleToSnake}_button_click`)
            setWorkflowDrawerState(_ => FullWidth(cardData.workflowType))
          }}
          graphicComponent={renderGraphic(cardData)}
        />
      )
      ->React.array}
    </div>
  </div>
}
