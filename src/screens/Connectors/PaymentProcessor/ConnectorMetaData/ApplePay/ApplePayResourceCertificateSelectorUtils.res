open LogicUtils

let getButtonState = (
  ~isLoading,
  ~selectedResourceId,
  ~linkedResourceId,
  ~isLinking,
): Button.buttonState =>
  switch (
    !isLoading && selectedResourceId->isNonEmptyString && selectedResourceId !== linkedResourceId,
    isLinking,
  ) {
  | (true, true) => Loading
  | (true, false) => Normal
  | (false, _) => Disabled
  }
