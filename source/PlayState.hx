package;

import Matricies;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

function pickRandom<T>(rand:FlxRandom, items:Array<T>) {
	return items[rand.int(0, items.length - 1)];
}

function pickRandomWeighted<T>(rand:FlxRandom, items:Array<T>, weights:Array<Float>) {
	return items[rand.weightedPick(weights)];
}

function convertPointToLocation(tileSize:Int, point:FlxPoint) {
	return new Location(Math.floor(point.y / tileSize), Math.floor(point.x / tileSize));
}

class PlayState extends FlxState
{
	var tiles:FlxTilemap;
	var rand:FlxRandom;
	var tower:Tower;

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
		var bugs:Array<Int> = [13, 14, 17, 18, 27, 29];

		var background = new FlxTilemap();
		background.loadMapFrom2DArray(
			constructMatrix((row, col) -> {
				var isEvenRow = row % 2 == 0;
				var isEvenCol = col % 2 == 0;

				// 2 color checkers
				if (isEvenRow && isEvenCol) {
					return 22;
				} else if (isEvenRow && !isEvenCol) {
					return 23;
				} else if (!isEvenRow && isEvenCol) {
					return 23;
				} else {
					return 22;
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

		var tileData = constructMatrix(
			(row, col) -> pickRandomWeighted(rand, [0, 63, 61, 62], [80, 18, 2, 1]),
			width,
			height
		);

		tiles = new FlxTilemap();
		tiles.loadMapFrom2DArray(
			tileData,
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

		if (FlxG.mouse.justPressed) {
			var location = convertPointToLocation(16, FlxG.mouse.getPosition());
			
			trace('mouse pressed at: ' + FlxG.mouse.getPosition() + ' -> ' + location.trace());
		}
	}
}