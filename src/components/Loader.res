@react.component
let make = (
  ~loadingText="Loading...",
  ~children=React.null,
  ~slow=false,
  ~customSpinnerIconColor: string="",
  ~loadingTextColor="",
) => {
  let loaderLottieFile = LottieFiles.useLottieJson("hyperswitch_loader.json")

  let animationType = if slow {
    "animate-spin-slow"
  } else {
    "animate-spin"
  }

  let size = if slow {
    60
  } else {
    20
  }

  let loader =
    <div className={`flex flex-col py-16 text-center items-center ${loadingTextColor}`}>
      <div className={`${animationType} mb-10`}>
        <Icon name="spinner" size customIconColor=customSpinnerIconColor />
      </div>
      {children}
    </div>

  <div className="flex flex-col">
    <div className="w-full flex justify-center py-10">
      <div className="w-20 h-16">
        <React.Suspense fallback={loader}>
          <ErrorBoundary>
            <div className="scale-400 pt-px">
              <Lottie animationData={loaderLottieFile} autoplay=true loop=true />
            </div>
          </ErrorBoundary>
        </React.Suspense>
      </div>
    </div>
  </div>
}
