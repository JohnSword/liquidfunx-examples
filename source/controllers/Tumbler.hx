package controllers;

import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;

class Tumbler extends TestbedTest {
  private static var MAX_NUM : Int = 800;
  var m_joint : RevoluteJoint;
  var m_count : Int;

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.allowSleep = false;
    bd.position.set(0.0, 10.0);
    var body : Body = m_world.createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(0.5, 10.0, new Vec2(10.0, 0.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(0.5, 10.0, new Vec2(-10.0, 0.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(10.0, 0.5, new Vec2(0.0, 10.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(10.0, 0.5, new Vec2(0.0, -10.0), 0.0);
    body.createFixtureShape(shape, 5.0);

    var jd : RevoluteJointDef = new RevoluteJointDef();
    jd.bodyA = getGroundBody();
    jd.bodyB = body;
    jd.localAnchorA.set(0.0, 10.0);
    jd.localAnchorB.set(0.0, 0.0);
    jd.referenceAngle = 0.0;
    jd.motorSpeed = 0.05 * MathUtils.PI;
    jd.maxMotorTorque = 1e8;
    jd.enableMotor = true;
    m_joint = cast m_world.createJoint(jd);
    m_count = 0;
  }

  override public function step() : Void {
    super.step();

    if (m_count < MAX_NUM) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.0, 10.0);
      var body : Body = m_world.createBody(bd);

      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(0.125, 0.125);
      body.createFixtureShape(shape, 1.0);

      ++m_count;
    }
  }

  override public function getTestName() : String {
    return "Tumbler";
  }
}

