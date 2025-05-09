type formData
@new external formData: unit => Fetch.formData = "FormData"
@send external append: (Fetch.formData, string, 'a) => unit = "append"
@new external blob: (array<'a>, {"type": string}) => Fetch.blob = "Blob"
@send external appendBlob: (Fetch.formData, string, Fetch.blob, 'a) => unit = "append"
