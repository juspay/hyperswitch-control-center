open ProductTypes

type productSelection = {
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
    ~product: productSelection,
    ~isSelected: bool,
    ~isDisabled: bool,
    ~onToggle: unit => unit,
  ) => {
    let baseClasses = "flex flex-col gap-2 p-4 rounded-lg border-2 cursor-pointer transition-all duration-200"
    let stateClasses = if isDisabled {
      "border-nd_gray-200 bg-nd_gray-50 cursor-not-allowed opacity-60"
    } else if isSelected {
      "border-nd_blue-500 bg-nd_blue-50"
    } else {
      "border-nd_gray-200 hover:border-nd_gray-300 bg-white"
    }

    <div
      className={`${baseClasses} ${stateClasses}`}
      onClick={_ => {
        if !isDisabled {
          onToggle()
        }
      }}>
      <div className="flex items-center gap-2">
        <Icon name={product.icon} size=24 />
        <span className="font-semibold text-sm text-nd_gray-700"> {product.name->React.string} </span>
        <RenderIf condition={isSelected}>
          <div className="ml-auto">
            <Icon name="nd-check" size=16 customIconColor="text-nd_blue-500" />
          </div>
        </RenderIf>
      </div>
      <p className="text-xs text-nd_gray-500 leading-relaxed"> {product.description->React.string} </p>
    </div>
  }
}

@react.component
let make = (~selectedProducts: array<productTypes>, ~onProductToggle: productTypes => unit) => {
  <div className="flex flex-col gap-3">
    <div className="flex flex-col gap-1">
      <h3 className="text-sm font-semibold text-nd_gray-700">
        {"Select products for production access"->React.string}
      </h3>
      <p className="text-xs text-nd_gray-500">
        {"Choose the products you want to request production access for:"->React.string}
      </p>
    </div>
    <div className="grid grid-cols-2 gap-3">
      {availableProducts
      ->Array.map(productInfo => {
        let isSelected = selectedProducts->Array.some(p => p == productInfo.product)
        let isDisabled = productInfo.product == Orchestration(V1)

        <ProductCard
          key={productInfo.name}
          product={productInfo}
          isSelected
          isDisabled
          onToggle={() => onProductToggle(productInfo.product)}
        />
      })
      ->React.array}
    </div>
  </div>
}
