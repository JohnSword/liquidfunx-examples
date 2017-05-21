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
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.RevoluteJointDef;
import box2d.dynamics.joints.WheelJoint;
import box2d.dynamics.joints.WheelJointDef;

class Car extends TestbedTest {
  private static var CAR_TAG : Int = 100;
  private static var WHEEL1_TAG : Int = 101;
  private static var WHEEL2_TAG : Int = 102;
  private static var SPRING1_TAG : Int = 103;
  private static var SPRING2_TAG : Int = 104;

  private var m_car : Body;
  private var m_wheel1 : Body;
  private var m_wheel2 : Body;

  private var m_hz : Float;
  private var m_zeta : Float;
  private var m_speed : Float;
  private var m_spring1 : WheelJoint;
  private var m_spring2 : WheelJoint;

  override public function getBodyTag(body : Body) : Int {
    if (body == m_car) {
      return CAR_TAG;
    }
    if (body == m_wheel1) {
      return WHEEL1_TAG;
    }
    if (body == m_wheel2) {
      return WHEEL2_TAG;
    }
    return super.getBodyTag(body);
  }

  override public function getJointTag(joint : Joint) : Int {
    if (joint == m_spring1) {
      return SPRING1_TAG;
    }
    if (joint == m_spring2) {
      return SPRING2_TAG;
    }
    return super.getJointTag(joint);
  }

  override public function processBody(body : Body, tag : Int) : Void {
    if (tag == CAR_TAG) {
      m_car = body;
    } else if (tag == WHEEL1_TAG) {
      m_wheel1 = body;
    } else if (tag == WHEEL2_TAG) {
      m_wheel2 = body;
    } else {
      super.processBody(body, tag);
    }
  }

  override public function processJoint(joint : Joint, tag : Int) : Void {
    if (tag == SPRING1_TAG) {
      m_spring1 = cast joint;
    } else if (tag == SPRING2_TAG) {
      m_spring2 = cast joint;
    } else {
      super.processJoint(joint, tag);
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function getTestName() : String {
    return "Car";
  }

  override public function initTest() : Void {
    m_hz = 4.0;
    m_zeta = 0.7;
    m_speed = 50.0;
   
    trace("Keys: left = a, brake = s, right = d, hz down = q, hz up = e");
    trace("frequency = " + m_hz + " hz, damping ratio = " + m_zeta);

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = m_world.createBody(bd);

    var shape : EdgeShape = new EdgeShape();

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 0.0;
    fd.friction = 0.6;

    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));
    ground.createFixture(fd);

    var hs : Array<Float>  = [0.25, 1.0, 4.0, 0.0, 0.0, -1.0, -2.0, -2.0, -1.25, 0.0];

    var x : Float = 20.0, y1 = 0.0, dx = 5.0;

    for(i in 0 ... 10) {
      var y2 : Float = hs[i];
      shape.set(new Vec2(x, y1), new Vec2(x + dx, y2));
      ground.createFixture(fd);
      y1 = y2;
      x += dx;
    }

    for(i in 0 ... 10) {
      var y2 : Float = hs[i];
      shape.set(new Vec2(x, y1), new Vec2(x + dx, y2));
      ground.createFixture(fd);
      y1 = y2;
      x += dx;
    }

    shape.set(new Vec2(x, 0.0), new Vec2(x + 40.0, 0.0));
    ground.createFixture(fd);

    x += 80.0;
    shape.set(new Vec2(x, 0.0), new Vec2(x + 40.0, 0.0));
    ground.createFixture(fd);

    x += 40.0;
    shape.set(new Vec2(x, 0.0), new Vec2(x + 10.0, 5.0));
    ground.createFixture(fd);

    x += 20.0;
    shape.set(new Vec2(x, 0.0), new Vec2(x + 40.0, 0.0));
    ground.createFixture(fd);

    x += 40.0;
    shape.set(new Vec2(x, 0.0), new Vec2(x, 20.0));
    ground.createFixture(fd);

    // Teeter
    var bd : BodyDef = new BodyDef();
    bd.position.set(140.0, 1.0);
    bd.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bd);

    var box : PolygonShape = new PolygonShape();
    box.setAsBox(10.0, 0.25);
    body.createFixtureShape(box, 1.0);

    var jd : RevoluteJointDef = new RevoluteJointDef();
    jd.initialize(ground, body, body.getPosition());
    jd.lowerAngle = -8.0 * MathUtils.PI / 180.0;
    jd.upperAngle = 8.0 * MathUtils.PI / 180.0;
    jd.enableLimit = true;
    m_world.createJoint(jd);

    body.applyAngularImpulse(100.0);

