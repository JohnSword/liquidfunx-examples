package controllers;

import box2d.collision.shapes.ChainShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.particle.ParticleGroupDef;

import haxe.ds.Vector;

class DamBreak extends TestbedTest {

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    var ground : Body = m_world.createBody(bd);

    var shape : ChainShape = new ChainShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices.set(0, new Vec2(-20, 0));
    vertices.set(1, new Vec2(20, 0));
    vertices.set(2, new Vec2(20, 40));
    vertices.set(3, new Vec2(-20, 40));
    shape.createLoop(vertices, 4);
    ground.createFixtureShape(shape, 0.0);

    m_world.setParticleRadius(0.15);
    m_world.setParticleDamping(0.2);
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(8, 10, new Vec2(-12, 10.1), 0);
    var pd : ParticleGroupDef = new ParticleGroupDef();
    pd.shape = shape;
    m_world.createParticleGroup(pd);
  }

override public function getTestName() : String {
    return "Dam Break";
  }
}

