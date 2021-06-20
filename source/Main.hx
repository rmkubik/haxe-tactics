package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(Config.instance.pixelsWide, Config.instance.pixelsHigh, PlayState));
	}
}
