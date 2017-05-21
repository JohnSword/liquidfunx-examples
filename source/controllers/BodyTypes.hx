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
 * .created at 1:14:57 AM Jan 14, 2011
 */
package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.PrismaticJointDef;
import box2d.dynamics.joints.RevoluteJointDef;

/**
 * @author Daniel Murphy
 */
class BodyTypes extends TestbedTest {

  private static var ATTACHMENT_TAG : Int = 19;
  private static var PLATFORM_TAG : Int = 20;

  var m_attachment : Body;
  var m_platform : Body;
  var m_speed : Float;

  override public function getBodyTag(body : Body) : Int {
      if (body == m_attachment)
        return ATTACHMENT_TAG;
      if (body == m_platform)
        return PLATFORM_TAG;
      return super.getBodyTag(body);
    }

override public function processBody(body : Body, tag : Int) : Void {
    if (tag == ATTACHMENT_TAG) {
      m_attachment = body;
    } else if (tag == PLATFORM_TAG) {
      m_platform = body;
    } else {
      super.processBody(body, tag);
    }
  }
  
override public function isSaveLoadEnabled() : Bool {
    return true;
  }

override public function initTest() : Void {
   trace("Keys: (d) dynamic, (s) static, (k) kinematic");

    m_speed = 3.0;

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;

    ground.createFixture(fd);

    // Define attachment
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 3.0);
    m_attachment = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 2.0);
    m_attachment.createFixtureShape(shape, 2.0);

    // Define platform
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(-4.0, 5.0);
    m_platform = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(0.5, 4.0, new Vec2(4.0, 0.0), 0.5 * MathUtils.PI);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.friction = 0.6;
    fd.density = 2.0;
    m_platform.createFixture(fd);

    var rjd : RevoluteJointDef = new RevoluteJointDef();
    rjd.initialize(m_attachment, m_platform, new Vec2(0.0, 5.0));
    rjd.maxMotorTorque = 50.0;
    rjd.enableMotor = true;
    getWorld().createJoint(rjd);

    var pjd : PrismaticJointDef = new PrismaticJointDef();
    pjd.initialize(ground, m_platform, new Vec2(0.0, 5.0), new Vec2(1.0, 0.0));

    pjd.maxMotorForce = 1000.0;
    pjd.enableMotor = true;
    pjd.lowerTranslation = -10.0;
    pjd.upperTranslation = 10.0;
    pjd.enableLimit = true;

    getWorld().createJoint(pjd);

    // .create a payload
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 8.0);
    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.75, 0.75);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.friction = 0.6;
    fd.density = 2.0;

    body.createFixture(fd);
  }

override public function step() : Void {
    super.step();

    // Drive the kinematic body.
    if (m_platform.getType() == BodyType.KINEMATIC) {
      var p : Vec2 = m_platform.getTransform().p;
      var v : Vec2 = m_platform.getLinearVelocity();

      if ((p.x < -10.0 && v.x < 0.0) || (p.x > 10.0 && v.x > 0.0)) {
        v.x = -v.x;
        m_platform.setLinearVelocity(v);
      }
    }
  }

override public function keyPressed(argKeyCode : Int) : Void {
  trace(argKeyCode);
    switch (argKeyCode) {
      case 68:
        m_platform.setType(BodyType.DYNAMIC);
      case 83:
        m_platform.setType(BodyType.STATIC);
      case 75:
        m_platform.setType(BodyType.KINEMATIC);
        m_platform.setLinearVelocity(new Vec2(-m_speed, 0.0));
        m_platform.setAngularVelocity(0.0);
    }
  }

override public function getTestName() : String {
    return "Body Types";
  }

}

