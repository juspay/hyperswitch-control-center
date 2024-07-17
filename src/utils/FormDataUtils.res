type formData
@new external formData: unit => Fetch.formData = "FormData"
@send external append: (Fetch.formData, string, 'a) => unit = "append"
