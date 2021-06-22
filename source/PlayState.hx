package;

import Arrays.some;
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
	TOWER: 72,
	VILLAGE: 74,
	GRANARY: 76,
	CAMP: 77,
	WOODCUTTERS: 86
}

typedef Cost = {
	?wood:Int,
	?food:Int,
	?stone:Int,
	?gold:Int,
}

typedef TileInfo = {
	name:String, 
	?cost: Cost,
	?range: Int
}

var TileTypeInfo:Map<Int, TileInfo> = [
	TileTypes.EMPTY => {
		name: 'Empty',
	},
	TileTypes.SELECTOR => {
		name: 'Empty',
	},
	TileTypes.TREE => {
		name: 'Tree',
	},
	TileTypes.BUSH_BERRY => {
		name: 'Berries',
	},
	TileTypes.STONE => {
		name: 'Stone',
	},
	TileTypes.GOLD => {
		name: 'Gold',
	},
	TileTypes.TOWER => {
		name: "Tower",
		cost: {
			stone: 10,
		},
		range: 3
	},
	TileTypes.VILLAGE => {
		name: 'Village',
		cost: {
			food: 10,
			wood: 10,
		},
		range: 2
	},
	TileTypes.GRANARY => {
		name: 'Granary',
		cost: {
			wood: 10,
		},
		range: 1
	},
	TileTypes.CAMP => {
		name: 'Camp',
		cost: {
			wood: 10,
		},
		range: 1
	},
	TileTypes.WOODCUTTERS => {
		name: 'Choppers',
		cost: {
			wood: 10,
		},
		range: 1
	},
];

function computeCostString(tileInfo:TileInfo) {
	var cost = tileInfo.cost;

	if (cost == null) {
		return 'Free';
	}

	var string = '';

	if (cost.food != null) {
		string += 'F: ' + cost.food + " ";
	}

	if (cost.wood != null) {
		string += 'W: ' + cost.wood + " ";
	}

	if (cost.gold != null) {
		string += 'G: ' + cost.gold + " ";
	}

	if (cost.stone != null) {
		string += 'S: ' + cost.stone + " ";
	}

	if (string == '') {
		return 'Free';
	}

	return string;
}

var UNSELECTED_INFO = ". . .";


class PlayState extends FlxState
{
	var rand:FlxRandom;
	var gameState:String;
	
	var grid:Grid;
	var BACKGROUND_LAYER = 0;
	var TILES_LAYER = 1;
	var UPPER_LAYER = 2;
	var FOG_LAYER = 3;

	var food:Int;
	var gold:Int;
	var stone:Int;
	var wood:Int;

	var resourceTextRow:TextRow;
	
	var selected:Location = null;
	
	var infoTitleText:FlxText;
	var infoDescriptionText:FlxText;
	var buildGrid:Grid;
	var buildings:Array<Int> = [TileTypes.VILLAGE, TileTypes.GRANARY, TileTypes.CAMP, TileTypes.WOODCUTTERS, TileTypes.TOWER];


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

					clearFog();
					
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

		grid.createLayer(
			constructMatrix((row, col) -> {
				var isEvenRow = row % 2 == 0;
				var isEvenCol = col % 2 == 0;

				// 2 color checkers
				if (isEvenRow && isEvenCol) {
					return 53;
				} else if (isEvenRow && !isEvenCol) {
					return 54;
				} else if (!isEvenRow && isEvenCol) {
					return 54;
				} else {
					return 53;
				}
			}, width, height)	
		);

		// set starting village
		var startingVillage = new Location(
			rand.int(0, width - 1),
			rand.int(0, height - 1)
		);

		startingVillage.setTile(grid.layers[TILES_LAYER], TileTypes.VILLAGE);

		clearFog();

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

		buildGrid.createLayer([buildings]);
		buildGrid.createLayer([buildings.map(a -> 0)]);
		
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
		
		infoDescriptionText = new FlxText(
			infoPanelPosition.x,
			infoPanelPosition.y + Config.instance.tileSize,
			infoPanelWidth,
			UNSELECTED_INFO
		);
		infoDescriptionText.borderStyle = FlxTextBorderStyle.OUTLINE;
		add(infoDescriptionText);


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
			// return to playing state
			gameState = 'playing';
		} else {
			selected = location;
		}

		// update info
		if (selected != null) {
			// render selections
			if (gameState == 'playing') {
				selected.setTile(grid.layers[UPPER_LAYER], TileTypes.SELECTOR);
	
				var selectedTile = selected.getTile(grid.layers[TILES_LAYER]);
				infoTitleText.text = TileTypeInfo[selectedTile].name;
			} else if (gameState == 'placing') {
				selected.setTile(buildGrid.layers[1], TileTypes.SELECTOR);
	
				var selectedTile = selected.getTile(buildGrid.layers[0]);
				infoTitleText.text = TileTypeInfo[selectedTile].name;
				infoDescriptionText.text = computeCostString(TileTypeInfo[selectedTile]);
			}
		} else {
			infoTitleText.text = UNSELECTED_INFO;
			infoDescriptionText.text = UNSELECTED_INFO;
		}
	}

	function clearFog() {
		// TODO: this should be refactored somewhere else reusuable...
		// var startingFogRemovals = createDiamond(startingVillage, 2);
		// for (location in startingFogRemovals) {
		// 	location.setTile(grid.layers[FOG_LAYER], 0);
		// }

		var dimensions = grid.getDimensions();
		var tileData = grid.layers[TILES_LAYER].getData();
		var matrix = covertArrayToMatrix(tileData, dimensions.width);
		
		var buildingLocations = [];
		
		forEachMatrix(location -> {
			if (some(building -> building == location.getTile(grid.layers[TILES_LAYER]), buildings)) {
				buildingLocations.push(location);
			}
		}, matrix);

		var buildingRanges = [];

		// find radius around each building
		for (buildingLocation in buildingLocations) {
			var building = buildingLocation.getTile(grid.layers[TILES_LAYER]);
			var range = TileTypeInfo[building].range;
			var tilesInRange = createDiamond(buildingLocation, range);

			buildingRanges.push(tilesInRange);
		}

		// set each location as cleared
		for (ranges in buildingRanges) {
			for (location in ranges) {
				location.setTile(grid.layers[FOG_LAYER], 0);
			}
		}
	}
}