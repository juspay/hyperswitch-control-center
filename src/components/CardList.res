type cardListInfo = {
  id: string,
  label: string,
  imageUrl: option<string>,
  secondaryLabel: option<string>,
  primaryTag: option<string>,
  tagsList: array<string>,
  description: option<string>,
  tertiaryText: option<string>,
  isLive: option<string>,
}

@react.component
let make = (~listInfo: array<cardListInfo>, ~onClickHandler) => {
  <div className="flex flex-row items-center flex-wrap overflow-scroll">
    {listInfo
    ->Js.Array2.mapi((item, index) => {
      <div
        key={item.label ++ index->Belt.Int.toString}
        onClick={_ => onClickHandler(item.id, item.label)}
        className="border border-solid border-[#E1E1E1] dark:!border-[#48484d] dark:hover:border-sky-300 hover:bg-[#E9F1FF] dark:bg-[#252626] cursor-pointer bg-[#F6F6F6] dark:hover:bg-[#111010] rounded-lg min-w-[300px] w-[calc(32%-20px)] overflow-hidden items-center mt-8 mr-4">
        {item.imageUrl->Belt.Option.mapWithDefault(React.null, imageUrl =>
          <ImageViewer
            shimmerClass="w-full h-[211px]"
            imageClass="h-[211px] w-auto object-cover"
            imageUrl={imageUrl}
            alt={item.label}
          />
        )}
        <div
          className="bg-white border-t border-[#E1E1E1] flex flex-col justify-between  min-h-[190px] dark:bg-[#111010]  pb-2 px-4 relative ">
          <div>
            {switch item.primaryTag {
            | None | Some("") => React.null
            | Some(tag) =>
              <div
                className=" flex bg-[#D0F1E1] text-[#0B6E40] px-1 pr-2 py-1 font-semibold rounded-2xl absolute -top-3 text-xs">
                <Icon className="p-1" size=16 name="bolt" />
                {React.string(tag)}
              </div>
            }}
            <div
              className="text-[#111111] dark:text-white pt-5 flex relative  font-semibold text-base">
              {React.string(item.label)}
              {item.isLive->Belt.Option.mapWithDefault(React.null, integrationStatus => {
                if integrationStatus->Js.String2.toLowerCase === "live" {
                  <div
                    className="ml-3 flex bg-[#D1E7FF] text-[#105099] px-1 pr-2 py-1 font-semibold rounded-2xl w-fit text-xs">
                    <Icon className="p-1" size=16 name="check" />
                    {React.string("LIVE")}
                  </div>
                } else if integrationStatus->Js.String2.toLowerCase === "integrating" {
                  <div
                    className="ml-3 flex bg-[#FDE9CE] text-[#945605] px-1 pr-2 py-1 font-semibold rounded-2xl w-fit text-xs">
                    <Icon className="p-1 relative -top-[1px]" size=16 name="exclamation" />
                    {React.string("Integrating")}
                  </div>
                } else {
                  React.null
                }
              })}
            </div>
            <div className="pt-2 text-jp-2-light-gray-1200  jb-subtitle-2 !leading-[20px]">
              {React.string(
                item.description->Belt.Option.getWithDefault("No description available"),
              )}
              {switch item.tertiaryText {
              | Some("") | None => React.null
              | Some(text) =>
                <div className="text-[#0E9225] font-semibold flex mt-3 text-sm">
                  <Icon
                    className="text-white bg-[#0E9255] p-[3px] rounded-xl mr-2 "
                    size=15
                    name="check"
                  />
                  {React.string(text)}
                </div>
              }}
            </div>
          </div>
          <div className="pt-2 w-full flex flex-row flex-wrap mb-1">
            {item.tagsList
            ->Js.Array2.mapi((tag, index) => {
              <div key={tag ++ index->Belt.Int.toString} className=" mt-2 w-fit flex mr-2 ">
                <Tag labelText=tag labelColor={LabelGray} isFill=true />
              </div>
            })
            ->React.array}
          </div>
        </div>
      </div>
    })
    ->React.array}
  </div>
}
