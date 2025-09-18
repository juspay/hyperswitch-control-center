let paymentMethodCell = cardNetwork => {
  <div className="flex items-center  mr-6">
    <GatewayIcon gateway={cardNetwork->String.toUpperCase} className="w-6 h-6 mr-1" />
    <div className="capitalize">
      {cardNetwork
      ->LogicUtils.capitalizeString
      ->React.string}
    </div>
  </div>
}
