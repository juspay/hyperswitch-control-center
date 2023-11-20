# Hyperswitch Control Center

Hyperswitch control center is an open source dashboard to easily view, manage and control your payments across multiple processors through Hyperswitch - an open source payments switch,

## Features

1. Connect to multiple payment processors like Stripe, Braintree, Adyen etc. in a few clicks
2. View and manage payments (payments, refunds, disputes) processed through multiple processors
3. Easily configure routing rules (volume-based, rule-based) to intelligently route your payments
4. Advanced analytics to make sense of your payments data


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
    npm install
    ```

4. Update the .env file in the root directory.

    ```bash
    apiBaseUrl=your-backend-url
    sdkBaseUrl=your-sdk-url
    ```

5. Start the ReScript compiler:
    ```bash
    npm run re:start
    ```

6. Start the development server:

    ```bash
    npm run start
    ```

6. Access the application in your browser at http://localhost:9000.

## Deployment

You can deploy the application to a hosting platform like Netlify, Vercel, or Firebase Hosting. Configure the deployment settings as needed for your chosen platform.

## Contributing
We welcome contributions from the community! If you would like to contribute to Hyperswitch, please follow our contribution guidelines.

## License

This project is open-source and available under the MIT License.