    // Bridge
    var N : Int = 20;
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(1.0, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 1.0;
    fd.friction = 0.6;

    var jd : RevoluteJointDef = new RevoluteJointDef();

    var prevBody : Body = ground;
    for(i in 0 ... N) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(161.0 + 2.0 * i, -0.125);
      var body : Body = m_world.createBody(bd);
      body.createFixture(fd);

      var anchor : Vec2 = new Vec2(160.0 + 2.0 * i, -0.125);
      jd.initialize(prevBody, body, anchor);
      m_world.createJoint(jd);

      prevBody = body;
    }

      var anchor : Vec2 = new Vec2(160.0 + 2.0 * N, -0.125);
      jd.initialize(prevBody, ground, anchor);
      m_world.createJoint(jd);

    // Boxes
    var box : PolygonShape = new PolygonShape();
    box.setAsBox(0.5, 0.5);

    var body : Body = null;
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    bd.position.set(230.0, 0.5);
    body = m_world.createBody(bd);
    body.createFixtureShape(box, 0.5);

    bd.position.set(230.0, 1.5);
    body = m_world.createBody(bd);
    body.createFixtureShape(box, 0.5);

    bd.position.set(230.0, 2.5);
    body = m_world.createBody(bd);
    body.createFixtureShape(box, 0.5);

    bd.position.set(230.0, 3.5);
    body = m_world.createBody(bd);
    body.createFixtureShape(box, 0.5);

    bd.position.set(230.0, 4.5);
    body = m_world.createBody(bd);
    body.createFixtureShape(box, 0.5);

    // Car
    var chassis : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(8);
    vertices[0] = new Vec2(-1.5, -0.5);
    vertices[1] = new Vec2(1.5, -0.5);
    vertices[2] = new Vec2(1.5, 0.0);
    vertices[3] = new Vec2(0.0, 0.9);
    vertices[4] = new Vec2(-1.15, 0.9);
    vertices[5] = new Vec2(-1.5, 0.2);
    chassis.set(vertices, 6);

    var circle : CircleShape = new CircleShape();
    circle.m_radius = 0.4;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 1.0);
    m_car = m_world.createBody(bd);
    m_car.createFixtureShape(chassis, 1.0);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = circle;
    fd.density = 1.0;
    fd.friction = 0.9;

    bd.position.set(-1.0, 0.35);
    m_wheel1 = m_world.createBody(bd);
    m_wheel1.createFixture(fd);

    bd.position.set(1.0, 0.4);
    m_wheel2 = m_world.createBody(bd);
    m_wheel2.createFixture(fd);

    var jd : WheelJointDef = new WheelJointDef();
    var axis : Vec2 = new Vec2(0.0, 1.0);

    jd.initialize(m_car, m_wheel1, m_wheel1.getPosition(), axis);
    jd.motorSpeed = 0.0;
    jd.maxMotorTorque = 20.0;
    jd.enableMotor = true;
    jd.frequencyHz = m_hz;
    jd.dampingRatio = m_zeta;
    m_spring1 = cast m_world.createJoint(jd);

    jd.initialize(m_car, m_wheel2, m_wheel2.getPosition(), axis);
    jd.motorSpeed = 0.0;
    jd.maxMotorTorque = 10.0;
    jd.enableMotor = false;
    jd.frequencyHz = m_hz;
    jd.dampingRatio = m_zeta;
    m_spring2 = cast m_world.createJoint(jd);
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    switch (argKeyCode) {
      case 65: //'a'
        m_spring1.enableMotor(true);
        m_spring1.setMotorSpeed(m_speed);

      case 83: //'s'
        m_spring1.enableMotor(true);
        m_spring1.setMotorSpeed(0.0);

      case 68: //'d'
        m_spring1.enableMotor(true);
        m_spring1.setMotorSpeed(-m_speed);

      case 81: //'q'
        m_hz = MathUtils.max(0.0, m_hz - 1.0);
        m_spring1.setSpringFrequencyHz(m_hz);
        m_spring2.setSpringFrequencyHz(m_hz);

      case 69: //'e'
        m_hz += 1.0;
        m_spring1.setSpringFrequencyHz(m_hz);
        m_spring2.setSpringFrequencyHz(m_hz);
    }
  }

  override public function keyReleased(argKeyCode : Int) : Void {
    super.keyReleased(argKeyCode);
    switch (argKeyCode) {
      case 65:
      case 83:
      case 68:
        m_spring1.enableMotor(false);
    }
  }

  override public function getDefaultCameraScale() : Float {
    return 15;
  }

  override public function step() : Void {
    super.step();
    getCamera().setCamera(m_car.getPosition());
  }
}

