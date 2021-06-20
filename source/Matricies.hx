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