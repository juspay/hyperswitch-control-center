module ModalContent = {
  @react.component
  let make = (~modalChildren, ~showModal, ~setShowModal) => {
    <Modal
      showModal
      setShowModal
      modalClass="mx-auto overflow-auto"
      childClass="m-1"
      closeOnOutsideClick=true
      alignModal="justify-center items-center"
      paddingClass="">
      modalChildren
    </Modal>
  }
}

@react.component
let make = (
  ~images: array<string>,
  ~onPlayVideo=_ => (),
  ~selectedMediaIndex=?,
  ~height="h-[calc(100vh-260px)]",
) => {
  let (selectedIndex, setSelectedIndex) = React.useState(_ => 0)
  let (showModal, setShowModal) = React.useState(_ => false)
  let onClickOpenModal = _ =>
    selectedMediaIndex->Belt.Option.mapWithDefault((), _ => setShowModal(_ => true))

  React.useEffect1(() => {
    selectedMediaIndex->Option.mapWithDefault((), selectedMediaIndex =>
      setSelectedIndex(_ => selectedMediaIndex)
    )
    None
  }, [selectedMediaIndex])

  let getVideoElement = (videoUrl: string, format: string) => {
    <div className="justify-center items-center flex h-full" key={selectedIndex->Belt.Int.toString}>
      <video
        onPlay={_ => onPlayVideo(videoUrl)}
        className="border rounded-[8px] text-center w-full max-h-[100%] cursor-pointer"
        muted=true
        autoPlay=false
        loop=true
        controls=true
        onClick=onClickOpenModal>
        <source src={videoUrl} type_={"video/" ++ format} />
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png"
          title="Unable to play Video"
        />
      </video>
      <ModalContent
        modalChildren={<video
          onPlay={_ => onPlayVideo(videoUrl)}
          className="border rounded-[8px] h-[800px] text-center w-full"
          muted=true
          autoPlay=false
          loop=true
          controls=true>
          <source src=videoUrl type_={"video/" ++ format} />
          <img
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png"
            title="Unable to play Video"
          />
        </video>}
        showModal
        setShowModal
      />
    </div>
  }

  <div
    className={`flex rounded-xl py-8 bg-[#fbfbfb] dark:bg-[#111010] items-center w-full text-center justify-center flex-wrap relative ${height}`}>
    <div className="flex items-center text-center w-auto h-[100%] justify-center">
      {switch images
      ->Belt.Array.get(selectedIndex)
      ->Belt.Option.flatMap(str => str->Js.String2.split(".")->Js.Array2.pop)
      ->Belt.Option.getWithDefault("") {
      | "" => React.null
      | format =>
        if format == "mp4" || format == "ogg" || format == "webm" {
          let videoUrl = images->Belt.Array.get(selectedIndex)->Belt.Option.getWithDefault("")
          videoUrl->getVideoElement(format)
        } else {
          <>
            <img
              alt="Feature Image"
              src={images
              ->Belt.Array.get(selectedIndex)
              ->Belt.Option.getWithDefault(
                "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/Image_not_available.png/640px-Image_not_available.png",
              )}
              className="items-center px-[20px] w-full max-h-full cursor-pointer"
              onClick=onClickOpenModal
            />
            {images
            ->Belt.Array.get(selectedIndex)
            ->Belt.Option.mapWithDefault(React.null, image =>
              <ModalContent
                modalChildren={<img
                  alt="Feature Image"
                  src={image}
                  className="items-center max-w-[315px] max-h-[700px]"
                />}
                showModal
                setShowModal
              />
            )}
          </>
        }
      }}
    </div>
    {images->Js.Array.length > 1
      ? <>
          <div
            className="bg-[#F2F2F2] rounded-3xl p-2 absolute left-8 top-1/2 hover:bg-[#E8F3FF] cursor-pointer"
            onClick={_ =>
              setSelectedIndex(_ =>
                selectedIndex == 0 ? images->Js.Array.length - 1 : selectedIndex - 1
              )}>
            <Icon className="align-middle text-[#797979]" size=16 name="chevron-left" />
          </div>
          <div
            className="bg-[#F2F2F2] rounded-3xl p-2 absolute right-8 top-1/2 hover:bg-[#E8F3FF] cursor-pointer"
            onClick={_ =>
              setSelectedIndex(_ =>
                selectedIndex == images->Js.Array.length - 1 ? 0 : selectedIndex + 1
              )}>
            <Icon className="align-middle text-[#797979]" size=16 name="chevron-right" />
          </div>
          <div
            className="flex flex-row text-center items-center justify-center w-full absolute -bottom-6">
            {images
            ->Js.Array2.mapi((img, index) => {
              switch img->Js.String2.split(".")->Js.Array2.pop->Belt.Option.getWithDefault("") {
              | "" => React.null
              | format =>
                if format == "mp4" || format == "ogg" || format == "webm" {
                  let additionalClass = {
                    if selectedIndex == index {
                      "text-[#1B85FF] "
                    } else {
                      "text-[#E1E1E1] "
                    }
                  }
                  <Icon
                    key={format ++ index->Belt.Int.toString}
                    name="play"
                    onClick={_ => setSelectedIndex(_ => index)}
                    size=10
                    className={`mx-0.5 cursor-pointer ${additionalClass}`}
                  />
                } else {
                  let additionalClass = {
                    if selectedIndex == index {
                      "bg-[#1B85FF]"
                    } else {
                      "bg-[#E1E1E1]"
                    }
                  }
                  <div
                    key={"imgViewer" ++ Belt.Int.toString(index)}
                    onClick={_ => setSelectedIndex(_ => index)}
                    className={`flex w-[10px] h-[10px] justify-center mx-0.5 cursor-pointer rounded-xl ${additionalClass}`}
                  />
                }
              }
            })
            ->React.array}
          </div>
        </>
      : React.null}
  </div>
}
