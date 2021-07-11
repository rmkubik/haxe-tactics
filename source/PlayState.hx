package;

import Arrays.some;
import Matricies;
import StringTools;
import TextRow;
import TileTypes;
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

function getLocationsInRange(origin:Location, range:Range): Array<Location> {
	var rangeFinders = [
		Shape.DIAMOND => createDiamond,
		Shape.SQUARE => createSquare
	];
	
	return rangeFinders[range.shape](origin, range.value);
}

function computeCostString(tileInfo:TileInfo): String {
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

function computeResourceString(tileInfo:TileInfo): String {
	var resource = tileInfo.resource;

	if (resource == null) {
		return UNSELECTED_INFO;
	}

	var resourceStrings = [
		'food' => 'F',
		'wood' => 'W',
		'gold' => 'G',
		'stone' => 'S'
	];

	return resourceStrings[resource.type] + ': ' + resource.value;
}

var UNSELECTED_INFO = ". . .";


class PlayState extends FlxState
{
	var rand:FlxRandom;
	// playing, placing
	var gameState:String = 'playing';
	
	var grid:Grid;
	var BACKGROUND_LAYER = 0;
	var TILES_LAYER = 1;
	var FOG_LAYER = 2;
	var UPPER_LAYER = 3;

	var food:Int = 10;
	var gold:Int = 10;
	var stone:Int = 10;
	var wood:Int = 10;

	var resourceTextRow:TextRow;
	
	var selected:Location = null;
	
	var infoTitleText:FlxText;
	var infoDescriptionText:FlxText;
	var buildGrid:Grid;
	var buildings:Array<TileTypes> = [TileTypes.VILLAGE, TileTypes.GRANARY, TileTypes.CAMP, TileTypes.WOODCUTTERS, TileTypes.TOWER, TileTypes.SAPLING_NEW];


	override public function create()
	{
		super.create();

		rand = new FlxRandom();

		var tilesBitmapData = openfl.Assets.getBitmapData(AssetPaths.sprites__png);
		var tilesheet:FlxGraphic = FlxGraphic.fromBitmapData(tilesBitmapData);

		var width = Config.instance.tilesWide;
		var height = Config.instance.tilesHigh;

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
					// var newTile = selected.getTile(buildGrid.layers[0]);
					// location.setTile(grid.layers[TILES_LAYER], newTile);

					// clearFog();
					
					// gameState = 'playing';
					if (tryPlaceBuilding(location)) {
						// make time pass
						trace('placed building');
						ageTrees(location);
					}
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
					return TileTypes.GROUND_1;
				} else if (isEvenRow && !isEvenCol) {
					return TileTypes.GROUND_2;
				} else if (!isEvenRow && isEvenCol) {
					return TileTypes.GROUND_2;
				} else {
					return TileTypes.GROUND_1;
				}
			}, width, height)	
		);

		var tileData = constructMatrix(
			(row, col) -> {
				var choice = pickRandomWeighted(
					rand,
					[TileTypes.EMPTY, TileTypes.TREE, TileTypes.BUSH_BERRY, TileTypes.STONE, TileTypes.GOLD],
					[75, 17, 6, 2, 1]
				);

				return choice;
			},
			width,
			height
		);
		grid.createLayer(tileData);
		
		grid.createLayer(
			constructMatrix((row, col) -> {
				var isEvenRow = row % 2 == 0;
				var isEvenCol = col % 2 == 0;

				// 2 color checkers
				if (isEvenRow && isEvenCol) {
					return TileTypes.FOG_1;
				} else if (isEvenRow && !isEvenCol) {
					return TileTypes.FOG_2;
				} else if (!isEvenRow && isEvenCol) {
					return TileTypes.FOG_2;
				} else {
					return TileTypes.FOG_1;
				}
			}, width, height)	
		);

		grid.createLayer(constructMatrix((row, col) -> TileTypes.EMPTY, width, height));

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
		buildGrid.createLayer([buildings.map(a -> TileTypes.EMPTY)]);
		
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

				var fogTile = selected.getTile(grid.layers[FOG_LAYER]);
				if (fogTile != TileTypes.EMPTY) {
					infoTitleText.text = "Fogged";
					infoDescriptionText.text = UNSELECTED_INFO;
					return;
				}
	
				var selectedTile = selected.getTile(grid.layers[TILES_LAYER]);
				infoTitleText.text = TileTypeInfo[selectedTile].name;
				infoDescriptionText.text = computeResourceString(TileTypeInfo[selectedTile]);
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

	function tryPlaceBuilding(location:Location): Bool {
		// is location valid
		var currentFogTile = location.getTile(grid.layers[FOG_LAYER]);

		if (currentFogTile != TileTypes.EMPTY) {
			trace('fogged');
			return false;
		}

		var currentTile = location.getTile(grid.layers[TILES_LAYER]);
		if (currentTile != TileTypes.EMPTY) {
			trace('occupied');
			return false;
		}

		var newTile = selected.getTile(buildGrid.layers[0]);
		var tileInfo = TileTypeInfo[newTile];

		if (!canAfford(tileInfo)) {
			trace('too expensive');
			return false;
		}

		location.setTile(grid.layers[TILES_LAYER], newTile);

		clearFog();
		
		removeCost(tileInfo);

		if (tileInfo.effect != null) {
			triggerEffect(location, tileInfo);
		}
		
		return true;
	}

	function triggerEffect(origin:Location, tileInfo:TileInfo): Void {
		var effect = tileInfo.effect;

		var effectMap = [
			'harvest' => harvest
		];

		effectMap[effect.func](origin, effect.args.range, effect.args.targets);
	}

	function harvest(origin:Location, range:Range, targets:Array<TileTypes>): Void {
		var locations:Array<Location> = getLocationsInRange(origin, range);

		// find tiles in those locations that match one of the targets
		var targetLocations = locations.filter(location -> {
			var tile = location.getTile(grid.layers[TILES_LAYER]);
			return targets.contains(tile);
		});

		// TODO: We need to see each of these steps animated indiviually
		// we don't even get to see newly revealed trees before we
		// immediately chop them down.
		for (targetLocation in targetLocations) {
			var tileType = targetLocation.getTile(grid.layers[TILES_LAYER]);
			var tileInfo = TileTypeInfo[tileType];
			
			addResources(tileInfo);

			targetLocation.setTile(grid.layers[TILES_LAYER], tileInfo.resource.harvested);
		}
	}

	function canAfford(tileInfo: TileInfo): Bool {
		var canAfford = true;
		var cost = tileInfo.cost;

		if (cost == null) {
			return true;
		}
		
		if (cost.food != null && cost.food > food) {
			canAfford = false;
		}

		if (cost.wood != null && cost.wood > wood) {
			canAfford = false;
		}

		if (cost.gold != null && cost.gold > gold) {
			canAfford = false;
		}

		if (cost.stone != null && cost.stone > stone) {
			canAfford = false;
		}

		return canAfford;
	}

	function removeCost(tileInfo:TileInfo): Void {
		var cost = tileInfo.cost;

		if (cost == null) {
			return;
		}
		
		if (cost.food != null) {
			food -= cost.food;
		}

		if (cost.wood != null) {
			wood -= cost.wood;
		}

		if (cost.gold != null) {
			gold -= cost.gold;
		}

		if (cost.stone != null) {
			stone -= cost.stone;
		}
	}

	function addResources(tileInfo:TileInfo): Void {
		var resource = tileInfo.resource;

		if (resource == null) {
			return;
		}
		
		switch (resource.type) {
			case 'food': food += resource.value;
			case 'wood': wood += resource.value;
			case 'gold': gold += resource.value;
			case 'stone': stone += resource.value;
		}
	}

	function clearFog() {
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
			var tilesInRange = getLocationsInRange(buildingLocation, range);

			buildingRanges.push(tilesInRange);
		}

		// set each location as cleared
		for (ranges in buildingRanges) {
			for (location in ranges) {
				location.setTile(grid.layers[FOG_LAYER], TileTypes.EMPTY);
			}
		}
	}

	function ageTrees(placedLocation: Location) {
		var dimensions = grid.getDimensions();
		var tileData = grid.layers[TILES_LAYER].getData();
		var matrix = covertArrayToMatrix(tileData, dimensions.width);

		var tileLayer = grid.layers[TILES_LAYER];
		
		forEachMatrix(location -> {
			if (location.isEqual(placedLocation)) {
				// skip this one, it was just placed
				return;
			}

			var tile = location.getTile(tileLayer);

			switch (tile) {
				case TileTypes.SAPLING_NEW:
					location.setTile(tileLayer, TileTypes.SAPLING_OLD);
				case TileTypes.SAPLING_OLD:
					location.setTile(tileLayer, TileTypes.TREE);
				default: {}
			}
		}, matrix);
	}
}