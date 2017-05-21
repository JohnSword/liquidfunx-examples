package;

import box2d.collision.Collision.PointState;
import box2d.common.Vec2;
import box2d.dynamics.Fixture;

/**
 * Contact point for {@link TestbedTest}.
 * @author Daniel Murphy
 */
class ContactPoint {
	public var fixtureA : Fixture;
	public var fixtureB : Fixture;
	public var normal : Vec2 = new Vec2();
	public var position : Vec2 = new Vec2();
	public var state : PointState;
	public var normalImpulse : Float = 0;
	public var tangentImpulse : Float = 0;
	public var separation : Float = 0;
	public function new() {}
}

