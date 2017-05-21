/*
* Copyright 2007 (c) Tim Knip, ascollada.org.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/

package;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.Lib;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * 
 */
class FPS extends Sprite
{
	
	public var time :Int;
	public var frameTime :Int;
	public var prevFrameTime :Int;
	public var secondTime :Int;
	public var prevSecondTime :Int;
	public var frames :Int;
	public var fps :String;
	public var tf:TextField;
	public var anim:String;
	public var bar:Shape;
	
	/**
	 * 
	 * @return
	 */
	public function new() {
		super();
		prevFrameTime = Lib.getTimer();
		prevSecondTime = Lib.getTimer();
		fps = "...";
		anim = "";
		frames = 0;
		
		bar = new Shape();
		addChild(bar);
		bar.x = 19;
		bar.y = 4;
		
		bar.graphics.beginFill(0xff0000, 0.5);
		bar.graphics.lineStyle();
		bar.graphics.drawRect(0, 0, 1, 15);
		bar.graphics.endFill();
		
		tf = new TextField();
		addChild(tf);
		tf.selectable = false;
		tf.x = 20;
		tf.y = 5;
		tf.width = 300;
		tf.height = 500;
		tf.defaultTextFormat = new TextFormat("Arial", 9, 0xffffff);
		tf.alpha = 0.6;
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	/**
	 * 
	 * @param	event
	 * @return
	 */
	private function enterFrameHandler( event:Event ):Void {
		time = Lib.getTimer();

		frameTime = time - prevFrameTime;
		secondTime = time - prevSecondTime;
		
		if(secondTime >= 1000) {
			fps = frames+"";
			frames = 0;
			prevSecondTime = time;
		}
		else
		{
			frames++;
		}
		
		bar.scaleX = frameTime;
		
		prevFrameTime = time;
		tf.text = ((fps + " FPS / ") + frameTime) + " MS" + anim;
	}
}


