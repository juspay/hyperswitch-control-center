# Hyperswitch Control Center

Hyperswitch control center is an open source dashboard to easily view, manage and control your payments across multiple processors through Hyperswitch - an open source payments switch.

## Features

1. Connect to multiple payment processors like Stripe, Braintree, Adyen etc. in a few clicks
2. View and manage payments (payments, refunds, disputes) processed through multiple processors
3. Easily configure routing rules (volume-based, rule-based) to intelligently route your payments
4. Advanced analytics to make sense of your payment data

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
   mixpanelToken = mixpanel-token
   # To view Mixpanel events on the Mixpanel dashboard, you must add your Mixpanel token; otherwise, you can ignore this requirement.
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

Feature flags allow the users to enable or disable certain functionalities or flows in the control center.

### Using feature flags

The FeatureFlag.json file can be found under config/FeatueFlag.json. By default, all the feature flags are turned off (`False` value).

### Feature flag descriptions

#### Generate report

The `generate_report` feature flag controls the ability to generate detailed reports on payments, refunds, and disputes. When enabled, this allows users to pull reports covering the previous 6 months of transaction data. The reports can provide insights into trends, identify issues, and inform business decisions.

#### Business profile

The `business_profile` feature flag enables the ability to create multiple business profiles within a single organisation account. Each business profile can have its own settings, connectors, and payment routing configuration from other profiles. This allows large enterprises to manage different lines of business, subsidiaries, or geographic regions under one umbrella account while keeping the data and workflows separate.

#### Mixpanel

The `mixpanel` feature flag controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via REST API.

#### MixpanelSDK

The `mixpanel_sdk` feature flag controls the collection and transmission of anonymous usage data to Mixpanel for analytics. When enabled, the dashboard will automatically send information about user actions and events to Mixpanel without collecting any personally identifiable information via it's SDK.

#### Verify Connector

The `verify_connector` feature flag enables connector validation when adding new payment processors. When enabled, this will perform a test API call to the processor after entering credentials to verify connectivity. This helps catch any issues with the integration or credentials before attempting to process live payments.

#### Feedback

The `feedback` feature flag enables the ability for users to provide direct product feedback from within the dashboard. When enabled, a feedback modal will be available in the UI that allows users to rate features, report bugs, and suggest improvements. Disabling this flag will remove the feedback modal and prevent collection of any user data.

#### Test Processors

The `test_processors` feature flag allows enabling sandbox/test payment processors for testing purposes. When enabled, developers and testers can add test payment processors like Stripe Test or PayPal Test to trial payment flows without touching live transactions or making processor API calls.

#### User Management / Team

The `user_management` feature flag enables user administration capabilities. When enabled, administrators can add, edit, and remove user accounts from the organization. They can also manage user roles and permissions that control access to different features and data.

#### Recon

The `recon` feature flag enables access to reconciliation capabilities in the Hyperswitch dashboard. When turned on, this unlocks the Reconciliation module that allows users to match payment transactions with bank/ledger entries for accounting purposes.

#### Payout

The `payout` feature flag enables the payout functionality in the dashboard. When enabled, this allows users to configure payout profiles, manage recipient details, schedule disbursements, and process payout batches to pay out funds to third parties.

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

#### Is Live Mode

The `is_live_mode` feature flag enables the live mode - that the user is accessing. When enabled, it will show a visual indicator within the dashboard signaling whether the user is currently in a test environment or live production environment.

#### Magic Link

The `magic_link` feature flag enables user sign-in and sign-up using magic links instead of passwords. When enabled, users can request a magic link via email that logs them into their account or creates a new account if they are signing up.

#### Production Access

The `production_access` feature flag enables a flow for users to request live production access. When enabled, it shows a modal or call-to-action allowing users to indicate interest in taking their account live and processing real payments.

#### Quick Start

The `quick_start` feature flag enables the simplified onboarding flow for new users, where they connect to processors, configure payment routing and test a payment, all in one flow.

#### Customers Module

The `customers_module` feature flag enables the customers module in dashboard. Users can see the customers and their details via enabling this flag.

---

## Deployment

You can deploy the application to a hosting platform like Netlify, Vercel, or Firebase Hosting. Configure the deployment settings as needed for your chosen platform.

### Deploy on AWS cloud

What you need to get started

- An AWS account

> P.S. You can directly start from Step 3 if you have installed and configured AWS CLI.

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

