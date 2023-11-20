/*
 * Reference - https://github.com/wojtekmaj/react-pdf

 * If url is not provided the path of the pdf should be in public folder

 */

@module("react-pdf") external pdfjs: {..} = "pdfjs"
pdfjs["GlobalWorkerOptions"]["workerSrc"] = `//unpkg.com/pdfjs-dist@${pdfjs["version"]}/build/pdf.worker.min.js`

open PDFViewerTypes
@react.component
let make = (~url, ~className="", ~loading, ~error) => {
  let (numPages, setNumPages) = React.useState(_ => 1)
  let (pageNumber, setPageNumber) = React.useState(_ => 1)

  let onLoadSuccess = (pages: pdfInfoType) => {
    setNumPages(_ => pages._pdfInfo.numPages)
  }

  let previousPage = _ => {
    setPageNumber(prev => prev - 1)
  }

  let nextPage = _ => {
    setPageNumber(prev => prev + 1)
  }

  <>
    <DocumentPDF file=url className onLoadSuccess loading error>
      <Page pageNumber={pageNumber} renderAnnotationLayer={false} renderTextLayer={false} />
    </DocumentPDF>
    <div className="flex items-center gap-3">
      <Button
        onClick={previousPage} text="Previous" buttonState={pageNumber <= 1 ? Disabled : Normal}
      />
      <p> {pageNumber->Belt.Int.toString->React.string} </p>
      <Button
        onClick={nextPage} text="Next" buttonState={pageNumber >= numPages ? Disabled : Normal}
      />
    </div>
  </>
}

let default = make
