enum TileTypes {
	EMPTY;
	SELECTOR;
	TREE;
	BUSH_BERRY;
	BUSH;
	STONE;
	STONE_MINED;
	GOLD;
	GOLD_MINED;
	TOWER;
	VILLAGE;
	GRANARY;
	CAMP;
	WOODCUTTERS;
	SAPLING_NEW;
	SAPLING_OLD;
	STUMP;
	GROUND_1;
	GROUND_2;
	GROUND_3;
	GROUND_4;
	FOG_1;
	FOG_2;
}

typedef Cost = {
	?wood:Int,
	?food:Int,
	?stone:Int,
	?gold:Int,
}

typedef TileInfo = {
	id: Int,
	name: String, 
	?cost: Cost,
	?range: Range,
	?resource: {
		type: String,
		value: Int,
		harvested: TileTypes
	},
	?effect: {
		func: String,
		?args: EffectArgs
	}
}

enum Shape {
	SQUARE;
	DIAMOND;
}

typedef Range = {
	value: Int,
	shape: Shape
}

typedef EffectArgs = {
	?range: Range,
	?targets: Array<TileTypes>,
	?resource: String,
	?quantity: Int
}

var TileTypeInfo:Map<TileTypes, TileInfo> = [
	TileTypes.EMPTY => {
		id: 0,
		name: 'Empty',
	},
	TileTypes.SELECTOR => {
		id: 21,
		name: 'Empty',
	},
	TileTypes.TREE => {
		id: 63,
		name: 'Tree',
		resource: {
			value: 10,
			type: 'wood',
			harvested: TileTypes.STUMP
		} 
	},
	TileTypes.BUSH_BERRY => {
		id: 64,
		name: 'Berries',
		resource: {
			value: 5,
			type: 'food',
			harvested: TileTypes.BUSH
		} 
	},
	TileTypes.STONE => {
		id: 61,
		name: 'Stone',
		resource: {
			value: 20,
			type: 'stone',
			harvested: TileTypes.STONE_MINED
		} 
	},
	TileTypes.GOLD => {
		id: 62,
		name: 'Gold',
		resource: {
			value: 20,
			type: 'gold',
			harvested: TileTypes.GOLD_MINED
		} 
	},
	TileTypes.TOWER => {
		id: 72,
		name: "Tower",
		cost: {
			stone: 10,
		},
		range: {
			value: 3,
			shape: Shape.DIAMOND
		}
	},
	TileTypes.VILLAGE => {
		id: 74,
		name: 'Village',
		cost: {
			food: 10,
			wood: 10,
		},
		range: {
			value: 2,
			shape: Shape.DIAMOND,
		},
		effect: {
			func: 'modifyResources',
			args: {
				resource: 'gold',
				quantity: 10
			}
		}
	},
	TileTypes.GRANARY => {
		id: 76,
		name: 'Granary',
		cost: {
			wood: 10,
		},
		range: {
			value: 1,
			shape: Shape.SQUARE
		},
		effect: {
			func: 'harvest',
			args: {
				range: {
					value: 1,
					shape: Shape.SQUARE
				},
				targets: [TileTypes.BUSH_BERRY]
			}
		}
	},
	TileTypes.CAMP => {
		id: 77,
		name: 'Miners',
		cost: {
			wood: 10,
		},
		range: {
			value: 1,
			shape: Shape.SQUARE
		},
		effect: {
			func: 'harvest',
			args: {
				range: {
					value: 1,
					shape: Shape.SQUARE
				},
				targets: [TileTypes.STONE, TileTypes.GOLD]
			}
		}
	},
	TileTypes.WOODCUTTERS => {
		id: 86,
		name: 'Choppers',
		cost: {
			wood: 5,
		},
		range: {
			value: 1,
			shape: Shape.SQUARE
		},
		effect: {
			func: 'harvest',
			args: {
				range: {
					value: 1,
					shape: Shape.SQUARE
				},
				targets: [TileTypes.TREE, TileTypes.SAPLING_NEW, TileTypes.SAPLING_OLD]
			}
		}
	},
	TileTypes.STUMP => {
		id: 90,
		name: 'Stump',
	},
	TileTypes.BUSH => {
		id: 80,
		name: 'Bush',
	},
	TileTypes.STONE_MINED => {
		id: 70,
		name: 'Stone',
	},
	TileTypes.GOLD_MINED => {
		id: 100,
		name: 'Gold',
	},
	TileTypes.SAPLING_NEW => {
		id: 88,
		name: 'Sapling',
		cost: {
			gold: 5,
		},
		resource: {
			value: 1,
			type: 'wood',
			harvested: TileTypes.STUMP
		},
		range: {
			value: 0,
			shape: Shape.DIAMOND,
		}
	},
	TileTypes.SAPLING_OLD => {
		id: 89,
		name: 'Sapling',
		resource: {
			value: 3,
			type: 'wood',
			harvested: TileTypes.STUMP
		} 
	},
	TileTypes.GROUND_1 => {
		id: 22,
		name: 'Ground'
	},
	TileTypes.GROUND_2 => {
		id: 23,
		name: 'Ground'
	},
	TileTypes.GROUND_3 => {
		id: 24,
		name: 'Ground'
	},
	TileTypes.GROUND_4 => {
		id: 25,
		name: 'Ground'
	},
	TileTypes.FOG_1 => {
		id: 53,
		name: 'Fog'
	},
	TileTypes.FOG_2 => {
		id: 54,
		name: 'Fog'
	}
];

function findTileTypeById(id:Int): TileTypes {
	for (key => tileInfo in TileTypeInfo) {
		if (id == tileInfo.id) {
			return key;
		}
	}

	return null;
}