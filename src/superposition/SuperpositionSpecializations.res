open SuperpositionTypes
open SuperpositionUtils
open LogicUtils
open Typography

module SpecializationRows = {
  @react.component
  let make = (~group: specializationGroup, ~canManage, ~onEdit, ~onRemove) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let count = group.entries->Array.length
    <div className="flex flex-col gap-2 p-4">
      <LoadedTable
        title={`Specializations of ${group.groupRow.key}`}
        hideTitle=true
        actualData={group.entries->Array.map(Nullable.make)}
        totalResults=count
        resultsPerPage=count
        offset
        setOffset
        currentFetchCount=count
        entity={SuperpositionTableEntity.specializationEntity(
          ~columns=SuperpositionTableEntity.specializationColumns,
          ~onEdit,
          ~onRemove,
          ~canManage,
        )}
        showResultsPerPageSelector=false
      />
      <RenderIf condition={count > 1}>
        <span className={`${body.sm.regular} text-nd_gray-500`}>
          {"If more than one condition matches, the one with the higher priority wins."->React.string}
        </span>
      </RenderIf>
    </div>
  }
}

module GroupsTable = {
  @react.component
  let make = (
    ~groups: array<specializationGroup>,
    ~isSearching,
    ~canManage,
    ~onEdit,
    ~onRemove,
  ) => {
    let (expanded, setExpanded) = React.useState(_ => [])
    let toggle = key =>
      setExpanded(prev =>
        prev->Array.includes(key)
          ? prev->Array.filter(item => item != key)
          : prev->Array.concat([key])
      )
    <div className="flex flex-col gap-3">
      {groups
      ->Array.map(group => {
        let key = group.groupRow.key
        let count = group.entries->Array.length
        <SuperpositionHelper.ExpandableSection
          key
          title={<div className="flex flex-col gap-0.5 min-w-0" title=key>
            <span className={`${body.md.semibold} text-nd_gray-700 break-words`}>
              {`${key->getKeyLocation} › ${key->getKeyLabel}`->React.string}
            </span>
            <RenderIf condition={group.groupRow.description->isNonEmptyString}>
              <span className={`${body.sm.regular} text-nd_gray-500 line-clamp-1`}>
                {group.groupRow.description->React.string}
              </span>
            </RenderIf>
          </div>}
          meta={`${count->Int.toString} ${count == 1 ? "specialization" : "specializations"}`}
          isExpanded={isSearching || expanded->Array.includes(key)}
          onToggle={() => toggle(key)}>
          <SpecializationRows group canManage onEdit onRemove />
        </SuperpositionHelper.ExpandableSection>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = () => {
  let {screenState, rows, dimensions, contexts, reload} = SuperpositionHooks.useConfigsPage(
    ~specializations=true,
  )
  let scope = SuperpositionHooks.useScope()
  let canManage = SuperpositionHooks.useCanManageConfigurations()
  let (searchText, setSearchText) = React.useState(_ => "")
  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let (editing, setEditing) = React.useState(_ => None)
  let (removing, setRemoving) = React.useState(_ => None)

  let groups = React.useMemo(
    () => getSpecializationGroups(~rows, ~contexts, ~scope),
    (rows, contexts, scope),
  )
  let filteredGroups = React.useMemo(() => {
    let query = searchText->String.trim->String.toLowerCase
    let matches = text => text->String.toLowerCase->String.includes(query)
    query->isEmptyString
      ? groups
      : groups->Array.filter(({groupRow, entries}) =>
          groupRow.key->matches ||
            entries->Array.some(({spec}) => spec.extraConditions->describeConditions->matches)
        )
  }, (groups, searchText))

  let tabs: array<Tabs.tab> =
    groups
    ->Array.reduce([], (namespaces, group) => {
      let namespace = (group.groupRow.key->getKeyPath).namespace
      namespaces->Array.includes(namespace) ? namespaces : namespaces->Array.concat([namespace])
    })
    ->Array.map((namespace): Tabs.tab => {
      let tabGroups =
        filteredGroups->Array.filter(group =>
          (group.groupRow.key->getKeyPath).namespace == namespace
        )
      {
        title: `${namespace->humanizeKeySegment} (${tabGroups->Array.length->Int.toString})`,
        renderContent: () =>
          <div className="pt-4">
            {tabGroups->isNonEmptyArray
              ? <GroupsTable
                  groups=tabGroups
                  isSearching={searchText->String.trim->isNonEmptyString}
                  canManage
                  onEdit={entry => setEditing(_ => Some(entry))}
                  onRemove={entry => setRemoving(_ => Some(entry))}
                />
              : <NewAnalyticsHelper.NoData height="h-40" message="No keys match." />}
          </div>,
      }
    })

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <PageUtils.PageHeading
        title="Specializations"
        subTitle="Values that apply only when extra conditions match, for example a specific connector."
      />
      <SuperpositionHelper.FixedScope />
      <SuperpositionHelper.HowItWorks
        storageKey="specializations"
        heading="When to create a specialization"
        linkText="When should I create a specialization?">
        <span className={`${body.md.regular} text-nd_gray-600`}>
          {"A custom value applies to everything within the fixed scope. If you want a different value for a specific case, like a particular connector or payment method, create a specialization."->React.string}
        </span>
        <span className={`${body.md.regular} text-nd_gray-600`}>
          {"A specialization lets you override values for specific conditions without changing the default. For example, keep the City label as \"City\" everywhere, but use \"Town\" when the connector is Stripe."->React.string}
        </span>
      </SuperpositionHelper.HowItWorks>
      <div className="flex justify-end">
        <SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search keys or conditions"
          showSearchIcon=true
          widthClass="w-80"
          autoFocus=false
        />
      </div>
      {tabs->isNonEmptyArray
        ? <Tabs
            tabs initialIndex=tabIndex onTitleClick={index => setTabIndex(_ => index)} size=Md
          />
        : <NewAnalyticsHelper.NoData height="h-40" message="No specializations yet." />}
      {switch editing {
      | Some({entryRow, spec}) =>
        <SuperpositionModals.SpecializationModal
          showModal=true
          setShowModal={_ => setEditing(_ => None)}
          heading="Edit specialization"
          rows=[entryRow]
          dimensions
          existingContext=spec.context
          onSaved=reload
        />
      | None => React.null
      }}
      {switch removing {
      | Some(entry) =>
        <SuperpositionModals.RemoveSpecializationModal
          entry onClose={() => setRemoving(_ => None)} onChanged=reload
        />
      | None => React.null
      }}
    </div>
  </PageLoaderWrapper>
}
