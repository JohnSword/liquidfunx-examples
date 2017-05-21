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
 * Created at 1:13:43 AM Sep 3, 2010
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Rot;
import box2d.common.Transform;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class CompoundShapes extends TestbedTest {

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    bd.position.set(0.0, 0.0);
    var body : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(50.0, 0.0), new Vec2(-50.0, 0.0));

    body.createFixtureShape(shape, 0.0);

    var circle1 : CircleShape = new CircleShape();
    circle1.m_radius = 0.5;
    circle1.m_p.set(-0.5, 0.5);

    var circle2 : CircleShape = new CircleShape();
    circle2.m_radius = 0.5;
    circle2.m_p.set(0.5, 0.5);

    for(i in 0 ... 10) {
      var x : Float = MathUtils.randomFloat(-0.1, 0.1);
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(x + 5.0, 1.05 + 2.5 * i);
      bd.angle = MathUtils.randomFloat(-MathUtils.PI, MathUtils.PI);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(circle1, 2.0);
      body.createFixtureShape(circle2, 0.0);
    }

    var polygon1 : PolygonShape = new PolygonShape();
    polygon1.setAsBox(0.25, 0.5);

    var polygon2 : PolygonShape = new PolygonShape();
    polygon2.setAsBox2(0.25, 0.5, new Vec2(0.0, -0.5), 0.5 * MathUtils.PI);

    for(i in 0 ... 10) {
      var x : Float = MathUtils.randomFloat(-0.1, 0.1);
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(x - 5.0, 1.05 + 2.5 * i);
      bd.angle = MathUtils.randomFloat(-MathUtils.PI, MathUtils.PI);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(polygon1, 2.0);
      body.createFixtureShape(polygon2, 2.0);
    }

    var xf1 : Transform = new Transform();
    xf1.q.set(0.3524 * MathUtils.PI);
    Rot.mulToOut(xf1.q, new Vec2(1.0, 0.0), xf1.p);

    var vertices : Vector<Vec2> = new Vector<Vec2>(3);

    var triangle1 : PolygonShape = new PolygonShape();
    vertices[0] = Transform.mul(xf1, new Vec2(-1.0, 0.0));
    vertices[1] = Transform.mul(xf1, new Vec2(1.0, 0.0));
    vertices[2] = Transform.mul(xf1, new Vec2(0.0, 0.5));
    triangle1.set(vertices, 3);

    var xf2 : Transform = new Transform();
    xf2.q.set(-0.3524 * MathUtils.PI);
    Rot.mulToOut(xf2.q, new Vec2(-1.0, 0.0), xf2.p);

    var triangle2 : PolygonShape = new PolygonShape();
    vertices[0] = Transform.mul(xf2, new Vec2(-1.0, 0.0));
    vertices[1] = Transform.mul(xf2, new Vec2(1.0, 0.0));
    vertices[2] = Transform.mul(xf2, new Vec2(0.0, 0.5));
    triangle2.set(vertices, 3);

    for(i in 0 ... 10) {
      var x : Float = MathUtils.randomFloat(-0.1, 0.1);
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(x, 2.05 + 2.5 * i);
      bd.angle = 0.0;
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(triangle1, 2.0);
      body.createFixtureShape(triangle2, 2.0);
    }

    var bottom : PolygonShape = new PolygonShape();
    bottom.setAsBox(1.5, 0.15);

    var left : PolygonShape = new PolygonShape();
    left.setAsBox2(0.15, 2.7, new Vec2(-1.45, 2.35), 0.2);

    var right : PolygonShape = new PolygonShape();
    right.setAsBox2(0.15, 2.7, new Vec2(1.45, 2.35), -0.2);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 2.0);
    var body : Body = getWorld().createBody(bd);
    body.createFixtureShape(bottom, 4.0);
    body.createFixtureShape(left, 4.0);
    body.createFixtureShape(right, 4.0);
  }

override public function getTestName() : String {
    return "Compound Shapes";
  }
}

