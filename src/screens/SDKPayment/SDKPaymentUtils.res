let initialValueForForm: HSwitchSettingTypes.profileEntity => SDKPaymentTypes.paymentType = defaultBusinessProfile => {
  {
    amount: 10000.00,
    currency: "USD",
    profileId: defaultBusinessProfile.profile_id,
    description: "Default value",
    customerId: "hyperswitch_sdk_demo_id",
    email: "guest@example.com",
    name: "John Doe",
    phone: "999999999",
    phoneCountryCode: "+65",
    authenticationType: "no_three_ds",
    shipping: {
      address: {
        line1: "1467",
        line2: "Harrison Street",
        line3: "Harrison Street",
        city: "San Fransico",
        state: "California",
        zip: "94122",
        country: "US",
        firstName: "John",
        lastName: "Doe",
      },
      phone: {
        number: "1234567890",
        countryCode: "+1",
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
        firstName: "John",
        lastName: "Doe",
      },
      phone: {
        number: "1234567890",
        countryCode: "+1",
      },
      email: "billing_email@gmail.com",
    },
    metadata: {
      orderDetails: {
        productName: "Apple iphone 15",
        quantity: 1,
        amount: 10000.00,
      },
    },
    captureMethod: "automatic",
    amountToCapture: Nullable.make(10000.00),
    returnUrl: `${Window.Location.origin}${Window.Location.pathName}`,
    countryCurrency: "US-USD",
    frmMetadata: {
      orderChannel: "web",
    },
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
  let order_channel = getDictFormDictOfValues("frm_metadata")->getString("order_channel", "")

  let mandateData: SDKPaymentTypes.mandateData = {
    customerAcceptance: {
      acceptanceType: "offline",
      acceptedAt: "1963-05-03T04:07:52.723Z",
      online: {
        ipAddress: "in sit",
        userAgent: "amet irure esse",
      },
    },
    mandateType: {
      multiUse: {
        amount: 10000,
        currency: countryCurrency->Array.at(1)->Option.getOr("USD"),
      },
    },
  }

  let frmMetadata: SDKPaymentTypes.frmMetadata = {
    orderChannel: order_channel,
  }

  {
    amount,
    currency: countryCurrency->Array.at(1)->Option.getOr("USD"),
    profileId: dictOfValues->getString("profile_id", ""),
    customerId: dictOfValues->getString("customer_id", ""),
    description: dictOfValues->getString("description", "Default value"),
    email: dictOfValues->getString("email", ""),
    name: dictOfValues->getString("name", ""),
    phone: dictOfValues->getString("phone", ""),
    phoneCountryCode: dictOfValues->getString("phone_country_code", ""),
    authenticationType: dictOfValues->getString("authentication_type", ""),
    shipping: {
      address: {
        line1: shippingAddress->getString("line1", ""),
        line2: shippingAddress->getString("line2", ""),
        line3: shippingAddress->getString("line3", ""),
        city: shippingAddress->getString("city", ""),
        state: shippingAddress->getString("state", ""),
        zip: shippingAddress->getString("zip", ""),
        country: shippingAddress->getString("country", ""),
        firstName: shippingAddress->getString("first_name", ""),
        lastName: shippingAddress->getString("last_name", ""),
      },
      phone: {
        number: shippingPhone->getString("number", ""),
        countryCode: shippingPhone->getString("country_code", ""),
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
        firstName: billingAddress->getString("first_name", ""),
        lastName: billingAddress->getString("last_name", ""),
      },
      phone: {
        number: billingPhone->getString("number", ""),
        countryCode: billingPhone->getString("country_code", ""),
      },
      email: billingEmail,
    },
    metadata: {
      orderDetails: {
        productName: metaData->getString("product_name", ""),
        quantity: 1,
        amount,
      },
    },
    captureMethod: "automatic",
    amountToCapture: amount === 0.00 ? Nullable.null : Nullable.make(amount),
    returnUrl: dictOfValues->getString("return_url", ""),
    paymentType: amount === 0.00 ? Nullable.make("setup_mandate") : Nullable.null,
    setupFutureUsage: amount === 0.00 ? Nullable.make("off_session") : Nullable.null,
    mandateData: amount === 0.00 ? Nullable.make(mandateData) : Nullable.null,
    countryCurrency: dictOfValues->getString("country_currency", "US-USD"),
    frmMetadata,
  }
}
