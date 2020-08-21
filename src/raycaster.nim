import sdl2
import game
import vectors
import sdl_helpers

const
  SCREEN_WIDTH = 720
  SCREEN_HEIGHT = 480

let
  COLOR_SKY = color(165, 230, 230, 255)
  COLOR_FLOOR = color(100, 120, 100, 255)
  COLOR_WALL = color(160, 160, 160, 255)

var
  window: WindowPtr
  render: RendererPtr
  evt: Event

  player: Player
  level: Level
  runGame = true

type
  Axis = enum X, Y


proc init() =
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow("SDL Window", SDL_WINDOWPOS_CENTERED,
      SDL_WINDOWPOS_CENTERED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN)
  render = createRenderer(window, -1, Renderer_Accelerated or
      Renderer_PresentVsync or Renderer_TargetTexture)

  evt = sdl2.defaultEvent
  (player, level) = initGame(30, 30)


proc update(delta: float) =
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break

  let
    moveSpeed = player.moveSpeed * delta
    rotSpeed = player.rotSpeed * delta
    kbState = getKeyboardState()

  if kbState[int SDL_SCANCODE_UP] == 1:
    let newPos = player.position + player.direction * moveSpeed
    if level[int(newPos.x)][int(player.position.y)] == tFloor:
      player.position.x = newPos.x
    if level[int(player.position.x)][int(newPos.y)] == tFloor:
      player.position.y = newPos.y

  if kbState[int SDL_SCANCODE_DOWN] == 1:
    let newPos = player.position - player.direction * moveSpeed
    if level[int(newPos.x)][int(player.position.y)] == tFloor:
      player.position.x = newPos.x
    if level[int(player.position.x)][int(newPos.y)] == tFloor:
      player.position.y = newPos.y

  if kbState[int SDL_SCANCODE_LEFT] == 1:
    player.direction = player.direction.rotatedBy(rotSpeed)
    player.camera = player.camera.rotatedBy(rotSpeed)

  if kbState[int SDL_SCANCODE_RIGHT] == 1:
    player.direction = player.direction.rotatedBy(-rotSpeed)
    player.camera = player.camera.rotatedBy(-rotSpeed)


proc draw() =
  # fill screen with sky color
  render.setDrawColor(COLOR_SKY)
  render.clear()

  # draw rect for floor
  render.setDrawColor(COLOR_FLOOR)
  var floorRect = rect(0, SCREEN_HEIGHT div 2, SCREEN_WIDTH, SCREEN_HEIGHT)
  render.fillRect(floorRect)

  # draw each column of pixels
  for x in 0..<SCREEN_WIDTH:
    var
      # determine the coordinate of the column on the camera plane [-1, 1]
      camOffset: float = 2 * x / SCREEN_WIDTH - 1
      # ray from player position to camera plane
      posToCam = player.direction + player.camera * camOffset
      cell = toVec2i(player.position)
      # distance from player's position to next x or y cell border
      posToBorder: Vec2
      # distance from one cell border to the next
      borderToBorder = (abs(1 / posToCam.x), abs(1 / posToCam.y)).Vec2
      # direction of ray's movement on the level grid {-1, 1}
      step: Vec2i
      # determines which side of wall cell was hit
      side: Axis
      # distance to hit
      dist: float

    # calculate step and posToBorder
    if posToCam.x < 0:
      step.x = -1
      posToBorder.x = (player.position.x - float(cell.x)) *
          borderToBorder.x
    else:
      step.x = 1
      posToBorder.x = (float(cell.x) + 1.0 - player.position.x) *
          borderToBorder.x

    if posToCam.y < 0:
      step.y = -1
      posToBorder.y = (player.position.y - float(cell.y)) *
          borderToBorder.y
    else:
      step.y = 1
      posToBorder.y = (float(cell.y) + 1.0 - player.position.y) *
          borderToBorder.y

    # DDA loop
    while true:
      if posToBorder.x < posToBorder.y:
        posToBorder.x += borderToBorder.x
        cell.x += step.x
        side = Axis.X
      else:
        posToBorder.y += borderToBorder.y
        cell.y += step.y
        side = Axis.Y

      if level[cell] != tFloor: break

    case side:
      of X:
        dist = (float(cell.x) - player.position.x + (1 - step.x) / 2) / posToCam.x
      of Y:
        dist = (float(cell.y) - player.position.y + (1 - step.y) / 2) / posToCam.y

    var
      lineSize = int(float(SCREEN_HEIGHT) / dist)
      drawStart = max(0.cint, cint(SCREEN_HEIGHT div 2 - lineSize div 2))
      drawEnd = min(SCREEN_HEIGHT, cint(SCREEN_HEIGHT div 2 + lineSize div 2))

    if side == Axis.X:
      render.setDrawColor(COLOR_WALL * 0.8)
    else:
      render.setDrawColor(COLOR_WALL)
    render.drawLine(cint(x), drawStart, cint(x), drawEnd)



proc main() =
  var
    t0, t1: uint32
    deltaTime: float

  init()

  while runGame:
    update(deltaTime)

    draw()
    render.present

    # calculate time between frames
    t0 = t1
    t1 = getTicks()
    deltaTime = float(t1 - t0) / 1000.0 # expressed in seconds

  destroy render
  destroy window
  sdl2.quit()


when isMainModule:
  main()
