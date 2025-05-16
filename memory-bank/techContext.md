# Hyperswitch Control Center - Technical Context

## Technology Stack Overview

Hyperswitch Control Center is built using a modern frontend technology stack centered around ReScript (a strongly-typed functional language that compiles to JavaScript) and React, with a focus on type safety, composability, and performance.

### Core Technologies

| Category | Technologies |
|----------|-------------|
| **Primary Language** | ReScript |
| **UI Framework** | React 18 |
| **Styling** | Tailwind CSS |
| **State Management** | Recoil |
| **Build System** | Webpack |
| **API Interaction** | Fetch (bs-fetch) |
| **Date Handling** | Day.js |
| **Visualization** | ApexCharts, Highcharts |
| **Form Management** | React Final Form |

## ReScript Overview

ReScript is the core language of the project, providing:

- **Strong Type System**: Catch errors at compile time rather than runtime
- **Pattern Matching**: Powerful capability for handling complex data structures
- **Interoperability**: Seamless JavaScript integration
- **Functional Paradigm**: Immutable data and pure functions as defaults

Key ReScript files are organized with:
- `.res` files containing the implementation
- `.resi` files containing the interface/type definitions (when present)

## Architecture Components

### Frontend Structure

1. **Components Layer**
   - Reusable UI components (src/components/)
   - Typed interfaces for component props
   - Component composition pattern

2. **API Layer**
   - Centralized API utilities (src/APIUtils/)
   - Type-safe API request/response handling
   - Error handling patterns

3. **State Management**
   - Recoil atoms and selectors (src/Recoils/)
   - Global state organization
   - Type-safe state access

4. **Module Organization**
   - Feature-based modules (Hypersense, IntelligentRouting, Recon, etc.)
   - Each module typically contains:
     - App component (entry point)
     - Container components (logic)
     - Screen components (presentation)

5. **Utility Layer**
   - Generic utilities (src/utils/)
   - Typography utilities (src/Typography/)
   - UI configuration (src/UIConfig/)

### Build System

- **Webpack**: Used for bundling and development server
- **Configuration Files**:
  - webpack.common.js - Common configuration
  - webpack.dev.js - Development-specific configuration
  - webpack.prod.js - Production-specific configuration
  - webpack.custom.js - Custom builds
  - webpack.server.js - Server configuration

### Development Workflow

1. **ReScript Compilation**
   - `npm run re:start` watches and compiles ReScript files
   - Compiled JavaScript is then processed by webpack

2. **Development Server**
   - `npm run start` launches the webpack dev server
   - Hot Module Replacement for quick iteration

3. **Production Build**
   - `npm run build:prod` creates optimized production build
   - Output is served from the dist directory

## Features & Customization

### Feature Flag System

Feature flags allow for controlled feature rollout and customization:

- Configuration stored in `config/FeatureFlag.json`
- Runtime overrides possible via environment variables
- Commonly toggled features include:
  - Payment features (reconciliation, payouts, FRM)
  - UI features (branding, test/live mode)
  - Integration options (email, test processors)

### Theming System

The application supports theme customization:

- Theme configuration in `ThemesProvider.res`
- Overridable values for colors, sidebar styles, buttons
- Custom logo and favicon support
- Runtime customization via environment variables

## Development Setup

### Prerequisites

- Node.js and npm/yarn
- Git (for version control)
- Docker (for running Hyperswitch backend)

### Getting Started Steps

1. **Clone repository**
   ```bash
   git clone https://github.com/juspay/hyperswitch-control-center.git
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start ReScript compiler**
   ```bash
   npm run re:start
   ```

4. **Configure Backend**
   - Clone and run Hyperswitch backend
   - Update config.toml with correct endpoints

5. **Start Development Server**
   ```bash
   npm run start
   ```

### Deployment Options

- **Docker**: Docker-based deployment using provided Dockerfile
- **AWS**: Automated AWS deployment using provided scripts
- **Custom**: Build with webpack and deploy to any static hosting

## Testing Framework

- **Cypress**: Used for end-to-end testing
- **Test Structure**: Organized in cypress/e2e/ by feature area
- **Test Execution**: Via `npm run cy:open` or `npm run cy:run`

## Technical Constraints

1. **Browser Compatibility**
   - Modern browser focus (Chrome, Firefox, Safari, Edge)
   - No explicit IE11 support

2. **Performance Targets**
   - Dashboard loading under 3 seconds
   - Smooth UI interactions (60 FPS)
   - Efficient handling of large data sets

3. **API Dependencies**
   - Requires functional Hyperswitch backend API
   - Configuration via config.toml

## Libraries & Dependencies

### Core Dependencies

- **@rescript/react**: ReScript bindings for React
- **@rescript/core**: Core ReScript utilities
- **recoil**: Atomic state management
- **tailwindcss**: Utility-first CSS framework

### UI Components and Visualization

- **@headlessui/react**: Unstyled, accessible UI components
- **apexcharts/react-apexcharts**: Interactive charts
- **highcharts/highcharts-react-official**: Advanced charting
- **framer-motion**: Animation library
- **react-beautiful-dnd**: Drag and drop functionality

### Form Handling

- **final-form/react-final-form**: Form state management
- **js-datepicker**: Date picker component

### Other Utilities

- **dayjs**: Lightweight date manipulation
- **mixpanel-browser**: Analytics integration
- **lottie-react**: Animation rendering
- **monaco-editor**: Code editor component

## Integration Points

1. **Hyperswitch API**
   - Primary backend integration point
   - REST API communication

2. **Payment Processors**
   - Indirect integration via Hyperswitch API
   - Processor-specific configuration screens

3. **Analytics Tools**
   - Mixpanel integration (when enabled)
   - Google Analytics integration (react-ga4)
