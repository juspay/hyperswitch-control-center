let reactImports = `import React, { useState, useEffect } from "react";
import { loadHyper } from "@juspay-tech/hyper-js";
import { HyperElements } from "@juspay-tech/react-hyper-js";`

let htmlHandleEvents = `async function handleSubmit(e) {
  e.preventDefault();
  setLoading(true);

  const { error } = await hyper.confirmPayment({
    widgets,
    confirmParams: {
      // Make sure to change this to your payment completion page
      return_url: "https://example.com/complete",
    },
  });

  // This point will only be reached if there is an immediate error occurring while confirming the payment. Otherwise, your customer will be redirected to your "return_url".

  // For some payment flows such as Sofort, iDEAL, your customer will be redirected to an intermediate page to complete authorization of the payment, and then redirected to the "return_url".

  if (error.type === "validation_error") {
    showMessage(error.message);
  } else {
    showMessage("An unexpected error occurred.");
  }
  setLoading(false);
}`

let reactHandleEvent = "const handleSubmit = async (e) => {
  e.preventDefault();

  if (!hyper || !widgets) {
    // hyper-js has not yet loaded.
    // Make sure to disable form submission until hyper-js has loaded.
    return;
  }

  setIsLoading(true);

  const { error, status } = await hyper.confirmPayment({
    widgets,
    confirmParams: {
      // Make sure to change this to your payment completion page
      return_url: `https://example.com/complete`,
    },
  });

  // This point will only be reached if there is an immediate error occurring while confirming the payment. Otherwise, your customer will be redirected to your `return_url`

  // For some payment flows such as Sofort, iDEAL, your customer will be redirected to an intermediate page to complete authorization of the payment, and then redirected to the `return_url`.
  if (error) {
    if (error.type === `validation_error`) {
      setMessage(error.message);
    } else {
      setMessage(`An unexpected error occurred.`);
    }
  } else {
    setMessage(`Your payment is ${status}`)
  }
  setIsLoading(false);
};"

let htmlDisplayConfirmation = `// Fetches the payment status after payment submission
async function checkStatus() {
  const clientSecret = new URLSearchParams(window.location.search).get(
    "payment_intent_client_secret"
  );

  if (!clientSecret) {
    return;
  }

  const { payment } = await hyper.retrievePayment(clientSecret);

  switch (payment.status) {
    case "succeeded":
      showMessage("Payment succeeded!");
      break;
    case "processing":
      showMessage("Your payment is processing.");
      break;
    case "requires_payment_method":
      showMessage("Your payment was not successful, please try again.");
      break;
    default:
      showMessage("Something went wrong.");
      break;
  }
}`

let reactDisplayConfirmation = `
//Look for a parameter called "payment_intent_client_secre" in the url which gives a payment ID, which is then used to retrieve the status of the payment

const paymentID = new URLSearchParams(window.location.search).get(
  "payment_intent_client_secret"
);

if (!paymentID) {
  return;
}

hyper.retrievePaymentIntent(paymentID).then(({ paymentIntent }) => {
  switch (paymentIntent.status) {
    case "succeeded":
      setMessage("Payment succeeded!");
      break;
    case "processing":
      setMessage("Your payment is processing.");
      break;
    case "requires_payment_method":
      setMessage("Your payment was not successful, please try again.");
      break;
    default:
      setMessage("Something went wrong.");
      break;
  }
});`

let htmlLoad = `<script src="https://beta.hyperswitch.io/v1/HyperLoader.js"></script>

<form id="payment-form">
  <div id="unified-checkout">
   <!--HyperLoader injects the Unified Checkout-->
  </div>
  <button id="submit">
    <div class="spinner hidden" id="spinner"></div>
    <span id="button-text">Pay now</span>
  </button>
  <div id="payment-message" class="hidden"></div>
</form>`

let reactLoad = `const hyperPromise = loadHyper("YOUR_PUBLISHABLE_KEY");
const [clientSecret, setClientSecret] = useState("");`

