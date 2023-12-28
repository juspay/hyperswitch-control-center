// Copied from https://gist.github.com/Frencil/aab561687cdd2b0de04a

let pretty = (range: array<float>, n: int) => {
  if range->Array.length === 2 {
    let range = if range[0] === range[1] {
      [0., range[1]->Belt.Option.getWithDefault(0.)]
    } else {
      range
    }

    let min_n = Belt.Int.toFloat(n) /. 3.
    let shrink_sml = 0.75
    let high_u_bias = 1.5
    let u5_bias = 0.5 +. 1.5 *. high_u_bias
    let d = Js.Math.abs_float(
      range[0]->Belt.Option.getWithDefault(0.) -. range[1]->Belt.Option.getWithDefault(0.),
    )

    let c = if Js.Math.log(d) /. Js.Math._LN10 < -2. {
      Js.Math.abs_float(d) *. shrink_sml /. min_n
    } else {
      d /. Belt.Int.toFloat(n)
    }

    let base = Js.Math.pow_float(
      ~base=10.,
      ~exp=Js.Math.floor_float(Js.Math.log(c) /. Js.Math._LN10),
    )
    let base_toFixed = if base < 1. {
      Js.Math.abs_float(Js.Math.round(Js.Math.log(base) /. Js.Math._LN10))->Belt.Float.toInt
    } else {
      0
    }

    let unit = ref(base)
    if 2. *. base -. c < high_u_bias *. (c -. unit.contents) {
      unit := 2. *. base
      if 5. *. base -. c < u5_bias *. (c -. unit.contents) {
        unit := 5. *. base
        if 10. *. base -. c < high_u_bias *. (c -. unit.contents) {
          unit := 10. *. base
        }
      }
    }

    let ticks = []
    let i = if range[0]->Belt.Option.getWithDefault(0.) <= unit.contents {
      0.
    } else {
      let i123 =
        Js.Math.floor_float(range[0]->Belt.Option.getWithDefault(0.) /. unit.contents) *.
        unit.contents

      i123
      ->Js.Float.toFixedWithPrecision(~digits=base_toFixed)
      ->Belt.Float.fromString
      ->Belt.Option.getWithDefault(0.)
    }

    let iRef = ref(i)
    let break = ref(false)
    while iRef.contents < range[1]->Belt.Option.getWithDefault(0.) && unit.contents > 0. {
      ticks->Array.push(iRef.contents)->ignore
      iRef := iRef.contents +. unit.contents
      if base_toFixed > 0 && unit.contents > 0. {
        iRef :=
          iRef.contents
          ->Js.Float.toFixedWithPrecision(~digits=base_toFixed)
          ->Belt.Float.fromString
          ->Belt.Option.getWithDefault(0.)
      } else {
        break := true
      }
    }
    ticks->Array.push(iRef.contents)->ignore

    ticks
  } else {
    [0.]
  }
}
