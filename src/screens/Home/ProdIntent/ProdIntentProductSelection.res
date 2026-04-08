open ProductTypes

type productSelectionItem = {
  product: productTypes,
  name: string,
  icon: string,
  description: string,
}

let availableProducts = [
  {
    product: Orchestration(V1),
    name: "Orchestration",
    icon: "orchestrator-home",
    description: "Payment orchestration platform",
  },
  {
    product: Recon(V1),
    name: "Reconciliation",
    icon: "recon-home",
    description: "Automated reconciliation",
  },
  {
    product: Recovery,
    name: "Revenue Recovery",
    icon: "recovery-home",
    description: "Failed payment recovery",
  },
  {
    product: CostObservability,
    name: "Cost Observability",
    icon: "nd-piggy-bank",
    description: "Payment cost analytics",
  },
]

module ProductCard = {
  @react.component
  let make = (
    ~product: productSelectionItem,
    ~isSelected: bool,
    ~isDisabled: bool,
    ~onToggle: unit => unit,
  ) => {
    let baseClasses = "flex flex-col gap-3 p-4 rounded-lg border-2 cursor-pointer transition-all duration-200"
    let stateClasses = if isDisabled {
      "border-nd_gray-200 bg-nd_gray-50 cursor-not-allowed opacity-60"
    } else if isSelected {
      "border-nd_blue-500 bg-nd_blue-50 hover:border-nd_blue-600"
    } else {
      "border-nd_gray-200 bg-white hover:border-nd_gray-300 hover:bg-nd_gray-50"
    }

    <div
      className={`${baseClasses} ${stateClasses}`}
      onClick={_ => {
        if !isDisabled {
          onToggle()
        }
      }}>
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Icon name={product.icon} size=24 />
          <span className="font-semibold text-nd_gray-700"> {product.name->React.string} </span>
        </div>
        <div
          className={`w-5 h-5 rounded border-2 flex items-center justify-center ${
            isSelected ? "bg-nd_blue-500 border-nd_blue-500" : "border-nd_gray-300 bg-white"
          }`}>
          <RenderIf condition={isSelected}>
            <Icon name="check" size=14 customIconColor="text-white" />
          </RenderIf>
        </div>
      </div>
      <p className="text-sm text-nd_gray-500"> {product.description->React.string} </p>
    </div>
  }
}

@react.component
let make = (~selectedProducts: array<productTypes>, ~onProductToggle: productTypes => unit) => {
  <div className="flex flex-col gap-4">
    <div className="flex flex-col gap-1">
      <span className="text-sm font-medium text-nd_gray-700">
        {"Select Products"->React.string}
      </span>
      <span className="text-xs text-nd_gray-500">
        {"Choose the products you want production access for"->React.string}
      </span>
    </div>
    <div className="grid grid-cols-2 gap-3">
      {availableProducts
      ->Array.map(product => {
        let isSelected = selectedProducts->Array.some(p => p == product.product)
        let isDisabled = product.product == Orchestration(V1)

        <ProductCard
          key={product.name}
          product
          isSelected
          isDisabled
          onToggle={() => onProductToggle(product.product)}
        />
      })
      ->React.array}
    </div>
  </div>
}
