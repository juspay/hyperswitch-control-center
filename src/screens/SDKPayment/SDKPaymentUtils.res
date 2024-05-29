let initialValueForForm: HSwitchSettingTypes.profileEntity => SDKPaymentTypes.paymentType = defaultBusinessProfile => {
  {
    amount: 10000.00,
    currency: "USD",
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
      email: "billing_email@gmail.com",
    },
    metadata: {
      order_details: {
        product_name: "Apple iphone 15",
        quantity: 1,
        amount: 10000.00,
      },
    },
    capture_method: "automatic",
    amount_to_capture: Nullable.make(10000.00),
    return_url: `${Window.Location.origin}${Window.Location.pathName}`,
    country_currency: "US-USD",
  }
}

let getTypedValueForPayment: JSON.t => SDKPaymentTypes.paymentType = values => {
  open LogicUtils
  let dictOfValues = values->getDictFromJsonObject
  let getDictFormDictOfValues = key => dictOfValues->getDictfromDict(key)

  let shippingAddress = getDictFormDictOfValues("shipping")->getDictfromDict("address")
  let shippingPhone = getDictFormDictOfValues("shipping")->getDictfromDict("phone")
  let billingAddress = getDictFormDictOfValues("billing")->getDictfromDict("address")
  let billingPhone = getDictFormDictOfValues("shipping")->getDictfromDict("phone")
  let billingEmail = getDictFormDictOfValues("billing")->getString("email", "")
  let metaData = getDictFormDictOfValues("metadata")->getDictfromDict("order_details")
  let amount = dictOfValues->getFloat("amount", 10000.00)
  let countryCurrency = dictOfValues->getString("country_currency", "US-USD")->String.split("-")

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
        currency: countryCurrency->Array.at(1)->Option.getOr("USD"),
      },
    },
  }

  {
    amount,
    currency: countryCurrency->Array.at(1)->Option.getOr("USD"),
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
        country: countryCurrency->Array.at(0)->Option.getOr("US"),
        first_name: billingAddress->getString("first_name", ""),
        last_name: billingAddress->getString("last_name", ""),
      },
      phone: {
        number: billingPhone->getString("number", ""),
        country_code: billingPhone->getString("country_code", ""),
      },
      email: billingEmail,
    },
    metadata: {
      order_details: {
        product_name: metaData->getString("product_name", ""),
        quantity: 1,
        amount,
      },
    },
    capture_method: "automatic",
    amount_to_capture: amount === 0.00 ? Nullable.null : Nullable.make(amount),
    return_url: dictOfValues->getString("return_url", ""),
    payment_type: amount === 0.00 ? Nullable.make("setup_mandate") : Nullable.null,
    setup_future_usage: amount === 0.00 ? Nullable.make("off_session") : Nullable.null,
    mandate_data: amount === 0.00 ? Nullable.make(mandateData) : Nullable.null,
    country_currency: dictOfValues->getString("country_currency", "US-USD"),
  }
}
