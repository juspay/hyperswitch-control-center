type ompTypeHook = {
  isCurrentMerchantPlatform: bool,
  isCurrentOrganizationPlatform: bool,
  isPlatformOrganization: string => bool,
  isPlatformMerchant: string => bool,
}

let useOMPType = () => {
  let {merchant_account_type} = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  )
  let {organization_type} = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.organizationDetailsValueAtom,
  )
  let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)

  let isCurrentMerchantPlatform = switch merchant_account_type {
  | #platform => true
  | _ => false
  }

  let isCurrentOrganizationPlatform = switch organization_type {
  | #platform => true
  | _ => false
  }

  let isPlatformOrganization = id => {
    let org = orgList->Array.find(org => org.id == id)
    switch org {
    | Some(org) => org.\"type"->Option.getOr(#standard) == #platform
    | None => false
    }
  }

  let isPlatformMerchant = id => {
    let merchant = merchantList->Array.find(merchant => merchant.id == id)
    switch merchant {
    | Some(merchant) => merchant.\"type"->Option.getOr(#standard) == #platform
    | None => false
    }
  }

  {
    isCurrentMerchantPlatform,
    isCurrentOrganizationPlatform,
    isPlatformMerchant,
    isPlatformOrganization,
  }
}