For this step you would need the following from your AWS account

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
curl https://raw.githubusercontent.com/juspay/hyperswitch-control-center/main/aws/hyperswitch_control_center_aws_setup.sh | bash
```

> This step takes around 10-15min

Once the script is executed, you will receive a Public IP as the response (e.g. http://34.207.75.225). This IP is the base URL for accessing the application's APIs

#### Clean Up

If you want to delete the application from your account simply run the below clean up script. You need to install JQ for this. For more information, [click here](https://jqlang.github.io/jq/download/)

```
curl https://raw.githubusercontent.com/juspay/hyperswitch-control-center/main/aws/hyperswitch_control_center_cleanup_setup.sh | bash
```

---

## Versioning

For a detailed list of changes made in each version, please refer to the [CHANGELOG](./CHANGELOG.md) file.

---

## Contributing

We welcome contributions from the community! If you would like to contribute to Hyperswitch, please follow our contribution guidelines.

### Commit Conventions

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for our commit messages. Each commit message should have a structured format:

`<type>(<subject>): <description>`

The commit message should begin with one of the following keywords followed by a colon: 'feat', 'fix', 'chore', 'refactor', 'docs', 'test' or 'style'. For example, it should be formatted like this: `feat: <subject> - <description>`

### Signing Commits

All commits should be signed to verify the authenticity of contributors. Follow the steps below to sign your commits:

1.  Generate a GPG key if you haven't already:

    ```bash
    gpg --gen-key
    ```

2.  List your GPG keys and copy the GPG key ID::

    ```bash
    gpg --list-secret-keys --keyid-format LONG
    ```

    #### Identify the GPG key you want to add to your GitHub account.

    a. Run the following command to export your GPG public key in ASCII-armored format:

    ```bash
      gpg --armor --export <GPG_KEY_ID>
    ```

    Replace <GPG_KEY_ID> with the actual key ID.

    b. Copy the entire output, including the lines that start with "-----BEGIN PGP PUBLIC KEY BLOCK-----" and "-----END PGP PUBLIC KEY BLOCK-----".

    c. Go to your GitHub Settings.

    d. Click on "SSH and GPG keys" in the left sidebar.

    e. Click the "New GPG key" button.

    f. Paste your GPG public key into the provided text box.

    g. Click the "Add GPG key" button.

    h. Now your GPG public key is associated with your GitHub account, and you can sign your commits for added security.

3.  Configure Git to use your GPG key:

    ```bash
    git config --global user.signingkey <GPG_KEY_ID>
    ```

4.  Set Git to sign all your commits by default:

    ```bash
    git config --global commit.gpgSign true
    ```

5.  Commit your changes with the -S option to sign the commit:
    ```bash
    git commit -S -m "your commit message"
    ```

For further assistance, please refer to the [GitHub documentation on signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits).

---

## Standard Process for Raising a Pull Request (PR) from a Branch

### Introduction

Welcome to the standard process for raising a Pull Request (PR) directly from a branch in our project! Please follow these guidelines to ensure that your contributions align with our project's goals and standards.

### Steps to Raise a PR from a Branch

1. **Clone the Repository**:

   - Clone the main repository to your local machine using the following command:
     ```bash
     git clone https://github.com/juspay/hyperswitch-control-center.git
     ```

2. **Create a New Branch**:

   - Create a new branch for your changes directly in the main repository. Please ensure the branch name is descriptive and relates to the feature or bug you're addressing.
     ```bash
     git checkout -b feature/your-feature-name
     ```

3. **Make Changes**:

   - Make the necessary changes in the codebase, ensuring that you follow the project's coding guidelines and standards.

4. **Commit Changes**:

   - Commit your changes with a clear and descriptive commit message. Please follow conventional commit [guidelines](https://www.conventionalcommits.org/).

5. **Push Changes**:

   - Push your changes to the branch in the main repository.
     ```bash
     git push origin feature/your-feature-name
     ```

6. **Create a Pull Request**:

   - Navigate to the main repository on GitHub and create a new PR from your branch. Provide a detailed description of the changes, along with any relevant context or screenshots.

7. **Respond to Feedback**:

   - Be responsive to feedback from reviewers. Address any comments or suggestions promptly and make the necessary changes as required.

### Additional Notes

- Ensure your PR adheres to our coding guidelines, style conventions, and documentation standards.
- Include relevant tests, documentation updates, or screenshots, if applicable.
- Collaborate and communicate effectively with other contributors and maintainers throughout the review process.

## License

This project is open-source and available under the Apache 2.0 license.

---
