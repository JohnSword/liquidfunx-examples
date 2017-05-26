package;

import TestbedController.MouseBehavior;
import TestbedController.UpdateBehavior;
import openfl.display.Sprite;
import box2d.dynamics.Body;
import box2d.dynamics.World;


class Main extends Sprite {
	var points:Array<Float> = [for (value in 0...10) value];

	private var e_count : Int = 4;
	private var m_world : World;
	private var stepCount : Int = 0;
	private var bodies : Array<Body>;

	public static var WORLD_SCALE:Float = 1 / 30;
	
	public function new() {
		#if (debug && cpp)
			new debugger.HaxeRemote(true, "localhost");
		#end
		super();

		this.addChild(new FPS());

		var m_debugdraw = new HxDebugDraw(this, true);
		var model : TestbedModel = new TestbedModel(this);
		model.setDebugDraw(m_debugdraw);

		var controller : TestbedController = new TestbedController(model, UpdateBehavior.UPDATE_CALLED, MouseBehavior.NORMAL, this);
		controller.updateExtents(960 / 2, 640 / 2);
		
		// the array of tests to load is in the TestbedModel class
		controller.playTest(22);
		// controller.playTest(model.getTestsSize() - 1);
		controller.start();
	}

 	// // public function update(elapsed:Float):Void {
 	// public function update(e):Void {
	// 	// for(i in 0 ... bodies.length) {
	// 	// 	var body : Body = bodies[i];
	// 	// 	trace(body.getPosition().x + " " + body.getPosition().y);
	// 	// }
	// 	var timeStep : Float = 1 / 30;
	// 	if(timeStep > 0) {
	// 		++stepCount;
	// 	}
	// 	m_world.step(timeStep, 8, 3);
	// 	this.graphics.clear();
	// 	m_world.drawDebugData();
	// }

}
