open Typography

@react.component
let make = (
  ~showModal: bool,
  ~setShowModal: (bool => bool) => unit,
  ~fileName: string,
  ~previewState: ReconEnginePipelinesTypes.filePreviewState,
) => {
  open ReconEnginePipelinesTypes
  open ReconEnginePipelinesUtils

  let theme = switch ThemeProvider.useTheme() {
  | Dark => "vs-dark"
  | Light => "vs"
  }
  let language = fileName->getMonacoLanguageFromFileName
  let screenState = switch previewState {
  | PreviewLoading => PageLoaderWrapper.Loading
  | PreviewLoaded(_) => PageLoaderWrapper.Success
  | PreviewFailed => PageLoaderWrapper.Custom
  }
  let content = switch previewState {
  | PreviewLoaded(content) => content
  | PreviewLoading | PreviewFailed => ""
  }

  <Modal
    setShowModal
    showModal
    closeOnOutsideClick=true
    modalHeading=fileName
    modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold} truncate`}
    modalClass="flex flex-col justify-start h-screen w-full overflow-hidden !bg-white"
    childClass="relative h-full">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-52" message="Failed to load file preview." />}
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin mb-1">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div className="h-full px-6 py-5 overflow-hidden">
        <MonacoEditorLazy
          defaultLanguage=language
          value=content
          readOnly=true
          theme
          height="calc(100vh - 220px)"
          showCopy=false
        />
      </div>
    </PageLoaderWrapper>
  </Modal>
}
