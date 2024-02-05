// Copied from https://gist.github.com/Frencil/aab561687cdd2b0de04a

let pretty = (range: array<float>, n: int) => {
  if range->Array.length === 2 {
    let range = if range[0] === range[1] {
      [0., range[1]->Option.getOr(0.)]
    } else {
      range
    }

    let min_n = Int.toFloat(n) /. 3.
    let shrink_sml = 0.75
    let high_u_bias = 1.5
    let u5_bias = 0.5 +. 1.5 *. high_u_bias
    let d = Math.abs(range[0]->Option.getOr(0.) -. range[1]->Option.getOr(0.))

    let c = if Math.log(d) /. Math.Constants.ln10 < -2. {
      Math.abs(d) *. shrink_sml /. min_n
    } else {
      d /. Int.toFloat(n)
    }

    let base = Math.pow(10., ~exp=Math.floor(Math.log(c) /. Math.Constants.ln10))
    let base_toFixed = if base < 1. {
      Math.abs(Math.round(Math.log(base) /. Math.Constants.ln10))->Float.toInt
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
    let i = if range[0]->Option.getOr(0.) <= unit.contents {
      0.
    } else {
      let i123 = Math.floor(range[0]->Option.getOr(0.) /. unit.contents) *. unit.contents

      i123->Float.toFixedWithPrecision(~digits=base_toFixed)->Float.fromString->Option.getOr(0.)
    }

    let iRef = ref(i)
    let break = ref(false)
    while iRef.contents < range[1]->Option.getOr(0.) && unit.contents > 0. {
      ticks->Array.push(iRef.contents)->ignore
      iRef := iRef.contents +. unit.contents
      if base_toFixed > 0 && unit.contents > 0. {
        iRef :=
          iRef.contents
          ->Float.toFixedWithPrecision(~digits=base_toFixed)
          ->Float.fromString
          ->Option.getOr(0.)
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
