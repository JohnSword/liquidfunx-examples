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
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;
import box2d.callbacks.RayCastCallback;

import haxe.ds.Vector;

enum Mode {
    e_closest;
    e_any;
    e_multiple;
}

class RayCastTest extends TestbedTest {

  public static var e_maxBodies : Int = 256;

  var m_bodyIndex : Int = 0;
  var m_bodies : Vector<Body>;
  var m_userData : Vector<Int>;
  var m_polygons : Vector<PolygonShape>;
  var m_circle : CircleShape;
  var m_edge : EdgeShape;
  var m_angle : Float = 0;
  var m_mode : Mode;

  override public function getTestName() : String {
    return "Raycast";
  }

  override public function initTest() : Void {
    trace("Press 1-6 to drop stuff, m to change the mode");
    trace("Polygon 1 is filtered");
    trace("Mode = " + m_mode);

    m_bodies = new Vector<Body>(e_maxBodies);
    m_userData = new Vector<Int>(e_maxBodies);
    m_polygons = new Vector<PolygonShape>(4);
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

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
  
    m_edge = new EdgeShape();
    m_edge.set(new Vec2(-1.0, 0.0), new Vec2(1.0, 0.0));

    m_bodyIndex = 0;

    m_angle = 0.0;

    m_mode = Mode.e_closest;
  }

  var ccallback : RayCastClosestCallback = new RayCastClosestCallback();
  var acallback : RayCastAnyCallback = new RayCastAnyCallback();
  var mcallback : RayCastMultipleCallback = new RayCastMultipleCallback();

  // pooling
  var point1 : Vec2 = new Vec2();
  var d : Vec2 = new Vec2();
  var pooledHead : Vec2 = new Vec2();
  var point2 : Vec2 = new Vec2();

  override public function step() : Void {
    var advanceRay : Bool = TestbedSettings.pause == false || TestbedSettings.singleStep;
    
    super.step();

    var L : Float = 11.0;
    point1.set(0.0, 10.0);
    d.set(L * MathUtils.cos(m_angle), L * MathUtils.sin(m_angle));
    point2.setVec(point1);
    point2.addLocalVec(d);

    if (m_mode == Mode.e_closest) {
      ccallback.init();
      getWorld().raycast(ccallback, point1, point2);

      if (ccallback.m_hit) {
        getDebugDraw().drawPoint(ccallback.m_point, 5.0, new Color3f(0.4, 0.9, 0.4));
        getDebugDraw().drawSegment(point1, ccallback.m_point, new Color3f(0.8, 0.8, 0.8));
        pooledHead.setVec(ccallback.m_normal);
        pooledHead.mulLocal(.5).addLocalVec(ccallback.m_point);
        getDebugDraw().drawSegment(ccallback.m_point, pooledHead, new Color3f(0.9, 0.9, 0.4));
      } else {
        getDebugDraw().drawSegment(point1, point2, new Color3f(0.8, 0.8, 0.8));
      }
    } else if (m_mode == Mode.e_any) {
      acallback.init();
      getWorld().raycast(acallback, point1, point2);

      if (acallback.m_hit) {
        getDebugDraw().drawPoint(acallback.m_point, 5.0, new Color3f(0.4, 0.9, 0.4));
        getDebugDraw().drawSegment(point1, acallback.m_point, new Color3f(0.8, 0.8, 0.8));
        pooledHead.setVec(acallback.m_normal);
        pooledHead.mulLocal(.5).addLocalVec(acallback.m_point);
        getDebugDraw().drawSegment(acallback.m_point, pooledHead, new Color3f(0.9, 0.9, 0.4));
      } else {
        getDebugDraw().drawSegment(point1, point2, new Color3f(0.8, 0.8, 0.8));
      }
    } else if (m_mode == Mode.e_multiple) {
      mcallback.init();
      getWorld().raycast(mcallback, point1, point2);
      getDebugDraw().drawSegment(point1, point2, new Color3f(0.8, 0.8, 0.8));

      for(i in 0 ... mcallback.m_count) {
        var p : Vec2 = mcallback.m_points[i];
        var n : Vec2 = mcallback.m_normals[i];
        getDebugDraw().drawPoint(p, 5.0, new Color3f(0.4, 0.9, 0.4));
        getDebugDraw().drawSegment(point1, p, new Color3f(0.8, 0.8, 0.8));
        pooledHead.setVec(n);
        pooledHead.mulLocal(.5).addLocalVec(p);
        getDebugDraw().drawSegment(p, pooledHead, new Color3f(0.9, 0.9, 0.4));
      }
    }

    if (advanceRay) {
      m_angle += 0.25 * MathUtils.PI / 180.0;
    }
  }

