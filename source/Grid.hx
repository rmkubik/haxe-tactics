import Matricies.Location;
import Matricies.mapMatrix;
import TileTypes.TileTypeInfo;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

function convertPointToLocation(point:FlxPoint, gridPosition:FlxPoint) {
  return new Location(
    Math.floor((point.y - gridPosition.y) / Config.instance.tileSize),
    Math.floor((point.x - gridPosition.x) / Config.instance.tileSize)
  );
}

class Grid {
  var tilesheet:FlxGraphic;
  public var layers:Array<FlxTilemap> = [];
  var position:FlxPoint;
  var state:FlxState;
  var onClick:(Location)->Void = (location) -> {};

  public function new(position, tilesheet, state, onClick) {
    this.tilesheet = tilesheet;
    this.position = position;
    this.state = state;
    this.onClick = onClick;
  }

  public function createLayer(tileTypes: Array<Array<TileTypes>>) {
    var tileData: Array<Array<Int>> = mapMatrix(location -> {
      // We're using row & col directly because location.getTile
      // only operates on FlxTilemaps.
      var tileType = tileTypes[location.row][location.col];
      
      return TileTypeInfo[tileType].id;
    }, tileTypes);
    
    var tiles = new FlxTilemap();
    tiles.loadMapFrom2DArray(
      tileData,
      tilesheet,
      Config.instance.tileSize,
      Config.instance.tileSize,
      FlxTilemapAutoTiling.OFF,
      1,
      1
    );
    tiles.setPosition(this.position.x, this.position.y);
    
    state.add(tiles);

    this.layers.push(tiles);
  }

  public function update() {
    if (FlxG.mouse.justPressed) {
			var mousePosition = FlxG.mouse.getPosition();
			var location = convertPointToLocation(mousePosition, this.position);
			
      onClick(location);
		}
  }

  public function getDimensions(): { width:Int, height:Int } {
    return {
      width: layers[0].widthInTiles,
      height: layers[0].heightInTiles
    }
  }
}