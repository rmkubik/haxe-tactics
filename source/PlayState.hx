package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRandom;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

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

class PlayState extends FlxState
{
	var tiles:FlxTilemap;
	var rand:FlxRandom;

	override public function create()
	{
		super.create();

		rand = new FlxRandom();
		 
		var text = new FlxText(10, 10, 100, "Hello, World!");
		add(text);

		var tilesBitmapData = openfl.Assets.getBitmapData(AssetPaths.sprites__png);
		var tilesheet:FlxGraphic = FlxGraphic.fromBitmapData(tilesBitmapData);

		var ITEM_COUNT = 20;
		var width = 10;
		var height = 10;

		var background = new FlxTilemap();
		background.loadMapFrom2DArray(
			constructMatrix((row, col) -> {
				var isEvenRow = row % 2 == 0;
				var isEvenCol = col % 2 == 0;

				if (isEvenRow && isEvenCol) {
					return 22;
				} else if (isEvenRow && !isEvenCol) {
					return 23;
				} else if (!isEvenRow && isEvenCol) {
					return 24;
				} else {
					return 25;
				}
			}, width, height),
			tilesheet,
			16,
			16,
			FlxTilemapAutoTiling.OFF,
			1,
			1
		);
		add(background);

		tiles = new FlxTilemap();
		tiles.loadMapFrom2DArray(
			constructMatrix((row, col) -> rand.int(1, ITEM_COUNT), width, height),
			tilesheet,
			16,
			16,
			FlxTilemapAutoTiling.OFF,
			1,
			1
		);
		add(tiles);

		FlxG.scaleMode = new RatioScaleMode();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}