  private function Create(index : Int) {
    if (m_bodies[m_bodyIndex] != null) {
      getWorld().destroyBody(m_bodies[m_bodyIndex]);
      m_bodies[m_bodyIndex] = null;
    }

    var bd : BodyDef = new BodyDef();

    var x : Float = Math.random() * 20 - 10;
    var y : Float = (Math.random() * 20);
    bd.position.set(x, y);
    bd.angle = Math.random() * MathUtils.TWOPI - MathUtils.PI;

    m_userData[m_bodyIndex] = index;
    bd.userData = m_userData[m_bodyIndex];

    if (index == 4) {
      bd.angularDamping = 0.02;
    }

    m_bodies[m_bodyIndex] = getWorld().createBody(bd);

    if (index < 4) {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_polygons[index];
      fd.friction = 0.3;
      m_bodies[m_bodyIndex].createFixture(fd);
    } else if (index < 5) {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_circle;
      fd.friction = 0.3;

      m_bodies[m_bodyIndex].createFixture(fd);
    } else {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_edge;
      fd.friction = 0.3;

      m_bodies[m_bodyIndex].createFixture(fd);
    }

    m_bodyIndex = (m_bodyIndex + 1) % e_maxBodies;
  }

  private function DestroyBody() : Void {
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
        Create(argKeyCode - 49);
      case 50: //'2'
        Create(argKeyCode - 49);
      case 51: //'3'
        Create(argKeyCode - 49);
      case 52: //'4'
        Create(argKeyCode - 49);
      case 53: //'5'
        Create(argKeyCode - 49);
      case 54: //'6'
        Create(argKeyCode - 49);

      case 68: //'d'
        DestroyBody();

      case 77: //'m'
        if (m_mode == Mode.e_closest) {
          m_mode = Mode.e_any;
        } else if (m_mode == Mode.e_any) {
          m_mode = Mode.e_multiple;
        } else if (m_mode == Mode.e_multiple) {
          m_mode = Mode.e_closest;
        }
        trace(m_mode);
    }
  }

}

// This test demonstrates how to use the world ray-cast feature.
// NOTE: we are intentionally filtering one of the polygons, therefore
// the ray will always miss one type of polygon.

// This callback finds the closest hit. Polygon 0 is filtered.
class RayCastClosestCallback implements RayCastCallback {

  public var m_hit : Bool;
  public var m_point : Vec2;
  public var m_normal : Vec2;

  public function new() {}

  public function init() : Void {
    m_hit = false;
  }

  public function reportFixture(fixture : Fixture, point : Vec2, normal : Vec2, fraction : Float) : Float {
    var body : Body = fixture.getBody();
    var userData : Dynamic = body.getUserData();
    if (userData != null) {
      var index : Int = cast userData;
      if (index == 0) {
        // filter
        return -1;
      }
    }

    m_hit = true;
    m_point = point;
    m_normal = normal;
    return fraction;
  }

}

// This callback finds any hit. Polygon 0 is filtered.
class RayCastAnyCallback implements RayCastCallback {

  public var m_hit : Bool;
  public var m_point : Vec2;
  public var m_normal : Vec2;

  public function new() {}

  public function init() : Void {
    m_hit = false;
  }

public function reportFixture(fixture : Fixture, point : Vec2, normal : Vec2, fraction : Float) : Float {
    var body : Body = fixture.getBody();
    var userData : Dynamic = body.getUserData();
    if (userData != null) {
      var index : Int = cast userData;
      if (index == 0) {
        // filter
        return -1;
      }
    }

    m_hit = true;
    m_point = point;
    m_normal = normal;
    return 0;
  }

}

// This ray cast collects multiple hits along the ray. Polygon 0 is filtered.
class RayCastMultipleCallback implements RayCastCallback {
  public var e_maxCount : Int = 30;
  public var m_points : Vector<Vec2> = new Vector<Vec2>(30);
  public var m_normals : Vector<Vec2> = new Vector<Vec2>(30);
  public var m_count : Int;

  public function new() {}

  public function init() : Void {
    for(i in 0 ... e_maxCount) {
      m_points[i] = new Vec2();
      m_normals[i] = new Vec2();
    }
    m_count = 0;
  }

  public function reportFixture(fixture : Fixture, point : Vec2, normal : Vec2, fraction : Float) : Float {
    var body : Body = fixture.getBody();
    var index : Int = 0;
    var userData : Dynamic = body.getUserData();
    if (userData != null) {
      index = cast userData;
      if (index == 0) {
        // filter
        return -1;
      }
    }

    m_points[m_count].setVec(point);
    m_normals[m_count].setVec(normal);
    ++m_count;

    if (m_count == e_maxCount) {
      return 0;
    }

    return 1;
  }

}

