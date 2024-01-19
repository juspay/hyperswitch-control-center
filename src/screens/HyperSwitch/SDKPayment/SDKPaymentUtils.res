let initialValueForForm: HSwitchSettingTypes.profileEntity => SDKPaymentTypes.paymentType = defaultBusinessProfile => {
  {
    amount: 10000.00,
    currency: "United States-USD",
    profile_id: defaultBusinessProfile.profile_id,
    description: "Default value",
    customer_id: "hyperswitch_sdk_demo_id",
    email: "guest@example.com",
    name: "John Doe",
    phone: "999999999",
    phone_country_code: "+65",
    authentication_type: "no_three_ds",
    shipping: {
      address: {
        line1: "1467",
        line2: "Harrison Street",
        line3: "Harrison Street",
        city: "San Fransico",
        state: "California",
        zip: "94122",
        country: "US",
        first_name: "John",
        last_name: "Doe",
      },
      phone: {
        number: "1234567890",
        country_code: "+1",
      },
    },
    billing: {
      address: {
        line1: "1467",
        line2: "Harrison Street",
        line3: "Harrison Street",
        city: "San Fransico",
        state: "California",
        zip: "94122",
        country: "US",
        first_name: "John",
        last_name: "Doe",
      },
      phone: {
        number: "1234567890",
        country_code: "+1",
      },
    },
    metadata: {
      order_details: {
        product_name: "Apple iphone 15",
        quantity: 1,
        amount: 100.00,
      },
    },
    capture_method: "automatic",
    amount_to_capture: Js.Nullable.return(100.00),
    return_url: `${Window.Location.origin}${Window.Location.pathName}`,
  }
}

let getCurrencyValue = (countryCurrency: string) => {
  countryCurrency->String.split("-")->Belt.Array.get(1)->Option.getWithDefault("USD")->String.trim
}

let getTypedValueForPayment: Js.Json.t => SDKPaymentTypes.paymentType = values => {
  open LogicUtils
  let dictOfValues = values->getDictFromJsonObject
  let shippingAddress =
    values->getDictFromJsonObject->getDictfromDict("shipping")->getDictfromDict("address")
  let shippingPhone =
    values->getDictFromJsonObject->getDictfromDict("shipping")->getDictfromDict("phone")
  let billingAddress =
    values->getDictFromJsonObject->getDictfromDict("billing")->getDictfromDict("address")
  let billingPhone =
    values->getDictFromJsonObject->getDictfromDict("shipping")->getDictfromDict("phone")
  let metaData =
    values->getDictFromJsonObject->getDictfromDict("metadata")->getDictfromDict("order_details")

  let mandateData: SDKPaymentTypes.mandateData = {
    customer_acceptance: {
      acceptance_type: "offline",
      accepted_at: "1963-05-03T04:07:52.723Z",
      online: {
        ip_address: "in sit",
        user_agent: "amet irure esse",
      },
    },
    mandate_type: {
      multi_use: {
        amount: 10000,
        currency: dictOfValues->getString("currency", "United States-USD")->getCurrencyValue,
      },
    },
  }
  let amount = dictOfValues->getFloat("amount", 100.00)

  {
    amount,
    currency: dictOfValues->getString("currency", "United States-USD"),
    profile_id: dictOfValues->getString("profile_id", ""),
    customer_id: dictOfValues->getString("customer_id", ""),
    description: dictOfValues->getString("description", "Default value"),
    email: dictOfValues->getString("email", ""),
    name: dictOfValues->getString("name", ""),
    phone: dictOfValues->getString("phone", ""),
    phone_country_code: dictOfValues->getString("phone_country_code", ""),
    authentication_type: dictOfValues->getString("authentication_type", ""),
    shipping: {
      address: {
        line1: shippingAddress->getString("line1", ""),
        line2: shippingAddress->getString("line2", ""),
        line3: shippingAddress->getString("line3", ""),
        city: shippingAddress->getString("city", ""),
        state: shippingAddress->getString("state", ""),
        zip: shippingAddress->getString("zip", ""),
        country: shippingAddress->getString("country", ""),
        first_name: shippingAddress->getString("first_name", ""),
        last_name: shippingAddress->getString("last_name", ""),
      },
      phone: {
        number: shippingPhone->getString("number", ""),
        country_code: shippingPhone->getString("country_code", ""),
      },
    },
    billing: {
      address: {
        line1: billingAddress->getString("line1", ""),
        line2: billingAddress->getString("line2", ""),
        line3: billingAddress->getString("line3", ""),
        city: billingAddress->getString("city", ""),
        state: billingAddress->getString("state", ""),
        zip: billingAddress->getString("zip", ""),
        country: billingAddress->getString("country", ""),
        first_name: billingAddress->getString("first_name", ""),
        last_name: billingAddress->getString("last_name", ""),
      },
      phone: {
        number: billingPhone->getString("number", ""),
        country_code: billingPhone->getString("country_code", ""),
      },
    },
    metadata: {
      order_details: {
        product_name: metaData->getString("product_name", ""),
        quantity: 1,
        amount,
      },
    },
    capture_method: "automatic",
    amount_to_capture: amount === 0.00 ? Js.Nullable.null : Js.Nullable.return(amount),
    return_url: dictOfValues->getString("return_url", ""),
    payment_type: amount === 0.00 ? Js.Nullable.return("setup_mandate") : Js.Nullable.null,
    setup_future_usage: amount === 0.00 ? Js.Nullable.return("off_session") : Js.Nullable.null,
    mandate_data: amount === 0.00 ? Js.Nullable.return(mandateData) : Js.Nullable.null,
  }
}
