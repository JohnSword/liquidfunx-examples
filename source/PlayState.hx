package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.display.shapes.FlxShapeCircle;

class PlayState extends FlxState
{

	override public function create():Void
	{
		super.create();

		var box = new FlxShapeBox(10, 10, 50, 50, { thickness:1, color:FlxColor.WHITE }, FlxColor.BLUE);
		add(box);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
