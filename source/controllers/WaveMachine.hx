package controllers;

import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;
import box2d.particle.ParticleGroupDef;

class WaveMachine extends TestbedTest {

  var m_joint : RevoluteJoint;
  var m_time : Float;

  override public function step() : Void {
    super.step();
    var hz : Float = TestbedSettings.Hz;
    if (hz > 0) {
      m_time += 1 / hz;
    }
    m_joint.setMotorSpeed(0.05 * MathUtils.cos(m_time) * MathUtils.PI);
  }

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.allowSleep = false;
    bd.position.set(0.0, 10.0);
    var body : Body = m_world.createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(0.5, 10.0, new Vec2(20.0, 0.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(0.5, 10.0, new Vec2(-20.0, 0.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(20.0, 0.5, new Vec2(0.0, 10.0), 0.0);
    body.createFixtureShape(shape, 5.0);
    shape.setAsBox2(20.0, 0.5, new Vec2(0.0, -10.0), 0.0);
    body.createFixtureShape(shape, 5.0);

    var jd : RevoluteJointDef = new RevoluteJointDef();
    jd.bodyA = getGroundBody();
    jd.bodyB = body;
    jd.localAnchorA.set(0.0, 10.0);
    jd.localAnchorB.set(0.0, 0.0);
    jd.referenceAngle = 0.0;
    jd.motorSpeed = 0.05 * MathUtils.PI;
    jd.maxMotorTorque = 1e7;
    jd.enableMotor = true;
    m_joint = cast m_world.createJoint(jd);

    m_world.setParticleRadius(0.15);
    m_world.setParticleDamping(0.2);

    var pd : ParticleGroupDef = new ParticleGroupDef();
    pd.flags = 0;

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(9.0, 9.0, new Vec2(0.0, 10.0), 0.0);

    pd.shape = shape;
    m_world.createParticleGroup(pd);

    m_time = 0;
  }

  override public function getTestName() : String {
    return "Wave Machine";
  }
}

