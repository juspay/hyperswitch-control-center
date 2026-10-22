type tagVariant =
  | @as("noFill") NoFill
  | @as("attentive") Attentive
  | @as("subtle") Subtle

type tagShape =
  | @as("squarical") Squarical
  | @as("rounded") Rounded

type tagSize =
  | @as("xs") Xs
  | @as("sm") Sm
  | @as("md") Md
  | @as("lg") Lg

type tagColor =
  | @as("neutral") Neutral
  | @as("primary") Primary
  | @as("success") Success
  | @as("error") Error
  | @as("warning") Warning
  | @as("purple") Purple

type slot = {slot: React.element}
type skeleton = {showSkeleton: bool}

module V2 = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~text: string,
    @as("type") ~type_: tagVariant=?,
    ~subType: tagShape=?,
    ~size: tagSize=?,
    ~color: tagColor=?,
    ~leftSlot: slot=?,
    ~rightSlot: slot=?,
    ~skeleton: skeleton=?,
  ) => React.element = "TagV2"
}

// Keep the application API stable while translating V2's visual and slot contracts.
@react.component
let make = (
  ~text: string,
  ~variant: option<tagVariant>=?,
  ~shape: option<tagShape>=?,
  ~size: option<tagSize>=?,
  ~color: option<tagColor>=?,
  ~leftSlot: option<React.element>=?,
  ~rightSlot: option<React.element>=?,
  ~showSkeleton: option<bool>=?,
) => {
  <V2
    text
    type_=?variant
    subType=?shape
    ?size
    ?color
    leftSlot=?{leftSlot->Option.map(slot => {slot: slot})}
    rightSlot=?{rightSlot->Option.map(slot => {slot: slot})}
    skeleton=?{showSkeleton->Option.map((showSkeleton): skeleton => {showSkeleton: showSkeleton})}
  />
}
