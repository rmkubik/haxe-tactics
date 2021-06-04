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