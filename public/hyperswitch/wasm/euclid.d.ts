/* tslint:disable */
/* eslint-disable */
/**
 * This function can be used by the frontend to educate wasm about the forex rates data.
 * The input argument is a struct fields base_currency and conversion where later is all the conversions associated with the base_currency
 * to all different currencies present.
 */
export function setForexData(forex: any): any;
/**
 * This function can be used to perform currency_conversion on the input amount, from_currency,
 * to_currency which are all expected to be one of currencies we already have in our Currency
 * enum.
 */
export function convertCurrency(amount: bigint, from_currency: any, to_currency: any): any;
/**
 * This function can be used by the frontend to get all the two letter country codes
 * along with their country names.
 */
export function getTwoLetterCountryCode(): any;
/**
 * This function can be used by the frontend to get all the merchant category codes
 * along with their names.
 */
export function getMerchantCategoryCodeWithName(): any;
/**
 * This function can be used by the frontend to provide the WASM with information about
 * all the merchant's connector accounts. The input argument is a vector of all the merchant's
 * connector accounts from the API.
 */
export function seedKnowledgeGraph(mcas: any): any;
/**
 * This function allows the frontend to get all the merchant's configured
 * connectors that are valid for a rule based on the conditions specified in
 * the rule
 */
export function getValidConnectorsForRule(rule: any): any;
export function analyzeProgram(js_program: any): any;
export function runProgram(program: any, input: any): any;
export function getAllConnectors(): any;
export function getAllKeys(): any;
export function getKeyType(key: string): string;
export function getThreeDsKeys(): any;
export function getSurchargeKeys(): any;
export function getThreeDsDecisionRuleKeys(): any;
export function parseToString(val: string): string;
export function getVariantValues(key: string): any;
export function addTwo(n1: bigint, n2: bigint): bigint;
export function getDescriptionCategory(): any;
export function getConnectorConfig(key: string): any;
export function getPayoutConnectorConfig(key: string): any;
export function getAuthenticationConnectorConfig(key: string): any;
export function getTaxProcessorConfig(key: string): any;
export function getPMAuthenticationProcessorConfig(key: string): any;
export function getRequestPayload(input: any, response: any): any;
export function getResponsePayload(input: any): any;
export function getAllPayoutKeys(): any;
export function getPayoutVariantValues(key: string): any;
export function getPayoutDescriptionCategory(): any;
export function getValidWebhookStatus(key: string): any;
/**
 *
 * Function exposed as `wasm` function in js `parse`. Allowing use to extend the functionality and
 * usage for web
 */
export function parse(val: string): string;

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly setForexData: (a: number, b: number) => void;
  readonly convertCurrency: (a: number, b: bigint, c: number, d: number) => void;
  readonly getTwoLetterCountryCode: (a: number) => void;
  readonly getMerchantCategoryCodeWithName: (a: number) => void;
  readonly seedKnowledgeGraph: (a: number, b: number) => void;
  readonly getValidConnectorsForRule: (a: number, b: number) => void;
  readonly analyzeProgram: (a: number, b: number) => void;
  readonly runProgram: (a: number, b: number, c: number) => void;
  readonly getAllConnectors: (a: number) => void;
  readonly getAllKeys: (a: number) => void;
  readonly getKeyType: (a: number, b: number, c: number) => void;
  readonly getThreeDsKeys: (a: number) => void;
  readonly getSurchargeKeys: (a: number) => void;
  readonly getThreeDsDecisionRuleKeys: (a: number) => void;
  readonly parseToString: (a: number, b: number, c: number) => void;
  readonly getVariantValues: (a: number, b: number, c: number) => void;
  readonly addTwo: (a: bigint, b: bigint) => bigint;
  readonly getDescriptionCategory: (a: number) => void;
  readonly getConnectorConfig: (a: number, b: number, c: number) => void;
  readonly getPayoutConnectorConfig: (a: number, b: number, c: number) => void;
  readonly getAuthenticationConnectorConfig: (a: number, b: number, c: number) => void;
  readonly getTaxProcessorConfig: (a: number, b: number, c: number) => void;
  readonly getPMAuthenticationProcessorConfig: (a: number, b: number, c: number) => void;
  readonly getRequestPayload: (a: number, b: number, c: number) => void;
  readonly getResponsePayload: (a: number, b: number) => void;
  readonly getAllPayoutKeys: (a: number) => void;
  readonly getPayoutVariantValues: (a: number, b: number, c: number) => void;
  readonly getPayoutDescriptionCategory: (a: number) => void;
  readonly getValidWebhookStatus: (a: number, b: number, c: number) => void;
  readonly ring_core_0_17_14__bn_mul_mont: (a: number, b: number, c: number, d: number, e: number, f: number) => void;
  readonly parse: (a: number, b: number, c: number) => void;
  readonly __wbindgen_export_0: (a: number, b: number) => number;
  readonly __wbindgen_export_1: (a: number, b: number, c: number, d: number) => number;
  readonly __wbindgen_export_2: (a: number) => void;
  readonly __wbindgen_add_to_stack_pointer: (a: number) => number;
  readonly __wbindgen_export_3: (a: number, b: number, c: number) => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;
/**
* Instantiates the given `module`, which can either be bytes or
* a precompiled `WebAssembly.Module`.
*
* @param {{ module: SyncInitInput }} module - Passing `SyncInitInput` directly is deprecated.
*
* @returns {InitOutput}
*/
export function initSync(module: { module: SyncInitInput } | SyncInitInput): InitOutput;

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {{ module_or_path: InitInput | Promise<InitInput> }} module_or_path - Passing `InitInput` directly is deprecated.
*
* @returns {Promise<InitOutput>}
*/
export default function __wbg_init (module_or_path?: { module_or_path: InitInput | Promise<InitInput> } | InitInput | Promise<InitInput>): Promise<InitOutput>;
