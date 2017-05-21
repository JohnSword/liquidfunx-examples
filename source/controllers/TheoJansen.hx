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
 * created at 12:22:58 AM Jan 13, 2011
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
import box2d.dynamics.joints.DistanceJointDef;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;

/**
 * @author Daniel Murphy
 */
class TheoJansen extends TestbedTest {

  private static var CHASSIS_TAG : Int = 1;
  private static var WHEEL_TAG : Int = 2;
  private static var MOTOR_TAG : Int = 8;

  var m_offset : Vec2 = new Vec2();
  var m_chassis : Body;
  var m_wheel : Body;
  var m_motorJoint : RevoluteJoint;
  var m_motorOn : Bool;
  var m_motorSpeed : Float = 0;

  override public function getBodyTag(argBody : Body) : Int {
    if (argBody == m_chassis) {
      return CHASSIS_TAG;
    } else if (argBody == m_wheel) {
      return WHEEL_TAG;
    }
    return 0;
  }

  override public function getJointTag(argJoint : Joint) : Int {
    if (argJoint == m_motorJoint) {
      return MOTOR_TAG;
    }
    return 0;
  }

  override public function processBody(argBody : Body, argTag : Int) : Void {
    if (argTag == CHASSIS_TAG) {
      m_chassis = argBody;
    } else if (argTag == WHEEL_TAG) {
      m_wheel = argBody;
    }
  }

  override public function processJoint(argJoint : Joint, argTag : Int) : Void {
    if (argTag == MOTOR_TAG) {
      m_motorJoint = cast argJoint;
      m_motorOn = m_motorJoint.isMotorEnabled();
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    trace("Keys: = a, brake = s, right = d, toggle motor = m");

    m_offset.set(0.0, 8.0);
    m_motorSpeed = 2.0;
    m_motorOn = true;
    var pivot : Vec2 = new Vec2(0.0, 0.8);

    // Ground
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-50.0, 0.0), new Vec2(50.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    shape.set(new Vec2(-50.0, 0.0), new Vec2(-50.0, 10.0));
    ground.createFixtureShape(shape, 0.0);

    shape.set(new Vec2(50.0, 0.0), new Vec2(50.0, 10.0));
    ground.createFixtureShape(shape, 0.0);

    // Balls
    for(i in 0 ... 40) {
      var shape : CircleShape = new CircleShape();
      shape.m_radius = 0.25;

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-40.0 + 2.0 * i, 0.5);

      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(shape, 1.0);
    }

    // Chassis
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(2.5, 1.0);

    var sd : FixtureDef = new FixtureDef();
    sd.density = 1.0;
    sd.shape = shape;
    sd.filter.groupIndex = -1;
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.setVec(pivot).addLocalVec(m_offset);
    m_chassis = getWorld().createBody(bd);
    m_chassis.createFixture(sd);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 1.6;

    var sd : FixtureDef = new FixtureDef();
    sd.density = 1.0;
    sd.shape = shape;
    sd.filter.groupIndex = -1;
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.setVec(pivot).addLocalVec(m_offset);
    m_wheel = getWorld().createBody(bd);
    m_wheel.createFixture(sd);

    var jd : RevoluteJointDef = new RevoluteJointDef();

    jd.initialize(m_wheel, m_chassis, pivot.add(m_offset));
    jd.collideConnected = false;
    jd.motorSpeed = m_motorSpeed;
    jd.maxMotorTorque = 400.0;
    jd.enableMotor = m_motorOn;
    m_motorJoint = cast getWorld().createJoint(jd);

    var wheelAnchor : Vec2;

    wheelAnchor = pivot.add(new Vec2(0.0, -0.8));

    createLeg(-1.0, wheelAnchor);
    createLeg(1.0, wheelAnchor);

    m_wheel.setTransform(m_wheel.getPosition(), 120.0 * MathUtils.PI / 180.0);
    createLeg(-1.0, wheelAnchor);
    createLeg(1.0, wheelAnchor);

    m_wheel.setTransform(m_wheel.getPosition(), -120.0 * MathUtils.PI / 180.0);
    createLeg(-1.0, wheelAnchor);
    createLeg(1.0, wheelAnchor);
  }

