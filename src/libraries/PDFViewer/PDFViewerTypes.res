type pdfInfoNumPages = {numPages: int}

type pdfInfoType = {_pdfInfo: pdfInfoNumPages}

module Page = {
  @module("react-pdf") @react.component
  external make: (
    ~pageNumber: int,
    ~renderAnnotationLayer: bool,
    ~renderTextLayer: bool,
    ~className: string=?,
    ~height: int=?,
    ~width: int=?,
    ~scale: int=?,
    ~loading: React.element=?,
    ~error: React.element=?,
  ) => React.element = "Page"
}

module DocumentPDF = {
  @module("react-pdf") @react.component
  external make: (
    ~children: React.element,
    ~file: string,
    ~className: string=?,
    ~loading: React.element=?,
    ~onLoadSuccess: pdfInfoType => unit,
    ~noData: React.element=?,
    ~error: React.element=?,
  ) => React.element = "Document"
}
