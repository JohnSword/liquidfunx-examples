/*******************************************************************************
 * Copyright (c) 2013, Daniel Murphy
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 	* Redistributions of source code must retain the above copyright notice,
 * 	  this list of conditions and the following disclaimer.
 * 	* Redistributions in binary form must reproduce the above copyright notice,
 * 	  this list of conditions and the following disclaimer in the documentation
 * 	  and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
/**
 *.created at 3:31:07 PM Jan 14, 2011
 */
package controllers;

import box2d.callbacks.RayCastCallback;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class EdgeShapes extends TestbedTest {

  var e_maxBodies : Int = 256;
  var m_bodyIndex : Int;
  var m_bodies : Vector<Body> = new Vector<Body>(256);
  var m_polygons : Vector<PolygonShape> = new Vector<PolygonShape>(4);
  var m_circle : CircleShape;
  var m_angle : Float = 0;

  override public function initTest() : Void {
    trace("Press 1-5 to drop stuff");

    for(i in 0 ... m_bodies.length) {
      m_bodies[i] = null;
    }

    // Ground body
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var x1 : Float = -20.0;
    var y1 : Float = 2.0 * MathUtils.cos(x1 / 10.0 * MathUtils.PI);
    for(i in 0 ... 80) {
      var x2 : Float = x1 + 0.5;
      var y2 : Float = 2.0 * MathUtils.cos(x2 / 10.0 * MathUtils.PI);

      var shape : EdgeShape = new EdgeShape();
      shape.set(new Vec2(x1, y1), new Vec2(x2, y2));
      ground.createFixtureShape(shape, 0.0);

      x1 = x2;
      y1 = y2;
    }

    var vertices : Vector<Vec2> = new Vector<Vec2>(3);
    vertices[0] = new Vec2(-0.5, 0.0);
    vertices[1] = new Vec2(0.5, 0.0);
    vertices[2] = new Vec2(0.0, 1.5);
    m_polygons[0] = new PolygonShape();
    m_polygons[0].set(vertices, 3);

    var vertices : Vector<Vec2> = new Vector<Vec2>(3);
    vertices[0] = new Vec2(-0.1, 0.0);
    vertices[1] = new Vec2(0.1, 0.0);
    vertices[2] = new Vec2(0.0, 1.5);
    m_polygons[1] = new PolygonShape();
    m_polygons[1].set(vertices, 3);

    var w : Float = 1.0;
    var b : Float = w / (2.0 + MathUtils.sqrt(2.0));
    var s : Float = MathUtils.sqrt(2.0) * b;

    var vertices : Vector<Vec2> = new Vector<Vec2>(8);
    vertices[0] = new Vec2(0.5 * s, 0.0);
    vertices[1] = new Vec2(0.5 * w, b);
    vertices[2] = new Vec2(0.5 * w, b + s);
    vertices[3] = new Vec2(0.5 * s, w);
    vertices[4] = new Vec2(-0.5 * s, w);
    vertices[5] = new Vec2(-0.5 * w, b + s);
    vertices[6] = new Vec2(-0.5 * w, b);
    vertices[7] = new Vec2(-0.5 * s, 0.0);

    m_polygons[2] = new PolygonShape();
    m_polygons[2].set(vertices, 8);

    m_polygons[3] = new PolygonShape();
    m_polygons[3].setAsBox(0.5, 0.5);

    m_circle = new CircleShape();
    m_circle.m_radius = 0.5;

    m_bodyIndex = 0;
    m_angle = 0.0;
  }

  public function Create(index : Int) : Void {
    if (m_bodies[m_bodyIndex] != null) {
      getWorld().destroyBody(m_bodies[m_bodyIndex]);
      m_bodies[m_bodyIndex] = null;
    }

    var bd : BodyDef = new BodyDef();

    var x : Float = MathUtils.randomFloat(-10.0, 10.0);
    var y : Float = MathUtils.randomFloat(10.0, 20.0);
    bd.position.set(x, y);
    bd.angle = MathUtils.randomFloat(-MathUtils.PI, MathUtils.PI);
    bd.type = BodyType.DYNAMIC;

    if (index == 4) {
      bd.angularDamping = 0.02;
    }

    m_bodies[m_bodyIndex] = getWorld().createBody(bd);

    if (index < 4) {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_polygons[index];
      fd.friction = 0.3;
      fd.density = 20.0;
      m_bodies[m_bodyIndex].createFixture(fd);
    } else {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_circle;
      fd.friction = 0.3;
      fd.density = 20.0;
      m_bodies[m_bodyIndex].createFixture(fd);
    }

    m_bodyIndex = (m_bodyIndex + 1) % e_maxBodies;
  }

  public function DestroyBody() : Void {
    for(i in 0 ... e_maxBodies) {
      if (m_bodies[i] != null) {
        getWorld().destroyBody(m_bodies[i]);
        m_bodies[i] = null;
        return;
      }
    }
  }

override public function keyPressed(argKeyCode : Int) : Void {
    switch (argKeyCode) {
      case 49: //'1'
      case 50: //'2'
      case 51: //'3'
      case 52: //'4'
      case 53: //'5'
        Create(argKeyCode - 1);
      case 68: //'d'
        DestroyBody();
    }
  }

  var escallback : EdgeShapesCallback = new EdgeShapesCallback();

  override public function step() : Void {
    var advanceRay : Bool = TestbedSettings.pause == false || TestbedSettings.singleStep;

    super.step();

    var L : Float = 25.0;
    var point1 : Vec2 = new Vec2(0.0, 10.0);
    var d : Vec2 = new Vec2(L * MathUtils.cos(m_angle), -L * MathUtils.abs(MathUtils.sin(m_angle)));
    var point2 : Vec2 = point1.add(d);


    escallback.m_fixture = null;
    getWorld().raycast(escallback, point1, point2);

    if (escallback.m_fixture != null) {
      getDebugDraw().drawPoint(escallback.m_point, 5.0, new Color3f(0.4, 0.9, 0.4));

      getDebugDraw().drawSegment(point1, escallback.m_point, new Color3f(0.8, 0.8, 0.8));

      var head : Vec2 = escallback.m_normal.mul(.5).addLocalVec(escallback.m_point);
      getDebugDraw().drawSegment(escallback.m_point, head, new Color3f(0.9, 0.9, 0.4));
    } else {
      getDebugDraw().drawSegment(point1, point2, new Color3f(0.8, 0.8, 0.8));
    }

    if (advanceRay) {
      m_angle += 0.25 * MathUtils.PI / 180.0;
    }
  }

override public function getTestName() : String {
    return "Edge Shapes";
  }

}


class EdgeShapesCallback implements RayCastCallback {
  public function new() {
    m_fixture = null;
  }

  public function reportFixture(fixture : Fixture, point : Vec2, normal : Vec2, fraction : Float) : Float {
    m_fixture = fixture;
    m_point = point;
    m_normal = normal;
    return fraction;
  }

  public var m_fixture : Fixture;
  public var m_point : Vec2;
  public var m_normal : Vec2;
}

