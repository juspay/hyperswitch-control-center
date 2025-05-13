open APIUtils
open SDKProvider

let useClientSecret = () => {
  let updateDetails = useUpdateMethod()
  let getURL = useGetURL()
  let url = getURL(~entityName=V1(SDK_PAYMENT), ~methodType=Post)
  let {setPaymentResult, setCheckIsSDKOpen} = React.useContext(defaultContext)

  let getClientSecret = async typedValues => {
    try {
      setCheckIsSDKOpen(_ => {
        initialPreview: false,
        isLoaded: false,
        isLoading: true,
        isError: false,
      })

      let body = typedValues->Identity.genericTypeToJson
      let response = await updateDetails(url, body, Fetch.Post)

      setPaymentResult(_ => response)

      setCheckIsSDKOpen(_ => {
        initialPreview: false,
        isLoading: false,
        isError: false,
        isLoaded: true,
      })

      response
    } catch {
    | Exn.Error(e) => {
        setCheckIsSDKOpen(_ => {
          initialPreview: false,
          isLoaded: false,
          isLoading: false,
          isError: true,
        })

        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }

  getClientSecret
}
