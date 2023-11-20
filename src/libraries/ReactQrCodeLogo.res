module Utils = {
  module T = {
    //         declare type EyeColor = string | InnerOuterEyeColor;
    // declare type InnerOuterEyeColor = {
    //     inner: string;
    //     outer: string;
    // };
    // declare type CornerRadii = number | [number, number, number, number] | InnerOuterRadii;
    // declare type InnerOuterRadii = {
    //     inner: number | [number, number, number, number];
    //     outer: number | [number, number, number, number];
    // };
    type _innerOuterEyeColor = {
      inner: string,
      outer: string,
    }
    type _innerOutRadiiEntity
    type _innerOutRadiiEntityEnum = Number(int) | ArrNum((int, int, int, int))
    type _innerOutRadii = {
      inner: _innerOutRadiiEntity,
      outer: _innerOutRadiiEntity,
    }
    type _eyeColor
    type _eyeColorEnum = String(string) | InnerOuterEyeColor(_innerOuterEyeColor)
    type _cornerRadii
    type _cornerRadiiEnum =
      Number(int) | ArrNum((int, int, int, int)) | InnerOuterRadii(_innerOutRadii)
    type eyeColor
    type eyeRadius
  }
  module EyeColor = {
    external identity: 'a => T.eyeColor = "%identity"
    let make = (e: T._eyeColorEnum) => {
      switch e {
      | String(s) => identity(s)
      | InnerOuterEyeColor(s) => identity(s)
      }
    }
  }
}
/**
 * { @link https://www.npmjs.com/package/react-qrcode-logo }
 * { @link https://github.com/gcoro/react-qrcode-logo/blob/master/dist/index.d.ts types }
 */
@module("react-qrcode-logo")
@react.component
external make: (
  ~value: string,
  ~ecLevel: [#L | #M | #Q | #H]=?,
  ~enableCORS: bool=?,
  ~size: int=?,
  ~quietZone: int=?,
  ~bgColor: string=?,
  ~fgColor: string=?,
  ~logoImage: string=?,
  ~logoWidth: float=?,
  ~logoHeight: float=?,
  ~logoOpacity: float=?,
  ~logoOnLoad: unit => unit=?,
  ~removeQrCodeBehindLogo: bool=?,
  ~logoPadding: int=?,
  ~logoPaddingStyle: [#square | #circle]=?,
  ~qrStyle: [#square | #dots]=?,
  ~style: ReactDOMStyle.t=?,
  ~eyeRadius: Utils.T.eyeRadius=?,
  ~eyeColor: Utils.T.eyeColor=?,
  ~id: string=?,
) => React.element = "QRCode"
