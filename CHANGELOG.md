# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -

## 2025.09.17.1

### Features

- Enable Nexixpay in PROD ([#3614](https://github.com/juspay/hyperswitch-control-center/pull/3614)) ([`8056197`](https://github.com/juspay/hyperswitch-control-center/commit/80561974344a148c34a53645c49eae9bd339f74e))

### Bug Fixes

- Fix cypress tests ([#3594](https://github.com/juspay/hyperswitch-control-center/pull/3594)) ([`305af15`](https://github.com/juspay/hyperswitch-control-center/commit/305af15708bd6f360ea784618de70b29fecb3c9f))
- Recon engine data overview `transformed_entries` list with `transformation_history` ([#3609](https://github.com/juspay/hyperswitch-control-center/pull/3609)) ([`6fccf01`](https://github.com/juspay/hyperswitch-control-center/commit/6fccf01c48822d7a7a3da028c5121f6d5db082df))

### Refactors

- Add recon engine hooks for `accounts`, `processing_entries` and `transformation_history` ([#3607](https://github.com/juspay/hyperswitch-control-center/pull/3607)) ([`e835c2d`](https://github.com/juspay/hyperswitch-control-center/commit/e835c2d442cf7a5c0011c1a5094aa01e59bcf572))

### Miscellaneous Tasks

- Count the `staging_entries` based on the `transformation_history_id` ([#3612](https://github.com/juspay/hyperswitch-control-center/pull/3612)) ([`4f0c4fe`](https://github.com/juspay/hyperswitch-control-center/commit/4f0c4fed8eb876a769bb43f4ff029434ba866d94))

**Full Changelog:** [`2025.09.17.0...2025.09.17.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.17.0...2025.09.17.1)

- - -

## 2025.09.17.0

### Refactors

- Recon engine `transactions` and `staging entries` types ([#3603](https://github.com/juspay/hyperswitch-control-center/pull/3603)) ([`63afc6e`](https://github.com/juspay/hyperswitch-control-center/commit/63afc6e5a97b25ba4fd496937ec2ab33bfe0629c))

### Miscellaneous Tasks

- Moved acquirer config settings and new toggles in new payment … ([#3573](https://github.com/juspay/hyperswitch-control-center/pull/3573)) ([`605c16d`](https://github.com/juspay/hyperswitch-control-center/commit/605c16dd5499dea74ad56dcbe151cf02111c168a))

**Full Changelog:** [`2025.09.16.0...2025.09.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.16.0...2025.09.17.0)

- - -

## 2025.09.16.0

### Features

- Added new connector peachpayments ([#3592](https://github.com/juspay/hyperswitch-control-center/pull/3592)) ([`e62dadd`](https://github.com/juspay/hyperswitch-control-center/commit/e62dadd5b1b4ca12464b141fe9a83aee2e6461e7))

### Bug Fixes

- Reconciliation engine naming and style changes ([#3590](https://github.com/juspay/hyperswitch-control-center/pull/3590)) ([`5fa841d`](https://github.com/juspay/hyperswitch-control-center/commit/5fa841d8d245f2065b70490bd8fc85366f287505))

### Refactors

- Move recon engine `account` and `rule` types from `ReconEngineOverviewTypes` to `ReconEngineTypes` ([#3597](https://github.com/juspay/hyperswitch-control-center/pull/3597)) ([`8e2a564`](https://github.com/juspay/hyperswitch-control-center/commit/8e2a564f94952b938e37ed33b0b5c6ef0545ee2f))
- Recon engine `ingestion` and `transformation` types ([#3601](https://github.com/juspay/hyperswitch-control-center/pull/3601)) ([`a67af3b`](https://github.com/juspay/hyperswitch-control-center/commit/a67af3b55368159fa8da2c2a35acc37fe26bd060))

### Miscellaneous Tasks

- Updated wasm for peachpayments connector ([#3593](https://github.com/juspay/hyperswitch-control-center/pull/3593)) ([`719bf92`](https://github.com/juspay/hyperswitch-control-center/commit/719bf92728e4b80e1c7e39cf5953772aebfb803c))

**Full Changelog:** [`2025.09.11.1...2025.09.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.11.1...2025.09.16.0)

- - -

## 2025.09.11.1

### Features

- Added manual retries and always enable overcapture toggles in payment settings ([#3540](https://github.com/juspay/hyperswitch-control-center/pull/3540)) ([`045236c`](https://github.com/juspay/hyperswitch-control-center/commit/045236ce1d0ead49d7ef3987c44f15b6e7d74185))
- Overview Screen changes ([#3563](https://github.com/juspay/hyperswitch-control-center/pull/3563)) ([`8dc4d36`](https://github.com/juspay/hyperswitch-control-center/commit/8dc4d36316eda14ff105be451a01dbf00fbe3bce))
- Recon engine accounts transformation page ([#3562](https://github.com/juspay/hyperswitch-control-center/pull/3562)) ([`8a51c03`](https://github.com/juspay/hyperswitch-control-center/commit/8a51c03df0084d7629b61a2f73a633b3e69e52bc))
- Exceptions screens recon engine ([#3569](https://github.com/juspay/hyperswitch-control-center/pull/3569)) ([`e8065c6`](https://github.com/juspay/hyperswitch-control-center/commit/e8065c66c41353d7d9810ca9d492a7feb2eaf3d4))
- Overview Transactions Table entity ([#3570](https://github.com/juspay/hyperswitch-control-center/pull/3570)) ([`ba97d9f`](https://github.com/juspay/hyperswitch-control-center/commit/ba97d9f5340cfd4aea2dbf44f0e10a163a255ca4))
- Recon engine accounts transformation details page ([#3575](https://github.com/juspay/hyperswitch-control-center/pull/3575)) ([`ffb69bd`](https://github.com/juspay/hyperswitch-control-center/commit/ffb69bdeb53ab1893d897880433fabcf911d213b))
- Added new connector paysafe ([#3579](https://github.com/juspay/hyperswitch-control-center/pull/3579)) ([`f3db350`](https://github.com/juspay/hyperswitch-control-center/commit/f3db35078fd2892dae67d66fc708983acae9453d))
- Recovery enable api-key creation and response key hash key field display in the summary page ([#3578](https://github.com/juspay/hyperswitch-control-center/pull/3578)) ([`7031843`](https://github.com/juspay/hyperswitch-control-center/commit/70318431602954ec9dd1b90082a35b841ef7bf24))
- Recon engine accounts transformed entries page ([#3584](https://github.com/juspay/hyperswitch-control-center/pull/3584)) ([`4434d7c`](https://github.com/juspay/hyperswitch-control-center/commit/4434d7cf559600055eadf597304f23915280cc69))
- Recon engine entries sidescreen changes ([#3585](https://github.com/juspay/hyperswitch-control-center/pull/3585)) ([`e53d6f5`](https://github.com/juspay/hyperswitch-control-center/commit/e53d6f5690ad5bda31fc1e6ae7388bfd9c9e1980))

### Bug Fixes

- Conditional heading for hash key ([#3494](https://github.com/juspay/hyperswitch-control-center/pull/3494)) ([`3c9eb0b`](https://github.com/juspay/hyperswitch-control-center/commit/3c9eb0b9604626333bda8ee9def5a304781acf08))

### Refactors

- Permalink usage ([#3566](https://github.com/juspay/hyperswitch-control-center/pull/3566)) ([`58daff1`](https://github.com/juspay/hyperswitch-control-center/commit/58daff1756b889b8ed8ae6c49d0db5489a1d59c2))

### Miscellaneous Tasks

- Updated wasm for paysafe connector ([#3580](https://github.com/juspay/hyperswitch-control-center/pull/3580)) ([`d9b34c9`](https://github.com/juspay/hyperswitch-control-center/commit/d9b34c90660d14cc753a9d95edb72a8406ac87c6))
- Added info icon to webhook url ([#3576](https://github.com/juspay/hyperswitch-control-center/pull/3576)) ([`2537fad`](https://github.com/juspay/hyperswitch-control-center/commit/2537fadf577ee1684601da31a18340f4cf88f52b))

**Full Changelog:** [`2025.09.11.0...2025.09.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.11.0...2025.09.11.1)

- - -

## 2025.09.11.0

### Features

- Recon engine transactions ([#3547](https://github.com/juspay/hyperswitch-control-center/pull/3547)) ([`b82a156`](https://github.com/juspay/hyperswitch-control-center/commit/b82a156dae890396b9633b267cf51e739d45cd29))
- Recon engine accounts overview screen ([#3546](https://github.com/juspay/hyperswitch-control-center/pull/3546)) ([`b109003`](https://github.com/juspay/hyperswitch-control-center/commit/b10900360ec06f675f1d830867ecf758bc73b0d2))

### Bug Fixes

- Fixed custom date range dropdown in routing analytics ([#3537](https://github.com/juspay/hyperswitch-control-center/pull/3537)) ([`934e1ed`](https://github.com/juspay/hyperswitch-control-center/commit/934e1ed018af467dbb838a50b04f90ff208c6319))

**Full Changelog:** [`2025.09.10.1...2025.09.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.10.1...2025.09.11.0)

- - -

## 2025.09.10.1

### Features

- Recovery webhooks url input ([#3541](https://github.com/juspay/hyperswitch-control-center/pull/3541)) ([`b7e8f05`](https://github.com/juspay/hyperswitch-control-center/commit/b7e8f052e30e2621cbab39f627c7cb8d231a4da7))

**Full Changelog:** [`2025.09.10.0...2025.09.10.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.10.0...2025.09.10.1)

- - -

## 2025.09.10.0

**Full Changelog:** [`2025.09.09.2...2025.09.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.09.2...2025.09.10.0)

- - -

## 2025.09.09.2

### Bug Fixes

- Theme config ([`5075b4a`](https://github.com/juspay/hyperswitch-control-center/commit/5075b4a8c2a028c48ce5bb5523688587263d33b0))
- Theme config ([`6b3b9a0`](https://github.com/juspay/hyperswitch-control-center/commit/6b3b9a01d7bcb9c8cf23962e5f705f07fd811b7e))
- Permalink config ([`f452703`](https://github.com/juspay/hyperswitch-control-center/commit/f4527035e475c6604d42185b8afe380977e000c9))

**Full Changelog:** [`2025.09.09.1...2025.09.09.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.09.1...2025.09.09.2)

- - -

## 2025.09.09.1

### Features

- Added decrypted flow for Nuvei and worldpayvantiv connectors in… ([#3532](https://github.com/juspay/hyperswitch-control-center/pull/3532)) ([`5b989e0`](https://github.com/juspay/hyperswitch-control-center/commit/5b989e031527c995e0b47c1bf9ee48d4f7d351e4))

### Bug Fixes

- Permalink and theme ([#3535](https://github.com/juspay/hyperswitch-control-center/pull/3535)) ([`94bbe1b`](https://github.com/juspay/hyperswitch-control-center/commit/94bbe1bbfab9ad167d4ab2ce5ceb8024af38c443))

**Full Changelog:** [`2025.09.09.0...2025.09.09.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.09.0...2025.09.09.1)

- - -

## 2025.09.09.0

### Features

- Customize default theme ([#3505](https://github.com/juspay/hyperswitch-control-center/pull/3505)) ([`d855652`](https://github.com/juspay/hyperswitch-control-center/commit/d855652e5bdf7aa8014b38d3c36deb625aba8ecf))
- Added Extended Authorization toggle in profile settings page ([#3512](https://github.com/juspay/hyperswitch-control-center/pull/3512)) ([`051d50f`](https://github.com/juspay/hyperswitch-control-center/commit/051d50f504006f5b6e857df7162c01aa780b754c))
- Recon engine accounts source page ([#3524](https://github.com/juspay/hyperswitch-control-center/pull/3524)) ([`d03d6b8`](https://github.com/juspay/hyperswitch-control-center/commit/d03d6b852b19343af80e05754399c31a3c78eff9))
- Recon engine accounts source details page ([#3529](https://github.com/juspay/hyperswitch-control-center/pull/3529)) ([`583adb8`](https://github.com/juspay/hyperswitch-control-center/commit/583adb818f66740c0b585fc716e9f4defa08d57a))

### Miscellaneous Tasks

- Refactored overall routing summary table component ([#3515](https://github.com/juspay/hyperswitch-control-center/pull/3515)) ([`0f07885`](https://github.com/juspay/hyperswitch-control-center/commit/0f07885044ae8720093dc4c4817064c54a96fbe9))

**Full Changelog:** [`2025.09.05.0...2025.09.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.05.0...2025.09.09.0)

- - -

## 2025.09.05.0

### Features

- Added network tokenization toggle in profile settings ([#3522](https://github.com/juspay/hyperswitch-control-center/pull/3522)) ([`03f0801`](https://github.com/juspay/hyperswitch-control-center/commit/03f080108826c3ef9a223e6109dc3161aab50397))

### Bug Fixes

- Fixed least cost routing analytics distribution bugs ([#3518](https://github.com/juspay/hyperswitch-control-center/pull/3518)) ([`9193727`](https://github.com/juspay/hyperswitch-control-center/commit/9193727055668d8c9eb35765ab159619c95a0b7f))

**Full Changelog:** [`2025.09.04.0...2025.09.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.04.0...2025.09.05.0)

- - -

## 2025.09.04.0

### Features

- Added summary table for least cost routing analytics ([#3509](https://github.com/juspay/hyperswitch-control-center/pull/3509)) ([`a45145f`](https://github.com/juspay/hyperswitch-control-center/commit/a45145ffe12fc23b4352bcb65149225533ecb7f9))
- Recon engine accounts section folder setup ([#3519](https://github.com/juspay/hyperswitch-control-center/pull/3519)) ([`f2f0adc`](https://github.com/juspay/hyperswitch-control-center/commit/f2f0adc74be507b56debe436fac631a147ebadbe))

### Bug Fixes

- Filter bugs when time range is changed ([#3413](https://github.com/juspay/hyperswitch-control-center/pull/3413)) ([`d4d7d70`](https://github.com/juspay/hyperswitch-control-center/commit/d4d7d70bacd7e38c029855a9c0a886300bef5bd0))

### Miscellaneous Tasks

- Recon engine remove subtitles and arrange the page heading ([#3517](https://github.com/juspay/hyperswitch-control-center/pull/3517)) ([`958194e`](https://github.com/juspay/hyperswitch-control-center/commit/958194e351fa91dd2ccfcc6511365ab046ee0c77))

**Full Changelog:** [`2025.09.03.0...2025.09.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.03.0...2025.09.04.0)

- - -

## 2025.09.03.0

### Features

- Allow user to share permalinks and switch ([#3472](https://github.com/juspay/hyperswitch-control-center/pull/3472)) ([`e92c36d`](https://github.com/juspay/hyperswitch-control-center/commit/e92c36d012f78f8c43c952e6eaa8557cb0027113))
- Added metrics cards for least cost routing analytics ([#3503](https://github.com/juspay/hyperswitch-control-center/pull/3503)) ([`cb8fcde`](https://github.com/juspay/hyperswitch-control-center/commit/cb8fcdef7cb59e6eec735d18c3b94765783573f7))

### Bug Fixes

- Recovery prod default route fix ([#3510](https://github.com/juspay/hyperswitch-control-center/pull/3510)) ([`c7f6ec9`](https://github.com/juspay/hyperswitch-control-center/commit/c7f6ec98feacd1bf00040a1da910edf6738611a8))
- User logout when product switch from recon engine to orchestrator ([#3508](https://github.com/juspay/hyperswitch-control-center/pull/3508)) ([`cce4792`](https://github.com/juspay/hyperswitch-control-center/commit/cce47920abcbd33be264478a9f01bad3b463bf07))

### Miscellaneous Tasks

- Recon engine date format and add account in the entries ([#3500](https://github.com/juspay/hyperswitch-control-center/pull/3500)) ([`f519a29`](https://github.com/juspay/hyperswitch-control-center/commit/f519a294e13d1395635b87387ebfe23446fd4851))

**Full Changelog:** [`2025.09.02.0...2025.09.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.02.0...2025.09.03.0)

- - -

## 2025.09.02.0

### Features

- Added new connector dwolla ([#3495](https://github.com/juspay/hyperswitch-control-center/pull/3495)) ([`2dac878`](https://github.com/juspay/hyperswitch-control-center/commit/2dac8787d02abf8b9afe10fa0955389d9a73a6cc))
- Added distribution graphs in least cost routing analytics ([#3487](https://github.com/juspay/hyperswitch-control-center/pull/3487)) ([`3c80b68`](https://github.com/juspay/hyperswitch-control-center/commit/3c80b689a61708c52d27354dc8cd6f875348d9af))

### Bug Fixes

- Payout details bugfix ([#3504](https://github.com/juspay/hyperswitch-control-center/pull/3504)) ([`cfd0cd1`](https://github.com/juspay/hyperswitch-control-center/commit/cfd0cd14142f01e13737346c6d8e02d89a55a62b))
- Calendar arrow movement changes ([#3493](https://github.com/juspay/hyperswitch-control-center/pull/3493)) ([`3e0c79c`](https://github.com/juspay/hyperswitch-control-center/commit/3e0c79c8d1e4432da387c50fe2ee9f7b008fab75))

### Miscellaneous Tasks

- Updated wasm for dwolla connector ([#3496](https://github.com/juspay/hyperswitch-control-center/pull/3496)) ([`5549cdf`](https://github.com/juspay/hyperswitch-control-center/commit/5549cdf67968786e1ee85b135806569bc1deb0f5))

**Full Changelog:** [`2025.09.01.0...2025.09.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.09.01.0...2025.09.02.0)

- - -

## 2025.09.01.0

### Features

- Recon engine overview summary accounts view ([#3475](https://github.com/juspay/hyperswitch-control-center/pull/3475)) ([`e8b0e09`](https://github.com/juspay/hyperswitch-control-center/commit/e8b0e094487e78b7c836ad541d930d555394612e))

### Bug Fixes

- Remove unnecessary hr for orgsidebar ([#3492](https://github.com/juspay/hyperswitch-control-center/pull/3492)) ([`28c399e`](https://github.com/juspay/hyperswitch-control-center/commit/28c399ee6113cbb3d260de2dc3a33d88d8d71691))

**Full Changelog:** [`2025.08.26.2...2025.09.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.26.2...2025.09.01.0)

- - -

## 2025.08.26.2

### Bug Fixes

- Sample analytics group by bugfix ([#3490](https://github.com/juspay/hyperswitch-control-center/pull/3490)) ([`9e64097`](https://github.com/juspay/hyperswitch-control-center/commit/9e640977e3ceec1d0a2d4d8daf63895854e57f88))

**Full Changelog:** [`2025.08.26.1...2025.08.26.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.26.1...2025.08.26.2)

- - -

## 2025.08.26.1

### Features

- Add recon engine overview volume graphs ([#3471](https://github.com/juspay/hyperswitch-control-center/pull/3471)) ([`3ed252a`](https://github.com/juspay/hyperswitch-control-center/commit/3ed252a50645892c224ddf4c915d4f369b7e43e1))

**Full Changelog:** [`2025.08.26.0...2025.08.26.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.26.0...2025.08.26.1)

- - -

## 2025.08.26.0

### Features

- Add new connector `Affirm` ([#3483](https://github.com/juspay/hyperswitch-control-center/pull/3483)) ([`4120353`](https://github.com/juspay/hyperswitch-control-center/commit/41203539a53b7f3dd31efae9f0af736f18f3f11a))
- Wasm changes for `Affirm` connector ([#3484](https://github.com/juspay/hyperswitch-control-center/pull/3484)) ([`5243c85`](https://github.com/juspay/hyperswitch-control-center/commit/5243c8573d905d3ec3dfb0efb7a821d6a6a5bbe3))
- Roles Information module with parent group info apis ([#3467](https://github.com/juspay/hyperswitch-control-center/pull/3467)) ([`4a93f94`](https://github.com/juspay/hyperswitch-control-center/commit/4a93f94b27f15a28f8683213265ec6e5158111c3))

### Bug Fixes

- Home page product switch ([#3476](https://github.com/juspay/hyperswitch-control-center/pull/3476)) ([`e706702`](https://github.com/juspay/hyperswitch-control-center/commit/e706702a411d76e170a4ed56a2008c700f83e76e))

### Miscellaneous Tasks

- Add `RETURN` as default refund reason for adyen connector ([#3486](https://github.com/juspay/hyperswitch-control-center/pull/3486)) ([`6a069ae`](https://github.com/juspay/hyperswitch-control-center/commit/6a069ae3728859a1b1e42e5c55cbd8e950d0c17b))

**Full Changelog:** [`2025.08.25.0...2025.08.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.25.0...2025.08.26.0)

- - -

## 2025.08.25.0

### Features

- Add blackhawknetwork connector ([#3479](https://github.com/juspay/hyperswitch-control-center/pull/3479)) ([`0040aa5`](https://github.com/juspay/hyperswitch-control-center/commit/0040aa5cc7a1b1de453ce62259ca3022b8edb92f))

### Miscellaneous Tasks

- Remove sync for terminal payment intent status ([#3469](https://github.com/juspay/hyperswitch-control-center/pull/3469)) ([`8077dea`](https://github.com/juspay/hyperswitch-control-center/commit/8077dead936c1a48dc0606eedeb36d6ff6ddce58))

**Full Changelog:** [`2025.08.22.0...2025.08.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.22.0...2025.08.25.0)

- - -

## 2025.08.22.0

### Features

- Add Cost observability in Home page. ([#3438](https://github.com/juspay/hyperswitch-control-center/pull/3438)) ([`6977c44`](https://github.com/juspay/hyperswitch-control-center/commit/6977c44ee391bde3f5a58a023778d13454693c53))
- Add rule wise stacked bar graphs in summary ([#3462](https://github.com/juspay/hyperswitch-control-center/pull/3462)) ([`daa3ac0`](https://github.com/juspay/hyperswitch-control-center/commit/daa3ac0499e5e3c7d3a3df99ebce3c5084936a4b))

### Bug Fixes

- Fix cypress tests ([#3464](https://github.com/juspay/hyperswitch-control-center/pull/3464)) ([`2711db3`](https://github.com/juspay/hyperswitch-control-center/commit/2711db3e5b37f3e07f7885e82e547e6d7feadd9f))

### Refactors

- Omp hook files ([#3465](https://github.com/juspay/hyperswitch-control-center/pull/3465)) ([`dcea80f`](https://github.com/juspay/hyperswitch-control-center/commit/dcea80f863e44038384c577df6f9bf58dc040723))

**Full Changelog:** [`2025.08.21.0...2025.08.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.21.0...2025.08.22.0)

- - -

## 2025.08.21.0

### Features

- Enable refund reason field for `adyen` connector ([#3442](https://github.com/juspay/hyperswitch-control-center/pull/3442)) ([`17ab078`](https://github.com/juspay/hyperswitch-control-center/commit/17ab0783a1b86c2c907af19561b0c14c2eab0082))

### Miscellaneous Tasks

- Routing analytics folder structure change and util functions refactoring ([#3451](https://github.com/juspay/hyperswitch-control-center/pull/3451)) ([`ae4fdbd`](https://github.com/juspay/hyperswitch-control-center/commit/ae4fdbd5e7a6e469b08d34dd5e371fc03ccfb058))
- Add archived tag for discarded transactions and entries in audit trail ([#3456](https://github.com/juspay/hyperswitch-control-center/pull/3456)) ([`c88e08b`](https://github.com/juspay/hyperswitch-control-center/commit/c88e08bb02a5ea1f92f3e030330bdcb218cf3289))

**Full Changelog:** [`2025.08.19.2...2025.08.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.19.2...2025.08.21.0)

- - -

## 2025.08.19.2

### Bug Fixes

- Readme update to remove old theme context ([#3418](https://github.com/juspay/hyperswitch-control-center/pull/3418)) ([`a90127e`](https://github.com/juspay/hyperswitch-control-center/commit/a90127e5f28183a4380d54f0adca72e5413c01a9))
- Recovery onboarding and switch merchant changes ([#3435](https://github.com/juspay/hyperswitch-control-center/pull/3435)) ([`71ec075`](https://github.com/juspay/hyperswitch-control-center/commit/71ec075f678143ce394fca958919630fcc8435ea))

**Full Changelog:** [`2025.08.19.1...2025.08.19.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.19.1...2025.08.19.2)

- - -

## 2025.08.19.1

### Bug Fixes

- Resolve product switch ([#3452](https://github.com/juspay/hyperswitch-control-center/pull/3452)) ([`c5c1d65`](https://github.com/juspay/hyperswitch-control-center/commit/c5c1d65470dbaad74195a9ef5145f15f6dfcb259))

**Full Changelog:** [`2025.08.19.0...2025.08.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.19.0...2025.08.19.1)

- - -

## 2025.08.19.0

### Bug Fixes

- Fix text box size issue for 13 inch screen ([#3447](https://github.com/juspay/hyperswitch-control-center/pull/3447)) ([`7dd07ff`](https://github.com/juspay/hyperswitch-control-center/commit/7dd07ffb47b273452e2c8748a9d70d2015ed875e))
- Payout connector display name ([#3450](https://github.com/juspay/hyperswitch-control-center/pull/3450)) ([`c68405c`](https://github.com/juspay/hyperswitch-control-center/commit/c68405c251ab01b8dfaca75423d162cb3066a591))
- Create merchant not visible in platform org ([#3443](https://github.com/juspay/hyperswitch-control-center/pull/3443)) ([`8edc6b1`](https://github.com/juspay/hyperswitch-control-center/commit/8edc6b11e455ac5286b66dd298a37a1b35fbf9b2))

### Miscellaneous Tasks

- Refactor missing point generation ([#3445](https://github.com/juspay/hyperswitch-control-center/pull/3445)) ([`743e301`](https://github.com/juspay/hyperswitch-control-center/commit/743e30114cd267f8803734118ca29e470cc1b7c7))
- Routing analytics time distribution graph changes ([#3414](https://github.com/juspay/hyperswitch-control-center/pull/3414)) ([`dff67e5`](https://github.com/juspay/hyperswitch-control-center/commit/dff67e5659d4d814df6593e005aa137504860e99))

**Full Changelog:** [`2025.08.14.0...2025.08.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.14.0...2025.08.19.0)

- - -

## 2025.08.14.0

### Features

- Add new connector `CheckBook` ([#3439](https://github.com/juspay/hyperswitch-control-center/pull/3439)) ([`776cb62`](https://github.com/juspay/hyperswitch-control-center/commit/776cb627d225c9b20fef7223e4e58cbf5def4123))

### Refactors

- Url routing ([#3340](https://github.com/juspay/hyperswitch-control-center/pull/3340)) ([`627eea7`](https://github.com/juspay/hyperswitch-control-center/commit/627eea7911cc47ae6b14f4def14056a3771796ef))

### Miscellaneous Tasks

- Rename data assistant to pulse ai and add mixpanel events ([#3440](https://github.com/juspay/hyperswitch-control-center/pull/3440)) ([`054c7d1`](https://github.com/juspay/hyperswitch-control-center/commit/054c7d1b7aa30a06fc1e611a489a01d5495a905f))
- Fix product url ([`c36709f`](https://github.com/juspay/hyperswitch-control-center/commit/c36709f8328daf35635f045175067ef96eb5a9d3))

**Full Changelog:** [`2025.08.13.0...2025.08.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.13.0...2025.08.14.0)

- - -

## 2025.08.13.0

### Features

- Add new connectors `AuthiPay`, `SilverFlow` and `Nordea` ([#3430](https://github.com/juspay/hyperswitch-control-center/pull/3430)) ([`a7ca4dc`](https://github.com/juspay/hyperswitch-control-center/commit/a7ca4dc2cd87974e650607f98f3b25bf266e3ea4))
- Wasm changes for `AuthiPay`, `SilverFlow` and `Nordea` connectors ([#3432](https://github.com/juspay/hyperswitch-control-center/pull/3432)) ([`71ad7aa`](https://github.com/juspay/hyperswitch-control-center/commit/71ad7aa5d18e08e9cb6b0a4e89cb7231866791b3))

### Miscellaneous Tasks

- Folder restructure ([`4602752`](https://github.com/juspay/hyperswitch-control-center/commit/46027524120f12fb7a0bf6d9d0d1c1963ab986cc))

**Full Changelog:** [`2025.08.12.0...2025.08.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.12.0...2025.08.13.0)

- - -

## 2025.08.12.0

### Features

- Add `CancelledPostCapture` status in the payments ([#3425](https://github.com/juspay/hyperswitch-control-center/pull/3425)) ([`59632ff`](https://github.com/juspay/hyperswitch-control-center/commit/59632ffac5f867f01970815c19fd48541c902f05))

**Full Changelog:** [`2025.08.11.0...2025.08.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.11.0...2025.08.12.0)

- - -

## 2025.08.11.0

### Features

- Api keys v2 orchestration ([#3420](https://github.com/juspay/hyperswitch-control-center/pull/3420)) ([`a9ec48e`](https://github.com/juspay/hyperswitch-control-center/commit/a9ec48e594ed5d5432bdfd0eb9aed0e7c9e1f8ed))

### Miscellaneous Tasks

- Api keys support for v2 and for vault ([#3415](https://github.com/juspay/hyperswitch-control-center/pull/3415)) ([`4081e0a`](https://github.com/juspay/hyperswitch-control-center/commit/4081e0a5451eba42c7ba121bf133d9433d69cd08))

**Full Changelog:** [`2025.08.07.1...2025.08.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.07.1...2025.08.11.0)

- - -

## 2025.08.07.1

### Miscellaneous Tasks

- Enable module based feature flag ([#3416](https://github.com/juspay/hyperswitch-control-center/pull/3416)) ([`d1a010b`](https://github.com/juspay/hyperswitch-control-center/commit/d1a010be4516be29ef5e605bfe80970dcc962190))

**Full Changelog:** [`2025.08.07.0...2025.08.07.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.07.0...2025.08.07.1)

- - -

## 2025.08.07.0

### Features

- Recovery prod changes ([#3395](https://github.com/juspay/hyperswitch-control-center/pull/3395)) ([`cecb97b`](https://github.com/juspay/hyperswitch-control-center/commit/cecb97ba9f2e4be6d9b84925685ecd23796db081))

### Bug Fixes

- Add email enabled check for magic link during sign up ([#3409](https://github.com/juspay/hyperswitch-control-center/pull/3409)) ([`ea18609`](https://github.com/juspay/hyperswitch-control-center/commit/ea18609e8ea46a5c0a48db91e3f4f56225d1b181))

### Miscellaneous Tasks

- Platform docs url update ([#3411](https://github.com/juspay/hyperswitch-control-center/pull/3411)) ([`3605cff`](https://github.com/juspay/hyperswitch-control-center/commit/3605cff83337710fdb3e0e4c652f83d2e7b47201))

**Full Changelog:** [`2025.08.06.0...2025.08.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.06.0...2025.08.07.0)

- - -

## 2025.08.06.0

### Features

- Added new connector bluecode ([#3398](https://github.com/juspay/hyperswitch-control-center/pull/3398)) ([`b8751b4`](https://github.com/juspay/hyperswitch-control-center/commit/b8751b4b09cba2079ef5b9df0fcfdcce05707657))
- Support payload connector ([#3403](https://github.com/juspay/hyperswitch-control-center/pull/3403)) ([`7dd76b6`](https://github.com/juspay/hyperswitch-control-center/commit/7dd76b6dccf43726cc414e8977190e40109abb65))
- Payouts detail page ([#3402](https://github.com/juspay/hyperswitch-control-center/pull/3402)) ([`d5bd661`](https://github.com/juspay/hyperswitch-control-center/commit/d5bd6616f50b8b3dbaec416872f9ef475b3cd87c))

### Miscellaneous Tasks

- Updated wasm for bluecode connector ([#3399](https://github.com/juspay/hyperswitch-control-center/pull/3399)) ([`05482bd`](https://github.com/juspay/hyperswitch-control-center/commit/05482bd809911f3ad572b98393e87588b5182718))
- Explore recipes mixpanel event addition ([#3406](https://github.com/juspay/hyperswitch-control-center/pull/3406)) ([`9e47476`](https://github.com/juspay/hyperswitch-control-center/commit/9e47476d99cf0764c53c06c0a89fbdb93123269d))

**Full Changelog:** [`2025.08.05.0...2025.08.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.05.0...2025.08.06.0)

- - -

## 2025.08.05.0

### Features

- Payment interface modifications for v1 and v2 ([#3367](https://github.com/juspay/hyperswitch-control-center/pull/3367)) ([`04c9322`](https://github.com/juspay/hyperswitch-control-center/commit/04c9322a96285e34ab29d7464251656137a422bc))

### Bug Fixes

- Fixed routing analytics bugs ([#3393](https://github.com/juspay/hyperswitch-control-center/pull/3393)) ([`a2664fc`](https://github.com/juspay/hyperswitch-control-center/commit/a2664fc00ba30c66e90eff34ddf694715e50af8a))

**Full Changelog:** [`2025.08.04.0...2025.08.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.04.0...2025.08.05.0)

- - -

## 2025.08.04.0

### Features

- New connector addition Paytm and Phonepe ([#3352](https://github.com/juspay/hyperswitch-control-center/pull/3352)) ([`7df7198`](https://github.com/juspay/hyperswitch-control-center/commit/7df7198d3cd3651d9f6566655ee26b19d8620612))
- Added new connectors fexiti and breadpay ([#3387](https://github.com/juspay/hyperswitch-control-center/pull/3387)) ([`241b468`](https://github.com/juspay/hyperswitch-control-center/commit/241b46831346ca4ecaafce24316f868e641a0ed3))

### Bug Fixes

- Signup coming up even when in auth methods its disabled ([#3385](https://github.com/juspay/hyperswitch-control-center/pull/3385)) ([`bbb6f33`](https://github.com/juspay/hyperswitch-control-center/commit/bbb6f33710cb4e9824ed258d1f5d5db25ba319dd))

### Miscellaneous Tasks

- Updated wasm for connectors flexiti and breadpay ([#3388](https://github.com/juspay/hyperswitch-control-center/pull/3388)) ([`ea0b4c1`](https://github.com/juspay/hyperswitch-control-center/commit/ea0b4c15230ac8f11cfb0890ed025cd03ccac0e5))

**Full Changelog:** [`2025.08.01.0...2025.08.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.08.01.0...2025.08.04.0)

- - -

## 2025.08.01.0

### Bug Fixes

- Recon overview txn filters bug ([#3376](https://github.com/juspay/hyperswitch-control-center/pull/3376)) ([`de93c3a`](https://github.com/juspay/hyperswitch-control-center/commit/de93c3a0cbea8bbeb5fccace5071069d757ef16e))

### Miscellaneous Tasks

- Removed merchantCountryCode field ([#3345](https://github.com/juspay/hyperswitch-control-center/pull/3345)) ([`bffb23b`](https://github.com/juspay/hyperswitch-control-center/commit/bffb23b8886c11d0fa3011748ee5e6efc2f84783))

**Full Changelog:** [`2025.07.31.0...2025.08.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.31.0...2025.08.01.0)

- - -

## 2025.07.31.0

### Features

- Routing Analytics Trends Distribution Graph ([#3361](https://github.com/juspay/hyperswitch-control-center/pull/3361)) ([`ca62626`](https://github.com/juspay/hyperswitch-control-center/commit/ca62626f503ca20da28d64c657529686bc54cca3))
- Add metrics in routing analytics ([#3369](https://github.com/juspay/hyperswitch-control-center/pull/3369)) ([`73b8658`](https://github.com/juspay/hyperswitch-control-center/commit/73b8658607e78600edebfb56c8a8ab686513a335))
- Added Routing analytics summary table component ([#3360](https://github.com/juspay/hyperswitch-control-center/pull/3360)) ([`70b7eea`](https://github.com/juspay/hyperswitch-control-center/commit/70b7eea93bd2525e0df14fd345dd705e3b17cf55))

### Bug Fixes

- Standardize amount format in recon engine ([#3363](https://github.com/juspay/hyperswitch-control-center/pull/3363)) ([`6c56318`](https://github.com/juspay/hyperswitch-control-center/commit/6c563188c88159ffcf65ca491515a911406bdba2))

### Refactors

- Chatbot button changes ([#3374](https://github.com/juspay/hyperswitch-control-center/pull/3374)) ([`c5fee2b`](https://github.com/juspay/hyperswitch-control-center/commit/c5fee2bb8045a98aa888edd7e6bf20ba7c32d7a8))

### Miscellaneous Tasks

- Renaming source and target names and setoffset ([#3371](https://github.com/juspay/hyperswitch-control-center/pull/3371)) ([`c0714d8`](https://github.com/juspay/hyperswitch-control-center/commit/c0714d80e1c2d40a09dd9227f3ce4e4e3b91daa1))

**Full Changelog:** [`2025.07.30.0...2025.07.31.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.30.0...2025.07.31.0)

- - -

## 2025.07.30.0

### Bug Fixes

- Org retrieve api requires organization manage permission to call ([#3366](https://github.com/juspay/hyperswitch-control-center/pull/3366)) ([`34db52e`](https://github.com/juspay/hyperswitch-control-center/commit/34db52e0b22887721ac304e87caf144377781747))

**Full Changelog:** [`2025.07.29.1...2025.07.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.29.1...2025.07.30.0)

- - -

## 2025.07.29.1

### Features

- Chat bot ui changes ([#3324](https://github.com/juspay/hyperswitch-control-center/pull/3324)) ([`5f23e3b`](https://github.com/juspay/hyperswitch-control-center/commit/5f23e3bac218c977666b0f46263cb56ed383b51d))
- Add filters in routing analytics ([#3358](https://github.com/juspay/hyperswitch-control-center/pull/3358)) ([`795c960`](https://github.com/juspay/hyperswitch-control-center/commit/795c960eef545dfe311a9aa03026ec531ce6a881))

**Full Changelog:** [`2025.07.29.0...2025.07.29.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.29.0...2025.07.29.1)

- - -

## 2025.07.29.0

### Features

- Payment operations list v2 ([#3354](https://github.com/juspay/hyperswitch-control-center/pull/3354)) ([`8b17189`](https://github.com/juspay/hyperswitch-control-center/commit/8b17189ee7b17e20b60ee699e8b03607db20a88c))

### Miscellaneous Tasks

- Webpack-common changes and asset movement ([#3341](https://github.com/juspay/hyperswitch-control-center/pull/3341)) ([`11409fc`](https://github.com/juspay/hyperswitch-control-center/commit/11409fcd40e6bd8940ae607a605c3af27e5f947b))

**Full Changelog:** [`2025.07.28.0...2025.07.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.28.0...2025.07.29.0)

- - -

## 2025.07.28.0

### Features

- Recon V1 credit debit filters ([#3335](https://github.com/juspay/hyperswitch-control-center/pull/3335)) ([`eb854fc`](https://github.com/juspay/hyperswitch-control-center/commit/eb854fc2f7098e9765fdb26f9d6dd150c48b3fdf))
- Recon engine file management screens ([#3343](https://github.com/juspay/hyperswitch-control-center/pull/3343)) ([`b4ff02b`](https://github.com/juspay/hyperswitch-control-center/commit/b4ff02bf0ca3cfe7c6a71e549472437cdc6dfd85))
- Recon engine connections screen ([#3330](https://github.com/juspay/hyperswitch-control-center/pull/3330)) ([`44b290b`](https://github.com/juspay/hyperswitch-control-center/commit/44b290b0da903f3d2ed21ccfd568aadf34266db2))

### Bug Fixes

- Recon V1 suggested ui changes ([#3332](https://github.com/juspay/hyperswitch-control-center/pull/3332)) ([`07a4f71`](https://github.com/juspay/hyperswitch-control-center/commit/07a4f711f25a5465d3c858023a3b464e1ac74fa0))
- Recon bugs ([#3348](https://github.com/juspay/hyperswitch-control-center/pull/3348)) ([`e23be39`](https://github.com/juspay/hyperswitch-control-center/commit/e23be393a24454119ca2e4c2e5ca80ddfd7dfdbc))

### Refactors

- Remove orgchart feature flag ([#3325](https://github.com/juspay/hyperswitch-control-center/pull/3325)) ([`592afb3`](https://github.com/juspay/hyperswitch-control-center/commit/592afb378e6e574895769be19342c67c658e3a19))

### Miscellaneous Tasks

- Payment interface types for v1 and v2 ([#3258](https://github.com/juspay/hyperswitch-control-center/pull/3258)) ([`96ffcac`](https://github.com/juspay/hyperswitch-control-center/commit/96ffcacaec23daa904b6774b537a750e66145701))
- Refactoring done for v2 moved api call to orders hook ([#3349](https://github.com/juspay/hyperswitch-control-center/pull/3349)) ([`cfb0611`](https://github.com/juspay/hyperswitch-control-center/commit/cfb06117a665029dd292c95c89e008449dc0a644))

**Full Changelog:** [`2025.07.25.0...2025.07.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.25.0...2025.07.28.0)

- - -

## 2025.07.25.0

### Features

- Vsaas ui changes ([#3255](https://github.com/juspay/hyperswitch-control-center/pull/3255)) ([`5a02551`](https://github.com/juspay/hyperswitch-control-center/commit/5a02551a4d418636f435886cd44231370e968ca6))

### Bug Fixes

- Added routing analytics distribution charts ([#3336](https://github.com/juspay/hyperswitch-control-center/pull/3336)) ([`48a8e06`](https://github.com/juspay/hyperswitch-control-center/commit/48a8e069e448bf0251d94ee370036396d25f192f))

**Full Changelog:** [`2025.07.24.1...2025.07.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.24.1...2025.07.25.0)

- - -

## 2025.07.24.1

### Features

- Right drawer for product exploration ([#3169](https://github.com/juspay/hyperswitch-control-center/pull/3169)) ([`f0ea731`](https://github.com/juspay/hyperswitch-control-center/commit/f0ea731cc22b7aa2b00ade28ea91c3354ceb6abd))

**Full Changelog:** [`2025.07.24.0...2025.07.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.24.0...2025.07.24.1)

- - -

## 2025.07.24.0

### Bug Fixes

- Disabled draggable columns when columns are searched in loaded table with custom columns ([#3320](https://github.com/juspay/hyperswitch-control-center/pull/3320)) ([`a7138ca`](https://github.com/juspay/hyperswitch-control-center/commit/a7138ca31878d348d2b211a3456a69d15d578e6b))

### Miscellaneous Tasks

- Common entity for connector list loaded table ([#3329](https://github.com/juspay/hyperswitch-control-center/pull/3329)) ([`0e438e6`](https://github.com/juspay/hyperswitch-control-center/commit/0e438e632ff81ff36fb844a7fb27d67522c2ead8))

**Full Changelog:** [`2025.07.23.0...2025.07.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.23.0...2025.07.24.0)

- - -

## 2025.07.23.0

### Bug Fixes

- Recon v2 show get production access ([#3322](https://github.com/juspay/hyperswitch-control-center/pull/3322)) ([`27aa5eb`](https://github.com/juspay/hyperswitch-control-center/commit/27aa5eb8a883a3778d3784d1dbdbc11a8e4a02a4))

### Miscellaneous Tasks

- Already configured frm cannot be configured again ([#3317](https://github.com/juspay/hyperswitch-control-center/pull/3317)) ([`3a4233e`](https://github.com/juspay/hyperswitch-control-center/commit/3a4233ec07cc73805728dafd16adaa9f0a5c5b55))
- Connector interface type changes ([#3277](https://github.com/juspay/hyperswitch-control-center/pull/3277)) ([`962515c`](https://github.com/juspay/hyperswitch-control-center/commit/962515c5a1c867dec64671c8f6c9d60d821c2bb8))

**Full Changelog:** [`2025.07.22.0...2025.07.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.22.0...2025.07.23.0)

- - -

## 2025.07.22.0

### Miscellaneous Tasks

- Recovery invoices page changes ([#3319](https://github.com/juspay/hyperswitch-control-center/pull/3319)) ([`09fd5a8`](https://github.com/juspay/hyperswitch-control-center/commit/09fd5a89e77495a62857d48cb5dc24695eea299c))

**Full Changelog:** [`2025.07.21.0...2025.07.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.21.0...2025.07.22.0)

- - -

## 2025.07.21.0

### Features

- Recon file upload changes ([#3314](https://github.com/juspay/hyperswitch-control-center/pull/3314)) ([`e1c7344`](https://github.com/juspay/hyperswitch-control-center/commit/e1c734417c202112a12f646ebd14701b7e7a782c))
- Blacklist Whitelist merchant config changes ([#3313](https://github.com/juspay/hyperswitch-control-center/pull/3313)) ([`e396984`](https://github.com/juspay/hyperswitch-control-center/commit/e3969847491b55c1fcf17d8623889f695b6efc13))
- Recon engine overview page ([#3303](https://github.com/juspay/hyperswitch-control-center/pull/3303)) ([`41063c3`](https://github.com/juspay/hyperswitch-control-center/commit/41063c399cde2bb29e819bfadb70b9ba9186f612))

**Full Changelog:** [`2025.07.18.0...2025.07.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.18.0...2025.07.21.0)

- - -

## 2025.07.18.0

### Features

- Recon rules API integration ([#3310](https://github.com/juspay/hyperswitch-control-center/pull/3310)) ([`7ef8f34`](https://github.com/juspay/hyperswitch-control-center/commit/7ef8f34397e54843163ed7630b6c37e93ae34a31))
- Recon V1 filters and transaction API integration ([#3306](https://github.com/juspay/hyperswitch-control-center/pull/3306)) ([`d92b44f`](https://github.com/juspay/hyperswitch-control-center/commit/d92b44f7a46a1a318132441f4b8332b91e7aa8ab))

**Full Changelog:** [`2025.07.17.1...2025.07.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.17.1...2025.07.18.0)

- - -

## 2025.07.17.1

### Features

- Recon rules detail page ([#3302](https://github.com/juspay/hyperswitch-control-center/pull/3302)) ([`2f26ba6`](https://github.com/juspay/hyperswitch-control-center/commit/2f26ba6c95340b87ed5835c4116523990b5b3ac9))
- Integrate chat bot ([#3301](https://github.com/juspay/hyperswitch-control-center/pull/3301)) ([`63968e0`](https://github.com/juspay/hyperswitch-control-center/commit/63968e0bd32cf8fca46058f0e6ec766bc4a815e6))

**Full Changelog:** [`2025.07.17.0...2025.07.17.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.17.0...2025.07.17.1)

- - -

## 2025.07.17.0

### Features

- Added functionality to change the order of columns in loaded table with custom columns ([#3251](https://github.com/juspay/hyperswitch-control-center/pull/3251)) ([`8088fc5`](https://github.com/juspay/hyperswitch-control-center/commit/8088fc5f6234b3e10fa4035b70af7dce3d8941c1))
- Hyperswitch recon engine v1 API types ([#3307](https://github.com/juspay/hyperswitch-control-center/pull/3307)) ([`7837988`](https://github.com/juspay/hyperswitch-control-center/commit/7837988cb50c49a0cce2d1937ea3567ab7898169))

### Bug Fixes

- Sidebar hidden fix ([#3300](https://github.com/juspay/hyperswitch-control-center/pull/3300)) ([`38e5ab1`](https://github.com/juspay/hyperswitch-control-center/commit/38e5ab1c7a1aa700116e377a6d4f3b568ba9e86a))

**Full Changelog:** [`2025.07.16.0...2025.07.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.16.0...2025.07.17.0)

- - -

## 2025.07.16.0

### Features

- Added new connector payload ([#3290](https://github.com/juspay/hyperswitch-control-center/pull/3290)) ([`365309f`](https://github.com/juspay/hyperswitch-control-center/commit/365309ff5620a3a40bdb59d81b64f91c557a72f6))
- Recon v1 Exceptions module ([#3285](https://github.com/juspay/hyperswitch-control-center/pull/3285)) ([`2ff4c8c`](https://github.com/juspay/hyperswitch-control-center/commit/2ff4c8c5d1dccfed2ea0d231cb0b670cc8c4cc36))

### Bug Fixes

- Audit logs order and log details mismatch fix ([#3289](https://github.com/juspay/hyperswitch-control-center/pull/3289)) ([`0dc4eb2`](https://github.com/juspay/hyperswitch-control-center/commit/0dc4eb2ec66497cfa21088d0b160ffb1add2816f))
- Addition of recon v1 in switches ([#3287](https://github.com/juspay/hyperswitch-control-center/pull/3287)) ([`3f8b3f5`](https://github.com/juspay/hyperswitch-control-center/commit/3f8b3f52f925743b39d5e33891756cae793f5081))

### Refactors

- Remove unused code ([#3282](https://github.com/juspay/hyperswitch-control-center/pull/3282)) ([`82335ac`](https://github.com/juspay/hyperswitch-control-center/commit/82335acf600df75a6f3f0f31593b7647ac7de7d3))

### Miscellaneous Tasks

- Dummy connector popup modal in v2 ([#3279](https://github.com/juspay/hyperswitch-control-center/pull/3279)) ([`f6e597e`](https://github.com/juspay/hyperswitch-control-center/commit/f6e597e62925029c817a7729f20d8fe6b8379a8a))
- Wasm update for payload connector ([#3291](https://github.com/juspay/hyperswitch-control-center/pull/3291)) ([`0059b9e`](https://github.com/juspay/hyperswitch-control-center/commit/0059b9ef309b5810f06151f25447732e8ae85521))
- Routing analytics general and distribution component folder and file structure ([#3276](https://github.com/juspay/hyperswitch-control-center/pull/3276)) ([`ce23b55`](https://github.com/juspay/hyperswitch-control-center/commit/ce23b55131eb719852f5242555d55e39d677b3a0))

**Full Changelog:** [`2025.07.15.0...2025.07.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.15.0...2025.07.16.0)

- - -

## 2025.07.15.0

### Features

- Added disable button to setup future and auth type fields in sdk ([#3206](https://github.com/juspay/hyperswitch-control-center/pull/3206)) ([`d51c88e`](https://github.com/juspay/hyperswitch-control-center/commit/d51c88ecfb946df44d5a4fae1a4afcc03bb9aa40))
- Recon engine transaction audit trail ([#3275](https://github.com/juspay/hyperswitch-control-center/pull/3275)) ([`3ca0959`](https://github.com/juspay/hyperswitch-control-center/commit/3ca09595c262e2cff2fdba46e75197754391d6c3))
- Recon v1 rules Library ([#3283](https://github.com/juspay/hyperswitch-control-center/pull/3283)) ([`6bc7c35`](https://github.com/juspay/hyperswitch-control-center/commit/6bc7c35b742d220dec61ce1d8fadd0e604339e99))

**Full Changelog:** [`2025.07.14.0...2025.07.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.14.0...2025.07.15.0)

- - -

## 2025.07.14.0

### Features

- Recon v1 upload ([#3271](https://github.com/juspay/hyperswitch-control-center/pull/3271)) ([`242ef8e`](https://github.com/juspay/hyperswitch-control-center/commit/242ef8e40e0263878c9fd36373dd0749853f2cae))
- Recon v1 overview and account module ([#3267](https://github.com/juspay/hyperswitch-control-center/pull/3267)) ([`4883472`](https://github.com/juspay/hyperswitch-control-center/commit/4883472e9719ec25fe28b115f75bba5413cd0e61))
- Recon engine transactions page ([#3266](https://github.com/juspay/hyperswitch-control-center/pull/3266)) ([`667b11b`](https://github.com/juspay/hyperswitch-control-center/commit/667b11b8dc633151fbace48d8fe738d47ae8267a))

### Testing

- Add cypress tests ([#3250](https://github.com/juspay/hyperswitch-control-center/pull/3250)) ([`30ee68b`](https://github.com/juspay/hyperswitch-control-center/commit/30ee68bab7b522a0cdd62a56feacbcc769fc6500))

### Miscellaneous Tasks

- Add entity-specific routes for authentication analytics v2 ([#3270](https://github.com/juspay/hyperswitch-control-center/pull/3270)) ([`9e2967a`](https://github.com/juspay/hyperswitch-control-center/commit/9e2967ae46190c1660d2332abc9a22252ccd372c))

**Full Changelog:** [`2025.07.10.0...2025.07.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.10.0...2025.07.14.0)

- - -

## 2025.07.10.0

### Features

- Recon(V1) product setup ([#3262](https://github.com/juspay/hyperswitch-control-center/pull/3262)) ([`72ceac7`](https://github.com/juspay/hyperswitch-control-center/commit/72ceac7b2a2ed0ec4e2e62810b38a963e5407b47))

**Full Changelog:** [`2025.07.09.0...2025.07.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.09.0...2025.07.10.0)

- - -

## 2025.07.09.0

### Features

- Orchestrator v2 connectors configuration steps ([#3232](https://github.com/juspay/hyperswitch-control-center/pull/3232)) ([`c11c6d5`](https://github.com/juspay/hyperswitch-control-center/commit/c11c6d53ffa2e38dcc23f432f9442849679148a3))

**Full Changelog:** [`2025.07.08.0...2025.07.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.08.0...2025.07.09.0)

- - -

## 2025.07.08.0

### Bug Fixes

- Prod access form not visible ([#3252](https://github.com/juspay/hyperswitch-control-center/pull/3252)) ([`9471bca`](https://github.com/juspay/hyperswitch-control-center/commit/9471bca999add0e10cad61e1303e6402a7cac0e4))
- Merchant name product prefix fix ([#3256](https://github.com/juspay/hyperswitch-control-center/pull/3256)) ([`2cc5829`](https://github.com/juspay/hyperswitch-control-center/commit/2cc5829cc4b61fbdef453d90378db8cce58ecdd6))

**Full Changelog:** [`2025.07.03.0...2025.07.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.03.0...2025.07.08.0)

- - -

## 2025.07.03.0

### Features

- Orchestrator v2 connected connectors table ([#3229](https://github.com/juspay/hyperswitch-control-center/pull/3229)) ([`7ddbf2c`](https://github.com/juspay/hyperswitch-control-center/commit/7ddbf2c5456dc0c34a2db4c72aa9717f2670b0e7))

### Bug Fixes

- Improvement and bug fixes ([#3239](https://github.com/juspay/hyperswitch-control-center/pull/3239)) ([`43445f2`](https://github.com/juspay/hyperswitch-control-center/commit/43445f24cd37a261d1695f529e564b646927184c))

### Miscellaneous Tasks

- Display prefilled merchant name in create merchant modal ([#3249](https://github.com/juspay/hyperswitch-control-center/pull/3249)) ([`58d2150`](https://github.com/juspay/hyperswitch-control-center/commit/58d2150e92d1db738945e8b11ac1488a6b3a6791))

**Full Changelog:** [`2025.07.02.0...2025.07.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.02.0...2025.07.03.0)

- - -

## 2025.07.02.0

### Bug Fixes

- Webhooks retry mixpanel event added ([#3241](https://github.com/juspay/hyperswitch-control-center/pull/3241)) ([`50453d5`](https://github.com/juspay/hyperswitch-control-center/commit/50453d50605838de319d435d06a498bc574146e3))

### Miscellaneous Tasks

- Added custom metadata headers tab in revamped payment settings ([#3235](https://github.com/juspay/hyperswitch-control-center/pull/3235)) ([`90f1e6b`](https://github.com/juspay/hyperswitch-control-center/commit/90f1e6b056b0d680cfcd03f6ac210ce32faa3b53))
- Product type matching bugfix ([#3236](https://github.com/juspay/hyperswitch-control-center/pull/3236)) ([`a0773a0`](https://github.com/juspay/hyperswitch-control-center/commit/a0773a026c9b18be40101f479afc6272797bc28d))

**Full Changelog:** [`2025.07.01.0...2025.07.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.07.01.0...2025.07.02.0)

- - -

## 2025.07.01.0

### Features

- Orchestrator v2 connectors list screen ([#3227](https://github.com/juspay/hyperswitch-control-center/pull/3227)) ([`f843512`](https://github.com/juspay/hyperswitch-control-center/commit/f843512c89c6bf5eae193a7ca3656c8d157cca64))

### Bug Fixes

- Make filter menu scrollable and fix filter type issues ([#3218](https://github.com/juspay/hyperswitch-control-center/pull/3218)) ([`b000101`](https://github.com/juspay/hyperswitch-control-center/commit/b0001017f71d8af77357c6c4bc586e9da141b000))

### Miscellaneous Tasks

- Added custom webhook headers tab in revamped payment settings ([#3210](https://github.com/juspay/hyperswitch-control-center/pull/3210)) ([`074a9ab`](https://github.com/juspay/hyperswitch-control-center/commit/074a9abb9af9b9ffb2aa73420bbd97a9226c94dd))
- Orchestration v2 connectors static changes ([#3224](https://github.com/juspay/hyperswitch-control-center/pull/3224)) ([`6edc146`](https://github.com/juspay/hyperswitch-control-center/commit/6edc1460c141d641ea5975564d1c1ede0d7a224d))
- Updated dynamo wasm ([#3222](https://github.com/juspay/hyperswitch-control-center/pull/3222)) ([`9c116ee`](https://github.com/juspay/hyperswitch-control-center/commit/9c116ee820290c992813fa3375d4e633db65bba2))

**Full Changelog:** [`2025.06.26.0...2025.07.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.26.0...2025.07.01.0)

- - -

## 2025.06.26.0

### Miscellaneous Tasks

- Orchestration v2 folder structure ([#3183](https://github.com/juspay/hyperswitch-control-center/pull/3183)) ([`94df672`](https://github.com/juspay/hyperswitch-control-center/commit/94df672f3924887e7af5f4ac5090132d4c65d156))
- Changes merchant category code dropdown name ([#3216](https://github.com/juspay/hyperswitch-control-center/pull/3216)) ([`41c95ce`](https://github.com/juspay/hyperswitch-control-center/commit/41c95ce5a2c1f67e31f8ab61ed552657f394e5be))

**Full Changelog:** [`2025.06.24.1...2025.06.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.24.1...2025.06.26.0)

- - -

## 2025.06.24.1

### Bug Fixes

- Webhook responsiveness fix ([#3204](https://github.com/juspay/hyperswitch-control-center/pull/3204)) ([`63086a1`](https://github.com/juspay/hyperswitch-control-center/commit/63086a134f2a479b8a0eabaaacd9590de0c91531))
- Fixed dropdown width and disabled deselect in merchant category … ([#3212](https://github.com/juspay/hyperswitch-control-center/pull/3212)) ([`9d6a0db`](https://github.com/juspay/hyperswitch-control-center/commit/9d6a0db8cd9162cb3b5809f89977d7cdaf459b15))

**Full Changelog:** [`2025.06.24.0...2025.06.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.24.0...2025.06.24.1)

- - -

## 2025.06.24.0

### Features

- Added merchant category code dropdown in payment settings page ([#3175](https://github.com/juspay/hyperswitch-control-center/pull/3175)) ([`ecf3f9a`](https://github.com/juspay/hyperswitch-control-center/commit/ecf3f9affa6fc8186baf1750408ea3a4c28bfeb7))

**Full Changelog:** [`2025.06.23.1...2025.06.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.23.1...2025.06.24.0)

- - -

## 2025.06.23.1

### Miscellaneous Tasks

- Payment settings threeds tab component ([#3188](https://github.com/juspay/hyperswitch-control-center/pull/3188)) ([`a533761`](https://github.com/juspay/hyperswitch-control-center/commit/a533761ccd84a6f772e32fbd4f4b52ad8bcc9f20))
- Recovery demo items changes ([#3200](https://github.com/juspay/hyperswitch-control-center/pull/3200)) ([`b9c48a9`](https://github.com/juspay/hyperswitch-control-center/commit/b9c48a981cea36808af4985016332433f7b229fb))

**Full Changelog:** [`2025.06.23.0...2025.06.23.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.23.0...2025.06.23.1)

- - -

## 2025.06.23.0

### Bug Fixes

- Theme colors for sidebar ompchart and border fix ([#3197](https://github.com/juspay/hyperswitch-control-center/pull/3197)) ([`b113ce3`](https://github.com/juspay/hyperswitch-control-center/commit/b113ce3fcd5334da0ea315c8c7702f1dce7aa029))

**Full Changelog:** [`2025.06.19.1...2025.06.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.19.1...2025.06.23.0)

- - -

## 2025.06.19.1

### Features

- Addition of new connectors for recovery on onboarding display ([#3191](https://github.com/juspay/hyperswitch-control-center/pull/3191)) ([`f252a1a`](https://github.com/juspay/hyperswitch-control-center/commit/f252a1ac53ca21af3ad3b4580c198eee5a5e3cfe))
- 3ds-exemption-rules ([#3190](https://github.com/juspay/hyperswitch-control-center/pull/3190)) ([`20b0fcb`](https://github.com/juspay/hyperswitch-control-center/commit/20b0fcb1320787ee34e227e71ab381ac5215f986))

### Bug Fixes

- Acquirer config bug fixes ([#3185](https://github.com/juspay/hyperswitch-control-center/pull/3185)) ([`ae2bad1`](https://github.com/juspay/hyperswitch-control-center/commit/ae2bad1ebc5f7a4f7ea0e21d5061f07b03d658c6))

### Refactors

- Refactored UI using tabs and individual authentication connector graphs ([#3193](https://github.com/juspay/hyperswitch-control-center/pull/3193)) ([`6d6b6f9`](https://github.com/juspay/hyperswitch-control-center/commit/6d6b6f99b3e101d56a3dca68424f962a2e6461ce))

**Full Changelog:** [`2025.06.19.0...2025.06.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.19.0...2025.06.19.1)

- - -

## 2025.06.19.0

### Features

- Addition of new connector tokenio ([#3176](https://github.com/juspay/hyperswitch-control-center/pull/3176)) ([`89e4b42`](https://github.com/juspay/hyperswitch-control-center/commit/89e4b4254bdd1c727e46aad21fa208af9dfd0471))

### Miscellaneous Tasks

- OMP Hierarchy ([#3001](https://github.com/juspay/hyperswitch-control-center/pull/3001)) ([`974eae5`](https://github.com/juspay/hyperswitch-control-center/commit/974eae5dc6a0bf21e8752b42f0d685bb4cb33b79))
- Recovery graphs minor ui tweaks ([#3181](https://github.com/juspay/hyperswitch-control-center/pull/3181)) ([`706120c`](https://github.com/juspay/hyperswitch-control-center/commit/706120cc835c48306b9b51c560e24cc9cc7b3813))

**Full Changelog:** [`2025.06.18.0...2025.06.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.18.0...2025.06.19.0)

- - -

## 2025.06.18.0

### Features

- Addition of new connector barclaycard ([#3177](https://github.com/juspay/hyperswitch-control-center/pull/3177)) ([`eb92457`](https://github.com/juspay/hyperswitch-control-center/commit/eb92457869dea18a6f91ce2822fb0e483770daa4))

### Bug Fixes

- Merchant update name validation ([#3168](https://github.com/juspay/hyperswitch-control-center/pull/3168)) ([`479417a`](https://github.com/juspay/hyperswitch-control-center/commit/479417a41cb55d9f367ebed4748e884edbe39135))
- Debit routing present in Payout routing ([#3165](https://github.com/juspay/hyperswitch-control-center/pull/3165)) ([`4d89518`](https://github.com/juspay/hyperswitch-control-center/commit/4d8951805a2d44773e7bf327256d1177d9effe9b))

### Miscellaneous Tasks

- Wasm update for barclaycard and tokenio ([#3178](https://github.com/juspay/hyperswitch-control-center/pull/3178)) ([`57b7f1f`](https://github.com/juspay/hyperswitch-control-center/commit/57b7f1f50ffdade2491cdca558e6cc3458b0461a))
- Payment Settings payment behaviour tab component ([#3152](https://github.com/juspay/hyperswitch-control-center/pull/3152)) ([`a5d8592`](https://github.com/juspay/hyperswitch-control-center/commit/a5d859247bcee6e46a042dd359bd0fce4cfb2c2d))

**Full Changelog:** [`2025.06.16.0...2025.06.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.16.0...2025.06.18.0)

- - -

## 2025.06.16.0

### Bug Fixes

- Validation of not allowing same merchant name in same organisation ([#3103](https://github.com/juspay/hyperswitch-control-center/pull/3103)) ([`7cf354c`](https://github.com/juspay/hyperswitch-control-center/commit/7cf354c5956028b1f04fca501eeec714599624ef))
- Screen sizes calender filter positioning ([#3155](https://github.com/juspay/hyperswitch-control-center/pull/3155)) ([`3122aec`](https://github.com/juspay/hyperswitch-control-center/commit/3122aec76cd9f445b1ec6095ccc1437304f7dc4d))

### Miscellaneous Tasks

- Not Found for 3ds secure io ([#3166](https://github.com/juspay/hyperswitch-control-center/pull/3166)) ([`90444bd`](https://github.com/juspay/hyperswitch-control-center/commit/90444bda9dce54acf8140198d342051b2ea28a23))
- Removed unused payment settings list and business profile pages ([#3171](https://github.com/juspay/hyperswitch-control-center/pull/3171)) ([`c1ac401`](https://github.com/juspay/hyperswitch-control-center/commit/c1ac4010aab9ddab7e6b88424046f35b01040a72))

**Full Changelog:** [`2025.06.13.0...2025.06.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.13.0...2025.06.16.0)

- - -

## 2025.06.13.0

### Features

- Acquirer config settings ([#3084](https://github.com/juspay/hyperswitch-control-center/pull/3084)) ([`0429084`](https://github.com/juspay/hyperswitch-control-center/commit/042908479669e5810de9f3c322e236f2ff5f8725))

### Bug Fixes

- Correct 3DS sankey data calculation and ui ([#3156](https://github.com/juspay/hyperswitch-control-center/pull/3156)) ([`03c46ea`](https://github.com/juspay/hyperswitch-control-center/commit/03c46eaa7f5a237bdf9bfeb34bf2568e46e002d3))

### Testing

- Add support for sso tests ([#3134](https://github.com/juspay/hyperswitch-control-center/pull/3134)) ([`172609b`](https://github.com/juspay/hyperswitch-control-center/commit/172609b07bcbf4a83939fc8a669e32945375aa32))

### Miscellaneous Tasks

- Payment settings page revamp main page ([#3132](https://github.com/juspay/hyperswitch-control-center/pull/3132)) ([`46b94ed`](https://github.com/juspay/hyperswitch-control-center/commit/46b94ed42e373d4bb7649a21f8d0bab3237a1fe0))

**Full Changelog:** [`2025.06.11.2...2025.06.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.11.2...2025.06.13.0)

- - -

## 2025.06.11.2

### Features

- Add 3ds exemption analytics ([#3072](https://github.com/juspay/hyperswitch-control-center/pull/3072)) ([`a460aa0`](https://github.com/juspay/hyperswitch-control-center/commit/a460aa03c2b2044ae05a82e6dc71644141653d98))

### Bug Fixes

- Calendar overlapping bugfix ([#3146](https://github.com/juspay/hyperswitch-control-center/pull/3146)) ([`c478492`](https://github.com/juspay/hyperswitch-control-center/commit/c478492e1b4743e3265b9cfe0eeddfa8b12adaf8))

**Full Changelog:** [`2025.06.11.1...2025.06.11.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.11.1...2025.06.11.2)

- - -

## 2025.06.11.1

### Bug Fixes

- Url updates for the default home page ([#3143](https://github.com/juspay/hyperswitch-control-center/pull/3143)) ([`334cdba`](https://github.com/juspay/hyperswitch-control-center/commit/334cdba15073311e81f9885858f91c99ba51a94a))

### Miscellaneous Tasks

- Recovery analytics ui changes ([#3124](https://github.com/juspay/hyperswitch-control-center/pull/3124)) ([`8f4d0e1`](https://github.com/juspay/hyperswitch-control-center/commit/8f4d0e182f3366da00682dead2af1005395c754b))

**Full Changelog:** [`2025.06.11.0...2025.06.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.11.0...2025.06.11.1)

- - -

## 2025.06.11.0

### Bug Fixes

- Horizontal scroll fix ([#3101](https://github.com/juspay/hyperswitch-control-center/pull/3101)) ([`5d46000`](https://github.com/juspay/hyperswitch-control-center/commit/5d46000d5f5d555e7b7f884947e141ab40da9fe3))
- Routing rule generated statements to exclude empty condition ([#3129](https://github.com/juspay/hyperswitch-control-center/pull/3129)) ([`e2430da`](https://github.com/juspay/hyperswitch-control-center/commit/e2430da018b13c940b5c09580193f624fc95087e))
- Custom daterange selector overlap with sidebar ([#3131](https://github.com/juspay/hyperswitch-control-center/pull/3131)) ([`e38adc4`](https://github.com/juspay/hyperswitch-control-center/commit/e38adc43d1ee6757da13da1d002737d9a4b108b2))

### Miscellaneous Tasks

- Recovery removed analytics feature flag ([#3136](https://github.com/juspay/hyperswitch-control-center/pull/3136)) ([`b9d86a5`](https://github.com/juspay/hyperswitch-control-center/commit/b9d86a544b822c68a83630c2186a1a806a6bb8a9))

**Full Changelog:** [`2025.06.09.0...2025.06.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.09.0...2025.06.11.0)

- - -

## 2025.06.09.0

### Bug Fixes

- Swap tabs in payout routing ([#3127](https://github.com/juspay/hyperswitch-control-center/pull/3127)) ([`53f0b23`](https://github.com/juspay/hyperswitch-control-center/commit/53f0b23bfe506287a2092fc3f3575824440cd770))
- Back navigation issue from SDK page ([#3126](https://github.com/juspay/hyperswitch-control-center/pull/3126)) ([`a30883e`](https://github.com/juspay/hyperswitch-control-center/commit/a30883e3b21a7bc949868ed3a56b390d8f7d2734))

**Full Changelog:** [`2025.06.06.0...2025.06.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.06.0...2025.06.09.0)

- - -

## 2025.06.06.0

### Features

- Routing audit logs ([#3120](https://github.com/juspay/hyperswitch-control-center/pull/3120)) ([`cef1135`](https://github.com/juspay/hyperswitch-control-center/commit/cef11359c67cf352e1d44e9c8f7ebe2a7aab3805))
- New connector worldpay vantiv ([#3090](https://github.com/juspay/hyperswitch-control-center/pull/3090)) ([`3ecb7af`](https://github.com/juspay/hyperswitch-control-center/commit/3ecb7afce0579e783d6207a5e8923a4ab284bf5a))

### Miscellaneous Tasks

- Removed recovery hard coded dummy keys ([#3086](https://github.com/juspay/hyperswitch-control-center/pull/3086)) ([`5affe18`](https://github.com/juspay/hyperswitch-control-center/commit/5affe18e414a854393d45e25de010a44ca0d9d11))

**Full Changelog:** [`2025.06.05.0...2025.06.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.05.0...2025.06.06.0)

- - -

## 2025.06.05.0

### Bug Fixes

- Debit routing duplication with multiple rules configuration ([#3114](https://github.com/juspay/hyperswitch-control-center/pull/3114)) ([`726ea9d`](https://github.com/juspay/hyperswitch-control-center/commit/726ea9d605c4d56b8d4ec7016749038b65d8d760))
- Overflow orgs case ([#3071](https://github.com/juspay/hyperswitch-control-center/pull/3071)) ([`5719b26`](https://github.com/juspay/hyperswitch-control-center/commit/5719b2658d6968c7c55416753afe6728921426e1))

**Full Changelog:** [`2025.06.04.2...2025.06.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.04.2...2025.06.05.0)

- - -

## 2025.06.04.2

### Bug Fixes

- Fixed generate reports modal responsiveness ([#3107](https://github.com/juspay/hyperswitch-control-center/pull/3107)) ([`92e7e90`](https://github.com/juspay/hyperswitch-control-center/commit/92e7e90f8fb2128f71a4b8c21ad2d86639d92ef2))

### Miscellaneous Tasks

- Make authentication type nullable ([#3106](https://github.com/juspay/hyperswitch-control-center/pull/3106)) ([`c7b2612`](https://github.com/juspay/hyperswitch-control-center/commit/c7b26125c2f0fc857a93f9354341ef3de55fc71b))
- Disable create configuration flow only for auth rate routing ([#3112](https://github.com/juspay/hyperswitch-control-center/pull/3112)) ([`f472b5b`](https://github.com/juspay/hyperswitch-control-center/commit/f472b5b30331c246209d9a9725a854687e50e3a1))

**Full Changelog:** [`2025.06.04.1...2025.06.04.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.04.1...2025.06.04.2)

- - -

## 2025.06.04.1

### Testing

- Fix failing routing tests ([#3093](https://github.com/juspay/hyperswitch-control-center/pull/3093)) ([`9324556`](https://github.com/juspay/hyperswitch-control-center/commit/93245563b51c8ad39161bb071bb30436019def22))

### Miscellaneous Tasks

- Path updated for dynamo wasm files as per BE changes ([#3100](https://github.com/juspay/hyperswitch-control-center/pull/3100)) ([`7b21754`](https://github.com/juspay/hyperswitch-control-center/commit/7b2175428307de38aff485b59c33b432229ad073))

**Full Changelog:** [`2025.06.04.0...2025.06.04.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.04.0...2025.06.04.1)

- - -

## 2025.06.04.0

### Features

- Auth-rate-based-routing for orchestrator ([#3033](https://github.com/juspay/hyperswitch-control-center/pull/3033)) ([`e5bba21`](https://github.com/juspay/hyperswitch-control-center/commit/e5bba214cc2c48c22e618ed28d55c6af09e603fe))

### Bug Fixes

- Updates for debit routing ([#3064](https://github.com/juspay/hyperswitch-control-center/pull/3064)) ([`82a3a97`](https://github.com/juspay/hyperswitch-control-center/commit/82a3a97d3f6ce1a6253e68f51931370354de3010))
- Debit routing configure modal ([#3094](https://github.com/juspay/hyperswitch-control-center/pull/3094)) ([`2f0dae7`](https://github.com/juspay/hyperswitch-control-center/commit/2f0dae721f561a8d98603df46e9244313c6b2beb))
- Configuring a Rule Based Configuration with amount / acquirer fraud rate conditions ([#3097](https://github.com/juspay/hyperswitch-control-center/pull/3097)) ([`420589f`](https://github.com/juspay/hyperswitch-control-center/commit/420589f2aa01aa6d5045467bc40638d0e00ccf51))

### Miscellaneous Tasks

- Displaying proper error message in case file is invalid in upl… ([#3096](https://github.com/juspay/hyperswitch-control-center/pull/3096)) ([`07286af`](https://github.com/juspay/hyperswitch-control-center/commit/07286aff7f15aebf5de557d291b2e5c914b222b6))

**Full Changelog:** [`2025.06.03.0...2025.06.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.06.03.0...2025.06.04.0)

- - -

## 2025.06.03.0

### Features

- Recovery invoices api data and removed hard coded data ([#3075](https://github.com/juspay/hyperswitch-control-center/pull/3075)) ([`1f3c6ba`](https://github.com/juspay/hyperswitch-control-center/commit/1f3c6ba8e1e65d2f550b1d95682f94840c243ba7))

### Miscellaneous Tasks

- Orchestrator Overview page revamp ([#3080](https://github.com/juspay/hyperswitch-control-center/pull/3080)) ([`0d8ebae`](https://github.com/juspay/hyperswitch-control-center/commit/0d8ebae7b8eb3859e0e26893343c219c0774121a))
- Missing line 1 & line 2 added ([#3087](https://github.com/juspay/hyperswitch-control-center/pull/3087)) ([`12c3d2b`](https://github.com/juspay/hyperswitch-control-center/commit/12c3d2b6c9312e9300b9778d60f4b15e6bc75896))

**Full Changelog:** [`2025.05.30.1...2025.06.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.30.1...2025.06.03.0)


- - -

## 2025.05.30.1

### Features

- Recovery auth rate summary graph, api utils and onboarding changes ([#3068](https://github.com/juspay/hyperswitch-control-center/pull/3068)) ([`97fa989`](https://github.com/juspay/hyperswitch-control-center/commit/97fa98939ef463757d2b819732fcb8854b45b081))
- Retry comparison graphs ([#3074](https://github.com/juspay/hyperswitch-control-center/pull/3074)) ([`4001ee7`](https://github.com/juspay/hyperswitch-control-center/commit/4001ee79920466a824a7e443bff07e304bc461ce))
- Auth rate up lift graph ([#3077](https://github.com/juspay/hyperswitch-control-center/pull/3077)) ([`255fe3b`](https://github.com/juspay/hyperswitch-control-center/commit/255fe3be8924d2e2ee9a2a9d8b01f321a322d811))
- Overall group graphs ([#3079](https://github.com/juspay/hyperswitch-control-center/pull/3079)) ([`2e560f4`](https://github.com/juspay/hyperswitch-control-center/commit/2e560f410f088dd63722e04408ac3bd1056dd1b9))

**Full Changelog:** [`2025.05.30.0...2025.05.30.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.30.0...2025.05.30.1)


- - -

## 2025.05.30.0

### Features

- Upload flow changes ([#2927](https://github.com/juspay/hyperswitch-control-center/pull/2927)) ([`b847d63`](https://github.com/juspay/hyperswitch-control-center/commit/b847d63b1883e48c320ee05533a1798084cc996b))

### Miscellaneous Tasks

- Removed unused business profile and business details code ([#3063](https://github.com/juspay/hyperswitch-control-center/pull/3063)) ([`b5e5c0a`](https://github.com/juspay/hyperswitch-control-center/commit/b5e5c0ae1d3e74bbef0d2cdb8f183e57f2908437))
- Update latest routing wasm ([#2959](https://github.com/juspay/hyperswitch-control-center/pull/2959)) ([`3c11c8c`](https://github.com/juspay/hyperswitch-control-center/commit/3c11c8cb3ff760e1c0ca2110dfbcda50d5eb2b9e))
- Removed frontend email case conversion ([#3065](https://github.com/juspay/hyperswitch-control-center/pull/3065)) ([`c92ada3`](https://github.com/juspay/hyperswitch-control-center/commit/c92ada3a4494107de2131bb55fa98771aed9837d))
- Update memory bank ([`9eee9af`](https://github.com/juspay/hyperswitch-control-center/commit/9eee9afa886be4279536e5b4a39843d3bc010bf2))
- Update memory bank ([`da8505d`](https://github.com/juspay/hyperswitch-control-center/commit/da8505dd06a0aca4dce454a764a2c873378347dc))

**Full Changelog:** [`2025.05.28.0...2025.05.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.28.0...2025.05.30.0)


- - -

## 2025.05.28.0

### Bug Fixes

- Text update in routing active card ([#3055](https://github.com/juspay/hyperswitch-control-center/pull/3055)) ([`23bab3f`](https://github.com/juspay/hyperswitch-control-center/commit/23bab3fe734c89d08d2dedb4d8c50eff77dfdea2))
- Standardise disabled state for sample analytics and show daterange filter field as dropdown ([#3040](https://github.com/juspay/hyperswitch-control-center/pull/3040)) ([`9db320f`](https://github.com/juspay/hyperswitch-control-center/commit/9db320fb3835a50cbe014479aa0d05f3f5c11aca))
- Sdk issue description ([#3058](https://github.com/juspay/hyperswitch-control-center/pull/3058)) ([`9ce308d`](https://github.com/juspay/hyperswitch-control-center/commit/9ce308d1311f999284139f3a1bce0cbb39c94d5a))

### Miscellaneous Tasks

- Added mixpanel event on start exploring button ([#3053](https://github.com/juspay/hyperswitch-control-center/pull/3053)) ([`b08376e`](https://github.com/juspay/hyperswitch-control-center/commit/b08376e01bdc7b9dc6eceb5b268b62bb2c0f8aba))
- Wasm changes & add archipel to prod ([#3060](https://github.com/juspay/hyperswitch-control-center/pull/3060)) ([`e22702a`](https://github.com/juspay/hyperswitch-control-center/commit/e22702a2cf1e15f66ba3eaacfa5446791f8fa94f))

**Full Changelog:** [`2025.05.26.1...2025.05.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.26.1...2025.05.28.0)


- - -

## 2025.05.26.1

### Features

- Stripe refund for split payment ([#3038](https://github.com/juspay/hyperswitch-control-center/pull/3038)) ([`7c64756`](https://github.com/juspay/hyperswitch-control-center/commit/7c64756917b7b1652428c57eee0f9562d5bdcfd8))
- Add worldpayxml connector ([#3049](https://github.com/juspay/hyperswitch-control-center/pull/3049)) ([`4432fd5`](https://github.com/juspay/hyperswitch-control-center/commit/4432fd57f5fa7f76075566c6674b37ec3972ede2))

### Bug Fixes

- Product type value added in prod intent api payload ([#3051](https://github.com/juspay/hyperswitch-control-center/pull/3051)) ([`3db23a3`](https://github.com/juspay/hyperswitch-control-center/commit/3db23a345cd08f6a20cc880cf508bd0ef5d93cca))

### Miscellaneous Tasks

- Update latest memory bank ([#3005](https://github.com/juspay/hyperswitch-control-center/pull/3005)) ([`3ba78a7`](https://github.com/juspay/hyperswitch-control-center/commit/3ba78a75c10d7e74d57d3ade0be8023471bd85ec))
- Remove unused code ([#3000](https://github.com/juspay/hyperswitch-control-center/pull/3000)) ([`f4aa8f7`](https://github.com/juspay/hyperswitch-control-center/commit/f4aa8f7784af5b7d40bdc7faeffcc15d09260f7b))

**Full Changelog:** [`2025.05.26.0...2025.05.26.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.26.0...2025.05.26.1)


- - -

## 2025.05.26.0

### Features

- Debit routing configuration addition ([#3025](https://github.com/juspay/hyperswitch-control-center/pull/3025)) ([`0f56cbf`](https://github.com/juspay/hyperswitch-control-center/commit/0f56cbf61a9bb416e943ddad171a36d75e71ab10))

### Miscellaneous Tasks

- Update preview image for Blur Web SDK ([#3031](https://github.com/juspay/hyperswitch-control-center/pull/3031)) ([`39a2986`](https://github.com/juspay/hyperswitch-control-center/commit/39a2986f6e354c18b24becab0a68f443b3aefada))
- Get prod access UI revamp ([#2974](https://github.com/juspay/hyperswitch-control-center/pull/2974)) ([`ec24629`](https://github.com/juspay/hyperswitch-control-center/commit/ec24629e9f4c66ff9d7a0a00b674882b60295f79))

**Full Changelog:** [`2025.05.23.0...2025.05.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.23.0...2025.05.26.0)


- - -

## 2025.05.23.0

### Bug Fixes

- Payout processor unknown name in edit pmt ([#3027](https://github.com/juspay/hyperswitch-control-center/pull/3027)) ([`2b859f3`](https://github.com/juspay/hyperswitch-control-center/commit/2b859f378ff2925286cea863520ac01d83de5ca1))

### Refactors

- Move typography folder under UI config ([#3013](https://github.com/juspay/hyperswitch-control-center/pull/3013)) ([`1bf95c9`](https://github.com/juspay/hyperswitch-control-center/commit/1bf95c936a68aee765c21c8e3f27c189b64937e5))

### Testing

- Fix failing tests ([#3026](https://github.com/juspay/hyperswitch-control-center/pull/3026)) ([`57d64fa`](https://github.com/juspay/hyperswitch-control-center/commit/57d64fa28be4758394747b1a7378abaefb7d1713))

### Miscellaneous Tasks

- Refactor hooks folder ([#2998](https://github.com/juspay/hyperswitch-control-center/pull/2998)) ([`026fbf0`](https://github.com/juspay/hyperswitch-control-center/commit/026fbf014cacff13ea4336b092315b8ed7a028d7))

**Full Changelog:** [`2025.05.22.0...2025.05.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.22.0...2025.05.23.0)


- - -

## 2025.05.22.0

### Features

- Recovery analytics feature flag ([#3023](https://github.com/juspay/hyperswitch-control-center/pull/3023)) ([`c372db0`](https://github.com/juspay/hyperswitch-control-center/commit/c372db04d690d2903b6fbeb43e4ba83328ec5904))

### Bug Fixes

- Prevent Web SDK script from loading multiple times ([#3020](https://github.com/juspay/hyperswitch-control-center/pull/3020)) ([`3a81ed2`](https://github.com/juspay/hyperswitch-control-center/commit/3a81ed2c9e5531b9717347edd92b9a97bf6c0f3e))

**Full Changelog:** [`2025.05.21.0...2025.05.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.21.0...2025.05.22.0)


- - -

## 2025.05.21.0

### Features

- Recovery analytics folder and side bar routes changes ([#2997](https://github.com/juspay/hyperswitch-control-center/pull/2997)) ([`1811176`](https://github.com/juspay/hyperswitch-control-center/commit/1811176dc498c9ef849fc779ff0c6ccf3f2f34aa))

### Bug Fixes

- Webhook ui enhancement ([#3007](https://github.com/juspay/hyperswitch-control-center/pull/3007)) ([`c33d40f`](https://github.com/juspay/hyperswitch-control-center/commit/c33d40fe052f1b1c4351a7902fadedc2f694b137))

### Miscellaneous Tasks

- Add metadata in mixpanel sample analytics ([#3002](https://github.com/juspay/hyperswitch-control-center/pull/3002)) ([`b228a6d`](https://github.com/juspay/hyperswitch-control-center/commit/b228a6da05a462faaf8b94485cc130ed21c36ea9))
- Standardize names ([#2985](https://github.com/juspay/hyperswitch-control-center/pull/2985)) ([`f5de8a8`](https://github.com/juspay/hyperswitch-control-center/commit/f5de8a8c31d44f0f68efd62f9339124ed9911a08))
- Redsys connector live ([#3016](https://github.com/juspay/hyperswitch-control-center/pull/3016)) ([`5bd3622`](https://github.com/juspay/hyperswitch-control-center/commit/5bd3622fde524c4ba471d351455a171b34db6690))
- Webhook minor updates 1 ([#3017](https://github.com/juspay/hyperswitch-control-center/pull/3017)) ([`66071c7`](https://github.com/juspay/hyperswitch-control-center/commit/66071c7d9cbb69a0c22e37749fbf019e8180b48b))

**Full Changelog:** [`2025.05.20.1...2025.05.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.20.1...2025.05.21.0)


- - -

## 2025.05.20.1

### Bug Fixes

- Analytics sample fixes ([#3012](https://github.com/juspay/hyperswitch-control-center/pull/3012)) ([`ab281e7`](https://github.com/juspay/hyperswitch-control-center/commit/ab281e709027f0ba1103042de43ace4f1833c58d))

**Full Changelog:** [`2025.05.20.0...2025.05.20.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.20.0...2025.05.20.1)


- - -

## 2025.05.20.0

### Features

- **connector:** Archipel connector ([#2876](https://github.com/juspay/hyperswitch-control-center/pull/2876)) ([`b247994`](https://github.com/juspay/hyperswitch-control-center/commit/b24799471c0b1404dd6b03914d8555a9c363995f))

### Bug Fixes

- Fixed arrows in custom range calenders ([#2969](https://github.com/juspay/hyperswitch-control-center/pull/2969)) ([`032291e`](https://github.com/juspay/hyperswitch-control-center/commit/032291eda32a23c35ac151e91ccdfa22e51aee13))

### Miscellaneous Tasks

- Fix typo in config ([#2986](https://github.com/juspay/hyperswitch-control-center/pull/2986)) ([`25e3b36`](https://github.com/juspay/hyperswitch-control-center/commit/25e3b367b4bd155075bcc94306b9adca4d1f1103))
- Sample data analytics feature flag and mixpanel addition ([#2994](https://github.com/juspay/hyperswitch-control-center/pull/2994)) ([`8916e7c`](https://github.com/juspay/hyperswitch-control-center/commit/8916e7c7882afb6aadc02d216e2881971505e89e))
- Revert "browser navigation" handle redirect from sso ([#2988](https://github.com/juspay/hyperswitch-control-center/pull/2988)) ([`7f4bd36`](https://github.com/juspay/hyperswitch-control-center/commit/7f4bd363710126dbd1391c5a7d764ee238cc4bd6))

**Full Changelog:** [`2025.05.19.0...2025.05.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.19.0...2025.05.20.0)


- - -

## 2025.05.19.0

### Bug Fixes

- Payme connector not sending webhookdetails when only additional secret is populated ([#2946](https://github.com/juspay/hyperswitch-control-center/pull/2946)) ([`6572126`](https://github.com/juspay/hyperswitch-control-center/commit/6572126fc65b9cdb1928f401b02347912cef2a3b))

### Miscellaneous Tasks

- Insights file name change ([#2976](https://github.com/juspay/hyperswitch-control-center/pull/2976)) ([`e57f860`](https://github.com/juspay/hyperswitch-control-center/commit/e57f860206e2653960742a0a027ba2638bdb7185))

**Full Changelog:** [`2025.05.16.2...2025.05.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.16.2...2025.05.19.0)


- - -

## 2025.05.16.2

### Bug Fixes

- Safari select buttons change in rule based routing ([#2979](https://github.com/juspay/hyperswitch-control-center/pull/2979)) ([`df72e24`](https://github.com/juspay/hyperswitch-control-center/commit/df72e245034d2492373e0074152f13a7d34e0e77))
- Soft color correction ([#2982](https://github.com/juspay/hyperswitch-control-center/pull/2982)) ([`aa9e359`](https://github.com/juspay/hyperswitch-control-center/commit/aa9e3599e26e06801d0dba5e04e1d7bc3ffa0524))

### Miscellaneous Tasks

- Memory bank update for table creation ([#2980](https://github.com/juspay/hyperswitch-control-center/pull/2980)) ([`0c7c26a`](https://github.com/juspay/hyperswitch-control-center/commit/0c7c26aac830246fdb79b6ac9a15a367f1b5c6a7))
- Sample data analytics ([#2912](https://github.com/juspay/hyperswitch-control-center/pull/2912)) ([`3c5fdc0`](https://github.com/juspay/hyperswitch-control-center/commit/3c5fdc00b839cbb089c029ed542d983b0f8a5108))
- Banner text design for sample analytics ([#2984](https://github.com/juspay/hyperswitch-control-center/pull/2984)) ([`e419bf1`](https://github.com/juspay/hyperswitch-control-center/commit/e419bf125a474820b8d93c510d2d7349e24354eb))

**Full Changelog:** [`2025.05.16.1...2025.05.16.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.16.1...2025.05.16.2)


- - -

## 2025.05.16.1

### Features

- Hubspot changes ([#2848](https://github.com/juspay/hyperswitch-control-center/pull/2848)) ([`a92a814`](https://github.com/juspay/hyperswitch-control-center/commit/a92a81448c4fcb0f22e349704f6fef54a987ea84))

**Full Changelog:** [`2025.05.16.0...2025.05.16.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.16.0...2025.05.16.1)


- - -

## 2025.05.16.0

### Bug Fixes

- Insights side bar highlight fix ([#2963](https://github.com/juspay/hyperswitch-control-center/pull/2963)) ([`03d5bfc`](https://github.com/juspay/hyperswitch-control-center/commit/03d5bfc9d9b1ee1a07da859a72249f34e32da477))

**Full Changelog:** [`2025.05.15.2...2025.05.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.15.2...2025.05.16.0)


- - -

## 2025.05.15.2

### Miscellaneous Tasks

- Update memory bank ([`f5d6a04`](https://github.com/juspay/hyperswitch-control-center/commit/f5d6a042670602850f0e34fed12dbc976548fe99))
- Update memory bank ([`54adac4`](https://github.com/juspay/hyperswitch-control-center/commit/54adac40798a4e8e5afd2d482e448bfd2bf45e11))
- Update memory bank ([`0ef13b5`](https://github.com/juspay/hyperswitch-control-center/commit/0ef13b510517148a3525787eb968da62b4801edc))
- Memory bank addition for table creation ([#2972](https://github.com/juspay/hyperswitch-control-center/pull/2972)) ([`f9c5709`](https://github.com/juspay/hyperswitch-control-center/commit/f9c57090738b6c6d429cfafb2ea4bc79da79b8b1))
- Style issues for scrolling sdk ([#2967](https://github.com/juspay/hyperswitch-control-center/pull/2967)) ([`2aff2c2`](https://github.com/juspay/hyperswitch-control-center/commit/2aff2c2b949f6e10710966ca6ccf7ecebfed8498))

**Full Changelog:** [`2025.05.15.1...2025.05.15.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.15.1...2025.05.15.2)

- - -

## 2025.05.15.1

### Features

- Add clarity tracking ([#2961](https://github.com/juspay/hyperswitch-control-center/pull/2961)) ([`dfb17d6`](https://github.com/juspay/hyperswitch-control-center/commit/dfb17d65933291a0b20e030bccd3f68dbf0c44ea))

### Miscellaneous Tasks

- Api call for payments - theme customization & bg-color added ([#2966](https://github.com/juspay/hyperswitch-control-center/pull/2966)) ([`77a0f2a`](https://github.com/juspay/hyperswitch-control-center/commit/77a0f2ab230e18d008baf85e48d297a01ae2f73c))

**Full Changelog:** [`2025.05.15.0...2025.05.15.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.15.0...2025.05.15.1)


- - -

## 2025.05.15.0

### Features

- Include UPI collect SVG asset in TestProcessor ([#2955](https://github.com/juspay/hyperswitch-control-center/pull/2955)) ([`9c4be55`](https://github.com/juspay/hyperswitch-control-center/commit/9c4be55bde9bbb2ccbd2705c519208e6ea47f249))
- SDK page revamp with updated configuration support ([#2895](https://github.com/juspay/hyperswitch-control-center/pull/2895)) ([`ae6cd59`](https://github.com/juspay/hyperswitch-control-center/commit/ae6cd5900f307ec4c5c7e3a7e1b463a0dda700c5))

### Miscellaneous Tasks

- Memory bank config ([#2960](https://github.com/juspay/hyperswitch-control-center/pull/2960)) ([`e6cd305`](https://github.com/juspay/hyperswitch-control-center/commit/e6cd305b91736ddd660a6b0d84b830dae9edc6c2))

**Full Changelog:** [`2025.05.14.0...2025.05.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.14.0...2025.05.15.0)


- - -

## 2025.05.14.0

### Features

- Added wasm for intelligent routing ([#2905](https://github.com/juspay/hyperswitch-control-center/pull/2905)) ([`6842aa2`](https://github.com/juspay/hyperswitch-control-center/commit/6842aa246c7c211e4477f0f4f44a9cd3c0430f93))

### Miscellaneous Tasks

- Upload flow core changes ([#2908](https://github.com/juspay/hyperswitch-control-center/pull/2908)) ([`a21b8e6`](https://github.com/juspay/hyperswitch-control-center/commit/a21b8e694d064135765ed2f0c8bd77846b96df7d))
- Update the memory bank ([`de6e3bc`](https://github.com/juspay/hyperswitch-control-center/commit/de6e3bc60163b1bc2d673461a22d314628be5229))

**Full Changelog:** [`2025.05.13.0...2025.05.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.13.0...2025.05.14.0)


- - -

## 2025.05.13.0

### Bug Fixes

- Override 3ds rule popup changes when deleted all 3ds rules ([#2919](https://github.com/juspay/hyperswitch-control-center/pull/2919)) ([`e57518c`](https://github.com/juspay/hyperswitch-control-center/commit/e57518cf3f20133d44dfc73982f095d5dc25e9aa))

### Miscellaneous Tasks

- Add memory bank ([`10150eb`](https://github.com/juspay/hyperswitch-control-center/commit/10150eb2a5677761d36ad23564003aa74eaf800d))
- Add memory bank ([`53d6918`](https://github.com/juspay/hyperswitch-control-center/commit/53d6918cfd4a6a2cc4d2ddd6415c62edfa8d5991))
- Add memory bank ([`1ddde37`](https://github.com/juspay/hyperswitch-control-center/commit/1ddde37f8c6156032f6a2410aee9a752db3bb945))

**Full Changelog:** [`2025.05.09.0...2025.05.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.09.0...2025.05.13.0)

- - -

## 2025.05.09.0

### Bug Fixes

- Recovery Processor Reference ID empty value validation check ([#2925](https://github.com/juspay/hyperswitch-control-center/pull/2925)) ([`8eb30c5`](https://github.com/juspay/hyperswitch-control-center/commit/8eb30c5ba472f823847f5899a3b7dd875702344d))
- Old analytics tab value bug fix ([#2926](https://github.com/juspay/hyperswitch-control-center/pull/2926)) ([`7d6d664`](https://github.com/juspay/hyperswitch-control-center/commit/7d6d664eb9f43e8c0c4604a95eb2c16143f8fd70))

**Full Changelog:** [`2025.05.08.0...2025.05.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.08.0...2025.05.09.0)


- - -

## 2025.05.08.0

### Bug Fixes

- Added health log in health handler ([#2942](https://github.com/juspay/hyperswitch-control-center/pull/2942)) ([`13aee58`](https://github.com/juspay/hyperswitch-control-center/commit/13aee585d2779da64a84aa1bcc6a03514f6f0dae))

### Testing

- Payment operations date checking with 2 digits ([#2936](https://github.com/juspay/hyperswitch-control-center/pull/2936)) ([`8dd6532`](https://github.com/juspay/hyperswitch-control-center/commit/8dd65320f16dfa2f30af8a4113b34e828169464d))

### Miscellaneous Tasks

- Updated pr label workflow ([#2915](https://github.com/juspay/hyperswitch-control-center/pull/2915)) ([`f34b5ee`](https://github.com/juspay/hyperswitch-control-center/commit/f34b5ee9065415f0b017643648515e79103074bd))

**Full Changelog:** [`2025.05.07.0...2025.05.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.07.0...2025.05.08.0)


- - -

## 2025.05.07.0

### Miscellaneous Tasks

- Added facilitapay connector ([#2929](https://github.com/juspay/hyperswitch-control-center/pull/2929)) ([`249bd03`](https://github.com/juspay/hyperswitch-control-center/commit/249bd03737eef7f011d898e510470c9c8781196f))
- Wasm update for facilitapay connector ([#2930](https://github.com/juspay/hyperswitch-control-center/pull/2930)) ([`5c867ed`](https://github.com/juspay/hyperswitch-control-center/commit/5c867edeecd62b337e1d7b986320e4bbbdc40711))

**Full Changelog:** [`2025.05.06.0...2025.05.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.06.0...2025.05.07.0)


- - -

## 2025.05.06.0

### Bug Fixes

- Added validation for the api keys ([#2920](https://github.com/juspay/hyperswitch-control-center/pull/2920)) ([`4fb87f0`](https://github.com/juspay/hyperswitch-control-center/commit/4fb87f0f64adca48cb4f26fab132bccde3939e5e))
- Changed old analytics graph font style to InterDisplay ([#2918](https://github.com/juspay/hyperswitch-control-center/pull/2918)) ([`2715444`](https://github.com/juspay/hyperswitch-control-center/commit/271544465319bb7750096fb7f5be8a2950d25668))

### Miscellaneous Tasks

- Changed revenue recovery mixpanel events ([#2902](https://github.com/juspay/hyperswitch-control-center/pull/2902)) ([`6c8c94f`](https://github.com/juspay/hyperswitch-control-center/commit/6c8c94f8ead4e4651cdcc2b309dff8dda9e5fb1a))

**Full Changelog:** [`2025.05.05.0...2025.05.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.05.0...2025.05.06.0)


- - -

## 2025.05.05.0

### Bug Fixes

- Browser navigation issues ([#2886](https://github.com/juspay/hyperswitch-control-center/pull/2886)) ([`fa75dc6`](https://github.com/juspay/hyperswitch-control-center/commit/fa75dc63202dcd5f1242b99631ef6aae5091d48b))

**Full Changelog:** [`2025.05.01.0...2025.05.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.05.01.0...2025.05.05.0)


- - -

## 2025.05.01.0

### Bug Fixes

- Safari ui changes for svg and select buttons ([#2910](https://github.com/juspay/hyperswitch-control-center/pull/2910)) ([`4da2944`](https://github.com/juspay/hyperswitch-control-center/commit/4da29446fd8177f5bb14f62e05ac84068acf6df5))
- Merchant name issue fix ([#2913](https://github.com/juspay/hyperswitch-control-center/pull/2913)) ([`436f881`](https://github.com/juspay/hyperswitch-control-center/commit/436f88117c261a7c9014564161e89600a9a5162e))

### Testing

- Add payment operations tests ([#2882](https://github.com/juspay/hyperswitch-control-center/pull/2882)) ([`d7048f0`](https://github.com/juspay/hyperswitch-control-center/commit/d7048f0040f5ff511e4afe813a8320b71e73e35d))

**Full Changelog:** [`2025.04.30.0...2025.05.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.30.0...2025.05.01.0)


- - -

## 2025.04.30.0

### Bug Fixes

- Payment show details fetch when payment id changes ([#2881](https://github.com/juspay/hyperswitch-control-center/pull/2881)) ([`814acbe`](https://github.com/juspay/hyperswitch-control-center/commit/814acbef980c084865d8cbdcf6337db7fbe3ea0b))
- Webhook url not configured text update ([#2899](https://github.com/juspay/hyperswitch-control-center/pull/2899)) ([`b087fd3`](https://github.com/juspay/hyperswitch-control-center/commit/b087fd37511bfcc534f57a5e42fa784f121b37c1))
- All types of connectors showing in operations connector filter ([#2897](https://github.com/juspay/hyperswitch-control-center/pull/2897)) ([`62390b7`](https://github.com/juspay/hyperswitch-control-center/commit/62390b7c5f6bea57a6c372e7e40c75ef6c7c1f3f))

### Miscellaneous Tasks

- Typography standardisation Tokens initialisation ([#2893](https://github.com/juspay/hyperswitch-control-center/pull/2893)) ([`3d5bfe4`](https://github.com/juspay/hyperswitch-control-center/commit/3d5bfe4a31cd3be36b1140955985320783adeafa))

**Full Changelog:** [`2025.04.29.0...2025.04.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.29.0...2025.04.30.0)


- - -

## 2025.04.29.0

### Miscellaneous Tasks

- Addition of letter spacing in tailwind ([#2885](https://github.com/juspay/hyperswitch-control-center/pull/2885)) ([`c6abafb`](https://github.com/juspay/hyperswitch-control-center/commit/c6abafba280ba5bea3e88b163a35719b7ab5d170))

**Full Changelog:** [`2025.04.25.0...2025.04.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.25.0...2025.04.29.0)


- - -

## 2025.04.25.0

### Bug Fixes

- Fix navbar alignment issues in 13inch Screens ([#2887](https://github.com/juspay/hyperswitch-control-center/pull/2887)) ([`e819c5d`](https://github.com/juspay/hyperswitch-control-center/commit/e819c5d3fab68d1662d449adf83bddc5ec0de63e))
- Added success toast after updating connector credentials ([#2890](https://github.com/juspay/hyperswitch-control-center/pull/2890)) ([`ed63b18`](https://github.com/juspay/hyperswitch-control-center/commit/ed63b188fd5a2d196fbc17a5e0cfbf77792440c9))

### Refactors

- Removed form values spy ([#2889](https://github.com/juspay/hyperswitch-control-center/pull/2889)) ([`cf25593`](https://github.com/juspay/hyperswitch-control-center/commit/cf25593a6a3c3c69a760b7af212d73677f961f89))

### Miscellaneous Tasks

- Removed business details and business profile page and refacto… ([#2845](https://github.com/juspay/hyperswitch-control-center/pull/2845)) ([`effcd34`](https://github.com/juspay/hyperswitch-control-center/commit/effcd347e99c3dcaa29fd31ff6a4c3942fe1403a))
- Themes release ([#2300](https://github.com/juspay/hyperswitch-control-center/pull/2300)) ([`d7d5046`](https://github.com/juspay/hyperswitch-control-center/commit/d7d5046008142ad5deab9a5512c8adc3404605a9))
- Added disable functionality to threeds connectors ([#2870](https://github.com/juspay/hyperswitch-control-center/pull/2870)) ([`d79d311`](https://github.com/juspay/hyperswitch-control-center/commit/d79d311616377e11cd68c1530dbacfe241ca808a))
- Added send invite mixpanel event ([#2891](https://github.com/juspay/hyperswitch-control-center/pull/2891)) ([`0228230`](https://github.com/juspay/hyperswitch-control-center/commit/02282302be8c5436c007a4059c16fdbb4449451d))

**Full Changelog:** [`2025.04.24.0...2025.04.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.24.0...2025.04.25.0)


- - -

## 2025.04.24.0

### Features

- Mobile responsive for operations section ([#2869](https://github.com/juspay/hyperswitch-control-center/pull/2869)) ([`5b7b9b5`](https://github.com/juspay/hyperswitch-control-center/commit/5b7b9b585f151bb5bc39bf0ec0c5b1e26fc8ede2))

### Bug Fixes

- Rename webhooks request heading to event data ([#2872](https://github.com/juspay/hyperswitch-control-center/pull/2872)) ([`e72e426`](https://github.com/juspay/hyperswitch-control-center/commit/e72e42635738a64d8b3a2b01b415ea179a76e614))
- Configure pmts filter issues ([#2871](https://github.com/juspay/hyperswitch-control-center/pull/2871)) ([`2182543`](https://github.com/juspay/hyperswitch-control-center/commit/21825431ecd6d55cad1688be8717c11b41adcf16))
- New authentication analytics key and dimensions changes ([#2880](https://github.com/juspay/hyperswitch-control-center/pull/2880)) ([`557441d`](https://github.com/juspay/hyperswitch-control-center/commit/557441d0117f40b759a785df9f938110e658c55c))

### Refactors

- Sdk code refactoring ([#2862](https://github.com/juspay/hyperswitch-control-center/pull/2862)) ([`7cabcbf`](https://github.com/juspay/hyperswitch-control-center/commit/7cabcbfdcf2d0bbcf0df7a7e2addc186377b2429))

### Miscellaneous Tasks

- Added country currency mapping with icons ([#2859](https://github.com/juspay/hyperswitch-control-center/pull/2859)) ([`7098f4a`](https://github.com/juspay/hyperswitch-control-center/commit/7098f4a53ece5385d6b02d08c68495ac92727ee3))
- Remove warnings ([#2875](https://github.com/juspay/hyperswitch-control-center/pull/2875)) ([`1ecc8b8`](https://github.com/juspay/hyperswitch-control-center/commit/1ecc8b80cea8c55ff2a3877aa2e1ba0cef5815b1))
- Configurartion record type ([#2877](https://github.com/juspay/hyperswitch-control-center/pull/2877)) ([`453247d`](https://github.com/juspay/hyperswitch-control-center/commit/453247d14c0622d847fdc7bfa92a29d0a67fc5ef))

**Full Changelog:** [`2025.04.23.0...2025.04.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.23.0...2025.04.24.0)


- - -

## 2025.04.23.0

### Bug Fixes

- Fixed ctp_vissa connector not updating ([#2856](https://github.com/juspay/hyperswitch-control-center/pull/2856)) ([`1c585b2`](https://github.com/juspay/hyperswitch-control-center/commit/1c585b2494ab20ab9202238ce2f020456144fd4a))

### Miscellaneous Tasks

- Changed scrollbar colour and state ([#2852](https://github.com/juspay/hyperswitch-control-center/pull/2852)) ([`5ab4ba7`](https://github.com/juspay/hyperswitch-control-center/commit/5ab4ba7b9df15784ea5dffd0202d273893a0a80d))
- Added time selection for payments and reports ([#2854](https://github.com/juspay/hyperswitch-control-center/pull/2854)) ([`1338d1d`](https://github.com/juspay/hyperswitch-control-center/commit/1338d1d1bae5aa044283a643a7e0c3b746b5e47d))

**Full Changelog:** [`2025.04.22.0...2025.04.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.22.0...2025.04.23.0)


- - -

## 2025.04.22.0

### Bug Fixes

- Connector metadata default ([#2849](https://github.com/juspay/hyperswitch-control-center/pull/2849)) ([`a48970b`](https://github.com/juspay/hyperswitch-control-center/commit/a48970b0c524953ff9d90617306d55a64014c15b))
- Webhooks request response data interchange fix ([#2850](https://github.com/juspay/hyperswitch-control-center/pull/2850)) ([`fa160e0`](https://github.com/juspay/hyperswitch-control-center/commit/fa160e0541e122ee69333b446690e374ab52e297))

### Miscellaneous Tasks

- Update login event ([#2855](https://github.com/juspay/hyperswitch-control-center/pull/2855)) ([`2c06a3c`](https://github.com/juspay/hyperswitch-control-center/commit/2c06a3cfe56df58e97f340e2d509e645f9712475))

**Full Changelog:** [`2025.04.18.0...2025.04.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.18.0...2025.04.22.0)


- - -

## 2025.04.18.0

### Bug Fixes

- Analytics group by currency NA row fix ([#2839](https://github.com/juspay/hyperswitch-control-center/pull/2839)) ([`bf681d9`](https://github.com/juspay/hyperswitch-control-center/commit/bf681d9a5e94bd7abab97ebb449dcc118612c5bb))
- Amount available to refund in payments page initiate refund ([#2840](https://github.com/juspay/hyperswitch-control-center/pull/2840)) ([`a990680`](https://github.com/juspay/hyperswitch-control-center/commit/a990680773329da9adecca760a3213251fdc89dc))
- Logs in payments details ([#2825](https://github.com/juspay/hyperswitch-control-center/pull/2825)) ([`00a0e67`](https://github.com/juspay/hyperswitch-control-center/commit/00a0e670121c9e62005da46a23eb4949fa94414c))
- Wrong metrics in the operations cards ([#2842](https://github.com/juspay/hyperswitch-control-center/pull/2842)) ([`d662154`](https://github.com/juspay/hyperswitch-control-center/commit/d6621540dd1b5bc3db777525eafadc7d0e734d63))

### Testing

- Refactor tests ([#2837](https://github.com/juspay/hyperswitch-control-center/pull/2837)) ([`8b3288e`](https://github.com/juspay/hyperswitch-control-center/commit/8b3288e2bbf29b831c31161eb3d83e643147a94d))

### Miscellaneous Tasks

- Modified connector bodykey handling for NoAuth auth type ([#2797](https://github.com/juspay/hyperswitch-control-center/pull/2797)) ([`955dad1`](https://github.com/juspay/hyperswitch-control-center/commit/955dad1884b3eda8b09730d776536a9244a059f7))
- Changed merchant level api endpoint to profile level ([#2843](https://github.com/juspay/hyperswitch-control-center/pull/2843)) ([`68f14af`](https://github.com/juspay/hyperswitch-control-center/commit/68f14af459f7a2478e3db8ab7f592f03eb431377))

**Full Changelog:** [`2025.04.17.0...2025.04.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.17.0...2025.04.18.0)


- - -

## 2025.04.17.0

### Bug Fixes

- Refunds disable/enable in operations ([#2833](https://github.com/juspay/hyperswitch-control-center/pull/2833)) ([`93fe0ec`](https://github.com/juspay/hyperswitch-control-center/commit/93fe0ec58b67574c8ff4886be1e524062fbfe6cd))

### Miscellaneous Tasks

- Added worldpay connector in prod ([#2832](https://github.com/juspay/hyperswitch-control-center/pull/2832)) ([`35e660e`](https://github.com/juspay/hyperswitch-control-center/commit/35e660e8f37fda6861c6776b277fef1183e0c71d))
- Recon navigation and url changes ([#2826](https://github.com/juspay/hyperswitch-control-center/pull/2826)) ([`bd467b9`](https://github.com/juspay/hyperswitch-control-center/commit/bd467b91b44bf5fe4474f761cff4dafb138be172))

**Full Changelog:** [`2025.04.16.0...2025.04.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.16.0...2025.04.17.0)


- - -

## 2025.04.16.0

### Features

- Recon onboarding api integration ([#2705](https://github.com/juspay/hyperswitch-control-center/pull/2705)) ([`92f0e94`](https://github.com/juspay/hyperswitch-control-center/commit/92f0e94fa31a61dc2d1a08afb04dfd711cbdce3b))

### Bug Fixes

- Text overlap in Configure PMTs & Remove profile id and name ([#2804](https://github.com/juspay/hyperswitch-control-center/pull/2804)) ([`73db657`](https://github.com/juspay/hyperswitch-control-center/commit/73db657ff29bb1b6696d3c5a99aa7fb5cf15c1af))
- Overlap sidebar ([#2817](https://github.com/juspay/hyperswitch-control-center/pull/2817)) ([`e123428`](https://github.com/juspay/hyperswitch-control-center/commit/e123428809d9d0515bd7be93bd5906d326d6ca2f))

**Full Changelog:** [`2025.04.11.2...2025.04.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.11.2...2025.04.16.0)


- - -

## 2025.04.11.2

### Bug Fixes

- Empty page issue on omp dropdown item click ([#2818](https://github.com/juspay/hyperswitch-control-center/pull/2818)) ([`12ca0a7`](https://github.com/juspay/hyperswitch-control-center/commit/12ca0a7ad3755e6ee0cfcd8e54205202ec241556))

**Full Changelog:** [`2025.04.11.1...2025.04.11.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.11.1...2025.04.11.2)


- - -

## 2025.04.11.1

### Bug Fixes

- Merchant name update failing for v2 ([#2815](https://github.com/juspay/hyperswitch-control-center/pull/2815)) ([`07df36c`](https://github.com/juspay/hyperswitch-control-center/commit/07df36c446ef66baf34514fd1b3d11b2f7f4adc7))
- Safari dashboard ui fixes ([#2809](https://github.com/juspay/hyperswitch-control-center/pull/2809)) ([`5fa8dbd`](https://github.com/juspay/hyperswitch-control-center/commit/5fa8dbd8d52b62c67e4b130c1a4f99cc0c3e1338))
- Recovery minor fixes ([#2813](https://github.com/juspay/hyperswitch-control-center/pull/2813)) ([`288eafe`](https://github.com/juspay/hyperswitch-control-center/commit/288eafec6526f4aed4ed9df77c44ac175e4b478b))

**Full Changelog:** [`2025.04.11.0...2025.04.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.11.0...2025.04.11.1)


- - -

## 2025.04.11.0

### Features

- Google pay decryption flow for cybersource ([#2652](https://github.com/juspay/hyperswitch-control-center/pull/2652)) ([`e1e9248`](https://github.com/juspay/hyperswitch-control-center/commit/e1e92484f7d07377ede90dae140d709e43187717))
- Field addition for create refund for coingate connector ([#2731](https://github.com/juspay/hyperswitch-control-center/pull/2731)) ([`3d47bfb`](https://github.com/juspay/hyperswitch-control-center/commit/3d47bfb2b7cf602e49bca853184fb9698abe4ad9))
- Webhook list and details introduced ([#2224](https://github.com/juspay/hyperswitch-control-center/pull/2224)) ([`79aff4b`](https://github.com/juspay/hyperswitch-control-center/commit/79aff4b749545eec118292fd614269155842c309))

### Bug Fixes

- Show payment details issue on new tab open ([#2805](https://github.com/juspay/hyperswitch-control-center/pull/2805)) ([`9f3d326`](https://github.com/juspay/hyperswitch-control-center/commit/9f3d326f25699274b3a3b1e97124a7eafebee97e))
- Pci security issues in docker and cypress ([#2794](https://github.com/juspay/hyperswitch-control-center/pull/2794)) ([`454757d`](https://github.com/juspay/hyperswitch-control-center/commit/454757dd74aa00ae6392e0fc18255489b38173aa))

### Refactors

- Copy text custom component displayValue type change ([#2808](https://github.com/juspay/hyperswitch-control-center/pull/2808)) ([`b722495`](https://github.com/juspay/hyperswitch-control-center/commit/b722495554ff0a5d3740fda94495610d6bb5262a))

### Miscellaneous Tasks

- Frontend Improvements ([#2802](https://github.com/juspay/hyperswitch-control-center/pull/2802)) ([`f141a66`](https://github.com/juspay/hyperswitch-control-center/commit/f141a66c953f4d4da4e71f5fd8dcf44d2aa19eeb))
- Added titles to the table instead of empty string ([#2811](https://github.com/juspay/hyperswitch-control-center/pull/2811)) ([`a242eb1`](https://github.com/juspay/hyperswitch-control-center/commit/a242eb11ad8493f5a3d8eaac4e7a65e6bb2c4813))
- Product type added in get production api payload ([#2683](https://github.com/juspay/hyperswitch-control-center/pull/2683)) ([`80113a2`](https://github.com/juspay/hyperswitch-control-center/commit/80113a24f34638365779e3571114a193dd2014aa))
- Login and signup page view count ([#2793](https://github.com/juspay/hyperswitch-control-center/pull/2793)) ([`8105d4c`](https://github.com/juspay/hyperswitch-control-center/commit/8105d4ca68d18e4c05e805ea6cf247f6c881217f))

**Full Changelog:** [`2025.04.10.0...2025.04.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.10.0...2025.04.11.0)


- - -

## 2025.04.10.0

### Bug Fixes

- Threeds app url validation ([#2795](https://github.com/juspay/hyperswitch-control-center/pull/2795)) ([`0206390`](https://github.com/juspay/hyperswitch-control-center/commit/020639081fce641472b4cbc2560c073b6b32c023))
- Profile name not showing in about payment section ([#2803](https://github.com/juspay/hyperswitch-control-center/pull/2803)) ([`d54afc9`](https://github.com/juspay/hyperswitch-control-center/commit/d54afc91b9c97c4d18e9e89e9e594c293aa26ad7))

### Miscellaneous Tasks

- Made charts responsive ([#2786](https://github.com/juspay/hyperswitch-control-center/pull/2786)) ([`5f3b144`](https://github.com/juspay/hyperswitch-control-center/commit/5f3b1447b4333ca3eec751c3090302515bfe120c))
- Show global search bar only for orchestrator ([#2801](https://github.com/juspay/hyperswitch-control-center/pull/2801)) ([`e3a5872`](https://github.com/juspay/hyperswitch-control-center/commit/e3a5872e5ab369e0095ff830d74ac7b60816ad5a))
- Recovery product name change ([#2798](https://github.com/juspay/hyperswitch-control-center/pull/2798)) ([`df5d052`](https://github.com/juspay/hyperswitch-control-center/commit/df5d052ffb0d877371b78df5cbcd8fba16c9e217))

**Full Changelog:** [`2025.04.09.0...2025.04.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.09.0...2025.04.10.0)


- - -

## 2025.04.09.0

### Bug Fixes

- Fixed vault 13 inch screen ui bugs ([#2789](https://github.com/juspay/hyperswitch-control-center/pull/2789)) ([`c4163c6`](https://github.com/juspay/hyperswitch-control-center/commit/c4163c60de43e8c0340723c6a85bd096bc6dc89b))

**Full Changelog:** [`2025.04.08.0...2025.04.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.08.0...2025.04.09.0)


- - -

## 2025.04.08.0

### Bug Fixes

- Browser console warnings ([#2729](https://github.com/juspay/hyperswitch-control-center/pull/2729)) ([`c75759c`](https://github.com/juspay/hyperswitch-control-center/commit/c75759c1605c93630222769278cb17ceb55b915b))

### Testing

- Add workflow tests ([#2773](https://github.com/juspay/hyperswitch-control-center/pull/2773)) ([`57ffe23`](https://github.com/juspay/hyperswitch-control-center/commit/57ffe23f85fa73128a1d394c0aa50accb7689641))

### Miscellaneous Tasks

- Changed label badge colours ([#2772](https://github.com/juspay/hyperswitch-control-center/pull/2772)) ([`d630b40`](https://github.com/juspay/hyperswitch-control-center/commit/d630b4021920bb8f6f102fc3032647b24eb5a751))
- Remove apm from product types ([#2783](https://github.com/juspay/hyperswitch-control-center/pull/2783)) ([`40a82fe`](https://github.com/juspay/hyperswitch-control-center/commit/40a82fe1f5f8522eec4e66fc7f3c5e6b4b8130df))
- Changed custom label cells to default label cells in modularit… ([#2784](https://github.com/juspay/hyperswitch-control-center/pull/2784)) ([`8bee012`](https://github.com/juspay/hyperswitch-control-center/commit/8bee01257765d0e9eaccea16104a4ef8cb0379bc))

**Full Changelog:** [`2025.04.07.0...2025.04.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.07.0...2025.04.08.0)


- - -

## 2025.04.07.0

### Bug Fixes

- Toast notification redesign ([#2771](https://github.com/juspay/hyperswitch-control-center/pull/2771)) ([`f7378f8`](https://github.com/juspay/hyperswitch-control-center/commit/f7378f8378790776f8f999b114b72ff8a724a0e9))
- Disabled the recon onboarding input fields ([#2776](https://github.com/juspay/hyperswitch-control-center/pull/2776)) ([`79024a9`](https://github.com/juspay/hyperswitch-control-center/commit/79024a95aba487ec104b4f256fd4e02e2db7c9fc))
- Hypersense product name change to cost observability ([#2780](https://github.com/juspay/hyperswitch-control-center/pull/2780)) ([`10ebe1f`](https://github.com/juspay/hyperswitch-control-center/commit/10ebe1f696a9d74740fb8eaba03091e05f0c1542))

### Miscellaneous Tasks

- Number type input for connector metadata ([#2770](https://github.com/juspay/hyperswitch-control-center/pull/2770)) ([`5fd329e`](https://github.com/juspay/hyperswitch-control-center/commit/5fd329e10c2f3aa0bd962bfbab01a16eba0af9b6))

**Full Changelog:** [`2025.04.04.0...2025.04.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.04.0...2025.04.07.0)


- - -

## 2025.04.04.0

### Features

- Addition of new connector - paystack ([#2306](https://github.com/juspay/hyperswitch-control-center/pull/2306)) ([`d7099ef`](https://github.com/juspay/hyperswitch-control-center/commit/d7099ef840c4f198e3adde688586dffe4508f7b0))

### Bug Fixes

- Recon ui issues in 13 inch screen ([#2767](https://github.com/juspay/hyperswitch-control-center/pull/2767)) ([`4726941`](https://github.com/juspay/hyperswitch-control-center/commit/4726941f67e7187065e2ee662ec4e700c35eafc7))
- Demo data banner issues ([#2768](https://github.com/juspay/hyperswitch-control-center/pull/2768)) ([`880dd75`](https://github.com/juspay/hyperswitch-control-center/commit/880dd75d461c4ea089891e150c769e5f3172aec7))

### Refactors

- Hyperswitch app refactor ([#2748](https://github.com/juspay/hyperswitch-control-center/pull/2748)) ([`65b9004`](https://github.com/juspay/hyperswitch-control-center/commit/65b9004512235feb2df9158a20d23160a85fbcd5))

### Miscellaneous Tasks

- Restructuring intelligent routing files ([#2758](https://github.com/juspay/hyperswitch-control-center/pull/2758)) ([`f13e1ee`](https://github.com/juspay/hyperswitch-control-center/commit/f13e1ee45f0f7a08153a925b15bb8b0682955c29))

**Full Changelog:** [`2025.04.03.1...2025.04.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.03.1...2025.04.04.0)


- - -

## 2025.04.03.1

### Miscellaneous Tasks

- Removed production access for v2 products ([#2761](https://github.com/juspay/hyperswitch-control-center/pull/2761)) ([`4a7646d`](https://github.com/juspay/hyperswitch-control-center/commit/4a7646d3bb11feb7fd82f82cd37560e1172ddb82))

**Full Changelog:** [`2025.04.03.0...2025.04.03.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.03.0...2025.04.03.1)


- - -

## 2025.04.03.0

### Features

- Debit routing toggle ([#2720](https://github.com/juspay/hyperswitch-control-center/pull/2720)) ([`71f2b87`](https://github.com/juspay/hyperswitch-control-center/commit/71f2b879b3c3aa4aa0570a2e0745792529fd2b4b))

### Miscellaneous Tasks

- Added mixpanel event whenever date dropdown is opened ([#2717](https://github.com/juspay/hyperswitch-control-center/pull/2717)) ([`0b38ec8`](https://github.com/juspay/hyperswitch-control-center/commit/0b38ec8f664fd35c88a4a2741b1b43cf106d90b7))
- Removed default allowed auth methods in google pay ([#2726](https://github.com/juspay/hyperswitch-control-center/pull/2726)) ([`a80f462`](https://github.com/juspay/hyperswitch-control-center/commit/a80f462c1806c72312c8858a674855acd98f4d92))
- Updated graph options ([#2752](https://github.com/juspay/hyperswitch-control-center/pull/2752)) ([`9a62866`](https://github.com/juspay/hyperswitch-control-center/commit/9a62866b6a605accd3558b5751548d129d154c0c))

**Full Changelog:** [`2025.04.02.0...2025.04.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.02.0...2025.04.03.0)


- - -

## 2025.04.02.0

### Bug Fixes

- Connector metadata ([#2732](https://github.com/juspay/hyperswitch-control-center/pull/2732)) ([`ae0a3c0`](https://github.com/juspay/hyperswitch-control-center/commit/ae0a3c0e0726c77a010924cefea896d96d9ea98c))

### Refactors

- Enable all feature flags by default ([#2733](https://github.com/juspay/hyperswitch-control-center/pull/2733)) ([`808dbaa`](https://github.com/juspay/hyperswitch-control-center/commit/808dbaa653cf06138d5f3ace0e3bfecff18d3ec0))

**Full Changelog:** [`2025.04.01.0...2025.04.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.04.01.0...2025.04.02.0)


- - -

## 2025.04.01.0

### Miscellaneous Tasks

- Updating graph ([#2721](https://github.com/juspay/hyperswitch-control-center/pull/2721)) ([`3981aa1`](https://github.com/juspay/hyperswitch-control-center/commit/3981aa1b3195f213b7e361a8746347de9aa5ce6b))

**Full Changelog:** [`2025.03.31.0...2025.04.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.31.0...2025.04.01.0)


- - -

## 2025.03.31.0

### Bug Fixes

- Remove resolve button after resolving ([#2714](https://github.com/juspay/hyperswitch-control-center/pull/2714)) ([`16b6510`](https://github.com/juspay/hyperswitch-control-center/commit/16b65105b32043072130a3fd45afe0e599385cdc))
- Webhook step horizontally scrollable ([#2719](https://github.com/juspay/hyperswitch-control-center/pull/2719)) ([`a3fcc6c`](https://github.com/juspay/hyperswitch-control-center/commit/a3fcc6ccd9edfac17ad3ecad1c9d94cf40efec03))

**Full Changelog:** [`2025.03.28.1...2025.03.31.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.28.1...2025.03.31.0)


- - -

## 2025.03.28.1

### Bug Fixes

- Recovery module bug fixes ([#2605](https://github.com/juspay/hyperswitch-control-center/pull/2605)) ([`0115ec5`](https://github.com/juspay/hyperswitch-control-center/commit/0115ec51847f13ca84e1929d19d0c1d83ebb114e))

### Refactors

- Profile Merchant Labels ([#2709](https://github.com/juspay/hyperswitch-control-center/pull/2709)) ([`1efc43f`](https://github.com/juspay/hyperswitch-control-center/commit/1efc43f0028889a19984a0926d98b46f67e0b155))

### Miscellaneous Tasks

- New design changes in intelligent routing ([#2707](https://github.com/juspay/hyperswitch-control-center/pull/2707)) ([`4ee6e79`](https://github.com/juspay/hyperswitch-control-center/commit/4ee6e7967ad71cb5ed1de5a25e658af7aa81679e))

**Full Changelog:** [`2025.03.28.0...2025.03.28.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.28.0...2025.03.28.1)


- - -

## 2025.03.28.0

### Features

- Nomupay connector addition ([#2704](https://github.com/juspay/hyperswitch-control-center/pull/2704)) ([`36068b3`](https://github.com/juspay/hyperswitch-control-center/commit/36068b30d09be062e45f479fe5f1104a22986441))

### Bug Fixes

- Render glitch of total customers and total token component ([#2711](https://github.com/juspay/hyperswitch-control-center/pull/2711)) ([`324bdeb`](https://github.com/juspay/hyperswitch-control-center/commit/324bdeb7cbe124872cad5e3e198cff1df59fbc9c))

### Testing

- Add workflow tests ([#2648](https://github.com/juspay/hyperswitch-control-center/pull/2648)) ([`ec88511`](https://github.com/juspay/hyperswitch-control-center/commit/ec88511ff7b22d1fbfc82ca4aac8db7530fe63a4))

**Full Changelog:** [`2025.03.27.0...2025.03.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.27.0...2025.03.28.0)


- - -

## 2025.03.27.0

### Bug Fixes

- Icon name fix ([#2699](https://github.com/juspay/hyperswitch-control-center/pull/2699)) ([`23415dc`](https://github.com/juspay/hyperswitch-control-center/commit/23415dcc4b783682cf4f1800c437767ae66e3ac6))
- Close icon on merchant select modal ([#2696](https://github.com/juspay/hyperswitch-control-center/pull/2696)) ([`489641a`](https://github.com/juspay/hyperswitch-control-center/commit/489641a2cdd300ab34951d09ff4d2bd9932e6795))
- Fixed vault bugs ([#2701](https://github.com/juspay/hyperswitch-control-center/pull/2701)) ([`8125392`](https://github.com/juspay/hyperswitch-control-center/commit/8125392936cdf61bc2c8cc171cf1ddc75ba9aaaf))

### Miscellaneous Tasks

- Recovery ui changes ([#2645](https://github.com/juspay/hyperswitch-control-center/pull/2645)) ([`d06efc8`](https://github.com/juspay/hyperswitch-control-center/commit/d06efc8e1f46e23a17d7c423e021013c96887260))
- Added scrollbar in vault tables ([#2703](https://github.com/juspay/hyperswitch-control-center/pull/2703)) ([`8e31612`](https://github.com/juspay/hyperswitch-control-center/commit/8e316120d9d1e02c012eb82d2e8e40508772980e))

**Full Changelog:** [`2025.03.26.1...2025.03.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.26.1...2025.03.27.0)


- - -

## 2025.03.26.1

### Bug Fixes

- PCI high severity issue ([#2676](https://github.com/juspay/hyperswitch-control-center/pull/2676)) ([`3fc8ed2`](https://github.com/juspay/hyperswitch-control-center/commit/3fc8ed22b624e519727f7fa7467ae60a47d2d119))
- Hyperloader reinitialisation ([#2693](https://github.com/juspay/hyperswitch-control-center/pull/2693)) ([`30b60db`](https://github.com/juspay/hyperswitch-control-center/commit/30b60db0701454dec45f5797d62312b657694341))

### Miscellaneous Tasks

- Add mixpanel for recon analytics ([#2691](https://github.com/juspay/hyperswitch-control-center/pull/2691)) ([`b452d5c`](https://github.com/juspay/hyperswitch-control-center/commit/b452d5c17c4ad3db4908ad610625c4763617fd47))

**Full Changelog:** [`2025.03.26.0...2025.03.26.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.26.0...2025.03.26.1)


- - -

## 2025.03.26.0

### Features

- Fetching recon reports from s3 ([#2670](https://github.com/juspay/hyperswitch-control-center/pull/2670)) ([`209308e`](https://github.com/juspay/hyperswitch-control-center/commit/209308ef1374d7cf80cffba2b6fc28f2ef447001))
- Duplicate and edit configuration for rule based routing ([#2631](https://github.com/juspay/hyperswitch-control-center/pull/2631)) ([`b62f449`](https://github.com/juspay/hyperswitch-control-center/commit/b62f4496a30f2bf0cf7e36ed96718dd8ba98a11b))
- Added scarf platform in dashboard ([#2684](https://github.com/juspay/hyperswitch-control-center/pull/2684)) ([`4786928`](https://github.com/juspay/hyperswitch-control-center/commit/47869281849e62b26a8e5faf284bd3578bf4489e))
- Recovery dummy data flow ([#2638](https://github.com/juspay/hyperswitch-control-center/pull/2638)) ([`33f55d3`](https://github.com/juspay/hyperswitch-control-center/commit/33f55d3ab25df83ca3028444778a2118e64bb88b))

### Bug Fixes

- Payout routing default fallback connector label ([#2677](https://github.com/juspay/hyperswitch-control-center/pull/2677)) ([`00e9dac`](https://github.com/juspay/hyperswitch-control-center/commit/00e9dac297aac24d51d190f6f1516ec138a03071))
- Sticky vertical step indicator in onboarding ([#2678](https://github.com/juspay/hyperswitch-control-center/pull/2678)) ([`dc770b2`](https://github.com/juspay/hyperswitch-control-center/commit/dc770b26a7ceca76e7161f729cbc7dc75ffa34f8))
- Switching merchants in modularity products ([#2682](https://github.com/juspay/hyperswitch-control-center/pull/2682)) ([`c564fbc`](https://github.com/juspay/hyperswitch-control-center/commit/c564fbc90bf049f45b6cc7df0cf5828af1f54f8b))
- Rule based routing month issue in description ([#2681](https://github.com/juspay/hyperswitch-control-center/pull/2681)) ([`320f339`](https://github.com/juspay/hyperswitch-control-center/commit/320f339fbef66d501ca37844abc3ebf8614f9c4c))
- Recon ui changes and processor validation ([#2688](https://github.com/juspay/hyperswitch-control-center/pull/2688)) ([`a197d99`](https://github.com/juspay/hyperswitch-control-center/commit/a197d991065fc77851fd068ba12c9020d839fef4))

### Miscellaneous Tasks

- Enabled only credit and debit payment methods for vault ([#2674](https://github.com/juspay/hyperswitch-control-center/pull/2674)) ([`b914184`](https://github.com/juspay/hyperswitch-control-center/commit/b914184021e52c2d822446411a10192cfd6c62d1))
- UI enhancements intelligent routing ([#2669](https://github.com/juspay/hyperswitch-control-center/pull/2669)) ([`0b2fee5`](https://github.com/juspay/hyperswitch-control-center/commit/0b2fee54bc1e42dacc424f3993effd385a52ad6e))
- Vault minor ui changes ([#2680](https://github.com/juspay/hyperswitch-control-center/pull/2680)) ([`39fad85`](https://github.com/juspay/hyperswitch-control-center/commit/39fad8548ed6425e530b2b92b0576faeefc39cf3))

**Full Changelog:** [`2025.03.24.2...2025.03.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.24.2...2025.03.26.0)


- - -

## 2025.03.24.2

### Features

- HiPay Connector addition ([#2661](https://github.com/juspay/hyperswitch-control-center/pull/2661)) ([`c491938`](https://github.com/juspay/hyperswitch-control-center/commit/c491938ee3397125203f34022cec73a8087c8894))

### Bug Fixes

- Analytics insights breaking fix ([#2672](https://github.com/juspay/hyperswitch-control-center/pull/2672)) ([`1c77c3d`](https://github.com/juspay/hyperswitch-control-center/commit/1c77c3d3a038409fbf2d55fda26b0ff7b8f8996f))

### Refactors

- Recon ui changes in analytics ([#2664](https://github.com/juspay/hyperswitch-control-center/pull/2664)) ([`bfc1182`](https://github.com/juspay/hyperswitch-control-center/commit/bfc118268f897bd0018467caa30f6b9746f040d5))

### Miscellaneous Tasks

- Remove profile level report - auth analytics ([#2633](https://github.com/juspay/hyperswitch-control-center/pull/2633)) ([`a45d922`](https://github.com/juspay/hyperswitch-control-center/commit/a45d922793cfa8986ce569c1314afc7f3ba28b01))

**Full Changelog:** [`2025.03.24.1...2025.03.24.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.24.1...2025.03.24.2)


- - -

## 2025.03.24.1

### Features

- Added new connector redsys ([#2658](https://github.com/juspay/hyperswitch-control-center/pull/2658)) ([`eb29310`](https://github.com/juspay/hyperswitch-control-center/commit/eb2931079d1ef39fe2dbd62c8cd41ef24e2cf9af))
- Wasm update for redsys ([#2659](https://github.com/juspay/hyperswitch-control-center/pull/2659)) ([`4465a60`](https://github.com/juspay/hyperswitch-control-center/commit/4465a60ac1a105928c23166edbbf888bc5ddfe1d))
- Added threeds requestor app url in payment settings ([#2650](https://github.com/juspay/hyperswitch-control-center/pull/2650)) ([`9b76b1d`](https://github.com/juspay/hyperswitch-control-center/commit/9b76b1d42581860de6d8f696117f5463b7154457))

### Bug Fixes

- Logo aspect ratio ([#2655](https://github.com/juspay/hyperswitch-control-center/pull/2655)) ([`3625158`](https://github.com/juspay/hyperswitch-control-center/commit/3625158ff53e48623cceb77c428526f40b798883))
- Default home changes ([#2657](https://github.com/juspay/hyperswitch-control-center/pull/2657)) ([`824b0dc`](https://github.com/juspay/hyperswitch-control-center/commit/824b0dc31a7bcd5bb32afddfc91126a1b9ffe567))

**Full Changelog:** [`2025.03.24.0...2025.03.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.24.0...2025.03.24.1)


- - -

## 2025.03.24.0

### Features

- Added checkbox for allowed auth methods in google pay ([#2359](https://github.com/juspay/hyperswitch-control-center/pull/2359)) ([`3c5c123`](https://github.com/juspay/hyperswitch-control-center/commit/3c5c1231cd27ace0caa4415e9f6006f9b3d14cda))

### Bug Fixes

- Removed actions, text changes, date changes ([#2641](https://github.com/juspay/hyperswitch-control-center/pull/2641)) ([`09442a8`](https://github.com/juspay/hyperswitch-control-center/commit/09442a854cdb9c2e78d7ada6e7bd638c14c113c6))
- Switch url redirection issue ([#2640](https://github.com/juspay/hyperswitch-control-center/pull/2640)) ([`e0ce9c5`](https://github.com/juspay/hyperswitch-control-center/commit/e0ce9c5ea5d7ee3fc042f1c3c616499ed1a0ebbd))

### Miscellaneous Tasks

- Billing connector metadata update ([#2606](https://github.com/juspay/hyperswitch-control-center/pull/2606)) ([`5c06c88`](https://github.com/juspay/hyperswitch-control-center/commit/5c06c8830e574658e7f1ef35a21f906bc996bff2))
- Configure retry tooltip text ([#2629](https://github.com/juspay/hyperswitch-control-center/pull/2629)) ([`aad4793`](https://github.com/juspay/hyperswitch-control-center/commit/aad47932600bf2e7fe1c94b3aabbae721c28b0f3))
- Added general mixpanel events ([#2607](https://github.com/juspay/hyperswitch-control-center/pull/2607)) ([`26d2d33`](https://github.com/juspay/hyperswitch-control-center/commit/26d2d33d8d0edac881938eb9678a1f11da0a3eb9))
- Made chargebee webhooks details field as required ([#2643](https://github.com/juspay/hyperswitch-control-center/pull/2643)) ([`2f9f344`](https://github.com/juspay/hyperswitch-control-center/commit/2f9f34480173c35882588d1c85886b1e6f43eb0b))
- Vault ui changes ([#2637](https://github.com/juspay/hyperswitch-control-center/pull/2637)) ([`3660da7`](https://github.com/juspay/hyperswitch-control-center/commit/3660da7d3ef883a1b3368ad07308630696f9a265))

**Full Changelog:** [`2025.03.21.0...2025.03.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.21.0...2025.03.24.0)


- - -

## 2025.03.21.0

### Miscellaneous Tasks

- Custom date style cell ([#2630](https://github.com/juspay/hyperswitch-control-center/pull/2630)) ([`18ffb71`](https://github.com/juspay/hyperswitch-control-center/commit/18ffb71e08380b6b370467bc56eab17cfb00a74e))

**Full Changelog:** [`2025.03.20.0...2025.03.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.20.0...2025.03.21.0)


- - -

## 2025.03.20.0

### Bug Fixes

- Operations external url ([#2585](https://github.com/juspay/hyperswitch-control-center/pull/2585)) ([`5adcbaa`](https://github.com/juspay/hyperswitch-control-center/commit/5adcbaaba8496eacdb54765dcdddd20dd9432c40))

### Miscellaneous Tasks

- Product type sidebar update on org switch ([#2505](https://github.com/juspay/hyperswitch-control-center/pull/2505)) ([`71247c9`](https://github.com/juspay/hyperswitch-control-center/commit/71247c97eb84a73f46046a7269bc37fa009f18d9))

**Full Changelog:** [`2025.03.19.1...2025.03.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.19.1...2025.03.20.0)


- - -

## 2025.03.19.1

### Features

- Added issuer filter - auth analytics ([#2577](https://github.com/juspay/hyperswitch-control-center/pull/2577)) ([`25e7e98`](https://github.com/juspay/hyperswitch-control-center/commit/25e7e981b8c6d2b83b1aae12834fb966ae5db8f9))

### Bug Fixes

- Show edit and copy icon in MP dropdowns mobile ([#2515](https://github.com/juspay/hyperswitch-control-center/pull/2515)) ([`83dfe5a`](https://github.com/juspay/hyperswitch-control-center/commit/83dfe5a9ba5401e73ddfcff7ae2e6f6a6d2d15f4))

### Miscellaneous Tasks

- Routing minor ui fixes ([#2535](https://github.com/juspay/hyperswitch-control-center/pull/2535)) ([`409a842`](https://github.com/juspay/hyperswitch-control-center/commit/409a842b3467e440047cb02acb02fbbbed5c54d9))

**Full Changelog:** [`2025.03.19.0...2025.03.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.19.0...2025.03.19.1)


- - -

## 2025.03.19.0

### Bug Fixes

- Connector list not updated on profile switch fix ([#2519](https://github.com/juspay/hyperswitch-control-center/pull/2519)) ([`6b0648e`](https://github.com/juspay/hyperswitch-control-center/commit/6b0648e102c7e3bcf6eef38f117f622ef705ad54))

**Full Changelog:** [`2025.03.18.1...2025.03.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.18.1...2025.03.19.0)


- - -

## 2025.03.18.1

### Bug Fixes

- Resolved issues when applying filters ([#2511](https://github.com/juspay/hyperswitch-control-center/pull/2511)) ([`1838845`](https://github.com/juspay/hyperswitch-control-center/commit/1838845e8fb233e3b56bf5bf7de4ad4924e9dc4a))
- Recon tabs and mixpanel event changes ([#2502](https://github.com/juspay/hyperswitch-control-center/pull/2502)) ([`c5619f1`](https://github.com/juspay/hyperswitch-control-center/commit/c5619f1a94d6322e51fa722e0d2a0072c37b96ee))

### Refactors

- Add constraints in smart routing rule configuration ([#2466](https://github.com/juspay/hyperswitch-control-center/pull/2466)) ([`825be17`](https://github.com/juspay/hyperswitch-control-center/commit/825be17fd322213b5f0aa018db186e75c8074a6d))

### Miscellaneous Tasks

- Changed links in vault config page ([#2516](https://github.com/juspay/hyperswitch-control-center/pull/2516)) ([`630822b`](https://github.com/juspay/hyperswitch-control-center/commit/630822be8f7615e40fd29115326be41c2d992df0))

**Full Changelog:** [`2025.03.18.0...2025.03.18.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.18.0...2025.03.18.1)


- - -

## 2025.03.18.0

### Bug Fixes

- Metrics - frictionless flow count ([#2504](https://github.com/juspay/hyperswitch-control-center/pull/2504)) ([`d906152`](https://github.com/juspay/hyperswitch-control-center/commit/d9061527dfc3762fabedcc887529522111c36ea4))
- Ui issue for insights ([#2510](https://github.com/juspay/hyperswitch-control-center/pull/2510)) ([`216618a`](https://github.com/juspay/hyperswitch-control-center/commit/216618a0f0d6f02af69ad7a26c3becec425515ad))

### Miscellaneous Tasks

- Remove tax identification number field from get production acc… ([#2507](https://github.com/juspay/hyperswitch-control-center/pull/2507)) ([`33045a3`](https://github.com/juspay/hyperswitch-control-center/commit/33045a399ad7850e7443e9b1a0b713a2a40e560d))

**Full Changelog:** [`2025.03.17.0...2025.03.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.17.0...2025.03.18.0)


- - -

## 2025.03.17.0

### Bug Fixes

- Dropdown issues in payment processors ([#2347](https://github.com/juspay/hyperswitch-control-center/pull/2347)) ([`2372d34`](https://github.com/juspay/hyperswitch-control-center/commit/2372d345f8c400018c0c7634cd700eade5f63ae8))
- Payout processor unknown issue ([#2497](https://github.com/juspay/hyperswitch-control-center/pull/2497)) ([`de16a25`](https://github.com/juspay/hyperswitch-control-center/commit/de16a252c4e52c40a03acb2cedabf70c9b534dd7))

### Miscellaneous Tasks

- Routing minor ui fixes ([#2492](https://github.com/juspay/hyperswitch-control-center/pull/2492)) ([`53663bb`](https://github.com/juspay/hyperswitch-control-center/commit/53663bb8c87f5f48381b76bf717d0ddfd85a2e0b))

**Full Changelog:** [`2025.03.13.4...2025.03.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.13.4...2025.03.17.0)


- - -

## 2025.03.13.4

### Miscellaneous Tasks

- Fix dynamic routing url ([`767805d`](https://github.com/juspay/hyperswitch-control-center/commit/767805dd2d8988f0c349e3d6fdbbe6855c393f6b))

**Full Changelog:** [`2025.03.13.3...2025.03.13.4`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.13.3...2025.03.13.4)

- - -

## 2025.03.13.3

### Bug Fixes

- Modularity fixes ([#2490](https://github.com/juspay/hyperswitch-control-center/pull/2490)) ([`b05d7c1`](https://github.com/juspay/hyperswitch-control-center/commit/b05d7c1082d9b01eb108c4e89d0acfaf2248856e))

### Miscellaneous Tasks

- Vault mixpanel events ([#2488](https://github.com/juspay/hyperswitch-control-center/pull/2488)) ([`b8f1954`](https://github.com/juspay/hyperswitch-control-center/commit/b8f1954263875bd7434fe222cfa3cbcb37409590))

**Full Changelog:** [`2025.03.13.2...2025.03.13.3`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.13.2...2025.03.13.3)


- - -

## 2025.03.13.2

### Bug Fixes

- Added acl for get started in product home ([#2477](https://github.com/juspay/hyperswitch-control-center/pull/2477)) ([`fc8868a`](https://github.com/juspay/hyperswitch-control-center/commit/fc8868a9dab737bd4855f2aa20b972d5a209526a))
- Added acl changes ([#2485](https://github.com/juspay/hyperswitch-control-center/pull/2485)) ([`b1a40d0`](https://github.com/juspay/hyperswitch-control-center/commit/b1a40d045495178cb95d03332f7f1184e9257c68))

### Miscellaneous Tasks

- Updated intelligent routing image ([#2481](https://github.com/juspay/hyperswitch-control-center/pull/2481)) ([`41236d6`](https://github.com/juspay/hyperswitch-control-center/commit/41236d6cef00d547d7c107e6917e881cf9d5581f))
- Recon mixpanel events ([#2471](https://github.com/juspay/hyperswitch-control-center/pull/2471)) ([`6ae6898`](https://github.com/juspay/hyperswitch-control-center/commit/6ae6898a956013927bdbf9605ca19c87e1e06df7))
- Api headers change for Dynamic Routing (Intelligent Routing) (Modularity) ([#2473](https://github.com/juspay/hyperswitch-control-center/pull/2473)) ([`6295490`](https://github.com/juspay/hyperswitch-control-center/commit/6295490cd98f2a075029c66c7b9eef08fa3a3532))
- Enable apis for routing ([#2479](https://github.com/juspay/hyperswitch-control-center/pull/2479)) ([`ffe4951`](https://github.com/juspay/hyperswitch-control-center/commit/ffe49518cb347d7c46277ff401825295edb56e6f))
- Intelligent routing mixpanel events ([#2484](https://github.com/juspay/hyperswitch-control-center/pull/2484)) ([`72248f2`](https://github.com/juspay/hyperswitch-control-center/commit/72248f2ffa782160054bb85664fa6e0292da4632))

**Full Changelog:** [`2025.03.13.1...2025.03.13.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.13.1...2025.03.13.2)


- - -

## 2025.03.13.1

### Features

- Generate sample report data functionality for vault ([#2411](https://github.com/juspay/hyperswitch-control-center/pull/2411)) ([`caa973e`](https://github.com/juspay/hyperswitch-control-center/commit/caa973eaa519517266e632828a919f3d6cc4c74f))

### Bug Fixes

- Connector name - unknown issue ([#2453](https://github.com/juspay/hyperswitch-control-center/pull/2453)) ([`5b373d3`](https://github.com/juspay/hyperswitch-control-center/commit/5b373d3f6fe92db3a9fe69af50eb38d6086a7dd0))
- Column graph tooltip formatter listing ([#2443](https://github.com/juspay/hyperswitch-control-center/pull/2443)) ([`c8af9b4`](https://github.com/juspay/hyperswitch-control-center/commit/c8af9b40e86ea0b072d0eaac8990b6475e3b6bfc))
- Sort issue of insights ([#2463](https://github.com/juspay/hyperswitch-control-center/pull/2463)) ([`17ff375`](https://github.com/juspay/hyperswitch-control-center/commit/17ff375e5fa2263a1a515075dc6439730732a1ea))
- Vault product minor fixes ([#2434](https://github.com/juspay/hyperswitch-control-center/pull/2434)) ([`e60ef39`](https://github.com/juspay/hyperswitch-control-center/commit/e60ef39c16abc2aef3f98ad2e707ef21193af5cb))
- Vault landing and connector api call changes ([#2467](https://github.com/juspay/hyperswitch-control-center/pull/2467)) ([`2a2ff64`](https://github.com/juspay/hyperswitch-control-center/commit/2a2ff64ccb9915db98aa48a6fd1fe571f774fcc2))
- Merchant switch home page fix ([#2474](https://github.com/juspay/hyperswitch-control-center/pull/2474)) ([`1761197`](https://github.com/juspay/hyperswitch-control-center/commit/1761197265e2cef16a67abf5c27ea6be814d0068))

### Miscellaneous Tasks

- Routing enhancements and api changes ([#2445](https://github.com/juspay/hyperswitch-control-center/pull/2445)) ([`4886bdf`](https://github.com/juspay/hyperswitch-control-center/commit/4886bdf53442c41f061d529087e04244c9f2b88f))
- Recovery token testing fixes ([#2464](https://github.com/juspay/hyperswitch-control-center/pull/2464)) ([`95b990b`](https://github.com/juspay/hyperswitch-control-center/commit/95b990b57b3d4d4277e44cff90a48ff57793498c))
- Get production access ([#2469](https://github.com/juspay/hyperswitch-control-center/pull/2469)) ([`6986068`](https://github.com/juspay/hyperswitch-control-center/commit/698606804e219c2b7049043146702f5a97801262))

### Revert

- Connector name - unknown issue ([#2461](https://github.com/juspay/hyperswitch-control-center/pull/2461)) ([`6252628`](https://github.com/juspay/hyperswitch-control-center/commit/62526283afbd536d89ca5caee4574ce3425a6a01))

**Full Changelog:** [`2025.03.13.0...2025.03.13.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.13.0...2025.03.13.1)


- - -

## 2025.03.13.0

### Features

- Recovery overview screen update and filters added ([#2435](https://github.com/juspay/hyperswitch-control-center/pull/2435)) ([`197ad9a`](https://github.com/juspay/hyperswitch-control-center/commit/197ad9a298ed2174ba606da6db70d2e7aa5b718a))

### Bug Fixes

- Add v1 - authentication analytics ([#2440](https://github.com/juspay/hyperswitch-control-center/pull/2440)) ([`2b4310e`](https://github.com/juspay/hyperswitch-control-center/commit/2b4310ed9cad6584717aa046269e8b9a272dcd43))
- Smart routing values fix ([#2439](https://github.com/juspay/hyperswitch-control-center/pull/2439)) ([`5b97ebd`](https://github.com/juspay/hyperswitch-control-center/commit/5b97ebd4ca8eea92f5b1f5f2fdf3e575f9f4b814))

### Miscellaneous Tasks

- Added v2 merchant switch apis ([#2426](https://github.com/juspay/hyperswitch-control-center/pull/2426)) ([`ff63005`](https://github.com/juspay/hyperswitch-control-center/commit/ff630053cca84ef162d5a178a3be4b71ee2a4481))
- Routing setup flow changes ([#2430](https://github.com/juspay/hyperswitch-control-center/pull/2430)) ([`38bedfe`](https://github.com/juspay/hyperswitch-control-center/commit/38bedfe4f6272c743bd0555337db5d140768b36d))
- Recovery copy changes ([#2437](https://github.com/juspay/hyperswitch-control-center/pull/2437)) ([`ba0f656`](https://github.com/juspay/hyperswitch-control-center/commit/ba0f6564e39bd4ab296b243d5f08a1b525bf8598))
- Disabled profile creation for v2 merchants ([#2441](https://github.com/juspay/hyperswitch-control-center/pull/2441)) ([`557d25e`](https://github.com/juspay/hyperswitch-control-center/commit/557d25ec1d7cad10b4d76172972874e063d53dc8))

**Full Changelog:** [`2025.03.12.1...2025.03.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.12.1...2025.03.13.0)


- - -

## 2025.03.12.1

### Features

- Recovery connector ui update ([#2422](https://github.com/juspay/hyperswitch-control-center/pull/2422)) ([`e927343`](https://github.com/juspay/hyperswitch-control-center/commit/e9273436a67a31bf396bce9c03c1c9426557ec86))
- Add generate reports for auth analytics ([#2433](https://github.com/juspay/hyperswitch-control-center/pull/2433)) ([`8871c32`](https://github.com/juspay/hyperswitch-control-center/commit/8871c327c71393e759f1773695010a91723bae4f))

### Miscellaneous Tasks

- APM screen for orchestrator ([#2415](https://github.com/juspay/hyperswitch-control-center/pull/2415)) ([`90819ee`](https://github.com/juspay/hyperswitch-control-center/commit/90819eed32591c0e9aa84b4d784a75b92d748e55))
- Routing design updates for ui ([#2424](https://github.com/juspay/hyperswitch-control-center/pull/2424)) ([`66c2972`](https://github.com/juspay/hyperswitch-control-center/commit/66c2972d1f2eb611492a52375c95780b486740de))

**Full Changelog:** [`2025.03.12.0...2025.03.12.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.12.0...2025.03.12.1)


- - -

## 2025.03.12.0

### Features

- Routing transaction count with auth rate graph ([#2420](https://github.com/juspay/hyperswitch-control-center/pull/2420)) ([`5ff9ecf`](https://github.com/juspay/hyperswitch-control-center/commit/5ff9ecfa4c72ca2592c73eb203e4bc1e991d9232))

### Miscellaneous Tasks

- Intelligent Routing Graphs ([#2412](https://github.com/juspay/hyperswitch-control-center/pull/2412)) ([`89f79fc`](https://github.com/juspay/hyperswitch-control-center/commit/89f79fc015d4b09a9410bafe48c0cd9fd29b0da9))
- Added version in user info ([#2414](https://github.com/juspay/hyperswitch-control-center/pull/2414)) ([`1043695`](https://github.com/juspay/hyperswitch-control-center/commit/10436954bb343c07d1f8e880a872ae7b60b7c3ed))
- Added v2 merchant creation and listing ([#2419](https://github.com/juspay/hyperswitch-control-center/pull/2419)) ([`7c037e6`](https://github.com/juspay/hyperswitch-control-center/commit/7c037e61ad0e4b41567fcf58e746b74e003f6868))

**Full Changelog:** [`2025.03.11.1...2025.03.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.11.1...2025.03.12.0)


- - -

## 2025.03.11.1

### Features

- Added filters in the authentication analytics ([#2404](https://github.com/juspay/hyperswitch-control-center/pull/2404)) ([`177fe57`](https://github.com/juspay/hyperswitch-control-center/commit/177fe57b0846a591ac6b8d73ff44012b2d6073d4))

### Bug Fixes

- Custom orchestrator navigation ([#2410](https://github.com/juspay/hyperswitch-control-center/pull/2410)) ([`551e01f`](https://github.com/juspay/hyperswitch-control-center/commit/551e01f7a440e195b984b6b7d6c477a8c19a2d16))

### Miscellaneous Tasks

- Vault customers and tokens api integration ([#2355](https://github.com/juspay/hyperswitch-control-center/pull/2355)) ([`a083a31`](https://github.com/juspay/hyperswitch-control-center/commit/a083a312d969d0b184895c54cad72dfae294c569))
- Additional tracking events ([#2397](https://github.com/juspay/hyperswitch-control-center/pull/2397)) ([`dd866d1`](https://github.com/juspay/hyperswitch-control-center/commit/dd866d11d6d4b5585831f179892b404366063764))
- Add product type in create merchant ([#2406](https://github.com/juspay/hyperswitch-control-center/pull/2406)) ([`e06ed1b`](https://github.com/juspay/hyperswitch-control-center/commit/e06ed1bc66886acec7263f5b770b28c387b2c087))

**Full Changelog:** [`2025.03.11.0...2025.03.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.11.0...2025.03.11.1)

- - -

## 2025.03.11.0

### Bug Fixes

- Advanced routing responsiveness ([#2400](https://github.com/juspay/hyperswitch-control-center/pull/2400)) ([`ed184a2`](https://github.com/juspay/hyperswitch-control-center/commit/ed184a20ee41c556cf888eec76ad7f551cc4c0f8))
- Key field not updating when changed in custom metadata headers ([#2393](https://github.com/juspay/hyperswitch-control-center/pull/2393)) ([`0c1ecd2`](https://github.com/juspay/hyperswitch-control-center/commit/0c1ecd2e14a8a6ed39311d06893ec0e251b988f4))

### Miscellaneous Tasks

- Intelligent routing transaction table ([#2401](https://github.com/juspay/hyperswitch-control-center/pull/2401)) ([`23ecaaa`](https://github.com/juspay/hyperswitch-control-center/commit/23ecaaafa5aa334c10b52d8863cc6eae68cc63a8))

**Full Changelog:** [`2025.03.07.3...2025.03.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.07.3...2025.03.11.0)


- - -

## 2025.03.07.3

### Features

- Analytics authentication insights ([#2390](https://github.com/juspay/hyperswitch-control-center/pull/2390)) ([`6f6a8eb`](https://github.com/juspay/hyperswitch-control-center/commit/6f6a8eb404a812145a062bb81684e1993cdeb28d))

### Bug Fixes

- Hypersense svg rendering on the home page ([#2391](https://github.com/juspay/hyperswitch-control-center/pull/2391)) ([`5ad0f80`](https://github.com/juspay/hyperswitch-control-center/commit/5ad0f80d50afe6362cfe5c84d30ab3dcf2a21a91))
- Changed metrics calculations ([#2395](https://github.com/juspay/hyperswitch-control-center/pull/2395)) ([`3e80641`](https://github.com/juspay/hyperswitch-control-center/commit/3e8064119b9c2b928f1777049e3f899ad359489b))

### Miscellaneous Tasks

- Intelligent routing ([#2379](https://github.com/juspay/hyperswitch-control-center/pull/2379)) ([`4ac7a4d`](https://github.com/juspay/hyperswitch-control-center/commit/4ac7a4dd7cc60a4934e27aabea7cc91f0fc11b9c))

**Full Changelog:** [`2025.03.07.2...2025.03.07.3`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.07.2...2025.03.07.3)


- - -

## 2025.03.07.2

### Features

- Authentication analytics page ([#2389](https://github.com/juspay/hyperswitch-control-center/pull/2389)) ([`a0365f2`](https://github.com/juspay/hyperswitch-control-center/commit/a0365f268b74e6f0c81d095c35f5b0f6f9ccf223))

**Full Changelog:** [`2025.03.07.1...2025.03.07.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.07.1...2025.03.07.2)


- - -

## 2025.03.07.1

### Features

- Add juspaythreeds connector addition ([#2387](https://github.com/juspay/hyperswitch-control-center/pull/2387)) ([`7b76584`](https://github.com/juspay/hyperswitch-control-center/commit/7b76584a3ce956d800fb9dd4abba1d0e249891b9))

**Full Changelog:** [`2025.03.07.0...2025.03.07.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.07.0...2025.03.07.1)


- - -

## 2025.03.07.0

### Features

- Apm onboarding page ([#2374](https://github.com/juspay/hyperswitch-control-center/pull/2374)) ([`59210cc`](https://github.com/juspay/hyperswitch-control-center/commit/59210ccb650b4af60e663a7223ca42ae7a63e044))

### Bug Fixes

- Frm connector list bug fix ([#2383](https://github.com/juspay/hyperswitch-control-center/pull/2383)) ([`a8ad21d`](https://github.com/juspay/hyperswitch-control-center/commit/a8ad21d00fe3e55d45fb202172f996e1bd09bf9d))

**Full Changelog:** [`2025.03.06.1...2025.03.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.06.1...2025.03.07.0)


- - -

## 2025.03.06.1

### Features

- Add force 3ds challenge ([#2381](https://github.com/juspay/hyperswitch-control-center/pull/2381)) ([`4941adb`](https://github.com/juspay/hyperswitch-control-center/commit/4941adbf70a576eef4e67452ae8f8c0a98c4986e))

### Miscellaneous Tasks

- Authentication analytics revamp ([#2377](https://github.com/juspay/hyperswitch-control-center/pull/2377)) ([`f7253de`](https://github.com/juspay/hyperswitch-control-center/commit/f7253de3332f30a184a8075de16b4cf1394a9f12))

**Full Changelog:** [`2025.03.06.0...2025.03.06.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.06.0...2025.03.06.1)


- - -

## 2025.03.06.0

### Features

- Recon screens v2 ([#2299](https://github.com/juspay/hyperswitch-control-center/pull/2299)) ([`ed8f8a8`](https://github.com/juspay/hyperswitch-control-center/commit/ed8f8a8c77c25d284011073606188a88610c24a4))
- Added new connector Moneris ([#2373](https://github.com/juspay/hyperswitch-control-center/pull/2373)) ([`ef993d4`](https://github.com/juspay/hyperswitch-control-center/commit/ef993d473f9e56aa41c20f1f9890377b01734553))
- Hypersense product ([#2362](https://github.com/juspay/hyperswitch-control-center/pull/2362)) ([`b4a1ebb`](https://github.com/juspay/hyperswitch-control-center/commit/b4a1ebbb55218a0aa959a72fcf68920cc34d8b1d))

### Bug Fixes

- Fraud and risk connector list bug fix ([#2364](https://github.com/juspay/hyperswitch-control-center/pull/2364)) ([`cd62e4f`](https://github.com/juspay/hyperswitch-control-center/commit/cd62e4fcb513ae76d0882f7058b8b55d39f00a5f))

### Refactors

- Moved recon app, screens, container into Recon folder ([#2366](https://github.com/juspay/hyperswitch-control-center/pull/2366)) ([`5da8e94`](https://github.com/juspay/hyperswitch-control-center/commit/5da8e941c297545d018e357d9a5181a333ed7aa3))

### Miscellaneous Tasks

- Update wallet additional details for v2 ([#2356](https://github.com/juspay/hyperswitch-control-center/pull/2356)) ([`651d557`](https://github.com/juspay/hyperswitch-control-center/commit/651d557769225b70a73ebcfc3793101cb7a7be16))
- Connector api integration for vault ([#2369](https://github.com/juspay/hyperswitch-control-center/pull/2369)) ([`1d45e1c`](https://github.com/juspay/hyperswitch-control-center/commit/1d45e1c07120da8f35f3a4499eebaaedf6c571d6))
- Change recon ([`564aa0c`](https://github.com/juspay/hyperswitch-control-center/commit/564aa0c90976e67f24e5edf9d349123e631af587))
- Rename the recon folders ([`4547637`](https://github.com/juspay/hyperswitch-control-center/commit/45476378f1219fd4cd792b2d8cd47e223388cfa8))

**Full Changelog:** [`2025.03.05.0...2025.03.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.05.0...2025.03.06.0)


- - -

## 2025.03.05.0

### Features

- Recovery onboarding flow ([#2329](https://github.com/juspay/hyperswitch-control-center/pull/2329)) ([`6b8b3cd`](https://github.com/juspay/hyperswitch-control-center/commit/6b8b3cd028f5c57d5778451f26e252095f237bd9))
- Added custom metadata fields in payment settings ([#2352](https://github.com/juspay/hyperswitch-control-center/pull/2352)) ([`c2b9973`](https://github.com/juspay/hyperswitch-control-center/commit/c2b9973875c17d6a65241705a5bce6b20658db6b))

### Bug Fixes

- Overflow profile in SDK checkout page ([#2351](https://github.com/juspay/hyperswitch-control-center/pull/2351)) ([`2f0abbb`](https://github.com/juspay/hyperswitch-control-center/commit/2f0abbb3165eadae170b241f8da829a1049ba692))

### Testing

- Update cypress tests ([#2343](https://github.com/juspay/hyperswitch-control-center/pull/2343)) ([`13e0732`](https://github.com/juspay/hyperswitch-control-center/commit/13e0732d94b83879fe93470fc3d974b9295bfbe3))

### Miscellaneous Tasks

- UI changes for vault ([#2353](https://github.com/juspay/hyperswitch-control-center/pull/2353)) ([`0957fa2`](https://github.com/juspay/hyperswitch-control-center/commit/0957fa22d4a4a963d6efe8aa49848637ce2541f4))
- Changed custom headers UI ([#2357](https://github.com/juspay/hyperswitch-control-center/pull/2357)) ([`7eb492d`](https://github.com/juspay/hyperswitch-control-center/commit/7eb492ddc0cdd5c7ae352cfa2d41a31a3b2e74ab))

**Full Changelog:** [`2025.03.04.0...2025.03.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.03.04.0...2025.03.05.0)


- - -

## 2025.03.04.0

### Refactors

- Support for v2 routes ([#2349](https://github.com/juspay/hyperswitch-control-center/pull/2349)) ([`a3d2d36`](https://github.com/juspay/hyperswitch-control-center/commit/a3d2d3655b5b4cb21176791c0b2fbfd7a064c58f))

### Miscellaneous Tasks

- Changes for modularity on product select ([#2276](https://github.com/juspay/hyperswitch-control-center/pull/2276)) ([`a7b510b`](https://github.com/juspay/hyperswitch-control-center/commit/a7b510b40ea8cb816674e3bf72b0a17b4e562fa8))
- Update v2 payment methods ([#2326](https://github.com/juspay/hyperswitch-control-center/pull/2326)) ([`52a7a55`](https://github.com/juspay/hyperswitch-control-center/commit/52a7a55dd993cd4a29455b07dcb149811d1d6fb5))
- Remove ([`157f91e`](https://github.com/juspay/hyperswitch-control-center/commit/157f91e0ebda640d35f1f28d57f59cf2974c3b47))
- Customization for charts and tabs ([#2345](https://github.com/juspay/hyperswitch-control-center/pull/2345)) ([`e5edcc2`](https://github.com/juspay/hyperswitch-control-center/commit/e5edcc24859f0e53070f7f127ee25117b2053ec6))

**Full Changelog:** [`2025.02.28.0...2025.03.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.28.0...2025.03.04.0)

- - -

## 2025.02.28.0

### Features

- Alt payment methods ([#2341](https://github.com/juspay/hyperswitch-control-center/pull/2341)) ([`e7d02fd`](https://github.com/juspay/hyperswitch-control-center/commit/e7d02fdafd36d1d582df29f7e95e74b2f50dd63a))

### Bug Fixes

- Maintaining org sidebar list order ([#2337](https://github.com/juspay/hyperswitch-control-center/pull/2337)) ([`0da43e3`](https://github.com/juspay/hyperswitch-control-center/commit/0da43e3b5e6da28a94cd1f832e462be559d71822))
- Enhancements in advance routing ([#2338](https://github.com/juspay/hyperswitch-control-center/pull/2338)) ([`82947eb`](https://github.com/juspay/hyperswitch-control-center/commit/82947eb149197d6fdff2db9eebee1465d42742db))

### Miscellaneous Tasks

- Routing folder structure revamp ([#2331](https://github.com/juspay/hyperswitch-control-center/pull/2331)) ([`af99476`](https://github.com/juspay/hyperswitch-control-center/commit/af99476d764afad26a0e2a8218ff704c6b47583c))
- Changed vault pmt screen css ([#2303](https://github.com/juspay/hyperswitch-control-center/pull/2303)) ([`dfcb5a7`](https://github.com/juspay/hyperswitch-control-center/commit/dfcb5a7426878c6e01e56c5f6e169af809f0d9d9))

**Full Changelog:** [`2025.02.26.0...2025.02.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.26.0...2025.02.28.0)


- - -

## 2025.02.26.0

### Features

- Added Column Graph, PieGraph, Stacked BarGraph ([#2317](https://github.com/juspay/hyperswitch-control-center/pull/2317)) ([`b3e0fee`](https://github.com/juspay/hyperswitch-control-center/commit/b3e0feeb4fe063c4aa4a7161867ff29d46f9dd14))

### Bug Fixes

- Recon icon display ([#2324](https://github.com/juspay/hyperswitch-control-center/pull/2324)) ([`39693ed`](https://github.com/juspay/hyperswitch-control-center/commit/39693ed6641c57836d0b96324aa8dcd6555ee1ef))
- Responsive merchant and profile dropdowns ([#2334](https://github.com/juspay/hyperswitch-control-center/pull/2334)) ([`6598e2d`](https://github.com/juspay/hyperswitch-control-center/commit/6598e2d68f9103f628eba832d7ec6936500c883f))

### Miscellaneous Tasks

- Changes in Input Fields, Search Box and Buttons ([#2319](https://github.com/juspay/hyperswitch-control-center/pull/2319)) ([`94f0b06`](https://github.com/juspay/hyperswitch-control-center/commit/94f0b06bc176f57764ff10ed932e9c75cd93e81b))
- Merchant search in dropdown ([#2321](https://github.com/juspay/hyperswitch-control-center/pull/2321)) ([`d8d9b86`](https://github.com/juspay/hyperswitch-control-center/commit/d8d9b8672c94eb42f153cc1ed921f84d78a8f61a))
- Recovery new folder structure ([#2314](https://github.com/juspay/hyperswitch-control-center/pull/2314)) ([`f0c9861`](https://github.com/juspay/hyperswitch-control-center/commit/f0c9861e2ffebecdbacbfac7a21587e11d163c69))
- Edit PMTs option for payout processors ([#2327](https://github.com/juspay/hyperswitch-control-center/pull/2327)) ([`412d278`](https://github.com/juspay/hyperswitch-control-center/commit/412d2781bd0d775e7d1b47f8c4c979e2717ed5f1))

**Full Changelog:** [`2025.02.24.0...2025.02.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.24.0...2025.02.26.0)


- - -

## 2025.02.24.0

### Features

- Added attempts table to revenue order details ([#2305](https://github.com/juspay/hyperswitch-control-center/pull/2305)) ([`2a6f34d`](https://github.com/juspay/hyperswitch-control-center/commit/2a6f34db1015dd4bf1d6c34a08e59fcc8b55e7ea))

### Testing

- Fix failing connector test ([#2310](https://github.com/juspay/hyperswitch-control-center/pull/2310)) ([`50e3bfc`](https://github.com/juspay/hyperswitch-control-center/commit/50e3bfc34acaf8cee00e3a193878e79be5fbd66d))

### Miscellaneous Tasks

- Implement v2 connector type ([#2315](https://github.com/juspay/hyperswitch-control-center/pull/2315)) ([`e061d8b`](https://github.com/juspay/hyperswitch-control-center/commit/e061d8ba15a8d4e83145d37377b89e1aec7c36d7))

**Full Changelog:** [`2025.02.20.0...2025.02.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.20.0...2025.02.24.0)

- - -

## 2025.02.20.0

### Features

- Added new connector coingate ([#2290](https://github.com/juspay/hyperswitch-control-center/pull/2290)) ([`db979f7`](https://github.com/juspay/hyperswitch-control-center/commit/db979f759cdcee3a76f42fa0f38bbbaf7c309f64))
- Wasm update for coingate ([#2291](https://github.com/juspay/hyperswitch-control-center/pull/2291)) ([`c867857`](https://github.com/juspay/hyperswitch-control-center/commit/c8678575d918470f7c711269c95db73e0d870cab))
- Recovery payment connector ([#2288](https://github.com/juspay/hyperswitch-control-center/pull/2288)) ([`e099c4f`](https://github.com/juspay/hyperswitch-control-center/commit/e099c4f0053fc2cae7bc0404b03d9c278a1de861))

### Bug Fixes

- Overflowing merchant profile names in dropdowns ([#2294](https://github.com/juspay/hyperswitch-control-center/pull/2294)) ([`98123ff`](https://github.com/juspay/hyperswitch-control-center/commit/98123ff069f3fc8381a091b4e1afc7a9f9bbf2a8))

### Miscellaneous Tasks

- Enable cancel edit pmt ([#2272](https://github.com/juspay/hyperswitch-control-center/pull/2272)) ([`3170e9b`](https://github.com/juspay/hyperswitch-control-center/commit/3170e9b069fcc338303ff6dd76ed922511805465))
- Add pmt in vault onboarding ([#2292](https://github.com/juspay/hyperswitch-control-center/pull/2292)) ([`395c78c`](https://github.com/juspay/hyperswitch-control-center/commit/395c78cfc9e7df8a53061157182797b3f99b820e))
- Addition of card discovery filter in payment ops ([#2297](https://github.com/juspay/hyperswitch-control-center/pull/2297)) ([`ae26068`](https://github.com/juspay/hyperswitch-control-center/commit/ae26068432886bb56ed7d8aa9fcdf19329693188))

**Full Changelog:** [`2025.02.19.1...2025.02.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.19.1...2025.02.20.0)

- - -

## 2025.02.19.1

### Bug Fixes

- Table ui fixes ([#2287](https://github.com/juspay/hyperswitch-control-center/pull/2287)) ([`83d9c47`](https://github.com/juspay/hyperswitch-control-center/commit/83d9c47d051141f63e5bdca000024653d299c910))

**Full Changelog:** [`2025.02.19.0...2025.02.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.19.0...2025.02.19.1)

- - -

## 2025.02.19.0

### Features

- Added recovery details page ([#2258](https://github.com/juspay/hyperswitch-control-center/pull/2258)) ([`55072ef`](https://github.com/juspay/hyperswitch-control-center/commit/55072ef2cb404f954b06d1d12af39c9b759e8cbd))
- Added slack link to network tokenization page ([#2280](https://github.com/juspay/hyperswitch-control-center/pull/2280)) ([`28b1e1e`](https://github.com/juspay/hyperswitch-control-center/commit/28b1e1e4bc9347d2975367d6dca7df32028545a2))

### Bug Fixes

- User role selection width adjustment in manage user modal ([#2281](https://github.com/juspay/hyperswitch-control-center/pull/2281)) ([`ffc82bb`](https://github.com/juspay/hyperswitch-control-center/commit/ffc82bbe1b963e920e415cc933f87b94f75d04a1))

### Miscellaneous Tasks

- Novalnet live ([#2279](https://github.com/juspay/hyperswitch-control-center/pull/2279)) ([`2627d70`](https://github.com/juspay/hyperswitch-control-center/commit/2627d70be409175d8e890849b43e9e6621d2a085))
- Fix empty type value causing error in update ([#2285](https://github.com/juspay/hyperswitch-control-center/pull/2285)) ([`ad74e13`](https://github.com/juspay/hyperswitch-control-center/commit/ad74e13453958446e8280a504c91b92fdf96f34d))

**Full Changelog:** [`2025.02.18.0...2025.02.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.18.0...2025.02.19.0)

- - -

## 2025.02.18.0

### Features

- Billing connector addition ([#2248](https://github.com/juspay/hyperswitch-control-center/pull/2248)) ([`40b6b85`](https://github.com/juspay/hyperswitch-control-center/commit/40b6b85a1c690f51c83abc93ebc63ca582383aa7))

### Bug Fixes

- Global search amount filter special characters fix ([#2266](https://github.com/juspay/hyperswitch-control-center/pull/2266)) ([`d0f57b8`](https://github.com/juspay/hyperswitch-control-center/commit/d0f57b81c8072c6ba27b454b5233faa086092ad1))
- View data gradient button ([#2270](https://github.com/juspay/hyperswitch-control-center/pull/2270)) ([`9f853ec`](https://github.com/juspay/hyperswitch-control-center/commit/9f853eca712cf8a35c2e906b84c83f0031d4a7d7))
- Fixed ui design bugs ([#2273](https://github.com/juspay/hyperswitch-control-center/pull/2273)) ([`04bc569`](https://github.com/juspay/hyperswitch-control-center/commit/04bc56964ab0c3b3b40fbaa946ee7b5a8fa912ff))
- Granularity time conversion fix for smart retry and refunds ([#2260](https://github.com/juspay/hyperswitch-control-center/pull/2260)) ([`a11fdd8`](https://github.com/juspay/hyperswitch-control-center/commit/a11fdd82de258e335510aba1a77d4cc8c54196dd))
- Design bugs ([#2262](https://github.com/juspay/hyperswitch-control-center/pull/2262)) ([`1efe310`](https://github.com/juspay/hyperswitch-control-center/commit/1efe3109df79aef9725581aeb6549bdcf5251571))

### Miscellaneous Tasks

- Sidebar collapse in products ([#2268](https://github.com/juspay/hyperswitch-control-center/pull/2268)) ([`d02c25c`](https://github.com/juspay/hyperswitch-control-center/commit/d02c25c582c1424a4b846c6391e13f6b35731e54))

**Full Changelog:** [`2025.02.17.0...2025.02.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.17.0...2025.02.18.0)

- - -

## 2025.02.17.0

### Features

- Vault customers and tokens ([#2244](https://github.com/juspay/hyperswitch-control-center/pull/2244)) ([`5d0c3ea`](https://github.com/juspay/hyperswitch-control-center/commit/5d0c3eaea48af42dd404b26f5ec44c3dcd046ffd))
- Vault network token ([#2243](https://github.com/juspay/hyperswitch-control-center/pull/2243)) ([`a775fae`](https://github.com/juspay/hyperswitch-control-center/commit/a775faed2e9fc9723bcb27e2849ed7c22421c108))

### Bug Fixes

- Routing bugfixes ([#2263](https://github.com/juspay/hyperswitch-control-center/pull/2263)) ([`6b79577`](https://github.com/juspay/hyperswitch-control-center/commit/6b79577aa2d721f0a74d549d2a3e57969ae59889))
- Added focus-visible on button and used hsl to generate colors ([#2256](https://github.com/juspay/hyperswitch-control-center/pull/2256)) ([`03b22c2`](https://github.com/juspay/hyperswitch-control-center/commit/03b22c241ec55b315181fd52183a95e2eb5dba43))

### Miscellaneous Tasks

- Vault-fixes and enhancements ([#2250](https://github.com/juspay/hyperswitch-control-center/pull/2250)) ([`7d63196`](https://github.com/juspay/hyperswitch-control-center/commit/7d631966539d21e7d218d89aa1d87d8c9ef29e0f))
- Commenting unavailable api ([#2264](https://github.com/juspay/hyperswitch-control-center/pull/2264)) ([`b61461d`](https://github.com/juspay/hyperswitch-control-center/commit/b61461dfe6079134d8ac1058ed3b397d26db003b))

**Full Changelog:** [`2025.02.14.0...2025.02.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.14.0...2025.02.17.0)

- - -

## 2025.02.14.0

### Features

- Addition of new connectors-Inespay ([#2245](https://github.com/juspay/hyperswitch-control-center/pull/2245)) ([`b62c2c8`](https://github.com/juspay/hyperswitch-control-center/commit/b62c2c82e3bebdf47b0a32979b684101aae77ebf))

### Refactors

- Update v2 payment methods ([#2234](https://github.com/juspay/hyperswitch-control-center/pull/2234)) ([`7912de4`](https://github.com/juspay/hyperswitch-control-center/commit/7912de45ba1c530e499a2a62cfc8110e94d68ead))

### Miscellaneous Tasks

- Wasm update for Inespay ([#2246](https://github.com/juspay/hyperswitch-control-center/pull/2246)) ([`da4e58f`](https://github.com/juspay/hyperswitch-control-center/commit/da4e58f08cc0458684be3a8ac446bb616869ea61))

**Full Changelog:** [`2025.02.13.0...2025.02.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.13.0...2025.02.14.0)

- - -

## 2025.02.13.0

### Features

- Added loaded table for revenue recovery payments ([#2206](https://github.com/juspay/hyperswitch-control-center/pull/2206)) ([`f3f3473`](https://github.com/juspay/hyperswitch-control-center/commit/f3f3473222d9e89957574d97152cb881e2928bb6))
- Global search amount filter ([#2231](https://github.com/juspay/hyperswitch-control-center/pull/2231)) ([`c9c0082`](https://github.com/juspay/hyperswitch-control-center/commit/c9c0082d7d38c00abb5ec7c1858c4d2a5e231ad8))
- Added vault connector flow pages ([#2217](https://github.com/juspay/hyperswitch-control-center/pull/2217)) ([`34144aa`](https://github.com/juspay/hyperswitch-control-center/commit/34144aa8cae3a83247714dd670aca9b12ad26d59))

### Bug Fixes

- Payout details page display ([#2242](https://github.com/juspay/hyperswitch-control-center/pull/2242)) ([`550eda6`](https://github.com/juspay/hyperswitch-control-center/commit/550eda6b7c40bd9b247c9828ae7a81edfa1bdbf8))

### Miscellaneous Tasks

- Granularity options for smart retry and refunds tab and minor bug fixes ([#2228](https://github.com/juspay/hyperswitch-control-center/pull/2228)) ([`3ed15dd`](https://github.com/juspay/hyperswitch-control-center/commit/3ed15ddf8fb25f72c7a38c3de68430e41d3017d1))

**Full Changelog:** [`2025.02.12.0...2025.02.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.12.0...2025.02.13.0)

- - -

## 2025.02.12.0

### Features

- Added Pie charts ([#2233](https://github.com/juspay/hyperswitch-control-center/pull/2233)) ([`2c88d3a`](https://github.com/juspay/hyperswitch-control-center/commit/2c88d3a812b009d428d8c474d2414c44e21f8dc0))
- Allow surcharge rule editing ([#2223](https://github.com/juspay/hyperswitch-control-center/pull/2223)) ([`fd45bf0`](https://github.com/juspay/hyperswitch-control-center/commit/fd45bf06f0e576944d3467242c3816286e6c7a04))

### Bug Fixes

- Update privacy policy hyperlink on login page ([#2237](https://github.com/juspay/hyperswitch-control-center/pull/2237)) ([`378c6fa`](https://github.com/juspay/hyperswitch-control-center/commit/378c6faf1e773dbdb61c194704d9fef87a07396c))

### Miscellaneous Tasks

- Sidebar enhancement ([#2225](https://github.com/juspay/hyperswitch-control-center/pull/2225)) ([`6a9de00`](https://github.com/juspay/hyperswitch-control-center/commit/6a9de00bb7f2c2df10eab41cec112975ff272776))

**Full Changelog:** [`2025.02.11.0...2025.02.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.11.0...2025.02.12.0)

- - -

## 2025.02.11.0

### Bug Fixes

- Ensure correct merchant profile ID selection in dropdown ([#2218](https://github.com/juspay/hyperswitch-control-center/pull/2218)) ([`f7ad5f3`](https://github.com/juspay/hyperswitch-control-center/commit/f7ad5f36e1ac806374ac04e08b8c41489bd3a21e))
- Default homepage fixes ([#2220](https://github.com/juspay/hyperswitch-control-center/pull/2220)) ([`72d06d6`](https://github.com/juspay/hyperswitch-control-center/commit/72d06d684e0087750a33c0c0b8b70a465c8311cf))

### Miscellaneous Tasks

- Table ui refactor ([#2208](https://github.com/juspay/hyperswitch-control-center/pull/2208)) ([`01fa5ec`](https://github.com/juspay/hyperswitch-control-center/commit/01fa5ec090f68d4fb9e0709069339e640b37b097))

**Full Changelog:** [`2025.02.07.0...2025.02.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.07.0...2025.02.11.0)

- - -

## 2025.02.07.0

### Features

- Recovery module page routes and side bar changes ([#2211](https://github.com/juspay/hyperswitch-control-center/pull/2211)) ([`7cd9f41`](https://github.com/juspay/hyperswitch-control-center/commit/7cd9f41e3221b7bf2213423b13040f3e6a30a490))

**Full Changelog:** [`2025.02.05.1...2025.02.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.05.1...2025.02.07.0)

- - -

## 2025.02.05.1

### Bug Fixes

- Search text being sent in payload even when search field is cleared ([#2194](https://github.com/juspay/hyperswitch-control-center/pull/2194)) ([`fcc23df`](https://github.com/juspay/hyperswitch-control-center/commit/fcc23dff3d29aad9a788b64cc5a48f4da4e0a71a))
- Button issues fix in payment settings and auth select ([#2204](https://github.com/juspay/hyperswitch-control-center/pull/2204)) ([`06cda2c`](https://github.com/juspay/hyperswitch-control-center/commit/06cda2c5dad551d18b7e51f9efe590eb693a5168))

### Miscellaneous Tasks

- Payment method UI changes wrt to new design ([#2209](https://github.com/juspay/hyperswitch-control-center/pull/2209)) ([`b1312e7`](https://github.com/juspay/hyperswitch-control-center/commit/b1312e7cb8767fe592651699d8600fc6b30cd57c))

**Full Changelog:** [`2025.02.05.0...2025.02.05.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.05.0...2025.02.05.1)

- - -

## 2025.02.05.0

### Features

- Added Onboarding Vertical Step Indicator ([#2195](https://github.com/juspay/hyperswitch-control-center/pull/2195)) ([`5ae18b2`](https://github.com/juspay/hyperswitch-control-center/commit/5ae18b2c861de457e91c3d9b3838331ee8348036))

### Bug Fixes

- User is logged when org and merchant switch occurs in product landing page ([#2192](https://github.com/juspay/hyperswitch-control-center/pull/2192)) ([`cb9d437`](https://github.com/juspay/hyperswitch-control-center/commit/cb9d4371690103308a79b341ef1166992e6607c0))

### Testing

- Fix failing cypress test cases ([#2189](https://github.com/juspay/hyperswitch-control-center/pull/2189)) ([`9fba059`](https://github.com/juspay/hyperswitch-control-center/commit/9fba059e9ce783eb783e72fbb143ebb01dacb9c1))

### Miscellaneous Tasks

- Navbar Redesign and OMP Movement ([#2181](https://github.com/juspay/hyperswitch-control-center/pull/2181)) ([`7979ef9`](https://github.com/juspay/hyperswitch-control-center/commit/7979ef9386bf3817e64926bdd34b31cbb4ad6ac3))
- Modularity Default Home page ([#2187](https://github.com/juspay/hyperswitch-control-center/pull/2187)) ([`123a5ff`](https://github.com/juspay/hyperswitch-control-center/commit/123a5ff1a35102679c96e657feadbc918ae20e7a))
- Connector summary page ([#2199](https://github.com/juspay/hyperswitch-control-center/pull/2199)) ([`c7916e4`](https://github.com/juspay/hyperswitch-control-center/commit/c7916e4e9902908e7bf1b2615d73325cb413a3c5))
- Vault connector integration ([#2203](https://github.com/juspay/hyperswitch-control-center/pull/2203)) ([`9a8510e`](https://github.com/juspay/hyperswitch-control-center/commit/9a8510e4ca3f26dcce128c0e2db302376de6048c))

**Full Changelog:** [`2025.02.03.0...2025.02.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.02.03.0...2025.02.05.0)

- - -

## 2025.02.03.0

### Features

- Vaulting setup ([#2177](https://github.com/juspay/hyperswitch-control-center/pull/2177)) ([`f216107`](https://github.com/juspay/hyperswitch-control-center/commit/f216107c61bed6265fd2a18e9fbe0e28a761db31))

### Bug Fixes

- Dashboard redesign ui issues ([#2176](https://github.com/juspay/hyperswitch-control-center/pull/2176)) ([`12042b8`](https://github.com/juspay/hyperswitch-control-center/commit/12042b898b2bf313004619d3902ada71b059a785))
- Org name update ([#2180](https://github.com/juspay/hyperswitch-control-center/pull/2180)) ([`5c26b10`](https://github.com/juspay/hyperswitch-control-center/commit/5c26b1075932a7f59496a0b83a3b48152eae03ce))
- Org indexes logic fix ([#2184](https://github.com/juspay/hyperswitch-control-center/pull/2184)) ([`4e330dc`](https://github.com/juspay/hyperswitch-control-center/commit/4e330dc917ee125420bbc90b07d4b86c03a63604))

### Miscellaneous Tasks

- Config colors changes ([#2174](https://github.com/juspay/hyperswitch-control-center/pull/2174)) ([`50d6de8`](https://github.com/juspay/hyperswitch-control-center/commit/50d6de88903b904cc8b2769e0459b5a781c6df28))
- Vaulting landing page ([#2182](https://github.com/juspay/hyperswitch-control-center/pull/2182)) ([`e6f9332`](https://github.com/juspay/hyperswitch-control-center/commit/e6f933231117adad95e804e70efe0e7f20b1760e))

**Full Changelog:** [`2025.01.30.1...2025.02.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.30.1...2025.02.03.0)

- - -

## 2025.01.30.1

### Features

- Klarna-checkout added for klarna updated wasm ([#2151](https://github.com/juspay/hyperswitch-control-center/pull/2151)) ([`6ed8259`](https://github.com/juspay/hyperswitch-control-center/commit/6ed8259db0a210e87c3a05f27b526980c1fb2026))
- New UI button ([#2147](https://github.com/juspay/hyperswitch-control-center/pull/2147)) ([`52a7125`](https://github.com/juspay/hyperswitch-control-center/commit/52a7125d6d3da5a5f9acf2fe16a07734049e7808))
- Product sidebar changes ([#2170](https://github.com/juspay/hyperswitch-control-center/pull/2170)) ([`c13ac06`](https://github.com/juspay/hyperswitch-control-center/commit/c13ac066f2c8131856e1dae87f391565293533b5))

### Bug Fixes

- Filter Select Box changes ([#2172](https://github.com/juspay/hyperswitch-control-center/pull/2172)) ([`70ddbf1`](https://github.com/juspay/hyperswitch-control-center/commit/70ddbf108bd9546d49698d9cbf67133528579cc2))

### Miscellaneous Tasks

- Text comp ui update ([#2166](https://github.com/juspay/hyperswitch-control-center/pull/2166)) ([`5a895dc`](https://github.com/juspay/hyperswitch-control-center/commit/5a895dc9fa65b3f7ad4f6327e627fb680c980a02))
- Dashboard White Theme Changes ( Including OMP ) ([#2153](https://github.com/juspay/hyperswitch-control-center/pull/2153)) ([`509126a`](https://github.com/juspay/hyperswitch-control-center/commit/509126ae8a225517ec0dd7431d5a8a4e8f114e81))

**Full Changelog:** [`2025.01.30.0...2025.01.30.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.30.0...2025.01.30.1)

- - -

## 2025.01.30.0

### Features

- Org Sidebar ([#2087](https://github.com/juspay/hyperswitch-control-center/pull/2087)) ([`e42777d`](https://github.com/juspay/hyperswitch-control-center/commit/e42777d725fca85ceafa6da7b03e9185194fddbe))
- Global font change to InterDisplay ([#2149](https://github.com/juspay/hyperswitch-control-center/pull/2149)) ([`f12ef18`](https://github.com/juspay/hyperswitch-control-center/commit/f12ef187279bdfad8ae20d1a0d128deb49b16200))
- Granularity options for refunds tab analytics ([#2107](https://github.com/juspay/hyperswitch-control-center/pull/2107)) ([`e177e9a`](https://github.com/juspay/hyperswitch-control-center/commit/e177e9a3cbda717c6207f56c25b8d1e8091b46f5))
- Granularity options for smart retry tab analytics ([#2106](https://github.com/juspay/hyperswitch-control-center/pull/2106)) ([`5d55571`](https://github.com/juspay/hyperswitch-control-center/commit/5d55571967688f96ab6d04ff8c92ccecf4de8729))

### Miscellaneous Tasks

- Redacted customers details page view ([#2145](https://github.com/juspay/hyperswitch-control-center/pull/2145)) ([`1fbf666`](https://github.com/juspay/hyperswitch-control-center/commit/1fbf666491ebda1b60ac2c7af51c4589f7b3a886))

**Full Changelog:** [`2025.01.29.2...2025.01.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.29.2...2025.01.30.0)

- - -

## 2025.01.29.2

### Miscellaneous Tasks

- Add analytics authentication ([#2158](https://github.com/juspay/hyperswitch-control-center/pull/2158)) ([`0fb9fba`](https://github.com/juspay/hyperswitch-control-center/commit/0fb9fba493a0bc91ee0685efe8a299e8a2830182))

**Full Changelog:** [`2025.01.29.1...2025.01.29.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.29.1...2025.01.29.2)

- - -

## 2025.01.29.1

### Bug Fixes

- Analytics filters init set function modification ([#2156](https://github.com/juspay/hyperswitch-control-center/pull/2156)) ([`64b97a5`](https://github.com/juspay/hyperswitch-control-center/commit/64b97a5fc1bc4699cda8a1b236633e9f6e60f2bf))

**Full Changelog:** [`2025.01.29.0...2025.01.29.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.29.0...2025.01.29.1)

- - -

## 2025.01.29.0

### Bug Fixes

- Surcharge and 3DS Delete permission ([#2148](https://github.com/juspay/hyperswitch-control-center/pull/2148)) ([`0baca0c`](https://github.com/juspay/hyperswitch-control-center/commit/0baca0c32c2b0054d76756242d0043ccf8f95cc0))
- Refactor modal warning icon in Smart and volume based routing ([#2143](https://github.com/juspay/hyperswitch-control-center/pull/2143)) ([`2db22fd`](https://github.com/juspay/hyperswitch-control-center/commit/2db22fd10056826301c67efb34909315ccdc68d8))

### Miscellaneous Tasks

- Added profile name validation ([#2128](https://github.com/juspay/hyperswitch-control-center/pull/2128)) ([`49bb20b`](https://github.com/juspay/hyperswitch-control-center/commit/49bb20bc8b8ad12535c12fccfa9d2f7a66b9fd72))

**Full Changelog:** [`2025.01.28.0...2025.01.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.28.0...2025.01.29.0)

- - -

## 2025.01.28.0

### Features

- Recovery product feature flag and folder structure ([#2141](https://github.com/juspay/hyperswitch-control-center/pull/2141)) ([`746f8b2`](https://github.com/juspay/hyperswitch-control-center/commit/746f8b286bb2a77b521ccc7bebb80eeccb253d2c))

### Bug Fixes

- Sdk checkout overlapping divs ([#2126](https://github.com/juspay/hyperswitch-control-center/pull/2126)) ([`bd240e5`](https://github.com/juspay/hyperswitch-control-center/commit/bd240e5ce65dfb2ebbebef91b271044be494e7ad))

**Full Changelog:** [`2025.01.27.0...2025.01.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.27.0...2025.01.28.0)

- - -

## 2025.01.27.0

### Bug Fixes

- Connector list not updating properly everytime ([#2124](https://github.com/juspay/hyperswitch-control-center/pull/2124)) ([`d2fc840`](https://github.com/juspay/hyperswitch-control-center/commit/d2fc840093ad6e15fc234c50e2a6bee223f3d002))
- Theme logo ([#2130](https://github.com/juspay/hyperswitch-control-center/pull/2130)) ([`64d5e21`](https://github.com/juspay/hyperswitch-control-center/commit/64d5e212098316a73d8610bc9e553bde261caf22))
- Sorted userlist by email ([#2129](https://github.com/juspay/hyperswitch-control-center/pull/2129)) ([`51a1f45`](https://github.com/juspay/hyperswitch-control-center/commit/51a1f45428075d3788b3b9d41bf2a0c6cb96ed2c))
- Surcharge delete button ([#2127](https://github.com/juspay/hyperswitch-control-center/pull/2127)) ([`5acc3fa`](https://github.com/juspay/hyperswitch-control-center/commit/5acc3fa613e8f04c3300b41e5e2d83448e3cf78e))

### Testing

- Cypress tests restructure ([#1928](https://github.com/juspay/hyperswitch-control-center/pull/1928)) ([`e07f609`](https://github.com/juspay/hyperswitch-control-center/commit/e07f6098a21c054259ef25b8e7b97924812c29d0))

### Miscellaneous Tasks

- Granularity time formatting to user time zone ([#2122](https://github.com/juspay/hyperswitch-control-center/pull/2122)) ([`580c93a`](https://github.com/juspay/hyperswitch-control-center/commit/580c93a4db103658a29974a623823e2c0eb761ed))
- Insights single point enhancement ([#2132](https://github.com/juspay/hyperswitch-control-center/pull/2132)) ([`0dded6e`](https://github.com/juspay/hyperswitch-control-center/commit/0dded6eb3fe9e3dbc83d0f169178a23a41ac1bbf))

**Full Changelog:** [`2025.01.24.0...2025.01.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.24.0...2025.01.27.0)

- - -

## 2025.01.24.0

### Features

- Addition of new connectors-Xendit and Jp morgan ([#2112](https://github.com/juspay/hyperswitch-control-center/pull/2112)) ([`324470e`](https://github.com/juspay/hyperswitch-control-center/commit/324470eef97a11fd265b752456b1a05c107bb396))
- Inline Edit Input Component ([#2111](https://github.com/juspay/hyperswitch-control-center/pull/2111)) ([`7e79163`](https://github.com/juspay/hyperswitch-control-center/commit/7e7916317c43665d1d2fc2d7cb7ff288fe1e8de3))

### Bug Fixes

- Merchant View Only Access to APIKeys ([#2099](https://github.com/juspay/hyperswitch-control-center/pull/2099)) ([`812e9ac`](https://github.com/juspay/hyperswitch-control-center/commit/812e9ac846e8bb11707917c84a2400ceb8bf19d8))
- Refactoring append themes css logic ([#2113](https://github.com/juspay/hyperswitch-control-center/pull/2113)) ([`345a005`](https://github.com/juspay/hyperswitch-control-center/commit/345a005e63795e3c38a8f332072fff8431491567))
- Removed System Metrics ([#2117](https://github.com/juspay/hyperswitch-control-center/pull/2117)) ([`b71121d`](https://github.com/juspay/hyperswitch-control-center/commit/b71121d9b2e513977e0766f236701f498f601955))

### Testing

- Cypress clear cookies ([#2119](https://github.com/juspay/hyperswitch-control-center/pull/2119)) ([`9978b2c`](https://github.com/juspay/hyperswitch-control-center/commit/9978b2c43aeaf99d6a1cf7249134585146c2d78b))

### Miscellaneous Tasks

- Customer list limit increased from 10 to 50 ([#2120](https://github.com/juspay/hyperswitch-control-center/pull/2120)) ([`9c0a3ba`](https://github.com/juspay/hyperswitch-control-center/commit/9c0a3ba4b4fb19b1658fb77e5bacd8b7c538de98))

**Full Changelog:** [`2025.01.21.1...2025.01.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.21.1...2025.01.24.0)

- - -

## 2025.01.21.1

### Features

- Granularity new analytics changes ([#2017](https://github.com/juspay/hyperswitch-control-center/pull/2017)) ([`cd30932`](https://github.com/juspay/hyperswitch-control-center/commit/cd3093227d7c4b2014dab5ac634c272f81a85f27))

### Bug Fixes

- Sdk go to payment button redirection fix ([#2102](https://github.com/juspay/hyperswitch-control-center/pull/2102)) ([`8e80124`](https://github.com/juspay/hyperswitch-control-center/commit/8e80124ec95c72751846869900d6f85dac6c1325))
- Add email support ([#2010](https://github.com/juspay/hyperswitch-control-center/pull/2010)) ([`b08179d`](https://github.com/juspay/hyperswitch-control-center/commit/b08179de3254b0ee7c3771e89ecb32c354077595))

### Refactors

- Value formatter moved to LogicUtils ([#2098](https://github.com/juspay/hyperswitch-control-center/pull/2098)) ([`fee2b92`](https://github.com/juspay/hyperswitch-control-center/commit/fee2b9202a30a1b38b10413fc9708bc185284dfc))

### Miscellaneous Tasks

- Enabled paybox connector on prod ([#2101](https://github.com/juspay/hyperswitch-control-center/pull/2101)) ([`adf6c49`](https://github.com/juspay/hyperswitch-control-center/commit/adf6c49588c75a4ab20cb3c6edcec5d98c2d9f62))

**Full Changelog:** [`2025.01.21.0...2025.01.21.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.21.0...2025.01.21.1)

- - -

## 2025.01.21.0

### Features

- Added responsiveness to api keys page ([#2061](https://github.com/juspay/hyperswitch-control-center/pull/2061)) ([`769daa7`](https://github.com/juspay/hyperswitch-control-center/commit/769daa796fc04297b01caf4e65c04d2f22fb965a))

### Bug Fixes

- Fixed multiple connector api calls ([#2060](https://github.com/juspay/hyperswitch-control-center/pull/2060)) ([`a77774a`](https://github.com/juspay/hyperswitch-control-center/commit/a77774a5fbfbda1fc2050a34d43173aa0e1e19e7))

### Refactors

- Changed linegraph and sankeygraph options ([#2089](https://github.com/juspay/hyperswitch-control-center/pull/2089)) ([`4cf2c50`](https://github.com/juspay/hyperswitch-control-center/commit/4cf2c50d5999015d4fb41947e4513f6a413bf14c))

### Miscellaneous Tasks

- Remove unused feature flags and codeblocks ([#1931](https://github.com/juspay/hyperswitch-control-center/pull/1931)) ([`d3d32a6`](https://github.com/juspay/hyperswitch-control-center/commit/d3d32a62684e67da7a5181046521852ba664a2ab))

**Full Changelog:** [`2025.01.20.1...2025.01.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.20.1...2025.01.21.0)

- - -

## 2025.01.20.1

### Features

- New analytics filters feature flag ([#2084](https://github.com/juspay/hyperswitch-control-center/pull/2084)) ([`b60da23`](https://github.com/juspay/hyperswitch-control-center/commit/b60da231df1ad01e073e9f2d6334e7a0724ab739))

**Full Changelog:** [`2025.01.20.0...2025.01.20.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.20.0...2025.01.20.1)

- - -

## 2025.01.20.0

### Features

- Sidebar changes for modularity ([#2063](https://github.com/juspay/hyperswitch-control-center/pull/2063)) ([`5073b70`](https://github.com/juspay/hyperswitch-control-center/commit/5073b70bd0515f5ea0d78411845fd10b0142fee2))

### Bug Fixes

- Invitation error message ([#2076](https://github.com/juspay/hyperswitch-control-center/pull/2076)) ([`08cfdf9`](https://github.com/juspay/hyperswitch-control-center/commit/08cfdf9f5c43e9d6bdf436390e2de18e4fc275a3))

### Refactors

- Moved Graphs folder to components ([#2079](https://github.com/juspay/hyperswitch-control-center/pull/2079)) ([`6dda7ad`](https://github.com/juspay/hyperswitch-control-center/commit/6dda7ad09b17b1c3d2710f9732c485efaa8b3f56))

### Miscellaneous Tasks

- Change Bar graph component ([#2081](https://github.com/juspay/hyperswitch-control-center/pull/2081)) ([`280bb72`](https://github.com/juspay/hyperswitch-control-center/commit/280bb72fc88d2f53c0a90dd8923f877efa25e964))

**Full Changelog:** [`2025.01.17.0...2025.01.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.17.0...2025.01.20.0)

- - -

## 2025.01.17.0

### Features

- Customer table pagination ([#2071](https://github.com/juspay/hyperswitch-control-center/pull/2071)) ([`4c84206`](https://github.com/juspay/hyperswitch-control-center/commit/4c842068bf9820c5ed1d4744163475f891639d1d))

### Bug Fixes

- Success toast in routing ([#2074](https://github.com/juspay/hyperswitch-control-center/pull/2074)) ([`af6bc6b`](https://github.com/juspay/hyperswitch-control-center/commit/af6bc6b0d8f64991677b1d3fad02fe37fd15d21f))

### Refactors

- Connector_type type added ([#2069](https://github.com/juspay/hyperswitch-control-center/pull/2069)) ([`80ba2f5`](https://github.com/juspay/hyperswitch-control-center/commit/80ba2f5bdebcad0171963723ff09267241d82841))

**Full Changelog:** [`2025.01.16.0...2025.01.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.16.0...2025.01.17.0)

- - -

## 2025.01.16.0

### Features

- New analytics filter refunds ([#2056](https://github.com/juspay/hyperswitch-control-center/pull/2056)) ([`db5b503`](https://github.com/juspay/hyperswitch-control-center/commit/db5b503fd5f4160ae78968a48b063a79cd39d7e8))

### Bug Fixes

- Fixed extend date button functionality ([#2064](https://github.com/juspay/hyperswitch-control-center/pull/2064)) ([`aee1f0c`](https://github.com/juspay/hyperswitch-control-center/commit/aee1f0c13f32fa9787fb058885c7c23a4dca6c82))
- Currency filter value fixes ([#2067](https://github.com/juspay/hyperswitch-control-center/pull/2067)) ([`41b7f64`](https://github.com/juspay/hyperswitch-control-center/commit/41b7f645b643288fea6d525934875ba35f3d047e))

### Miscellaneous Tasks

- Filter authentication processor ([#2065](https://github.com/juspay/hyperswitch-control-center/pull/2065)) ([`94c8a45`](https://github.com/juspay/hyperswitch-control-center/commit/94c8a4540c2898c8f64d69b539bcd15624f568ef))

**Full Changelog:** [`2025.01.14.0...2025.01.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.14.0...2025.01.16.0)

- - -

## 2025.01.14.0

### Bug Fixes

- Global search id search fix ([#2054](https://github.com/juspay/hyperswitch-control-center/pull/2054)) ([`6dcaf1f`](https://github.com/juspay/hyperswitch-control-center/commit/6dcaf1f834464dc4fc966719ec6be39d597f7f1a))

### Miscellaneous Tasks

- Conditional enforcement of cookies ([#2050](https://github.com/juspay/hyperswitch-control-center/pull/2050)) ([`7c25c4b`](https://github.com/juspay/hyperswitch-control-center/commit/7c25c4b42be1bc5fe48777fece35cb9c1f2f42dd))

**Full Changelog:** [`2025.01.13.0...2025.01.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.13.0...2025.01.14.0)

- - -

## 2025.01.13.0

### Features

- Recon Setup ([#1981](https://github.com/juspay/hyperswitch-control-center/pull/1981)) ([`1a13c1e`](https://github.com/juspay/hyperswitch-control-center/commit/1a13c1e10909e05f64d83f7b9f9dda6c4af9cbf8))
- Banner for maintenance ([#2022](https://github.com/juspay/hyperswitch-control-center/pull/2022)) ([`0695232`](https://github.com/juspay/hyperswitch-control-center/commit/0695232e3fff0abc3fc6824fcba8fc2693ae8dcc))

### Bug Fixes

- Disable deselecting item ([#2058](https://github.com/juspay/hyperswitch-control-center/pull/2058)) ([`64347ef`](https://github.com/juspay/hyperswitch-control-center/commit/64347ef3a81bf3b0ac48931fd5ff76fe10dd14d6))

### Miscellaneous Tasks

- Limit unusually large width of dropdown ([#2046](https://github.com/juspay/hyperswitch-control-center/pull/2046)) ([`edaf8b4`](https://github.com/juspay/hyperswitch-control-center/commit/edaf8b441f1ede8ed4b1dcb753ff198d3e0464cd))
- Org dropdown for tenant admin ([#2053](https://github.com/juspay/hyperswitch-control-center/pull/2053)) ([`ec27e2c`](https://github.com/juspay/hyperswitch-control-center/commit/ec27e2c5a6bce6842329e13103364f5d58b848f4))

**Full Changelog:** [`2025.01.10.0...2025.01.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.10.0...2025.01.13.0)

- - -

## 2025.01.10.0

### Bug Fixes

- Font color primary ([#2048](https://github.com/juspay/hyperswitch-control-center/pull/2048)) ([`c19764f`](https://github.com/juspay/hyperswitch-control-center/commit/c19764fd71235a579ead51a32b898f16e5db29f1))

### Miscellaneous Tasks

- Show info banner for download api key ([#2041](https://github.com/juspay/hyperswitch-control-center/pull/2041)) ([`a0c429b`](https://github.com/juspay/hyperswitch-control-center/commit/a0c429bfef34eb91ef2a7561c03d2034c6d4f7f8))
- Themes API Frontend Support ([#1982](https://github.com/juspay/hyperswitch-control-center/pull/1982)) ([`01cc69c`](https://github.com/juspay/hyperswitch-control-center/commit/01cc69c026dbc725876c766612b63588c2969fd4))

**Full Changelog:** [`2025.01.09.0...2025.01.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.09.0...2025.01.10.0)

- - -

## 2025.01.09.0

### Features

- Global search mixpanel events ([#2028](https://github.com/juspay/hyperswitch-control-center/pull/2028)) ([`2356530`](https://github.com/juspay/hyperswitch-control-center/commit/2356530d37f23d980c6c2dcd6490f835beb2d9a5))
- New analytics filter payments ([#2019](https://github.com/juspay/hyperswitch-control-center/pull/2019)) ([`90c0be2`](https://github.com/juspay/hyperswitch-control-center/commit/90c0be2f71bcbbd00d9d28df56306f544ccf5b72))
- New analytics currency filter smart retry ([#2037](https://github.com/juspay/hyperswitch-control-center/pull/2037)) ([`951bda8`](https://github.com/juspay/hyperswitch-control-center/commit/951bda85721db84f2eab511fd837da2e3ec70bac))
- Mixpanel x request id on alert events ([#2042](https://github.com/juspay/hyperswitch-control-center/pull/2042)) ([`a3dd8cd`](https://github.com/juspay/hyperswitch-control-center/commit/a3dd8cd8babfff780c8c85f2af77f03f4840ad97))

### Miscellaneous Tasks

- Minor file refactor and table data ordering ([#2031](https://github.com/juspay/hyperswitch-control-center/pull/2031)) ([`88f6af5`](https://github.com/juspay/hyperswitch-control-center/commit/88f6af5e02520e29bb5717539cdf9980c5576a0a))
- Global search free text handling ([#2034](https://github.com/juspay/hyperswitch-control-center/pull/2034)) ([`04b7f20`](https://github.com/juspay/hyperswitch-control-center/commit/04b7f203ea7b2a231a92edecfdd4ada447584655))
- Show merchant switch toast ([#2040](https://github.com/juspay/hyperswitch-control-center/pull/2040)) ([`e540954`](https://github.com/juspay/hyperswitch-control-center/commit/e54095412fb1dfd42b2884ad52b0c76c0026bc81))

**Full Changelog:** [`2025.01.08.0...2025.01.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.08.0...2025.01.09.0)

- - -

## 2025.01.08.0

### Features

- Extenddatebutton ([#2001](https://github.com/juspay/hyperswitch-control-center/pull/2001)) ([`7961ba6`](https://github.com/juspay/hyperswitch-control-center/commit/7961ba673d88798b2bd194a538bb01d262d0786e))

### Bug Fixes

- Dropdown buttons ([#2013](https://github.com/juspay/hyperswitch-control-center/pull/2013)) ([`602a787`](https://github.com/juspay/hyperswitch-control-center/commit/602a787c9cc8c50590ac9c93c3f5811222f6f23b))

### Miscellaneous Tasks

- Dropdown ellipses text ([#2025](https://github.com/juspay/hyperswitch-control-center/pull/2025)) ([`f5d246a`](https://github.com/juspay/hyperswitch-control-center/commit/f5d246a3c1a9d1db3f42814089a589a482c78cd4))
- Moved Connector and Business Profile API call to SDK Page ([#2016](https://github.com/juspay/hyperswitch-control-center/pull/2016)) ([`57a8ea4`](https://github.com/juspay/hyperswitch-control-center/commit/57a8ea46ffb9a3d22c6fc9fcfbc4006cd178a806))
- Dropdown options for profile ([#2026](https://github.com/juspay/hyperswitch-control-center/pull/2026)) ([`ea4094e`](https://github.com/juspay/hyperswitch-control-center/commit/ea4094e52b79c808c3b147c955a06329b5d301da))

**Full Changelog:** [`2025.01.07.0...2025.01.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.07.0...2025.01.08.0)

- - -

## 2025.01.07.0

### Features

- New analytics filter utils changes ([#2011](https://github.com/juspay/hyperswitch-control-center/pull/2011)) ([`800d97f`](https://github.com/juspay/hyperswitch-control-center/commit/800d97fe62ad89eaa8c0e90a07860917d3e9e23d))

### Bug Fixes

- Api creds redesign ([#1991](https://github.com/juspay/hyperswitch-control-center/pull/1991)) ([`12b9ca2`](https://github.com/juspay/hyperswitch-control-center/commit/12b9ca224a9c2e173696f59d303413acb753e148))
- Made responsive ([#1994](https://github.com/juspay/hyperswitch-control-center/pull/1994)) ([`59ccd24`](https://github.com/juspay/hyperswitch-control-center/commit/59ccd24db68b2c9c26df6e48b68b3a7ecae49e6c))

### Miscellaneous Tasks

- Event logs ui enhancements ([#1998](https://github.com/juspay/hyperswitch-control-center/pull/1998)) ([`aca60b0`](https://github.com/juspay/hyperswitch-control-center/commit/aca60b07ea51c2a174c953c0868c3139715ba205))
- Switch merchant name fix ([#2020](https://github.com/juspay/hyperswitch-control-center/pull/2020)) ([`cb1cdb4`](https://github.com/juspay/hyperswitch-control-center/commit/cb1cdb455c7499237f13f819047a90cdba33da3c))

**Full Changelog:** [`2025.01.03.2...2025.01.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.03.2...2025.01.07.0)

- - -

## 2025.01.03.2

### Refactors

- Payment settings redesign ([#1996](https://github.com/juspay/hyperswitch-control-center/pull/1996)) ([`c009366`](https://github.com/juspay/hyperswitch-control-center/commit/c009366f5b22b36d06efe5200c7d57a440452c0a))

### Miscellaneous Tasks

- Added required tenant user checks ([#2008](https://github.com/juspay/hyperswitch-control-center/pull/2008)) ([`8144ae1`](https://github.com/juspay/hyperswitch-control-center/commit/8144ae1cc53a312b1b19555d73c486b30acb07db))

**Full Changelog:** [`2025.01.03.1...2025.01.03.2`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.03.1...2025.01.03.2)

- - -

## 2025.01.03.1

### Miscellaneous Tasks

- Support multitenancy domain ([#1979](https://github.com/juspay/hyperswitch-control-center/pull/1979)) ([`93f318c`](https://github.com/juspay/hyperswitch-control-center/commit/93f318cf33254a4fc9363834e727dc8243a0f52d))

**Full Changelog:** [`2025.01.03.0...2025.01.03.1`](https://github.com/juspay/hyperswitch-control-center/compare/2025.01.03.0...2025.01.03.1)

- - -

## 2025.01.03.0

### Features

- New analytics filter component ([#1962](https://github.com/juspay/hyperswitch-control-center/pull/1962)) ([`b754615`](https://github.com/juspay/hyperswitch-control-center/commit/b7546155c0705c04b1468e1985015b0ab24eaf53))

### Bug Fixes

- Get production access component visibility in sandbox ([#2000](https://github.com/juspay/hyperswitch-control-center/pull/2000)) ([`1636ab2`](https://github.com/juspay/hyperswitch-control-center/commit/1636ab21c37402d113a64db8a7794a67fe4655c6))

### Miscellaneous Tasks

- Invite users enhancement ([#1964](https://github.com/juspay/hyperswitch-control-center/pull/1964)) ([`b47d5f5`](https://github.com/juspay/hyperswitch-control-center/commit/b47d5f5626f16a2b42ddca103f6a9024d9a92ef1))
- Banner revamp ([#1990](https://github.com/juspay/hyperswitch-control-center/pull/1990)) ([`6cf5697`](https://github.com/juspay/hyperswitch-control-center/commit/6cf56970079a4354caa4e4dae7c6c14a9883e3f6))

**Full Changelog:** [`2024.12.31.0...2025.01.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.31.0...2025.01.03.0)

- - -

## 2024.12.31.0

### Features

- Enable google pay for airwallex ([#1976](https://github.com/juspay/hyperswitch-control-center/pull/1976)) ([`0138abe`](https://github.com/juspay/hyperswitch-control-center/commit/0138abe72e100d64421f615893645d4f9fbf7a3d))

### Bug Fixes

- Background color default config fix ([#1988](https://github.com/juspay/hyperswitch-control-center/pull/1988)) ([`f768696`](https://github.com/juspay/hyperswitch-control-center/commit/f768696c728627da95b299836f7ac5403c380a72))

### Refactors

- Refunds popup design ([#1983](https://github.com/juspay/hyperswitch-control-center/pull/1983)) ([`9c18971`](https://github.com/juspay/hyperswitch-control-center/commit/9c18971e4f9a5f8b162de393b55e01ded382f8dc))

### Miscellaneous Tasks

- Connector search results fix in routing ([#1984](https://github.com/juspay/hyperswitch-control-center/pull/1984)) ([`f88d360`](https://github.com/juspay/hyperswitch-control-center/commit/f88d360060f2de60fecab722833b6e863e0d2e3b))
- Update merchant name after sbx onbaording ([#1987](https://github.com/juspay/hyperswitch-control-center/pull/1987)) ([`1cc440b`](https://github.com/juspay/hyperswitch-control-center/commit/1cc440b0f5f54e202868680d79f97b5cc6781af0))

**Full Changelog:** [`2024.12.30.0...2024.12.31.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.30.0...2024.12.31.0)

- - -

## 2024.12.30.0

### Features

- Global search filters ux enhancements ([#1977](https://github.com/juspay/hyperswitch-control-center/pull/1977)) ([`cde0b70`](https://github.com/juspay/hyperswitch-control-center/commit/cde0b709b40061dbf0962ac6f087ff10b0c0a52d))

**Full Changelog:** [`2024.12.25.0...2024.12.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.25.0...2024.12.30.0)

- - -

## 2024.12.25.0

### Features

- New Theme Structure and Custom Style Integration ([#1958](https://github.com/juspay/hyperswitch-control-center/pull/1958)) ([`e15d0a1`](https://github.com/juspay/hyperswitch-control-center/commit/e15d0a167372b1784c1706751af0e66b0a881299))
- Recon Landing Page ([#1970](https://github.com/juspay/hyperswitch-control-center/pull/1970)) ([`9c1005b`](https://github.com/juspay/hyperswitch-control-center/commit/9c1005be2230804f94c321597a125190f08ef366))
- Added 3ds connector for click to pay - mastercard ([#1974](https://github.com/juspay/hyperswitch-control-center/pull/1974)) ([`09f68c9`](https://github.com/juspay/hyperswitch-control-center/commit/09f68c92ba108c376c9a5665b48d610ec20dab08))

### Bug Fixes

- Move disabled connectors at bottom ([#1949](https://github.com/juspay/hyperswitch-control-center/pull/1949)) ([`c278fbd`](https://github.com/juspay/hyperswitch-control-center/commit/c278fbdf6a9689966963c950226fabccb0d2d559))

### Refactors

- Separated payout processors files ([#1953](https://github.com/juspay/hyperswitch-control-center/pull/1953)) ([`3baac29`](https://github.com/juspay/hyperswitch-control-center/commit/3baac29e94d3393b31a0865397dbe2a4df2067f9))

### Miscellaneous Tasks

- Setup recon product ([#1966](https://github.com/juspay/hyperswitch-control-center/pull/1966)) ([`31bac54`](https://github.com/juspay/hyperswitch-control-center/commit/31bac5427d0b3f38fd1e6f85cf559ee5faf9a56e))
- Setup recon configuration ([#1972](https://github.com/juspay/hyperswitch-control-center/pull/1972)) ([`1bb4347`](https://github.com/juspay/hyperswitch-control-center/commit/1bb43476e5b24e64c0cf4058c85312b35969b9c7))

**Full Changelog:** [`2024.12.24.0...2024.12.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.24.0...2024.12.25.0)

- - -

## 2024.12.24.0

### Miscellaneous Tasks

- Show switch org input box for tenant admin ([#1925](https://github.com/juspay/hyperswitch-control-center/pull/1925)) ([`4f8af0e`](https://github.com/juspay/hyperswitch-control-center/commit/4f8af0ed3e51e51350b5c169a680856c2de1b177))

**Full Changelog:** [`2024.12.23.0...2024.12.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.23.0...2024.12.24.0)

- - -

## 2024.12.23.0

### Miscellaneous Tasks

- Moving business profile component to helper file ([#1959](https://github.com/juspay/hyperswitch-control-center/pull/1959)) ([`49471d3`](https://github.com/juspay/hyperswitch-control-center/commit/49471d3fb2dcaf43fd9b7dc72b7fdee96b81d0cf))

**Full Changelog:** [`2024.12.20.0...2024.12.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.20.0...2024.12.23.0)

- - -

## 2024.12.20.0

### Miscellaneous Tasks

- Add fiuu to prod ([#1956](https://github.com/juspay/hyperswitch-control-center/pull/1956)) ([`4addc3e`](https://github.com/juspay/hyperswitch-control-center/commit/4addc3e56af1672433a36499d6186ebc0c65000e))
- Omp views redesign changes ([#1894](https://github.com/juspay/hyperswitch-control-center/pull/1894)) ([`2dfb19a`](https://github.com/juspay/hyperswitch-control-center/commit/2dfb19a8e63f5374ebc61d9b9755054e06fc2f73))
- Omp views new analytics ([#1898](https://github.com/juspay/hyperswitch-control-center/pull/1898)) ([`b227695`](https://github.com/juspay/hyperswitch-control-center/commit/b2276953814e5089753bf3363c6c4a55a80217d7))

**Full Changelog:** [`2024.12.19.0...2024.12.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.19.0...2024.12.20.0)

- - -

## 2024.12.19.0

### Features

- Addition of new connector - Elavon ([#1950](https://github.com/juspay/hyperswitch-control-center/pull/1950)) ([`e5ee018`](https://github.com/juspay/hyperswitch-control-center/commit/e5ee018cb2126307b02635e6e0b9497444779c83))
- Add click to pay in payment settings ([#1927](https://github.com/juspay/hyperswitch-control-center/pull/1927)) ([`db89acf`](https://github.com/juspay/hyperswitch-control-center/commit/db89acf233da6960895185630e7c07fb36b7db3d))

### Refactors

- Invite user input ([#1919](https://github.com/juspay/hyperswitch-control-center/pull/1919)) ([`84cf9aa`](https://github.com/juspay/hyperswitch-control-center/commit/84cf9aa35af7a7a8b68b6890f56020ffa5cdd84b))
- Changed folder structure of connectors ([#1952](https://github.com/juspay/hyperswitch-control-center/pull/1952)) ([`e5bae80`](https://github.com/juspay/hyperswitch-control-center/commit/e5bae806282ef90fc8669c73cfb7f1c871a9a734))

**Full Changelog:** [`2024.12.18.0...2024.12.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.18.0...2024.12.19.0)

- - -

## 2024.12.18.0

### Features

- Refunds reasons ([#1941](https://github.com/juspay/hyperswitch-control-center/pull/1941)) ([`e93ba39`](https://github.com/juspay/hyperswitch-control-center/commit/e93ba39eab5f0c4cfee047dcb6fa320ce02f66f6))
- Refunds overview section ([#1932](https://github.com/juspay/hyperswitch-control-center/pull/1932)) ([`8f7bd7d`](https://github.com/juspay/hyperswitch-control-center/commit/8f7bd7d0c9c4b31a8a6fd27bfbc74643719c85a0))
- Refunds success distribution ([#1935](https://github.com/juspay/hyperswitch-control-center/pull/1935)) ([`fdab784`](https://github.com/juspay/hyperswitch-control-center/commit/fdab784075f146b3db70aa0561e850696043072f))
- Refunds failure distribution ([#1937](https://github.com/juspay/hyperswitch-control-center/pull/1937)) ([`bcf649b`](https://github.com/juspay/hyperswitch-control-center/commit/bcf649bb582d2e1bbf717b1b9a78d2249c44b654))
- Refunds failure reasons ([#1938](https://github.com/juspay/hyperswitch-control-center/pull/1938)) ([`971ecca`](https://github.com/juspay/hyperswitch-control-center/commit/971ecca6e97d0994603075bccee429fa36a3bd45))

### Bug Fixes

- Search box issues in "Connectors" pages ([#1942](https://github.com/juspay/hyperswitch-control-center/pull/1942)) ([`3690346`](https://github.com/juspay/hyperswitch-control-center/commit/3690346060b48ac23e4f4b05a4aaa4430276171c))
- List invitation error on logout from recon ([#1944](https://github.com/juspay/hyperswitch-control-center/pull/1944)) ([`939457d`](https://github.com/juspay/hyperswitch-control-center/commit/939457d996c07eea31f4de25858cfe0939af602d))

**Full Changelog:** [`2024.12.17.1...2024.12.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.17.1...2024.12.18.0)

- - -

## 2024.12.17.1

### Miscellaneous Tasks

- Package update ([#1946](https://github.com/juspay/hyperswitch-control-center/pull/1946)) ([`8c8a444`](https://github.com/juspay/hyperswitch-control-center/commit/8c8a4441886bfa47590b3a81de35adbca30d2fb6))

**Full Changelog:** [`2024.12.17.0...2024.12.17.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.17.0...2024.12.17.1)

- - -

## 2024.12.17.0

### Features

- Additional recipients in generate report ([#1911](https://github.com/juspay/hyperswitch-control-center/pull/1911)) ([`73478b5`](https://github.com/juspay/hyperswitch-control-center/commit/73478b58de6b762ee3db76d258d27f7325f706f0))
- Refunds amount count module ([#1915](https://github.com/juspay/hyperswitch-control-center/pull/1915)) ([`3493139`](https://github.com/juspay/hyperswitch-control-center/commit/3493139c91f8a0256983dd2937ed156e62960403))

### Bug Fixes

- Removing unused feature flags ([#1920](https://github.com/juspay/hyperswitch-control-center/pull/1920)) ([`1a55514`](https://github.com/juspay/hyperswitch-control-center/commit/1a555148efe72b01bab729db84d3d8bb17c8803a))

**Full Changelog:** [`2024.12.16.0...2024.12.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.16.0...2024.12.17.0)

- - -

## 2024.12.16.0

### Features

- Refunds success rate ([#1917](https://github.com/juspay/hyperswitch-control-center/pull/1917)) ([`4693520`](https://github.com/juspay/hyperswitch-control-center/commit/4693520ea4ac550d510d2f15fe2d01c5ba5c925b))

### Bug Fixes

- Handle recon-iframe logout in dashboard ([#1914](https://github.com/juspay/hyperswitch-control-center/pull/1914)) ([`dc07d46`](https://github.com/juspay/hyperswitch-control-center/commit/dc07d46a0e0098b3e4162d48d4c7879a3df35aa3))

**Full Changelog:** [`2024.12.13.1...2024.12.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.13.1...2024.12.16.0)

- - -

## 2024.12.13.1

### Bug Fixes

- Separate section custom headers ([#1916](https://github.com/juspay/hyperswitch-control-center/pull/1916)) ([`d86074a`](https://github.com/juspay/hyperswitch-control-center/commit/d86074ab9e3cd85aab2ba79c12b5e2451693cc59))

### Miscellaneous Tasks

- Refunds analytics v2 file refactor ([#1913](https://github.com/juspay/hyperswitch-control-center/pull/1913)) ([`16761f4`](https://github.com/juspay/hyperswitch-control-center/commit/16761f4c510a477f54c2dc49ed0ace391f45eae2))

**Full Changelog:** [`2024.12.13.0...2024.12.13.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.13.0...2024.12.13.1)

- - -

## 2024.12.13.0

### Features

- New analytics refunds tab ([#1889](https://github.com/juspay/hyperswitch-control-center/pull/1889)) ([`fc5392f`](https://github.com/juspay/hyperswitch-control-center/commit/fc5392f0079c0961def238df1cc1ee96c714202e))

### Miscellaneous Tasks

- New analytics text font and color changes ([#1902](https://github.com/juspay/hyperswitch-control-center/pull/1902)) ([`054b6c4`](https://github.com/juspay/hyperswitch-control-center/commit/054b6c47b5c7d2fd09c901e638da9a32d5792c4e))

**Full Changelog:** [`2024.12.12.2...2024.12.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.12.2...2024.12.13.0)

- - -

## 2024.12.12.2

### Features

- New pill input type ([#1901](https://github.com/juspay/hyperswitch-control-center/pull/1901)) ([`9c4c673`](https://github.com/juspay/hyperswitch-control-center/commit/9c4c673eb60454a723ee39219792a160f16a1152))

### Bug Fixes

- Custom http headers ([#1910](https://github.com/juspay/hyperswitch-control-center/pull/1910)) ([`4fcbce6`](https://github.com/juspay/hyperswitch-control-center/commit/4fcbce62ebac9432f68c084a81fa74c99c6f7da5))

**Full Changelog:** [`2024.12.12.1...2024.12.12.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.12.1...2024.12.12.2)

- - -

## 2024.12.12.1

### Features

- Update custom webhook headers ([#1908](https://github.com/juspay/hyperswitch-control-center/pull/1908)) ([`39b0bb0`](https://github.com/juspay/hyperswitch-control-center/commit/39b0bb0ed314957b312541fd3f38651f810251a6))

**Full Changelog:** [`2024.12.12.0...2024.12.12.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.12.0...2024.12.12.1)

- - -

## 2024.12.12.0

### Bug Fixes

- Amount Filter bug ([#1900](https://github.com/juspay/hyperswitch-control-center/pull/1900)) ([`5761c53`](https://github.com/juspay/hyperswitch-control-center/commit/5761c53c5804095b01262b1a19bfe3db03c40fe6))

**Full Changelog:** [`2024.12.10.0...2024.12.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.10.0...2024.12.12.0)

- - -

## 2024.12.10.0

### Bug Fixes

- Analytics minor changes ([#1897](https://github.com/juspay/hyperswitch-control-center/pull/1897)) ([`feae8ba`](https://github.com/juspay/hyperswitch-control-center/commit/feae8baa147b837ec75783445327990593214579))

**Full Changelog:** [`2024.12.09.2...2024.12.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.09.2...2024.12.10.0)

- - -

## 2024.12.09.2

### Features

- Paymants failure reasons ([#1892](https://github.com/juspay/hyperswitch-control-center/pull/1892)) ([`807e047`](https://github.com/juspay/hyperswitch-control-center/commit/807e0478b06f05168bd78365ced8df302f1b13f8))

**Full Changelog:** [`2024.12.09.1...2024.12.09.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.09.1...2024.12.09.2)

- - -

## 2024.12.09.1

### Features

- Merchant Reference ID filter PaymentOps ([#1807](https://github.com/juspay/hyperswitch-control-center/pull/1807)) ([`7164693`](https://github.com/juspay/hyperswitch-control-center/commit/7164693da549cfc34578aafc616c587baaef1e14))
- Smart retry amount analytics ([#1872](https://github.com/juspay/hyperswitch-control-center/pull/1872)) ([`c5c5542`](https://github.com/juspay/hyperswitch-control-center/commit/c5c554284ede550bc527fbf11bd834d0276f7b26))
- Successful smart retry distribution ([#1882](https://github.com/juspay/hyperswitch-control-center/pull/1882)) ([`72602c1`](https://github.com/juspay/hyperswitch-control-center/commit/72602c167daae61d5146c277de2ea2f9a602e1b3))
- New analytics smart retry failure distribution ([#1886](https://github.com/juspay/hyperswitch-control-center/pull/1886)) ([`698e17a`](https://github.com/juspay/hyperswitch-control-center/commit/698e17a6c6a12ac492c82c564a562354fb793466))
- Smart retry analytics modules ([#1890](https://github.com/juspay/hyperswitch-control-center/pull/1890)) ([`5b1b2e9`](https://github.com/juspay/hyperswitch-control-center/commit/5b1b2e99497ba200e634b19d3953453007afe55b))
- Refunds amount filter and UI enhancements ([#1884](https://github.com/juspay/hyperswitch-control-center/pull/1884)) ([`2134cbf`](https://github.com/juspay/hyperswitch-control-center/commit/2134cbf6b41d2f2744909ed4872c2d6323a11ecc))

### Bug Fixes

- Truncate cols of connector transaction ID in Payment ops ([#1855](https://github.com/juspay/hyperswitch-control-center/pull/1855)) ([`b481bd8`](https://github.com/juspay/hyperswitch-control-center/commit/b481bd8cc4883505861c9672eabbd23ab7eb40bb))
- Amount Filter Validations and Changes ([#1869](https://github.com/juspay/hyperswitch-control-center/pull/1869)) ([`e2d1591`](https://github.com/juspay/hyperswitch-control-center/commit/e2d15915f75b26666da50957e9c14be8522cfe64))

### Miscellaneous Tasks

- Updated api endpoints /removed v2 urls ([#1515](https://github.com/juspay/hyperswitch-control-center/pull/1515)) ([`70881b4`](https://github.com/juspay/hyperswitch-control-center/commit/70881b47c871f6d2414f93afb3c1d5814b2fd55f))
- Smart retry tab code ([#1865](https://github.com/juspay/hyperswitch-control-center/pull/1865)) ([`25c9d23`](https://github.com/juspay/hyperswitch-control-center/commit/25c9d2394cdf3aafb5739c169dfc4364259f3f07))
- New analytics bar file refactor ([#1880](https://github.com/juspay/hyperswitch-control-center/pull/1880)) ([`71714a4`](https://github.com/juspay/hyperswitch-control-center/commit/71714a41eea537241dff4630f69ea355f73d8bf2))

**Full Changelog:** [`2024.12.09.0...2024.12.09.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.09.0...2024.12.09.1)

- - -

## 2024.12.09.0

### Bug Fixes

- Update list on accept invite ([#1873](https://github.com/juspay/hyperswitch-control-center/pull/1873)) ([`945ce14`](https://github.com/juspay/hyperswitch-control-center/commit/945ce14bab0c7a95170bf4ad72509b76a102049c))

### Miscellaneous Tasks

- Organize transaction modules ([#1876](https://github.com/juspay/hyperswitch-control-center/pull/1876)) ([`58e3731`](https://github.com/juspay/hyperswitch-control-center/commit/58e37314a3911f235fe619521940660fdeec58df))

**Full Changelog:** [`2024.12.06.1...2024.12.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.06.1...2024.12.09.0)

- - -

## 2024.12.06.1

### Miscellaneous Tasks

- Percentage calculation changes ([#1870](https://github.com/juspay/hyperswitch-control-center/pull/1870)) ([`6cddccc`](https://github.com/juspay/hyperswitch-control-center/commit/6cddccc5b19966c0abe0288caddf92b8ecb4af66))

**Full Changelog:** [`2024.12.06.0...2024.12.06.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.06.0...2024.12.06.1)

- - -

## 2024.12.06.0

### Miscellaneous Tasks

- New analytics code refactor ([#1856](https://github.com/juspay/hyperswitch-control-center/pull/1856)) ([`30e223f`](https://github.com/juspay/hyperswitch-control-center/commit/30e223f2d5cc70c0bf200937a3c23c765bac780e))

**Full Changelog:** [`2024.12.05.0...2024.12.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.05.0...2024.12.06.0)

- - -

## 2024.12.05.0

### Features

- Paze additional details ([#1835](https://github.com/juspay/hyperswitch-control-center/pull/1835)) ([`ecdffa2`](https://github.com/juspay/hyperswitch-control-center/commit/ecdffa2dca940099154d15220ce505dfbca27b8f))

### Refactors

- Recon - update recon resources for rendering sidebar values based on permissions ([#1787](https://github.com/juspay/hyperswitch-control-center/pull/1787)) ([`bba3315`](https://github.com/juspay/hyperswitch-control-center/commit/bba33153a46cae32850b44a22655e6dcc864ee9c))

**Full Changelog:** [`2024.12.04.1...2024.12.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.04.1...2024.12.05.0)

- - -

## 2024.12.04.1

### Features

- Multitenancy changes to support tenant entity ([#1641](https://github.com/juspay/hyperswitch-control-center/pull/1641)) ([`84dcdf0`](https://github.com/juspay/hyperswitch-control-center/commit/84dcdf0820f8913c958d4fe5a7e384ba98769961))

### Bug Fixes

- Global search filters feature flag ([#1851](https://github.com/juspay/hyperswitch-control-center/pull/1851)) ([`64c8647`](https://github.com/juspay/hyperswitch-control-center/commit/64c8647452da211f96cd28e1a63c7176c4a30f7d))
- Horizontal scroll in views ([#1830](https://github.com/juspay/hyperswitch-control-center/pull/1830)) ([`b017689`](https://github.com/juspay/hyperswitch-control-center/commit/b01768924e108e6535b7b5f6fbbf9050c9bcf910))

### Miscellaneous Tasks

- Refactoring ops utils file ([#1590](https://github.com/juspay/hyperswitch-control-center/pull/1590)) ([`fa199af`](https://github.com/juspay/hyperswitch-control-center/commit/fa199af6e3b1760ca743b7b7c318d9fcfb4e45f9))
- New analytics minor changes ([#1853](https://github.com/juspay/hyperswitch-control-center/pull/1853)) ([`dcf82b0`](https://github.com/juspay/hyperswitch-control-center/commit/dcf82b004da3de2483edfced5f37c27a1eb2c98a))

**Full Changelog:** [`2024.12.04.0...2024.12.04.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.04.0...2024.12.04.1)

- - -

## 2024.12.04.0

### Miscellaneous Tasks

- Hiding org merchant dropdown for internal user ([#1843](https://github.com/juspay/hyperswitch-control-center/pull/1843)) ([`c411e40`](https://github.com/juspay/hyperswitch-control-center/commit/c411e40d3c792fbba1d760d7c53562a209cf98f4))
- Global search filters list update ([#1847](https://github.com/juspay/hyperswitch-control-center/pull/1847)) ([`b3672d1`](https://github.com/juspay/hyperswitch-control-center/commit/b3672d1ca89952705fc714692d38ce2febba6f4e))

**Full Changelog:** [`2024.12.03.1...2024.12.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.03.1...2024.12.04.0)

- - -

## 2024.12.03.1

### Bug Fixes

- Refunds amount overview fix ([#1838](https://github.com/juspay/hyperswitch-control-center/pull/1838)) ([`2224f61`](https://github.com/juspay/hyperswitch-control-center/commit/2224f6169a4b59c7c6fd872597f06fc56902511d))
- Global search on key press fix ([#1840](https://github.com/juspay/hyperswitch-control-center/pull/1840)) ([`de5304c`](https://github.com/juspay/hyperswitch-control-center/commit/de5304cb7a037d054b5b1e0ef26d6539343c977a))

**Full Changelog:** [`2024.12.03.0...2024.12.03.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.12.03.0...2024.12.03.1)

- - -

## 2024.12.03.0

### Bug Fixes

- Global search fixes ([#1832](https://github.com/juspay/hyperswitch-control-center/pull/1832)) ([`b670e71`](https://github.com/juspay/hyperswitch-control-center/commit/b670e718d424f5d7cf19e5ad6d94b5a436aa7878))

**Full Changelog:** [`2024.11.29.3...2024.12.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.29.3...2024.12.03.0)

- - -

## 2024.11.29.3

### Bug Fixes

- Amount filter validation ([#1834](https://github.com/juspay/hyperswitch-control-center/pull/1834)) ([`8be6040`](https://github.com/juspay/hyperswitch-control-center/commit/8be6040a9af511e48ad7abd78f8475ea6f7940da))

**Full Changelog:** [`2024.11.29.2...2024.11.29.3`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.29.2...2024.11.29.3)

- - -

## 2024.11.29.2

### Bug Fixes

- Tooltip fix for date range component ([#1821](https://github.com/juspay/hyperswitch-control-center/pull/1821)) ([`b797a6a`](https://github.com/juspay/hyperswitch-control-center/commit/b797a6a98c3a5a531701823f9a87345a251480cd))
- Date range compare component end time fix 00:00 to 59.59 ([#1824](https://github.com/juspay/hyperswitch-control-center/pull/1824)) ([`dfdcd9c`](https://github.com/juspay/hyperswitch-control-center/commit/dfdcd9c9017d792954f92178451e83fba41feebe))

### Miscellaneous Tasks

- Omp remove copy icon ([#1826](https://github.com/juspay/hyperswitch-control-center/pull/1826)) ([`0216973`](https://github.com/juspay/hyperswitch-control-center/commit/021697341a08ebb66ce2eef63fa678fa4599ddc3))

**Full Changelog:** [`2024.11.29.1...2024.11.29.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.29.1...2024.11.29.2)

- - -

## 2024.11.29.1

### Features

- Payment Operations Amount Filter ([#1796](https://github.com/juspay/hyperswitch-control-center/pull/1796)) ([`8102096`](https://github.com/juspay/hyperswitch-control-center/commit/8102096df30e078d93fe7645ac9595ea838ae84b))

### Bug Fixes

- Sidebar-active-selection-resolution ([#1813](https://github.com/juspay/hyperswitch-control-center/pull/1813)) ([`41972e3`](https://github.com/juspay/hyperswitch-control-center/commit/41972e310ca90cf0b6bcfa6cde27b5dd7c5a0e59))

### Miscellaneous Tasks

- Redesign omp dropdowns ([#1785](https://github.com/juspay/hyperswitch-control-center/pull/1785)) ([`e2789d9`](https://github.com/juspay/hyperswitch-control-center/commit/e2789d9680f7ed9bd2e23393ab3ceb2a4d491c8e))

**Full Changelog:** [`2024.11.29.0...2024.11.29.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.29.0...2024.11.29.1)

- - -

## 2024.11.29.0

### Miscellaneous Tasks

- Minor modification for enhancement and bugfix ([#1815](https://github.com/juspay/hyperswitch-control-center/pull/1815)) ([`491271f`](https://github.com/juspay/hyperswitch-control-center/commit/491271f20334455a497c6c5267548c9969f0236d))

**Full Changelog:** [`2024.11.28.1...2024.11.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.28.1...2024.11.29.0)

- - -

## 2024.11.28.1

### Bug Fixes

- Sanky flow chart change and tooltip ui advancements ([#1820](https://github.com/juspay/hyperswitch-control-center/pull/1820)) ([`868d15b`](https://github.com/juspay/hyperswitch-control-center/commit/868d15beaf5c01462c03d856124f72492be2c1e4))

**Full Changelog:** [`2024.11.28.0...2024.11.28.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.28.0...2024.11.28.1)

- - -

## 2024.11.28.0

### Bug Fixes

- Move columns in payment operations ([#1819](https://github.com/juspay/hyperswitch-control-center/pull/1819)) ([`aeeb226`](https://github.com/juspay/hyperswitch-control-center/commit/aeeb226394600757d87db8b32d7d5f1b7bd44dbc))
- Global search filters access check ([#1816](https://github.com/juspay/hyperswitch-control-center/pull/1816)) ([`5705b5d`](https://github.com/juspay/hyperswitch-control-center/commit/5705b5d50343b0f63da4a6a7bbe312c92865fdde))
- Horizontal Scrollbar to Tables ([#1811](https://github.com/juspay/hyperswitch-control-center/pull/1811)) ([`3299a22`](https://github.com/juspay/hyperswitch-control-center/commit/3299a221f19383ade404a144acc7972e9e82e6c7))

### Miscellaneous Tasks

- Fix admin permission to create new omp ([#1747](https://github.com/juspay/hyperswitch-control-center/pull/1747)) ([`12843a5`](https://github.com/juspay/hyperswitch-control-center/commit/12843a5e659ca2653273301ef6562e5e482d8da6))
- Added ref for user-info to get updated data ([#1804](https://github.com/juspay/hyperswitch-control-center/pull/1804)) ([`1bd5f44`](https://github.com/juspay/hyperswitch-control-center/commit/1bd5f44ce6e7c75cabee62846d68462e96aa76ba))

**Full Changelog:** [`2024.11.27.1...2024.11.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.27.1...2024.11.28.0)

- - -

## 2024.11.27.1

### Features

- **authn:** Enable cookies ([#1810](https://github.com/juspay/hyperswitch-control-center/pull/1810)) ([`e88a857`](https://github.com/juspay/hyperswitch-control-center/commit/e88a8570ba00c40bcb24832ba1bc05d8cb6b2273))

**Full Changelog:** [`2024.11.27.0...2024.11.27.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.27.0...2024.11.27.1)

- - -

## 2024.11.27.0

### Bug Fixes

- Changed global search date range fix ([#1803](https://github.com/juspay/hyperswitch-control-center/pull/1803)) ([`70dc324`](https://github.com/juspay/hyperswitch-control-center/commit/70dc324e7724a2c980b9eee00ca98049c0cf76f3))

### Miscellaneous Tasks

- Disabled access to test payment not having operation manage ([#1794](https://github.com/juspay/hyperswitch-control-center/pull/1794)) ([`82d2e40`](https://github.com/juspay/hyperswitch-control-center/commit/82d2e40a0fb7c7a0c84a4e65e4c5cee979854e5e))

**Full Changelog:** [`2024.11.25.2...2024.11.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.25.2...2024.11.27.0)

- - -

## 2024.11.25.2

### Features

- Frontend invite limit ([#1689](https://github.com/juspay/hyperswitch-control-center/pull/1689)) ([`022b229`](https://github.com/juspay/hyperswitch-control-center/commit/022b2291c0ca098e310c896e9b4b1c696c019255))

### Bug Fixes

- Sdk fix pr ([#1788](https://github.com/juspay/hyperswitch-control-center/pull/1788)) ([`f5b49d8`](https://github.com/juspay/hyperswitch-control-center/commit/f5b49d8cc750d70ae65ec8d2edabbce693513314))
- Analytics table data display changes and distribution cols order change ([#1773](https://github.com/juspay/hyperswitch-control-center/pull/1773)) ([`aa0fb1d`](https://github.com/juspay/hyperswitch-control-center/commit/aa0fb1d7e0b4584341bed402eafb28748eace7cb))
- Error on sdk page when no payment connector connected ([#1776](https://github.com/juspay/hyperswitch-control-center/pull/1776)) ([`9bb9284`](https://github.com/juspay/hyperswitch-control-center/commit/9bb9284fcca79a59564a8edf4830bba6b20ced51))
- Global search enter listener ([#1797](https://github.com/juspay/hyperswitch-control-center/pull/1797)) ([`ec03f6d`](https://github.com/juspay/hyperswitch-control-center/commit/ec03f6d693fb08e9a89e2448937c8a343e787070))

### Miscellaneous Tasks

- Design feedback changes ([#1768](https://github.com/juspay/hyperswitch-control-center/pull/1768)) ([`331c4cc`](https://github.com/juspay/hyperswitch-control-center/commit/331c4cc29646c785875dfdfb2744a992301f1ece))
- Analytic amount metrics ([#1791](https://github.com/juspay/hyperswitch-control-center/pull/1791)) ([`bb0674b`](https://github.com/juspay/hyperswitch-control-center/commit/bb0674b85e2a13d0dcb33cc473bf5fe3b50e57cd))
- Url path after OMP switch ([#1770](https://github.com/juspay/hyperswitch-control-center/pull/1770)) ([`db22304`](https://github.com/juspay/hyperswitch-control-center/commit/db22304eff24d29171aaabc17d5bf5c14b871739))
- Enable we domain for fiuu apple pay ([#1793](https://github.com/juspay/hyperswitch-control-center/pull/1793)) ([`6af0622`](https://github.com/juspay/hyperswitch-control-center/commit/6af0622502a957f2bfe8dffb83bc090f5682e02b))

**Full Changelog:** [`2024.11.25.1...2024.11.25.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.25.1...2024.11.25.2)

- - -

## 2024.11.25.1

### Features

- Fiuu connector added note part ([#1777](https://github.com/juspay/hyperswitch-control-center/pull/1777)) ([`a8ce191`](https://github.com/juspay/hyperswitch-control-center/commit/a8ce1914a172f6f003440454137253b808e058ff))
- Global search categories suggestions ([#1734](https://github.com/juspay/hyperswitch-control-center/pull/1734)) ([`735c74a`](https://github.com/juspay/hyperswitch-control-center/commit/735c74a996f79bd1c868f4b888818bdbc40e86de))

### Bug Fixes

- Analytics refunds amount usd conversion fix ([#1778](https://github.com/juspay/hyperswitch-control-center/pull/1778)) ([`c598653`](https://github.com/juspay/hyperswitch-control-center/commit/c59865324499d619979844876e996d62cd1194da))

**Full Changelog:** [`2024.11.25.0...2024.11.25.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.25.0...2024.11.25.1)

- - -

## 2024.11.25.0

### Miscellaneous Tasks

- Reverting routing filtering connector list changes ([#1781](https://github.com/juspay/hyperswitch-control-center/pull/1781)) ([`c5126a0`](https://github.com/juspay/hyperswitch-control-center/commit/c5126a07e202a1395e237c5dd3d5a08b1ec6bc15))

**Full Changelog:** [`2024.11.21.0...2024.11.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.21.0...2024.11.25.0)

- - -

## 2024.11.21.0

### Bug Fixes

- Customer ID remove key ([#1769](https://github.com/juspay/hyperswitch-control-center/pull/1769)) ([`1e7105c`](https://github.com/juspay/hyperswitch-control-center/commit/1e7105c6075b00f70c98530056699b6fccaa89a4))

**Full Changelog:** [`2024.11.20.0...2024.11.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.20.0...2024.11.21.0)

- - -

## 2024.11.20.0

### Features

- **assets:** Add welcome email assets ([#1763](https://github.com/juspay/hyperswitch-control-center/pull/1763)) ([`f27529a`](https://github.com/juspay/hyperswitch-control-center/commit/f27529a52d97a445be621e29bf3892ea5387561a))
- Customer ID filter ([#1746](https://github.com/juspay/hyperswitch-control-center/pull/1746)) ([`d409b01`](https://github.com/juspay/hyperswitch-control-center/commit/d409b017a2f64f2a103530a2a685c5a43ec4b38d))

### Bug Fixes

- Default routing connector list extraction changes ([#1765](https://github.com/juspay/hyperswitch-control-center/pull/1765)) ([`0c4fc5d`](https://github.com/juspay/hyperswitch-control-center/commit/0c4fc5dbad9c6c38988a9f12bac7263ebe18b513))

**Full Changelog:** [`2024.11.19.1...2024.11.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.19.1...2024.11.20.0)

- - -

## 2024.11.19.1

### Features

- Dispute count analytics for new analytics overview section ([#1759](https://github.com/juspay/hyperswitch-control-center/pull/1759)) ([`0ca639a`](https://github.com/juspay/hyperswitch-control-center/commit/0ca639aacdb8d395b3cffd1af6da95b36f241365))

### Bug Fixes

- Docker build ([`4b027be`](https://github.com/juspay/hyperswitch-control-center/commit/4b027bef47e90e27444bf206a17dae50c39415c2))
- Totp error toast ([#1756](https://github.com/juspay/hyperswitch-control-center/pull/1756)) ([`1ad7cae`](https://github.com/juspay/hyperswitch-control-center/commit/1ad7caeca3aff13266c7a3ab97b242560c7fc698))
- Filter sessionized metrics ([#1761](https://github.com/juspay/hyperswitch-control-center/pull/1761)) ([`8ab03a6`](https://github.com/juspay/hyperswitch-control-center/commit/8ab03a699a2e3749d19b65b42a1f99ba6d4d2f12))

**Full Changelog:** [`2024.11.19.0...2024.11.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.19.0...2024.11.19.1)

- - -

## 2024.11.19.0

### Bug Fixes

- Email case insensitive ([#1727](https://github.com/juspay/hyperswitch-control-center/pull/1727)) ([`e9d5b2f`](https://github.com/juspay/hyperswitch-control-center/commit/e9d5b2f370b127fa9e7eb391bca327773a258759))
- Payment prosecces count fix ([#1745](https://github.com/juspay/hyperswitch-control-center/pull/1745)) ([`87f090a`](https://github.com/juspay/hyperswitch-control-center/commit/87f090a180e512b122622c85d74caa5634ecec1c))

### Miscellaneous Tasks

- Removing api call not required on sdk page ([#1753](https://github.com/juspay/hyperswitch-control-center/pull/1753)) ([`c2cb225`](https://github.com/juspay/hyperswitch-control-center/commit/c2cb225cb9cd3a32eb04fbd5e76faf502915498a))

**Full Changelog:** [`2024.11.18.0...2024.11.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.18.0...2024.11.19.0)

- - -

## 2024.11.18.0

### Bug Fixes

- Filter routing connector list ([#1717](https://github.com/juspay/hyperswitch-control-center/pull/1717)) ([`5362c68`](https://github.com/juspay/hyperswitch-control-center/commit/5362c6817e8bc45bdc51e832c49397fcf741c333))
- List profile api ([#1748](https://github.com/juspay/hyperswitch-control-center/pull/1748)) ([`ee8eee2`](https://github.com/juspay/hyperswitch-control-center/commit/ee8eee2c37c84b332a8e9eeda0a5546a3a62221a))
- Login cancel link fix ([#1749](https://github.com/juspay/hyperswitch-control-center/pull/1749)) ([`06093d6`](https://github.com/juspay/hyperswitch-control-center/commit/06093d62e878613e6e5d1b0da934056d2d49003d))

### Miscellaneous Tasks

- Remove duplicate api calls ([#1687](https://github.com/juspay/hyperswitch-control-center/pull/1687)) ([`0fb965e`](https://github.com/juspay/hyperswitch-control-center/commit/0fb965e84b67e7768c141063b6faf22d5d85f56e))

**Full Changelog:** [`2024.11.15.0...2024.11.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.15.0...2024.11.18.0)

- - -

## 2024.11.15.0

### Bug Fixes

- Metric value change ([#1740](https://github.com/juspay/hyperswitch-control-center/pull/1740)) ([`341a3c4`](https://github.com/juspay/hyperswitch-control-center/commit/341a3c46de62d4869e59d37fcdbe6d215013eb32))

**Full Changelog:** [`2024.11.14.1...2024.11.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.14.1...2024.11.15.0)

- - -

## 2024.11.14.1

### Miscellaneous Tasks

- Sankey single value fix ([#1736](https://github.com/juspay/hyperswitch-control-center/pull/1736)) ([`fcf906d`](https://github.com/juspay/hyperswitch-control-center/commit/fcf906d434250577bc2da2eaaa437497ab9e4379))

**Full Changelog:** [`2024.11.14.0...2024.11.14.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.14.0...2024.11.14.1)

- - -

## 2024.11.14.0

### Features

- Profile id search ([#1719](https://github.com/juspay/hyperswitch-control-center/pull/1719)) ([`85344dd`](https://github.com/juspay/hyperswitch-control-center/commit/85344dd6a5e475d30d903bd1d5cfa7e3142f6583))
- Update org name ([#1669](https://github.com/juspay/hyperswitch-control-center/pull/1669)) ([`8b53637`](https://github.com/juspay/hyperswitch-control-center/commit/8b53637061fd954eae9ed93f9ede9051e9265fc2))

### Bug Fixes

- Bug fixes for two-fa restriction ([#1708](https://github.com/juspay/hyperswitch-control-center/pull/1708)) ([`e19f167`](https://github.com/juspay/hyperswitch-control-center/commit/e19f167b46219f23a28d6578f4efd179cebd199d))
- Analytics minor bugs ([#1732](https://github.com/juspay/hyperswitch-control-center/pull/1732)) ([`f981ccb`](https://github.com/juspay/hyperswitch-control-center/commit/f981ccbebcc2d2c12ef78b26b4c34af5c00430d4))

**Full Changelog:** [`2024.11.13.0...2024.11.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.13.0...2024.11.14.0)

- - -

## 2024.11.13.0

### Bug Fixes

- Read write ordering consistency ([#1685](https://github.com/juspay/hyperswitch-control-center/pull/1685)) ([`dfb7e02`](https://github.com/juspay/hyperswitch-control-center/commit/dfb7e02fff0c9db55b9143c04e98d176b007461a))
- Show role name for custom roles ([#1701](https://github.com/juspay/hyperswitch-control-center/pull/1701)) ([`8bfc04b`](https://github.com/juspay/hyperswitch-control-center/commit/8bfc04b1c9a5921875d2318d57a3c8065d3f730a))
- Sankey ui fixes ([#1722](https://github.com/juspay/hyperswitch-control-center/pull/1722)) ([`38fd02a`](https://github.com/juspay/hyperswitch-control-center/commit/38fd02aef24851e31bf6747924402722683bfdaa))
- Payment processed USD string fix ([#1725](https://github.com/juspay/hyperswitch-control-center/pull/1725)) ([`509e7ad`](https://github.com/juspay/hyperswitch-control-center/commit/509e7ad3e8e5c61194057c05e8e430bef75d8705))

**Full Changelog:** [`2024.11.12.0...2024.11.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.12.0...2024.11.13.0)

- - -

## 2024.11.12.0

### Bug Fixes

- Compare date range component minor fixes ([#1716](https://github.com/juspay/hyperswitch-control-center/pull/1716)) ([`5bb44e3`](https://github.com/juspay/hyperswitch-control-center/commit/5bb44e3c5a03bca60030411e92fa1513e6c732fb))
- Sankey flow chart count fix ([#1711](https://github.com/juspay/hyperswitch-control-center/pull/1711)) ([`abddad9`](https://github.com/juspay/hyperswitch-control-center/commit/abddad9370d2ba847ee3f4cc38053d80cedcbc6c))
- Handle logout ([#1710](https://github.com/juspay/hyperswitch-control-center/pull/1710)) ([`469e272`](https://github.com/juspay/hyperswitch-control-center/commit/469e272d56b4deecd18653f0abb0bbac38ccdfe7))

**Full Changelog:** [`2024.11.11.1...2024.11.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.11.1...2024.11.12.0)

- - -

## 2024.11.11.1

### Features

- Sanky flow chart change ([#1695](https://github.com/juspay/hyperswitch-control-center/pull/1695)) ([`f8d4aae`](https://github.com/juspay/hyperswitch-control-center/commit/f8d4aae9ea0fc9ff932a0d93909b9de182d14fd9))
- Add functionality to force two-fa ([#1697](https://github.com/juspay/hyperswitch-control-center/pull/1697)) ([`d478424`](https://github.com/juspay/hyperswitch-control-center/commit/d4784242112bc51b8d921e10c09a0f78a2143b62))
- Change password feature ([#1700](https://github.com/juspay/hyperswitch-control-center/pull/1700)) ([`b51680c`](https://github.com/juspay/hyperswitch-control-center/commit/b51680cd0f0ba2e6622c3090f80636e6a418bb0c))

### Bug Fixes

- Analytics revamp bug fixes ([#1703](https://github.com/juspay/hyperswitch-control-center/pull/1703)) ([`d78dee1`](https://github.com/juspay/hyperswitch-control-center/commit/d78dee1415221de04043f3871f100a0c54700cb6))

### Miscellaneous Tasks

- Bar graph tooltip enhancement ([#1704](https://github.com/juspay/hyperswitch-control-center/pull/1704)) ([`eb37c2f`](https://github.com/juspay/hyperswitch-control-center/commit/eb37c2f3fb28c11ad8eda66ec456cb3bd375db69))
- Update mixpanel details ([#1684](https://github.com/juspay/hyperswitch-control-center/pull/1684)) ([`aad2309`](https://github.com/juspay/hyperswitch-control-center/commit/aad2309f8bd0c752f5a4343bf211bb71af731a02))

**Full Changelog:** [`2024.11.11.0...2024.11.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.11.0...2024.11.11.1)

- - -

## 2024.11.11.0

### Refactors

- Cluttered package json refactor ([#1649](https://github.com/juspay/hyperswitch-control-center/pull/1649)) ([`214c806`](https://github.com/juspay/hyperswitch-control-center/commit/214c806d9860ecf16b390d9db1f22a03fe8ed0c0))

**Full Changelog:** [`2024.11.08.0...2024.11.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.08.0...2024.11.11.0)

- - -

## 2024.11.08.0

### Features

- Analytics payment processed currency conversion ([#1691](https://github.com/juspay/hyperswitch-control-center/pull/1691)) ([`19d2c70`](https://github.com/juspay/hyperswitch-control-center/commit/19d2c702bcdea931c2de5d937989b6d8639c8c49))

**Full Changelog:** [`2024.11.07.1...2024.11.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.07.1...2024.11.08.0)

- - -

## 2024.11.07.1

### Bug Fixes

- Compare filter date display fix to ISO format ([#1692](https://github.com/juspay/hyperswitch-control-center/pull/1692)) ([`eb2ea9c`](https://github.com/juspay/hyperswitch-control-center/commit/eb2ea9cbe471dc3e45b9bec6ea48b0a73e62540e))

### Miscellaneous Tasks

- Disable cookies from frontend ([#1657](https://github.com/juspay/hyperswitch-control-center/pull/1657)) ([`f3f4416`](https://github.com/juspay/hyperswitch-control-center/commit/f3f441638bcd0e261a29dcccbdf3cfb1bf0cdc17))

**Full Changelog:** [`2024.11.07.0...2024.11.07.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.07.0...2024.11.07.1)

- - -

## 2024.11.07.0

### Testing

- Verification of search in payment operations page using cypress ([#1677](https://github.com/juspay/hyperswitch-control-center/pull/1677)) ([`bdc5c99`](https://github.com/juspay/hyperswitch-control-center/commit/bdc5c990f2537874823121c7cbb8acdb54e60bd3))

### Miscellaneous Tasks

- TwoFa restriction after multiple failed attempts after logging in ([#1651](https://github.com/juspay/hyperswitch-control-center/pull/1651)) ([`65bec34`](https://github.com/juspay/hyperswitch-control-center/commit/65bec340eabcabcb4b0ac52d364390a951f6835b))

**Full Changelog:** [`2024.11.04.1...2024.11.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.04.1...2024.11.07.0)

- - -

## 2024.11.04.1

### Miscellaneous Tasks

- Update new analytics ([`6572b00`](https://github.com/juspay/hyperswitch-control-center/commit/6572b00fc8c49db187d0ecdd268ae6804876d53d))

**Full Changelog:** [`2024.11.04.0...2024.11.04.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.11.04.0...2024.11.04.1)

- - -

## 2024.11.04.0

### Features

- Create compare date filter ([#1678](https://github.com/juspay/hyperswitch-control-center/pull/1678)) ([`86264d0`](https://github.com/juspay/hyperswitch-control-center/commit/86264d00d9f4f3bf18707b9f3806cdf528d9ff25))
- Enable comparison filter in new analytics ([#1679](https://github.com/juspay/hyperswitch-control-center/pull/1679)) ([`03bf0ba`](https://github.com/juspay/hyperswitch-control-center/commit/03bf0bae2535b9ea5c7e3bfe3b4952ffb12fbcc5))

### Bug Fixes

- Remove dispute stage col ([#1676](https://github.com/juspay/hyperswitch-control-center/pull/1676)) ([`1e94fad`](https://github.com/juspay/hyperswitch-control-center/commit/1e94fad454a2c1c37ef27945c48022a481ddb87f))
- Analytics sessionizer bugs ([#1671](https://github.com/juspay/hyperswitch-control-center/pull/1671)) ([`f73a5b7`](https://github.com/juspay/hyperswitch-control-center/commit/f73a5b7798522e1ca6233be0d6daeed5d8314a4d))

### Refactors

- Resource-access-added ([#1635](https://github.com/juspay/hyperswitch-control-center/pull/1635)) ([`e6cd819`](https://github.com/juspay/hyperswitch-control-center/commit/e6cd819b97fe3b876aed757fe4c36ae9b0478d76))
- Invite user api restructure v2 ([#1681](https://github.com/juspay/hyperswitch-control-center/pull/1681)) ([`47d26b3`](https://github.com/juspay/hyperswitch-control-center/commit/47d26b3005759a09bbb75140391bd0433bb6f7ab))

**Full Changelog:** [`2024.10.31.0...2024.11.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.31.0...2024.11.04.0)

- - -

## 2024.10.31.0

### Miscellaneous Tasks

- Pop-up modal extra prop addition ([#1660](https://github.com/juspay/hyperswitch-control-center/pull/1660)) ([`6421c4f`](https://github.com/juspay/hyperswitch-control-center/commit/6421c4f1a9ebba6b0cbecb1925ead5cb8cdf99a9))

**Full Changelog:** [`2024.10.30.0...2024.10.31.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.30.0...2024.10.31.0)

- - -

## 2024.10.30.0

### Bug Fixes

- Analytics sessionizer bugs ([#1665](https://github.com/juspay/hyperswitch-control-center/pull/1665)) ([`af79394`](https://github.com/juspay/hyperswitch-control-center/commit/af7939491179c4b2d58338f94d060e4d21c90e79))

### Testing

- Verification of time range filters in payment operations page using cypress ([#1658](https://github.com/juspay/hyperswitch-control-center/pull/1658)) ([`8acfd0e`](https://github.com/juspay/hyperswitch-control-center/commit/8acfd0e7ecbf8a7ee6c98a68029c028b7ffc2f3e))
- Verify Columns in Payment operations page ([#1667](https://github.com/juspay/hyperswitch-control-center/pull/1667)) ([`6c4338d`](https://github.com/juspay/hyperswitch-control-center/commit/6c4338d5eaa188ee9c9a4ef2db8cf4297fa13374))

**Full Changelog:** [`2024.10.29.0...2024.10.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.29.0...2024.10.30.0)

- - -

## 2024.10.29.0

### Features

- Smart retry analytics ([#1642](https://github.com/juspay/hyperswitch-control-center/pull/1642)) ([`e166495`](https://github.com/juspay/hyperswitch-control-center/commit/e166495d24fd6088423b4e9e8062d2524bd3202c))
- Add samsung pay payment method support for cybersource ([#1650](https://github.com/juspay/hyperswitch-control-center/pull/1650)) ([`02d66da`](https://github.com/juspay/hyperswitch-control-center/commit/02d66da7495fa52c470261d0dba97e770a6c1ffe))

### Bug Fixes

- Changes to enable card-network ([#1655](https://github.com/juspay/hyperswitch-control-center/pull/1655)) ([`d910c1e`](https://github.com/juspay/hyperswitch-control-center/commit/d910c1e649ac7ae78f5d7cf02a20769abb5e17eb))

**Full Changelog:** [`2024.10.25.0...2024.10.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.25.0...2024.10.29.0)

- - -

## 2024.10.25.0

### Bug Fixes

- Auto retry bug ([#1639](https://github.com/juspay/hyperswitch-control-center/pull/1639)) ([`46f4de6`](https://github.com/juspay/hyperswitch-control-center/commit/46f4de64f0c68e587a62c876b56e94a5e25ec26d))
- Merchant account credentials not shown in profile view ([#1626](https://github.com/juspay/hyperswitch-control-center/pull/1626)) ([`9108801`](https://github.com/juspay/hyperswitch-control-center/commit/9108801555d2e3e03908dbe33f4a52ce9c0503a3))

### Miscellaneous Tasks

- TwoFa restriction after multiple failed attempts before login ([#1594](https://github.com/juspay/hyperswitch-control-center/pull/1594)) ([`9ff488b`](https://github.com/juspay/hyperswitch-control-center/commit/9ff488b8edc99af45fc8f77ab1f56e6cef34a838))
- Add merchant specific config ([#1643](https://github.com/juspay/hyperswitch-control-center/pull/1643)) ([`aac4ada`](https://github.com/juspay/hyperswitch-control-center/commit/aac4adabf17e96ef7d02fe91048fca8b668030a8))

**Full Changelog:** [`2024.10.24.0...2024.10.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.24.0...2024.10.25.0)

- - -

## 2024.10.24.0

### Testing

- Creation of test payment using sdk cypress ([#1555](https://github.com/juspay/hyperswitch-control-center/pull/1555)) ([`1bd1e56`](https://github.com/juspay/hyperswitch-control-center/commit/1bd1e563f993ec483ef43651996b9c836e33de0d))

**Full Changelog:** [`2024.10.22.2...2024.10.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.22.2...2024.10.24.0)

- - -

## 2024.10.22.2

### Bug Fixes

- Card-network issue fix and removed calendly link ([#1637](https://github.com/juspay/hyperswitch-control-center/pull/1637)) ([`ed43df1`](https://github.com/juspay/hyperswitch-control-center/commit/ed43df1cb02b1d407934bf54eb035b1c207daf20))

**Full Changelog:** [`2024.10.22.1...2024.10.22.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.22.1...2024.10.22.2)

- - -

## 2024.10.22.1

### Bug Fixes

- Single status view setting to all ([#1634](https://github.com/juspay/hyperswitch-control-center/pull/1634)) ([`20a1a38`](https://github.com/juspay/hyperswitch-control-center/commit/20a1a38e9282c729843081b880ff7fa2f7b010a5))

**Full Changelog:** [`2024.10.22.0...2024.10.22.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.22.0...2024.10.22.1)

- - -

## 2024.10.22.0

### Features

- Card-network in payment filters ([#1447](https://github.com/juspay/hyperswitch-control-center/pull/1447)) ([`7dbb073`](https://github.com/juspay/hyperswitch-control-center/commit/7dbb07389af96f416118ad7d06aee60205da5793))

### Bug Fixes

- New analytics metric name fixes ([#1636](https://github.com/juspay/hyperswitch-control-center/pull/1636)) ([`542dd72`](https://github.com/juspay/hyperswitch-control-center/commit/542dd7248f94ddf50124eeeb8ca143954fde6098))
- Make auto retry value field mandatory ([#1632](https://github.com/juspay/hyperswitch-control-center/pull/1632)) ([`e80706e`](https://github.com/juspay/hyperswitch-control-center/commit/e80706e3fbdaf66a5bb62b25b16c55f879516785))

### Miscellaneous Tasks

- Profile name validations on edit profile ([#1633](https://github.com/juspay/hyperswitch-control-center/pull/1633)) ([`2c5ffb5`](https://github.com/juspay/hyperswitch-control-center/commit/2c5ffb591c3fe269bd60cc4138836ac964e31a4f))
- Create separate webpack ([#1592](https://github.com/juspay/hyperswitch-control-center/pull/1592)) ([`a22f5a6`](https://github.com/juspay/hyperswitch-control-center/commit/a22f5a6f4112846f280b64e1cd26b648b2a7f8a0))

**Full Changelog:** [`2024.10.18.0...2024.10.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.18.0...2024.10.22.0)

- - -

## 2024.10.18.0

### Features

- Added search func (profile) and id in OMP dropdowns (scroll and sort fixed) ([#1584](https://github.com/juspay/hyperswitch-control-center/pull/1584)) ([`f40413c`](https://github.com/juspay/hyperswitch-control-center/commit/f40413cae89cd4124e6252d65eba95f33fa05e6f))

### Bug Fixes

- Disable edit for profile level user (Business section) ([#1613](https://github.com/juspay/hyperswitch-control-center/pull/1613)) ([`ac2b906`](https://github.com/juspay/hyperswitch-control-center/commit/ac2b906a4eddc81b43531725139748a771ba46f3))

### Miscellaneous Tasks

- Enhance transaction views ([#1562](https://github.com/juspay/hyperswitch-control-center/pull/1562)) ([`4bca186`](https://github.com/juspay/hyperswitch-control-center/commit/4bca186ae28a4cdf5a7c8870c5d649e35b3bc5a9))

**Full Changelog:** [`2024.10.16.0...2024.10.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.16.0...2024.10.18.0)

- - -

## 2024.10.16.0

### Features

- Dispute views ([#1563](https://github.com/juspay/hyperswitch-control-center/pull/1563)) ([`75bb251`](https://github.com/juspay/hyperswitch-control-center/commit/75bb251b60b503dadb9a1cd167a85761d0adaf62))

### Bug Fixes

- Profile name validations ([#1564](https://github.com/juspay/hyperswitch-control-center/pull/1564)) ([`487012e`](https://github.com/juspay/hyperswitch-control-center/commit/487012e72eb7a0413c207653d9efc28873a9e356))
- Connected list on top in 3DS connectors , tax processors and PM authentication processors ([#1605](https://github.com/juspay/hyperswitch-control-center/pull/1605)) ([`f772fb9`](https://github.com/juspay/hyperswitch-control-center/commit/f772fb98d1170003eaa53c47a689bd57ec476f87))

### Miscellaneous Tasks

- Sankey response structure ([#1579](https://github.com/juspay/hyperswitch-control-center/pull/1579)) ([`a0710f2`](https://github.com/juspay/hyperswitch-control-center/commit/a0710f2583318f0752ec0484219d649b4476998b))
- Overview section spacing fix and payments metrics changes ([#1600](https://github.com/juspay/hyperswitch-control-center/pull/1600)) ([`37ea150`](https://github.com/juspay/hyperswitch-control-center/commit/37ea150dc86de15b215252d323b3f19ddb8b7a47))

**Full Changelog:** [`2024.10.14.1...2024.10.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.14.1...2024.10.16.0)

- - -

## 2024.10.14.1

### Features

- Fiuu google pay gateway name ([#1597](https://github.com/juspay/hyperswitch-control-center/pull/1597)) ([`721cd4a`](https://github.com/juspay/hyperswitch-control-center/commit/721cd4a6cabc72e77850b2b8a8b0996cb91cd72d))

**Full Changelog:** [`2024.10.14.0...2024.10.14.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.14.0...2024.10.14.1)

- - -

## 2024.10.14.0

### Bug Fixes

- Unauthorised page issue ([#1588](https://github.com/juspay/hyperswitch-control-center/pull/1588)) ([`8241854`](https://github.com/juspay/hyperswitch-control-center/commit/824185436c979389fb1bf87567ce9956abb748f2))

**Full Changelog:** [`2024.10.11.0...2024.10.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.11.0...2024.10.14.0)

- - -

## 2024.10.11.0

### Bug Fixes

- Fix: added command to run the project in windows env ([#828](https://github.com/juspay/hyperswitch-control-center/pull/828)) ([`b3d009e`](https://github.com/juspay/hyperswitch-control-center/commit/b3d009e5c257bf96d9d87ab7e873598bc301e484))
- Url name issue in create custom role page ([#1586](https://github.com/juspay/hyperswitch-control-center/pull/1586)) ([`b40f6d0`](https://github.com/juspay/hyperswitch-control-center/commit/b40f6d04f485e96f0d59f29c60ad1077941d83e7))

**Full Changelog:** [`2024.10.10.1...2024.10.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.10.1...2024.10.11.0)

- - -

## 2024.10.10.1

### Features

- Org changes for invite ([#1543](https://github.com/juspay/hyperswitch-control-center/pull/1543)) ([`c70d32c`](https://github.com/juspay/hyperswitch-control-center/commit/c70d32c1a52490b588036f4c8071abdd108c7db6))

### Miscellaneous Tasks

- File movement for two fa attempts inside dashboard ([#1556](https://github.com/juspay/hyperswitch-control-center/pull/1556)) ([`4c720da`](https://github.com/juspay/hyperswitch-control-center/commit/4c720da95e5b95fa813c57c41aa232c2162463c4))

**Full Changelog:** [`2024.10.10.0...2024.10.10.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.10.0...2024.10.10.1)

- - -

## 2024.10.10.0

### Miscellaneous Tasks

- User-permission type change ([#1577](https://github.com/juspay/hyperswitch-control-center/pull/1577)) ([`ebc0a33`](https://github.com/juspay/hyperswitch-control-center/commit/ebc0a33b21dc9ecfb50cc812161f05b1debeead7))

**Full Changelog:** [`2024.10.08.2...2024.10.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.08.2...2024.10.10.0)

- - -

## 2024.10.08.2

### Features

- Addition of new connector "NEXIXPAY" ([#1569](https://github.com/juspay/hyperswitch-control-center/pull/1569)) ([`8437983`](https://github.com/juspay/hyperswitch-control-center/commit/8437983269d3554d4abd0ab3a6649ddf88da373e))

**Full Changelog:** [`2024.10.08.1...2024.10.08.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.08.1...2024.10.08.2)

- - -

## 2024.10.08.1

### Features

- Tooltip fix and enhancement ([#1571](https://github.com/juspay/hyperswitch-control-center/pull/1571)) ([`0cda40b`](https://github.com/juspay/hyperswitch-control-center/commit/0cda40b243acab3bbbcfa0f8488389c642e67785))
- Failed payment distribution graph ([#1528](https://github.com/juspay/hyperswitch-control-center/pull/1528)) ([`470b582`](https://github.com/juspay/hyperswitch-control-center/commit/470b582b5da77abb9a00a42948451d00942be62c))
- Graphs legends display ([#1574](https://github.com/juspay/hyperswitch-control-center/pull/1574)) ([`233b192`](https://github.com/juspay/hyperswitch-control-center/commit/233b1922ada5018ee92847fc5b859d63d5246d03))

### Bug Fixes

- Selected item displays on top of list ([#1560](https://github.com/juspay/hyperswitch-control-center/pull/1560)) ([`5e36d6f`](https://github.com/juspay/hyperswitch-control-center/commit/5e36d6fac432d33e57313d4f058925a8b414665e))
- UI connector preview ([#1538](https://github.com/juspay/hyperswitch-control-center/pull/1538)) ([`d32e536`](https://github.com/juspay/hyperswitch-control-center/commit/d32e5366d751505afb1264ea4ad3724cf9ffd808))
- Update status of connector ( Disable / Enable ) ([#1575](https://github.com/juspay/hyperswitch-control-center/pull/1575)) ([`b5c14dd`](https://github.com/juspay/hyperswitch-control-center/commit/b5c14ddc588b2fa1939591b7bcccc43f7ff883a2))

**Full Changelog:** [`2024.10.08.0...2024.10.08.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.08.0...2024.10.08.1)

- - -

## 2024.10.08.0

### Features

- Add auto retries in payment settings ([#1551](https://github.com/juspay/hyperswitch-control-center/pull/1551)) ([`78479fa`](https://github.com/juspay/hyperswitch-control-center/commit/78479fade99cc04b115a8c40924ade9c9ae38606))

### Miscellaneous Tasks

- Ran prettier command to format unformatted file ([#1566](https://github.com/juspay/hyperswitch-control-center/pull/1566)) ([`66e2063`](https://github.com/juspay/hyperswitch-control-center/commit/66e206350e60989068206c29ffd63d30fad7f094))

**Full Changelog:** [`2024.10.07.1...2024.10.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.07.1...2024.10.08.0)

- - -

## 2024.10.07.1

### Features

- Payments overview section ([#1552](https://github.com/juspay/hyperswitch-control-center/pull/1552)) ([`06dae63`](https://github.com/juspay/hyperswitch-control-center/commit/06dae6364e3cb481a1321bb302f29f4052b8c338))

### Bug Fixes

- Prod x feature deployment ([#127](https://github.com/juspay/hyperswitch-control-center/pull/127)) ([`6a9e9ab`](https://github.com/juspay/hyperswitch-control-center/commit/6a9e9abd0c492e59eebe5c4ad4c0b1e47a736513))
- Api not getting called due to user permission data not updated ([#1565](https://github.com/juspay/hyperswitch-control-center/pull/1565)) ([`ad7d230`](https://github.com/juspay/hyperswitch-control-center/commit/ad7d23080039e77758fd52330bad664590d6d4f3))

### Refactors

- Code changes ([#1550](https://github.com/juspay/hyperswitch-control-center/pull/1550)) ([`ba9ead3`](https://github.com/juspay/hyperswitch-control-center/commit/ba9ead301fc0d2d2a01c2e2410fb8dd88a4e3551))

**Full Changelog:** [`2024.10.07.0...2024.10.07.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.07.0...2024.10.07.1)

- - -

## 2024.10.07.0

### Features

- Compare function ([#1542](https://github.com/juspay/hyperswitch-control-center/pull/1542)) ([`938ccc7`](https://github.com/juspay/hyperswitch-control-center/commit/938ccc7bc2e83cf149b6c9660d28dd3275b6a128))
- Added graphs header ([#1539](https://github.com/juspay/hyperswitch-control-center/pull/1539)) ([`583ddf2`](https://github.com/juspay/hyperswitch-control-center/commit/583ddf2f3672d2bc04cabd9e6b6eb848e1e5dfca))
- Add scroll for merchant, org, and profile dropdowns ([#1537](https://github.com/juspay/hyperswitch-control-center/pull/1537)) ([`3bee31c`](https://github.com/juspay/hyperswitch-control-center/commit/3bee31cbb86952b4ece81902f7f9ff0d6cd6670c))

### Testing

- Creation of dummy connector using cypress ([#1497](https://github.com/juspay/hyperswitch-control-center/pull/1497)) ([`f040964`](https://github.com/juspay/hyperswitch-control-center/commit/f040964457cdd557bf5c8a414d72ce265a51e741))

**Full Changelog:** [`2024.10.04.0...2024.10.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.04.0...2024.10.07.0)

- - -

## 2024.10.04.0

### Miscellaneous Tasks

- Modify new analytics utils ([#1531](https://github.com/juspay/hyperswitch-control-center/pull/1531)) ([`4760207`](https://github.com/juspay/hyperswitch-control-center/commit/476020779802fee0f3d7b3ac30f25366ba0c7050))
- Sanky mapper function ([#1524](https://github.com/juspay/hyperswitch-control-center/pull/1524)) ([`1a90976`](https://github.com/juspay/hyperswitch-control-center/commit/1a90976631ab10b977b9ccc5bfd3721bdd465d44))
- Remove agreement screen and prod onboarding ([#1493](https://github.com/juspay/hyperswitch-control-center/pull/1493)) ([`f5c9f40`](https://github.com/juspay/hyperswitch-control-center/commit/f5c9f4007095221e5d5f6d521887d463cbb6e35c))

**Full Changelog:** [`2024.10.02.0...2024.10.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.02.0...2024.10.04.0)

- - -

## 2024.10.02.0

### Features

- New analytics filter ([#1518](https://github.com/juspay/hyperswitch-control-center/pull/1518)) ([`f580f3d`](https://github.com/juspay/hyperswitch-control-center/commit/f580f3d103b9552dd9bcc30773b4d32b21add91d))
- Api integration new analytics ([#1521](https://github.com/juspay/hyperswitch-control-center/pull/1521)) ([`8f71786`](https://github.com/juspay/hyperswitch-control-center/commit/8f71786fb5bfb0fce7be4a93145aabb756693044))

### Bug Fixes

- Table text-wrap removed ([#1517](https://github.com/juspay/hyperswitch-control-center/pull/1517)) ([`966426c`](https://github.com/juspay/hyperswitch-control-center/commit/966426cc004b4cb46e98efcd59ff7809f043c0e3))
- Error due to unautorised url ([#1526](https://github.com/juspay/hyperswitch-control-center/pull/1526)) ([`de08357`](https://github.com/juspay/hyperswitch-control-center/commit/de08357c89d01232e1b3912423bc2f32c7194f78))

**Full Changelog:** [`2024.10.01.0...2024.10.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.10.01.0...2024.10.02.0)

- - -

## 2024.10.01.0

### Features

- Dispute filters ([#1474](https://github.com/juspay/hyperswitch-control-center/pull/1474)) ([`d8c8974`](https://github.com/juspay/hyperswitch-control-center/commit/d8c8974539d321d5241638112f92b9207e1427bc))

### Bug Fixes

- Check for disabled pm auth connector ([#1506](https://github.com/juspay/hyperswitch-control-center/pull/1506)) ([`9105eb1`](https://github.com/juspay/hyperswitch-control-center/commit/9105eb1c534b972acc8a0dd21258215cf566e3d2))
- Removed unused api from app ([#1500](https://github.com/juspay/hyperswitch-control-center/pull/1500)) ([`5b9635e`](https://github.com/juspay/hyperswitch-control-center/commit/5b9635e8db8462bfff5059d6ef0c78dbecb8c651))
- Transaction views ([#1498](https://github.com/juspay/hyperswitch-control-center/pull/1498)) ([`80efd6c`](https://github.com/juspay/hyperswitch-control-center/commit/80efd6cd449dc1561049f5b666dc09f01ac4a789))

### Miscellaneous Tasks

- Omp views ui changes ([#1486](https://github.com/juspay/hyperswitch-control-center/pull/1486)) ([`677015c`](https://github.com/juspay/hyperswitch-control-center/commit/677015c0456d555a368f4663b55a3ec7e59e3cd2))
- Fix testing bug - displaying Processor in table ([#1507](https://github.com/juspay/hyperswitch-control-center/pull/1507)) ([`5c61535`](https://github.com/juspay/hyperswitch-control-center/commit/5c61535901d063995a860f8d4cda4dbcc475a970))
- Changes in connector addition template ([#1496](https://github.com/juspay/hyperswitch-control-center/pull/1496)) ([`1fcb0b5`](https://github.com/juspay/hyperswitch-control-center/commit/1fcb0b5bbc61acea6dc5f772682c1e177bb3da63))
- Updated file names and variables names for successful payment … ([#1519](https://github.com/juspay/hyperswitch-control-center/pull/1519)) ([`6bb53ca`](https://github.com/juspay/hyperswitch-control-center/commit/6bb53ca66f7ef51de9977f81c86b7e272d54a9f9))

**Full Changelog:** [`2024.09.30.0...2024.10.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.30.0...2024.10.01.0)

- - -

## 2024.09.30.0

### Features

- Custom tool-tip analytics ([#1445](https://github.com/juspay/hyperswitch-control-center/pull/1445)) ([`91b5abe`](https://github.com/juspay/hyperswitch-control-center/commit/91b5abecce4399ae6fcc104bfaa435cab6ba778e))
- Metric selector and tabs for new analytics module ([#1485](https://github.com/juspay/hyperswitch-control-center/pull/1485)) ([`511ee1e`](https://github.com/juspay/hyperswitch-control-center/commit/511ee1ee6642d74a45c2ab0e69cfc8699d4559be))
- Refund view changes ([#1315](https://github.com/juspay/hyperswitch-control-center/pull/1315)) ([`4ba9162`](https://github.com/juspay/hyperswitch-control-center/commit/4ba91621ca8221625a2cfffb62903e1123350ee7))

### Bug Fixes

- Fix resend invite api url ([#1491](https://github.com/juspay/hyperswitch-control-center/pull/1491)) ([`ea36663`](https://github.com/juspay/hyperswitch-control-center/commit/ea3666350d7ab85761ab934a0d7ee75712652b87))

### Miscellaneous Tasks

- Remove mixpanel sdk ([#1483](https://github.com/juspay/hyperswitch-control-center/pull/1483)) ([`7a2c0b0`](https://github.com/juspay/hyperswitch-control-center/commit/7a2c0b0673dcbdfc499705bcea7e50dd2d9189b8))

**Full Changelog:** [`2024.09.26.1...2024.09.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.26.1...2024.09.30.0)

- - -

## 2024.09.26.1

### Miscellaneous Tasks

- Github template added ([#1458](https://github.com/juspay/hyperswitch-control-center/pull/1458)) ([`c6c1455`](https://github.com/juspay/hyperswitch-control-center/commit/c6c1455fc55b1ea2cdc47de2d608386e51649e7c))
- Removed compiler warning and threeds comp change ([#1478](https://github.com/juspay/hyperswitch-control-center/pull/1478)) ([`2999335`](https://github.com/juspay/hyperswitch-control-center/commit/2999335de1a167a7f199169abb9bfb36ec5603d9))
- Modified table customise columns, warning remove ([#1477](https://github.com/juspay/hyperswitch-control-center/pull/1477)) ([`59b390a`](https://github.com/juspay/hyperswitch-control-center/commit/59b390aa5c2c49a5bb6c046e09c550ae80dca05e))
- Internal entity removal ([#1467](https://github.com/juspay/hyperswitch-control-center/pull/1467)) ([`4c94b8d`](https://github.com/juspay/hyperswitch-control-center/commit/4c94b8d1dc53f888ba4703fe5c0da3326ae6ca0f))

**Full Changelog:** [`2024.09.26.0...2024.09.26.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.26.0...2024.09.26.1)

- - -

## 2024.09.26.0

### Bug Fixes

- Table customise column bugfix ([#1469](https://github.com/juspay/hyperswitch-control-center/pull/1469)) ([`abc1852`](https://github.com/juspay/hyperswitch-control-center/commit/abc18523def610b41c653bddb0745318a18e77bb))
- Update connector url on preview ([#1471](https://github.com/juspay/hyperswitch-control-center/pull/1471)) ([`de870b5`](https://github.com/juspay/hyperswitch-control-center/commit/de870b577f7c3222c7ca059e91c09f50de2d0dfa))

### Miscellaneous Tasks

- Empty points generator function for graphs ([#1460](https://github.com/juspay/hyperswitch-control-center/pull/1460)) ([`0d3433e`](https://github.com/juspay/hyperswitch-control-center/commit/0d3433e4524b4f90cd09737ea5acc495f999af55))
- Transaction view feature flag ([#1472](https://github.com/juspay/hyperswitch-control-center/pull/1472)) ([`8b48ef4`](https://github.com/juspay/hyperswitch-control-center/commit/8b48ef43278255c50d2c3437f7c8045024f2c45f))
- Payments distribution graph ([#1459](https://github.com/juspay/hyperswitch-control-center/pull/1459)) ([`e15f598`](https://github.com/juspay/hyperswitch-control-center/commit/e15f598507b6a45b403c44321dcf415e3d421b96))

**Full Changelog:** [`2024.09.25.0...2024.09.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.25.0...2024.09.26.0)

- - -

## 2024.09.25.0

### Bug Fixes

- List users views in users page ([#1453](https://github.com/juspay/hyperswitch-control-center/pull/1453)) ([`bad2df8`](https://github.com/juspay/hyperswitch-control-center/commit/bad2df84baedc00e30751355c009b0bd7da11654))

**Full Changelog:** [`2024.09.24.1...2024.09.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.24.1...2024.09.25.0)

- - -

## 2024.09.24.1

### Features

- Bar graph entity ([#1457](https://github.com/juspay/hyperswitch-control-center/pull/1457)) ([`2f12b56`](https://github.com/juspay/hyperswitch-control-center/commit/2f12b5698d51777782af06022bf35ca07e8c02a2))

### Bug Fixes

- Omp views changes in analytics & ops ([#1452](https://github.com/juspay/hyperswitch-control-center/pull/1452)) ([`b089409`](https://github.com/juspay/hyperswitch-control-center/commit/b089409c1455ecc7b84c866a960ac8460f855e8c))

### Miscellaneous Tasks

- Payments success rate graph ([#1439](https://github.com/juspay/hyperswitch-control-center/pull/1439)) ([`46277b1`](https://github.com/juspay/hyperswitch-control-center/commit/46277b12c9ceda6d2a31f17247292bbb380900ca))

**Full Changelog:** [`2024.09.24.0...2024.09.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.24.0...2024.09.24.1)

- - -

## 2024.09.24.0

### Features

- New tabs ui ([#1440](https://github.com/juspay/hyperswitch-control-center/pull/1440)) ([`955cd2c`](https://github.com/juspay/hyperswitch-control-center/commit/955cd2c38a574a77b780b898a518cb70d4c9788e))

**Full Changelog:** [`2024.09.23.0...2024.09.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.23.0...2024.09.24.0)

- - -

## 2024.09.23.0

### Miscellaneous Tasks

- Update profile dropdown ([#1434](https://github.com/juspay/hyperswitch-control-center/pull/1434)) ([`e6fe7bc`](https://github.com/juspay/hyperswitch-control-center/commit/e6fe7bcbd3afe6eb62fe85333c78312d782a547f))

**Full Changelog:** [`2024.09.20.0...2024.09.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.20.0...2024.09.23.0)

- - -

## 2024.09.20.0

### Features

- Overview file cleanup and files restructuring ([#1436](https://github.com/juspay/hyperswitch-control-center/pull/1436)) ([`c063e64`](https://github.com/juspay/hyperswitch-control-center/commit/c063e645e3698477f3bea565d0c0e12c1c5442f1))

**Full Changelog:** [`2024.09.19.1...2024.09.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.19.1...2024.09.20.0)

- - -

## 2024.09.19.1

### Bug Fixes

- User management name changes ([#1432](https://github.com/juspay/hyperswitch-control-center/pull/1432)) ([`ff64997`](https://github.com/juspay/hyperswitch-control-center/commit/ff6499771645c096d04e26acbec3efa2b137cf2c))

**Full Changelog:** [`2024.09.19.0...2024.09.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.19.0...2024.09.19.1)

- - -

## 2024.09.19.0

### Features

- New connector deutsche bank ([#1408](https://github.com/juspay/hyperswitch-control-center/pull/1408)) ([`fb7847b`](https://github.com/juspay/hyperswitch-control-center/commit/fb7847bf840e7aa33148f2593558ed533bebad95))

### Testing

- Cypress update ([#1420](https://github.com/juspay/hyperswitch-control-center/pull/1420)) ([`6f59156`](https://github.com/juspay/hyperswitch-control-center/commit/6f59156bae44fe3d80d236c50b6562445bd5e0ee))

### Miscellaneous Tasks

- Merchant name validation added ([#1416](https://github.com/juspay/hyperswitch-control-center/pull/1416)) ([`e143725`](https://github.com/juspay/hyperswitch-control-center/commit/e14372523fc323aaf2c90bc630d73e4bcee9d57b))
- Update wasm for deutsche ([#1429](https://github.com/juspay/hyperswitch-control-center/pull/1429)) ([`6fc9d63`](https://github.com/juspay/hyperswitch-control-center/commit/6fc9d63757df8ba9fb4e5df1d448de5189903c27))
- Post login questions page related files removal ([#1427](https://github.com/juspay/hyperswitch-control-center/pull/1427)) ([`93382db`](https://github.com/juspay/hyperswitch-control-center/commit/93382db3ff28d9f0e99af08407c7f9593930466a))
- UI changes for update connector creds ([#1438](https://github.com/juspay/hyperswitch-control-center/pull/1438)) ([`3101b29`](https://github.com/juspay/hyperswitch-control-center/commit/3101b298e0e4dff45cef5afa23f0f32da1166e92))

**Full Changelog:** [`2024.09.18.0...2024.09.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.18.0...2024.09.19.0)

- - -

## 2024.09.18.0

### Features

- Remove user-management revamp feature flag ([#1394](https://github.com/juspay/hyperswitch-control-center/pull/1394)) ([`6d7123b`](https://github.com/juspay/hyperswitch-control-center/commit/6d7123bd4302193c11291d44fe381e2fcab112e4))

### Bug Fixes

- Bug fixes ui ([#1396](https://github.com/juspay/hyperswitch-control-center/pull/1396)) ([`8e4d2d8`](https://github.com/juspay/hyperswitch-control-center/commit/8e4d2d8cc35b348d43371364c05bed157d8d6062))

### Miscellaneous Tasks

- Home page changes for profile level users ([#1409](https://github.com/juspay/hyperswitch-control-center/pull/1409)) ([`877de7f`](https://github.com/juspay/hyperswitch-control-center/commit/877de7fd8e52c1d46e43653525b77aa26d08dbf9))

**Full Changelog:** [`2024.09.17.2...2024.09.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.17.2...2024.09.18.0)

- - -

## 2024.09.17.2

### Features

- Handle masked api keys ([#1400](https://github.com/juspay/hyperswitch-control-center/pull/1400)) ([`2cc832c`](https://github.com/juspay/hyperswitch-control-center/commit/2cc832ca2d1c8b7689d175e5b0d5d01cc7304d0d))

### Miscellaneous Tasks

- Handle masked api keys ([`91358cb`](https://github.com/juspay/hyperswitch-control-center/commit/91358cb6dcca083e5669b57be4141119ada5635e))

**Full Changelog:** [`2024.09.17.1...2024.09.17.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.17.1...2024.09.17.2)

- - -

## 2024.09.17.1

### Features

- Tax processor addition and taxjar addition ([#1379](https://github.com/juspay/hyperswitch-control-center/pull/1379)) ([`0b4dad9`](https://github.com/juspay/hyperswitch-control-center/commit/0b4dad9a496d315ac43b26d829f55f6f281050f6))
- Table view switch to the graph component ([#1381](https://github.com/juspay/hyperswitch-control-center/pull/1381)) ([`70b7a61`](https://github.com/juspay/hyperswitch-control-center/commit/70b7a615fb5c99e409a213102a2987bbca03b855))

### Miscellaneous Tasks

- Analytics entity refactor ([#1377](https://github.com/juspay/hyperswitch-control-center/pull/1377)) ([`52fecda`](https://github.com/juspay/hyperswitch-control-center/commit/52fecdabeb832e938c1f07bd66465f5654aea171))
- Taxjar icon ([#1403](https://github.com/juspay/hyperswitch-control-center/pull/1403)) ([`af175be`](https://github.com/juspay/hyperswitch-control-center/commit/af175be31897efc133b8ffe8fe020afe55a80216))
- Tax processor ([#1405](https://github.com/juspay/hyperswitch-control-center/pull/1405)) ([`6fc6374`](https://github.com/juspay/hyperswitch-control-center/commit/6fc6374ad4ed30ee613c13f7bfed5b5f6b666f6a))

**Full Changelog:** [`2024.09.17.0...2024.09.17.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.17.0...2024.09.17.1)

- - -

## 2024.09.17.0

### Features

- Core file changes for tax processor addition ([#1378](https://github.com/juspay/hyperswitch-control-center/pull/1378)) ([`9aba852`](https://github.com/juspay/hyperswitch-control-center/commit/9aba85242e62c5d723d74992fa389265148ad99d))
- Payment operation revamp ([#1203](https://github.com/juspay/hyperswitch-control-center/pull/1203)) ([`2fee0ee`](https://github.com/juspay/hyperswitch-control-center/commit/2fee0ee3cc087496604cd65376745cd8c9bd8740))
- Novalnet connector addition ([#1373](https://github.com/juspay/hyperswitch-control-center/pull/1373)) ([`989b1f6`](https://github.com/juspay/hyperswitch-control-center/commit/989b1f69a1c7cb0fd5e03f3bc10ff6a1cb53950f))

### Miscellaneous Tasks

- Moved user management files from old modules ([#1389](https://github.com/juspay/hyperswitch-control-center/pull/1389)) ([`188a136`](https://github.com/juspay/hyperswitch-control-center/commit/188a13685f6017d32c597b53febf0d0a5b6d2d62))
- Update wasm for tax processor ([#1391](https://github.com/juspay/hyperswitch-control-center/pull/1391)) ([`7a40f4a`](https://github.com/juspay/hyperswitch-control-center/commit/7a40f4a3ea155e99e4f24009ded9a572f9966866))
- Unused vars removed ([#1383](https://github.com/juspay/hyperswitch-control-center/pull/1383)) ([`790040d`](https://github.com/juspay/hyperswitch-control-center/commit/790040d4e9c1c3fec1dfab2cc41eb47f3c8a05e8))

**Full Changelog:** [`2024.09.16.0...2024.09.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.16.0...2024.09.17.0)

- - -

## 2024.09.16.0

### Miscellaneous Tasks

- Line graph utils ([#1349](https://github.com/juspay/hyperswitch-control-center/pull/1349)) ([`ba4e885`](https://github.com/juspay/hyperswitch-control-center/commit/ba4e88565818551f1a82bc6c76da6dff1ceb4273))

**Full Changelog:** [`2024.09.13.0...2024.09.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.13.0...2024.09.16.0)

- - -

## 2024.09.13.0

### Bug Fixes

- Volume based routing fix ([#1365](https://github.com/juspay/hyperswitch-control-center/pull/1365)) ([`8bc98e4`](https://github.com/juspay/hyperswitch-control-center/commit/8bc98e4ae0b61001d3ac23a3ddaac16e26dee2c0))
- Global search fixes ([#1366](https://github.com/juspay/hyperswitch-control-center/pull/1366)) ([`7274021`](https://github.com/juspay/hyperswitch-control-center/commit/727402161be194f636f91f5cb1e416ec6e256596))

### Miscellaneous Tasks

- Add a sankey utils graph ([#1371](https://github.com/juspay/hyperswitch-control-center/pull/1371)) ([`74f5d0c`](https://github.com/juspay/hyperswitch-control-center/commit/74f5d0cc60fa2fd6667f7f0dbbb552d6bd238b1e))

**Full Changelog:** [`2024.09.11.1...2024.09.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.11.1...2024.09.13.0)

- - -

## 2024.09.11.1

### Bug Fixes

- User management revamp bugs ([#1355](https://github.com/juspay/hyperswitch-control-center/pull/1355)) ([`22f7958`](https://github.com/juspay/hyperswitch-control-center/commit/22f7958a30e0e68b1cb93eb29e09383816805f0a))

**Full Changelog:** [`2024.09.11.0...2024.09.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.11.0...2024.09.11.1)

- - -

## 2024.09.11.0

### Bug Fixes

- Ui bugs homepage ([#1350](https://github.com/juspay/hyperswitch-control-center/pull/1350)) ([`6f25b23`](https://github.com/juspay/hyperswitch-control-center/commit/6f25b23abec7a63a40aaa447ac8cc5022162d67c))
- User management bugs ([#1343](https://github.com/juspay/hyperswitch-control-center/pull/1343)) ([`36d234d`](https://github.com/juspay/hyperswitch-control-center/commit/36d234d9508cc593a9b989957c5cc4beb5e723cd))

### Miscellaneous Tasks

- Add down time feature flag ([#1342](https://github.com/juspay/hyperswitch-control-center/pull/1342)) ([`a51a91f`](https://github.com/juspay/hyperswitch-control-center/commit/a51a91f225e18625855bcd0cea66add64e01dc92))

**Full Changelog:** [`2024.09.10.0...2024.09.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.10.0...2024.09.11.0)

- - -

## 2024.09.10.0

### Features

- Mixpanel 5xx error ([#1313](https://github.com/juspay/hyperswitch-control-center/pull/1313)) ([`6fba4b3`](https://github.com/juspay/hyperswitch-control-center/commit/6fba4b3ea91a58eadfc341cb66dd01af538cf52d))
- New analytics file structure ([#1310](https://github.com/juspay/hyperswitch-control-center/pull/1310)) ([`6bb8fae`](https://github.com/juspay/hyperswitch-control-center/commit/6bb8faef4a6d77ffaeaee38879580c1db25c45d0))
- Table remote sorting feature ([#1198](https://github.com/juspay/hyperswitch-control-center/pull/1198)) ([`c9b6691`](https://github.com/juspay/hyperswitch-control-center/commit/c9b6691d5b27c0e00c4a451a37ade2b11ddbfb7d))
- New analytics tabs ([#1338](https://github.com/juspay/hyperswitch-control-center/pull/1338)) ([`646b752`](https://github.com/juspay/hyperswitch-control-center/commit/646b75280d622fd7f2c27274fda61b4f3082a3f6))
- Add disable option for pm auth processor ([#1332](https://github.com/juspay/hyperswitch-control-center/pull/1332)) ([`0a491d1`](https://github.com/juspay/hyperswitch-control-center/commit/0a491d1f36b01b530565918c30802e9e299a5bc1))

### Bug Fixes

- Bug fix width issue ([#1326](https://github.com/juspay/hyperswitch-control-center/pull/1326)) ([`266ebc2`](https://github.com/juspay/hyperswitch-control-center/commit/266ebc20d5d47586702cfa994bd5d5cc611c34ca))

### Miscellaneous Tasks

- Pending invitations in home page ([#1330](https://github.com/juspay/hyperswitch-control-center/pull/1330)) ([`ba13558`](https://github.com/juspay/hyperswitch-control-center/commit/ba135588b915be2339082ec0b65da403253f161b))

**Full Changelog:** [`2024.09.06.4...2024.09.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.06.4...2024.09.10.0)

- - -

## 2024.09.06.4

### Bug Fixes

- User permission change for audit trail ([#1322](https://github.com/juspay/hyperswitch-control-center/pull/1322)) ([`26f2dcf`](https://github.com/juspay/hyperswitch-control-center/commit/26f2dcf529e49dca17c78c51f22357905643f01c))
- Merchant id from user-info ([#1324](https://github.com/juspay/hyperswitch-control-center/pull/1324)) ([`12b0d16`](https://github.com/juspay/hyperswitch-control-center/commit/12b0d168a012220dd475884546910485bc1edffb))

**Full Changelog:** [`2024.09.06.3...2024.09.06.4`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.06.3...2024.09.06.4)

- - -

## 2024.09.06.3

### Bug Fixes

- Internal user changes ([#1320](https://github.com/juspay/hyperswitch-control-center/pull/1320)) ([`1ef01dd`](https://github.com/juspay/hyperswitch-control-center/commit/1ef01dd0ed25f34381a4edf7b838245e750111e4))

**Full Changelog:** [`2024.09.06.2...2024.09.06.3`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.06.2...2024.09.06.3)

- - -

## 2024.09.06.2

### Bug Fixes

- Fixed all profiles issue in teams ([#1318](https://github.com/juspay/hyperswitch-control-center/pull/1318)) ([`5dcf9a1`](https://github.com/juspay/hyperswitch-control-center/commit/5dcf9a1e8b745e5bfea0b49e672942861de0ef52))

### Miscellaneous Tasks

- Chore: pin functionality removed ([#1297](https://github.com/juspay/hyperswitch-control-center/pull/1297)) ([`0aafec4`](https://github.com/juspay/hyperswitch-control-center/commit/0aafec4579aa3655807696ac23d570c301567f0f))

**Full Changelog:** [`2024.09.06.1...2024.09.06.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.06.1...2024.09.06.2)

- - -

## 2024.09.06.1

### Bug Fixes

- User-revamp fixes ([#1317](https://github.com/juspay/hyperswitch-control-center/pull/1317)) ([`0317fb1`](https://github.com/juspay/hyperswitch-control-center/commit/0317fb10398f091b10e579532347228ab00a16c2))

**Full Changelog:** [`2024.09.06.0...2024.09.06.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.06.0...2024.09.06.1)

- - -

## 2024.09.06.0

### Bug Fixes

- Fix: bug fixes user restructuring ([#1311](https://github.com/juspay/hyperswitch-control-center/pull/1311)) ([`7fd1bc7`](https://github.com/juspay/hyperswitch-control-center/commit/7fd1bc7de5886e68c6508cac1de2c5d873437b95))
- Dialog on org , merchant and profile switch & bug-fixes ([#1299](https://github.com/juspay/hyperswitch-control-center/pull/1299)) ([`007ea04`](https://github.com/juspay/hyperswitch-control-center/commit/007ea042f8e9510ce4b6a2481bb201b4ff440f7a))

**Full Changelog:** [`2024.09.05.2...2024.09.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.05.2...2024.09.06.0)

- - -

## 2024.09.05.2

### Features

- Enabled wellsfargo connector ([#1300](https://github.com/juspay/hyperswitch-control-center/pull/1300)) ([`2b45cfa`](https://github.com/juspay/hyperswitch-control-center/commit/2b45cfa968cd6af4e4f5b180d93d37b4ac0faf81))
- Fiuu connector added ([#1308](https://github.com/juspay/hyperswitch-control-center/pull/1308)) ([`5ac5d5f`](https://github.com/juspay/hyperswitch-control-center/commit/5ac5d5fae3ef885d3c809775f054ed96bb23541c))

### Miscellaneous Tasks

- Analytics org merchant profile level api ([#1302](https://github.com/juspay/hyperswitch-control-center/pull/1302)) ([`70707b4`](https://github.com/juspay/hyperswitch-control-center/commit/70707b45356b7d4297e496cf1c489d6e2f0663be))
- Show user details page ([#1208](https://github.com/juspay/hyperswitch-control-center/pull/1208)) ([`964812d`](https://github.com/juspay/hyperswitch-control-center/commit/964812dbdae3b5bd999bebf1575a6897e2dd34c6))
- Org merchant profile level views analytics ([#1303](https://github.com/juspay/hyperswitch-control-center/pull/1303)) ([`93fd685`](https://github.com/juspay/hyperswitch-control-center/commit/93fd685364fe23a604c752dad44706ffed2c5e61))
- Pending invites screen changes ([#1307](https://github.com/juspay/hyperswitch-control-center/pull/1307)) ([`f4f2779`](https://github.com/juspay/hyperswitch-control-center/commit/f4f2779958ca0ebed7210df351b7981d1df9653c))

**Full Changelog:** [`2024.09.05.1...2024.09.05.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.05.1...2024.09.05.2)

- - -

## 2024.09.05.1

### Miscellaneous Tasks

- Disable customers for profile level users ([#1304](https://github.com/juspay/hyperswitch-control-center/pull/1304)) ([`d5c72ef`](https://github.com/juspay/hyperswitch-control-center/commit/d5c72ef3ab0fcc9c933dbc940e911cd2a0cbbfa3))

**Full Changelog:** [`2024.09.05.0...2024.09.05.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.05.0...2024.09.05.1)

- - -

## 2024.09.05.0

### Features

- Added Fiserv IPG connector ([#1289](https://github.com/juspay/hyperswitch-control-center/pull/1289)) ([`009605e`](https://github.com/juspay/hyperswitch-control-center/commit/009605edaa70469c548f976b768b5bba5279617c))

### Miscellaneous Tasks

- New user invitation page ([#1199](https://github.com/juspay/hyperswitch-control-center/pull/1199)) ([`968478a`](https://github.com/juspay/hyperswitch-control-center/commit/968478abab002a38568d917cafe6fa33a3ef5c3b))
- Add profile level views in payment page ([#1290](https://github.com/juspay/hyperswitch-control-center/pull/1290)) ([`ff5d897`](https://github.com/juspay/hyperswitch-control-center/commit/ff5d897d8dac67ff5c17eee9e56da5797097c2cb))

**Full Changelog:** [`2024.09.04.1...2024.09.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.04.1...2024.09.05.0)

- - -

## 2024.09.04.1

### Bug Fixes

- Entity scaffold url path ([#1293](https://github.com/juspay/hyperswitch-control-center/pull/1293)) ([`791f91d`](https://github.com/juspay/hyperswitch-control-center/commit/791f91d6e7f6bac5d40cee177e6e62d636cd3264))

### Miscellaneous Tasks

- Update user info hook ([#1287](https://github.com/juspay/hyperswitch-control-center/pull/1287)) ([`1500415`](https://github.com/juspay/hyperswitch-control-center/commit/1500415edf33477fb4485d801549fb419f787fcb))
- Profile level api integration ([#1285](https://github.com/juspay/hyperswitch-control-center/pull/1285)) ([`b4d546d`](https://github.com/juspay/hyperswitch-control-center/commit/b4d546d50314513733da314e30a3cec1304a4983))

**Full Changelog:** [`2024.09.04.0...2024.09.04.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.04.0...2024.09.04.1)

- - -

## 2024.09.04.0

### Features

- Payment views core ([#1277](https://github.com/juspay/hyperswitch-control-center/pull/1277)) ([`bc46dd5`](https://github.com/juspay/hyperswitch-control-center/commit/bc46dd5a8ec999bd8f9a50d261737a6099a1f46f))

### Miscellaneous Tasks

- New user invitation independent files ([#1275](https://github.com/juspay/hyperswitch-control-center/pull/1275)) ([`af3f17a`](https://github.com/juspay/hyperswitch-control-center/commit/af3f17a53c8b290a8656f2ab8539377b1d7dbb33))
- Call switch api in core modules ([#1265](https://github.com/juspay/hyperswitch-control-center/pull/1265)) ([`fc4df39`](https://github.com/juspay/hyperswitch-control-center/commit/fc4df39123763bd473e04c6fae5579458f21d9f9))
- Update user info context with extra parameter ([#1283](https://github.com/juspay/hyperswitch-control-center/pull/1283)) ([`2d0b962`](https://github.com/juspay/hyperswitch-control-center/commit/2d0b962a01986178863e2bcf8fa2f3ae5bceab65))

**Full Changelog:** [`2024.09.02.0...2024.09.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.02.0...2024.09.04.0)

- - -

## 2024.09.02.0

### Features

- Square connector added ([#1217](https://github.com/juspay/hyperswitch-control-center/pull/1217)) ([`d3305df`](https://github.com/juspay/hyperswitch-control-center/commit/d3305df5625397932e9108296ff3e584cb3ca728))
- Profile settings changes ([#1227](https://github.com/juspay/hyperswitch-control-center/pull/1227)) ([`46f457e`](https://github.com/juspay/hyperswitch-control-center/commit/46f457e04db9fdb5fe543433f06e7632dc8e2297))
- Connector additional merchant data fields ([#1216](https://github.com/juspay/hyperswitch-control-center/pull/1216)) ([`977be5a`](https://github.com/juspay/hyperswitch-control-center/commit/977be5a5bc3c03ad63fecae5e58931045399fec0))

### Bug Fixes

- Recon issue fixed ([#1271](https://github.com/juspay/hyperswitch-control-center/pull/1271)) ([`fc954b6`](https://github.com/juspay/hyperswitch-control-center/commit/fc954b6883e1278a20ec9b4059ce8a158bcfbae9))
- Routing gateway same name fix ([#1248](https://github.com/juspay/hyperswitch-control-center/pull/1248)) ([`39b2a53`](https://github.com/juspay/hyperswitch-control-center/commit/39b2a539e661514a0c5ca90bd80a87a9360a0664))

### Miscellaneous Tasks

- Switch org merch profile logic ([#1226](https://github.com/juspay/hyperswitch-control-center/pull/1226)) ([`38580cb`](https://github.com/juspay/hyperswitch-control-center/commit/38580cb3989cb1bb2550bf76e748536e991f190c))
- Integrate core profile level apis ([#1261](https://github.com/juspay/hyperswitch-control-center/pull/1261)) ([`7fd008f`](https://github.com/juspay/hyperswitch-control-center/commit/7fd008f4c49c6bf1d877479bd742fe0adac0f3c0))
- Switch org , merchant , profile implementation ([#1257](https://github.com/juspay/hyperswitch-control-center/pull/1257)) ([`92e6b86`](https://github.com/juspay/hyperswitch-control-center/commit/92e6b86b0ae1e47f153ea0ede55f5dc47b1e70db))
- Removed duplicated file and updated imports ([#1269](https://github.com/juspay/hyperswitch-control-center/pull/1269)) ([`b767afc`](https://github.com/juspay/hyperswitch-control-center/commit/b767afc376bc28ac70b0dabdaff726906267fbfa))
- Remove basic auth ([#1255](https://github.com/juspay/hyperswitch-control-center/pull/1255)) ([`d8b105c`](https://github.com/juspay/hyperswitch-control-center/commit/d8b105cd51f04e671a1c9aa6873dbd7d016478f0))
- List roles table api changes ([#1258](https://github.com/juspay/hyperswitch-control-center/pull/1258)) ([`1651d2b`](https://github.com/juspay/hyperswitch-control-center/commit/1651d2b863246bd82a6ff137f10f6f2b3efc6b71))

**Full Changelog:** [`2024.09.01.0...2024.09.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.09.01.0...2024.09.02.0)

- - -

## 2024.09.01.0

### Features

- Core changes omp list ([#1249](https://github.com/juspay/hyperswitch-control-center/pull/1249)) ([`400d437`](https://github.com/juspay/hyperswitch-control-center/commit/400d437e2280248107ea084b8b70934b01b60f5a))
- Switch component for OMP ([#1221](https://github.com/juspay/hyperswitch-control-center/pull/1221)) ([`83cdcef`](https://github.com/juspay/hyperswitch-control-center/commit/83cdcef0ab24794dc2056790703c6651430a13b1))

### Bug Fixes

- Pagination rows per page selector fix ([#1246](https://github.com/juspay/hyperswitch-control-center/pull/1246)) ([`e8d319e`](https://github.com/juspay/hyperswitch-control-center/commit/e8d319ea2659ae38800ead60974bc648449cb10c))

### Miscellaneous Tasks

- Add profile id in the user info context ([#1247](https://github.com/juspay/hyperswitch-control-center/pull/1247)) ([`a4fab61`](https://github.com/juspay/hyperswitch-control-center/commit/a4fab61f267ed0c7c9685c583883873f578e4982))
- Home payments ops copy changes ([#1235](https://github.com/juspay/hyperswitch-control-center/pull/1235)) ([`f52185a`](https://github.com/juspay/hyperswitch-control-center/commit/f52185a5fdfe2953d213c8576c883128c9270c03))
- List users with api changes ([#1232](https://github.com/juspay/hyperswitch-control-center/pull/1232)) ([`6f227c8`](https://github.com/juspay/hyperswitch-control-center/commit/6f227c8e8a0e14716919b3d724ec8d8738f6e970))
- Org, merch ,profile list atom ([#1253](https://github.com/juspay/hyperswitch-control-center/pull/1253)) ([`2d4e63c`](https://github.com/juspay/hyperswitch-control-center/commit/2d4e63c583ecd999f654ed28e1086e4146ef67dd))

**Full Changelog:** [`2024.08.29.0...2024.09.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.29.0...2024.09.01.0)

- - -

## 2024.08.29.0

### Bug Fixes

- Smart retries tooltip bug fix ([#1228](https://github.com/juspay/hyperswitch-control-center/pull/1228)) ([`7edbf15`](https://github.com/juspay/hyperswitch-control-center/commit/7edbf1573c37fa3a3c72a7e7d32147e5eb445905))
- Disputes table col ordering ([#1234](https://github.com/juspay/hyperswitch-control-center/pull/1234)) ([`1974f75`](https://github.com/juspay/hyperswitch-control-center/commit/1974f756041c9fd72f6a9da054822d504530aaec))
- Payouts pagination order fix ([#1230](https://github.com/juspay/hyperswitch-control-center/pull/1230)) ([`5160e1e`](https://github.com/juspay/hyperswitch-control-center/commit/5160e1ec220b192f78eb3581b26d703dbb095515))
- Prod intent website regex change ([#1229](https://github.com/juspay/hyperswitch-control-center/pull/1229)) ([`82007f1`](https://github.com/juspay/hyperswitch-control-center/commit/82007f1decd1a03684d5391303e6850b1860d8de))
- Hyperlinks fix at login page ([#1236](https://github.com/juspay/hyperswitch-control-center/pull/1236)) ([`14fd311`](https://github.com/juspay/hyperswitch-control-center/commit/14fd311f9e64f82d9f19dccff3d1ce6a75dcc7c6))

**Full Changelog:** [`2024.08.28.0...2024.08.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.28.0...2024.08.29.0)

- - -

## 2024.08.28.0

### Miscellaneous Tasks

- User info provider changes ([#1224](https://github.com/juspay/hyperswitch-control-center/pull/1224)) ([`f86b8d5`](https://github.com/juspay/hyperswitch-control-center/commit/f86b8d5858c86faf086293e104c4ea84b47c2440))
- Auth hooks change ([#1222](https://github.com/juspay/hyperswitch-control-center/pull/1222)) ([`c830aab`](https://github.com/juspay/hyperswitch-control-center/commit/c830aabe4ea0deaf0c2dae2d0cf774cc102bdaf5))

**Full Changelog:** [`2024.08.27.0...2024.08.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.27.0...2024.08.28.0)

- - -

## 2024.08.27.0

### Features

- Paybox wellsfargo connector added ([#1202](https://github.com/juspay/hyperswitch-control-center/pull/1202)) ([`0678545`](https://github.com/juspay/hyperswitch-control-center/commit/06785458fc5fa40a25b59643178e849f6482c152))
- Pagination support for payouts table ([#1220](https://github.com/juspay/hyperswitch-control-center/pull/1220)) ([`af1aafa`](https://github.com/juspay/hyperswitch-control-center/commit/af1aafa03a1fae638b92731d67a0a10d690e2882))
- Netcetera to prod ([#1211](https://github.com/juspay/hyperswitch-control-center/pull/1211)) ([`1ee1e6f`](https://github.com/juspay/hyperswitch-control-center/commit/1ee1e6fb15d5d5b668d6e3fae7484f52497661bd))

### Miscellaneous Tasks

- Rearrange connector folders ([#1213](https://github.com/juspay/hyperswitch-control-center/pull/1213)) ([`34f0890`](https://github.com/juspay/hyperswitch-control-center/commit/34f08908fcad06bf96e3059f879eb84534b25e48))

**Full Changelog:** [`2024.08.26.0...2024.08.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.26.0...2024.08.27.0)

- - -

## 2024.08.26.0

### Bug Fixes

- Redirect on new tab fix ([#1082](https://github.com/juspay/hyperswitch-control-center/pull/1082)) ([`05aa61b`](https://github.com/juspay/hyperswitch-control-center/commit/05aa61b41949ca4b6aa08f68cbec9d019222b480))

### Miscellaneous Tasks

- Pmt billing address name fields ([#1193](https://github.com/juspay/hyperswitch-control-center/pull/1193)) ([`27a2bcb`](https://github.com/juspay/hyperswitch-control-center/commit/27a2bcbf58edab3a9269173013be0724ebdfd917))
- Graphs color code update ([#1207](https://github.com/juspay/hyperswitch-control-center/pull/1207)) ([`cbad264`](https://github.com/juspay/hyperswitch-control-center/commit/cbad264d9e249103493f9b004a12481a5f136339))
- Refactor initial pageload ([#1176](https://github.com/juspay/hyperswitch-control-center/pull/1176)) ([`3d942fb`](https://github.com/juspay/hyperswitch-control-center/commit/3d942fbcb43a500ef7ba62cf1ba2d4d8ae017963))

**Full Changelog:** [`2024.08.25.0...2024.08.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.25.0...2024.08.26.0)

- - -

## 2024.08.25.0

### Miscellaneous Tasks

- List users UI changes ([#1113](https://github.com/juspay/hyperswitch-control-center/pull/1113)) ([`939d109`](https://github.com/juspay/hyperswitch-control-center/commit/939d109986c1bfd9a9fbae2408f2b951c9a42cb3))
- Plaid minor enhancements ([#1175](https://github.com/juspay/hyperswitch-control-center/pull/1175)) ([`08b5942`](https://github.com/juspay/hyperswitch-control-center/commit/08b5942d8ff9e5bab3cd6b42052eaa6128fc79ce))

**Full Changelog:** [`2024.08.22.0...2024.08.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.22.0...2024.08.25.0)

- - -

## 2024.08.22.0

### Bug Fixes

- Loading page height before login screen ([#1195](https://github.com/juspay/hyperswitch-control-center/pull/1195)) ([`0f6de89`](https://github.com/juspay/hyperswitch-control-center/commit/0f6de8993b3c8540d7d56b06b5bb4635f939a648))
- Performance monitor bugs ([#1190](https://github.com/juspay/hyperswitch-control-center/pull/1190)) ([`047438f`](https://github.com/juspay/hyperswitch-control-center/commit/047438f2290936d50cc846f7cdf28fe7497955b6))

### Miscellaneous Tasks

- Update github workflow ([`a94f218`](https://github.com/juspay/hyperswitch-control-center/commit/a94f218c43f383990b4deac68caf8e46c0d9ef4c))

**Full Changelog:** [`2024.08.21.0...2024.08.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.21.0...2024.08.22.0)

- - -

## 2024.08.21.0

### Features

- Performance monitor exclude filter value ([#1178](https://github.com/juspay/hyperswitch-control-center/pull/1178)) ([`273afaa`](https://github.com/juspay/hyperswitch-control-center/commit/273afaa9bba08597f88bdbcc0f6ed609a183eca7))

### Bug Fixes

- Totp extra settings not visible in profile page ([#1183](https://github.com/juspay/hyperswitch-control-center/pull/1183)) ([`02faa3e`](https://github.com/juspay/hyperswitch-control-center/commit/02faa3e4cfdbbe4759200463f294ac02497ba43f))

### Miscellaneous Tasks

- Bug fix audit trail ([#1186](https://github.com/juspay/hyperswitch-control-center/pull/1186)) ([`c7b3ef2`](https://github.com/juspay/hyperswitch-control-center/commit/c7b3ef2dd647ee536e76f6e5d586491d8085e153))
- Make email with password login ([#1110](https://github.com/juspay/hyperswitch-control-center/pull/1110)) ([`8c3360c`](https://github.com/juspay/hyperswitch-control-center/commit/8c3360cad4b4f9db4223a6d55a297651ac20417b))

**Full Changelog:** [`2024.08.20.1...2024.08.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.20.1...2024.08.21.0)

- - -

## 2024.08.20.1

### Miscellaneous Tasks

- Updated wasm ([#1171](https://github.com/juspay/hyperswitch-control-center/pull/1171)) ([`33ae887`](https://github.com/juspay/hyperswitch-control-center/commit/33ae88775bb2f3de98275ef9e4e2d69402eef41c))
- Updating the user profile in mixpanel after user login ([#1065](https://github.com/juspay/hyperswitch-control-center/pull/1065)) ([`1454dd5`](https://github.com/juspay/hyperswitch-control-center/commit/1454dd53dda265bdce78d514457b508319d7fb0b))
- Connector api dependency on orders removed ([#1167](https://github.com/juspay/hyperswitch-control-center/pull/1167)) ([`3bd054b`](https://github.com/juspay/hyperswitch-control-center/commit/3bd054b153cccd88fd7964a65802e6efb46463a6))
- User revamp independent files ([#1169](https://github.com/juspay/hyperswitch-control-center/pull/1169)) ([`2a8499e`](https://github.com/juspay/hyperswitch-control-center/commit/2a8499e7ce42850683242642bcfe6666d27201d6))

**Full Changelog:** [`2024.08.20.0...2024.08.20.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.20.0...2024.08.20.1)

- - -

## 2024.08.20.0

### Bug Fixes

- Failure rate formula fix ([#1170](https://github.com/juspay/hyperswitch-control-center/pull/1170)) ([`86bcb16`](https://github.com/juspay/hyperswitch-control-center/commit/86bcb167bf6ab8c6e4b8f7c12479ab62bafcf5a3))

### Refactors

- Removed unused packages ([#1141](https://github.com/juspay/hyperswitch-control-center/pull/1141)) ([`caa9113`](https://github.com/juspay/hyperswitch-control-center/commit/caa91136bb5eed97c5dcf12591b53d655fca9b4d))

### Miscellaneous Tasks

- Refactor gauge chart entity ([#1161](https://github.com/juspay/hyperswitch-control-center/pull/1161)) ([`e9454b8`](https://github.com/juspay/hyperswitch-control-center/commit/e9454b89d3218fbb950e6b35fb2fb5a99c100ff2))
- Refund type removed from refunds api ([#1165](https://github.com/juspay/hyperswitch-control-center/pull/1165)) ([`178dc64`](https://github.com/juspay/hyperswitch-control-center/commit/178dc642f1404e6185d237c7913844d90852c9b1))
- Frm api changes ([#782](https://github.com/juspay/hyperswitch-control-center/pull/782)) ([`e0f2911`](https://github.com/juspay/hyperswitch-control-center/commit/e0f2911a899a946d9983d6af97722767a56fbf99))

**Full Changelog:** [`2024.08.14.0...2024.08.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.14.0...2024.08.20.0)

- - -

## 2024.08.14.0

### Features

- Added sr rate graphs ([#1155](https://github.com/juspay/hyperswitch-control-center/pull/1155)) ([`f8e4c13`](https://github.com/juspay/hyperswitch-control-center/commit/f8e4c1375f977b68f67badc23afe23b63a6de4d1))

### Bug Fixes

- Bug fix ([#1153](https://github.com/juspay/hyperswitch-control-center/pull/1153)) ([`88b5e8b`](https://github.com/juspay/hyperswitch-control-center/commit/88b5e8b75c945179de4dce4058fb4e4d5874dc70))
- Feature flag sidebar ([#1152](https://github.com/juspay/hyperswitch-control-center/pull/1152)) ([`2361077`](https://github.com/juspay/hyperswitch-control-center/commit/2361077afdc0f7f0c768913f0345bdeae1839886))

### Miscellaneous Tasks

- Added mca id in 3ds and pm auth table ([#1157](https://github.com/juspay/hyperswitch-control-center/pull/1157)) ([`ec3529f`](https://github.com/juspay/hyperswitch-control-center/commit/ec3529fc911955fd939d43a07a728916a3987aff))

**Full Changelog:** [`2024.08.13.1...2024.08.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.13.1...2024.08.14.0)

- - -

## 2024.08.13.1

### Features

- Added table performance ([#1149](https://github.com/juspay/hyperswitch-control-center/pull/1149)) ([`1199a23`](https://github.com/juspay/hyperswitch-control-center/commit/1199a2337c0e1f5440d86954f58351272a54f65e))

### Miscellaneous Tasks

- Update wasm ([#1151](https://github.com/juspay/hyperswitch-control-center/pull/1151)) ([`1873d89`](https://github.com/juspay/hyperswitch-control-center/commit/1873d89d8bd56075ae2be3d272c27ae9ad132c3f))

**Full Changelog:** [`2024.08.13.0...2024.08.13.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.13.0...2024.08.13.1)

- - -

## 2024.08.13.0

### Features

- Integrating pm authenticator processor in connector flow ([#1126](https://github.com/juspay/hyperswitch-control-center/pull/1126)) ([`123324a`](https://github.com/juspay/hyperswitch-control-center/commit/123324adfc3e68cbd9ded9dcf5ad21a74c7b1608))

### Bug Fixes

- Commented apex charts and pinned mixpanel version ([#1136](https://github.com/juspay/hyperswitch-control-center/pull/1136)) ([`59e6b12`](https://github.com/juspay/hyperswitch-control-center/commit/59e6b12c4384c5e127a750b794efc29474fcb85f))
- Frm api payload update ([#1143](https://github.com/juspay/hyperswitch-control-center/pull/1143)) ([`a145ef3`](https://github.com/juspay/hyperswitch-control-center/commit/a145ef3dcbf5c40372f067505273b26fd3aea33a))

### Refactors

- Using joinWith instead of joinWithUnsafe ([#1135](https://github.com/juspay/hyperswitch-control-center/pull/1135)) ([`da65d02`](https://github.com/juspay/hyperswitch-control-center/commit/da65d0291aa38c17cba2c3fef6596a10d158283b))

### Miscellaneous Tasks

- Make global search result table consistent ([#1147](https://github.com/juspay/hyperswitch-control-center/pull/1147)) ([`da9b669`](https://github.com/juspay/hyperswitch-control-center/commit/da9b6697d6f85d848e8a24e6cdf3b18ab22951bc))
- Added merchant connector id ([#1140](https://github.com/juspay/hyperswitch-control-center/pull/1140)) ([`0a5d210`](https://github.com/juspay/hyperswitch-control-center/commit/0a5d210bd194f56e9b0c77da4f6afda14640e485))

**Full Changelog:** [`2024.08.12.0...2024.08.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.12.0...2024.08.13.0)

- - -

## 2024.08.12.0

### Miscellaneous Tasks

- Changes for tabs & table customization ([#1118](https://github.com/juspay/hyperswitch-control-center/pull/1118)) ([`7f126c2`](https://github.com/juspay/hyperswitch-control-center/commit/7f126c28754fb75246bacee82a6b76736bedd5a6))
- Performance monitor ([#1102](https://github.com/juspay/hyperswitch-control-center/pull/1102)) ([`143397b`](https://github.com/juspay/hyperswitch-control-center/commit/143397b7ae74ae1b47a83382efd82deb77ad5517))

**Full Changelog:** [`2024.08.11.0...2024.08.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.11.0...2024.08.12.0)

- - -

## 2024.08.11.0

### Features

- Addition of pm authentication processor new flow ([#1125](https://github.com/juspay/hyperswitch-control-center/pull/1125)) ([`d18b4d1`](https://github.com/juspay/hyperswitch-control-center/commit/d18b4d15a63860a8729fccf48a0ba7217ca7b87d))

### Bug Fixes

- Frictionless success metric fix ([#1133](https://github.com/juspay/hyperswitch-control-center/pull/1133)) ([`d5afd14`](https://github.com/juspay/hyperswitch-control-center/commit/d5afd14131749d2405325c11ed1e842dcf50b775))

**Full Changelog:** [`2024.08.08.0...2024.08.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.08.0...2024.08.11.0)

- - -

## 2024.08.08.0

### Features

- Enable pm_auth_processor ([#1124](https://github.com/juspay/hyperswitch-control-center/pull/1124)) ([`5702f1e`](https://github.com/juspay/hyperswitch-control-center/commit/5702f1e776ea5ce4b7481e5f49f1e818227899df))

### Miscellaneous Tasks

- Refactor user info context ([#1103](https://github.com/juspay/hyperswitch-control-center/pull/1103)) ([`919201a`](https://github.com/juspay/hyperswitch-control-center/commit/919201a10c690e556cef8d5158f8fe9d176c9973))

**Full Changelog:** [`2024.08.06.0...2024.08.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.06.0...2024.08.08.0)

- - -

## 2024.08.06.0

### Refactors

- V(11) rescript - unit functions not required, file name change form bucklescript to res.js & react dom style ([#1100](https://github.com/juspay/hyperswitch-control-center/pull/1100)) ([`798bfb5`](https://github.com/juspay/hyperswitch-control-center/commit/798bfb56d37c593e73bf02f593b43cf35c9bd71f))

### Miscellaneous Tasks

- Extra param for row level customization with select box ([#1116](https://github.com/juspay/hyperswitch-control-center/pull/1116)) ([`d201eac`](https://github.com/juspay/hyperswitch-control-center/commit/d201eac7e38723fdf45cd9def5f41aeac07cf054))
- Plaid connector addition ([#1096](https://github.com/juspay/hyperswitch-control-center/pull/1096)) ([`e20fae4`](https://github.com/juspay/hyperswitch-control-center/commit/e20fae4cc68ee97cd560adeaeeec6b7e2ef39fec))

**Full Changelog:** [`2024.08.02.1...2024.08.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.02.1...2024.08.06.0)

- - -

## 2024.08.02.1

### Bug Fixes

- Added datatrans connector icon ([#1104](https://github.com/juspay/hyperswitch-control-center/pull/1104)) ([`ea5a995`](https://github.com/juspay/hyperswitch-control-center/commit/ea5a995f5a912f7a19884b728dc2060964b74067))
- Signin password check removed ([#1106](https://github.com/juspay/hyperswitch-control-center/pull/1106)) ([`1858350`](https://github.com/juspay/hyperswitch-control-center/commit/18583501ff744af89e36886c31de6d08a2e35aa4))

**Full Changelog:** [`2024.08.02.0...2024.08.02.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.08.02.0...2024.08.02.1)

- - -

## 2024.08.02.0

### Bug Fixes

- Apple pay extra step for stripe ([#1098](https://github.com/juspay/hyperswitch-control-center/pull/1098)) ([`b9d2ce7`](https://github.com/juspay/hyperswitch-control-center/commit/b9d2ce72589ee8359c8090f928e2f05c66d2a1d8))

**Full Changelog:** [`2024.07.30.0...2024.08.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.30.0...2024.08.02.0)

- - -

## 2024.07.30.0

### Miscellaneous Tasks

- Update pull request template ([`d17044b`](https://github.com/juspay/hyperswitch-control-center/commit/d17044b9d8214f9c6e00b00661852f78f634fdda))

**Full Changelog:** [`2024.07.29.0...2024.07.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.29.0...2024.07.30.0)

- - -

## 2024.07.29.0

### Features

- Datatrans new connector addition ([#1091](https://github.com/juspay/hyperswitch-control-center/pull/1091)) ([`257b929`](https://github.com/juspay/hyperswitch-control-center/commit/257b9295d670591d4a22680ccdce4070eeded1e6))

### Bug Fixes

- Remove name from address fields ([#1089](https://github.com/juspay/hyperswitch-control-center/pull/1089)) ([`b4e1c1a`](https://github.com/juspay/hyperswitch-control-center/commit/b4e1c1a6f1c68b1a0b1924fe594e77f8b80c1972))

### Miscellaneous Tasks

- Improve lighthouse performance ([#1088](https://github.com/juspay/hyperswitch-control-center/pull/1088)) ([`ca411a5`](https://github.com/juspay/hyperswitch-control-center/commit/ca411a5f206f5c6b012defcabf3e6c6d568f27c5))

**Full Changelog:** [`2024.07.28.0...2024.07.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.28.0...2024.07.29.0)

- - -

## 2024.07.28.0

### Bug Fixes

- Rename single stat titles and tooltip texts ([#1081](https://github.com/juspay/hyperswitch-control-center/pull/1081)) ([`503f922`](https://github.com/juspay/hyperswitch-control-center/commit/503f92257c43dc471cc4add96e42650ffcbb5110))

**Full Changelog:** [`2024.07.26.0...2024.07.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.26.0...2024.07.28.0)

- - -

## 2024.07.26.0

### Miscellaneous Tasks

- Added frm_metadata in payments api sdk ([#1075](https://github.com/juspay/hyperswitch-control-center/pull/1075)) ([`267722c`](https://github.com/juspay/hyperswitch-control-center/commit/267722c659b491f934552f1d822a473d9a6a401e))

**Full Changelog:** [`2024.07.25.0...2024.07.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.25.0...2024.07.26.0)

- - -

## 2024.07.25.0

### Bug Fixes

- Enhance filters ui ([#1038](https://github.com/juspay/hyperswitch-control-center/pull/1038)) ([`7343036`](https://github.com/juspay/hyperswitch-control-center/commit/7343036f22ad713d6e50744ecfc4e0d51a385a53))
- Order customer email fix ([#1071](https://github.com/juspay/hyperswitch-control-center/pull/1071)) ([`a0862fd`](https://github.com/juspay/hyperswitch-control-center/commit/a0862fd25a780363e4247680dc082107ca1b37a3))

### Miscellaneous Tasks

- Apple pay extra step addition ([#1047](https://github.com/juspay/hyperswitch-control-center/pull/1047)) ([`5896b0c`](https://github.com/juspay/hyperswitch-control-center/commit/5896b0cd53eefadfbd4c449a52bf2cc5ad401ceb))

**Full Changelog:** [`2024.07.24.1...2024.07.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.24.1...2024.07.25.0)

- - -

## 2024.07.24.1

### Features

- PCI certificate addition under compliance section ([#1027](https://github.com/juspay/hyperswitch-control-center/pull/1027)) ([`a84d8d8`](https://github.com/juspay/hyperswitch-control-center/commit/a84d8d8540155c703bae7552e51df4711d2c1e9a))

### Bug Fixes

- Redirect url from payout connector enable/disable ([#1026](https://github.com/juspay/hyperswitch-control-center/pull/1026)) ([`d8a6c32`](https://github.com/juspay/hyperswitch-control-center/commit/d8a6c32398198ee30f9f217cf7702dd02bf6e5e5))
- Global search back button fix ([#1053](https://github.com/juspay/hyperswitch-control-center/pull/1053)) ([`f52c4c3`](https://github.com/juspay/hyperswitch-control-center/commit/f52c4c3664aa1e5b926d4e0108e45d28fda877b8))
- SimplifiedHelper optional ([#1063](https://github.com/juspay/hyperswitch-control-center/pull/1063)) ([`69f10fe`](https://github.com/juspay/hyperswitch-control-center/commit/69f10fefd2c45fa44198e0e9075a494e8eb9ee2a))

### Miscellaneous Tasks

- Removing recon_v2 feature flag ([#1057](https://github.com/juspay/hyperswitch-control-center/pull/1057)) ([`4ef9c9b`](https://github.com/juspay/hyperswitch-control-center/commit/4ef9c9b80d510bf1e90119f7886b9ee7affee7f3))
- Core api changes for regex ([#1048](https://github.com/juspay/hyperswitch-control-center/pull/1048)) ([`1450c32`](https://github.com/juspay/hyperswitch-control-center/commit/1450c323fa727d1ae4488005440a70fbfa595a3b))

**Full Changelog:** [`2024.07.24.0...2024.07.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.24.0...2024.07.24.1)

- - -

## 2024.07.24.0

### Bug Fixes

- Sign up button not working for sbx ([#1059](https://github.com/juspay/hyperswitch-control-center/pull/1059)) ([`f56a2cd`](https://github.com/juspay/hyperswitch-control-center/commit/f56a2cdb0a5abc5d36ec9807e00b7ebdc525ac3e))

**Full Changelog:** [`2024.07.23.1...2024.07.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.23.1...2024.07.24.0)

- - -

## 2024.07.23.1

### Bug Fixes

- Webhook custom headers ([#1056](https://github.com/juspay/hyperswitch-control-center/pull/1056)) ([`f9f670a`](https://github.com/juspay/hyperswitch-control-center/commit/f9f670a1349287acaa1bac8868c49ff443d3fdb5))

**Full Changelog:** [`2024.07.23.0...2024.07.23.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.23.0...2024.07.23.1)

- - -

## 2024.07.23.0

### Miscellaneous Tasks

- Itaubank icon update ([#1045](https://github.com/juspay/hyperswitch-control-center/pull/1045)) ([`beb72b7`](https://github.com/juspay/hyperswitch-control-center/commit/beb72b7627edc807a45faf5b4608479d341ef2b5))

**Full Changelog:** [`2024.07.22.1...2024.07.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.22.1...2024.07.23.0)

- - -

## 2024.07.22.1

### Bug Fixes

- Password validation ([#817](https://github.com/juspay/hyperswitch-control-center/pull/817)) ([`de53095`](https://github.com/juspay/hyperswitch-control-center/commit/de53095b646b17f452cadeaba455d08b7095f16a))
- Webhook custom headers ([#1044](https://github.com/juspay/hyperswitch-control-center/pull/1044)) ([`27be1d9`](https://github.com/juspay/hyperswitch-control-center/commit/27be1d9575ddf0e3ba18837a1671953f57d8a009))

**Full Changelog:** [`2024.07.22.0...2024.07.22.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.22.0...2024.07.22.1)

- - -

## 2024.07.22.0

### Features

- Itaubank connector addition ([#1042](https://github.com/juspay/hyperswitch-control-center/pull/1042)) ([`2880ab1`](https://github.com/juspay/hyperswitch-control-center/commit/2880ab1dc482ce9904f23959870e2e49d94d0150))

### Bug Fixes

- Global search empty table fix ([#1030](https://github.com/juspay/hyperswitch-control-center/pull/1030)) ([`fb29fb4`](https://github.com/juspay/hyperswitch-control-center/commit/fb29fb499f89111e6d9998b355a6b46f9fa5e2cb))
- Custom webhook headers ([#1036](https://github.com/juspay/hyperswitch-control-center/pull/1036)) ([`66e8885`](https://github.com/juspay/hyperswitch-control-center/commit/66e8885593286dcfaeca472a5af7660562dca5c8))
- Moved delete all sample data from account settings ([#1034](https://github.com/juspay/hyperswitch-control-center/pull/1034)) ([`be4b048`](https://github.com/juspay/hyperswitch-control-center/commit/be4b04817ce107aec49c873a67ec9f2fa0ac2dfb))
- Global search minor bugs ([#1040](https://github.com/juspay/hyperswitch-control-center/pull/1040)) ([`f74cdfc`](https://github.com/juspay/hyperswitch-control-center/commit/f74cdfc70aeaaa500a894cc39b692bfb5f457e50))

### Refactors

- Uiutils unnecessary component and module can be removed ([#1032](https://github.com/juspay/hyperswitch-control-center/pull/1032)) ([`c40b0d5`](https://github.com/juspay/hyperswitch-control-center/commit/c40b0d5bb21ddd0b14c9aac493590d3a968c1f4d))

### Miscellaneous Tasks

- Payment attempt table sorting ([#1031](https://github.com/juspay/hyperswitch-control-center/pull/1031)) ([`b32d712`](https://github.com/juspay/hyperswitch-control-center/commit/b32d71226f3102f639723ff978e059e556585257))

**Full Changelog:** [`2024.07.21.0...2024.07.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.21.0...2024.07.22.0)

- - -

## 2024.07.21.0

### Bug Fixes

- Add icon fix for safari ([#1028](https://github.com/juspay/hyperswitch-control-center/pull/1028)) ([`75a778b`](https://github.com/juspay/hyperswitch-control-center/commit/75a778bcc3ad1d507e7a97a8c4e0e77a62136d49))

**Full Changelog:** [`2024.07.18.1...2024.07.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.18.1...2024.07.21.0)

- - -

## 2024.07.18.1

### Features

- Add mifinity to prod ([#1013](https://github.com/juspay/hyperswitch-control-center/pull/1013)) ([`d2b5645`](https://github.com/juspay/hyperswitch-control-center/commit/d2b56459bb63492226c556ff1288ae958ae0cb2f))
- Customer more details ([#1005](https://github.com/juspay/hyperswitch-control-center/pull/1005)) ([`b00e07a`](https://github.com/juspay/hyperswitch-control-center/commit/b00e07af28764c14d61ed4c0b97b14b8f3840dc2))

### Bug Fixes

- Active payments counter changes ([#998](https://github.com/juspay/hyperswitch-control-center/pull/998)) ([`741641f`](https://github.com/juspay/hyperswitch-control-center/commit/741641f29cceb22689b60fcccdc53699bf668159))
- Payout routing rule list ([#1020](https://github.com/juspay/hyperswitch-control-center/pull/1020)) ([`55dd2e1`](https://github.com/juspay/hyperswitch-control-center/commit/55dd2e1337f635070629730ac35c14304b351d87))
- Dropdown scroll issue & redundant css removed ([#1022](https://github.com/juspay/hyperswitch-control-center/pull/1022)) ([`349456c`](https://github.com/juspay/hyperswitch-control-center/commit/349456cc0e08bd6114a329c2b7caceff536f450d))
- Global search email fix ([#1018](https://github.com/juspay/hyperswitch-control-center/pull/1018)) ([`60b6155`](https://github.com/juspay/hyperswitch-control-center/commit/60b6155b30767f04d2442b4c036f20628c716b35))
- Table local sort fix ([#1006](https://github.com/juspay/hyperswitch-control-center/pull/1006)) ([`7b361b7`](https://github.com/juspay/hyperswitch-control-center/commit/7b361b7e0910720c1188e90736e719f073aff2d6))

### Refactors

- Useeffect 0-7 to single useeffect ([#1011](https://github.com/juspay/hyperswitch-control-center/pull/1011)) ([`0cbd716`](https://github.com/juspay/hyperswitch-control-center/commit/0cbd716c7760c0db5f9d6fb41673769fecb96b52))

### Miscellaneous Tasks

- Usecallback & usememo removal ([#1014](https://github.com/juspay/hyperswitch-control-center/pull/1014)) ([`7efb82c`](https://github.com/juspay/hyperswitch-control-center/commit/7efb82c3151208f1c906d0262ca8d3318477ecd2))
- Replaced deprecated function in webpack ([#999](https://github.com/juspay/hyperswitch-control-center/pull/999)) ([`07d31cd`](https://github.com/juspay/hyperswitch-control-center/commit/07d31cd8f2eed3716061a5cb3d5ad993d53b1ab4))
- Enable mifinity prod ([#1009](https://github.com/juspay/hyperswitch-control-center/pull/1009)) ([`2adfacd`](https://github.com/juspay/hyperswitch-control-center/commit/2adfacd205443271bffc519b05c1571a6f506344))

**Full Changelog:** [`2024.07.18.0...2024.07.18.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.18.0...2024.07.18.1)

- - -

## 2024.07.18.0

### Features

- Add support for outgoing webhook custom http headers ([#1001](https://github.com/juspay/hyperswitch-control-center/pull/1001)) ([`f693f41`](https://github.com/juspay/hyperswitch-control-center/commit/f693f410b855fa0eeb039b69cd5674503482d6c0))

### Bug Fixes

- Added attempts count column in payment list table ([#1002](https://github.com/juspay/hyperswitch-control-center/pull/1002)) ([`8ab36fa`](https://github.com/juspay/hyperswitch-control-center/commit/8ab36fa39e6c52ab0cfd06d7aaa8c240857f9cee))

**Full Changelog:** [`2024.07.17.0...2024.07.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.17.0...2024.07.18.0)

- - -

## 2024.07.17.0

### Bug Fixes

- Removed agreement screen ([#991](https://github.com/juspay/hyperswitch-control-center/pull/991)) ([`ac658fd`](https://github.com/juspay/hyperswitch-control-center/commit/ac658fdfe75243761fb74b88a6409d4c29282f1c))

**Full Changelog:** [`2024.07.16.0...2024.07.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.16.0...2024.07.17.0)

- - -

## 2024.07.16.0

### Features

- Feat: load time metric - user journey analytics ([#931](https://github.com/juspay/hyperswitch-control-center/pull/931)) ([`0df6ad4`](https://github.com/juspay/hyperswitch-control-center/commit/0df6ad455678b83a4d018508de06e70cf990a123))

### Bug Fixes

- Audit trail empty log details on load ([#988](https://github.com/juspay/hyperswitch-control-center/pull/988)) ([`1f5428b`](https://github.com/juspay/hyperswitch-control-center/commit/1f5428b4d0384209c41233bc40d778f8624cca99))

### Miscellaneous Tasks

- Mixpanel changes ([#946](https://github.com/juspay/hyperswitch-control-center/pull/946)) ([`9dca413`](https://github.com/juspay/hyperswitch-control-center/commit/9dca4139c3546467bbc908fce7bceed45836d7b0))
- Inform users about currency denomination in rule based routing ([#997](https://github.com/juspay/hyperswitch-control-center/pull/997)) ([`66c90b6`](https://github.com/juspay/hyperswitch-control-center/commit/66c90b694ec9997c483897b25bde03d288014876))
- Removed open source tile from Home ([#979](https://github.com/juspay/hyperswitch-control-center/pull/979)) ([`5f6e7ed`](https://github.com/juspay/hyperswitch-control-center/commit/5f6e7ed68a006323b8a4c8d841def3ae5a1f904e))

**Full Changelog:** [`2024.07.15.0...2024.07.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.15.0...2024.07.16.0)

- - -

## 2024.07.15.0

### Bug Fixes

- Generate reports access change ([#980](https://github.com/juspay/hyperswitch-control-center/pull/980)) ([`d5bc21f`](https://github.com/juspay/hyperswitch-control-center/commit/d5bc21f9bc777349e2a3428300f1d080643192c2))

**Full Changelog:** [`2024.07.12.0...2024.07.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.12.0...2024.07.15.0)

- - -

## 2024.07.12.0

### Bug Fixes

- Dynamic charts and filter ui fix ([#982](https://github.com/juspay/hyperswitch-control-center/pull/982)) ([`31e5637`](https://github.com/juspay/hyperswitch-control-center/commit/31e563754d875b9ef906e59b59eb79136ff6a545))

### Miscellaneous Tasks

- Removed console logs for testing ([#976](https://github.com/juspay/hyperswitch-control-center/pull/976)) ([`a0c323a`](https://github.com/juspay/hyperswitch-control-center/commit/a0c323a365c69514563651d84958d0ececaa482f))
- Refactor connector metadata ([#854](https://github.com/juspay/hyperswitch-control-center/pull/854)) ([`604b028`](https://github.com/juspay/hyperswitch-control-center/commit/604b02849dda2e9caa9f403823715dd2a96a4f7c))
- Update latest wasm ([#985](https://github.com/juspay/hyperswitch-control-center/pull/985)) ([`a4e216c`](https://github.com/juspay/hyperswitch-control-center/commit/a4e216c94c774f7e6f6d4d3b9f26e418337cb115))

**Full Changelog:** [`2024.07.11.3...2024.07.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.11.3...2024.07.12.0)

- - -

## 2024.07.11.3

### Bug Fixes

- User analytics granularity fix ([#975](https://github.com/juspay/hyperswitch-control-center/pull/975)) ([`e06709b`](https://github.com/juspay/hyperswitch-control-center/commit/e06709bb11f63030b762addd4839c97ccb026b22))

### Miscellaneous Tasks

- Common filter for payment analytics page ([#963](https://github.com/juspay/hyperswitch-control-center/pull/963)) ([`3808822`](https://github.com/juspay/hyperswitch-control-center/commit/3808822c20553f6d334fde55e542c4d1bd0aaee9))

**Full Changelog:** [`2024.07.11.2...2024.07.11.3`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.11.2...2024.07.11.3)

- - -

## 2024.07.11.2

### Features

- Global search customer email search support ([#964](https://github.com/juspay/hyperswitch-control-center/pull/964)) ([`ba411d1`](https://github.com/juspay/hyperswitch-control-center/commit/ba411d179aa89891fbf60e42dd07c5b9a43766b1))

### Miscellaneous Tasks

- Orders and refunds more table items ([#970](https://github.com/juspay/hyperswitch-control-center/pull/970)) ([`088f0d1`](https://github.com/juspay/hyperswitch-control-center/commit/088f0d1339ce2a2c7b4b19572c016eeae7ea8667))
- New connector added bambora apac ([#973](https://github.com/juspay/hyperswitch-control-center/pull/973)) ([`2658d8a`](https://github.com/juspay/hyperswitch-control-center/commit/2658d8a960405c0a5a5ecb185121062f021a4b0d))

**Full Changelog:** [`2024.07.11.1...2024.07.11.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.11.1...2024.07.11.2)

- - -

## 2024.07.11.1

### Bug Fixes

- Recon not showing fixes ([#971](https://github.com/juspay/hyperswitch-control-center/pull/971)) ([`76c084a`](https://github.com/juspay/hyperswitch-control-center/commit/76c084ab813517fcdcde02576a8a04cd14e7df90))

**Full Changelog:** [`2024.07.11.0...2024.07.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.11.0...2024.07.11.1)

- - -

## 2024.07.11.0

### Features

- Recon module changes ([#926](https://github.com/juspay/hyperswitch-control-center/pull/926)) ([`f5669fa`](https://github.com/juspay/hyperswitch-control-center/commit/f5669fa4877c87d8478b3f481973e65e48470da7))

**Full Changelog:** [`2024.07.10.1...2024.07.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.10.1...2024.07.11.0)

- - -

## 2024.07.10.1

### Features

- Added feature flag for the granularity ([#961](https://github.com/juspay/hyperswitch-control-center/pull/961)) ([`6e52d4e`](https://github.com/juspay/hyperswitch-control-center/commit/6e52d4e71d2a52c6fd43f33cacd140ada2426b55))

### Bug Fixes

- Heading for new table column merchant ref id ([#959](https://github.com/juspay/hyperswitch-control-center/pull/959)) ([`6fff367`](https://github.com/juspay/hyperswitch-control-center/commit/6fff367c6423e1ac387f8d1bb5931c48369d4898))

### Miscellaneous Tasks

- Url refactoring ([#957](https://github.com/juspay/hyperswitch-control-center/pull/957)) ([`cca1cb9`](https://github.com/juspay/hyperswitch-control-center/commit/cca1cb9fea4d47e2b9b3bf5d8dfbb367a7d758db))
- File restructure and rearrangement ([#944](https://github.com/juspay/hyperswitch-control-center/pull/944)) ([`8ac8f7a`](https://github.com/juspay/hyperswitch-control-center/commit/8ac8f7a823e17d3b4d6a2d3d13e4e483f2af4df3))

**Full Changelog:** [`2024.07.10.0...2024.07.10.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.10.0...2024.07.10.1)

- - -

## 2024.07.10.0

### Miscellaneous Tasks

- Added razorpay in payment connectors ([#951](https://github.com/juspay/hyperswitch-control-center/pull/951)) ([`e426c95`](https://github.com/juspay/hyperswitch-control-center/commit/e426c95f9e052cb05770ee7f82c6fa7fae1e4942))

**Full Changelog:** [`2024.07.09.1...2024.07.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.09.1...2024.07.10.0)

- - -

## 2024.07.09.1

### Features

- Mixpanel page view ([#933](https://github.com/juspay/hyperswitch-control-center/pull/933)) ([`eeffd40`](https://github.com/juspay/hyperswitch-control-center/commit/eeffd403f510a570dd1d6bdfda693ead3b083293))

### Miscellaneous Tasks

- Added merchant order reference id field in "more payment details" ([#942](https://github.com/juspay/hyperswitch-control-center/pull/942)) ([`2a9ce62`](https://github.com/juspay/hyperswitch-control-center/commit/2a9ce622f72008c3eda91123ea25577cd3e5fd20))
- Api utils refactoring ([#936](https://github.com/juspay/hyperswitch-control-center/pull/936)) ([`c11a098`](https://github.com/juspay/hyperswitch-control-center/commit/c11a0983af34b75cba3492bf12148b6ba9eb0568))

**Full Changelog:** [`2024.07.09.0...2024.07.09.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.09.0...2024.07.09.1)

- - -

## 2024.07.09.0

### Bug Fixes

- Return url validation ([#934](https://github.com/juspay/hyperswitch-control-center/pull/934)) ([`8db4272`](https://github.com/juspay/hyperswitch-control-center/commit/8db4272bea32c5ae2a3d6fe0d1713a9f85831018))

**Full Changelog:** [`2024.07.05.2...2024.07.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.05.2...2024.07.09.0)

- - -

## 2024.07.05.2

### Miscellaneous Tasks

- Add package apex ([#928](https://github.com/juspay/hyperswitch-control-center/pull/928)) ([`5f3ac2d`](https://github.com/juspay/hyperswitch-control-center/commit/5f3ac2dbe381d243fc2d1a5c975c781fec6f7841))

**Full Changelog:** [`2024.07.05.1...2024.07.05.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.05.1...2024.07.05.2)

- - -

## 2024.07.05.1

### Features

- Analytics more granularity to the graphs ([#924](https://github.com/juspay/hyperswitch-control-center/pull/924)) ([`58fbd32`](https://github.com/juspay/hyperswitch-control-center/commit/58fbd3226a6f063232f7f4a5ac730faf8ff73316))

### Bug Fixes

- Analytics warnings ([#925](https://github.com/juspay/hyperswitch-control-center/pull/925)) ([`67d85a8`](https://github.com/juspay/hyperswitch-control-center/commit/67d85a8f1f906a1712afd385b23831032f276f97))

### Miscellaneous Tasks

- Analytics filters separation ([#863](https://github.com/juspay/hyperswitch-control-center/pull/863)) ([`dfa33ef`](https://github.com/juspay/hyperswitch-control-center/commit/dfa33ef6ab50786ca61e18b8597a10b486b03430))

**Full Changelog:** [`2024.07.05.0...2024.07.05.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.05.0...2024.07.05.1)

- - -

## 2024.07.05.0

### Bug Fixes

- Accept invite flow breaking for non-auth users ([#919](https://github.com/juspay/hyperswitch-control-center/pull/919)) ([`03cc8c9`](https://github.com/juspay/hyperswitch-control-center/commit/03cc8c90009560628f590032abf0813c9717c14b))

**Full Changelog:** [`2024.07.04.0...2024.07.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.04.0...2024.07.05.0)

- - -

## 2024.07.04.0

### Bug Fixes

- Domain addition in logout url ([#904](https://github.com/juspay/hyperswitch-control-center/pull/904)) ([`ea317c4`](https://github.com/juspay/hyperswitch-control-center/commit/ea317c485115b57f9a69a02f77aa2007c43d558f))
- Routing stack bug fix ([#917](https://github.com/juspay/hyperswitch-control-center/pull/917)) ([`89a5894`](https://github.com/juspay/hyperswitch-control-center/commit/89a58949f0d6d9025d1ebc5ead4231c09396f368))

### Miscellaneous Tasks

- Sidebar scrollbar individual component css ([#908](https://github.com/juspay/hyperswitch-control-center/pull/908)) ([`4e723f8`](https://github.com/juspay/hyperswitch-control-center/commit/4e723f802259259a935728ef83a82db788df8397))
- Orders card network column change and orders and refunds more … ([#895](https://github.com/juspay/hyperswitch-control-center/pull/895)) ([`89882b4`](https://github.com/juspay/hyperswitch-control-center/commit/89882b41292e329686e89065ce2416b6a088580d))

**Full Changelog:** [`2024.07.03.0...2024.07.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.03.0...2024.07.04.0)

- - -

## 2024.07.03.0

### Miscellaneous Tasks

- More date filter options ([#896](https://github.com/juspay/hyperswitch-control-center/pull/896)) ([`f6df0c3`](https://github.com/juspay/hyperswitch-control-center/commit/f6df0c370207ff1e77b11cf184043e4c6761d104))
- Upgrade to latest rescript version ([#847](https://github.com/juspay/hyperswitch-control-center/pull/847)) ([`8ca1fe4`](https://github.com/juspay/hyperswitch-control-center/commit/8ca1fe4c5f1caf32fb388b6bb1c56bc696683a0e))
- Refactor theme ([#912](https://github.com/juspay/hyperswitch-control-center/pull/912)) ([`f757d00`](https://github.com/juspay/hyperswitch-control-center/commit/f757d0064066b3ff857fcae559f9ac6125b2534c))

**Full Changelog:** [`2024.07.02.0...2024.07.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.02.0...2024.07.03.0)

- - -

## 2024.07.02.0

### Miscellaneous Tasks

- Removed avg ticket size and refunds propcessed amount ([#892](https://github.com/juspay/hyperswitch-control-center/pull/892)) ([`e0ac19e`](https://github.com/juspay/hyperswitch-control-center/commit/e0ac19e0af32388ee5b4789e033cef25f149560a))
- Webhooks multi request support ([#890](https://github.com/juspay/hyperswitch-control-center/pull/890)) ([`ca489e5`](https://github.com/juspay/hyperswitch-control-center/commit/ca489e5f625ca1b987c731abda5bdb2fb0ec7bcb))

**Full Changelog:** [`2024.07.01.2...2024.07.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.01.2...2024.07.02.0)

- - -

## 2024.07.01.2

### Features

- Feat: realtime user analytics ([#872](https://github.com/juspay/hyperswitch-control-center/pull/872)) ([`b6d6036`](https://github.com/juspay/hyperswitch-control-center/commit/b6d603621541fa46fbe53f5e43c4bac4a33e58ab))

### Bug Fixes

- Signup auth methods ([#887](https://github.com/juspay/hyperswitch-control-center/pull/887)) ([`6e6f469`](https://github.com/juspay/hyperswitch-control-center/commit/6e6f4697f1c0da63463693341f5a29079d494155))

**Full Changelog:** [`2024.07.01.1...2024.07.01.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.01.1...2024.07.01.2)

- - -

## 2024.07.01.1

### Miscellaneous Tasks

- Singout api call falling using spt ([#885](https://github.com/juspay/hyperswitch-control-center/pull/885)) ([`0e28321`](https://github.com/juspay/hyperswitch-control-center/commit/0e283213d660f9d4994a074c62b5c306fda4eec4))
- Payment logs ui changes ([#883](https://github.com/juspay/hyperswitch-control-center/pull/883)) ([`e977daf`](https://github.com/juspay/hyperswitch-control-center/commit/e977dafd85c15745279fc378e669c3c293531852))

**Full Changelog:** [`2024.07.01.0...2024.07.01.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.07.01.0...2024.07.01.1)

- - -

## 2024.07.01.0

### Refactors

- Handle logout hook changes ([#881](https://github.com/juspay/hyperswitch-control-center/pull/881)) ([`e2a81ba`](https://github.com/juspay/hyperswitch-control-center/commit/e2a81ba700f081d030d5521e44e5345a0d8f8569))

**Full Changelog:** [`2024.06.28.0...2024.07.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.28.0...2024.07.01.0)

- - -

## 2024.06.28.0

### Miscellaneous Tasks

- Allow singup based on auth methods ([#878](https://github.com/juspay/hyperswitch-control-center/pull/878)) ([`48904da`](https://github.com/juspay/hyperswitch-control-center/commit/48904da42b0839209a47be59db651a4f102f84ff))
- Add field domain name as optional field ([#880](https://github.com/juspay/hyperswitch-control-center/pull/880)) ([`ee6d0bd`](https://github.com/juspay/hyperswitch-control-center/commit/ee6d0bdc8700f4c4af9bd2e035c75b957fdfe5dd))

**Full Changelog:** [`2024.06.27.0...2024.06.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.27.0...2024.06.28.0)

- - -

## 2024.06.27.0

### Features

- SSO integration in dashboard ([#870](https://github.com/juspay/hyperswitch-control-center/pull/870)) ([`3c348e1`](https://github.com/juspay/hyperswitch-control-center/commit/3c348e147a6e7b428c4be4ff91adb491c6469d00))

**Full Changelog:** [`2024.06.26.0...2024.06.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.26.0...2024.06.27.0)

- - -

## 2024.06.26.0

### Miscellaneous Tasks

- Filters ui in newline ([#869](https://github.com/juspay/hyperswitch-control-center/pull/869)) ([`014b800`](https://github.com/juspay/hyperswitch-control-center/commit/014b80052193465928deaec9fd3f23c2d1ae4b5a))
- Add zsl in prod ([#873](https://github.com/juspay/hyperswitch-control-center/pull/873)) ([`41fb23e`](https://github.com/juspay/hyperswitch-control-center/commit/41fb23e83ed2b64770da907576c4289bedf4267b))

**Full Changelog:** [`2024.06.25.0...2024.06.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.25.0...2024.06.26.0)

- - -

## 2024.06.25.0

### Bug Fixes

- Disputes accept dispute button condition change ([#868](https://github.com/juspay/hyperswitch-control-center/pull/868)) ([`48cd4b8`](https://github.com/juspay/hyperswitch-control-center/commit/48cd4b8ebb664ab060862734866c4a96d5cfb3bd))

### Refactors

- Local storage key name change ([#858](https://github.com/juspay/hyperswitch-control-center/pull/858)) ([`3309371`](https://github.com/juspay/hyperswitch-control-center/commit/3309371dcc2eeb2f9ab9d342b8341a91b0adaded))

### Miscellaneous Tasks

- Auth list API integration ([#849](https://github.com/juspay/hyperswitch-control-center/pull/849)) ([`b31a58c`](https://github.com/juspay/hyperswitch-control-center/commit/b31a58c60ef22ac412c246d0db71a5ddd2d5f581))
- Store authid in sessionstorage ([#862](https://github.com/juspay/hyperswitch-control-center/pull/862)) ([`7dfbf1f`](https://github.com/juspay/hyperswitch-control-center/commit/7dfbf1fd9901317e1a80bb9b3fab59f51db43dd0))
- Move prod agreement url env ([#866](https://github.com/juspay/hyperswitch-control-center/pull/866)) ([`ce3d682`](https://github.com/juspay/hyperswitch-control-center/commit/ce3d682f1b3bb33146c26b2a5cc2a8f38fc34448))
- Update sessiontoken ([`a7c8390`](https://github.com/juspay/hyperswitch-control-center/commit/a7c8390b1fd17259bd06b0e475d2080322ca0706))

**Full Changelog:** [`2024.06.24.0...2024.06.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.24.0...2024.06.25.0)

- - -

## 2024.06.24.0

### Miscellaneous Tasks

- Showing all payment method types in filters ([#841](https://github.com/juspay/hyperswitch-control-center/pull/841)) ([`d5a93aa`](https://github.com/juspay/hyperswitch-control-center/commit/d5a93aacd0c52f0237f9a0a2a3aafe9d1c5992ba))

**Full Changelog:** [`2024.06.21.0...2024.06.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.21.0...2024.06.24.0)

- - -

## 2024.06.21.0

### Bug Fixes

- Verify email flow ([#855](https://github.com/juspay/hyperswitch-control-center/pull/855)) ([`1fbfbd3`](https://github.com/juspay/hyperswitch-control-center/commit/1fbfbd3ed4a9ca550d231f22d5e3ef3273e3066b))

**Full Changelog:** [`2024.06.20.1...2024.06.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.20.1...2024.06.21.0)

- - -

## 2024.06.20.1

### Miscellaneous Tasks

- Map the display name to label ([#853](https://github.com/juspay/hyperswitch-control-center/pull/853)) ([`72e6927`](https://github.com/juspay/hyperswitch-control-center/commit/72e69271f7e3847bbc37466d755f636333718266))

**Full Changelog:** [`2024.06.20.0...2024.06.20.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.20.0...2024.06.20.1)

- - -

## 2024.06.20.0

### Features

- Add boolean field to collect shipping details ([#783](https://github.com/juspay/hyperswitch-control-center/pull/783)) ([`5e7c3c7`](https://github.com/juspay/hyperswitch-control-center/commit/5e7c3c792700c41bbb0b1cec207c300aae6b85d6))

### Miscellaneous Tasks

- Card network changes and customer details card ([#837](https://github.com/juspay/hyperswitch-control-center/pull/837)) ([`4df01b5`](https://github.com/juspay/hyperswitch-control-center/commit/4df01b524fe67ee5a6e5244e5669cc8dec644bfe))
- Sso decision screen addition ([#836](https://github.com/juspay/hyperswitch-control-center/pull/836)) ([`cdd769c`](https://github.com/juspay/hyperswitch-control-center/commit/cdd769c46fb1b856930a2b184a5a1df400b2f5d2))
- Allow user to enter apple pay label ([#852](https://github.com/juspay/hyperswitch-control-center/pull/852)) ([`282c746`](https://github.com/juspay/hyperswitch-control-center/commit/282c7466b0e54d233722c6ab7676ce9edebe99d6))

**Full Changelog:** [`2024.06.19.2...2024.06.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.19.2...2024.06.20.0)

- - -

## 2024.06.19.2

### Miscellaneous Tasks

- Quick fix merchant ([#846](https://github.com/juspay/hyperswitch-control-center/pull/846)) ([`94e6dfe`](https://github.com/juspay/hyperswitch-control-center/commit/94e6dfe0c7d664d9868d2f3abd0209aa140ff64d))

**Full Changelog:** [`2024.06.19.1...2024.06.19.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.19.1...2024.06.19.2)

- - -

## 2024.06.19.1

### Miscellaneous Tasks

- Switch merchant quick fix ([#845](https://github.com/juspay/hyperswitch-control-center/pull/845)) ([`22093f6`](https://github.com/juspay/hyperswitch-control-center/commit/22093f6fe6f5281d519559df8e4a4473b8d0f958))

**Full Changelog:** [`2024.06.19.0...2024.06.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.19.0...2024.06.19.1)

- - -

## 2024.06.19.0

### Bug Fixes

- Payments table description column fix ([#834](https://github.com/juspay/hyperswitch-control-center/pull/834)) ([`5e8290e`](https://github.com/juspay/hyperswitch-control-center/commit/5e8290e9b8c8956f5d6e4c5a78adc772ae999fae))
- Switch merchant dialog box ui issue ([#839](https://github.com/juspay/hyperswitch-control-center/pull/839)) ([`51baf8e`](https://github.com/juspay/hyperswitch-control-center/commit/51baf8ee05421736986337776e995c2a7803f4e0))

### Refactors

- Auth module folder restructuring ([#831](https://github.com/juspay/hyperswitch-control-center/pull/831)) ([`f37237d`](https://github.com/juspay/hyperswitch-control-center/commit/f37237dcb756cc5f5b7be86e2154a555e6b08996))

**Full Changelog:** [`2024.06.18.0...2024.06.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.18.0...2024.06.19.0)

- - -

## 2024.06.18.0

### Miscellaneous Tasks

- Dynamic tabs ([#769](https://github.com/juspay/hyperswitch-control-center/pull/769)) ([`d6e16ad`](https://github.com/juspay/hyperswitch-control-center/commit/d6e16adb4dc87656eee1484f9f05b834f6131ad1))
- Showing error message on payment failure ([#806](https://github.com/juspay/hyperswitch-control-center/pull/806)) ([`99db9c1`](https://github.com/juspay/hyperswitch-control-center/commit/99db9c182617047d90534754a5b1e8e353ca3744))

**Full Changelog:** [`2024.06.16.0...2024.06.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.16.0...2024.06.18.0)

- - -

## 2024.06.16.0

### Miscellaneous Tasks

- Sso new enum addition ([#825](https://github.com/juspay/hyperswitch-control-center/pull/825)) ([`6390602`](https://github.com/juspay/hyperswitch-control-center/commit/6390602c9da68c2b830e882f7e36ef9f5a57fc8d))

**Full Changelog:** [`2024.06.13.0...2024.06.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.13.0...2024.06.16.0)

- - -

## 2024.06.13.0

### Bug Fixes

- Recovery code button state fix ([#813](https://github.com/juspay/hyperswitch-control-center/pull/813)) ([`9bf73d6`](https://github.com/juspay/hyperswitch-control-center/commit/9bf73d68a68b36b5169f8a843bbe26efe37ee426))

### Refactors

- Totp flow file rename ([#822](https://github.com/juspay/hyperswitch-control-center/pull/822)) ([`a762c91`](https://github.com/juspay/hyperswitch-control-center/commit/a762c918698f7d26d68158d3744cc90444c64e65))

### Miscellaneous Tasks

- Pmt type changes ([#819](https://github.com/juspay/hyperswitch-control-center/pull/819)) ([`b2f520d`](https://github.com/juspay/hyperswitch-control-center/commit/b2f520d620bda3de490fea7e7f60fee54a91546b))

**Full Changelog:** [`2024.06.12.0...2024.06.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.12.0...2024.06.13.0)

- - -

## 2024.06.12.0

### Miscellaneous Tasks

- Add multiline inputbox for accepting private key ([#818](https://github.com/juspay/hyperswitch-control-center/pull/818)) ([`a567dd5`](https://github.com/juspay/hyperswitch-control-center/commit/a567dd53d66f6abe429452dab8f92bbd1343100e))

**Full Changelog:** [`2024.06.11.1...2024.06.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.11.1...2024.06.12.0)

- - -

## 2024.06.11.1

### Miscellaneous Tasks

- Add three more fields in apple pay ios certificate flow ([#811](https://github.com/juspay/hyperswitch-control-center/pull/811)) ([`724200b`](https://github.com/juspay/hyperswitch-control-center/commit/724200b46c60c2b5a92eb7eb6f3ee8413dc50277))

**Full Changelog:** [`2024.06.11.0...2024.06.11.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.11.0...2024.06.11.1)

- - -

## 2024.06.11.0

### Refactors

- Auth header as a separate component ([#810](https://github.com/juspay/hyperswitch-control-center/pull/810)) ([`fe123c0`](https://github.com/juspay/hyperswitch-control-center/commit/fe123c0816d0c26af86da81b796fa779093f10c9))

**Full Changelog:** [`2024.06.10.1...2024.06.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.10.1...2024.06.11.0)

- - -

## 2024.06.10.1

### Miscellaneous Tasks

- Chore: Metadata ui change in payment ops table ([#807](https://github.com/juspay/hyperswitch-control-center/pull/807)) ([`9ba0a27`](https://github.com/juspay/hyperswitch-control-center/commit/9ba0a278770dff437fe8430eaa2cf3550a838ff4))

**Full Changelog:** [`2024.06.10.0...2024.06.10.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.10.0...2024.06.10.1)

- - -

## 2024.06.10.0

### Miscellaneous Tasks

- Add processed amount ([#809](https://github.com/juspay/hyperswitch-control-center/pull/809)) ([`d75d4b1`](https://github.com/juspay/hyperswitch-control-center/commit/d75d4b17b65e398b24fb87f6e4b37095eb427b55))

**Full Changelog:** [`2024.06.09.0...2024.06.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.09.0...2024.06.10.0)

- - -

## 2024.06.09.0

### Miscellaneous Tasks

- Payment ops changes ([#795](https://github.com/juspay/hyperswitch-control-center/pull/795)) ([`f3f3a1c`](https://github.com/juspay/hyperswitch-control-center/commit/f3f3a1c0198c29dab01a7839c741799ff762b9c4))

**Full Changelog:** [`2024.06.07.1...2024.06.09.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.07.1...2024.06.09.0)

- - -

## 2024.06.07.1

### Bug Fixes

- Removed required fields for metadata cybersource ([#803](https://github.com/juspay/hyperswitch-control-center/pull/803)) ([`7a145c9`](https://github.com/juspay/hyperswitch-control-center/commit/7a145c9a3808543e976a499c019b64ca27971b48))

### Refactors

- Auth refactor ([#791](https://github.com/juspay/hyperswitch-control-center/pull/791)) ([`931d8f0`](https://github.com/juspay/hyperswitch-control-center/commit/931d8f0018db963c7c93902d37151f339cf62653))

### Miscellaneous Tasks

- Date range change ([#796](https://github.com/juspay/hyperswitch-control-center/pull/796)) ([`b738629`](https://github.com/juspay/hyperswitch-control-center/commit/b7386297d2bbebcc1417aa4ede1591247bc54d43))

**Full Changelog:** [`2024.06.07.0...2024.06.07.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.07.0...2024.06.07.1)

- - -

## 2024.06.07.0

### Features

- Mifinity connector addition ([#798](https://github.com/juspay/hyperswitch-control-center/pull/798)) ([`230f2a1`](https://github.com/juspay/hyperswitch-control-center/commit/230f2a16d55d2b378d6d45358e5f82313d532eeb))

**Full Changelog:** [`2024.06.06.2...2024.06.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.06.2...2024.06.07.0)

- - -

## 2024.06.06.2

### Bug Fixes

- Apple pay map type ([#801](https://github.com/juspay/hyperswitch-control-center/pull/801)) ([`7da9f5b`](https://github.com/juspay/hyperswitch-control-center/commit/7da9f5b0fd8ac248f32ba105d9d729c1db004ac8))

**Full Changelog:** [`2024.06.06.1...2024.06.06.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.06.1...2024.06.06.2)

- - -

## 2024.06.06.1

### Bug Fixes

- Apple pay metadata ([#800](https://github.com/juspay/hyperswitch-control-center/pull/800)) ([`f093c61`](https://github.com/juspay/hyperswitch-control-center/commit/f093c6196e5d45519a5856d857b1eba24b142242))

**Full Changelog:** [`2024.06.06.0...2024.06.06.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.06.0...2024.06.06.1)

- - -

## 2024.06.06.0

### Features

- Adyenplatform integ ([#787](https://github.com/juspay/hyperswitch-control-center/pull/787)) ([`336be2e`](https://github.com/juspay/hyperswitch-control-center/commit/336be2e824835a7341610e2c29b51b1b672d85cd))

**Full Changelog:** [`2024.06.05.2...2024.06.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.05.2...2024.06.06.0)

- - -

## 2024.06.05.2

### Miscellaneous Tasks

- Chore: enable klarna for live ([#719](https://github.com/juspay/hyperswitch-control-center/pull/719)) ([`b3b2e08`](https://github.com/juspay/hyperswitch-control-center/commit/b3b2e0875a904bcc8d5ace892a5b7bdf571af03f))

**Full Changelog:** [`2024.06.05.1...2024.06.05.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.05.1...2024.06.05.2)

- - -

## 2024.06.05.1

### Bug Fixes

- Totp bug fixes with accept invite in home ([#788](https://github.com/juspay/hyperswitch-control-center/pull/788)) ([`8add1ee`](https://github.com/juspay/hyperswitch-control-center/commit/8add1eec77c47712b3823317b2a01dd1ddf3f835))

### Miscellaneous Tasks

- Fix refund filters ([#790](https://github.com/juspay/hyperswitch-control-center/pull/790)) ([`1ad6650`](https://github.com/juspay/hyperswitch-control-center/commit/1ad6650b54edb09844dc84596476988ca064c3ac))

**Full Changelog:** [`2024.06.05.0...2024.06.05.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.05.0...2024.06.05.1)

- - -

## 2024.06.05.0

### Miscellaneous Tasks

- Allow metchant to select different paypal paymentmenthod typ ([#785](https://github.com/juspay/hyperswitch-control-center/pull/785)) ([`4aaad80`](https://github.com/juspay/hyperswitch-control-center/commit/4aaad80234f46bba46a5b6c02b9964675d4d3da8))

**Full Changelog:** [`2024.06.04.2...2024.06.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.04.2...2024.06.05.0)

- - -

## 2024.06.04.2

### Features

- Payouts ([#774](https://github.com/juspay/hyperswitch-control-center/pull/774)) ([`f47a0b6`](https://github.com/juspay/hyperswitch-control-center/commit/f47a0b68126be2a7f60606ad4658af3e7d7fbc1f))

**Full Changelog:** [`2024.06.04.1...2024.06.04.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.04.1...2024.06.04.2)

- - -

## 2024.06.04.1

### Features

- Regenerate recovery codes ([#776](https://github.com/juspay/hyperswitch-control-center/pull/776)) ([`d34f858`](https://github.com/juspay/hyperswitch-control-center/commit/d34f858a4f69bdcd1bee199e732aa87a2540d8f0))

### Bug Fixes

- Refunds filters url fix ([#779](https://github.com/juspay/hyperswitch-control-center/pull/779)) ([`7e06ef7`](https://github.com/juspay/hyperswitch-control-center/commit/7e06ef789963d03762ae77a9cf53f89cfd2c1f12))
- Pageloader wrapper error case logout button addition ([#780](https://github.com/juspay/hyperswitch-control-center/pull/780)) ([`4347f8d`](https://github.com/juspay/hyperswitch-control-center/commit/4347f8d5e7f9bd8a19860a576a5998f03b894845))

**Full Changelog:** [`2024.06.04.0...2024.06.04.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.04.0...2024.06.04.1)

- - -

## 2024.06.04.0

### Features

- Reset-totp inside control-center ([#759](https://github.com/juspay/hyperswitch-control-center/pull/759)) ([`b3280ef`](https://github.com/juspay/hyperswitch-control-center/commit/b3280ef69b59fa48866306cf9c8587052c929f64))

### Bug Fixes

- Disable sdk show preview ([#768](https://github.com/juspay/hyperswitch-control-center/pull/768)) ([`639ca09`](https://github.com/juspay/hyperswitch-control-center/commit/639ca09a9e59e630414cb4bcd716314df467e4d5))
- Github workflows ([#773](https://github.com/juspay/hyperswitch-control-center/pull/773)) ([`e24fa1e`](https://github.com/juspay/hyperswitch-control-center/commit/e24fa1eec06aefc756687f0effccccee3a8de17c))

### Miscellaneous Tasks

- Update paypal metadata ([#770](https://github.com/juspay/hyperswitch-control-center/pull/770)) ([`98b0b00`](https://github.com/juspay/hyperswitch-control-center/commit/98b0b003679e4309bf0291fac345e0e5fbcaf14a))

**Full Changelog:** [`2024.06.02.0...2024.06.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.06.02.0...2024.06.04.0)

- - -

## 2024.06.02.0

### Bug Fixes

- Pay now button validations ([#754](https://github.com/juspay/hyperswitch-control-center/pull/754)) ([`bf32df5`](https://github.com/juspay/hyperswitch-control-center/commit/bf32df5494eb84bdfea63728cf4b3f7879f099d9))

**Full Changelog:** [`2024.05.30.1...2024.06.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.30.1...2024.06.02.0)

- - -

## 2024.05.30.1

### Miscellaneous Tasks

- Update placeholder klarna ([#765](https://github.com/juspay/hyperswitch-control-center/pull/765)) ([`6afc98d`](https://github.com/juspay/hyperswitch-control-center/commit/6afc98d206ef90c125758ea9d789dba3916a10ba))

**Full Changelog:** [`2024.05.30.0...2024.05.30.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.30.0...2024.05.30.1)

- - -

## 2024.05.30.0

### Miscellaneous Tasks

- Update klaran metadata ([#762](https://github.com/juspay/hyperswitch-control-center/pull/762)) ([`41622fc`](https://github.com/juspay/hyperswitch-control-center/commit/41622fc20526d1cd81e0f9726a4ccfc2d0c2237d))
- Remove currency metrics ([#761](https://github.com/juspay/hyperswitch-control-center/pull/761)) ([`6f251e1`](https://github.com/juspay/hyperswitch-control-center/commit/6f251e1b28f96f9912613e7dbea7f811c616f816))

**Full Changelog:** [`2024.05.29.4...2024.05.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.29.4...2024.05.30.0)

- - -

## 2024.05.29.4

### Miscellaneous Tasks

- UI fix audit ([#753](https://github.com/juspay/hyperswitch-control-center/pull/753)) ([`778839a`](https://github.com/juspay/hyperswitch-control-center/commit/778839a6de1a53fccd71fcc94b5c38288d7d91cf))

**Full Changelog:** [`2024.05.29.3...2024.05.29.4`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.29.3...2024.05.29.4)

- - -

## 2024.05.29.3

### Bug Fixes

- Configure pmts redirect url fix ([#752](https://github.com/juspay/hyperswitch-control-center/pull/752)) ([`6f6d735`](https://github.com/juspay/hyperswitch-control-center/commit/6f6d735c4745f7d3fea23bb5d1afb92f201004e3))

**Full Changelog:** [`2024.05.29.2...2024.05.29.3`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.29.2...2024.05.29.3)

- - -

## 2024.05.29.2

### Miscellaneous Tasks

- Eventlog UI shown in expanded state ([#750](https://github.com/juspay/hyperswitch-control-center/pull/750)) ([`f243ce0`](https://github.com/juspay/hyperswitch-control-center/commit/f243ce05a27047783ff7cb494e948e113f387b4d))

**Full Changelog:** [`2024.05.29.1...2024.05.29.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.29.1...2024.05.29.2)

- - -

## 2024.05.29.1

### Bug Fixes

- Amount to capture ([#738](https://github.com/juspay/hyperswitch-control-center/pull/738)) ([`e3599d3`](https://github.com/juspay/hyperswitch-control-center/commit/e3599d314e3493e23d47ad855a34802b26f14bb0))
- Filter end time ([#744](https://github.com/juspay/hyperswitch-control-center/pull/744)) ([`6e8a665`](https://github.com/juspay/hyperswitch-control-center/commit/6e8a665cab3edd4264ae6b2bc5fb9a68d76af588))
- Totp phase2 bugfixes ([#747](https://github.com/juspay/hyperswitch-control-center/pull/747)) ([`627547e`](https://github.com/juspay/hyperswitch-control-center/commit/627547ef9c283fcc163b4dfa2a940891f6ca0417))

### Miscellaneous Tasks

- Move info to Tooltip ([#736](https://github.com/juspay/hyperswitch-control-center/pull/736)) ([`2accc9e`](https://github.com/juspay/hyperswitch-control-center/commit/2accc9ec0b4121bba7fb81ef1d2f5f5949aad65b))
- Events and logs ui changes ([#735](https://github.com/juspay/hyperswitch-control-center/pull/735)) ([`5879c37`](https://github.com/juspay/hyperswitch-control-center/commit/5879c37af886e71fd072af70581fd03fac853a80))
- Update paypal payment experience ([#748](https://github.com/juspay/hyperswitch-control-center/pull/748)) ([`a27353f`](https://github.com/juspay/hyperswitch-control-center/commit/a27353f9c013f5f403c3b0ba65e6b3068c4109f6))

**Full Changelog:** [`2024.05.29.0...2024.05.29.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.29.0...2024.05.29.1)

- - -

## 2024.05.29.0

### Bug Fixes

- Production access form fields addition ([#731](https://github.com/juspay/hyperswitch-control-center/pull/731)) ([`7ec5828`](https://github.com/juspay/hyperswitch-control-center/commit/7ec5828b4a501ed16935d9a6ab5d65add171954b))
- Dummy connector warnings ([#734](https://github.com/juspay/hyperswitch-control-center/pull/734)) ([`69bf502`](https://github.com/juspay/hyperswitch-control-center/commit/69bf5025742805135fc54e23319c23132f2cd564))

**Full Changelog:** [`2024.05.28.0...2024.05.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.28.0...2024.05.29.0)

- - -

## 2024.05.28.0

### Features

- Api enhancement for totp flow and recovery code input ([#713](https://github.com/juspay/hyperswitch-control-center/pull/713)) ([`7268044`](https://github.com/juspay/hyperswitch-control-center/commit/726804470e37b886646342f2040133c62697c3ae))

### Bug Fixes

- Authentication analytics funnel ([#726](https://github.com/juspay/hyperswitch-control-center/pull/726)) ([`e0e0314`](https://github.com/juspay/hyperswitch-control-center/commit/e0e0314e0e174bbd76525d3a7cf23290409fc4a9))
- Intermittent black screen while switching merchant ([#725](https://github.com/juspay/hyperswitch-control-center/pull/725)) ([`3458b53`](https://github.com/juspay/hyperswitch-control-center/commit/3458b535778ebd56523b2fef12714ed5535146d1))

### Miscellaneous Tasks

- Profile page component addition for 2fa ([#722](https://github.com/juspay/hyperswitch-control-center/pull/722)) ([`81eee64`](https://github.com/juspay/hyperswitch-control-center/commit/81eee64b3f4e3d2329d584e694fd7746c79dabd3))
- Page title changes ([#729](https://github.com/juspay/hyperswitch-control-center/pull/729)) ([`e286d1f`](https://github.com/juspay/hyperswitch-control-center/commit/e286d1f058b7d0e7e190c8ce5c34e598e199a16d))

**Full Changelog:** [`2024.05.27.0...2024.05.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.27.0...2024.05.28.0)

- - -

## 2024.05.27.0

### Features

- Added client cols in payment analytics and payment attempt entity ([#710](https://github.com/juspay/hyperswitch-control-center/pull/710)) ([`2e471cc`](https://github.com/juspay/hyperswitch-control-center/commit/2e471ccfdc6898a60fcafb7dd634e53623baa647))

### Miscellaneous Tasks

- Recovery code component ([#715](https://github.com/juspay/hyperswitch-control-center/pull/715)) ([`a3093b0`](https://github.com/juspay/hyperswitch-control-center/commit/a3093b06eafbadef6b06322d1f1f21c7da0f7ad4))

**Full Changelog:** [`2024.05.26.0...2024.05.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.26.0...2024.05.27.0)

- - -

## 2024.05.26.0

### Bug Fixes

- User analytics fix ([#709](https://github.com/juspay/hyperswitch-control-center/pull/709)) ([`2e03162`](https://github.com/juspay/hyperswitch-control-center/commit/2e03162dd914d7e161b39e6d127040525804bf0b))

### Miscellaneous Tasks

- Download access code component ([#707](https://github.com/juspay/hyperswitch-control-center/pull/707)) ([`82f145c`](https://github.com/juspay/hyperswitch-control-center/commit/82f145cf0307a56afb546354f1d0146d51266792))

**Full Changelog:** [`2024.05.24.0...2024.05.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.24.0...2024.05.26.0)

- - -

## 2024.05.24.0

### Features

- Added authentication details block in payment details ([#703](https://github.com/juspay/hyperswitch-control-center/pull/703)) ([`89c7108`](https://github.com/juspay/hyperswitch-control-center/commit/89c7108c309a3273529f97c96f8f42604009751f))

### Bug Fixes

- Sdk country currency issue ([#704](https://github.com/juspay/hyperswitch-control-center/pull/704)) ([`f7a9250`](https://github.com/juspay/hyperswitch-control-center/commit/f7a925004b1033eff1a4f0887120159c8f8578a0))

### Miscellaneous Tasks

- Fix console warning ([#702](https://github.com/juspay/hyperswitch-control-center/pull/702)) ([`ae03248`](https://github.com/juspay/hyperswitch-control-center/commit/ae032488b0322fdca0ef6667d0c70c55de755bcf))

**Full Changelog:** [`2024.05.23.1...2024.05.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.23.1...2024.05.24.0)

- - -

## 2024.05.23.1

### Bug Fixes

- Global search in firefox ([#692](https://github.com/juspay/hyperswitch-control-center/pull/692)) ([`866c899`](https://github.com/juspay/hyperswitch-control-center/commit/866c8996f420f7655199cf94108ef974e7983607))
- Apple pay connector integration ([#701](https://github.com/juspay/hyperswitch-control-center/pull/701)) ([`3adc1e9`](https://github.com/juspay/hyperswitch-control-center/commit/3adc1e97643168c0c09da488d439c94656796976))
- Payment refunds api optimization ([#697](https://github.com/juspay/hyperswitch-control-center/pull/697)) ([`22268ef`](https://github.com/juspay/hyperswitch-control-center/commit/22268ef59b491283ea9d4e182aef9dc2af7cb1d1))

### Refactors

- Totp elements separation ([#696](https://github.com/juspay/hyperswitch-control-center/pull/696)) ([`41b9d0d`](https://github.com/juspay/hyperswitch-control-center/commit/41b9d0d79b4d4dd969ff727b0ffe1d9f8e5b2e6b))

### Miscellaneous Tasks

- Change label for add filters menu ([#690](https://github.com/juspay/hyperswitch-control-center/pull/690)) ([`928ccf6`](https://github.com/juspay/hyperswitch-control-center/commit/928ccf6e1d577aad7d41b1d7b1debaa2d2c741d2))
- Minor ui fixes in filters ([#699](https://github.com/juspay/hyperswitch-control-center/pull/699)) ([`f4ba4fc`](https://github.com/juspay/hyperswitch-control-center/commit/f4ba4fc29ce104e9f8bbe4e476176bfd1c473693))

**Full Changelog:** [`2024.05.23.0...2024.05.23.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.23.0...2024.05.23.1)

- - -

## 2024.05.23.0

### Miscellaneous Tasks

- Filter & list api for payment & refunds ([#620](https://github.com/juspay/hyperswitch-control-center/pull/620)) ([`5900070`](https://github.com/juspay/hyperswitch-control-center/commit/5900070eff25b78ad9c3cdf2d46b14c77b627285))

**Full Changelog:** [`2024.05.22.1...2024.05.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.22.1...2024.05.23.0)

- - -

## 2024.05.22.1

### Features

- Authentication analytics ([#678](https://github.com/juspay/hyperswitch-control-center/pull/678)) ([`09f5eb7`](https://github.com/juspay/hyperswitch-control-center/commit/09f5eb75c8a25729cd2894c4d6dcde00285d28b8))

### Miscellaneous Tasks

- Payment filter modification ([#683](https://github.com/juspay/hyperswitch-control-center/pull/683)) ([`5ff2aef`](https://github.com/juspay/hyperswitch-control-center/commit/5ff2aef82a4582dd4b55b031702d80b7517a23f2))
- Refunds table and force sync button for refunds view ([#654](https://github.com/juspay/hyperswitch-control-center/pull/654)) ([`c008487`](https://github.com/juspay/hyperswitch-control-center/commit/c008487eee028f9b82c076de0e8c7779dc989fdd))

**Full Changelog:** [`2024.05.22.0...2024.05.22.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.22.0...2024.05.22.1)

- - -

## 2024.05.22.0

### Bug Fixes

- Added dummy connector image ([#680](https://github.com/juspay/hyperswitch-control-center/pull/680)) ([`50bbf60`](https://github.com/juspay/hyperswitch-control-center/commit/50bbf608de2dfaddc299195637bf0495ef3c137c))
- Checkbox click & text click select custom role ([#666](https://github.com/juspay/hyperswitch-control-center/pull/666)) ([`c9147ec`](https://github.com/juspay/hyperswitch-control-center/commit/c9147ec8bdf87cc1452198492bf7f20402c358b3))
- Sdk return url ([#684](https://github.com/juspay/hyperswitch-control-center/pull/684)) ([`1103381`](https://github.com/juspay/hyperswitch-control-center/commit/110338180f941c5bfcd503b38922d6cba3c96993))
- Input box issue fix ([#686](https://github.com/juspay/hyperswitch-control-center/pull/686)) ([`5e229c9`](https://github.com/juspay/hyperswitch-control-center/commit/5e229c9986c65a3130d468bcff054f74f8bffb2f))

### Miscellaneous Tasks

- Frm type changes ([#679](https://github.com/juspay/hyperswitch-control-center/pull/679)) ([`8a5bf2c`](https://github.com/juspay/hyperswitch-control-center/commit/8a5bf2cdf3841b7ed1c618719c9dca38e14b514d))

**Full Changelog:** [`2024.05.21.0...2024.05.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.21.0...2024.05.22.0)

- - -

## 2024.05.21.0

### Bug Fixes

- TOTP setup access-code changes ([#668](https://github.com/juspay/hyperswitch-control-center/pull/668)) ([`6784a85`](https://github.com/juspay/hyperswitch-control-center/commit/6784a859a1b55b6a7edf40b12857881d7c02fd46))
- Switch merchant business name modal fix ([#670](https://github.com/juspay/hyperswitch-control-center/pull/670)) ([`c5689d1`](https://github.com/juspay/hyperswitch-control-center/commit/c5689d17ea1bc2fa45b434c3b7b095bfab0c59cb))
- Icons are not working on firefox ([#673](https://github.com/juspay/hyperswitch-control-center/pull/673)) ([`0e46add`](https://github.com/juspay/hyperswitch-control-center/commit/0e46add797727e1244df4aacf6f4edabbc6979a4))
- Global search not working in Firefox ([#677](https://github.com/juspay/hyperswitch-control-center/pull/677)) ([`40a0380`](https://github.com/juspay/hyperswitch-control-center/commit/40a0380f16b604e71ac8f937a21c69a23dc5348d))
- Favicon missing in firebox ([#675](https://github.com/juspay/hyperswitch-control-center/pull/675)) ([`3f628cb`](https://github.com/juspay/hyperswitch-control-center/commit/3f628cbfff366028d1387e2a01c8d030e7b12cab))

**Full Changelog:** [`2024.05.20.0...2024.05.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.20.0...2024.05.21.0)

- - -

## 2024.05.20.0

### Bug Fixes

- Redirect to be send inside confirm params ([#664](https://github.com/juspay/hyperswitch-control-center/pull/664)) ([`db770dc`](https://github.com/juspay/hyperswitch-control-center/commit/db770dcd63dbb4a141758d9fd9117208d99b10f5))

**Full Changelog:** [`2024.05.19.0...2024.05.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.19.0...2024.05.20.0)

- - -

## 2024.05.19.0

### Miscellaneous Tasks

- Refactor payment hooks ([#661](https://github.com/juspay/hyperswitch-control-center/pull/661)) ([`9688b41`](https://github.com/juspay/hyperswitch-control-center/commit/9688b41a3543e5846e85f5ff068a3046a65a60b7))
- Payment method table filters ([#659](https://github.com/juspay/hyperswitch-control-center/pull/659)) ([`e1e25da`](https://github.com/juspay/hyperswitch-control-center/commit/e1e25da9dc58173b5bb41965f34e4a3fc638a122))

**Full Changelog:** [`2024.05.17.0...2024.05.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.17.0...2024.05.19.0)

- - -

## 2024.05.17.0

### Bug Fixes

- Totp switch merchant bug fix ([#655](https://github.com/juspay/hyperswitch-control-center/pull/655)) ([`d1830c5`](https://github.com/juspay/hyperswitch-control-center/commit/d1830c5da34e11cec8eaca62ed61c3f5726eb921))

### Miscellaneous Tasks

- Chore: added riskifyd ([#643](https://github.com/juspay/hyperswitch-control-center/pull/643)) ([`5ee1616`](https://github.com/juspay/hyperswitch-control-center/commit/5ee16164dc9ec89136f766703e2c94d95373d68f))

**Full Changelog:** [`2024.05.16.0...2024.05.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.16.0...2024.05.17.0)

- - -

## 2024.05.16.0

### Miscellaneous Tasks

- Add workflow to check linked issue ([#650](https://github.com/juspay/hyperswitch-control-center/pull/650)) ([`840ef97`](https://github.com/juspay/hyperswitch-control-center/commit/840ef97e6edda6f8f972f5b965312f3a613f1775))
- Update cypress workflow ([#652](https://github.com/juspay/hyperswitch-control-center/pull/652)) ([`69a1031`](https://github.com/juspay/hyperswitch-control-center/commit/69a1031196d6487117da456934eca4c5c23e10f6))
- Update makefile ([`ad380c3`](https://github.com/juspay/hyperswitch-control-center/commit/ad380c3274fb028cde804d5e6176b2f2a0833442))

**Full Changelog:** [`2024.05.15.1...2024.05.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.15.1...2024.05.16.0)

- - -

## 2024.05.15.1

### Features

- Feat: integrate totp auth ([#640](https://github.com/juspay/hyperswitch-control-center/pull/640)) ([`2da7d26`](https://github.com/juspay/hyperswitch-control-center/commit/2da7d26f894853917921da17e3dc14f718b9effb))

### Miscellaneous Tasks

- Analytics modification ([#634](https://github.com/juspay/hyperswitch-control-center/pull/634)) ([`511fe09`](https://github.com/juspay/hyperswitch-control-center/commit/511fe09c07bcd04944812c10e27c8966c58f6dab))

**Full Changelog:** [`2024.05.15.0...2024.05.15.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.15.0...2024.05.15.1)

- - -

## 2024.05.15.0

### Miscellaneous Tasks

- Filter refactor ([#627](https://github.com/juspay/hyperswitch-control-center/pull/627)) ([`a9f138a`](https://github.com/juspay/hyperswitch-control-center/commit/a9f138af231f6480b209065bea12e3537e25b0d4))

**Full Changelog:** [`2024.05.14.0...2024.05.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.14.0...2024.05.15.0)

- - -

## 2024.05.14.0

### Miscellaneous Tasks

- Convert get url to hook ([#635](https://github.com/juspay/hyperswitch-control-center/pull/635)) ([`75bfdd8`](https://github.com/juspay/hyperswitch-control-center/commit/75bfdd87c5c76c637b63ec8c4cb5bb7d1b4bda05))

**Full Changelog:** [`2024.05.12.0...2024.05.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.12.0...2024.05.14.0)

- - -

## 2024.05.12.0

### Features

- Changes for new auth flow ([#630](https://github.com/juspay/hyperswitch-control-center/pull/630)) ([`aab2dd2`](https://github.com/juspay/hyperswitch-control-center/commit/aab2dd273cd7044a4efb634e7a296eba3831bda7))

**Full Changelog:** [`2024.05.10.0...2024.05.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.10.0...2024.05.12.0)

- - -

## 2024.05.10.0

### Features

- Bambora to prod ([#629](https://github.com/juspay/hyperswitch-control-center/pull/629)) ([`822d7aa`](https://github.com/juspay/hyperswitch-control-center/commit/822d7aabdcfccc83031360df722ec5dba74e246e))

### Miscellaneous Tasks

- Disable agreement and onboarding survey when branding is enabled ([`a851334`](https://github.com/juspay/hyperswitch-control-center/commit/a8513341ec9ff331c9c1841ef386d52293a4fd68))

**Full Changelog:** [`2024.05.08.0...2024.05.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.08.0...2024.05.10.0)

- - -

## 2024.05.08.0

### Miscellaneous Tasks

- Auth provider changes ([#625](https://github.com/juspay/hyperswitch-control-center/pull/625)) ([`4db2372`](https://github.com/juspay/hyperswitch-control-center/commit/4db23721e2573673b1a70363141d237171c2c26e))

**Full Changelog:** [`2024.05.07.0...2024.05.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.07.0...2024.05.08.0)

- - -

## 2024.05.07.0

### Miscellaneous Tasks

- Added new payout connectors ([#623](https://github.com/juspay/hyperswitch-control-center/pull/623)) ([`4c1a399`](https://github.com/juspay/hyperswitch-control-center/commit/4c1a399f506c77a3ada70cfa3a9bbc8732486107))
- React QR code library addition ([#617](https://github.com/juspay/hyperswitch-control-center/pull/617)) ([`c28c302`](https://github.com/juspay/hyperswitch-control-center/commit/c28c302241847aa75516dfa3d0deaae9a5ca94b2))

**Full Changelog:** [`2024.05.06.0...2024.05.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.06.0...2024.05.07.0)

- - -

## 2024.05.06.0

### Miscellaneous Tasks

- Update wasm ([#621](https://github.com/juspay/hyperswitch-control-center/pull/621)) ([`2dc1c0a`](https://github.com/juspay/hyperswitch-control-center/commit/2dc1c0ad70e419486b8d993756dde0af11b00666))

**Full Changelog:** [`2024.05.03.0...2024.05.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.05.03.0...2024.05.06.0)

- - -

## 2024.05.03.0

### Bug Fixes

- Filter fix ([#618](https://github.com/juspay/hyperswitch-control-center/pull/618)) ([`562195e`](https://github.com/juspay/hyperswitch-control-center/commit/562195ed649851486c7f698ddc68ac2045966f75))
- Updated calendly link ([#615](https://github.com/juspay/hyperswitch-control-center/pull/615)) ([`28592bd`](https://github.com/juspay/hyperswitch-control-center/commit/28592bde6e1facb72baeedad892958844b9331ed))
- Accept invite in home fix ([#619](https://github.com/juspay/hyperswitch-control-center/pull/619)) ([`d127cba`](https://github.com/juspay/hyperswitch-control-center/commit/d127cbaac21c0aa2afe645c9460eaee9dc516d1b))

**Full Changelog:** [`2024.04.29.0...2024.05.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.29.0...2024.05.03.0)

- - -

## 2024.04.29.0

### Bug Fixes

- Prod onboarding url issue ([#614](https://github.com/juspay/hyperswitch-control-center/pull/614)) ([`c915e58`](https://github.com/juspay/hyperswitch-control-center/commit/c915e581357366a32868f5efd3ab04a12cba0930))

### Miscellaneous Tasks

- Config feature flags on run time ([#588](https://github.com/juspay/hyperswitch-control-center/pull/588)) ([`946c06a`](https://github.com/juspay/hyperswitch-control-center/commit/946c06a128cc39466df2cef96fcd6cea7fffcc20))

**Full Changelog:** [`2024.04.28.0...2024.04.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.28.0...2024.04.29.0)

- - -

## 2024.04.28.0

### Features

- Profile name update ([#610](https://github.com/juspay/hyperswitch-control-center/pull/610)) ([`4b73368`](https://github.com/juspay/hyperswitch-control-center/commit/4b7336816f5fc0c562248bb75028c8bc7554734d))

### Bug Fixes

- Onboarding survey api call fix ([#609](https://github.com/juspay/hyperswitch-control-center/pull/609)) ([`405dd1a`](https://github.com/juspay/hyperswitch-control-center/commit/405dd1a90f1e156d63ccb554f52f3394c5952574))

**Full Changelog:** [`2024.04.25.0...2024.04.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.25.0...2024.04.28.0)

- - -

## 2024.04.25.0

### Features

- Onboarding survey fe changes ([#593](https://github.com/juspay/hyperswitch-control-center/pull/593)) ([`7f891c9`](https://github.com/juspay/hyperswitch-control-center/commit/7f891c947b857aaa051c51ef0446df1b6e6f35a9))

### Bug Fixes

- Fix: global search ux ([#601](https://github.com/juspay/hyperswitch-control-center/pull/601)) ([`4f5155c`](https://github.com/juspay/hyperswitch-control-center/commit/4f5155c7833a13ded76105f5534e4cb39303c0f4))

**Full Changelog:** [`2024.04.24.2...2024.04.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.24.2...2024.04.25.0)

- - -

## 2024.04.24.2

### Bug Fixes

- Empty box in connector fix ([#608](https://github.com/juspay/hyperswitch-control-center/pull/608)) ([`202e340`](https://github.com/juspay/hyperswitch-control-center/commit/202e34041abbcbfe8ccf0ab7596b9d72f15279c3))

**Full Changelog:** [`2024.04.24.1...2024.04.24.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.24.1...2024.04.24.2)

- - -

## 2024.04.24.1

### Features

- Added netcetera threeds authenticator ([#605](https://github.com/juspay/hyperswitch-control-center/pull/605)) ([`3527e00`](https://github.com/juspay/hyperswitch-control-center/commit/3527e00c96957c6ea437d14dc374836556abb2aa))

### Bug Fixes

- Netcetera icon added ([#607](https://github.com/juspay/hyperswitch-control-center/pull/607)) ([`b4501ca`](https://github.com/juspay/hyperswitch-control-center/commit/b4501cab70b6fa172317e15e04991be1cf8d89c6))

**Full Changelog:** [`2024.04.24.0...2024.04.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.24.0...2024.04.24.1)

- - -

## 2024.04.24.0

### Features

- Authorize.net in prod ([#606](https://github.com/juspay/hyperswitch-control-center/pull/606)) ([`6de72a6`](https://github.com/juspay/hyperswitch-control-center/commit/6de72a6a432baa818741cfd77202238da617b4c7))

**Full Changelog:** [`2024.04.23.2...2024.04.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.23.2...2024.04.24.0)

- - -

## 2024.04.23.2

### Bug Fixes

- Base url show payments fix ([#603](https://github.com/juspay/hyperswitch-control-center/pull/603)) ([`f774020`](https://github.com/juspay/hyperswitch-control-center/commit/f774020650198a6adb8848c3203ed2f5193d2225))

**Full Changelog:** [`2024.04.23.1...2024.04.23.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.23.1...2024.04.23.2)

- - -

## 2024.04.23.1

### Bug Fixes

- Agreement version change ([#600](https://github.com/juspay/hyperswitch-control-center/pull/600)) ([`f819f26`](https://github.com/juspay/hyperswitch-control-center/commit/f819f26f30e8084f4c5c0bbe21937987114ae322))

### Miscellaneous Tasks

- Update connector metadata for nmi and 3ds ([#602](https://github.com/juspay/hyperswitch-control-center/pull/602)) ([`b9f8499`](https://github.com/juspay/hyperswitch-control-center/commit/b9f8499c6c72f51e00c488bf9474757eb027635e))

**Full Changelog:** [`2024.04.23.0...2024.04.23.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.23.0...2024.04.23.1)

- - -

## 2024.04.23.0

### Features

- Base url change ([#595](https://github.com/juspay/hyperswitch-control-center/pull/595)) ([`7c3bf0c`](https://github.com/juspay/hyperswitch-control-center/commit/7c3bf0c7bb79d71a49c2e2031a32b7c190a4bf7c))

### Miscellaneous Tasks

- Profile page changes ([#566](https://github.com/juspay/hyperswitch-control-center/pull/566)) ([`6f2dbb4`](https://github.com/juspay/hyperswitch-control-center/commit/6f2dbb46e88a8bc7b7d5e4ceb304491a71b71159))

**Full Changelog:** [`2024.04.18.0...2024.04.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.18.0...2024.04.23.0)

- - -

## 2024.04.18.0

### Features

- Support merchant business country ([`d365865`](https://github.com/juspay/hyperswitch-control-center/commit/d3658651e911e632c604419df9951c1bd5d15f39))

### Bug Fixes

- Make applepay merchant business country required fields ([#592](https://github.com/juspay/hyperswitch-control-center/pull/592)) ([`b50cf5a`](https://github.com/juspay/hyperswitch-control-center/commit/b50cf5a1fd7402274f2a6b4b20952ad4d6280c9a))
- Added dummy connector image ([#591](https://github.com/juspay/hyperswitch-control-center/pull/591)) ([`63d30d6`](https://github.com/juspay/hyperswitch-control-center/commit/63d30d69c65d9e9f8944cc9bcc92720126bfc62f))

**Full Changelog:** [`2024.04.17.0...2024.04.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.17.0...2024.04.18.0)

- - -

## 2024.04.17.0

### Features

- Signout api call ([#583](https://github.com/juspay/hyperswitch-control-center/pull/583)) ([`f03f33f`](https://github.com/juspay/hyperswitch-control-center/commit/f03f33f6795ebad0db0cfb283e9b1dd6d56eb0c7))

### Bug Fixes

- Ui button css changes ([#584](https://github.com/juspay/hyperswitch-control-center/pull/584)) ([`627c8f4`](https://github.com/juspay/hyperswitch-control-center/commit/627c8f4a3a35ef6524e9ade0be6952b523c38647))
- Css changes ([#586](https://github.com/juspay/hyperswitch-control-center/pull/586)) ([`0522921`](https://github.com/juspay/hyperswitch-control-center/commit/05229216a28cb3c8f551a294852147873a24a081))

### Miscellaneous Tasks

- Support merchant business country apple pay ([#587](https://github.com/juspay/hyperswitch-control-center/pull/587)) ([`0c4c6ad`](https://github.com/juspay/hyperswitch-control-center/commit/0c4c6adffea7ca0ba80e4e4e66810c8ce647c932))

**Full Changelog:** [`2024.04.16.0...2024.04.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.16.0...2024.04.17.0)

- - -

## 2024.04.16.0

### Miscellaneous Tasks

- Dummy processor flow ([#527](https://github.com/juspay/hyperswitch-control-center/pull/527)) ([`321e080`](https://github.com/juspay/hyperswitch-control-center/commit/321e08013df672280c0f53d4b30479da46581d6b))

**Full Changelog:** [`2024.04.15.0...2024.04.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.15.0...2024.04.16.0)

- - -

## 2024.04.15.0

### Features

- Zsl processor addition ([#578](https://github.com/juspay/hyperswitch-control-center/pull/578)) ([`f2403b0`](https://github.com/juspay/hyperswitch-control-center/commit/f2403b01fca06a2318ba062b6479ee1c2314d2d6))

### Miscellaneous Tasks

- Tailwind mutlitenancy config ([#577](https://github.com/juspay/hyperswitch-control-center/pull/577)) ([`0935d74`](https://github.com/juspay/hyperswitch-control-center/commit/0935d7451ab4dfd33fe8dd6595a1c631c28e00b1))
- Audit log ui fixes ([#582](https://github.com/juspay/hyperswitch-control-center/pull/582)) ([`bedbcb2`](https://github.com/juspay/hyperswitch-control-center/commit/bedbcb216793409d7082b8b926c10d9c8f57c37b))

**Full Changelog:** [`2024.04.10.0...2024.04.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.10.0...2024.04.15.0)

- - -

## 2024.04.10.0

### Bug Fixes

- Webhook url and return url regex change ([#572](https://github.com/juspay/hyperswitch-control-center/pull/572)) ([`09e1ca3`](https://github.com/juspay/hyperswitch-control-center/commit/09e1ca30c3814c0b6ebba4dee27d4a5bb93e6038))

### Miscellaneous Tasks

- Checkbox input type added ([#567](https://github.com/juspay/hyperswitch-control-center/pull/567)) ([`d5a22c0`](https://github.com/juspay/hyperswitch-control-center/commit/d5a22c0446567b6b3086ae5478d37ac4e6fdfe1e))

**Full Changelog:** [`2024.04.08.0...2024.04.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.08.0...2024.04.10.0)

- - -

## 2024.04.08.0

### Bug Fixes

- Return url and webhook url regex change ([#569](https://github.com/juspay/hyperswitch-control-center/pull/569)) ([`57a2f11`](https://github.com/juspay/hyperswitch-control-center/commit/57a2f11a61bc1f46811b220c11e4a5a116a63ced))

**Full Changelog:** [`2024.04.04.0...2024.04.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.04.0...2024.04.08.0)

- - -

## 2024.04.04.0

### Bug Fixes

- Billwerk-icon change ([#563](https://github.com/juspay/hyperswitch-control-center/pull/563)) ([`e047482`](https://github.com/juspay/hyperswitch-control-center/commit/e047482f72d3b6e51ba5092d84d9b6aa35fe87e9))
- Configure pmts page issue fix ([#564](https://github.com/juspay/hyperswitch-control-center/pull/564)) ([`0e61f85`](https://github.com/juspay/hyperswitch-control-center/commit/0e61f8588628913b3820f8fcb37ff1f4da22e5ca))

**Full Changelog:** [`2024.04.03.1...2024.04.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.03.1...2024.04.04.0)

- - -

## 2024.04.03.1

### Bug Fixes

- Billwerk icon addition ([#562](https://github.com/juspay/hyperswitch-control-center/pull/562)) ([`930a7ec`](https://github.com/juspay/hyperswitch-control-center/commit/930a7ecc11c30dc8e830cfb89fde99d5b83a43e6))

**Full Changelog:** [`2024.04.03.0...2024.04.03.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.03.0...2024.04.03.1)

- - -

## 2024.04.03.0

### Features

- Feat: payout routing changes ([#551](https://github.com/juspay/hyperswitch-control-center/pull/551)) ([`66d98cb`](https://github.com/juspay/hyperswitch-control-center/commit/66d98cb0b5da0feed856b6c8737ba942b1194dc0))
- Feat: accept country and currency while configuring a connector ([#495](https://github.com/juspay/hyperswitch-control-center/pull/495)) ([`9c1b389`](https://github.com/juspay/hyperswitch-control-center/commit/9c1b389d6c2661147a146b9bee7ca79cdf38f7d9))

### Bug Fixes

- Billwerk connector addition ([#561](https://github.com/juspay/hyperswitch-control-center/pull/561)) ([`c577c6c`](https://github.com/juspay/hyperswitch-control-center/commit/c577c6ce5bcac2a6e1a8bdcc21a34ee8b6011f43))

**Full Changelog:** [`2024.04.02.0...2024.04.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.02.0...2024.04.03.0)

- - -

## 2024.04.02.0

### Bug Fixes

- Days to respond in show disputes issue ([#553](https://github.com/juspay/hyperswitch-control-center/pull/553)) ([`ac356c5`](https://github.com/juspay/hyperswitch-control-center/commit/ac356c502fa7e87bb40a93708fca6f064c61133d))

### Miscellaneous Tasks

- Payout wasm changes ([#552](https://github.com/juspay/hyperswitch-control-center/pull/552)) ([`a110ba0`](https://github.com/juspay/hyperswitch-control-center/commit/a110ba0d74286ace2f3819f5a02cc9dfd48db297))
- Added feature flag for disputes ([#557](https://github.com/juspay/hyperswitch-control-center/pull/557)) ([`1afc1e0`](https://github.com/juspay/hyperswitch-control-center/commit/1afc1e045ae11c1f5bb89b41d44d08ab830f7403))

**Full Changelog:** [`2024.04.01.0...2024.04.02.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.04.01.0...2024.04.02.0)

- - -

## 2024.04.01.0

### Bug Fixes

- Audit log scroll fix ([#542](https://github.com/juspay/hyperswitch-control-center/pull/542)) ([`6670bee`](https://github.com/juspay/hyperswitch-control-center/commit/6670beee0fb96ecf10b871452d5e420074293c26))
- Fix: removed unused file, sdk source mapper fix - audit trail, integr… ([#526](https://github.com/juspay/hyperswitch-control-center/pull/526)) ([`f9234a2`](https://github.com/juspay/hyperswitch-control-center/commit/f9234a2a590a0a2f415b50a2f366f366ef216825))

### Miscellaneous Tasks

- Js.Array2 core changes for sorted function ([#540](https://github.com/juspay/hyperswitch-control-center/pull/540)) ([`4f78c80`](https://github.com/juspay/hyperswitch-control-center/commit/4f78c8011945f3ce25175bdb8cb47635ce45e2d8))
- Remove unused feature flags ([#547](https://github.com/juspay/hyperswitch-control-center/pull/547)) ([`2035945`](https://github.com/juspay/hyperswitch-control-center/commit/2035945f3cb014c2bd3d5df925b0cfef127a1814))
- Global search feature flag ([#550](https://github.com/juspay/hyperswitch-control-center/pull/550)) ([`1911539`](https://github.com/juspay/hyperswitch-control-center/commit/1911539d5f3c9eedfeaced49fdfb32bd45631d9f))
- Sorting processor list ([#493](https://github.com/juspay/hyperswitch-control-center/pull/493)) ([`13ee22f`](https://github.com/juspay/hyperswitch-control-center/commit/13ee22ffd443fe52f0ead8337b8e768d3789fee4))

**Full Changelog:** [`2024.03.28.0...2024.04.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.28.0...2024.04.01.0)

- - -

## 2024.03.28.0

### Features

- Global search ([#523](https://github.com/juspay/hyperswitch-control-center/pull/523)) ([`0108cc5`](https://github.com/juspay/hyperswitch-control-center/commit/0108cc5bb4118b7f63cb420048428672a68801de))

### Miscellaneous Tasks

- Js.changes ([#544](https://github.com/juspay/hyperswitch-control-center/pull/544)) ([`76c6d87`](https://github.com/juspay/hyperswitch-control-center/commit/76c6d87779c5cc29b63972c9086fdcefe58bd9a9))
- Custom testId for buttons ([#545](https://github.com/juspay/hyperswitch-control-center/pull/545)) ([`a53c4f9`](https://github.com/juspay/hyperswitch-control-center/commit/a53c4f9e6637bbdd3d9a3a94db85e7b6e5e0e2a2))

**Full Changelog:** [`2024.03.27.2...2024.03.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.27.2...2024.03.28.0)

- - -

## 2024.03.27.2

### Miscellaneous Tasks

- Core changes ([#541](https://github.com/juspay/hyperswitch-control-center/pull/541)) ([`ac07f2e`](https://github.com/juspay/hyperswitch-control-center/commit/ac07f2e842cd42cc7ee693b06b4d50076b8525d1))

**Full Changelog:** [`2024.03.27.1...2024.03.27.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.27.1...2024.03.27.2)

- - -

## 2024.03.27.1

### Miscellaneous Tasks

- Feature flag removal of accept-invite ([#518](https://github.com/juspay/hyperswitch-control-center/pull/518)) ([`fe91351`](https://github.com/juspay/hyperswitch-control-center/commit/fe913518e5c60585b21b6b04ae18bb5773fe839e))

**Full Changelog:** [`2024.03.27.0...2024.03.27.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.27.0...2024.03.27.1)

- - -

## 2024.03.27.0

### Miscellaneous Tasks

- Enabled audit log for all connectors ([#538](https://github.com/juspay/hyperswitch-control-center/pull/538)) ([`52544b3`](https://github.com/juspay/hyperswitch-control-center/commit/52544b3694548e4e7ac7a9a0b0a0b9a851f7f00d))
- Core changes ([#539](https://github.com/juspay/hyperswitch-control-center/pull/539)) ([`a7a3060`](https://github.com/juspay/hyperswitch-control-center/commit/a7a306071290424428b24cf338ef166a6e611a28))

**Full Changelog:** [`2024.03.26.0...2024.03.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.26.0...2024.03.27.0)

- - -

## 2024.03.26.0

### Bug Fixes

- Added delete 3ds rule ([#534](https://github.com/juspay/hyperswitch-control-center/pull/534)) ([`6951b43`](https://github.com/juspay/hyperswitch-control-center/commit/6951b438c203a61f2a206e935e48e94baa43f838))
- Rule based routing on click of ruleno warning fix ([#531](https://github.com/juspay/hyperswitch-control-center/pull/531)) ([`d9bc3c8`](https://github.com/juspay/hyperswitch-control-center/commit/d9bc3c83dfb7169c2d98ad23383af287d00c56fb))

### Miscellaneous Tasks

- Invite-multiple feature flag removal ([#516](https://github.com/juspay/hyperswitch-control-center/pull/516)) ([`161c20f`](https://github.com/juspay/hyperswitch-control-center/commit/161c20faaf17f3239eaf40db6b6f6837cd4f90f5))
- Clean tailwind config ([#533](https://github.com/juspay/hyperswitch-control-center/pull/533)) ([`beaf529`](https://github.com/juspay/hyperswitch-control-center/commit/beaf52919124d129f4308bfa3b68b784a76269d8))

**Full Changelog:** [`2024.03.21.0...2024.03.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.21.0...2024.03.26.0)

- - -

## 2024.03.21.0

### Bug Fixes

- Upload evidence modal fix ([#525](https://github.com/juspay/hyperswitch-control-center/pull/525)) ([`59cd028`](https://github.com/juspay/hyperswitch-control-center/commit/59cd028fca25e7858ea40ede40cd88f9d2eba165))

### Miscellaneous Tasks

- Wasm cache issue ([#529](https://github.com/juspay/hyperswitch-control-center/pull/529)) ([`1444555`](https://github.com/juspay/hyperswitch-control-center/commit/14445551e65491282994714c808313fc63a4050d))
- Update checkout optional fields ([#530](https://github.com/juspay/hyperswitch-control-center/pull/530)) ([`5ff2544`](https://github.com/juspay/hyperswitch-control-center/commit/5ff25441027f9610e9c346b51dc1fd3e6dc6bd1c))

**Full Changelog:** [`2024.03.19.1...2024.03.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.19.1...2024.03.21.0)

- - -

## 2024.03.19.1

### Features

- Dispute analytics ([#470](https://github.com/juspay/hyperswitch-control-center/pull/470)) ([`090eb00`](https://github.com/juspay/hyperswitch-control-center/commit/090eb00d7186fd0d4449c3a23ba33e073ed5487e))

### Miscellaneous Tasks

- Added mixpanel events for connector flow ([#521](https://github.com/juspay/hyperswitch-control-center/pull/521)) ([`4ecac71`](https://github.com/juspay/hyperswitch-control-center/commit/4ecac71bc93703426619488323d529bddbcbd20f))

**Full Changelog:** [`2024.03.19.0...2024.03.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.19.0...2024.03.19.1)

- - -

## 2024.03.19.0

### Bug Fixes

- Disputes show counter button condition change ([#522](https://github.com/juspay/hyperswitch-control-center/pull/522)) ([`aec0a47`](https://github.com/juspay/hyperswitch-control-center/commit/aec0a476c2fd025c11c6d6266d2bdd87a908b2e4))

**Full Changelog:** [`2024.03.18.0...2024.03.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.18.0...2024.03.19.0)

- - -

## 2024.03.18.0

### Bug Fixes

- 3ds-url-fix ([#514](https://github.com/juspay/hyperswitch-control-center/pull/514)) ([`5cba46b`](https://github.com/juspay/hyperswitch-control-center/commit/5cba46b61251f30527a7c6cb79d6bac20a3618ce))
- Prod onboarding screen fix ([#520](https://github.com/juspay/hyperswitch-control-center/pull/520)) ([`11d355c`](https://github.com/juspay/hyperswitch-control-center/commit/11d355c668602250834a5fb9e7faba10d5dcc8d8))

**Full Changelog:** [`2024.03.17.0...2024.03.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.17.0...2024.03.18.0)

- - -

## 2024.03.17.0

### Bug Fixes

- Prod onboarding form and switch merchant dropdown changes ([#500](https://github.com/juspay/hyperswitch-control-center/pull/500)) ([`6afccf6`](https://github.com/juspay/hyperswitch-control-center/commit/6afccf66d35497a515bf393baa6fc62cb0a5fe17))

### Miscellaneous Tasks

- Filter enhancement ([#504](https://github.com/juspay/hyperswitch-control-center/pull/504)) ([`fb5b9b2`](https://github.com/juspay/hyperswitch-control-center/commit/fb5b9b228d49d18bd5d3d5d40cfb9b2535233822))
- Added feature flag for threeds authenticator ([#507](https://github.com/juspay/hyperswitch-control-center/pull/507)) ([`c2876ab`](https://github.com/juspay/hyperswitch-control-center/commit/c2876ab2c5189cc4b996f4f9a328ff81ce656875))
- Update readme ([#511](https://github.com/juspay/hyperswitch-control-center/pull/511)) ([`ceadf7a`](https://github.com/juspay/hyperswitch-control-center/commit/ceadf7a085f9af0a7914dad2ca258828c10f7f5b))

**Full Changelog:** [`2024.03.14.0...2024.03.17.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.14.0...2024.03.17.0)

- - -

## 2024.03.14.0

### Testing

- Test cases for sandbox quickstart ([#497](https://github.com/juspay/hyperswitch-control-center/pull/497)) ([`b19780c`](https://github.com/juspay/hyperswitch-control-center/commit/b19780c444bd640dd0d30d5b01e8b85add15b3ec))

**Full Changelog:** [`2024.03.13.0...2024.03.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.13.0...2024.03.14.0)

- - -

## 2024.03.13.0

### Features

- Added 3ds authenticator ([#444](https://github.com/juspay/hyperswitch-control-center/pull/444)) ([`c8cacc2`](https://github.com/juspay/hyperswitch-control-center/commit/c8cacc26901bd47d4aa5bfe5176bb7cdd6e8963c))

### Bug Fixes

- Wasm changes for 3ds ([#499](https://github.com/juspay/hyperswitch-control-center/pull/499)) ([`8021225`](https://github.com/juspay/hyperswitch-control-center/commit/80212254480a94a0ec600a9d85a204af2e4b3186))
- Threeds fields addition in payment settings ([#491](https://github.com/juspay/hyperswitch-control-center/pull/491)) ([`0a627e3`](https://github.com/juspay/hyperswitch-control-center/commit/0a627e3eb16b61b590c6446f8cf8d0a2b9c85a06))

### Miscellaneous Tasks

- Add sidebar mixpanel events ([#494](https://github.com/juspay/hyperswitch-control-center/pull/494)) ([`20f0967`](https://github.com/juspay/hyperswitch-control-center/commit/20f0967373044b2b353613e1b5f71441f89b0131))
- Back button test case ([#488](https://github.com/juspay/hyperswitch-control-center/pull/488)) ([`1ad98f6`](https://github.com/juspay/hyperswitch-control-center/commit/1ad98f6f0e83624dcd98060f0a3a5bce0ad4035c))

**Full Changelog:** [`2024.03.11.0...2024.03.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.11.0...2024.03.13.0)

- - -

## 2024.03.11.0

### Refactors

- Removed permissions ([#484](https://github.com/juspay/hyperswitch-control-center/pull/484)) ([`fa93405`](https://github.com/juspay/hyperswitch-control-center/commit/fa93405825890b944ea65a788faa94e8fe0f1a17))

**Full Changelog:** [`2024.03.10.0...2024.03.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.10.0...2024.03.11.0)

- - -

## 2024.03.10.0

### Miscellaneous Tasks

- Connector list type mapping ([#465](https://github.com/juspay/hyperswitch-control-center/pull/465)) ([`5887682`](https://github.com/juspay/hyperswitch-control-center/commit/5887682d661a43d53023f2c67ff4405bfe056efd))

**Full Changelog:** [`2024.03.07.0...2024.03.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.07.0...2024.03.10.0)

- - -

## 2024.03.07.0

### Bug Fixes

- Quick start connector selection bug and connector list bug fixes ([#482](https://github.com/juspay/hyperswitch-control-center/pull/482)) ([`2dfb70f`](https://github.com/juspay/hyperswitch-control-center/commit/2dfb70f82d86e240a7d00f57f42e710528e186c3))
- Cypress test ([#486](https://github.com/juspay/hyperswitch-control-center/pull/486)) ([`15c286f`](https://github.com/juspay/hyperswitch-control-center/commit/15c286f1913fdec55b75f5f115c4271856695403))
- Fix: Back button function ([#475](https://github.com/juspay/hyperswitch-control-center/pull/475)) ([`345c618`](https://github.com/juspay/hyperswitch-control-center/commit/345c618dda30d4ba9e74b0d13a2fb64c60366f26))

### Miscellaneous Tasks

- Sidebar UI ([#481](https://github.com/juspay/hyperswitch-control-center/pull/481)) ([`180a40a`](https://github.com/juspay/hyperswitch-control-center/commit/180a40a65321ecbdbc7a0392f80dd302718da12d))

**Full Changelog:** [`2024.03.06.0...2024.03.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.06.0...2024.03.07.0)

- - -

## 2024.03.07.0

### Bug Fixes

- Quick start connector selection bug and connector list bug fixes ([#482](https://github.com/juspay/hyperswitch-control-center/pull/482)) ([`2dfb70f`](https://github.com/juspay/hyperswitch-control-center/commit/2dfb70f82d86e240a7d00f57f42e710528e186c3))
- Cypress test ([#486](https://github.com/juspay/hyperswitch-control-center/pull/486)) ([`15c286f`](https://github.com/juspay/hyperswitch-control-center/commit/15c286f1913fdec55b75f5f115c4271856695403))

### Miscellaneous Tasks

- Sidebar UI ([#481](https://github.com/juspay/hyperswitch-control-center/pull/481)) ([`180a40a`](https://github.com/juspay/hyperswitch-control-center/commit/180a40a65321ecbdbc7a0392f80dd302718da12d))

**Full Changelog:** [`2024.03.06.0...2024.03.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.06.0...2024.03.07.0)

- - -

## 2024.03.06.0

### Features

- Added new connector ([#480](https://github.com/juspay/hyperswitch-control-center/pull/480)) ([`d5238fb`](https://github.com/juspay/hyperswitch-control-center/commit/d5238fbabc928e2241fd5ecf0c92b98ffa347512))

### Miscellaneous Tasks

- Remove feature banner ([#479](https://github.com/juspay/hyperswitch-control-center/pull/479)) ([`a6668b7`](https://github.com/juspay/hyperswitch-control-center/commit/a6668b70ccbaff3fcd798db20e6c5258fd5b4ffc))

**Full Changelog:** [`2024.03.05.2...2024.03.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.05.2...2024.03.06.0)

- - -

## 2024.03.05.2

### Bug Fixes

- Connector type frm ([#478](https://github.com/juspay/hyperswitch-control-center/pull/478)) ([`3bb3706`](https://github.com/juspay/hyperswitch-control-center/commit/3bb3706a2801397287dab8efef77e353809a9f5f))

**Full Changelog:** [`2024.03.05.1...2024.03.05.2`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.05.1...2024.03.05.2)

- - -

## 2024.03.05.1

### Miscellaneous Tasks

- Update wasm ([#477](https://github.com/juspay/hyperswitch-control-center/pull/477)) ([`fc1cddd`](https://github.com/juspay/hyperswitch-control-center/commit/fc1cddd5eac251e6b2a8a61bb92e251289ddf16f))

**Full Changelog:** [`2024.03.05.0...2024.03.05.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.05.0...2024.03.05.1)

- - -

## 2024.03.05.0

### Features

- Feat: Create custom role ([#473](https://github.com/juspay/hyperswitch-control-center/pull/473)) ([`d5739ad`](https://github.com/juspay/hyperswitch-control-center/commit/d5739ad8c9c17be479cadd72049c7f561218be5a))

### Style

- Sidebar ui enhancement ([#457](https://github.com/juspay/hyperswitch-control-center/pull/457)) ([`0cdf96d`](https://github.com/juspay/hyperswitch-control-center/commit/0cdf96da2b071ead12665890ee24b45376face80))

**Full Changelog:** [`2024.03.04.0...2024.03.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.04.0...2024.03.05.0)

- - -

## 2024.03.04.0

### Bug Fixes

- Add a mapper to change role names from `snake_case` to `Title Case` ([#468](https://github.com/juspay/hyperswitch-control-center/pull/468)) ([`6593fa2`](https://github.com/juspay/hyperswitch-control-center/commit/6593fa28fea74a28be44f438830ee5a2c3357026))
- User management api to groups ([#471](https://github.com/juspay/hyperswitch-control-center/pull/471)) ([`452e2c3`](https://github.com/juspay/hyperswitch-control-center/commit/452e2c3c099c74c0c8a32db7ff1f53570ca5ce52))

### Miscellaneous Tasks

- Audit refactor component ([#440](https://github.com/juspay/hyperswitch-control-center/pull/440)) ([`b5513bf`](https://github.com/juspay/hyperswitch-control-center/commit/b5513bf8a5b093c061adacfebe7110f5e809b613))

### Style

- Home page ui ([#463](https://github.com/juspay/hyperswitch-control-center/pull/463)) ([`b48bd5a`](https://github.com/juspay/hyperswitch-control-center/commit/b48bd5af5eb36198aec049ad3f2d1e89aab4c627))

**Full Changelog:** [`2024.03.03.0...2024.03.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.03.03.0...2024.03.04.0)

- - -

## 2024.03.03.0

### Bug Fixes

- Cursor changes for clickable label ([#464](https://github.com/juspay/hyperswitch-control-center/pull/464)) ([`4f62325`](https://github.com/juspay/hyperswitch-control-center/commit/4f62325e97c89819f1cb69ef7e444d208b9fa867))

**Full Changelog:** [`2024.02.29.1...2024.03.03.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.29.1...2024.03.03.0)

- - -

## 2024.02.29.1

### Bug Fixes

- Connector type ([`8037fa5`](https://github.com/juspay/hyperswitch-control-center/commit/8037fa57feeb78740a64809c28c5478f938ddbde))

**Full Changelog:** [`2024.02.29.0...2024.02.29.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.29.0...2024.02.29.1)

- - -

## 2024.02.29.0

### Bug Fixes

- Clear recoil ([#461](https://github.com/juspay/hyperswitch-control-center/pull/461)) ([`8865a76`](https://github.com/juspay/hyperswitch-control-center/commit/8865a76b8ef9fb83ce63ff02bc557e4b56e6f0d1))
- Connector type change ([#462](https://github.com/juspay/hyperswitch-control-center/pull/462)) ([`c31de0f`](https://github.com/juspay/hyperswitch-control-center/commit/c31de0f25840e0e930eb80b658f89c564246c424))

### Refactors

- Business recoil value from string to typed ([#458](https://github.com/juspay/hyperswitch-control-center/pull/458)) ([`16655fb`](https://github.com/juspay/hyperswitch-control-center/commit/16655fbcd59fdf27f3e6c07c2cc49c9b3c99b8f1))

**Full Changelog:** [`2024.02.28.0...2024.02.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.28.0...2024.02.29.0)

- - -

## 2024.02.28.0

### Features

- Email from billing 448 ([#454](https://github.com/juspay/hyperswitch-control-center/pull/454)) ([`322220c`](https://github.com/juspay/hyperswitch-control-center/commit/322220c772ad7dcda4d78e09a40703ef8ad63ad1))

### Refactors

- MerchantDetails recoil value from string to typed ([#455](https://github.com/juspay/hyperswitch-control-center/pull/455)) ([`2e461f8`](https://github.com/juspay/hyperswitch-control-center/commit/2e461f823bc84f9f599c2a45558ec999829b73e4))

**Full Changelog:** [`2024.02.27.0...2024.02.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.27.0...2024.02.28.0)

- - -

## 2024.02.27.0

### Features

- Enable label clickling ([#437](https://github.com/juspay/hyperswitch-control-center/pull/437)) ([`bc517e2`](https://github.com/juspay/hyperswitch-control-center/commit/bc517e2391918387cd8c832eba5300381a5c1385))

### Bug Fixes

- Live onboarding webhook url update fix ([#452](https://github.com/juspay/hyperswitch-control-center/pull/452)) ([`ebbe843`](https://github.com/juspay/hyperswitch-control-center/commit/ebbe843dc49a6ae8a2a1715c83a92242ecf43702))

### Miscellaneous Tasks

- Add cypress coverage ([#443](https://github.com/juspay/hyperswitch-control-center/pull/443)) ([`e3b5f1d`](https://github.com/juspay/hyperswitch-control-center/commit/e3b5f1d918c8733cf3bd351d386d6265ebf3b940))

**Full Changelog:** [`2024.02.26.0...2024.02.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.26.0...2024.02.27.0)

- - -

## 2024.02.26.0

### Features

- Update Role & Delete user added ([#403](https://github.com/juspay/hyperswitch-control-center/pull/403)) ([`e79e5ea`](https://github.com/juspay/hyperswitch-control-center/commit/e79e5eab681b6c29a248886eb5b57b22ad2caa0f))

### Bug Fixes

- Email_trim_fix ([#435](https://github.com/juspay/hyperswitch-control-center/pull/435)) ([`f14a257`](https://github.com/juspay/hyperswitch-control-center/commit/f14a257ffbe649e8e670d1db18a28804ad4fedc1))
- Clear recoil state on logout ([#445](https://github.com/juspay/hyperswitch-control-center/pull/445)) ([`35c48f9`](https://github.com/juspay/hyperswitch-control-center/commit/35c48f9d6651be814386de6e8854bf8c0c5e2c90))
- Dashboard default permission and signout fix ([#451](https://github.com/juspay/hyperswitch-control-center/pull/451)) ([`75b6c42`](https://github.com/juspay/hyperswitch-control-center/commit/75b6c427dedd040c2c9a17eaad417e7f23721258))

### Refactors

- Moved all the atoms to one folder ([#447](https://github.com/juspay/hyperswitch-control-center/pull/447)) ([`91b5290`](https://github.com/juspay/hyperswitch-control-center/commit/91b529023b30a6c0cf6c0186c49f0778cb97b612))

**Full Changelog:** [`2024.02.22.1...2024.02.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.22.1...2024.02.26.0)

- - -

## 2024.02.22.1

### Bug Fixes

- Homev2 accept invite ([#442](https://github.com/juspay/hyperswitch-control-center/pull/442)) ([`9209d2b`](https://github.com/juspay/hyperswitch-control-center/commit/9209d2b07a686af1986bce7492513b59143c87cd))
- Stepper UI fix on Home page ([#432](https://github.com/juspay/hyperswitch-control-center/pull/432)) ([`84adad4`](https://github.com/juspay/hyperswitch-control-center/commit/84adad4eaa32f50c01aaa23d033043c4e8ec9296))

**Full Changelog:** [`2024.02.22.0...2024.02.22.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.22.0...2024.02.22.1)

- - -

## 2024.02.22.0

### Features

- Accept from email intermediate screen ([#422](https://github.com/juspay/hyperswitch-control-center/pull/422)) ([`e13c6ca`](https://github.com/juspay/hyperswitch-control-center/commit/e13c6ca1d45aabb38b967c6fa51ebe57ff38cc30))

### Refactors

- Added connector types and renamed the connector util functions ([#433](https://github.com/juspay/hyperswitch-control-center/pull/433)) ([`8cdf723`](https://github.com/juspay/hyperswitch-control-center/commit/8cdf72333e0d3d52f5156835a96214a1846a3b86))

**Full Changelog:** [`2024.02.21.0...2024.02.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.21.0...2024.02.22.0)

- - -

## 2024.02.21.0

### Bug Fixes

- Accept invite accept button issue ([#429](https://github.com/juspay/hyperswitch-control-center/pull/429)) ([`b77897a`](https://github.com/juspay/hyperswitch-control-center/commit/b77897a6340e1f9b7a678f3fad4481de040ff9c5))
- Accept invite issue ([#430](https://github.com/juspay/hyperswitch-control-center/pull/430)) ([`ee9120f`](https://github.com/juspay/hyperswitch-control-center/commit/ee9120f3652d93cf3ed180af5ab40d696afa4dc5))

### Refactors

- Connector show processor card code refactor for usability ([#415](https://github.com/juspay/hyperswitch-control-center/pull/415)) ([`bbba268`](https://github.com/juspay/hyperswitch-control-center/commit/bbba268f77b05c28a26768af131ce05e68d58d7d))
- Refactor: frm - update info for FRM flows ([#421](https://github.com/juspay/hyperswitch-control-center/pull/421)) ([`0892d58`](https://github.com/juspay/hyperswitch-control-center/commit/0892d581ff6a5f9ddcb9443498149cfcba1c6ac9))

### Miscellaneous Tasks

- Add cypress test for prod onboarding ([#424](https://github.com/juspay/hyperswitch-control-center/pull/424)) ([`1a659a3`](https://github.com/juspay/hyperswitch-control-center/commit/1a659a35404db66372dad322282931558f5ead0d))
- Hyperswitch git ignore file changes ([#420](https://github.com/juspay/hyperswitch-control-center/pull/420)) ([`7eca110`](https://github.com/juspay/hyperswitch-control-center/commit/7eca1108c97d7d31e32b728795f07328c428cdfe))
- Minor text changes ([#428](https://github.com/juspay/hyperswitch-control-center/pull/428)) ([`a046c8c`](https://github.com/juspay/hyperswitch-control-center/commit/a046c8c393aa98ab89a4927947fca9e99e799ff4))

**Full Changelog:** [`2024.02.20.0...2024.02.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.20.0...2024.02.21.0)

- - -

## 2024.02.20.0

### Features

- Accept Invite Home Page Changes ([#419](https://github.com/juspay/hyperswitch-control-center/pull/419)) ([`38e4cb3`](https://github.com/juspay/hyperswitch-control-center/commit/38e4cb38d99a1cd6e6df16f9fd98785066a78632))

### Miscellaneous Tasks

- Sidebar Connector Hierarchy changes ([#426](https://github.com/juspay/hyperswitch-control-center/pull/426)) ([`c2d505c`](https://github.com/juspay/hyperswitch-control-center/commit/c2d505c2baa1ed6ca6b24ecee95a6f9d4d7a9a73))

**Full Changelog:** [`2024.02.19.0...2024.02.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.19.0...2024.02.20.0)

- - -

## 2024.02.19.0

### Features

- Switch merchant API Recoil Addition ([#417](https://github.com/juspay/hyperswitch-control-center/pull/417)) ([`4207423`](https://github.com/juspay/hyperswitch-control-center/commit/4207423f6f28bb6e89581c0a8481b77bac3c6fe3))

### Miscellaneous Tasks

- Code changes Int.ToString added ([#407](https://github.com/juspay/hyperswitch-control-center/pull/407)) ([`ad6c0e8`](https://github.com/juspay/hyperswitch-control-center/commit/ad6c0e82f1c6660447a8e62e14aa42377f8e1b2d))

**Full Changelog:** [`2024.02.18.0...2024.02.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.18.0...2024.02.19.0)

- - -

## 2024.02.18.0

### Bug Fixes

- Prod start command ([#414](https://github.com/juspay/hyperswitch-control-center/pull/414)) ([`4bdebb0`](https://github.com/juspay/hyperswitch-control-center/commit/4bdebb012b1bc9277723826cb6f27e51aa1a266c))

**Full Changelog:** [`2024.02.16.0...2024.02.18.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.16.0...2024.02.18.0)

- - -

## 2024.02.16.0

### Bug Fixes

- Fix accept invite re-render issue ([#411](https://github.com/juspay/hyperswitch-control-center/pull/411)) ([`d990e18`](https://github.com/juspay/hyperswitch-control-center/commit/d990e1831d9b151d24f5b86731904986f175629d))

**Full Changelog:** [`2024.02.15.0...2024.02.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.15.0...2024.02.16.0)

- - -

## 2024.02.15.0

### Bug Fixes

- Page forwarding issue for access forbidden in quick start ([#405](https://github.com/juspay/hyperswitch-control-center/pull/405)) ([`4b9c219`](https://github.com/juspay/hyperswitch-control-center/commit/4b9c219642d41082bfb2bf31c277590cbb13fdc1))

**Full Changelog:** [`2024.02.14.0...2024.02.15.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.14.0...2024.02.15.0)

- - -

## 2024.02.14.0

### Features

- Accept invite flow ([#353](https://github.com/juspay/hyperswitch-control-center/pull/353)) ([`657487f`](https://github.com/juspay/hyperswitch-control-center/commit/657487f214cb837a17345f40f58c33d744252d55))
- React Debounce Package removal & adding own functionality ([#391](https://github.com/juspay/hyperswitch-control-center/pull/391)) ([`82fb611`](https://github.com/juspay/hyperswitch-control-center/commit/82fb6114e01709ae3507a94fac72d1233dbc2a53))
- Added new graph library ([#394](https://github.com/juspay/hyperswitch-control-center/pull/394)) ([`98213a6`](https://github.com/juspay/hyperswitch-control-center/commit/98213a6bd9867819aa0f0504272e2d25c313d7f7))
- Feature flag accept invite ([#396](https://github.com/juspay/hyperswitch-control-center/pull/396)) ([`5803fe1`](https://github.com/juspay/hyperswitch-control-center/commit/5803fe155d69515349aae0d8645c484acef7b88f))
- Feature flag addition for Invite Multiple ([#397](https://github.com/juspay/hyperswitch-control-center/pull/397)) ([`087226e`](https://github.com/juspay/hyperswitch-control-center/commit/087226e73777024a00b1f281dc02719515b92380))
- Audit log enhancement ([#379](https://github.com/juspay/hyperswitch-control-center/pull/379)) ([`ced590c`](https://github.com/juspay/hyperswitch-control-center/commit/ced590c3b186664e2ac3a78cebde359f2afb2367))
- Added Counter disputes ([#347](https://github.com/juspay/hyperswitch-control-center/pull/347)) ([`d080614`](https://github.com/juspay/hyperswitch-control-center/commit/d080614356df05119e747897088d76a0e4753fd1))

### Bug Fixes

- Connector label update ([#279](https://github.com/juspay/hyperswitch-control-center/pull/279)) ([`4442ae4`](https://github.com/juspay/hyperswitch-control-center/commit/4442ae4c5dfd580c5e049e96ad1b9534bb61b0f6))
- Reset password local storage issue ([#401](https://github.com/juspay/hyperswitch-control-center/pull/401)) ([`534e3a9`](https://github.com/juspay/hyperswitch-control-center/commit/534e3a903e404a5c2ffb03d0bc33983821f970b4))

### Miscellaneous Tasks

- Empty & Non empty string logic_utils ([#378](https://github.com/juspay/hyperswitch-control-center/pull/378)) ([`c567b72`](https://github.com/juspay/hyperswitch-control-center/commit/c567b72f01120334d248c2f11abe7f4a897e87ab))

**Full Changelog:** [`2024.02.13.0...2024.02.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.13.0...2024.02.14.0)

- - -

## 2024.02.13.0

### Bug Fixes

- Minor Ui changes ([#392](https://github.com/juspay/hyperswitch-control-center/pull/392)) ([`66dc8ee`](https://github.com/juspay/hyperswitch-control-center/commit/66dc8ee5cc0ccec2cd11a19a9c206aaa188a95f2))

### Miscellaneous Tasks

- Chore: ui changes dashboard ([#380](https://github.com/juspay/hyperswitch-control-center/pull/380)) ([`090ff59`](https://github.com/juspay/hyperswitch-control-center/commit/090ff5943f3edc3de7e6e0e7c085ff80c976cf95))

**Full Changelog:** [`2024.02.12.1...2024.02.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.12.1...2024.02.13.0)

- - -

## 2024.02.12.1

### Miscellaneous Tasks

- Add signup cypress test ([#381](https://github.com/juspay/hyperswitch-control-center/pull/381)) ([`d39a5e2`](https://github.com/juspay/hyperswitch-control-center/commit/d39a5e28ac76268c41f2ccea78dc766b8f950928))

**Full Changelog:** [`2024.02.12.0...2024.02.12.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.12.0...2024.02.12.1)

- - -

## 2024.02.12.0

### Features

- Invite_multiple API Support added ([#376](https://github.com/juspay/hyperswitch-control-center/pull/376)) ([`26a502e`](https://github.com/juspay/hyperswitch-control-center/commit/26a502e840c592eac14d430f438fed88defa59f9))
- Enable VOLT in Live ([#384](https://github.com/juspay/hyperswitch-control-center/pull/384)) ([`4a7274b`](https://github.com/juspay/hyperswitch-control-center/commit/4a7274ba4628c02b2fc2dc0e5b6985f0478706ca))

### Miscellaneous Tasks

- Add health readiness endpoint ([#375](https://github.com/juspay/hyperswitch-control-center/pull/375)) ([`3e31ae1`](https://github.com/juspay/hyperswitch-control-center/commit/3e31ae174b4ae5a8a4c758b7022148e4c123508d))

**Full Changelog:** [`2024.02.11.0...2024.02.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.11.0...2024.02.12.0)

- - -

## 2024.02.11.0

### Features

- User_id remove from URL & feature flag removal of user management ([#371](https://github.com/juspay/hyperswitch-control-center/pull/371)) ([`08baca8`](https://github.com/juspay/hyperswitch-control-center/commit/08baca8df8a85df6985eb0cd47c675cecdfa8711))

**Full Changelog:** [`2024.02.08.0...2024.02.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.08.0...2024.02.11.0)

- - -

## 2024.02.08.0

### Features

- Change switch merchant response - filter is_active ([#362](https://github.com/juspay/hyperswitch-control-center/pull/362)) ([`2fd7c3d`](https://github.com/juspay/hyperswitch-control-center/commit/2fd7c3d650317dce003355df7baf4b949ec1f789))
- Add company name ([#359](https://github.com/juspay/hyperswitch-control-center/pull/359)) ([`9024dcd`](https://github.com/juspay/hyperswitch-control-center/commit/9024dcda6c7c1eaa8b0a7e1a03b42aa605c7ad45))

### Bug Fixes

- Payments header button alignment ([#366](https://github.com/juspay/hyperswitch-control-center/pull/366)) ([`f9f545b`](https://github.com/juspay/hyperswitch-control-center/commit/f9f545bc8457c0a01cf0d35637bd6853660f7ea0))
- Readme updated for new modules ([#367](https://github.com/juspay/hyperswitch-control-center/pull/367)) ([`8d91475`](https://github.com/juspay/hyperswitch-control-center/commit/8d91475ef2d1917de45b235b69300c43959921f1))
- Permsision API Changes ([#373](https://github.com/juspay/hyperswitch-control-center/pull/373)) ([`cf7b8e5`](https://github.com/juspay/hyperswitch-control-center/commit/cf7b8e5026167e7bb7770dd5d00ba7e3e5b5dd92))

**Full Changelog:** [`2024.02.07.0...2024.02.08.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.07.0...2024.02.08.0)

- - -

## 2024.02.07.0

### Bug Fixes

- Added support for other content-type ([#337](https://github.com/juspay/hyperswitch-control-center/pull/337)) ([`06002c6`](https://github.com/juspay/hyperswitch-control-center/commit/06002c6eafb2160a381c7d7fe8bef27bdb6da627))
- Headers object issue ([#350](https://github.com/juspay/hyperswitch-control-center/pull/350)) ([`f9dd029`](https://github.com/juspay/hyperswitch-control-center/commit/f9dd02998d1669a72c72689290e0412454a35f1a))

### Miscellaneous Tasks

- Update test ([`bde52da`](https://github.com/juspay/hyperswitch-control-center/commit/bde52da31270b8a9eb16ac3b50f2f044bbec88e1))
- Payout Enabled ([#357](https://github.com/juspay/hyperswitch-control-center/pull/357)) ([`6095b05`](https://github.com/juspay/hyperswitch-control-center/commit/6095b05fb4008a1c484ae139cbd61aeb57fc7e6d))

**Full Changelog:** [`2024.02.06.1...2024.02.07.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.06.1...2024.02.07.0)

- - -

## 2024.02.06.1

### Bug Fixes

- UI connector icon ([#348](https://github.com/juspay/hyperswitch-control-center/pull/348)) ([`b66af59`](https://github.com/juspay/hyperswitch-control-center/commit/b66af594a230e33c5e0eb6642ed4b8c5649e1d70))

**Full Changelog:** [`2024.02.06.0...2024.02.06.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.06.0...2024.02.06.1)

- - -

## 2024.02.06.0

### Features

- Add access control all over codebase ([#281](https://github.com/juspay/hyperswitch-control-center/pull/281)) ([`7c6beec`](https://github.com/juspay/hyperswitch-control-center/commit/7c6beecdcbcfdda9c93aaffd85d7a526ab4a137d))

### Bug Fixes

- Global search bar no-data found page fix ([#346](https://github.com/juspay/hyperswitch-control-center/pull/346)) ([`c52318e`](https://github.com/juspay/hyperswitch-control-center/commit/c52318e80d00b2f1b020b64a908f0b74089f7205))

### Refactors

- Font css function refactor ([#342](https://github.com/juspay/hyperswitch-control-center/pull/342)) ([`1c8109a`](https://github.com/juspay/hyperswitch-control-center/commit/1c8109a8e5e12b610e0e46eaadd42f71bff37c2b))

### Miscellaneous Tasks

- Add health endpoint ([#341](https://github.com/juspay/hyperswitch-control-center/pull/341)) ([`e194250`](https://github.com/juspay/hyperswitch-control-center/commit/e19425092b2019f5623f3b09a2772182a2ed5f51))

**Full Changelog:** [`2024.02.05.0...2024.02.06.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.05.0...2024.02.06.0)

- - -

## 2024.02.05.0

### Bug Fixes

- Added connector display name ([#329](https://github.com/juspay/hyperswitch-control-center/pull/329)) ([`f3ea262`](https://github.com/juspay/hyperswitch-control-center/commit/f3ea262e1b6995dcbf8023fbd3e7e392b9cd481d))

### Miscellaneous Tasks

- Refactor code ([#331](https://github.com/juspay/hyperswitch-control-center/pull/331)) ([`e9de547`](https://github.com/juspay/hyperswitch-control-center/commit/e9de5473855e12f22d18ba9fa137fb94f05b6f0f))
- Remove Customers Module Feature flag ([#336](https://github.com/juspay/hyperswitch-control-center/pull/336)) ([`da9a7fa`](https://github.com/juspay/hyperswitch-control-center/commit/da9a7fa5ce03ded823a5cd45d5eea2871704b5f4))
- Date core api changes ([#334](https://github.com/juspay/hyperswitch-control-center/pull/334)) ([`85c784f`](https://github.com/juspay/hyperswitch-control-center/commit/85c784fcdd906bc96dc42fbbfab289923044e907))

**Full Changelog:** [`2024.02.04.0...2024.02.05.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.04.0...2024.02.05.0)

- - -

## 2024.02.04.0

### Bug Fixes

- Glitch in homepage ([#325](https://github.com/juspay/hyperswitch-control-center/pull/325)) ([`a3116ed`](https://github.com/juspay/hyperswitch-control-center/commit/a3116ed23cd226cd4257b8df7e27531c4150aa84))

**Full Changelog:** [`2024.02.01.1...2024.02.04.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.01.1...2024.02.04.0)

- - -

## 2024.02.01.1

### Features

- Table access block ([#323](https://github.com/juspay/hyperswitch-control-center/pull/323)) ([`4950084`](https://github.com/juspay/hyperswitch-control-center/commit/4950084b4bce57eac9fb183f65e773ee86cfd567))

### Bug Fixes

- UI css fixes ([#320](https://github.com/juspay/hyperswitch-control-center/pull/320)) ([`07ff876`](https://github.com/juspay/hyperswitch-control-center/commit/07ff876051a9bd86b1ab4c4f5423dcf0d5c54015))
- Switch Merchant Issue ([#324](https://github.com/juspay/hyperswitch-control-center/pull/324)) ([`780c93b`](https://github.com/juspay/hyperswitch-control-center/commit/780c93b57d14b400dd3be2ab064e544844a04c3d))

### Miscellaneous Tasks

- Exn & Math Core API use ([#319](https://github.com/juspay/hyperswitch-control-center/pull/319)) ([`b063a78`](https://github.com/juspay/hyperswitch-control-center/commit/b063a78a8d9a2eeafc58b416ff987d801e328f6c))

**Full Changelog:** [`2024.02.01.0...2024.02.01.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.02.01.0...2024.02.01.1)

- - -

## 2024.02.01.0

### Features

- Acl button access block ([#314](https://github.com/juspay/hyperswitch-control-center/pull/314)) ([`2fd2436`](https://github.com/juspay/hyperswitch-control-center/commit/2fd2436febf71f0a3bc4b6413fa6b4ce06375fa5))

### Bug Fixes

- Profile access control ([#317](https://github.com/juspay/hyperswitch-control-center/pull/317)) ([`50db59f`](https://github.com/juspay/hyperswitch-control-center/commit/50db59f25b564edb2826a2b1130b0dd8ec04e1c9))

### Miscellaneous Tasks

- Add workflow dispatch for cypress ([`f65ca5a`](https://github.com/juspay/hyperswitch-control-center/commit/f65ca5aab56ffc3876902787f3d526363a68f062))
- Add workflow dispatch for cypress ([`8349f61`](https://github.com/juspay/hyperswitch-control-center/commit/8349f614a931767001e259e9b27d3148938f40e8))
- Add workflow dispatch for cypress ([`c01bbc5`](https://github.com/juspay/hyperswitch-control-center/commit/c01bbc591b72e7b8498b4f4cc67444bab9f27382))
- Add workflow dispatch for cypress ([`0c94ac8`](https://github.com/juspay/hyperswitch-control-center/commit/0c94ac8b02c3978ba75fa8c5a5422e4ca4adc46b))
- Add workflow dispatch for cypress ([`de87a7b`](https://github.com/juspay/hyperswitch-control-center/commit/de87a7bfe57eeda2391c5205028fc0cd55691cc5))

**Full Changelog:** [`2024.01.31.1...2024.02.01.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.31.1...2024.02.01.0)

- - -

## 2024.01.31.1

### Miscellaneous Tasks

- Add e2e testcase ([#262](https://github.com/juspay/hyperswitch-control-center/pull/262)) ([`be32a53`](https://github.com/juspay/hyperswitch-control-center/commit/be32a53b73bb12c617716d9f2bc1499e0d84c9f5))
- Chore: feature flag addition for paypal automatic flow ([#316](https://github.com/juspay/hyperswitch-control-center/pull/316)) ([`4764a34`](https://github.com/juspay/hyperswitch-control-center/commit/4764a341fb23d650051f2650bdf1a3718c72f0b9))

**Full Changelog:** [`2024.01.31.0...2024.01.31.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.31.0...2024.01.31.1)

- - -

## 2024.01.31.0

### Features

- Feat: paypal changes ([#285](https://github.com/juspay/hyperswitch-control-center/pull/285)) ([`2ecef9f`](https://github.com/juspay/hyperswitch-control-center/commit/2ecef9fc776ed27ae06c17c900ecf0126bfd799b))

### Miscellaneous Tasks

- Js.Json API removed - JSON Core API Used. ([#311](https://github.com/juspay/hyperswitch-control-center/pull/311)) ([`1ff05f8`](https://github.com/juspay/hyperswitch-control-center/commit/1ff05f803229ddc10178c4257b7cfd9a17609d95))
- Nullable Core API Added.. ([#315](https://github.com/juspay/hyperswitch-control-center/pull/315)) ([`c8ae50b`](https://github.com/juspay/hyperswitch-control-center/commit/c8ae50b0f680c93e2ead174f328df4ab82d8e41d))

**Full Changelog:** [`2024.01.30.0...2024.01.31.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.30.0...2024.01.31.0)

- - -

## 2024.01.30.0

### Features

- Made the customize columns to appear in Portal for same line ([#308](https://github.com/juspay/hyperswitch-control-center/pull/308)) ([`ea21b97`](https://github.com/juspay/hyperswitch-control-center/commit/ea21b97c5964d34ce335a8c69e43142a65eb25bf))

### Refactors

- Proper identification of reactHyperJs from hyperswitch ([#299](https://github.com/juspay/hyperswitch-control-center/pull/299)) ([`4038dff`](https://github.com/juspay/hyperswitch-control-center/commit/4038dff12c539382490752979b917f7790b08ca6))

### Miscellaneous Tasks

- Remove Belt API from codebase ([#310](https://github.com/juspay/hyperswitch-control-center/pull/310)) ([`089c051`](https://github.com/juspay/hyperswitch-control-center/commit/089c05142ad9591adac3ef94f66c48321fe6ec65))

**Full Changelog:** [`2024.01.29.0...2024.01.30.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.29.0...2024.01.30.0)

- - -

## 2024.01.29.0

### Features

- Accept dispute ([#214](https://github.com/juspay/hyperswitch-control-center/pull/214)) ([`4c0d56b`](https://github.com/juspay/hyperswitch-control-center/commit/4c0d56b134276787cfbc3b48d53c591f8dcc7ae1))

### Bug Fixes

- Audit log fix ([#305](https://github.com/juspay/hyperswitch-control-center/pull/305)) ([`6bffa75`](https://github.com/juspay/hyperswitch-control-center/commit/6bffa75d580896bb86122da823e94814516bdb41))
- Enabling nmi in prod ([#309](https://github.com/juspay/hyperswitch-control-center/pull/309)) ([`30ebc24`](https://github.com/juspay/hyperswitch-control-center/commit/30ebc24a558969fbc2789700c93247d5dd586120))

### Miscellaneous Tasks

- Rescript core version upgrade ([#293](https://github.com/juspay/hyperswitch-control-center/pull/293)) ([`2d03f43`](https://github.com/juspay/hyperswitch-control-center/commit/2d03f43092cc8a7ed030a2f2ad8df663f081c15b))

**Full Changelog:** [`2024.01.25.1...2024.01.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.25.1...2024.01.29.0)

- - -

## 2024.01.25.1

### Miscellaneous Tasks

- Update release-stable-version.yml ([#306](https://github.com/juspay/hyperswitch-control-center/pull/306)) ([`a4f9dfa`](https://github.com/juspay/hyperswitch-control-center/commit/a4f9dfa4d0a327feb629621e4b270c19fa87a1df))
- Remove old workflow ([#307](https://github.com/juspay/hyperswitch-control-center/pull/307)) ([`4b01c99`](https://github.com/juspay/hyperswitch-control-center/commit/4b01c99656ba7fc1bc93a8b76a786bdcf318f949))

**Full Changelog:** [`2024.01.25.0...2024.01.25.1`](https://github.com/juspay/hyperswitch-control-center/compare/2024.01.25.0...2024.01.25.1)

- - -

## 2024.01.25.0

### Bug Fixes

- Close connector drop down bydefault ([#303](https://github.com/juspay/hyperswitch-control-center/pull/303)) ([`7006d91`](https://github.com/juspay/hyperswitch-control-center/commit/7006d915dec69b2db96cf36a5399accd86f173c2))

### Miscellaneous Tasks

- Change tag creation ([#297](https://github.com/juspay/hyperswitch-control-center/pull/297)) ([`1466e6a`](https://github.com/juspay/hyperswitch-control-center/commit/1466e6adf9dac3d746c5105b5ccfb9b1a51f9c4c))

- - -

## 1.29.0 (2024-01-24)

### Features

- Added webhooks events ([#272](https://github.com/juspay/hyperswitch-control-center/pull/272)) ([`17efd52`](https://github.com/juspay/hyperswitch-control-center/commit/17efd52ad93f9b4350b68931d2dd43bf8dadb841))
- Syntax highlighter ([#300](https://github.com/juspay/hyperswitch-control-center/pull/300)) ([`d4b800f`](https://github.com/juspay/hyperswitch-control-center/commit/d4b800f32927a6e28a991e574cf312124add26bc))

### Bug Fixes

- Headers issue ([#295](https://github.com/juspay/hyperswitch-control-center/pull/295)) ([`91f98c4`](https://github.com/juspay/hyperswitch-control-center/commit/91f98c4aedb7b744043e63405ed9189b14103fb9))
- Quick start default selection issue ([#287](https://github.com/juspay/hyperswitch-control-center/pull/287)) ([`0ce1d05`](https://github.com/juspay/hyperswitch-control-center/commit/0ce1d055066453338b98b725fef5dcb5c8a402b6))
- Content type fix ([#302](https://github.com/juspay/hyperswitch-control-center/pull/302)) ([`ad2ffb9`](https://github.com/juspay/hyperswitch-control-center/commit/ad2ffb9df736e6617a6ebfd3fb6e7cd1803458af))

### Miscellaneous Tasks

- Utils refactor ([#282](https://github.com/juspay/hyperswitch-control-center/pull/282)) ([`40954d2`](https://github.com/juspay/hyperswitch-control-center/commit/40954d25e225520d41bd2585f2b0fbfc4d9ee965))
- Remove redundant code ([#298](https://github.com/juspay/hyperswitch-control-center/pull/298)) ([`d047ae7`](https://github.com/juspay/hyperswitch-control-center/commit/d047ae7905b3df6fc19679519ed29ad17c164e29))

**Full Changelog:** [`v1.28.1...v1.29.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.28.1...v1.29.0)

- - -


## 1.28.1 (2024-01-23)

### Bug Fixes

- Use apifetcher function update ([#283](https://github.com/juspay/hyperswitch-control-center/pull/283)) ([`d587598`](https://github.com/juspay/hyperswitch-control-center/commit/d587598a1f13a234b68b5bc204780fda3c773e0e))
- Changes for supporting form data type in api ([#257](https://github.com/juspay/hyperswitch-control-center/pull/257)) ([`84c283b`](https://github.com/juspay/hyperswitch-control-center/commit/84c283b8092e3296dc97c87725966d540f490d5b))
- Access Control Issue ([#284](https://github.com/juspay/hyperswitch-control-center/pull/284)) ([`f35bcc5`](https://github.com/juspay/hyperswitch-control-center/commit/f35bcc524184c0c1bcc84a41198e81424bef7cc4))

**Full Changelog:** [`v1.28.0...v1.28.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.28.0...v1.28.1)

- - -


## 1.28.0 (2024-01-22)

### Features

- Permission based sidebar navigation ([#265](https://github.com/juspay/hyperswitch-control-center/pull/265)) ([`d545a56`](https://github.com/juspay/hyperswitch-control-center/commit/d545a56ceed84777fac27c7b8ca0ce92042bddaf))
- ACLButton Added ([#277](https://github.com/juspay/hyperswitch-control-center/pull/277)) ([`1032650`](https://github.com/juspay/hyperswitch-control-center/commit/1032650defeec0ef25eeb31735db116421b2bdfe))

**Full Changelog:** [`v1.27.0...v1.28.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.27.0...v1.28.0)

- - -


## 1.27.0 (2024-01-21)

### Features

- Update pr label on merge to closed ([#207](https://github.com/juspay/hyperswitch-control-center/pull/207)) ([`f8994ff`](https://github.com/juspay/hyperswitch-control-center/commit/f8994ff8faadc73bf89c67048d2c798024701963))

### Bug Fixes

- Make basic details form to accept form input without Save button ([#271](https://github.com/juspay/hyperswitch-control-center/pull/271)) ([`3784090`](https://github.com/juspay/hyperswitch-control-center/commit/3784090a99cf67c4dee69b914b66fe7979a39620))

### Miscellaneous Tasks

- Option Core changes ([#268](https://github.com/juspay/hyperswitch-control-center/pull/268)) ([`94e70d3`](https://github.com/juspay/hyperswitch-control-center/commit/94e70d37fb3fc36104ea3ad412f03afc7d115369))

**Full Changelog:** [`v1.26.0...v1.27.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.26.0...v1.27.0)

- - -


## 1.26.0 (2024-01-18)

### Features

- Add new user ([#237](https://github.com/juspay/hyperswitch-control-center/pull/237)) ([`3749e32`](https://github.com/juspay/hyperswitch-control-center/commit/3749e3278602c2ad514079db3d6d78226cfa9391))
- Access added for Button ([#274](https://github.com/juspay/hyperswitch-control-center/pull/274)) ([`d5ecee6`](https://github.com/juspay/hyperswitch-control-center/commit/d5ecee626d3da87f6bda8495b7539ba8660a7618))

### Bug Fixes

- Floating point value fix for test payment ([#270](https://github.com/juspay/hyperswitch-control-center/pull/270)) ([`038a714`](https://github.com/juspay/hyperswitch-control-center/commit/038a71492de22f1a1a51b6de9f68f010bf872268))

### Refactors

- Routing types and utils ([#254](https://github.com/juspay/hyperswitch-control-center/pull/254)) ([`b8b5034`](https://github.com/juspay/hyperswitch-control-center/commit/b8b5034fbae6974e34c799e6f9333e3663247f7f))

### Miscellaneous Tasks

- Added Access Type & Remove the Read & ReadWrite Type ([#267](https://github.com/juspay/hyperswitch-control-center/pull/267)) ([`49e3eae`](https://github.com/juspay/hyperswitch-control-center/commit/49e3eaeb9bd14a3c788649b81cf561386a5ce006))
- Refactor invite users ([#273](https://github.com/juspay/hyperswitch-control-center/pull/273)) ([`85b07d0`](https://github.com/juspay/hyperswitch-control-center/commit/85b07d0cf058dd0842b11acb7714cd85f8d9d6c6))

**Full Changelog:** [`v1.25.1...v1.26.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.25.1...v1.26.0)

- - -


## 1.25.1 (2024-01-17)

### Miscellaneous Tasks

- Sidebar refactoring & permissions added ([#264](https://github.com/juspay/hyperswitch-control-center/pull/264)) ([`f428679`](https://github.com/juspay/hyperswitch-control-center/commit/f428679fa9b98e002e8bb1f670af65595ae64845))
- Access Control Module added ([#266](https://github.com/juspay/hyperswitch-control-center/pull/266)) ([`59d0b53`](https://github.com/juspay/hyperswitch-control-center/commit/59d0b5387476536ed3a7f6a9f3468a3bd115232f))

**Full Changelog:** [`v1.25.0...v1.25.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.25.0...v1.25.1)

- - -


## 1.25.0 (2024-01-16)

### Features

- Cybersource enabled in Prod ([#256](https://github.com/juspay/hyperswitch-control-center/pull/256)) ([`93f202e`](https://github.com/juspay/hyperswitch-control-center/commit/93f202e4c0b76e29de7e515e3b405692a09e3e40))

### Bug Fixes

- Make tax_on_surcharge optional and add description ([#259](https://github.com/juspay/hyperswitch-control-center/pull/259)) ([`498437b`](https://github.com/juspay/hyperswitch-control-center/commit/498437b94fe6f69c42708baca19ba9132714f467))

**Full Changelog:** [`v1.24.2...v1.25.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.24.2...v1.25.0)

- - -


## 1.24.2 (2024-01-12)

### Bug Fixes

- Currency change ([#249](https://github.com/juspay/hyperswitch-control-center/pull/249)) ([`f72f290`](https://github.com/juspay/hyperswitch-control-center/commit/f72f290468125c6763e89047b162642ab3bf27e6))
- Currency change ([#250](https://github.com/juspay/hyperswitch-control-center/pull/250)) ([`89f4874`](https://github.com/juspay/hyperswitch-control-center/commit/89f487488a008dafd1e704f4e796048eda631429))

**Full Changelog:** [`v1.24.1...v1.24.2`](https://github.com/juspay/hyperswitch-control-center/compare/v1.24.1...v1.24.2)

- - -


## 1.24.1 (2024-01-12)

### Bug Fixes

- Curruncy fix ([#248](https://github.com/juspay/hyperswitch-control-center/pull/248)) ([`12c72a7`](https://github.com/juspay/hyperswitch-control-center/commit/12c72a7cb95fd408737564111e324c44c0001626))

**Full Changelog:** [`v1.24.0...v1.24.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.24.0...v1.24.1)

- - -


## 1.24.0 (2024-01-12)

### Features

- Zero payment added ([#246](https://github.com/juspay/hyperswitch-control-center/pull/246)) ([`90dbf28`](https://github.com/juspay/hyperswitch-control-center/commit/90dbf287265bf51920edc2666ead6b8bdd49f337))

**Full Changelog:** [`v1.23.3...v1.24.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.23.3...v1.24.0)

- - -


## 1.23.3 (2024-01-11)

### Bug Fixes

- revert customer module flag removal ([#244](https://github.com/juspay/hyperswitch-control-center/pull/244)) ([`15d2e6e`](https://github.com/juspay/hyperswitch-control-center/commit/15d2e6e341f9336f69cb3d23fbaf0c90c8acce3e))
- Business & Shipping Details Updated ([#245](https://github.com/juspay/hyperswitch-control-center/pull/245)) ([`8a91072`](https://github.com/juspay/hyperswitch-control-center/commit/8a91072733bc865a4078daa4c1d4034858629de1))

**Full Changelog:** [`v1.23.2...v1.23.3`](https://github.com/juspay/hyperswitch-control-center/compare/v1.23.2...v1.23.3)

- - -


## 1.23.2 (2024-01-11)

### Bug Fixes

- Customer module flag removal ([#242](https://github.com/juspay/hyperswitch-control-center/pull/242)) ([`5b06a76`](https://github.com/juspay/hyperswitch-control-center/commit/5b06a7657e4605fe6b35fe506913ea429d97a204))

**Full Changelog:** [`v1.23.1...v1.23.2`](https://github.com/juspay/hyperswitch-control-center/compare/v1.23.1...v1.23.2)

- - -


## 1.23.1 (2024-01-11)

### Bug Fixes

- Show billing and shipping address ([#233](https://github.com/juspay/hyperswitch-control-center/pull/233)) ([`f19eca8`](https://github.com/juspay/hyperswitch-control-center/commit/f19eca827599002dbdb694856d383daf8a995713))
- Profile changes in Routing ([#236](https://github.com/juspay/hyperswitch-control-center/pull/236)) ([`623599a`](https://github.com/juspay/hyperswitch-control-center/commit/623599a5221502d6c390ab79be68f9d282e45538))
- Surcharge value type ([#238](https://github.com/juspay/hyperswitch-control-center/pull/238)) ([`995c3bb`](https://github.com/juspay/hyperswitch-control-center/commit/995c3bbfd709616965e350f67f971e524fff6a2f))

**Full Changelog:** [`v1.23.0...v1.23.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.23.0...v1.23.1)

- - -


## 1.23.0 (2024-01-10)

### Features

- Duplicate and edit configuration in volume based routing ([#146](https://github.com/juspay/hyperswitch-control-center/pull/146)) ([`5520ba8`](https://github.com/juspay/hyperswitch-control-center/commit/5520ba8a04fb709bde4a6197c6ee4c6f07ce3a6a))
- Customers Module feature flag ([#218](https://github.com/juspay/hyperswitch-control-center/pull/218)) ([`1e0b297`](https://github.com/juspay/hyperswitch-control-center/commit/1e0b29775127cbbfaf1f21a82b786c324e3fa7d7))
- Connector Label added in Show Payments ([#216](https://github.com/juspay/hyperswitch-control-center/pull/216)) ([`73e0b3d`](https://github.com/juspay/hyperswitch-control-center/commit/73e0b3d7b59b588807771cb5fd9fdd68996b1252))
- Mixpanel added for quick start flow ([#222](https://github.com/juspay/hyperswitch-control-center/pull/222)) ([`611594f`](https://github.com/juspay/hyperswitch-control-center/commit/611594f3baeb2d7579679ede49b0d0e91fde7983))
- Change data type response for switch merchant ([#212](https://github.com/juspay/hyperswitch-control-center/pull/212)) ([`bb1ce83`](https://github.com/juspay/hyperswitch-control-center/commit/bb1ce83b209f8cbee3fb3f4d29c28ca0640a0b80))

### Bug Fixes

- Moved HyperLoader script ([#110](https://github.com/juspay/hyperswitch-control-center/pull/110)) ([`e94a1b4`](https://github.com/juspay/hyperswitch-control-center/commit/e94a1b4ac8ec77bf943b70f481496db3636ad53e))
- Make self-serve sidebar responsive ([#226](https://github.com/juspay/hyperswitch-control-center/pull/226)) ([`a0305d2`](https://github.com/juspay/hyperswitch-control-center/commit/a0305d254beec02de40e6098273bad2ef140904b))

### Refactors

- Remove dead code ([#138](https://github.com/juspay/hyperswitch-control-center/pull/138)) ([`6c7ac5c`](https://github.com/juspay/hyperswitch-control-center/commit/6c7ac5cc9637c3c8ed3cf0072b346e2e99db3053))

**Full Changelog:** [`v1.22.0...v1.23.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.22.0...v1.23.0)

- - -


## 1.22.0 (2024-01-09)

### Features

- Modal added for Switch merchant switch. ([#213](https://github.com/juspay/hyperswitch-control-center/pull/213)) ([`660c706`](https://github.com/juspay/hyperswitch-control-center/commit/660c706b26c6a7177b36dd416483e4435e686fd4))

**Full Changelog:** [`v1.21.0...v1.22.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.21.0...v1.22.0)

- - -


## 1.21.0 (2024-01-09)

### Features

- Customers module ([#198](https://github.com/juspay/hyperswitch-control-center/pull/198)) ([`c307fd7`](https://github.com/juspay/hyperswitch-control-center/commit/c307fd7bde4b3d43d54022b67f6be2265fc70eca))

### Bug Fixes

- Eslint issue ([#205](https://github.com/juspay/hyperswitch-control-center/pull/205)) ([`011edf1`](https://github.com/juspay/hyperswitch-control-center/commit/011edf188a610b7dd6977d32006cda3c5b029965))
- Filters enhance ([#160](https://github.com/juspay/hyperswitch-control-center/pull/160)) ([`77cebce`](https://github.com/juspay/hyperswitch-control-center/commit/77cebced9bfd9621f7c15b40c92b82f9c8be8c4f))

**Full Changelog:** [`v1.20.0...v1.21.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.20.0...v1.21.0)

- - -


## 1.20.0 (2024-01-08)

### Features

- Added new filters for payments ([#172](https://github.com/juspay/hyperswitch-control-center/pull/172)) ([`fd648de`](https://github.com/juspay/hyperswitch-control-center/commit/fd648de4e7cc0fde72b7316f9679abc248e0118f))

### Bug Fixes

- Connector integration status and disabled ui change ([#192](https://github.com/juspay/hyperswitch-control-center/pull/192)) ([`f784ef2`](https://github.com/juspay/hyperswitch-control-center/commit/f784ef27762098645886396e5043c219e566fa91))
- Revert useField in TextInput ([#199](https://github.com/juspay/hyperswitch-control-center/pull/199)) ([`47cc5ed`](https://github.com/juspay/hyperswitch-control-center/commit/47cc5ede71736e1c6ecd5045b6f3b4c4b829436b))

### Miscellaneous Tasks

- Analytics files Js.Dict -> Dict migration ([#194](https://github.com/juspay/hyperswitch-control-center/pull/194)) ([`71934b5`](https://github.com/juspay/hyperswitch-control-center/commit/71934b58d459ca979d7d150c41478e05b205ebcc))

**Full Changelog:** [`v1.19.5...v1.20.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.5...v1.20.0)

- - -


## 1.19.5 (2024-01-08)

### Bug Fixes

- Add merchant fix ([#184](https://github.com/juspay/hyperswitch-control-center/pull/184)) ([`7bc7226`](https://github.com/juspay/hyperswitch-control-center/commit/7bc7226cf2ee0c70b8dc49c73de91020c2f9b8e7))

### Miscellaneous Tasks

- Add eslint hook ([#166](https://github.com/juspay/hyperswitch-control-center/pull/166)) ([`4a10a94`](https://github.com/juspay/hyperswitch-control-center/commit/4a10a94728ec6d62897e3299c2c924301ad86f0f))

**Full Changelog:** [`v1.19.4...v1.19.5`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.4...v1.19.5)

- - -


## 1.19.4 (2024-01-05)

### Bug Fixes

- Switch merchant enabled for Live Env ([#176](https://github.com/juspay/hyperswitch-control-center/pull/176)) ([`035ab3e`](https://github.com/juspay/hyperswitch-control-center/commit/035ab3e55609b0cb2d8c5c026229fd0e1fb6d780))

### Miscellaneous Tasks

- Add issue template ([`0f112ed`](https://github.com/juspay/hyperswitch-control-center/commit/0f112edc291e34635cf89ad88a37be83c22de67f))
- Mixpanel country added ([#171](https://github.com/juspay/hyperswitch-control-center/pull/171)) ([`4ee8937`](https://github.com/juspay/hyperswitch-control-center/commit/4ee89375bf14b55bd9b68d8d64f5d628abe0469e))
- Array changes ([#174](https://github.com/juspay/hyperswitch-control-center/pull/174)) ([`1571bc2`](https://github.com/juspay/hyperswitch-control-center/commit/1571bc29d7c6a74eb02894789b172ecc14f8e592))
- String clean changes ([#175](https://github.com/juspay/hyperswitch-control-center/pull/175)) ([`d2ce5be`](https://github.com/juspay/hyperswitch-control-center/commit/d2ce5be1d23f5a19161305e71f4373f9fe49c205))

**Full Changelog:** [`v1.19.3...v1.19.4`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.3...v1.19.4)

- - -


## 1.19.3 (2024-01-04)

### Documentation

- Added security policy, code of conduct and contributing md files ([#167](https://github.com/juspay/hyperswitch-control-center/pull/167)) ([`4056ba9`](https://github.com/juspay/hyperswitch-control-center/commit/4056ba9ee8eeebb32b125e10c6a31eac28f3b8c4))
- Added license file and contributing guidelines ([#168](https://github.com/juspay/hyperswitch-control-center/pull/168)) ([`bc102ba`](https://github.com/juspay/hyperswitch-control-center/commit/bc102ba6237be4c8a17e2e6c999b6cf2ad80f6af))

**Full Changelog:** [`v1.19.2...v1.19.3`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.2...v1.19.3)

- - -


## 1.19.2 (2024-01-04)

### Bug Fixes

- Disputes api change ([#162](https://github.com/juspay/hyperswitch-control-center/pull/162)) ([`17e4c8a`](https://github.com/juspay/hyperswitch-control-center/commit/17e4c8a013c3934c192f8ae7303db501d1e2c19f))
- Connector list fix for search live ([#164](https://github.com/juspay/hyperswitch-control-center/pull/164)) ([`24e1cef`](https://github.com/juspay/hyperswitch-control-center/commit/24e1cef2010c77cf69e80bfb54fd34acbc00fafd))
- Email issue in mixpanel capture ([#163](https://github.com/juspay/hyperswitch-control-center/pull/163)) ([`c2ff8a9`](https://github.com/juspay/hyperswitch-control-center/commit/c2ff8a9f610b0a1874435e977f3f3a48a5a1b0e1))
- Cashtocode update flow ([#148](https://github.com/juspay/hyperswitch-control-center/pull/148)) ([`c17b466`](https://github.com/juspay/hyperswitch-control-center/commit/c17b46692e7f723a8680b5b1cecd7bf383e536c8))

**Full Changelog:** [`v1.19.1...v1.19.2`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.1...v1.19.2)

- - -


## 1.19.1 (2024-01-03)

### Bug Fixes

- Enabled braintree in prod ([#161](https://github.com/juspay/hyperswitch-control-center/pull/161)) ([`bcffb62`](https://github.com/juspay/hyperswitch-control-center/commit/bcffb627f8a25af19352d4740e879dbc8772e06a))

### Miscellaneous Tasks

- Move from Js Library to Core Array/Dict components ([#145](https://github.com/juspay/hyperswitch-control-center/pull/145)) ([`6a68efd`](https://github.com/juspay/hyperswitch-control-center/commit/6a68efd851515f8a4af17077a9145483364a7cb5))

**Full Changelog:** [`v1.19.0...v1.19.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.19.0...v1.19.1)

- - -


## 1.19.0 (2024-01-03)

### Features

- Surcharge ([#123](https://github.com/juspay/hyperswitch-control-center/pull/123)) ([`95a1d81`](https://github.com/juspay/hyperswitch-control-center/commit/95a1d8146057a8262b824d0784e32c268118af73))
- Added mixpanel events ([#158](https://github.com/juspay/hyperswitch-control-center/pull/158)) ([`543e074`](https://github.com/juspay/hyperswitch-control-center/commit/543e0749dfcc2b0a426eecd554c4890396793f38))
- Multi filters support ([#79](https://github.com/juspay/hyperswitch-control-center/pull/79)) ([`fd1aa3d`](https://github.com/juspay/hyperswitch-control-center/commit/fd1aa3d0b108f14375d50cc50833395fb6f19867))
- Prod enum changes ([#128](https://github.com/juspay/hyperswitch-control-center/pull/128)) ([`b67b95a`](https://github.com/juspay/hyperswitch-control-center/commit/b67b95a5555b5d7d46ee0e1ccd808821e6505336))

**Full Changelog:** [`v1.18.3...v1.19.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.18.3...v1.19.0)

- - -


## 1.18.3 (2024-01-02)

### Bug Fixes

- Scrollbar revert ([#153](https://github.com/juspay/hyperswitch-control-center/pull/153)) ([`731ac50`](https://github.com/juspay/hyperswitch-control-center/commit/731ac503e93d051cf3dc1b34593e91b896105897))
- Business profile addition modal bugfix ([#152](https://github.com/juspay/hyperswitch-control-center/pull/152)) ([`7075812`](https://github.com/juspay/hyperswitch-control-center/commit/707581209d18e19c9247a551544a317035cd2039))
- Unnecessary API List count of connectors stop ([#154](https://github.com/juspay/hyperswitch-control-center/pull/154)) ([`40ae278`](https://github.com/juspay/hyperswitch-control-center/commit/40ae2788172c19f05206df59131e6a35e1b70f8e))

### Miscellaneous Tasks

- Mixpanel clearing ([#155](https://github.com/juspay/hyperswitch-control-center/pull/155)) ([`c3a6eaf`](https://github.com/juspay/hyperswitch-control-center/commit/c3a6eaff6f42abc977e8121e1730f2372fc1b5de))

**Full Changelog:** [`v1.18.2...v1.18.3`](https://github.com/juspay/hyperswitch-control-center/compare/v1.18.2...v1.18.3)

- - -


## 1.16.0 (2023-12-26)

### Features

- README.md PR title changes ([#134](https://github.com/juspay/hyperswitch-control-center/pull/134)) ([`66ef342`](https://github.com/juspay/hyperswitch-control-center/commit/66ef342d46095bac4a2901daac198b60d647d2c6))

### Bug Fixes

- FixedPageWidth Changes ([#132](https://github.com/juspay/hyperswitch-control-center/pull/132)) ([`921eab4`](https://github.com/juspay/hyperswitch-control-center/commit/921eab4629e0a921b6f29bc286a9009173180570))
- APIUtils changes ([#135](https://github.com/juspay/hyperswitch-control-center/pull/135)) ([`9ec16e8`](https://github.com/juspay/hyperswitch-control-center/commit/9ec16e87f32e7564d363f6bbc9d0c323e816aa4f))
- API fix and radio icon changes ([#136](https://github.com/juspay/hyperswitch-control-center/pull/136)) ([`2ee3bf2`](https://github.com/juspay/hyperswitch-control-center/commit/2ee3bf2f7fb10491ffe036a30c009da853e62366))

### Refactors

- ApiUtils file to use the apiPrefix once only ([#122](https://github.com/juspay/hyperswitch-control-center/pull/122)) ([`dc4e644`](https://github.com/juspay/hyperswitch-control-center/commit/dc4e644a9a7825bf74d47c5d225c71efb5b31369))

**Full Changelog:** [`v1.15.1...v1.16.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.15.1...v1.16.0)

- - -


## 1.14.0 (2023-12-24)

### Features

- Sidebar expansion close ([#126](https://github.com/juspay/hyperswitch-control-center/pull/126)) ([`ea91fba`](https://github.com/juspay/hyperswitch-control-center/commit/ea91fba4505fc8b64e0bc161ca41d1395fb83af2))

**Full Changelog:** [`v1.13.1...v1.14.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.13.1...v1.14.0)

- - -


## 1.13.1 (2023-12-21)

### Bug Fixes

- Disable-user-invite-button ([#124](https://github.com/juspay/hyperswitch-control-center/pull/124)) ([`36177c7`](https://github.com/juspay/hyperswitch-control-center/commit/36177c71ae369b1b82c16b6ed59d298a646efc3a))

**Full Changelog:** [`v1.13.0...v1.13.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.13.0...v1.13.1)

- - -


## 1.13.0 (2023-12-20)

### Features

- New wasm changes ([#114](https://github.com/juspay/hyperswitch-control-center/pull/114)) ([`758f80d`](https://github.com/juspay/hyperswitch-control-center/commit/758f80d945bd558f7059b8ec40b2b373aaa2e77a))
- Dropdown grouping added in routing ([#102](https://github.com/juspay/hyperswitch-control-center/pull/102)) ([`52933b4`](https://github.com/juspay/hyperswitch-control-center/commit/52933b434dd6920e821a465b51c5bbb46ced68cd))
- Resend Invite Removal ([#121](https://github.com/juspay/hyperswitch-control-center/pull/121)) ([`3551622`](https://github.com/juspay/hyperswitch-control-center/commit/35516226ad3e784626812e4a3be09dcb165a867d))

### Bug Fixes

- Connector UI Issue. ([#113](https://github.com/juspay/hyperswitch-control-center/pull/113)) ([`ad28e1c`](https://github.com/juspay/hyperswitch-control-center/commit/ad28e1ca72f3d57407cb679a451e43ccd94ae2de))
- Signout API removed. ([#116](https://github.com/juspay/hyperswitch-control-center/pull/116)) ([`af13892`](https://github.com/juspay/hyperswitch-control-center/commit/af13892017a5ca1e4bac8dcbe26d837a87467634))
- Connector files changes for paypal onboarding ([#115](https://github.com/juspay/hyperswitch-control-center/pull/115)) ([`74f327c`](https://github.com/juspay/hyperswitch-control-center/commit/74f327c5067a17d44313492e0032422a70d8aa9d))
- Metadata field issue fix ([#117](https://github.com/juspay/hyperswitch-control-center/pull/117)) ([`585674a`](https://github.com/juspay/hyperswitch-control-center/commit/585674a5fe324492c290c1e6ec32fd8b71822402))
- Typos in readme - fix typos in Readme.md ([#105](https://github.com/juspay/hyperswitch-control-center/pull/105)) ([`c88dcd2`](https://github.com/juspay/hyperswitch-control-center/commit/c88dcd23a8c291fd538ba6c4631a15cdf28c502d))
- Refunds reports end point change ([#119](https://github.com/juspay/hyperswitch-control-center/pull/119)) ([`ffc819e`](https://github.com/juspay/hyperswitch-control-center/commit/ffc819ef39c33f7a58e560cd3d1a1e7184ef4eba))

**Full Changelog:** [`v1.12.0...v1.13.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.12.0...v1.13.0)

- - -


## 1.12.0 (2023-12-19)

### Features

- Group-drop-down-component-changes ([#97](https://github.com/juspay/hyperswitch-control-center/pull/97)) ([`adcd89e`](https://github.com/juspay/hyperswitch-control-center/commit/adcd89e58542a7b0e0a7941e8dd4bb8abbd620eb))
- Add scrollbar and white space scrollable ([#111](https://github.com/juspay/hyperswitch-control-center/pull/111)) ([`a3bb4fe`](https://github.com/juspay/hyperswitch-control-center/commit/a3bb4feedb12fc6d3dcbc2cf845e90bb26fef7dd))
- Added path and api method in audit logs ([#112](https://github.com/juspay/hyperswitch-control-center/pull/112)) ([`1005cc7`](https://github.com/juspay/hyperswitch-control-center/commit/1005cc7099bf4ed6d6fdadd9f843c1937b733fe2))

### Bug Fixes

- Oss build url change ([#87](https://github.com/juspay/hyperswitch-control-center/pull/87)) ([`82f5272`](https://github.com/juspay/hyperswitch-control-center/commit/82f5272aff3453afbbc5fcf7b0e3aee4eed32cb2))

**Full Changelog:** [`v1.11.0...v1.12.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.11.0...v1.12.0)

- - -


## 1.11.0 (2023-12-18)

### Features

- Enable apple pay cybersource ([#109](https://github.com/juspay/hyperswitch-control-center/pull/109)) ([`c800865`](https://github.com/juspay/hyperswitch-control-center/commit/c8008650f7b4b426523f6ac30a83afac922cbe1a))

### Refactors

- Dead Code Removal ([#107](https://github.com/juspay/hyperswitch-control-center/pull/107)) ([`5859497`](https://github.com/juspay/hyperswitch-control-center/commit/585949773178633ad022abb443b69c50e884ef86))

**Full Changelog:** [`v1.10.0...v1.11.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.10.0...v1.11.0)

- - -


## 1.10.0 (2023-12-15)

### Features

- Show Details Paymentb Enhancement ([#104](https://github.com/juspay/hyperswitch-control-center/pull/104)) ([`134d470`](https://github.com/juspay/hyperswitch-control-center/commit/134d470ceadef14e02c5ca6b31d1475b25212d0d))

**Full Changelog:** [`v1.9.0...v1.10.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.9.0...v1.10.0)

- - -


## 1.9.0 (2023-12-15)

### Features

- Show Orders Enhancements & sidebar value changes ([#103](https://github.com/juspay/hyperswitch-control-center/pull/103)) ([`a1631f3`](https://github.com/juspay/hyperswitch-control-center/commit/a1631f3b1f3e6021053cae934146ca09368ab333))

### Refactors

- Refactoring key errors ([#98](https://github.com/juspay/hyperswitch-control-center/pull/98)) ([`50b86b9`](https://github.com/juspay/hyperswitch-control-center/commit/50b86b9670ecec63ddc6ed8221e55b9ae593e20a))
- Refactoring key errors ([#100](https://github.com/juspay/hyperswitch-control-center/pull/100)) ([`1ddbe68`](https://github.com/juspay/hyperswitch-control-center/commit/1ddbe6874c93dccee2cfc1d73281ba6ce9008323))

**Full Changelog:** [`v1.8.0...v1.9.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.8.0...v1.9.0)

- - -


## 1.8.0 (2023-12-14)

### Features

- GetDescriptionCategory function added. ([#96](https://github.com/juspay/hyperswitch-control-center/pull/96)) ([`5c32afb`](https://github.com/juspay/hyperswitch-control-center/commit/5c32afbb0257abd44d9937ac7604e972a882ff35))
- Cypress integration ([#39](https://github.com/juspay/hyperswitch-control-center/pull/39)) ([`ca6cacd`](https://github.com/juspay/hyperswitch-control-center/commit/ca6cacdcbd6d2c57898a6bdf21b29d1d36abe374))

**Full Changelog:** [`v1.7.0...v1.8.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.7.0...v1.8.0)

- - -


## 1.7.0 (2023-12-13)

### Features

- Refund enable for Partially Captured Payments ([#94](https://github.com/juspay/hyperswitch-control-center/pull/94)) ([`5634990`](https://github.com/juspay/hyperswitch-control-center/commit/5634990a6c0e5952f65e6c435f546314347acaac))

### Bug Fixes

- Connector label  and profile id default value fix ([#95](https://github.com/juspay/hyperswitch-control-center/pull/95)) ([`9822972`](https://github.com/juspay/hyperswitch-control-center/commit/9822972f9ed6724f365ee36d5d27f14458e1f960))

**Full Changelog:** [`v1.6.0...v1.7.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.6.0...v1.7.0)

- - -


## 1.6.0 (2023-12-12)

### Features

- Identity file changes ([#91](https://github.com/juspay/hyperswitch-control-center/pull/91)) ([`706a414`](https://github.com/juspay/hyperswitch-control-center/commit/706a414e4e3f455ebdc9a0cbf792b240e6f1b384))
- Routing back to Integration Fields if Connector Label already exist. ([#93](https://github.com/juspay/hyperswitch-control-center/pull/93)) ([`ff1b90b`](https://github.com/juspay/hyperswitch-control-center/commit/ff1b90b87f0188d7fca96cf9288465226317df9f))
- Sub steps ([#56](https://github.com/juspay/hyperswitch-control-center/pull/56)) ([`16a3e18`](https://github.com/juspay/hyperswitch-control-center/commit/16a3e1850a658e397dc8f924f1bc07443e73ace5))
- Default id for connector label ([#84](https://github.com/juspay/hyperswitch-control-center/pull/84)) ([`cc09ab5`](https://github.com/juspay/hyperswitch-control-center/commit/cc09ab534f8bc87ae71a117b965a5f1201cc5a35))

### Refactors

- Dead code removal. ([#92](https://github.com/juspay/hyperswitch-control-center/pull/92)) ([`6c3f3cf`](https://github.com/juspay/hyperswitch-control-center/commit/6c3f3cf326c31b3bd2aa8931c169c86238d9ad88))

**Full Changelog:** [`v1.5.0...v1.6.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.5.0...v1.6.0)

- - -


## 1.5.0 (2023-12-11)

### Features

- Refunds search based on refunds id ([#83](https://github.com/juspay/hyperswitch-control-center/pull/83)) ([`f5363b4`](https://github.com/juspay/hyperswitch-control-center/commit/f5363b4ac3547232bd637884bd8a9fad85056608))
- Identity file changes in Codebase. ([#89](https://github.com/juspay/hyperswitch-control-center/pull/89)) ([`9e3aec7`](https://github.com/juspay/hyperswitch-control-center/commit/9e3aec7f7434cf4610db50a716653e73693aec94))
- Webhook Section Update - In Connector Preview ([#90](https://github.com/juspay/hyperswitch-control-center/pull/90)) ([`07a2cf1`](https://github.com/juspay/hyperswitch-control-center/commit/07a2cf1d5f36541e69dcf701c38fce33697f0df0))

### Bug Fixes

- Recoil value for feature flag updated ([#85](https://github.com/juspay/hyperswitch-control-center/pull/85)) ([`d7bb46e`](https://github.com/juspay/hyperswitch-control-center/commit/d7bb46e26c766ab8b43488ff42c6a0ad4eb21864))
- Added configure return url after business profile ([#82](https://github.com/juspay/hyperswitch-control-center/pull/82)) ([`ade63aa`](https://github.com/juspay/hyperswitch-control-center/commit/ade63aa8177d6269e02ac0db4f6e63867511b661))
- SDK Processing - Go to payments not working fix ([#88](https://github.com/juspay/hyperswitch-control-center/pull/88)) ([`f45d8dd`](https://github.com/juspay/hyperswitch-control-center/commit/f45d8dd6016f859b76013364c83c0758e5a42114))

### Refactors

- Common file for all identity functions ([#86](https://github.com/juspay/hyperswitch-control-center/pull/86)) ([`6ad715f`](https://github.com/juspay/hyperswitch-control-center/commit/6ad715fb11da557f4f07ff35e8f616b69684ff0c))

**Full Changelog:** [`v1.4.0...v1.5.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.4.0...v1.5.0)

- - -


## 1.4.0 (2023-12-08)

### Features

- New connector addition Helcim ([#80](https://github.com/juspay/hyperswitch-control-center/pull/80)) ([`0e59c4a`](https://github.com/juspay/hyperswitch-control-center/commit/0e59c4a6e80fe9d03c8f289810f7796e3da23cb1))

### Bug Fixes

- Hide connector sr ([#81](https://github.com/juspay/hyperswitch-control-center/pull/81)) ([`0880fd8`](https://github.com/juspay/hyperswitch-control-center/commit/0880fd8757f46236caff8783eb3154ec88b286c2))

**Full Changelog:** [`v1.3.1...v1.4.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.3.1...v1.4.0)

- - -


## 1.3.1 (2023-12-07)

### Bug Fixes

- Euclid wasm minimum amount ([#78](https://github.com/juspay/hyperswitch-control-center/pull/78)) ([`2f730e0`](https://github.com/juspay/hyperswitch-control-center/commit/2f730e0602e49dd11a8e0790df91941b91e1577b))
- Update wasm file to fix minimum amount ([`ea1b8fe`](https://github.com/juspay/hyperswitch-control-center/commit/ea1b8fefdf83a583d115467e78e10c68b4a1145e))

**Full Changelog:** [`v1.3.0...v1.3.1`](https://github.com/juspay/hyperswitch-control-center/compare/v1.3.0...v1.3.1)

- - -


## 1.3.0 (2023-12-07)

### Features

- Profile id and profile name concat ([#73](https://github.com/juspay/hyperswitch-control-center/pull/73)) ([`8266a95`](https://github.com/juspay/hyperswitch-control-center/commit/8266a95ede73e2b66677d7d1046c4271c8fbd526))
- New connector Icons and  Searchbar for connector ([#46](https://github.com/juspay/hyperswitch-control-center/pull/46)) ([`2717c0d`](https://github.com/juspay/hyperswitch-control-center/commit/2717c0d3f09807022f53929ddd244aed3c28034d))

### Bug Fixes

- Default card layout ([#70](https://github.com/juspay/hyperswitch-control-center/pull/70)) ([`b7690bc`](https://github.com/juspay/hyperswitch-control-center/commit/b7690bc569895ce0d92425314bcfc783f8d3365f))
- Top 5 errors fix ([#60](https://github.com/juspay/hyperswitch-control-center/pull/60)) ([`d5b19d6`](https://github.com/juspay/hyperswitch-control-center/commit/d5b19d67ea6cc7e07153b0bfb58ca4beedf1a594))
- SDK code refactoring and return URL addition ([#72](https://github.com/juspay/hyperswitch-control-center/pull/72)) ([`d77b875`](https://github.com/juspay/hyperswitch-control-center/commit/d77b875b9e1c872985678975d4651f6cc90ac364))
- SDK Go to payment fix in Success Status ([#74](https://github.com/juspay/hyperswitch-control-center/pull/74)) ([`66ea60b`](https://github.com/juspay/hyperswitch-control-center/commit/66ea60b321bdd3efd7980a99e007135f29998951))
- Payment settings added under developers ([#77](https://github.com/juspay/hyperswitch-control-center/pull/77)) ([`592ce41`](https://github.com/juspay/hyperswitch-control-center/commit/592ce413fb529847c1428197f18420e6f2a28d66))

### Miscellaneous Tasks

- Response warnings removed ([#68](https://github.com/juspay/hyperswitch-control-center/pull/68)) ([`7427f10`](https://github.com/juspay/hyperswitch-control-center/commit/7427f1051dc6e88258699a90cef3453f66fe5f98))
- User Management File Changes ([#76](https://github.com/juspay/hyperswitch-control-center/pull/76)) ([`8807933`](https://github.com/juspay/hyperswitch-control-center/commit/8807933a676f8041eab5cbc5b833ed06e17a76eb))

**Full Changelog:** [`v1.2.0...v1.3.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.2.0...v1.3.0)

- - -


## 1.2.0 (2023-12-06)

### Features

- Bankofamerica addition in prod ([#69](https://github.com/juspay/hyperswitch-control-center/pull/69)) ([`bf6bde8`](https://github.com/juspay/hyperswitch-control-center/commit/bf6bde89eaaf3c443e07c191b42d2a9293377130))
- Support oss auth flow ([#64](https://github.com/juspay/hyperswitch-control-center/pull/64)) ([`59601ec`](https://github.com/juspay/hyperswitch-control-center/commit/59601ec4449505ff4fcd1e048d6ced78997062a9))

### Bug Fixes

- 3ds code refactor and bugfixes ([#61](https://github.com/juspay/hyperswitch-control-center/pull/61)) ([`9d4f503`](https://github.com/juspay/hyperswitch-control-center/commit/9d4f5036b458b671f4f1899619d891f74e936b8f))
- Commit-msg file changes & README.md file updated. ([#65](https://github.com/juspay/hyperswitch-control-center/pull/65)) ([`96a81e0`](https://github.com/juspay/hyperswitch-control-center/commit/96a81e0363ade432fb288cc59a5dfb64ad029e48))
- Update README.md ([#66](https://github.com/juspay/hyperswitch-control-center/pull/66)) ([`1930bd2`](https://github.com/juspay/hyperswitch-control-center/commit/1930bd294de22a962304c4389426b741429fd1dc))
- Live Mode SDK Fixes. ([#67](https://github.com/juspay/hyperswitch-control-center/pull/67)) ([`844920b`](https://github.com/juspay/hyperswitch-control-center/commit/844920b6fd09aa07edbf33ba83ff2aaa394c7a78))

**Full Changelog:** [`v1.1.0...v1.2.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.1.0...v1.2.0)

- - -


## 1.1.0 (2023-12-05)

### Features

- Business profile UI changes ([#51](https://github.com/juspay/hyperswitch-control-center/pull/51)) ([`7d2a443`](https://github.com/juspay/hyperswitch-control-center/commit/7d2a4430980539977a8e8ddfd9d959547549258a))

### Bug Fixes

- Warning icon added ([#59](https://github.com/juspay/hyperswitch-control-center/pull/59)) ([`4fbaee4`](https://github.com/juspay/hyperswitch-control-center/commit/4fbaee4bf0b1b65b08513bd9208e49f154911ae0))
- Optional test live mode removal & typo fix ([#63](https://github.com/juspay/hyperswitch-control-center/pull/63)) ([`9466057`](https://github.com/juspay/hyperswitch-control-center/commit/94660575566729f1b6a8013e9d09e1a4bc8cff20))

### Miscellaneous Tasks

- Signed commit added. ([#62](https://github.com/juspay/hyperswitch-control-center/pull/62)) ([`4f69afe`](https://github.com/juspay/hyperswitch-control-center/commit/4f69afe1946bd431fb6e8a31ee621358ff28ad12))
- Cleanup Configs ([#48](https://github.com/juspay/hyperswitch-control-center/pull/48)) ([`5bfae97`](https://github.com/juspay/hyperswitch-control-center/commit/5bfae972ac4cd2f367d26317c203b2c9d425535d))
- Dead code removal ([#55](https://github.com/juspay/hyperswitch-control-center/pull/55)) ([`b220415`](https://github.com/juspay/hyperswitch-control-center/commit/b220415bc390a5129e82e1b59dc6115a35cb6f84))

**Full Changelog:** [`v1.0.5...v1.1.0`](https://github.com/juspay/hyperswitch-control-center/compare/v1.0.5...v1.1.0)

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).
