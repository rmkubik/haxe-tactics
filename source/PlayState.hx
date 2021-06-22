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
	VILLAGE: 74,
	GRANARY: 76,
	CAMP: 77,
	WOODCUTTERS: 86
}

var TileTypeInfo:Map<Int, Any> = [
	TileTypes.EMPTY => 'Empty',
	TileTypes.SELECTOR => 'Empty',
	TileTypes.TREE => 'Tree',
	TileTypes.BUSH_BERRY => 'Berries',
	TileTypes.STONE => 'Stone',
	TileTypes.GOLD => 'Gold',
	TileTypes.VILLAGE => 'Village',
	TileTypes.GRANARY => 'Granary',
	TileTypes.CAMP => 'Camp',
	TileTypes.WOODCUTTERS => 'Cutters'
];

var UNSELECTED_INFO = ". . .";


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

		// playing, placing
		gameState = 'playing';
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
				if (!location.isInBounds(grid.layers[0])) {
					return;
				}

				clearSelectors();

				if (gameState == 'placing') {
					var newTile = selected.getTile(buildGrid.layers[0]);
					location.setTile(grid.layers[TILES_LAYER], newTile);
					
					gameState = 'playing';
				} else if (gameState == 'playing') {					

				}

				select(location);
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
		var buildPanelPosition = new FlxPoint(
			0,
			Config.instance.pixelsHigh - Config.instance.bottomMargin
		);
		buildGrid = new Grid(
			buildPanelPosition,
			tilesheet,
			this,
			location -> {
				if (!location.isInBounds(buildGrid.layers[0])) {
					return;
				}

				clearSelectors();

				gameState = 'placing';	
				
				select(location);
			}
		);
		buildGrid.createLayer([
			[TileTypes.VILLAGE, TileTypes.GRANARY, TileTypes.CAMP, TileTypes.WOODCUTTERS]
		]);
		buildGrid.createLayer([
			[0, 0, 0, 0]
		]);
		
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
			UNSELECTED_INFO
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
		buildGrid.update();
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

	function clearSelectors() {
		if (selected != null) {
			// clear old selections
			if (selected.isInBounds(grid.layers[UPPER_LAYER])) {
				selected.setTile(grid.layers[UPPER_LAYER], TileTypes.EMPTY);
			}

			if (selected.isInBounds(buildGrid.layers[1])) {
				selected.setTile(buildGrid.layers[1], TileTypes.EMPTY);
			}
		}
	}

	function select(location:Location) {
		// de-select exisiting selection
		if (location.isEqual(selected)) {
			selected = null;
		} else {
			selected = location;
		}

		// update info
		if (selected != null) {
			// render selections
			if (gameState == 'playing') {
				selected.setTile(grid.layers[UPPER_LAYER], TileTypes.SELECTOR);
	
				var selectedTile = selected.getTile(grid.layers[TILES_LAYER]);
				infoTitleText.text = TileTypeInfo[selectedTile];
			} else if (gameState == 'placing') {
				selected.setTile(buildGrid.layers[1], TileTypes.SELECTOR);
	
				var selectedTile = selected.getTile(buildGrid.layers[0]);
				infoTitleText.text = TileTypeInfo[selectedTile];
			}
		} else {
			infoTitleText.text = UNSELECTED_INFO;
		}
	}
}