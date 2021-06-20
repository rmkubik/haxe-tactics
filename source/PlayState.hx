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
import flixel.util.FlxColor;

function pickRandom<T>(rand:FlxRandom, items:Array<T>) {
	return items[rand.int(0, items.length - 1)];
}

function pickRandomWeighted<T>(rand:FlxRandom, items:Array<T>, weights:Array<Float>) {
	return items[rand.weightedPick(weights)];
}

function convertPointToLocation(tileSize:Int, point:FlxPoint) {
	return new Location(Math.floor((point.y - Config.instance.topMargin) / tileSize), Math.floor(point.x / tileSize));
}

var TileTypes = {
	EMPTY: 0,
	SELECTOR: 21,
	TREE: 63,
	STONE: 61,
	GOLD: 62,
	VILLAGE: 74
}

var TileTypeInfo:Map<Int, Any> = [
	TileTypes.EMPTY => 'Empty',
	TileTypes.SELECTOR => 'Empty',
	TileTypes.TREE => 'Tree',
	TileTypes.STONE => 'Stone',
	TileTypes.GOLD => 'Gold',
	TileTypes.VILLAGE => 'Village'
];


class PlayState extends FlxState
{
	var tiles:FlxTilemap;
	var upperLayer:FlxTilemap;
	var rand:FlxRandom;
	var tower:Tower;
	var gameState:String;
	var gold:Int;
	var stone:Int;
	var wood:Int;
	var goldText:FlxText;
	var stoneText:FlxText;
	var woodText:FlxText;
	var selected:Location = null;
	var infoTitleText:FlxText;
	var infoBodyTest:FlxText;

	override public function create()
	{
		super.create();

		rand = new FlxRandom();

		var tilesBitmapData = openfl.Assets.getBitmapData(AssetPaths.sprites__png);
		var tilesheet:FlxGraphic = FlxGraphic.fromBitmapData(tilesBitmapData);

		var ITEM_COUNT = 20;
		var width = Config.instance.tilesWide;
		var height = Config.instance.tilesHigh;
		var bugs:Array<Int> = [13, 14, 17, 18, 27, 29];
		// placingStart, playing, placing
		gameState = 'placingStart';
		gold = 100;
		wood = 100;
		stone = 100;

		bgColor = new FlxColor(0xFF663931);

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
			Config.instance.tileSize,
			Config.instance.tileSize,
			FlxTilemapAutoTiling.OFF,
			1,
			1
		);
		background.setPosition(0, Config.instance.topMargin);
		add(background);

		var tileData = constructMatrix(
			(row, col) -> pickRandomWeighted(rand, [TileTypes.EMPTY, TileTypes.TREE, TileTypes.STONE, TileTypes.GOLD], [80, 18, 2, 1]),
			width,
			height
		);

		tiles = new FlxTilemap();
		tiles.loadMapFrom2DArray(
			tileData,
			tilesheet,
			Config.instance.tileSize,
			Config.instance.tileSize,
			FlxTilemapAutoTiling.OFF,
			1,
			1
		);
		tiles.setPosition(0, Config.instance.topMargin);
		add(tiles);

		upperLayer = new FlxTilemap();
		upperLayer.loadMapFrom2DArray(
			constructMatrix((row, col) -> 0, width, height),
			tilesheet,
			Config.instance.tileSize,
			Config.instance.tileSize,
			FlxTilemapAutoTiling.OFF,
			1,
			1
		);
		upperLayer.setPosition(0, Config.instance.topMargin);
		add(upperLayer);

		// top bar
		var textWidth = Config.instance.tileSize * 3;

		goldText = new FlxText(0 * textWidth, 0, textWidth, 'G: ' + Std.string(gold));
		goldText.borderStyle = FlxTextBorderStyle.OUTLINE;
		add(goldText);

		stoneText = new FlxText(1 * textWidth, 0, textWidth, 'S: ' + Std.string(stone));
		stoneText.borderStyle = FlxTextBorderStyle.OUTLINE;
		add(stoneText);

		woodText = new FlxText(2 * textWidth, 0, textWidth, 'W: ' + Std.string(wood));
		woodText.borderStyle = FlxTextBorderStyle.OUTLINE;
		add(woodText);

		// bottom bar
		
		// info bar on far right
		var infoPanelWidth = Config.instance.tileSize * 4;
		var infoPanelPosition = new FlxPoint(
			Config.instance.pixelsWide - infoPanelWidth,
			Config.instance.pixelsHigh - Config.instance.bottomMargin
		);
		infoTitleText = new FlxText(
			infoPanelPosition.x,
			infoPanelPosition.y,
			infoPanelWidth,
			". . ."
		);
		infoTitleText.borderStyle = FlxTextBorderStyle.OUTLINE;
		add(infoTitleText);

		FlxG.scaleMode = new RatioScaleMode();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			var position = FlxG.mouse.getPosition();
			var location = convertPointToLocation(Config.instance.tileSize, position);
			
			trace('mouse pressed at: ' + position + ' -> ' + location.trace());

			if (gameState == 'placingStart') {
				location.setTile(tiles, TileTypes.VILLAGE);
				gameState = 'playing';
			} else if (gameState == 'playing') {
				if (selected != null) {
					selected.setTile(upperLayer, TileTypes.EMPTY);
				}
				
				selected = location;
			}
		}

		if (selected != null) {
			selected.setTile(upperLayer, TileTypes.SELECTOR);

			var selectedTile = selected.getTile(tiles);
			infoTitleText.text = TileTypeInfo[selectedTile];
		}
	}
}