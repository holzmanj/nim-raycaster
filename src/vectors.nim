import math

type
  Vec2* = tuple
    x, y: float

  Vec2i* = tuple
    x, y: int


func toVec2i*(v: Vec2): Vec2i =
  (int v.x, int v.y)

func `+`*(u, v: Vec2): Vec2 = (x: u.x + v.x, y: u.y + v.y)
proc `+=`*(u: var Vec2; v: Vec2) = (u = u + v)

func `-`*(u, v: Vec2): Vec2 = (x: u.x - v.x, y: u.y - v.y)
proc `-=`*(u: var Vec2; v: Vec2) = (u = u - v)

func `*`*(v: Vec2; s: float): Vec2 = (x: v.x * s, y: v.y * s)
func `*`*(s: float; v: Vec2): Vec2 = v * s

func `/`*(v: Vec2; s: float): Vec2 = (x: v.x / s, y: v.y / s)

func magnitude*(v: Vec2): float = sqrt(v.x^2 + v.y^2)

func normalized*(v: Vec2): Vec2 = v / v.magnitude

func rotatedBy*(v: Vec2; theta: float): Vec2 =
  (v.x * cos(theta) - v.y * sin(theta), v.x * sin(theta) + v.y * cos(theta))

# for indexing arrays/sequences with Vec2i
func `[]`*[N, T](a: openarray[array[N, T]]; v: Vec2i): T = a[v.x][v.y]
func `[]`*[T](a: openarray[seq[T]]; v: Vec2i): T = a[v.x][v.y]