let htmlInitialize = `async function initialize() {
  const response = await fetch("/create-payment", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ items: [{ id: "xl-tshirt" }], country: "US" }),
  });
  const { clientSecret } = await response.json();

  const appearance = {
    theme: "midnight",
  };

  widgets = hyper.widgets({ appearance, clientSecret });

  var unifiedCheckoutOptions = {
      wallets: {
          walletReturnUrl: 'https://example.com/complete',
          //Mandatory parameter for Wallet Flows such as Googlepay, Paypal and Applepay
      },
  };

  const unifiedCheckout = widgets.create("payment", unifiedCheckoutOptions);
  unifiedCheckout.mount("#unified-checkout");
}`

let reactInitialize = "
 useEffect(() => {
    fetch(`/create-payment-intent`, {
      method: `POST`,
      body: JSON.stringify({ items: [{ id: `xl-tshirt` }], country: `US` }),
    }).then(async (result) => {
      var { clientSecret } = await result.json();
      setClientSecret(clientSecret);
    });
  }, []);

<>
  {clientSecret && (
    <HyperElements options={{ clientSecret }} hyper={hyperPromise}>
      <CheckoutForm return_url={`${window.location.origin}/completion}` />
    </HyperElements>
  )}
</> "

let reactCheckoutFormDisplayCheckoutPage = "import { UnifiedCheckout, useHyper, useWidgets } from '@juspay-tech/react-hyper-js';

// store a reference to hyper
const hyper = useHyper();

var unifiedCheckoutOptions = {
      wallets: {
          walletReturnUrl: 'https://example.com/complete',
          //Mandatory parameter for Wallet Flows such as Googlepay, Paypal and Applepay
      },
};

<form id='payment-form' onSubmit={handleSubmit}>
  <UnifiedCheckout id='unified-checkout' options={unifiedCheckoutOptions} />
    <button id='submit'>
      <span id='button-text'>
          {isLoading ? <div className='spinner' id='spinner'></div> : 'Pay Now'}
      </span>
    </button>
    {/* Show any error or success messages */}
    {message && <div id='payment-message'>{message}</div>}
</form>"

let nodeInstallDependencies = `npm install @juspay-tech/hyperswitch-node`

let reactInstallDependencies = `npm install @juspay-tech/hyper-js
npm install @juspay-tech/react-hyper-js`

let rubyRequestPayment = `require 'net/http'
require 'sinatra'
require 'json'
require 'uri'

hyper_switch_api_key = 'HYPERSWITCH_API_KEY'
hyper_switch_api_base_url = 'https://sandbox.hyperswitch.io/payments'

set :static, true
set :port, 4242

# Securely calculate the order amount
def calculate_order_amount(_items)
  # Replace this constant with a calculation of the order's amount
  # Calculate the order total on the server to prevent
  # people from directly manipulating the amount on the client
  1400
end

# An endpoint to start the payment process
post '/create-payment' do

  data = JSON.parse(request.body.read)

  # If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
  # please pass the fields business_country and business_label in this request body.
  # For accessing more features, you can check out the request body schema for payments-create API here :
  # https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
          
  payload = { amount: calculate_order_amount(data['items']), currency: 'USD' }.to_json
  uri = URI.parse(hyper_switch_api_base_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(uri.path,
                                'Content-Type' => 'application/json',
                                'Accept' => 'application/json',
                                'api-key' => hyper_switch_api_key)
  request.body = payload
  response = http.request(request)
  response_data = JSON.parse(response.body)
  {
    clientSecret: response_data['client_secret']
  }.to_json

end`

let javaRequestPayment = `package com.hyperswitch.sample;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;

import java.net.HttpURLConnection;
import java.net.URL;

import java.nio.file.Paths;

import static spark.Spark.post;
import static spark.Spark.staticFiles;
import static spark.Spark.port;

import org.json.JSONObject;

public class server {

  public static void main(String[] args) {

    port(4242);

    staticFiles.externalLocation(Paths.get("public").toAbsolutePath().toString());

    post("/create-payment", (request, response) -> {

      response.type("application/json");

      /*
        If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
        please pass the fields business_country and business_label in this request body.
        For accessing more features, you can check out the request body schema for payments-create API here :
        https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
      */

      String payload = "{ \"amount\": 100, \"currency\": \"USD\" }";

      String response_string = createPayment(payload);
      JSONObject response_json = new JSONObject(response_string);

      String client_secret = response_json.getString("client_secret");

      JSONObject final_response = new JSONObject();
      final_response.put("clientSecret", client_secret);

      return final_response;

    });

  }

  private static String createPayment(String payload) {

    try {

      String HYPER_SWITCH_API_KEY = "HYPERSWITCH_API_KEY";
      String HYPER_SWITCH_API_BASE_URL = "https://sandbox.hyperswitch.io/payments";

      URL url = new URL(HYPER_SWITCH_API_BASE_URL);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();

      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json");
      conn.setRequestProperty("Accept", "application/json");
      conn.setRequestProperty("api-key", HYPER_SWITCH_API_KEY);
      conn.setDoOutput(true);

      try (OutputStream os = conn.getOutputStream()) {
        byte[] input = payload.getBytes("utf-8");
        os.write(input, 0, input.length);
      }

      int responseCode = conn.getResponseCode();

      if (responseCode == HttpURLConnection.HTTP_OK) {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "utf-8"))) {
          StringBuilder response = new StringBuilder();
          String responseLine;
          while ((responseLine = br.readLine()) != null) {
            response.append(responseLine.trim());
          }
          return response.toString();
        }
      } else {
        return "HTTP request failed with response code: " + responseCode;
      }
    } catch (IOException e) {
      return e.getMessage();
    }

  }

}`

let pythonRequestPayment = `#! /usr/bin/env python3.6
"""
Python 3.6 or newer required.
"""
import http.client
import json
import os
from flask import Flask, render_template, jsonify, request

app = Flask(__name__,
            static_folder='public',
            static_url_path='',
            template_folder='public')

def calculate_order_amount(items):
  # Replace this constant with a calculation of the order's amount
  # Calculate the order total on the server to prevent
  # people from directly manipulating the amount on the client
  return 1400

@app.route('/create-payment', methods=['POST'])
def create_payment():
  try:
    conn = http.client.HTTPSConnection("sandbox.hyperswitch.io")

    # If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
    # please pass the fields business_country and business_label in this request body.
    # For accessing more features, you can check out the request body schema for payments-create API here :
    # https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
              
    payload = "{\n \"amount\": 100,\n \"currency\": \"USD\"\n}"
    headers = {
      'Content-Type': "application/json",
      'Accept': "application/json",
      'api-key': "HYPERSWITCH_API_KEY",
    }
    conn.request("POST", "/payments", payload, headers)
    res = conn.getresponse()
    data = json.loads(res.read())
    return jsonify({'clientSecret': data['client_secret']})
  except Exception as e:
    return jsonify(error=str(e)), 403

if __name__ == '__main__':
  app.run(port=4242)`

let netRequestPayment = `using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json;

namespace HyperswitchExample
{
  public class Program
  {
    public static void Main(string[] args)
    {
      WebHost.CreateDefaultBuilder(args)
        .UseUrls("http://0.0.0.0:4242")
        .UseWebRoot("public")
        .UseStartup<Startup>()
        .Build()
        .Run();
    }
  }

  public class Startup
  {
    public void ConfigureServices(IServiceCollection services)
    {
      services.AddMvc().AddNewtonsoftJson();
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
      if (env.IsDevelopment()) app.UseDeveloperExceptionPage();
      app.UseRouting();
      app.UseStaticFiles();
      app.UseEndpoints(endpoints => endpoints.MapControllers());
    }

  }

  [Route("create-payment")]
  [ApiController]
  public class PaymentIntentApiController : Controller
  {

    [HttpPost]
    public async Task<ActionResult> CreateAsync(PaymentIntentCreateRequest request)
    {
        string HYPER_SWITCH_API_KEY = "HYPERSWITCH_API_KEY";
        string HYPER_SWITCH_API_BASE_URL = "https://sandbox.hyperswitch.io/payments";

        /*
          If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
          please pass the fields business_country and business_label in this request body.
          For accessing more features, you can check out the request body schema for payments-create API here :
          https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
        */

        var payload = new { amount = CalculateOrderAmount(request.Items), currency = "USD" };

        using (var httpClient = new System.Net.Http.HttpClient())
        {
            httpClient.DefaultRequestHeaders.Add("api-key", HYPER_SWITCH_API_KEY);

            var jsonPayload = JsonConvert.SerializeObject(payload);

            var content = new System.Net.Http.StringContent(jsonPayload, System.Text.Encoding.UTF8, "application/json");

            var response = await httpClient.PostAsync(HYPER_SWITCH_API_BASE_URL, content);
            var responseContent = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                dynamic responseData = JsonConvert.DeserializeObject(responseContent);
                return Json(new {clientSecret = responseData.client_secret});
            }
            else
            {
                return Json(new {error = "Request failed"});
            }
        }
    }

    private int CalculateOrderAmount(Item[] items)
    {
      return 1400;
    }

    public class Item
    {
      [JsonProperty("id")]
      public string Id { get; set; }
    }

    public class PaymentIntentCreateRequest
    {
      [JsonProperty("items")]
      public Item[] Items { get; set; }
    }
  }
}`

let rustRequestPayment = `extern crate reqwest;
use reqwest::header;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut headers = header::HeaderMap::new();
    headers.insert("Content-Type", "application/json".parse().unwrap());
    headers.insert("Accept", "application/json".parse().unwrap());
    headers.insert("api-key", "YOUR_API_KEY".parse().unwrap());

    let client = reqwest::blocking::Client::new();
    let res = client.post("https://sandbox.hyperswitch.io/payments")
        .headers(headers)
        .body(r#"
{
 "amount": 100,
 "currency": "USD"
}
"#
        )
        .send()?
        .text()?;
    println!("{}", res);

    Ok(())
}`

let shellRequestPayment = `curl --location --request POST 'https://sandbox.hyperswitch.io/payments' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--header 'api-key: YOUR_API_KEY' \
--data-raw '{
 "amount": 100,
 "currency": "USD"
}'`

let phpRequestPayment = `<?php

require_once '../vendor/autoload.php';
require_once '../secrets.php';

$HYPER_SWITCH_API_KEY = $hyperswitch_secret_key;
$HYPER_SWITCH_API_BASE_URL = "https://sandbox.hyperswitch.io/payments";

function calculateOrderAmount(array $items): int {
    // Replace this constant with a calculation of the order's amount
    // Calculate the order total on the server to prevent
    // people from directly manipulating the amount on the client
    return 1400;
}

try {

    $jsonStr = file_get_contents('php://input');
    $jsonObj = json_decode($jsonStr);

    /*
        If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
        please pass the fields business_country and business_label in this request body.
        For accessing more features, you can check out the request body schema for payments-create API here :
        https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
    */
    
    $payload = json_encode(array(
        "amount" => calculateOrderAmount($jsonObj->items),
        "currency" => "USD"
    ));

    $ch = curl_init($HYPER_SWITCH_API_BASE_URL);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        'Content-Type: application/json',
        'Accept: application/json',
        'api-key: ' . $HYPER_SWITCH_API_KEY
    ));

    $responseFromAPI = curl_exec($ch);
    if ($responseFromAPI === false) {
         $output = json_encode(array("error" => curl_error($ch)), 403);
    }

    curl_close($ch);

    $decoded_response = json_decode($responseFromAPI, true);

    $output=array("clientSecret" => $decoded_response['client_secret']);

    echo json_encode($output);

} catch (Exception $e) {

    echo json_encode(array("error" => $e->getMessage()), 403);
    
}`
let goRequestPayment = `package main

import (
	"encoding/json"
  	"log"
	"fmt"
	"net/http"
  	"bytes"
)

const HYPER_SWITCH_API_KEY = "HYPERSWITCH_API_KEY"
const HYPER_SWITCH_API_BASE_URL = "https://sandbox.hyperswitch.io"

func createPaymentHandler(w http.ResponseWriter, r *http.Request) {
	
	/*
		If you have two or more “business_country” + “business_label” pairs configured in your Hyperswitch dashboard,
		please pass the fields business_country and business_label in this request body.
		For accessing more features, you can check out the request body schema for payments-create API here :
		https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
	*/
	
	payload := []byte("{"amount": 100, "currency": "USD"}")
	client := &http.Client{}
	req, err := http.NewRequest("POST", HYPER_SWITCH_API_BASE_URL+"/payments", bytes.NewBuffer(payload))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("api-key", HYPER_SWITCH_API_KEY)

	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		http.Error(w, fmt.Sprintf("API request failed with status code: %d", resp.StatusCode), http.StatusInternalServerError)
		return
	}

	var data map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&data)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{"clientSecret": data["client_secret"]})
}

func main() {
	fs := http.FileServer(http.Dir("public"))
  http.Handle("/", fs)
  http.HandleFunc("/create-payment", createPaymentHandler)

  addr := "localhost:4242"
  log.Printf("Listening on %s ...", addr)
  log.Fatal(http.ListenAndServe(addr, nil))
}`

let nodeReplaceApiKey: UserOnboardingTypes.migratestripecode = {
  from: `// FROM
  const stripe = require("stripe")("your_stripe_api_key");
  const paymentIntent = await stripe.paymentIntents.create({...})`,
  to: `//TO 
  const hyper = require("@juspay-tech/hyperswitch-node")("your_hyperswitch_api_key");
  const paymentIntent = await stripe.paymentIntents.create({...})`,
}

let reactCheckoutForm: UserOnboardingTypes.migratestripecode = {
  from: `// FROM
  import { PaymentElement,  useStripe, useElements,} from "@stripe/react-stripe-js";`,
  to: `//TO
  import {   UnifiedCheckout, useStripe,  useElements,} from "@juspay-tech/react-hyper-js";`,
}
let htmlCheckoutForm: UserOnboardingTypes.migratestripecode = {
  from: `// FROM
  <script src="https://js.stripe.com/v3/"></script>`,
  to: `//TO
  <script src="https://beta.hyperswitch.io/v1/HyperLoader.js"></script>`,
}

let reactHyperSwitchCheckout: UserOnboardingTypes.migratestripecode = {
  from: `// FROM
  const stripePromise = loadStripe("your_stripe_publishable_key");`,
  to: `//TO 
  const hyperPromise = loadHyper("your_hyperswitch_publishable_key");
  `,
}
let htmlHyperSwitchCheckout: UserOnboardingTypes.migratestripecode = {
  from: `// FROM 
  const stripe = Stripe("your_stripe_publishable_key");`,
  to: `// To
  const hyper = Hyper("your_hyperswitch_publishable_key"); `,
}

let nodeMigrateFromStripeDXForReact = `npm install @juspay-tech/react-hyper-js
npm install @juspay-tech/hyper-js
npm install @juspay-tech/hyperswitch-node
`
let nodeMigrateFromStripeDXForHTML = `npm install @juspay-tech/hyperswitch-node`

let nodeCreateAPayment: string = `const express = require("express");
const app = express();

const hyperswitch = require("@juspay-tech/hyperswitch-node")('HYPERSWITCH_API_KEY');

app.use(express.static("public"));
app.use(express.json());

const calculateOrderAmount = (items) => {
  return 1345;
};

app.post("/create-payment", async (req, res) => {

  const { items } = req.body;

  /*
     If you have two or more "business_country" + "business_label" pairs configured in your Hyperswitch dashboard,
     please pass the fields business_country and business_label in this request body.
     For accessing more features, you can check out the request body schema for payments-create API here :
     https://api-reference.hyperswitch.io/docs/hyperswitch-api-reference/60bae82472db8-payments-create
  */

  const paymentIntent = await hyperswitch.paymentIntents.create({
    amount: calculateOrderAmount(items),
    currency: "USD",
  });

  res.send({
    clientSecret: paymentIntent.client_secret,
  });
});

app.listen(4242, () => console.log("Node server listening on port 4242!"));`
