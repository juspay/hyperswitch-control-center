## Description

Enable merchants to clone/copy volume-based routing rules between business profiles using a simple copy-paste workflow.

## Changes Made

### Files Modified:

1. **src/libraries/Clipboard.res**
   - Added `readTextDoc` binding for reading clipboard text

2. **src/screens/Routing/RoutingTypes.res**
   - Added `clipboardVolumeSplitData` type
   - Added `clipboardAlgorithm` type
   - Added `clipboardRoutingData` type
   - Added `clipboardValidationResult` variant type

3. **src/screens/Routing/RoutingUtils.res**
   - Added `extractVolumeSplitData` function
   - Added `copyRoutingToClipboard` function
   - Added `validateClipboardData` function
   - Added `readRoutingFromClipboard` function
   - Added `generateUniqueName` function

4. **src/screens/Routing/VolumeSplitRouting/VolumeSplitRouting.res**
   - Added `IndividualConnectorSelect` component for per-slot connector selection
   - Added "Copy Configuration" button in Preview state
   - Added paste banner with validation when clipboard contains routing config
   - Shows volume splits reference in paste banner
   - Renders individual dropdowns for each pre-filled slot
   - Filters out already-selected connectors from other slot dropdowns
   - Validates all slots filled before enabling Configure Rule button
   - Preserves original volume split percentages when pasting

## How It Works

1. **Copy**: User clicks "Copy Configuration" in source profile
   - Routing config JSON copied to clipboard with name, description, volume splits
   - Shows success toast

2. **Switch**: User switches to target profile

3. **Paste**: Create page detects clipboard data
   - Shows banner: "Paste configuration from another profile?"
   - Displays original volume splits (e.g., "Original volume splits: 50%, 50%")

4. **Configure**: User clicks "Paste Configuration"
   - Pre-fills name with "(Copy)" suffix
   - Pre-fills description
   - Shows individual select boxes for each slot with original percentages
   - User selects connector for each slot
   - Selected connectors are filtered out from other slots

5. **Save**: All slots must be filled before Configure Rule button is enabled

## Testing

- [ ] Copy button copies correct JSON structure
- [ ] Paste banner shows only when clipboard has valid data from different profile
- [ ] Volume splits are preserved correctly
- [ ] Individual select boxes render for each slot
- [ ] Selected connectors are filtered from other dropdowns
- [ ] Configure Rule button disabled until all slots filled
- [ ] Clear selection (X button) works correctly
- [ ] Backend receives correct format with connector name (not MCI ID)

## Related

This feature addresses the pain point where merchants with multiple profiles must manually recreate the same routing logic for each profile.