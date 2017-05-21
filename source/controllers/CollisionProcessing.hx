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
 * Created at 2:51:18 PM Jan 23, 2011
 */
package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

import de.polygonal.ds.ListSet;

// import haxe.ds.;

/**
 * @author Daniel Murphy
 */
class CollisionProcessing extends TestbedTest {

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    // Ground body
    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-50.0, 0.0), new Vec2(50.0, 0.0));

    var sd : FixtureDef = new FixtureDef();
    sd.shape = shape;

    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);
    ground.createFixture(sd);

    var xLo : Float = -5.0, xHi = 5.0;
    var yLo : Float = 2.0, yHi = 35.0;

    // Small triangle
    var vertices : Vector<Vec2> = new Vector<Vec2>(3);
    vertices[0] = new Vec2(-1.0, 0.0);
    vertices[1] = new Vec2(1.0, 0.0);
    vertices[2] = new Vec2(0.0, 2.0);

    var polygon : PolygonShape = new PolygonShape();
    polygon.set(vertices, 3);

    var triangleShapeDef : FixtureDef = new FixtureDef();
    triangleShapeDef.shape = polygon;
    triangleShapeDef.density = 1.0;

    var triangleBodyDef : BodyDef = new BodyDef();
    triangleBodyDef.type = BodyType.DYNAMIC;
    triangleBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body1 : Body = getWorld().createBody(triangleBodyDef);
    body1.createFixture(triangleShapeDef);

    // Large triangle (recycle definitions)
    vertices[0].mulLocal(2.0);
    vertices[1].mulLocal(2.0);
    vertices[2].mulLocal(2.0);
    polygon.set(vertices, 3);

    triangleBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body2 : Body = getWorld().createBody(triangleBodyDef);
    body2.createFixture(triangleShapeDef);

    // Small box
    polygon.setAsBox(1.0, 0.5);

    var boxShapeDef : FixtureDef = new FixtureDef();
    boxShapeDef.shape = polygon;
    boxShapeDef.density = 1.0;

    var boxBodyDef : BodyDef = new BodyDef();
    boxBodyDef.type = BodyType.DYNAMIC;
    boxBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body3 : Body = getWorld().createBody(boxBodyDef);
    body3.createFixture(boxShapeDef);

    // Large box (recycle definitions)
    polygon.setAsBox(2.0, 1.0);
    boxBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body4 : Body = getWorld().createBody(boxBodyDef);
    body4.createFixture(boxShapeDef);

    // Small circle
    var circle : CircleShape = new CircleShape();
    circle.m_radius = 1.0;

    var circleShapeDef : FixtureDef = new FixtureDef();
    circleShapeDef.shape = circle;
    circleShapeDef.density = 1.0;

    var circleBodyDef : BodyDef = new BodyDef();
    circleBodyDef.type = BodyType.DYNAMIC;
    circleBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body5 : Body = getWorld().createBody(circleBodyDef);
    body5.createFixture(circleShapeDef);

    // Large circle
    circle.m_radius *= 2.0;
    circleBodyDef.position.set(MathUtils.randomFloat(xLo, xHi), MathUtils.randomFloat(yLo, yHi));

    var body6 : Body = getWorld().createBody(circleBodyDef);
    body6.createFixture(circleShapeDef);
  }

override public function step() : Void {
    super.step();

    // We are going to destroy some bodies according to contact
    // points. We must buffer the bodies that should be destroyed
    // because they may belong to multiple contact points.
    // var nuke : HashMap<Body> = new HashMap<Body>();
    var nuke : ListSet<Body> = new ListSet<Body>();
    
    // Traverse the contact results. Destroy bodies that
    // are touching heavier bodies.
    for(i in 0 ... getPointCount()) {
      var point : ContactPoint = points[i];

      var body1 : Body = point.fixtureA.getBody();
      var body2 : Body = point.fixtureB.getBody();
      var mass1 : Float = body1.getMass();
      var mass2 : Float = body2.getMass();

      if (mass1 > 0.0 && mass2 > 0.0) {
        if (mass2 > mass1) {
          nuke.set(body1);
        } else {
          nuke.set(body2);
        }
      }
    }

    // Sort the nuke array to group duplicates.
    // Arrays.sort(nuke);

    // Destroy the bodies, skipping duplicates.
    for (b in nuke) {
    // for (Body b : nuke) {
      if (b != getBomb()) {
        getWorld().destroyBody(b);
      }
    }

    nuke = null;
  }

override public function getTestName() : String {
    return "Collision Processing";
  }
}

