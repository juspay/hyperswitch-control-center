# Hyperswitch Control Center

Hyperswitch control center is an open source dashboard to easily view, manage and control your payments across multiple processors through Hyperswitch - an open source payments switch.

## Features

1. Connect to multiple payment processors like Stripe, Braintree, Adyen etc. in a few clicks
2. View and manage payments (payments, refunds, disputes) processed through multiple processors
3. Easily configure routing rules (volume-based, rule-based) to intelligently route your payments
4. Advanced analytics to make sense of your payments data

---

## Standard Installation

### Prerequisites

1. Node.js and npm installed on your machine.

### Installation Steps

Follow these simple steps to set up Hyperswitch on your local machine.

1. Clone the repository:

   ```bash
   git clone https://github.com/juspay/hyperswitch-control-center.git
   ```

2. Navigate to the project directory:

   ```bash
    cd hyperswitch-control-center
   ```

3. Install project dependencies:

   ```bash
   npm install --force
   ```

4. Update the .env file in the root directory.

   ```bash
   apiBaseUrl = your-backend-url
   sdkBaseUrl = your-sdk-url
   ```

5. Start the ReScript compiler:

   ```bash
   npm run re:start
   ```

6. In another terminal window, start the development server:

   ```bash
   npm run start
   ```

7. Access the application in your browser at http://localhost:9000.

---

## Feature Flags

Feature flags allows the users to enable or disable certain functionalities or flows in the control center.

### Using feature flags

The FeatureFlag.json file can be found under config/FeatueFlag.json. By default, all the feature flags is turned off (`False` value).

### Feature flag descriptions

#### Generate report

The `generate_report` feature flag controls the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.

#### Business profile

The `business_profile` feature flag enables the ability to create multiple business profiles within a single organisation account. Each business profile can have its own settings, connectors, and payment routing configuration from other profiles. This allows large enterprises to manage different lines of business, subsidiaries, or geographic regions under one umbrella account while keeping the data and workflows separate.

#### Mixpanel

The `mixpanel` feature flag controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information.

#### Verify Connector

The `verify_connector` feature flag enables connector validation when adding new payment processors. When enabled, this will perform a test API call to the processor after entering credentials to verify connectivity. This helps catch any issues with the integration or credentials before attempting to process live payments.

#### Feedback

The `feedback` feature flag enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.

#### Test Processors

The `test_processors` feature flag allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payments flows without touching live transactions or making processor API calls.

#### User Management

The `user_management` feature flag enables user administration capabilities. When enabled, administrators can add, edit, and remove user accounts from the organization. They can also manage user roles and permissions that control access to different features and data.

#### Recon

The `recon` feature flag enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.

#### Payout

The `payout` feature flag enables the payouts functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.

#### FRM

The `frm` feature flag enables the Fraud and Risk Management (FRM) module within the dashboard. When enabled, this unlocks integrations with FRM players like Riskified and Signified.

#### Sample data

The `sample_data` feature flag enables the ability to load simulated sample data into the dashboard for preview purposes. When enabled, dummy transactions, analytics, and reporting data can be generated.

#### System Metrics

The `system_metrics` feature flag unlocks access to system monitoring and metrics pages within the dashboard. When enabled, users can view technical performance data like payment latency, uptime, API response times, error rates, and more.

#### Audit trail

The `audit_trail` feature flag enables access to payment and refund audit logs within the dashboard. When turned on, users can view detailed trails showing the history of transactions including status changes, approvals, edits, and more.

#### Switch Merchant

The `switch_merchant` feature flag allows organizations to create and manage multiple merchant accounts within a single dashboard instance. When enabled, users can set up and configure separate merchants for different business lines, products, or brands. Users can switch between merchant profiles which have independent settings, connectors, and reporting.

#### Home page

The `home_page` feature flag controls whether the dashboard home page is enabled or hidden. When turned on, the home page displaying summary metrics and quick links will be visible after logging in.

