open SuperpositionTypes
open SuperpositionUtils
open SuperpositionHelper
open LogicUtils
open Typography

type modalState =
  | Closed
  | EditRow(configRow)
  | BulkCustomize(array<configRow>)
  | BulkSpecialize(array<configRow>)
  | ResetRow(configRow)
  | ExplainRow(configRow)

module BulkActionBar = {
  @react.component
  let make = (~count, ~onClear, ~onCustomize, ~onSpecialize, ~canManage) => {
    <div
      className="sticky bottom-4 z-10 flex items-center justify-between gap-4 border border-nd_primary_blue-200 bg-nd_primary_blue-50 rounded-lg px-4 py-2 shadow-sm">
      <span className={`${body.md.semibold} text-nd_gray-700`}>
        {`${count->Int.toString} ${count == 1 ? "key" : "keys"} selected`->React.string}
      </span>
      <div className="flex items-center gap-3">
        <Button
          text="Clear" buttonType=Secondary onClick={_ => onClear()} customButtonStyle="!w-fit"
        />
        <Button
          text="Customize"
          buttonType=Secondary
          buttonState={canManage ? Normal : Disabled}
          onClick={_ => onCustomize()}
          customButtonStyle="!w-fit"
        />
        <Button
          text="Add specialization"
          buttonType=Primary
          buttonState={canManage ? Normal : Disabled}
          onClick={_ => onSpecialize()}
          customButtonStyle="!w-fit"
        />
      </div>
    </div>
  }
}

module StatusFilter = {
  @react.component
  let make = (~rows: array<configRow>, ~selected, ~setSelected) => {
    let count = status => rows->Array.filter(row => row->getValueStatus == status)->Array.length
    let options: array<SelectBox.dropdownOption> = [
      (
        {
          label: `All features (${rows->Array.length->Int.toString})`,
          value: "all",
        }: SelectBox.dropdownOption
      ),
      ...valueStatuses->Array.map((status): SelectBox.dropdownOption => {
        label: `${status->getValueStatusLabel} (${status->count->Int.toString})`,
        value: status->getValueStatusLabel,
      }),
    ]
    let selectedValue = selected->Option.mapOr("all", getValueStatusLabel)
    <div className="w-56">
      <SingleSelectWrapper
        items={options->SingleSelectWrapper.makeItems(~selectedValue)}
        placeholder="Status"
        input={makeInput(
          ~name="status-filter",
          ~value=selectedValue->JSON.Encode.string,
          ~onChange=ev => {
            let value = ev->Identity.formReactEventToString
            setSelected(_ =>
              valueStatuses->Array.find(status => status->getValueStatusLabel == value)
            )
          },
        )}
        fullWidth=true
      />
    </div>
  }
}

module KeysTable = {
  @react.component
  let make = (
    ~title,
    ~rows: array<configRow>,
    ~selectedKeys,
    ~setSelectedKeys,
    ~entity,
    ~canManage,
  ) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let count = rows->Array.length
    let rowKeys = rows->Array.map(row => row.key)
    let selectedData =
      rows
      ->Array.filter(row => selectedKeys->Array.includes(row.key))
      ->Array.map(Identity.genericTypeToJson)
    let setSelectedData = update => {
      let nextKeys =
        update(selectedData)->Array.map(json => (json->Identity.jsonToAnyType: configRow).key)
      setSelectedKeys(prev =>
        prev->Array.filter(key => !(rowKeys->Array.includes(key)))->Array.concat(nextKeys)
      )
    }
    <LoadedTable
      title
      hideTitle=true
      actualData={rows->Array.map(Nullable.make)}
      totalResults=count
      resultsPerPage=20
      offset
      setOffset
      currentFetchCount=count
      entity
      checkBoxProps={{showCheckBox: canManage, selectedData, setSelectedData}}
      // Just the checkbox and its cell padding, so the names sit close to it. The header's
      // select-all checkbox carries an extra margin, so its right padding goes.
      checkBoxColumnWidth="!w-20 !pr-0"
      showResultsPerPageSelector=false
    />
  }
}

