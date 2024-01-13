/* tslint:disable */
/* eslint-disable */
/**
* This function can be used by the frontend to educate wasm about the forex rates data.
* The input argument is a struct fields base_currency and conversion where later is all the conversions associated with the base_currency
* to all different currencies present.
* @param {any} forex
* @returns {any}
*/
export function setForexData(forex: any): any;
/**
* This function can be used to perform currency_conversion on the input amount, from_currency,
* to_currency which are all expected to be one of currencies we already have in our Currency
* enum.
* @param {bigint} amount
* @param {any} from_currency
* @param {any} to_currency
* @returns {any}
*/
export function convertCurrency(amount: bigint, from_currency: any, to_currency: any): any;
/**
* This function can be used by the frontend to provide the WASM with information about
* all the merchant's connector accounts. The input argument is a vector of all the merchant's
* connector accounts from the API.
* @param {any} mcas
* @returns {any}
*/
export function seedKnowledgeGraph(mcas: any): any;
/**
* This function allows the frontend to get all the merchant's configured
* connectors that are valid for a rule based on the conditions specified in
* the rule
* @param {any} rule
* @returns {any}
*/
export function getValidConnectorsForRule(rule: any): any;
/**
* @param {any} js_program
* @returns {any}
*/
export function analyzeProgram(js_program: any): any;
/**
* @param {any} program
* @param {any} input
* @returns {any}
*/
export function runProgram(program: any, input: any): any;
/**
* @returns {any}
*/
export function getAllConnectors(): any;
/**
* @returns {any}
*/
export function getAllKeys(): any;
/**
* @param {string} key
* @returns {string}
*/
export function getKeyType(key: string): string;
/**
* @returns {any}
*/
export function getThreeDsKeys(): any;
/**
* @returns {any}
*/
export function getSurchargeKeys(): any;
/**
* @param {string} val
* @returns {string}
*/
export function parseToString(val: string): string;
/**
* @param {string} key
* @returns {any}
*/
export function getVariantValues(key: string): any;
/**
* @param {bigint} n1
* @param {bigint} n2
* @returns {bigint}
*/
export function addTwo(n1: bigint, n2: bigint): bigint;
/**
* @param {string} key
* @returns {any}
*/
export function getConnectorConfig(key: string): any;
/**
* @param {string} key
* @returns {any}
*/
export function getPayoutConnectorConfig(key: string): any;
/**
* @param {any} input
* @param {any} response
* @returns {any}
*/
export function getRequestPayload(input: any, response: any): any;
/**
* @param {any} input
* @returns {any}
*/
export function getResponsePayload(input: any): any;
/**
* @returns {any}
*/
export function getDescriptionCategory(): any;
/**
*
* Function exposed as `wasm` function in js `parse`. Allowing use to extend the functionality and
* usage for web
* @param {string} val
* @returns {string}
*/
export function parse(val: string): string;

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly setForexData: (a: number, b: number) => void;
  readonly convertCurrency: (a: number, b: number, c: number, d: number) => void;
  readonly seedKnowledgeGraph: (a: number, b: number) => void;
  readonly getValidConnectorsForRule: (a: number, b: number) => void;
  readonly analyzeProgram: (a: number, b: number) => void;
  readonly runProgram: (a: number, b: number, c: number) => void;
  readonly getAllConnectors: (a: number) => void;
  readonly getAllKeys: (a: number) => void;
  readonly getKeyType: (a: number, b: number, c: number) => void;
  readonly getThreeDsKeys: (a: number) => void;
  readonly getSurchargeKeys: (a: number) => void;
  readonly getVariantValues: (a: number, b: number, c: number) => void;
  readonly addTwo: (a: number, b: number) => number;
  readonly getConnectorConfig: (a: number, b: number, c: number) => void;
  readonly getPayoutConnectorConfig: (a: number, b: number, c: number) => void;
  readonly getRequestPayload: (a: number, b: number, c: number) => void;
  readonly getResponsePayload: (a: number, b: number) => void;
  readonly getDescriptionCategory: (a: number) => void;
  readonly parse: (a: number, b: number, c: number) => void;
  readonly parseToString: (a: number, b: number, c: number) => void;
  readonly __wbindgen_export_0: (a: number, b: number) => number;
  readonly __wbindgen_export_1: (a: number, b: number, c: number, d: number) => number;
  readonly __wbindgen_add_to_stack_pointer: (a: number) => number;
  readonly __wbindgen_export_2: (a: number, b: number, c: number) => void;
  readonly __wbindgen_export_3: (a: number) => void;
}

export type SyncInitInput = BufferSource | WebAssembly.Module;
/**
* Instantiates the given `module`, which can either be bytes or
* a precompiled `WebAssembly.Module`.
*
* @param {SyncInitInput} module
*
* @returns {InitOutput}
*/
export function initSync(module: SyncInitInput): InitOutput;

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {InitInput | Promise<InitInput>} module_or_path
*
* @returns {Promise<InitOutput>}
*/
export default function __wbg_init (module_or_path?: InitInput | Promise<InitInput>): Promise<InitOutput>;
