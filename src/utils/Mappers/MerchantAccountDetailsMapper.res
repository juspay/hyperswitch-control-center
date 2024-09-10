open HSwitchSettingTypes
let getMerchantDetails = (values: JSON.t) => {
  open LogicUtils
  let valuesDict = values->getDictFromJsonObject
  let merchantDetails = valuesDict->getObj("merchant_details", Dict.make())
  let address = merchantDetails->getObj("address", Dict.make())

  let primary_business_details =
    valuesDict
    ->getArrayFromDict("primary_business_details", [])
    ->Array.map(detail => {
      let detailDict = detail->getDictFromJsonObject

      let info = {
        business: detailDict->getString("business", ""),
        country: detailDict->getString("country", ""),
      }

      info
    })

  let reconStatusMapper = reconStatus => {
    switch reconStatus->String.toLowerCase {
    | "notrequested" => NotRequested
    | "requested" => Requested
    | "active" => Active
    | "disabled" => Disabled
    | _ => NotRequested
    }
  }

  let payload: merchantPayload = {
    merchant_name: valuesDict->getOptionString("merchant_name"),
    api_key: valuesDict->getString("api_key", ""),
    publishable_key: valuesDict->getString("publishable_key", ""),
    merchant_id: valuesDict->getString("merchant_id", ""),
    locker_id: valuesDict->getString("locker_id", ""),
    primary_business_details,
    merchant_details: {
      primary_contact_person: merchantDetails->getOptionString("primary_contact_person"),
      primary_email: merchantDetails->getOptionString("primary_email"),
      primary_phone: merchantDetails->getOptionString("primary_phone"),
      secondary_contact_person: merchantDetails->getOptionString("secondary_contact_person"),
      secondary_email: merchantDetails->getOptionString("secondary_email"),
      secondary_phone: merchantDetails->getOptionString("secondary_phone"),
      website: merchantDetails->getOptionString("website"),
      about_business: merchantDetails->getOptionString("about_business"),
      address: {
        line1: address->getOptionString("line1"),
        line2: address->getOptionString("line2"),
        line3: address->getOptionString("line3"),
        city: address->getOptionString("city"),
        state: address->getOptionString("state"),
        zip: address->getOptionString("zip"),
      },
    },
    enable_payment_response_hash: getBool(valuesDict, "enable_payment_response_hash", false),
    sub_merchants_enabled: getBool(valuesDict, "sub_merchants_enabled", false),
    metadata: valuesDict->getString("metadata", ""),
    parent_merchant_id: valuesDict->getString("parent_merchant_id", ""),
    payment_response_hash_key: valuesDict->getOptionString("payment_response_hash_key"),
    redirect_to_merchant_with_http_post: getBool(
      valuesDict,
      "redirect_to_merchant_with_http_post",
      true,
    ),
    recon_status: getString(valuesDict, "recon_status", "")->reconStatusMapper,
  }
  payload
}
