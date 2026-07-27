open Typography
module ActionButtons = {
  @react.component
  let make = (~handleDelete) => {
    <div className="flex gap-4 justify-end w-full">
      <Button
        text="Delete Theme"
        buttonType=Secondary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
        onClick={_ => handleDelete()}
      />
      <FormRenderer.SubmitButton text="Update Theme" buttonType=Primary buttonSize={Small} />
    </div>
  }
}
