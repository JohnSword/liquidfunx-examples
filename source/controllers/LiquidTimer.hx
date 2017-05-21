package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.ChainShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.particle.ParticleGroupDef;
import box2d.particle.ParticleType;

class LiquidTimer extends TestbedTest {

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    var ground : Body = m_world.createBody(bd);

    var shape : ChainShape = new ChainShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(-20, 0);
    vertices[1] = new Vec2(20, 0);
    vertices[2] = new Vec2(20, 40);
    vertices[3] = new Vec2(-20, 40);
    shape.createLoop(vertices, 4);
    ground.createFixtureShape(shape, 0.0);


    m_world.setParticleRadius(0.15);
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(20, 4, new Vec2(0, 36), 0);
    var pd : ParticleGroupDef = new ParticleGroupDef();
    pd.flags = ParticleType.b2_tensileParticle | ParticleType.b2_viscousParticle;
    pd.shape = shape;
    m_world.createParticleGroup(pd);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20, 32), new Vec2(-12, 32));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-11, 32), new Vec2(20, 32));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-12, 32), new Vec2(-12, 28));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-11, 32), new Vec2(-11, 28));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-16, 24), new Vec2(8, 20));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(16, 16), new Vec2(-8, 12));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-12, 8), new Vec2(-12, 0));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-4, 8), new Vec2(-4, 0));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(4, 8), new Vec2(4, 0));
    body.createFixtureShape(shape, 0.1);

    var bd : BodyDef = new BodyDef();
    var body : Body = m_world.createBody(bd);
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(12, 8), new Vec2(12, 0));
    body.createFixtureShape(shape, 0.1);
  }

  override public function getTestName() : String {
    return "Liquid Timer";
  }
}