#### Test Live Toggle

The `test_live_toggle` feature flag enables users to toggle between test and live modes when signing in. When enabled, users will see an option during sign-in to actively switch between test and live environments.

#### Test Live Mode

The `test_live_mode` feature flag enables displaying the current mode - test or live - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment.

#### Magic Link

The `magic_link` feature flag enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.

#### Production Access

The `production_access` feature flag enables a flow for users to request live production access. When enabled, it shows a modal or call-to-action allowing users to indicate interest in taking their account live and processing real payments.

#### Quick Start

The `quick_start` feature flag enables the simplified onboarding flow for new users, where he connects to processors, configure payment routing and testing a payment, all in one flow.

#### Stripe plus paypal

The `stripe_plus_paypal` feature flag enables access to simplified multi-processor connectivity through Stripe and PayPal. When turned on, users are guided through a streamlined setup flow to connect both Stripe and PayPal accounts and experience it in a checkout page.

#### Woocommerce

The `woocommerce` feature flag controls the visibility of WooCommerce integration with Hyperswitch flow within the dashboard. When enabled, users will have access to the step-by-step guide to integrate the woocommerce plugin for hyperswitch.

#### Open SDK

The `open_sdk` feature flag enables access to the Checkout Page web SDK from within the dashboard. When enabled, developers can preview the SDK from within the dashboard and make payments.

---

## Deployment

You can deploy the application to a hosting platform like Netlify, Vercel, or Firebase Hosting. Configure the deployment settings as needed for your chosen platform.

### Deploy on AWS cloud

What you need to get started

- An AWS account

> P.S. You can directly start fron Step 3 if you have installed and configured AWS CLI.

#### Step 1 - Install or update the AWS CLI

> For more information, [click here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

**For Linux x86 (64-bit)**

1. Run the following command on your terminal

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

2. Confirm the installation with the following command

```
aws --version
```

3. Expected Response: aws-cli/2.10.0 Python/3.11.2 Linux/4.14.133-113.105.amzn2.x86_64 botocore/2.4.5

**For Linux ARM**

1. Run the following command on your terminal

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

2. Confirm the installation with the following command

```
aws --version
```

3. Expected Response: aws-cli/2.10.0 Python/3.11.2 Linux/4.14.133-113.105.amzn2.x86_64 botocore/2.4.5

**For MacOS**

1. Run the following command on your terminal

```
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

2. To verify that the shell can find and run the aws command in your $PATH, use the following commands

```
which aws
```

3. Expected Response: /usr/local/bin/aws

#### Step 2 - Configure the AWS CLI

For this step you would need the following from you AWS account

- Access key ID
- Secret Access Key

You can create or manage your access keys from the Security Credentials tab inside your AWS Console. For more information, [click here](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)

![image](https://github.com/juspay/hyperswitch-control-center/assets/126671331/eda911ec-ae09-49be-99ca-3b32f262be9b)

Once you have the keys run the below command

```
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

#### Step 3 - Setup Hyperswitch

You can now deploy the hyperswitch application by running the below command in the same terminal session.

```
curl https://raw.githubusercontent.com/juspay/hyperswitch/main/aws/hyperswitch_control_center_aws_setup.sh | bash
```

> This step takes around 10-15min

Once the script is executed, you will receive a Public IP as the response (e.g. http://34.207.75.225). This IP is the base URL for accessing the application's APIs

#### Clean Up

If you want to delete the application from your account simply run the below clean up script. Ypu need to install JQ for this. For more information, [click here](https://jqlang.github.io/jq/download/)

```
curl https://raw.githubusercontent.com/juspay/hyperswitch/main/aws/hyperswitch_control_center_cleanup_setup.sh | bash
```

---

## Contributing

We welcome contributions from the community! If you would like to contribute to Hyperswitch, please follow our contribution guidelines.

---

## License

This project is open-source and available under the MIT License.

---
