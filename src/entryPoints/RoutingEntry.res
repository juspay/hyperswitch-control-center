module HyperSwitchEntryComponent = {
  open HyperswitchAtom
  @react.component
  let make = () => {
    open HyperSwitchEntryUtils
    let fetchDetails = APIUtils.useGetMethod()
    let url = RescriptReactRouter.useUrl()
    let (_zone, setZone) = React.useContext(UserTimeZoneProvider.userTimeContext)
    let setFeatureFlag = featureFlagAtom->Recoil.useSetRecoilState
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (userGroupACL, setuserGroupACL) = Recoil.useRecoilState(userGroupACLAtom)

    let configEnv = (urlConfig: JSON.t) => {
      open LogicUtils
      open HyperSwitchConfigTypes
      try {
        let dict = urlConfig->getDictFromJsonObject->getDictfromDict("endpoints")
        let value: urlConfig = {
          apiBaseUrl: dict->getString("api_url", ""),
          mixpanelToken: dict->getString("mixpanel_token", ""),
          sdkBaseUrl: dict->getString("sdk_url", "")->getNonEmptyString,
          agreementUrl: dict->getString("agreement_url", "")->getNonEmptyString,
          dssCertificateUrl: dict->getString("dss_certificate_url", "")->getNonEmptyString,
          applePayCertificateUrl: dict
          ->getString("apple_pay_certificate_url", "")
          ->getNonEmptyString,
          agreementVersion: dict->getString("agreement_version", "")->getNonEmptyString,
          reconIframeUrl: dict->getString("recon_iframe_url", "")->getNonEmptyString,
          urlThemeConfig: {
            faviconUrl: dict->getString("favicon_url", "")->getNonEmptyString,
            logoUrl: dict->getString("logo_url", "")->getNonEmptyString,
          },
          hypersenseUrl: dict->getString("hypersense_url", ""),
        }
        DOMUtils.window._env_ = value
      } catch {
      | _ => Exn.raiseError("Error on configuring endpoint")
      }
    }

    let fetchThemeAndDomainFromUrl = () => {
      let params = url.search->LogicUtils.getDictFromUrlSearchParams
      let themeID = params->Dict.get("theme_id")
      let domainUrl = params->Dict.get("domain")

      if themeID->Option.isSome {
        setThemeIdtoStore(themeID->Option.getOr(""))
      }

      if domainUrl->Option.isSome {
        setDomaintoStore(domainUrl->Option.getOr(""))
      }
      let themeId = getThemeIdfromStore()
      (themeId, domainUrl)
    }

    let fetchConfig = async () => {
      try {
        let (_, domain) = fetchThemeAndDomainFromUrl()
        let apiURL = `${GlobalVars.getHostUrlWithBasePath}/config/feature?domain=${domain->Option.getOr(
            "",
          )}` // todo: domain shall be removed from query params later
        let res = await fetchDetails(apiURL)
        let featureFlags = res->FeatureFlagUtils.featureFlagType
        setFeatureFlag(_ => featureFlags)
        let _ = configEnv(res) // to set initial env

        // Delay added on Expecting feature flag recoil gets updated
        await HyperSwitchUtils.delay(1000)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => Custom)
      }
    }

    React.useEffect(() => {
      let _ = setSessionData(~key="auth_id", ~searchParams=url.search)
      let _ = fetchConfig()->ignore
      None
    }, [])

    React.useEffect(() => {
      TimeZoneUtils.getUserTimeZone()->setZone
      None
    }, [])

    let updateAccessControl = () => {
      open GroupACLMapper
      open LogicUtils

      let response = {
        "groups": [
          "recon_ops_manage",
          "account_manage",
          "account_view",
          "merchant_details_manage",
          "recon_reports_view",
          "recon_ops_view",
          "analytics_view",
          "merchant_details_view",
          "connectors_view",
          "connectors_manage",
          "organization_manage",
          "recon_reports_manage",
          "workflows_view",
          "users_manage",
          "operations_manage",
          "workflows_manage",
          "operations_view",
          "users_view",
        ],
        "resources": [
          "recon_reports",
          "run_recon",
          "routing",
          "recon_config",
          "connector",
          "payout",
          "revenue_recovery",
          "dispute",
          "analytics",
          "account",
          "recon_upload",
          "recon_and_settlement_analytics",
          "recon_files",
          "report",
          "surcharge_decision_manager",
          "user",
          "customer",
          "api_key",
          "recon_token",
          "payment",
          "mandate",
          "three_ds_decision_manager",
          "refund",
          "webhook_event",
        ],
      }->Identity.genericTypeToJson

      let dict = response->getDictFromJsonObject

      let groupsAccessValue = getStrArrayFromDict(dict, "groups", [])

      let resourcesAccessValue = getStrArrayFromDict(dict, "resources", [])
      let userGroupACLMap =
        groupsAccessValue->Array.map(ele => ele->mapStringToGroupAccessType)->convertValueToMapGroup
      let resourceACLMap =
        resourcesAccessValue
        ->Array.map(ele => ele->mapStringToResourceAccessType)
        ->convertValueToMapResources

      setuserGroupACL(_ => Some({
        groups: userGroupACLMap,
        resources: resourceACLMap,
      }))
    }

    React.useEffect(() => {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
      updateAccessControl()
      None
    }, [])

    <PageLoaderWrapper
      screenState
      sectionHeight="h-screen"
      customUI={<NoDataFound message="Oops! Missing config" renderType=NotFound />}>
      <div className="text-black h-screen overflow-scroll ">
        <AuthInfoProvider>
          <AuthWrapper>
            <ConnectorContainer />
          </AuthWrapper>
        </AuthInfoProvider>
      </div>
    </PageLoaderWrapper>
  }
}

let uiConfig: UIConfig.t = HyperSwitchDefaultConfig.config
EntryPointUtils.renderDashboardApp(<HyperSwitchEntryComponent />)
