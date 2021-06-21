package;

import flixel.math.FlxPoint;
import flixel.text.FlxText;

class TextRow 
{
  var texts: Array<FlxText> = [];
  var textWidth: Int;
  var position: FlxPoint;
  
	public function new(columnCount, textWidth, position, state)
	{
    this.textWidth = textWidth;
    this.position = position;
    
    createTexts(columnCount);

    add(state);
	}

  function createTexts(columnCount) {
    for (i in 0...columnCount) {
      var text = new FlxText(position.x + (i * textWidth), position.y, textWidth, '');
      text.borderStyle = FlxTextBorderStyle.OUTLINE;
      
      this.texts.push(text);
    }
  }

  public function updateTexts(strings) {
    for (i in 0...strings.length) {
      this.texts[i].text = strings[i];
    }
  }

  function add(state) {
    for (text in texts) {
      state.add(text);
    }
  }
}
