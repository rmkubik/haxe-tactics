import Arrays.removeDuplicates;
import flixel.tile.FlxTilemap;

class Location {
	public var row:Int;
	public var col:Int;

	public function new(row, col) {
		this.row = row;
		this.col = col;
	}

	public function trace() {
		return  '(row: ' + this.row + ' | col: ' + this.col + ')';
	}

	public function getXY() {
		return {
			x: this.col,
			y: this.row
		}
	}

	public function getTile(tiles:FlxTilemap) {
		var locationXY = this.getXY();
		
		return tiles.getTile(locationXY.x, locationXY.y);
	}

	public function setTile(tiles:FlxTilemap, value:Int) {
		var locationXY = this.getXY();
		
		tiles.setTile(locationXY.x, locationXY.y, value);
	}

	public function isInBounds(tiles:FlxTilemap) {
		return this.row >= 0 && this.row < tiles.heightInTiles && this.col >= 0 && this.col < tiles.widthInTiles;
	}

	public function isEqual(other:Location) {
		return other != null && this.row == other.row && this.col == other.col;
	}

	public function add(other:Location) {
		return new Location(row + other.row, col + other.col);
	}
}

function constructMatrix(construct, width, height) {
	var matrix = [];
	
	for (row in 0...height) {
		matrix[row] = [];
		
		for (col in 0...width) {
			var item = construct(row, col);
			
			matrix[row].push(item);
		}
	}

	return matrix;
}

function forEachMatrix(sideEffect: (location:Location) -> Void, matrix:Array<Array<Any>>): Void {
	var width = matrix.length;
	var height = matrix[0].length;
	
	for (row in 0...height) {		
		for (col in 0...width) {
			sideEffect(new Location(row, col));
		}
	}
}

function covertArrayToMatrix<T>(array:Array<T>, width): Array<Array<T>> {
	var matrix = [];

	var numberOfRows = Math.floor(array.length / width);

	for (row in 0...numberOfRows) {
		var startingIndex = row * width;
		
		matrix[row] = array.slice(startingIndex, startingIndex + width);
	}

	return matrix;
}

// ex. radius == 2
// . . x . .
// . x x x .
// x x x x x
// . x x x .
// . . x . .
function createDiamond(origin:Location, radius:Int): Array<Location> {
	var locations:Array<Location> = [];

	for (depth in 0...radius + 1) {
    // top of diamond
    locations.push(new Location(origin.row + (-radius + depth), origin.col));
    // bottom of diamond
    locations.push(new Location(origin.row + (radius - depth), origin.col));

		if (depth == 0) {
			// only add additional columns after the peak
			continue;
		}

		for (layerWidth in 1...depth + 1) {
      // top rows of diamond
      locations.push(
        new Location(origin.row + (-radius + depth), origin.col + layerWidth)
      );
			locations.push(
				new Location(origin.row + (-radius + depth), origin.col - layerWidth)
			);
      //bottom rows of diamond
      locations.push(
        new Location(origin.row + (radius - depth), origin.col + layerWidth)
      );
			locations.push(
				new Location(origin.row + (radius - depth), origin.col - layerWidth)
			);
    }
	}

	return removeDuplicates((a:Location, b:Location) -> a.isEqual(b), locations);
}

// ex. radius == 1
// . . . . .
// . x x x .
// . x x x .
// . x x x .
// . . . . .
function createSquare(origin:Location, radius:Int): Array<Location> {
	var locations:Array<Location> = [];

	for (rowAdjust in 0...radius + 1) {
		for (colAdjust in 0...radius + 1) {
			locations.push(
				new Location(origin.row - rowAdjust, origin.col + colAdjust)
			);
			locations.push(
				new Location(origin.row + rowAdjust, origin.col + colAdjust)
			);
			locations.push(
				new Location(origin.row + rowAdjust, origin.col - colAdjust)
			);
			locations.push(
				new Location(origin.row - rowAdjust, origin.col - colAdjust)
			);
		}	
	}

  return removeDuplicates((a:Location, b:Location) -> a.isEqual(b), locations);
}