import Matricies.Location;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

function convertPointToLocation(tileSize:Int, point:FlxPoint) {
	return new Location(Math.floor((point.y - Config.instance.topMargin) / tileSize), Math.floor(point.x / tileSize));
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

  public function createLayer(tileData) {
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
			var position = FlxG.mouse.getPosition();
			var location = convertPointToLocation(Config.instance.tileSize, position);
			
			trace('mouse pressed at: ' + position + ' -> ' + location.trace());

      onClick(location);
		}
  }
}