  private function createLeg(s : Float, wheelAnchor : Vec2) : Void {
    var p1 : Vec2 = new Vec2(5.4 * s, -6.1);
    var p2 : Vec2 = new Vec2(7.2 * s, -1.2);
    var p3 : Vec2 = new Vec2(4.3 * s, -1.9);
    var p4 : Vec2 = new Vec2(3.1 * s, 0.8);
    var p5 : Vec2 = new Vec2(6.0 * s, 1.5);
    var p6 : Vec2 = new Vec2(2.5 * s, 3.7);

    var fd1 : FixtureDef = new FixtureDef();
    var fd2 : FixtureDef = new FixtureDef();
    fd1.filter.groupIndex = -1;
    fd2.filter.groupIndex = -1;
    fd1.density = 1.0;
    fd2.density = 1.0;

    var poly1 : PolygonShape = new PolygonShape();
    var poly2 : PolygonShape = new PolygonShape();

    if (s > 0.0) {
      var vertices : Vector<Vec2> = new Vector<Vec2>(3);

      vertices[0] = p1;
      vertices[1] = p2;
      vertices[2] = p3;
      poly1.set(vertices, 3);

      vertices[0] = new Vec2();
      vertices[1] = p5.sub(p4);
      vertices[2] = p6.sub(p4);
      poly2.set(vertices, 3);
    } else {
      var vertices : Vector<Vec2> = new Vector<Vec2>(3);

      vertices[0] = p1;
      vertices[1] = p3;
      vertices[2] = p2;
      poly1.set(vertices, 3);

      vertices[0] = new Vec2();
      vertices[1] = p6.sub(p4);
      vertices[2] = p5.sub(p4);
      poly2.set(vertices, 3);
    }

    fd1.shape = poly1;
    fd2.shape = poly2;

    var bd1 : BodyDef = new BodyDef(), bd2 = new BodyDef();
    bd1.type = BodyType.DYNAMIC;
    bd2.type = BodyType.DYNAMIC;
    bd1.position = m_offset;
    bd2.position = p4.add(m_offset);

    bd1.angularDamping = 10.0;
    bd2.angularDamping = 10.0;

    var body1 : Body = getWorld().createBody(bd1);
    var body2 : Body = getWorld().createBody(bd2);

    body1.createFixture(fd1);
    body2.createFixture(fd2);

    var djd : DistanceJointDef = new DistanceJointDef();

    // Using a soft distance constraint can reduce some jitter.
    // It also makes the structure seem a bit more fluid by
    // acting like a suspension system.
    djd.dampingRatio = 0.5;
    djd.frequencyHz = 10.0;

    djd.initialize(body1, body2, p2.add(m_offset), p5.add(m_offset));
    getWorld().createJoint(djd);

    djd.initialize(body1, body2, p3.add(m_offset), p4.add(m_offset));
    getWorld().createJoint(djd);

    djd.initialize(body1, m_wheel, p3.add(m_offset), wheelAnchor.add(m_offset));
    getWorld().createJoint(djd);

    djd.initialize(body2, m_wheel, p6.add(m_offset), wheelAnchor.add(m_offset));
    getWorld().createJoint(djd);

    var rjd : RevoluteJointDef = new RevoluteJointDef();

    rjd.initialize(body2, m_chassis, p4.add(m_offset));
    getWorld().createJoint(rjd);
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    trace(argKeyCode);
    switch (argKeyCode) {
      case 65: //'a'
        m_motorJoint.setMotorSpeed(-m_motorSpeed);

      case 83: //'s'
        m_motorJoint.setMotorSpeed(0.0);

      case 68: //'d'
        m_motorJoint.setMotorSpeed(m_motorSpeed);

      case 77: //'m'
        m_motorJoint.enableMotor(!m_motorJoint.isMotorEnabled());
    }
  }

  override public function getTestName() : String {
    return "TheoJansen Walker";
  }
}

