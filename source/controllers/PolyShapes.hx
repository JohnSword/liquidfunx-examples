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
 * Created at 1:41:40 PM Jan 23, 2011
 */
package controllers;

import box2d.callbacks.DebugDraw;
import box2d.callbacks.QueryCallback;
import box2d.collision.AABB;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.collision.shapes.Shape;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Settings;
import box2d.common.Transform;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;
import box2d.pooling.IWorldPool;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class PolyShapes extends TestbedTest {

  var k_maxBodies : Int = 256;
  var m_bodyIndex : Int = 0;
  var m_bodies : Vector<Body> = new Vector<Body>(256);
  var m_polygons : Vector<PolygonShape> = new Vector<PolygonShape>(4);
  var m_circle : CircleShape;

  override public function initTest() : Void {
    trace("Press 1-5 to drop stuff");
    trace("Press 'a' to (de)activate some bodies");
    trace("Press 'd' to destroy a body");
    trace("Up to 30 bodies in the target circle are highlighted");

    // Ground body
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

    m_bodyIndex = 0;
  }

  private function Create(index : Int) : Void {
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    var x : Float = MathUtils.randomFloat(-2.0, 2.0);
    bd.position.set(x, 10.0);
    bd.angle = MathUtils.randomFloat(-MathUtils.PI, MathUtils.PI);

    if (index == 4) {
      bd.angularDamping = 0.02;
    }

    m_bodies[m_bodyIndex] = getWorld().createBody(bd);

    if (index < 4) {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_polygons[index];
      fd.density = 1.0;
      fd.friction = 0.3;
      m_bodies[m_bodyIndex].createFixture(fd);
    } else {
      var fd : FixtureDef = new FixtureDef();
      fd.shape = m_circle;
      fd.density = 1.0;
      fd.friction = 0.3;

      m_bodies[m_bodyIndex].createFixture(fd);
    }

    m_bodyIndex = (m_bodyIndex + 1) % k_maxBodies;
  }

  private function DestroyBody() : Void {
    for(i in 0 ... k_maxBodies) {
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
        Create(0);
      case 50: //'2'
        Create(1);
      case 51: //'3'
        Create(2);
      case 52: //'4'
        Create(3);
      case 53: //'5'
        Create(4);
      case 65: //'a'
        var i : Int = 0;
        while ( i < k_maxBodies) {
          if (m_bodies[i] != null) {
            var active : Bool = m_bodies[i].isActive();
            m_bodies[i].setActive(!active);
          }
          i += 2;
        }
      case 68: //'d'
        DestroyBody();
    }
  }

  /**
   * @see org.jbox2d.testbed.framework.TestbedTest#step(org.jbox2d.testbed.framework.TestbedSettings)
   */
  override public function step() : Void {
    super.step();

    var callback : PolyShapesCallback = new PolyShapesCallback(getWorld().getPool());
    callback.m_circle.m_radius = 2.0;
    callback.m_circle.m_p.set(0.0, 2.1);
    callback.m_transform.setIdentity();
    callback.debugDraw = getDebugDraw();

    var aabb : AABB = new AABB();
    callback.m_circle.computeAABB(aabb, callback.m_transform, 0);

    getWorld().queryAABB(callback, aabb);

    var color : Color3f = new Color3f(0.4, 0.7, 0.8);
    getDebugDraw().drawCircle(callback.m_circle.m_p, callback.m_circle.m_radius, color);
  }

  /**
   * @see org.jbox2d.testbed.framework.TestbedTest#getTestName()
   */
  override public function getTestName() : String {
    return "PolyShapes";
  }

}

/**
 * This callback is called by b2World::QueryAABB. We find all the fixtures that overlap an AABB. Of
 * those, we use b2TestOverlap to determine which fixtures overlap a circle. Up to 30 overlapped
 * fixtures will be highlighted with a yellow border.
 * 
 * @author Daniel Murphy
 */

class PolyShapesCallback implements QueryCallback {
  public var e_maxCount : Int = 30;
  public var m_circle : CircleShape = new CircleShape();
  public var m_transform : Transform = new Transform();
  public var debugDraw : DebugDraw;
  public var m_count : Int;
  public var p : IWorldPool;

  public function new(argWorld : IWorldPool) {
    m_count = 0;
    p = argWorld;
  }

  public function DrawFixture(fixture : Fixture) : Void {
    var color : Color3f = new Color3f(0.95, 0.95, 0.6);
    var xf : Transform = fixture.getBody().getTransform();

    switch (fixture.getType()) {
      case CIRCLE: {
        var circle : CircleShape = cast fixture.getShape();

        var center : Vec2 = Transform.mul(xf, circle.m_p);
        var radius : Float = circle.m_radius;

        debugDraw.drawCircle(center, radius, color);
      }
      case POLYGON: {
        var poly : PolygonShape = cast fixture.getShape();
        var vertexCount : Int = poly.m_count;
        var vertices : Vector<Vec2> = new Vector<Vec2>(Settings.maxPolygonVertices);
        for(i in 0 ... vertexCount) {
          vertices[i] = Transform.mul(xf, poly.m_vertices[i]);
        }
        debugDraw.drawPolygon(vertices, vertexCount, color);
      }
      default:
    }
  }

  public function reportFixture(fixture : Fixture) : Bool {
    if (m_count == e_maxCount) {
      return false;
    }

    var body : Body = fixture.getBody();
    var shape : Shape = fixture.getShape();

    var overlap : Bool = p.getCollision().testOverlap(shape, 0, m_circle, 0, body.getTransform(), m_transform);

    if (overlap) {
      DrawFixture(fixture);
      ++m_count;
    }

    return true;
  }
}

