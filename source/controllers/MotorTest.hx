package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.MotorJoint;
import box2d.dynamics.joints.MotorJointDef;

class MotorTest extends TestbedTest {
  var m_joint : MotorJoint;
  var m_time : Float;
  var m_go : Bool;

override public function initTest() : Void {
    trace("Keys: (s) pause");
    
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));
    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    getGroundBody().createFixture(fd);

    // Define motorized body
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 8.0);
    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(2.0, 0.5);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.friction = 0.6;
    fd.density = 2.0;
    body.createFixture(fd);

    var mjd : MotorJointDef = new MotorJointDef();
    mjd.initialize(getGroundBody(), body);
    mjd.maxForce = 1000.0;
    mjd.maxTorque = 1000.0;
    m_joint = cast m_world.createJoint(mjd);

    m_go = false;
    m_time = 0.0;
  }

  override public function keyPressed(keyCode : Int) : Void {
    super.keyPressed(keyCode);

    switch (keyCode) {
      case 83: //'s'
        m_go = !m_go;
    }
  }

  // pooling
  var linearOffset : Vec2 = new Vec2();
  var color : Color3f = new Color3f(0.9, 0.9, 0.9);

  override public function step() : Void {
    var hz : Float = TestbedSettings.Hz;
    if (m_go && hz > 0.0) {
      m_time += 1.0 / hz;
    }

    linearOffset.x = 6.0 * MathUtils.sin(2.0 * m_time);
    linearOffset.y = 8.0 + 4.0 * MathUtils.sin(1.0 * m_time);

    var angularOffset : Float = 4.0 * m_time;

    m_joint.setLinearOffset(linearOffset);
    m_joint.setAngularOffset(angularOffset);

    getDebugDraw().drawPoint(linearOffset, 4.0, color);
    super.step();
  }

override public function getTestName() : String {
    return "Motor Joint";
  }
}

