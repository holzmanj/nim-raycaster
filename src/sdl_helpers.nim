import sdl2

func `*`*(c: Color, f: float): Color =
  (r: uint8(float(c.r) * f),
  g: uint8(float(c.g) * f),
  b: uint8(float(c.b) * f),
  a: c.a)

func `*=`*(c: var Color, f: float) =
  c = c * f
