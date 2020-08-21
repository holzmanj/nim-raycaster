import sequtils
import vectors

type
  Player* = object
    position*, direction*, camera*: Vec2
    moveSpeed*, rotSpeed*: float

  Tile* = enum
    tFloor
    tWall

  Level* = seq[seq[Tile]]


func generateLevel(width, height: int): Level =
  result = newSeqWith(width, newSeqWith(height, tFloor))
  # Add walls around perimeter of level
  for x in 0..<width:
    result[x][0] = tWall
    result[x][height-1] = tWall
  for y in 0..<height:
    result[0][y] = tWall
    result[width-1][y] = tWall


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
