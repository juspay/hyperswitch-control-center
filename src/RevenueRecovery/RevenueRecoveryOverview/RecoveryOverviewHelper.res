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
    ~overiddingHeadingStyles="",
    ~textColor="!font-medium !text-nd_gray-600",
  ) => {
    let marginClass = if labelMargin->LogicUtils.isEmptyString {
      "mt-4 py-0"
    } else {
      labelMargin
    }

    let fontClass = if isInHeader {
      "text-fs-20"
    } else {
      "text-fs-13"
    }

    let textColor =
      textColor->LogicUtils.isEmptyString ? "text-jp-gray-900 dark:text-white" : textColor

    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div
          className={`flex ${isHorizontal ? "flex-row justify-between" : "flex-col gap-1"} py-4 `}>
          <div
            className={`flex flex-row text-fs-11  ${isHorizontal
                ? "flex justify-start"
                : ""} text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 `}>
            <div className={`${overiddingHeadingStyles} w-full`}>
              {React.string(showTitle ? `${heading.title}:` : " x")}
            </div>
            <RenderIf condition={description->LogicUtils.isNonEmptyString}>
              <div className="text-sm text-gray-500 -mt-1">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </RenderIf>
          </div>
          <div
            className={`${isHorizontal
                ? "flex justify-end"
                : ""} ${fontClass} font-semibold text-left ${textColor}`}>
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