@send external scrollBy: (Dom.element, {"left": int, "behavior": string}) => unit = "scrollBy"

module SegmentPills = {
  @react.component
  let make = (~tabs: array<segmentTab>, ~selected, ~onSelect) => {
    let scrollRef = React.useRef(Nullable.null)
    let scroll = left =>
      scrollRef.current
      ->Nullable.toOption
      ->Option.forEach(el => el->scrollBy({"left": left, "behavior": "smooth"}))
    let arrow = (~icon, ~left) =>
      <div
        className="shrink-0 flex items-center justify-center h-8 w-8 rounded-lg border border-nd_gray-150 cursor-pointer text-nd_gray-500 hover:bg-nd_gray-50"
        onClick={_ => scroll(left)}>
        <Icon name=icon size=12 />
      </div>
    <div className="flex items-center gap-2 border border-nd_gray-150 rounded-xl p-2">
      {arrow(~icon="chevron-left", ~left=-240)}
      <div
        ref={scrollRef->ReactDOM.Ref.domRef}
        className="flex items-center gap-2 overflow-x-auto no-scrollbar flex-1 py-1 px-0.5">
        {tabs
        ->Array.map(tab =>
          <div key=tab.label className="shrink-0">
            <Button
              text={`${tab.label} (${tab.tabRows->Array.length->Int.toString})`}
              buttonType={selected == Some(tab.label) ? Primary : Secondary}
              buttonSize=Small
              onClick={_ => onSelect(tab.label)}
              customButtonStyle="!w-fit"
              disableRipple=true
            />
          </div>
        )
        ->React.array}
      </div>
      {arrow(~icon="chevron-right", ~left=240)}
    </div>
  }
}

let rec followPath = (rows, ~depth, path) =>
  switch path {
  | list{label, ...rest} => {
      let (_, tabs) = rows->getSegmentTabs(~depth)
      switch tabs->Array.find(tab => tab.label == label) {
      | Some(tab) => list{(tabs, tab), ...followPath(tab.tabRows, ~depth=tab.depth, rest)}
      | None => list{}
      }
    }
  | list{} => list{}
  }

let rec getFirstPath = (rows, ~depth) =>
  switch rows->getSegmentTabs(~depth) {
  | ([], tabs) =>
    switch tabs->Array.get(0) {
    | Some(first) => list{first.label, ...getFirstPath(first.tabRows, ~depth=first.depth)}
    | None => list{}
    }
  | _ => list{}
  }

let rec getSingleChildPath = (rows, ~depth) =>
  switch rows->getSegmentTabs(~depth) {
  | ([], [only]) => list{only.label, ...getSingleChildPath(only.tabRows, ~depth=only.depth)}
  | _ => list{}
  }

