## Type of Change

<!-- Put an `x` in the boxes that apply -->

- [ ] Bugfix
- [x] New feature
- [ ] Enhancement
- [ ] Refactoring
- [ ] Dependency updates
- [ ] Documentation
- [ ] CI/CD

## Description

Enable merchants to clone/copy volume-based routing configurations between business profiles using a simple copy-paste workflow.

### Changes Made:

1. **src/libraries/Clipboard.res**
   - Added `readTextDoc` binding for reading clipboard text via navigator.clipboard API

2. **src/screens/Routing/RoutingTypes.res**
   - Added `clipboardVolumeSplitData` type for volume split data structure
   - Added `clipboardAlgorithm` type for algorithm data with splits
   - Added `clipboardRoutingData` type for complete clipboard payload (name, description, algorithm, source_profile, copied_at)
   - Added `clipboardValidationResult` variant type (Valid | Invalid | Expired | NotFound)

3. **src/screens/Routing/RoutingUtils.res**
   - Added `extractVolumeSplitData` function to extract splits from algorithm dict
   - Added `copyRoutingToClipboard` function to copy routing config as JSON with toast notification
   - Added `validateClipboardData` function to validate JSON structure, algorithm type (volume_split), and 24-hour expiration
   - Added `readRoutingFromClipboard` function to read clipboard with permission handling
   - Added `generateUniqueName` function to handle duplicate name resolution with "(Copy)" suffix

4. **src/screens/Routing/VolumeSplitRouting/VolumeSplitRouting.res**
   - Added `IndividualConnectorSelect` component for per-slot connector selection with dropdown
   - Added "Copy Configuration" button in Preview state next to "Duplicate & Edit Configuration"
   - Added paste banner in Create state that appears when clipboard contains valid routing config from different profile
   - Shows "Original volume splits: X%, Y%" in paste banner for user reference
   - Renders individual dropdowns for each pre-filled slot when pasting
   - Filters out already-selected connectors from other slot dropdowns (prevents duplicates)
   - Shows selected connector as a chip with X button to clear selection
   - Validates all slots filled before enabling "Configure Rule" button (shows warning message if not)
   - Preserves original volume split percentages when pasting configuration

## Motivation and Context

Merchants with multiple business profiles currently need to manually recreate the same routing logic for each profile. This is time-consuming and error-prone. This feature addresses this pain point by allowing merchants to:

1. Copy a volume-based routing configuration from one profile
2. Switch to another profile using the existing profile switcher
3. Paste the configuration with pre-filled volume splits
4. Select appropriate connectors for the target profile
5. Save the cloned configuration

The solution leverages profile-scoped JWT tokens, so no complex cross-profile APIs are needed - just a simple frontend copy-paste approach.

## How did you test it?

<!-- Testing was done manually. Screenshots can be provided if needed. -->

### Manual Testing Steps:

1. **Copy Configuration:**
   - Navigate to Volume Split Routing in Profile A
   - Click "Copy Configuration" button
   - Verify toast: "Configuration copied! Switch profiles and paste to clone."
   - Verify clipboard contains JSON with name, description, splits, source_profile

2. **Paste Configuration:**
   - Switch to Profile B
   - Navigate to Create New Volume Split Routing
   - Verify paste banner appears: "Paste configuration from another profile?"
   - Verify banner shows: "Original volume splits: 50%, 50%"

3. **Select Connectors:**
   - Click "Paste Configuration" button
   - Verify individual dropdowns appear for each slot with correct percentages
   - Select connector for Slot 1
   - Verify selected connector appears as chip (dropdown hidden)
   - Verify connector removed from Slot 2 dropdown options
   - Select connector for Slot 2

4. **Validation:**
   - Verify "Configure Rule" button appears only after all slots filled
   - Verify warning message when slots not filled: "Please select a connector for each slot to continue."
   - Click X on selected connector to clear selection
   - Verify connector reappears in other dropdowns

5. **Save:**
   - Click "Configure Rule" button
   - Verify configuration saves with correct split percentages
   - Verify backend receives correct format with connector name (not MCI ID)

## Where to test it?

- [ ] INTEG
- [x] SANDBOX
- [ ] PROD

## Checklist

<!-- Put an `x` in the boxes that apply -->

- [x] I ran `npm run re:build`
- [x] I reviewed submitted code
- [ ] I added unit tests for my changes where possible

## API Changes

No backend API changes required. The feature uses existing APIs:
- `POST /routing` - Create new routing config
- `GET /account/profiles` - List profiles
- `GET /account/connectors` - List connectors for current profile

## Security Considerations

1. **Clipboard access**: Requires user gesture (click) to read clipboard
2. **No sensitive data**: Copied JSON contains only routing logic (name, description, splits), no credentials or secrets
3. **Profile validation**: Source profile ID included for reference only; no cross-profile access
4. **Expiration**: Clipboard data older than 24 hours is rejected

## Future Enhancements (Out of Scope)

1. Support for Priority routing algorithm copy-paste
2. Support for Advanced routing copy-paste
3. Copy history (last 5 copied configs)
4. Template library (save as reusable template)