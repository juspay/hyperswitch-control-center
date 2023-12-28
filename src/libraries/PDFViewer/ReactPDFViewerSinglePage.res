/*
 * Reference - https://github.com/wojtekmaj/react-pdf

 * If url is not provided the path of the pdf should be in public folder

 */

@module("react-pdf") external pdfjs: {..} = "pdfjs"
pdfjs["GlobalWorkerOptions"]["workerSrc"] = `//unpkg.com/pdfjs-dist@${pdfjs["version"]}/build/pdf.worker.min.js`

open PDFViewerTypes
@react.component
let make = (~url, ~className, ~loading, ~height=700, ~width=800, ~error) => {
  let (numPages, setNumPages) = React.useState(_ => 1)

  let onLoadSuccess = (pages: pdfInfoType) => {
    setNumPages(_ => pages._pdfInfo.numPages)
  }

  let noData =
    <div className="bg-white h-[70vh] flex items-center justify-center m-auto gap-2">
      <Icon name="error-circle" size=16 />
      {"Please upload the PDF File."->React.string}
    </div>

  <DocumentPDF file=url className onLoadSuccess error loading noData>
    {Belt.Array.makeBy(numPages, i => i + 1)
    ->Array.mapWithIndex((ele, index) => {
      <Page
        key={`page_${index->string_of_int}`}
        pageNumber={ele}
        renderAnnotationLayer={true}
        renderTextLayer={false}
        height
        width
        loading
      />
    })
    ->React.array}
  </DocumentPDF>
}

let default = make
