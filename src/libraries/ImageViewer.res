@module("react-shimmer-effect") @react.component
let make = (
  ~shimmerClass="w-full h-auto min-h-[110px]",
  ~imageClass="h-full w-auto",
  ~imageUrl,
  ~alt: string="",
) => {
  let (isLoading, setIsLoading) = React.useState(_ => true)

  <div className="flex justify-center h-auto bg-transparent rounded-t-lg">
    <Shimmer
      styleClass={`${if isLoading {
          shimmerClass
        } else {
          "hidden"
        }}`}
    />
    <img
      className={imageClass}
      alt={alt}
      src={imageUrl}
      loading=#"lazy"
      onLoad={_ => {setIsLoading(_ => false)}}
    />
  </div>
}
