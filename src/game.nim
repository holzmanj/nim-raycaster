import sequtils
import vectors

type
  Player* = object
    position*, direction*, camera*: Vec2
    moveSpeed*, rotSpeed*: float

  Tile* = enum
    tFloor
    tStoneWall
    tWoodWall

  Level* = seq[seq[Tile]]


func generateLevel(width, height: int): Level =
  result = newSeqWith(width, newSeqWith(height, tFloor))
  # Add walls around perimeter of level
  for x in 0..<width:
    result[x][0] = tStoneWall
    result[x][height-1] = tStoneWall
  for y in 0..<height:
    result[0][y] = tStoneWall
    result[width-1][y] = tStoneWall

  # add some wooden walls that you can walk around
  let
    xHalf = width div 2
    yHalf = height div 2
  for x in 2..width-2:
    if x == xHalf: continue
    for y in [yHalf-2, yHalf+2]:
      result[x][y] = tWoodWall


func initGame*(levelWidth, levelHeight: int): (Player, Level) =
  var
    player = Player(
      position: (levelWidth / 2, levelHeight / 2),
      direction: (-1.0, 0.0),
      camera: (0.0, 0.66),
      moveSpeed: 7.0,
      rotSpeed: 3.0)
    level = generateLevel(levelWidth, levelHeight)

  (player, level)
