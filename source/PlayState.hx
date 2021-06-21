package;

import Matricies;
import StringTools;
import TextRow;
import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.FlxText;
import flixel.util.FlxColor;

function pickRandom<T>(rand:FlxRandom, items:Array<T>) {
	return items[rand.int(0, items.length - 1)];
}

function pickRandomWeighted<T>(rand:FlxRandom, items:Array<T>, weights:Array<Float>) {
	return items[rand.weightedPick(weights)];
}

var TileTypes = {
	EMPTY: 0,
	SELECTOR: 21,
	TREE: 63,
	BUSH_BERRY: 64,
	STONE: 61,
	GOLD: 62,
	VILLAGE: 74
}

var TileTypeInfo:Map<Int, Any> = [
	TileTypes.EMPTY => 'Empty',
	TileTypes.SELECTOR => 'Empty',
	TileTypes.TREE => 'Tree',
	TileTypes.BUSH_BERRY => 'Berries',
	TileTypes.STONE => 'Stone',
	TileTypes.GOLD => 'Gold',
	TileTypes.VILLAGE => 'Village'
];


class PlayState extends FlxState
{
	var rand:FlxRandom;
	var gameState:String;
	
	var grid:Grid;
	var BACKGROUND_LAYER = 0;
	var TILES_LAYER = 1;
	var UPPER_LAYER = 2;

	var food:Int;
	var gold:Int;
	var stone:Int;
	var wood:Int;

	var resourceTextRow:TextRow;
	
	var selected:Location = null;
	
	var infoTitleText:FlxText;
	var infoBodyTest:FlxText;
	var buildGrid:Grid;

	override public function create()
	{
		super.create();

		rand = new FlxRandom();

		var tilesBitmapData = openfl.Assets.getBitmapData(AssetPaths.sprites__png);
		var tilesheet:FlxGraphic = FlxGraphic.fromBitmapData(tilesBitmapData);

		var width = Config.instance.tilesWide;
		var height = Config.instance.tilesHigh;

		// placingStart, playing, placing
		gameState = 'placingStart';
		food = 0;
		gold = 0;
		wood = 0;
		stone = 0;

		bgColor = new FlxColor(0xFF663931);

		grid = new Grid(
			new FlxPoint(0, Config.instance.topMargin),
			tilesheet,
			this,
			(location) -> {
				if (gameState == 'placingStart') {
					location.setTile(grid.layers[TILES_LAYER], TileTypes.VILLAGE);
					gameState = 'playing';
				} else if (gameState == 'playing') {
					if (selected != null) {
						selected.setTile(grid.layers[UPPER_LAYER], TileTypes.EMPTY);
					}
					
					selected = location;
				}
			}
		);

		grid.createLayer(
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
			}, width, height)	
		);

		var tileData = constructMatrix(
			(row, col) -> pickRandomWeighted(rand, [TileTypes.EMPTY, TileTypes.TREE, TileTypes.BUSH_BERRY, TileTypes.STONE, TileTypes.GOLD], [75, 17, 6, 2, 1]),
			width,
			height
		);
		grid.createLayer(tileData);
		
		grid.createLayer(constructMatrix((row, col) -> 0, width, height));

		// top bar
		var textWidth = Config.instance.tileSize * 2;
	
		resourceTextRow = new TextRow(4, textWidth, new FlxPoint(0, 0), this);
		updateTextBar();

		// bottom bar
		var buildPanelWidth = Config.instance.tileSize * 6;
		var buildPanelPosition = new FlxPoint(
			0,
			Config.instance.pixelsHigh - Config.instance.bottomMargin
		);
		
		 
		
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

		updateTextBar();

		grid.update();

		if (selected != null) {
			selected.setTile(grid.layers[UPPER_LAYER], TileTypes.SELECTOR);

			var selectedTile = selected.getTile(grid.layers[TILES_LAYER]);
			infoTitleText.text = TileTypeInfo[selectedTile];
		}
	}

	function updateTextBar() {
		var format = count -> StringTools.lpad(Std.string(count), '0', 2);
		
		resourceTextRow.updateTexts([
			'F: ' + format(food),
			'W: ' + format(wood),
			'G: ' + format(gold),
			'S: ' + format(stone)
		]);
	}
}