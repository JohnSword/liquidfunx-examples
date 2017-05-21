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
 * Created at 6:00:03 AM Jan 12, 2011
 */
package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.PrismaticJoint;
import box2d.dynamics.joints.PrismaticJointDef;

/**
 * @author Daniel Murphy
 */
class PrismaticTest extends TestbedTest {
  
  private static var JOINT_TAG : Int = 1;
  var m_joint : PrismaticJoint;

  override public function getJointTag(joint : Joint) : Int {
    if (joint == m_joint)
      return JOINT_TAG;
    return super.getJointTag(joint);
  }

  override public function processJoint(joint : Joint, tag : Int) : Void {
    if (tag == JOINT_TAG) {
      m_joint = cast joint;
    } else {
      super.processJoint(joint, tag);
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    trace("Keys: (l) limits, (m) motors, (s) speed");

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(2.0, 0.5);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(-10.0, 10.0);
    bd.angle = 0.5 * MathUtils.PI;
    bd.allowSleep = false;
    var body : Body = getWorld().createBody(bd);
    body.createFixtureShape(shape, 5.0);

    var pjd : PrismaticJointDef = new PrismaticJointDef();

    // Bouncy limit
    var axis : Vec2 = new Vec2(2.0, 1.0);
    axis.normalize();
    pjd.initialize(ground, body, new Vec2(0.0, 0.0), axis);

    // Non-bouncy limit
    // pjd.Initialize(ground, body, Vec2(-10.0f, 10.0f), Vec2(1.0f, 0.0f));

    pjd.motorSpeed = 10.0;
    pjd.maxMotorForce = 10000.0;
    pjd.enableMotor = true;
    pjd.lowerTranslation = 0.0;
    pjd.upperTranslation = 20.0;
    pjd.enableLimit = true;

    m_joint = cast getWorld().createJoint(pjd);
  }

  override public function step() : Void {
    super.step();
    var force : Float = m_joint.getMotorForce(1);
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    trace(argKeyCode);
    switch (argKeyCode) {
      case 76: //'l'
        m_joint.enableLimit(!m_joint.isLimitEnabled());
        getModel().getCodedKeys()[argKeyCode] = false;
      case 77: //'m'
        m_joint.enableMotor(!m_joint.isMotorEnabled());
        getModel().getCodedKeys()[argKeyCode] = false;
      case 83: //'s'
        m_joint.setMotorSpeed(-m_joint.getMotorSpeed());
        getModel().getCodedKeys()[argKeyCode] = false;
    }
  }

  override public function getTestName() : String {
    return "Prismatic";
  }
}

