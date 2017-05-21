package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;

class EdgeTest extends TestbedTest {

  override public function initTest() : Void {
    var ground : Body = getGroundBody();

    var v1 : Vec2 = new Vec2(-10.0, 0.0), v2 = new Vec2(-7.0, -2.0), v3 = new Vec2(-4.0, 0.0);
    var v4 : Vec2 = new Vec2(0.0, 0.0), v5 = new Vec2(4.0, 0.0), v6 = new Vec2(7.0, 2.0), v7 =
        new Vec2(10.0, 0.0);

    var shape : EdgeShape = new EdgeShape();

    shape.set(v1, v2);
    shape.m_hasVertex3 = true;
    shape.m_vertex3.setVec(v3);
    ground.createFixtureShape(shape, 0.0);

    shape.set(v2, v3);
    shape.m_hasVertex0 = true;
    shape.m_hasVertex3 = true;
    shape.m_vertex0.setVec(v1);
    shape.m_vertex3.setVec(v4);
    ground.createFixtureShape(shape, 0.0);

    shape.set(v3, v4);
    shape.m_hasVertex0 = true;
    shape.m_hasVertex3 = true;
    shape.m_vertex0.setVec(v2);
    shape.m_vertex3.setVec(v5);
    ground.createFixtureShape(shape, 0.0);

    shape.set(v4, v5);
    shape.m_hasVertex0 = true;
    shape.m_hasVertex3 = true;
    shape.m_vertex0.setVec(v3);
    shape.m_vertex3.setVec(v6);
    ground.createFixtureShape(shape, 0.0);

    shape.set(v5, v6);
    shape.m_hasVertex0 = true;
    shape.m_hasVertex3 = true;
    shape.m_vertex0.setVec(v4);
    shape.m_vertex3.setVec(v7);
    ground.createFixtureShape(shape, 0.0);

    shape.set(v6, v7);
    shape.m_hasVertex0 = true;
    shape.m_vertex0.setVec(v5);
    ground.createFixtureShape(shape, 0.0);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(-0.5, 0.6);
    bd.allowSleep = false;
    var body : Body = m_world.createBody(bd);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 0.5;

    body.createFixtureShape(shape, 1.0);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(1.0, 0.6);
    bd.allowSleep = false;
    var body : Body = m_world.createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.5);

    body.createFixtureShape(shape, 1.0);
  }

override public function getTestName() : String {
    return "Edge Test";
  }

}

