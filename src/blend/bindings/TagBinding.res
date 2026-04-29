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

@module("@juspay/blend-design-system") @react.component
external make: (
  ~text: string,
  ~variant: tagVariant=?,
  ~shape: tagShape=?,
  ~size: tagSize=?,
  ~color: tagColor=?,
  ~leftSlot: React.element=?,
  ~rightSlot: React.element=?,
  ~showSkeleton: bool=?,
) => React.element = "Tag"
