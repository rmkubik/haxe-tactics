import Matricies;
import flixel.FlxSprite;

class Tower {
  var location:Location;
  var base:FlxSprite;
  var top:FlxSprite;

  public function new(add, location) {
    this.location = location;

    base = new FlxSprite(location.row * 16, location.col * 16);
    top = new FlxSprite(location.row * 16, location.col * 16);
    
    base.loadGraphic(AssetPaths.sprites__png, true, 16, 16);
    top.loadGraphic(AssetPaths.sprites__png, true, 16, 16);

    base.loadGraphic(AssetPaths.sprites__png, true, 16, 16);
    top.loadGraphic(AssetPaths.sprites__png, true, 16, 16);

    base.animation.add("idle", [29], 1, false);
    top.animation.add("idle", [39], 1, false);

    base.animation.play("idle");
    top.animation.play("idle");

    add(base);
    add(top);
  }

  public function update() {
    top.angle = top.angle + 1 % 360;
  }
}