module SegmentNav = {
  @react.component
  let make = (
    ~title,
    ~rows: array<configRow>,
    ~selectedKeys,
    ~setSelectedKeys,
    ~makeEntity,
    ~canManage,
  ) => {
    let (path, setPath) = React.useState(_ => None)
    let (levels, current, childTabs) = React.useMemo(() => {
      let levels =
        rows->followPath(~depth=0, path->Option.getOr(rows->getFirstPath(~depth=0)))->List.toArray
      let current = levels->Array.at(-1)->Option.map(((_, tab)) => tab)
      let (_, childTabs) =
        current
        ->Option.mapOr(rows, tab => tab.tabRows)
        ->getSegmentTabs(~depth=current->Option.mapOr(0, tab => tab.depth))
      (levels, current, childTabs)
    }, (rows, path))
    let chosenPath = levels->Array.map(((_, tab)) => tab.label)
    let currentRows = current->Option.mapOr(rows, tab => tab.tabRows)
    let currentDepth = current->Option.mapOr(0, tab => tab.depth)
    let goTo = labels => setPath(_ => Some(labels->List.fromArray))
    let choose = (~index, ~tabs: array<segmentTab>, label) =>
      switch tabs->Array.find(tab => tab.label == label) {
      | Some(tab) =>
        goTo(
          [
            ...chosenPath->Array.slice(~start=0, ~end=index),
            label,
            ...tab.tabRows->getSingleChildPath(~depth=tab.depth)->List.toArray,
          ],
        )
      | None => ()
      }

    let choiceIndex =
      levels->Array.reduceWithIndex(-1, (found, (tabs, _), index) =>
        tabs->Array.length > 1 ? index : found
      )
    let (pills, selectedPill, onSelectPill) = switch (childTabs, levels->Array.get(choiceIndex)) {
    | ([], Some((tabs, tab))) => (tabs, Some(tab.label), choose(~index=choiceIndex, ~tabs, ...))
    | _ => (childTabs, None, choose(~index=chosenPath->Array.length, ~tabs=childTabs, ...))
    }

    let crumb = (~label, ~count, ~isLast, ~onClick) =>
      <span
        className={`${body.md.medium} ${isLast
            ? "text-nd_primary_blue-500"
            : "text-nd_gray-500 cursor-pointer hover:text-nd_gray-700"}`}
        onClick={_ => isLast ? () : onClick()}>
        {`${label} (${count->Int.toString})`->React.string}
      </span>
    let count = currentRows->Array.length

    <div className="flex flex-col gap-4">
      <div className="flex flex-wrap items-center gap-2">
        {crumb(~label="All", ~count=rows->Array.length, ~isLast=levels->isEmptyArray, ~onClick=() =>
          goTo([])
        )}
        {levels
        ->Array.mapWithIndex(((_, tab), index) =>
          <React.Fragment key={index->Int.toString}>
            <Icon name="chevron-right" size=10 className="text-nd_gray-400" />
            {crumb(
              ~label=tab.label,
              ~count=tab.tabRows->Array.length,
              ~isLast=index == levels->Array.length - 1,
              ~onClick=() => goTo(chosenPath->Array.slice(~start=0, ~end=index + 1)),
            )}
          </React.Fragment>
        )
        ->React.array}
      </div>
      <RenderIf condition={pills->isNonEmptyArray}>
        <SegmentPills tabs=pills selected=selectedPill onSelect=onSelectPill />
      </RenderIf>
      <div className="flex flex-col border border-nd_gray-150 rounded-xl overflow-hidden">
        <div
          className="flex items-center gap-3 px-5 py-3 bg-nd_gray-25 border-b border-nd_gray-150">
          <span className={`${body.lg.semibold} text-nd_gray-800`}>
            {current->Option.mapOr(title, tab => tab.label)->React.string}
          </span>
          <span className="h-4 w-px bg-nd_gray-200" />
          <span className={`${body.md.regular} text-nd_gray-500`}>
            {`${count->Int.toString} ${count == 1 ? "key" : "keys"}`->React.string}
          </span>
        </div>
        {count > 0
          ? <KeysTable
              title={[title, ...chosenPath]->Array.joinWith(" › ")}
              rows=currentRows
              selectedKeys
              setSelectedKeys
              entity={makeEntity(~labelDepth=currentDepth)}
              canManage
            />
          : <NewAnalyticsHelper.NoData height="h-40" message="No keys match." />}
      </div>
    </div>
  }
}

module OwnershipSection = {
  @react.component
  let make = (
    ~ownership,
    ~rows: array<configRow>,
    ~selectedKeys,
    ~setSelectedKeys,
    ~makeEntity,
    ~canManage,
  ) => {
    let (statusFilter, setStatusFilter) = React.useState(_ => None)
    let isOwned = ownership == Owned

    let visibleRows = switch statusFilter {
    | Some(status) => rows->Array.filter(row => row->getValueStatus == status)
    | None => rows
    }

    <div className="flex flex-col gap-4 pt-4">
      <div className="flex items-center justify-between gap-4">
        <span className={`${body.md.regular} text-nd_gray-500`}>
          {(
            isOwned
              ? "Features that belong only to this account. You set them directly."
              : "Features set by the platform for every profile. Edit one to give this profile a custom value."
          )->React.string}
        </span>
        <RenderIf condition={!isOwned}>
          <StatusFilter rows selected=statusFilter setSelected=setStatusFilter />
        </RenderIf>
      </div>
      {rows->isNonEmptyArray
        ? <SegmentNav
            title={isOwned ? "Owned" : "Customizable"}
            rows=visibleRows
            selectedKeys
            setSelectedKeys
            makeEntity
            canManage
          />
        : <NewAnalyticsHelper.NoData
            height="h-40" message={isOwned ? "No owned features." : "No customizable features."}
          />}
    </div>
  }
}

