open Typography
open LogicUtils

module StatCard = {
  @react.component
  let make = (
    ~label: string,
    ~value: int,
    ~desc: string,
    ~descColor="text-nd_gray-400",
    ~onClick=?,
  ) => {
    let isClickable = onClick->Option.isSome

    <div
      className={`flex flex-col p-4 flex-1 min-w-0 ${isClickable
          ? "cursor-pointer hover:bg-nd_gray-50 transition-colors"
          : ""}`}
      onClick={_ => onClick->Option.mapOr((), fn => fn())}>
      <p className={`${body.xs.semibold} uppercase tracking-wide text-nd_gray-400 mb-1`}>
        {label->React.string}
      </p>
      <div className={`${heading.lg.semibold} text-nd_gray-800 mb-0.5`}>
        <ReconEngineOverviewSummaryHelper.NumberCell value />
      </div>
      <RenderIf condition={desc->isNonEmptyString}>
        <p className={`${body.xs.regular} ${descColor}`}> {desc->React.string} </p>
      </RenderIf>
    </div>
  }
}

module ErrorsModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~errors: array<(string, string)>) => {
    let modalScrollbarCss = `
      @supports (-webkit-appearance: none){
        .modal-scrollbar {
            scrollbar-width: auto;
            scrollbar-color: #CACFD8;
          }

        .modal-scrollbar::-webkit-scrollbar {
          display: block;
          height: 4px;
          width: 5px;
        }

        .modal-scrollbar::-webkit-scrollbar-thumb {
          background-color: #CACFD8;
          border-radius: 3px;
        }

        .modal-scrollbar::-webkit-scrollbar-track {
          display: none;
        }
    }`

    <>
      <style> {React.string(modalScrollbarCss)} </style>
      <Modal
        setShowModal
        showModal
        closeOnOutsideClick=true
        modalHeading={`View Errors (${errors->Array.length->Int.toString})`}
        modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
        alignModal="justify-center items-center"
        modalClass="flex flex-col justify-start !h-400-px w-2/5 !overflow-y-scroll !bg-white dark:!bg-jp-gray-lightgray_background"
        childClass="relative h-full">
        <div className="h-full relative">
          <div className="absolute inset-0 overflow-scroll px-8 py-4 modal-scrollbar mb-20">
            <RenderIf condition={errors->isNonEmptyArray}>
              <div className="flex flex-col gap-4">
                {errors
                ->Array.map(((transformationName, error)) =>
                  <div
                    key={randomString(~length=10)}
                    className="flex flex-row items-start p-3 rounded-lg bg-nd_red-50">
                    <Icon
                      name="nd-multiple-cross"
                      size=16
                      className="text-nd_red-400 mr-2 mt-0.5 flex-shrink-0"
                    />
                    <div className="flex flex-col gap-0.5">
                      <p className={`text-nd_gray-400 ${body.xs.medium}`}>
                        {transformationName->React.string}
                      </p>
                      <p className={`text-nd_gray-600 ${body.md.medium}`}>
                        {error->React.string}
                      </p>
                    </div>
                  </div>
                )
                ->React.array}
              </div>
            </RenderIf>
            <RenderIf condition={errors->isEmptyArray}>
              <NewAnalyticsHelper.NoData message="No Errors Found" height="h-40" />
            </RenderIf>
          </div>
          <div
            className="absolute flex justify-end bottom-0 w-full bg-white dark:bg-jp-gray-lightgray_background p-4 border-t border-nd_gray-150">
            <Button
              customButtonStyle="!w-fit"
              buttonType=Button.Primary
              onClick={_ => setShowModal(_ => false)}
              text="OK"
            />
          </div>
        </div>
      </Modal>
    </>
  }
}
