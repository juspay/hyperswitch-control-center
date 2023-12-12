open LogicUtils
open LineChartUtils
type nodeConfigs = {
  success_vol_metrix: string,
  total_vol_metrix: string,
}

let numericArraySortComperator = (a, b) => {
  let (_, val1) = a
  let (_, val2) = b
  if val1 < val2 {
    1
  } else if val1 > val2 {
    -1
  } else {
    0
  }
}

let convertToSankeyFormat = (
  ~lastStageAdd,
  ~arr: array<Js.Json.t>,
  ~sankeyConfig: nodeConfigs,
  ~snakeyActiveTab: array<string>,
  ~topN: int,
) => {
  let sankeyArr = []
  let nodeArr = []
  let topNDicts = Js.Dict.empty()
  snakeyActiveTab->Belt.Array.forEach(groupBy => {
    let currentDimsTopN = Js.Dict.empty()
    arr->Belt.Array.forEach(item => {
      let groupByVal = item->getDictFromJsonObject->getString(groupBy, "")
      let groupByVal = groupByVal === "" ? "NA" : groupByVal
      let totalStats = item->getDictFromJsonObject->getInt(sankeyConfig.total_vol_metrix, 0)
      currentDimsTopN->appendToDictValue(groupByVal, totalStats)
    })

    currentDimsTopN
    ->Js.Dict.entries
    ->Js.Array2.map(topN => {
      let (key, value) = topN

      (key, value->AnalyticsUtils.sumOfArr)
    })
    ->Js.Array2.sortInPlaceWith(numericArraySortComperator)
    ->Js.Array2.filteri((_, index) => index < topN)
    ->Belt.Array.forEachWithIndex((_, item) => {
      let (key, _) = item
      topNDicts->appendToDictValue(groupBy, key)
    })
  })

  let lastIndex = snakeyActiveTab->Js.Array2.length - 1

  snakeyActiveTab->Belt.Array.forEachWithIndex((index, item) => {
    let topNMetrix = topNDicts->Js.Dict.get(item)->Belt.Option.getWithDefault([])
    if index === 0 {
      // first index
      let currentSelectedTabDict = Js.Dict.empty()
      arr->Belt.Array.forEach(sankeyData => {
        let sankeyDict = sankeyData->getDictFromJsonObject
        let levelName = sankeyDict->getString(item, "")
        let levelName = levelName === "" ? "NA" : levelName

        let totalVolFromStartToLevel = sankeyDict->getInt(sankeyConfig.total_vol_metrix, 0)
        topNMetrix->Js.Array2.includes(levelName)
          ? currentSelectedTabDict->appendToDictValue(levelName, totalVolFromStartToLevel)
          : currentSelectedTabDict->appendToDictValue("Others", totalVolFromStartToLevel)
      })

      let updatedTotalSum =
        currentSelectedTabDict
        ->Js.Dict.entries
        ->Js.Array2.map(item => {
          let (key, value) = item
          let totalSum = value->AnalyticsUtils.sumOfArr
          (key, totalSum)
        })

      let total_sum =
        updatedTotalSum
        ->Js.Array2.map(item => {
          let (_, value) = item
          value
        })
        ->AnalyticsUtils.sumOfArr

      updatedTotalSum
      ->Js.Array2.sortInPlaceWith(numericArraySortComperator)
      ->Belt.Array.forEach(item => {
        let (key, value) = item
        sankeyArr
        ->Js.Array2.push((
          "Start",
          `${key}( +++ )${snakeyActiveTab[index]->Belt.Option.getWithDefault("")}`,
          value,
          total_sum,
          index,
        ))
        ->ignore

        nodeArr
        ->Js.Array2.push({
          let value: SankeyHighcharts.node = {
            id: `${key}( +++ )${snakeyActiveTab[index]->Belt.Option.getWithDefault("")}`,
            color: "#c59144",
            name: key,
            dataLabels: {"x": 45},
          }
          value
        })
        ->ignore
      })
      nodeArr
      ->Js.Array2.push({
        let value: SankeyHighcharts.node = {
          id: "Start",
          color: "#4097f7",
          name: "Start",
          dataLabels: {"x": 45},
        }
        value
      })
      ->ignore
    } else if lastIndex !== 0 {
      let currentSelectedTabDict = Js.Dict.empty()
      let currentSelectedTabDict1St = Js.Dict.empty()
      // middle index
      let dimsPrev = snakeyActiveTab[index - 1]->Belt.Option.getWithDefault("")
      let dimsCurrent = snakeyActiveTab[index]->Belt.Option.getWithDefault("")
      let topNMetrixCurr = topNDicts->Js.Dict.get(dimsCurrent)->Belt.Option.getWithDefault([])
      let topNMetrixPrev = topNDicts->Js.Dict.get(dimsPrev)->Belt.Option.getWithDefault([])
      arr->Belt.Array.forEach(sankeyData => {
        let sankeyDict = sankeyData->getDictFromJsonObject
        let levelNamePrev = sankeyDict->getString(dimsPrev, "")
        let levelNamePrev = levelNamePrev === "" ? "NA" : levelNamePrev

        let totalVolFromStartToLevel = sankeyDict->getInt(sankeyConfig.total_vol_metrix, 0)
        let levelNamePrev =
          topNMetrixPrev->Js.Array2.includes(levelNamePrev) ? levelNamePrev : "Others"
        currentSelectedTabDict1St->appendToDictValue(levelNamePrev, totalVolFromStartToLevel)
      })
      let currentSelectedTabDict1St =
        currentSelectedTabDict1St
        ->Js.Dict.entries
        ->Js.Array2.map(item => {
          let (key, value) = item
          let totalSum = value->AnalyticsUtils.sumOfArr
          (key, totalSum)
        })
        ->Js.Dict.fromArray

      arr->Belt.Array.forEach(sankeyData => {
        let sankeyDict = sankeyData->getDictFromJsonObject
        let levelNamePrev = sankeyDict->getString(dimsPrev, "")
        let levelNamePrev = levelNamePrev === "" ? "NA" : levelNamePrev
        let levelNameCurrent = sankeyDict->getString(dimsCurrent, "")
        let levelNameCurrent = levelNameCurrent === "" ? "NA" : levelNameCurrent

        let levelNamePrev =
          topNMetrixPrev->Js.Array2.includes(levelNamePrev) ? levelNamePrev : "Others"
        let levelNameCurrent =
          topNMetrixCurr->Js.Array2.includes(levelNameCurrent) ? levelNameCurrent : "Others"
        let totalVolFromStartToLevel = sankeyDict->getInt(sankeyConfig.total_vol_metrix, 0)

        currentSelectedTabDict->appendToDictValue(
          `${levelNamePrev}( +++ )${levelNameCurrent}`,
          totalVolFromStartToLevel,
        )
      })
      //
      currentSelectedTabDict
      ->Js.Dict.entries
      ->Js.Array2.map(item => {
        let (key, value) = item
        let totalSum = value->AnalyticsUtils.sumOfArr
        (key, totalSum)
      })
      ->Js.Array2.sortInPlaceWith(numericArraySortComperator)
      ->Belt.Array.forEach(item => {
        let (key, totalSum) = item

        let keyArr = key->Js.String2.split("( +++ )")

        let prevLevel = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let prevLevel = prevLevel === "" ? "NA" : prevLevel
        let currentLevel = keyArr->Belt.Array.get(1)->Belt.Option.getWithDefault("")
        let currentLevel = currentLevel === "" ? "NA" : currentLevel
        sankeyArr
        ->Js.Array2.push((
          `${prevLevel}( +++ )${dimsPrev}`,
          `${currentLevel}( +++ )${dimsCurrent}`,
          totalSum,
          currentSelectedTabDict1St
          ->Js.Dict.get(keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault(""))
          ->Belt.Option.getWithDefault(0),
          index,
        ))
        ->ignore

        nodeArr
        ->Js.Array2.push({
          let value: SankeyHighcharts.node = {
            id: `${prevLevel}( +++ )${dimsPrev}`,
            color: "#c59144",
            name: prevLevel,
            dataLabels: {"x": 45},
          }
          value
        })
        ->ignore

        nodeArr
        ->Js.Array2.push({
          let value: SankeyHighcharts.node = {
            id: `${currentLevel}( +++ )${dimsCurrent}`,
            color: "#c59144",
            name: currentLevel,
            dataLabels: {"x": 45},
          }
          value
        })
        ->ignore
      })
    } else {
      ()
    }
    if index === lastIndex && lastStageAdd {
      let currentSelectedTabDictlast = Js.Dict.empty()
      let topNMetrixCurr =
        topNDicts
        ->Js.Dict.get(snakeyActiveTab[lastIndex]->Belt.Option.getWithDefault(""))
        ->Belt.Option.getWithDefault([])
      arr->Belt.Array.forEach(sankeyData => {
        let sankeyDict = sankeyData->getDictFromJsonObject
        let levelName =
          sankeyDict->getString(snakeyActiveTab[lastIndex]->Belt.Option.getWithDefault(""), "")
        let levelName = levelName === "" ? "NA" : levelName
        let totalVolFromStartToLevel = sankeyDict->getInt(sankeyConfig.total_vol_metrix, 0)
        let successVol = sankeyDict->getInt(sankeyConfig.success_vol_metrix, 0)
        let levelName = topNMetrixCurr->Js.Array2.includes(levelName) ? levelName : "Others"
        currentSelectedTabDictlast->appendToDictValue(
          levelName,
          (totalVolFromStartToLevel, successVol),
        )
      })

      currentSelectedTabDictlast
      ->Js.Dict.entries
      ->Js.Array2.map(item => {
        let (key, value) = item

        let totalSum =
          value
          ->Js.Array2.map(
            item => {
              let (totalVolume, _) = item
              totalVolume
            },
          )
          ->AnalyticsUtils.sumOfArr
        let successSum =
          value
          ->Js.Array2.map(
            item => {
              let (_, successVolume) = item
              successVolume
            },
          )
          ->AnalyticsUtils.sumOfArr

        (key, (totalSum, successSum))
      })
      ->Js.Array2.sortInPlaceWith(numericArraySortComperator)
      ->Belt.Array.forEach(item => {
        let (key, twoSUms) = item
        let (totalSum, successSum) = twoSUms
        sankeyArr
        ->Js.Array2.push((
          `${key}( +++ )${snakeyActiveTab[index]->Belt.Option.getWithDefault("")}`,
          "Success",
          successSum,
          totalSum,
          lastIndex + 1,
        ))
        ->ignore
        sankeyArr
        ->Js.Array2.push((
          `${key}( +++ )${snakeyActiveTab[index]->Belt.Option.getWithDefault("")}`,
          "Failure",
          totalSum - successSum,
          totalSum,
          lastIndex + 1,
        ))
        ->ignore

        nodeArr
        ->Js.Array2.push({
          let value: SankeyHighcharts.node = {
            id: `${key}( +++ )${snakeyActiveTab[index]->Belt.Option.getWithDefault("")}`,
            color: "#c59144",
            name: key,
            dataLabels: {"x": 45},
          }
          value
        })
        ->ignore
      })
    }
  })

  (sankeyArr, nodeArr)
}
