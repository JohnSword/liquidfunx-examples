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
 * Created at 12:32:26 AM Aug 15, 2010
 */
package controllers;

import box2d.collision.TimeOfImpact;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.collision.shapes.Shape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;

/**
 * @author Daniel Murphy
 */
class ContinuousTest extends TestbedTest {

  var m_body : Body;
  var currFixture : Fixture;
  var m_poly : PolygonShape;
  var m_circle : CircleShape;
  var nextShape : Shape = null;
  var polygon : Bool = false;
  var m_angularVelocity : Float = 0;

  override public function getTestName() : String {
    return "Continuous";
  }

  public function switchObjects() : Void {
    if (polygon) {
      nextShape = m_circle;
    } else {
      nextShape = m_poly;
    }
    polygon = !polygon;
  }

  override public function initTest() : Void {
    trace("Press 'c' to change launch shape");

    var bd : BodyDef = new BodyDef();
    bd.position.set(0.0, 0.0);
    var body : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();

    shape.set(new Vec2(-10.0, 0.0), new Vec2(10.0, 0.0));
    body.createFixtureShape(shape, 0.0);

    var pshape : PolygonShape = new PolygonShape();
    pshape.setAsBox2(0.2, 1.0, new Vec2(0.5, 1.0), 0.0);
    body.createFixtureShape(pshape, 0.0);

    m_poly = new PolygonShape();
    m_poly.setAsBox(2.0, 0.1);
    m_circle = new CircleShape();
    m_circle.m_p.setZero();
    m_circle.m_radius = 0.5;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 20.0);

    m_body = getWorld().createBody(bd);
    currFixture = m_body.createFixtureShape(m_poly, 1.0);

    m_angularVelocity = Math.random() * 100 - 50;
    m_angularVelocity = 33.468121;
    m_body.setLinearVelocity(new Vec2(0.0, -100.0));
    m_body.setAngularVelocity(m_angularVelocity);

    TimeOfImpact.toiCalls = 0;
    TimeOfImpact.toiIters = 0;
    TimeOfImpact.toiMaxIters = 0;
    TimeOfImpact.toiRootIters = 0;
    TimeOfImpact.toiMaxRootIters = 0;
  }

public function launch() : Void {
    m_body.setTransform(new Vec2(0.0, 20.0), 0.0);
    m_angularVelocity = Math.random() * 100 - 50;
    m_body.setLinearVelocity(new Vec2(0.0, -100.0));
    m_body.setAngularVelocity(m_angularVelocity);
  }

override public function step() : Void {
    if (nextShape != null) {
      m_body.destroyFixture(currFixture);
      currFixture = m_body.createFixtureShape(nextShape, 1);
      nextShape = null;
    }
    // if (stepCount == 12){
    // stepCount += 0;
    // } what is this?

    super.step();

    if (getStepCount() % 60 == 0) {
      launch();
    }
  }

override public function keyPressed(argKeyCode : Int) : Void {
    switch (argKeyCode) {
      case 67: // 'c'
        switchObjects();
    }
  }
}

