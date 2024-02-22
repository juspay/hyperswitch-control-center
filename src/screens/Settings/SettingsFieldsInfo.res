open HSwitchSettingTypes
let primaryDetails: fieldsInfoType = {
  name: "Primary Details",
  description: "Add primary contact details",
  inputFields: [
    {
      placeholder: "Enter Contact Name",
      label: "Contact Name",
      name: "primary_contact_person",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Contact Phone",
      label: "Contact Phone",
      name: "primary_phone",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Contact Mail",
      label: "Contact Mail",
      name: "primary_email",
      inputType: InputFields.textInput(),
    },
  ],
}
let secondaryDetails: fieldsInfoType = {
  name: "Secondary Details",
  description: "Add secondary contact details",
  inputFields: [
    {
      placeholder: "Enter Contact Name",
      label: "Contact Name",
      name: "secondary_contact_person",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Contact Phone",
      label: "Contact Phone",
      name: "secondary_phone",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Contact Mail",
      label: "Contact Mail",
      name: "secondary_email",
      inputType: InputFields.textInput(),
    },
  ],
}
let businessDetails: fieldsInfoType = {
  name: "Business Details",
  description: "Add business details",
  inputFields: [
    {
      placeholder: "Enter Website Name",
      label: "Website",
      name: "website",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Description",
      label: "Description",
      name: "about_business",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Address Line 1",
      label: "Address Line 1",
      name: "line1",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Address Line 2 ",
      label: "Address Line 2",
      name: "line2",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter Zip Code",
      label: "Zip",
      name: "zip",
      inputType: InputFields.textInput(),
    },
    {
      placeholder: "Enter City",
      label: "City",
      name: "city",
      inputType: InputFields.textInput(),
    },
  ],
}
