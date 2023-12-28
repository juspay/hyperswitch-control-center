module Section = {
  @react.component
  let make = (
    ~children,
    ~customCssClass="border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-950 rounded-md p-0 m-3",
  ) => {
    <div className=customCssClass> children </div>
  }
}

module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~isInHeader=false,
    ~isHorizontal=false,
    ~customMoneyStyle="",
    ~labelMargin="",
    ~customDateStyle="",
    ~wordBreak=true,
    ~textColor="",
    ~overiddingHeadingStyles="",
  ) => {
    let marginClass = if labelMargin == "" {
      "mt-4 py-0"
    } else {
      labelMargin
    }

    let fontClass = if isInHeader {
      "text-fs-20"
    } else {
      "text-fs-13"
    }
    let breakWords = if wordBreak {
      "break-all"
    } else {
      ""
    }

    let textColor = textColor === "" ? "text-jp-gray-900 dark:text-white" : textColor

    let description = heading.description->Belt.Option.getWithDefault("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div className={`flex ${isHorizontal ? "flex-row gap-3" : "flex-col gap-1"} py-4`}>
          <div
            className="flex flex-row text-fs-11 leading-3 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 items-center">
            <div className={`${overiddingHeadingStyles}`}>
              {React.string(showTitle ? heading.title : "")}
            </div>
            <UIUtils.RenderIf condition={description != ""}>
              <div className="text-sm text-gray-500 mx-2 -mt-1">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </UIUtils.RenderIf>
          </div>
          <div className={`${fontClass} font-semibold text-left  mr-5 ${textColor} ${breakWords}`}>
            <Table.TableCell
              cell=value
              textAlign=Table.Left
              fontBold=true
              customMoneyStyle
              labelMargin=marginClass
              customDateStyle
            />
          </div>
        </div>
      </AddDataAttributes>
    }
  }
}

type topic =
  | String(string)
  | ReactElement(React.element)

module Heading = {
  @react.component
  let make = (~topic: topic, ~children=?, ~borderClass="border-b", ~headingCss="") => {
    let widthClass = headingCss === "" ? "" : "w-full"
    <div
      className={`${borderClass} border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 flex justify justify-between dark:bg-jp-gray-lightgray_background ${headingCss}`}>
      <div className={`p-2 m-2 flex flex-row justify-start ${widthClass}`}>
        {switch topic {
        | String(string) =>
          <AddDataAttributes attributes=[("data-heading", string)]>
            <span className="text-gray-600 dark:text-gray-400 font-bold text-base text-fs-16">
              {React.string({string})}
            </span>
          </AddDataAttributes>
        | ReactElement(element) => element
        }}
      </div>
      <div className="p-2 m-2 flex flex-row justify-end ">
        <span>
          {switch children {
          | Some(element) => element
          | None => React.null
          }}
        </span>
      </div>
    </div>
  }
}

module Details = {
  // open PreviewDetails
  @react.component
  let make = (
    ~heading,
    ~data,
    ~getHeading,
    ~getCell,
    ~excludeColKeys=[],
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-3/12",
    ~chargeBackField=None,
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~children=?,
    ~headRightElement=React.null,
    ~borderRequired=true,
    ~isHeadingRequired=true,
    ~cardView=false,
    ~showDetails=true,
    ~headingCss="",
    ~showTitle=true,
    ~flexClass="flex flex-wrap",
  ) => {
    if !cardView {
      <Section
        customCssClass={`${borderRequired
            ? "border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960"
            : ""} ${bgColor} rounded-md `}>
        <UIUtils.RenderIf condition=isHeadingRequired>
          <Heading topic=heading headingCss> {headRightElement} </Heading>
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition=showDetails>
          <FormRenderer.DesktopRow>
            <div
              className={`${flexClass} ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
              {detailsFields
              ->Array.mapWithIndex((colType, i) => {
                if !(excludeColKeys->Array.includes(colType)) {
                  <div className=widthClass key={Belt.Int.toString(i)}>
                    <DisplayKeyValueParams
                      heading={getHeading(colType)}
                      value={getCell(data, colType)}
                      customMoneyStyle="!text-fs-13"
                      labelMargin="!py-0 mt-2"
                      customDateStyle="!font-fira-code"
                      showTitle
                    />
                    <div />
                  </div>
                } else {
                  React.null
                }
              })
              ->React.array}
              {switch chargeBackField {
              | Some(field) =>
                <div className="flex flex-col py-4">
                  <div
                    className="text-fs-11 leading-3 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
                    {React.string("Chargeback Amount")}
                  </div>
                  <div
                    className="text-fs-13 font-semibold text-left dark:text-white text-jp-gray-900 break-all">
                    <Table.TableCell
                      cell=field
                      textAlign=Table.Left
                      fontBold=true
                      customDateStyle="!font-fira-code"
                      customMoneyStyle="!text-fs-13"
                      labelMargin="!py-0 mt-2 h-6"
                    />
                  </div>
                </div>

              | None => React.null
              }}
            </div>
          </FormRenderer.DesktopRow>
        </UIUtils.RenderIf>
        {switch children {
        | Some(ele) => ele
        | None => React.null
        }}
      </Section>
    } else {
      <div
        className="flex flex-col w-full pt-4 gap-4 bg-white rounded-md dark:bg-jp-gray-lightgray_background">
        {detailsFields
        ->Array.map(item => {
          <div className="flex justify-between">
            <div className="text-jp-gray-900 dark:text-white opacity-50 font-medium">
              {getHeading(item).title->React.string}
            </div>
            <div className="font-semibold break-all">
              <Table.TableCell cell={getCell(data, item)} />
            </div>
          </div>
        })
        ->React.array}
      </div>
    }
  }
}