@react.component
let make = () => {
  let {screenState, rows, dimensions, contexts, reload} = SuperpositionHooks.useConfigsPage()
  let canManage = SuperpositionHooks.useCanManageConfigurations()
  let api = SuperpositionHooks.useSuperpositionApi()
  let showToast = ToastAdapter.useShowToast()
  let (sectionIndex, setSectionIndex) = React.useState(_ => 0)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (selectedKeys, setSelectedKeys) = React.useState(_ => [])
  let (modalState, setModalState) = React.useState(_ => Closed)
  let closeModal = () => setModalState(_ => Closed)

  let searchedRows = React.useMemo(() => {
    let query = searchText->String.trim->String.toLowerCase
    let matches = text => text->String.toLowerCase->String.includes(query)
    query->isEmptyString
      ? rows
      : rows->Array.filter(row =>
          row.key->matches ||
          row.key->getKeyLabel->matches ||
          row.key->getKeyLocation->matches ||
          row.description->matches
        )
  }, (rows, searchText))
  let selectedRows = rows->Array.filter(row => selectedKeys->Array.includes(row.key))
  let afterBulkSave = () => {
    setSelectedKeys(_ => [])
    reload()
  }

  let makeEntity = (~columns, ~labelDepth) =>
    SuperpositionTableEntity.configEntity(
      ~columns,
      ~labelDepth,
      ~onEdit=row => setModalState(_ => EditRow(row)),
      ~onReset=row => setModalState(_ => ResetRow(row)),
      ~onExplain=row => setModalState(_ => ExplainRow(row)),
      ~canManage,
    )

  let section = (~ownership) => {
    let sectionRows = searchedRows->Array.filter(row => row.ownership == ownership)
    (
      sectionRows->Array.length,
      <OwnershipSection
        ownership
        rows=sectionRows
        selectedKeys
        setSelectedKeys
        makeEntity={(~labelDepth) =>
          makeEntity(
            ~columns=ownership == Owned
              ? SuperpositionTableEntity.ownedColumns
              : SuperpositionTableEntity.customizableColumns,
            ~labelDepth,
          )}
        canManage
      />,
    )
  }
  let (customizableCount, customizableSection) = section(~ownership=Managed)
  let (ownedCount, ownedSection) = section(~ownership=Owned)
  let sections: array<Tabs.tab> = [
    {
      title: `Customizable (${customizableCount->Int.toString})`,
      renderContent: () => customizableSection,
    },
    {title: `Owned (${ownedCount->Int.toString})`, renderContent: () => ownedSection},
  ]

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-4">
      <PageUtils.PageHeading
        title="Features" subTitle="Feature values that apply to this profile."
      />
      <FixedScope />
      <HowItWorks
        storageKey="features"
        heading="How feature values work"
        linkText="How do feature values work?">
        <div className="flex flex-col gap-2">
          <Term term="Customizable">
            {"Set by the platform for every profile. Keep the platform's value or give this profile it's own custom value."->React.string}
          </Term>
          <Term term="Owned">
            {"Belongs only to this account. Nothing above sets them, so you can set them directly."->React.string}
          </Term>
          <Term term="Status">
            {"Default means nobody changed it. Updated means your organization or provider changed it. Custom means it was set for this profile or by this profile. You can reset it to go back to the previous level."->React.string}
          </Term>
          <Term term="Specialization">
            {"Use one when part of this profile needs a different value. It adds dimensions below the fixed scope, such as connector or payment method, so you control the values further down. Select keys, then Add specialization."->React.string}
          </Term>
        </div>
        <span className={`${body.sm.regular} text-nd_gray-500`}>
          {"The most specific value wins: Default, then Updated, then Custom, then a specialization whose conditions match."->React.string}
        </span>
      </HowItWorks>
      <div className="flex justify-end">
        <SearchInput
          inputText=searchText
          onChange={value => setSearchText(_ => value)}
          placeholder="Search all keys"
          showSearchIcon=true
          widthClass="w-80"
          autoFocus=false
        />
      </div>
      <Tabs
        tabs=sections
        initialIndex=sectionIndex
        onTitleClick={index => setSectionIndex(_ => index)}
        size=Md
      />
      <RenderIf condition={selectedRows->isNonEmptyArray}>
        <BulkActionBar
          count={selectedRows->Array.length}
          onClear={() => setSelectedKeys(_ => [])}
          onCustomize={() => setModalState(_ => BulkCustomize(selectedRows))}
          onSpecialize={() => setModalState(_ => BulkSpecialize(selectedRows))}
          canManage
        />
      </RenderIf>
      {switch modalState {
      | Closed => React.null
      | EditRow(row) =>
        <SuperpositionModals.SpecializationModal
          showModal=true
          setShowModal={_ => closeModal()}
          heading="Edit value"
          description={`Sets ${row.key->getKeyLabel} for this profile. Saving makes it a custom value.`}
          rows=[row]
          dimensions
          allowConditions=false
          saveText="Save"
          onSaved=reload
        />
      | BulkCustomize(selected) =>
        <SuperpositionModals.SpecializationModal
          showModal=true
          setShowModal={_ => closeModal()}
          heading="Customize"
          description="Sets these keys for this profile. The scope is fixed; add a specialization to narrow it."
          rows=selected
          dimensions
          allowConditions=false
          saveText="Save custom values"
          onSaved=afterBulkSave
        />
      | BulkSpecialize(selected) =>
        <SuperpositionModals.SpecializationModal
          showModal=true
          setShowModal={_ => closeModal()}
          heading="Add specialization"
          description="Sets these keys for this profile only when the conditions match."
          rows=selected
          dimensions
          requireConditions=true
          saveText="Add specialization"
          onSaved=afterBulkSave
        />
      | ResetRow(row) =>
        switch row.thisLevelContext {
        | Some(context) => {
            let resetStatus = row->getResetStatus->getValueStatusLabel
            <SuperpositionModals.ReasonModal
              heading="Revert custom value"
              description={`${row.key->getKeyLabel} will go back to its ${resetStatus->String.toLowerCase} value.`}
              confirmText="Revert"
              onClose=closeModal
              onConfirm={async changeReason => {
                await api.removeKeys(~context, ~keys=[row.key], ~changeReason)
                showToast(
                  ~message=`Now using the ${resetStatus->String.toLowerCase} value`,
                  ~toastType=ToastSuccess,
                )
                closeModal()
                reload()
              }}>
              <div className="flex flex-col gap-3">
                <SectionLabel
                  label="How this value is resolved"
                  hint="Reverting removes the last step, set at this level."
                />
                <SuperpositionModals.ExplainTimeline row contexts />
              </div>
              <div className="grid grid-cols-2 gap-4 border border-nd_gray-150 rounded-lg p-4">
                <div className="flex flex-col gap-1">
                  <SectionLabel label="Current value" />
                  <ValueText value=row.value />
                </div>
                <div className="flex flex-col gap-1">
                  <SectionLabel label={`After revert (${resetStatus})`} />
                  <ValueText value=row.inheritedValue />
                </div>
              </div>
            </SuperpositionModals.ReasonModal>
          }
        | None => React.null
        }
      | ExplainRow(row) =>
        <SuperpositionModals.ExplainModal
          showModal=true setShowModal={_ => closeModal()} row contexts
        />
      }}
    </div>
  </PageLoaderWrapper>
}
