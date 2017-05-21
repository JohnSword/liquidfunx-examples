package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.particle.ParticleGroupDef;
import box2d.particle.ParticleType;

class Particles extends TestbedTest {
  
  override public function getTestName() : String {
    return "Particles";
  }

  override public function initTest() : Void {
    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(-40, -10);
    vertices[1] = new Vec2(40, -10);
    vertices[2] = new Vec2(40, 0);
    vertices[3] = new Vec2(-40, 0);
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(-40, -1);
    vertices[1] = new Vec2(-20, -1);
    vertices[2] = new Vec2(-20, 20);
    vertices[3] = new Vec2(-40, 30);
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices[0] = new Vec2(20, -1);
    vertices[1] = new Vec2(40, -1);
    vertices[2] = new Vec2(40, 30);
    vertices[3] = new Vec2(20, 20);
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    m_world.setParticleRadius(0.35);
    m_world.setParticleDamping(0.2);

    var shape : CircleShape = new CircleShape();
    shape.m_p.set(0, 30);
    shape.m_radius = 20;
    var pd : ParticleGroupDef = new ParticleGroupDef();
    pd.flags = ParticleType.b2_waterParticle;
    pd.shape = shape;
    m_world.createParticleGroup(pd);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);
    var shape : CircleShape = new CircleShape();
    shape.m_p.set(0, 80);
    shape.m_radius = 5;
    body.createFixtureShape(shape, 0.5);

  }
}

