package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.RevoluteJointDef;
import box2d.dynamics.joints.RopeJointDef;

class RopeTest extends TestbedTest {

  var m_ropeDef : RopeJointDef;
  var m_rope : Joint;

  override public function initTest() : Void {
    trace("Press (j) to toggle the rope joint.");

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    fd.friction = 0.2;
    fd.filter.categoryBits = 0x0001;
    fd.filter.maskBits = 0xFFFF & ~0x0002;

    var jd : RevoluteJointDef = new RevoluteJointDef();
    jd.collideConnected = false;

    var N : Int = 10;
    var y : Float = 15.0;
    m_ropeDef = new RopeJointDef();
    m_ropeDef.localAnchorA.set(0.0, y);

    var prevBody : Body = ground;
    for(i in 0 ... N) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.5 + 1.0 * i, y);
      if (i == N - 1) {
        shape.setAsBox(1.5, 1.5);
        fd.density = 100.0;
        fd.filter.categoryBits = 0x0002;
        bd.position.set(1.0 * i, y);
        bd.angularDamping = 0.4;
      }

      var body : Body = getWorld().createBody(bd);

      body.createFixture(fd);

      var anchor : Vec2 = new Vec2(i, y);
      jd.initialize(prevBody, body, anchor);
      getWorld().createJoint(jd);

      prevBody = body;
    }

    m_ropeDef.localAnchorB.setZero();

    var extraLength : Float = 0.01;
    m_ropeDef.maxLength = N - 1.0 + extraLength;
    m_ropeDef.bodyB = prevBody;

    m_ropeDef.bodyA = ground;
    m_rope = getWorld().createJoint(m_ropeDef);
  }

  override public function keyPressed(keyCode : Int) : Void {
    trace(keyCode);
    switch (keyCode) {
      case 74: //'j'
        if (m_rope != null) {
          getWorld().destroyJoint(m_rope);
          m_rope = null;
        } else {
          m_rope = getWorld().createJoint(m_ropeDef);
        }
    }
  }

  override public function getTestName() : String {
    return "Rope Joint";
  }

}

