package controllers;

import box2d.collision.Distance;
import box2d.collision.TimeOfImpact;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;

 class BulletTest extends TestbedTest {

  var m_body : Body;
  var m_bullet : Body;
  var m_x : Float = 0;
  
override public function getDefaultCameraPos() : Vec2 {
    return new Vec2(0, 6);
  }
  
override public function getDefaultCameraScale() : Float {
    return 40;
  }

override public function initTest() : Void {
      var bd : BodyDef = new BodyDef();
      bd.position.set(0.0, 0.0);
      var body : Body = m_world.createBody(bd);

      var edge : EdgeShape = new EdgeShape();

      edge.set(new Vec2(-10.0, 0.0), new Vec2(10.0, 0.0));
      body.createFixtureShape(edge, 0.0);

      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox2(0.2, 1.0, new Vec2(0.5, 1.0), 0.0);
      body.createFixtureShape(shape, 0.0);

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.0, 4.0);

      var box : PolygonShape = new PolygonShape();
      box.setAsBox(2.0, 0.1);

      m_body = m_world.createBody(bd);
      m_body.createFixtureShape(box, 1.0);

      box.setAsBox(0.25, 0.25);

      // m_x = RandomFloat(-1.0f, 1.0f);
      m_x = -0.06530577;
      bd.position.set(m_x, 10.0);
      bd.bullet = true;

      m_bullet = m_world.createBody(bd);
      m_bullet.createFixtureShape(box, 100.0);

      m_bullet.setLinearVelocity(new Vec2(0.0, -50.0));
  }

public function launch() : Void {
    m_body.setTransform(new Vec2(0.0, 4.0), 0.0);
    m_body.setLinearVelocity(new Vec2());
    m_body.setAngularVelocity(0.0);

    m_x = MathUtils.randomFloat(-1.0, 1.0);
    m_bullet.setTransform(new Vec2(m_x, 10.0), 0.0);
    m_bullet.setLinearVelocity(new Vec2(0.0, -50.0));
    m_bullet.setAngularVelocity(0.0);

    Distance.GJK_CALLS = 0;
    Distance.GJK_ITERS = 0;
    Distance.GJK_MAX_ITERS = 0;

    TimeOfImpact.toiCalls = 0;
    TimeOfImpact.toiIters = 0;
    TimeOfImpact.toiMaxIters = 0;
    TimeOfImpact.toiRootIters = 0;
    TimeOfImpact.toiMaxRootIters = 0;
  }

override public function step() : Void {
    super.step();

    // if (Distance.GJK_CALLS > 0) {
    //   trace(String.format("gjk calls = %d, ave gjk iters = %3.1, max gjk iters = %d",
    //       Distance.GJK_CALLS, Distance.GJK_ITERS * 1.0 / (Distance.GJK_CALLS),
    //       Distance.GJK_MAX_ITERS));
    // }

    // if (TimeOfImpact.toiCalls > 0) {
    //   addTextLine(String.format("toi calls = %d, ave toi iters = %3.1, max toi iters = %d",
    //       TimeOfImpact.toiCalls, TimeOfImpact.toiIters * 1f / (TimeOfImpact.toiCalls),
    //       TimeOfImpact.toiMaxRootIters));

    //   addTextLine(String.format("ave toi root iters = %3.1, max toi root iters = %d",
    //       TimeOfImpact.toiRootIters * 1f / (TimeOfImpact.toiCalls), TimeOfImpact.toiMaxRootIters));
    // }

    if (getStepCount() % 60 == 0) {
      launch();
    }
  }

override public function getTestName() : String {
    return "Bullet Test";
  }

}

