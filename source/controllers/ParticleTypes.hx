package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.particle.ParticleGroupDef;
import box2d.particle.ParticleType;

class ParticleTypes extends TestbedTest {

  var circle : Body;
  var flags : Int = ParticleType.b2_tensileParticle;

  override public function initTest() : Void {
    trace("'a' Clear");
    trace("'e' Elastic " + ((flags & ParticleType.b2_elasticParticle) != 0));
    trace("'q' Powder  " + ((flags & ParticleType.b2_powderParticle) != 0));
    trace("'t' Tensile " + ((flags & ParticleType.b2_tensileParticle) != 0));
    trace("'v' Viscous " + ((flags & ParticleType.b2_viscousParticle) != 0));

    var bd : BodyDef = new BodyDef();
    var ground : Body = m_world.createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(-40, -10);
    vertices[1] = new Vec2(40, -10);
    vertices[2] = new Vec2(40, 0);
    vertices[3] = new Vec2(-40, 0);
    shape.set(vertices, 4);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(-40, -1);
    vertices[1] = new Vec2(-20, -1);
    vertices[2] = new Vec2(-20, 20);
    vertices[3] = new Vec2(-40, 30);
    shape.set(vertices, 4);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(20, -1);
    vertices[1] = new Vec2(40, -1);
    vertices[2] = new Vec2(40, 30);
    vertices[3] = new Vec2(20, 20);
    shape.set(vertices, 4);
    ground.createFixtureShape(shape, 0.0);

    // m_world.setParticleRadius(0.2);
    m_world.setParticleRadius(0.3);
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(20, 10, new Vec2(0, 10), 0);
    var pd : ParticleGroupDef = new ParticleGroupDef();
    pd.flags = pd.flags;
    pd.shape = shape;
    m_world.createParticleGroup(pd);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.KINEMATIC;
    var body : Body = m_world.createBody(bd);
    circle = body;
    var shape : CircleShape = new CircleShape();
    shape.m_p.set(0, 5);
    shape.m_radius = 1;
    body.createFixtureShape(shape, 0.1);
    body.setLinearVelocity(new Vec2(-6, 0.0));

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(1, 1, new Vec2(-10, 5), 0);
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(1, 1, new Vec2(10, 5), 0.5);
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(0, 20), new Vec2(1, 21));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(3, 20), new Vec2(4, 21));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-3, 21), new Vec2(-2, 20));
    body.createFixtureShape(shape, 0.1);
  }

  override public function step() : Void {
    super.step();

    var p : Vec2 = circle.getTransform().p;
    var v : Vec2 = circle.getLinearVelocity();

    if ((p.x < -10.0 && v.x < 0.0) || (p.x > 10.0 && v.x > 0.0)) {
      v.x = -v.x;
      circle.setLinearVelocity(v);
    }
    var flagsBuffer : Vector<Int> = m_world.getParticleFlagsBuffer();
    for(i in 0 ... m_world.getParticleCount()) {
      flagsBuffer[i] = flags;
    }
  }

  override public function keyPressed(keyCode : Int) : Void {
    super.keyPressed(keyCode);
    var toggle : Int = 0;
    trace(keyCode);
    switch (keyCode) {
      case 65: //'a'
        flags = 0;
      case 69: //'e'
        toggle = ParticleType.b2_elasticParticle;
      case 81: //'q'
        toggle = ParticleType.b2_powderParticle;
      // case 't':
      //   toggle = ParticleType.b2_tensileParticle;
      // case 'v':
      //   toggle = ParticleType.b2_viscousParticle;
    }
    if (toggle != 0) {
      if ((flags & toggle) != 0) {
        flags = flags & ~toggle;
      } else {
        flags = flags | toggle;
      }
    }
  }

  override public function getTestName() : String {
    return "ParticleTypes";
  }
}

