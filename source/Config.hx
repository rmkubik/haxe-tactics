class Config {
  public var tilesHigh = 10;
  public var tilesWide = 10;
  public var tileSize = 16;
  public var topMargin = 16;
  public var bottomMargin = 32;
  public var globalScale = 4; // use this in Project.xml
  public var pixelsWide:Int;
  public var pixelsHigh:Int;

  // read-only property
  public static final instance:Config = new Config();
  
  private function new () {
    pixelsWide = tilesWide * tileSize;
    pixelsHigh = tilesHigh * tileSize + topMargin + bottomMargin;
  }
}