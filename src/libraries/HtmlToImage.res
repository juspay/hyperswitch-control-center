// https://www.npmjs.com/package/html-to-image

// types https://github.com/bubkoo/html-to-image/
module T = {
  @deriving(abstract)
  type options = {
    /**
   * Width in pixels to be applied to node before rendering.
   */
    @optional
    width: int,
    /**
   * Height in pixels to be applied to node before rendering.
   */
    @optional
    height: int,
    /**
   * A string value for the background color, any valid CSS color value.
   */
    @optional
    backgroundColor: string,
    /**
   * Width in pixels to be applied to canvas on export.
   */
    @optional
    canvasWidth: int,
    /**
   * Height in pixels to be applied to canvas on export.
   */
    @optional
    canvasHeight: int,
    /**
   * An object whose properties to be copied to node's style before rendering.
   */
    @optional
    style: ReactDOMStyle.t,
    /**
   * A function taking DOM node as argument. Should return `true` if passed
   * node should be included in the output. Excluding node means excluding
   * it's children as well.
   */
    @optional
    filter: (~domNode: Webapi.Dom.Element.t) => bool,
    /**
   * A number between `0` and `1` indicating image quality (e.g. 0.92 => 92%)
   * of the JPEG image.
   */
    @optional
    quality: float,
    /**
   * Set to `true` to append the current time as a query string to URL
   * requests to enable cache busting.
   */
    @optional
    cacheBust: bool,
    /**
   * Set false to use all URL as cache key.
   * Default: false | undefined - which strips away the query parameters
   */
    @optional
    includeQueryParams: bool,
    /**
   * A data URL for a placeholder image that will be used when fetching
   * an image fails. Defaults to an empty string and will render empty
   * areas for failed images.
   */
    @optional
    imagePlaceholder: string,
    /**
   * The pixel ratio of captured image. Defalut is the actual pixel ratio of
   * the device. Set 1 to use as initial-scale 1 for the image
   */
    @optional
    pixelRatio: float,
    /**
   * Option to skip the fonts download and embed.
   */
    @optional
    skipFonts: bool,
    /**
   * The preferred font format. If specified all other font formats are ignored.
   */
    @optional
    preferredFontFormat: [
      | #woff
      | #woff2
      | #truetype
      | #opentype
      | #"embedded-opentype"
      | #svg
    ],
    /**
   * A CSS string to specify for font embeds. If specified only this CSS will
   * be present in the resulting image. Use with `getFontEmbedCSS()` to
   * create embed CSS for use across multiple calls to library functions.
   */
    @optional
    fontEmbedCSS: string,
    /**
   * A boolean to turn off auto scaling for truly massive images..
   */
    @optional
    skipAutoScale: bool,
    /**
   * A string indicating the image format. The default type is image/png; that type is also used if the given type isn't supported.
   */
    @optional
    @as("type")
    _type: string,

    //   fetchRequestInit?: 'a, //todo
  }
  type t = (. ~node: Webapi.Dom.Element.t, ~options: options) => Js.Promise.t<string>
}
// not utilizing this
// module Utils = {
//   let downloadImage = %raw(`
//     function (uri, name) {
//     const link = document.createElement("a");
//     link.download = name;
//     link.href = uri;
//     document.body.appendChild(link);
//     link.click();
//     document.body.removeChild(link);
//   }`)
// }

@module("html-to-image") external toSvg: T.t = "toSvg"
@module("html-to-image") external toCanvas: T.t = "toCanvas"
@module("html-to-image") external toPixelData: T.t = "toPixelData"
@module("html-to-image") external toPng: T.t = "toPng"
@module("html-to-image") external toJpeg: T.t = "toJpeg"
@module("html-to-image") external toBlob: T.t = "toBlob"
@module("html-to-image") external getFontEmbedCSS: T.t = "getFontEmbedCSS"
