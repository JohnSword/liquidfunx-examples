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
 * Created at 12:46:04 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.PulleyJoint;
import box2d.dynamics.joints.PulleyJointDef;

/**
 * @author Daniel Murphy
 */
class Pulleys extends TestbedTest {
  private static var JOINT_TAG : Int = 2;

  var m_joint1 : PulleyJoint;  

  override public function getJointTag(joint : Joint) : Int {
    if (joint == m_joint1)
      return JOINT_TAG;
    return super.getJointTag(joint);
  }

  override public function processJoint(joint : Joint, tag : Int) : Void {
    if (tag == JOINT_TAG) {
      m_joint1 = cast joint;
    } else {
      super.processJoint(joint, tag);
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var y : Float = 16.0;
    var L : Float = 12.0;
    var a : Float = 1.0;
    var b : Float = 2.0;
    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var circle : CircleShape = new CircleShape();
    circle.m_radius = 2.0;

    circle.m_p.set(-10.0, y + b + L);
    ground.createFixtureShape(circle, 0.0);

    circle.m_p.set(10.0, y + b + L);
    ground.createFixtureShape(circle, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(a, b);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    bd.position.set(-10.0, y);
    var body1 : Body = getWorld().createBody(bd);
    body1.createFixtureShape(shape, 5.0);

    bd.position.set(10.0, y);
    var body2 : Body = getWorld().createBody(bd);
    body2.createFixtureShape(shape, 5.0);

    var pulleyDef : PulleyJointDef = new PulleyJointDef();
    var anchor1 : Vec2 = new Vec2(-10.0, y + b);
    var anchor2 : Vec2 = new Vec2(10.0, y + b);
    var groundAnchor1 : Vec2 = new Vec2(-10.0, y + b + L);
    var groundAnchor2 : Vec2 = new Vec2(10.0, y + b + L);
    pulleyDef.initialize(body1, body2, groundAnchor1, groundAnchor2, anchor1, anchor2, 2.0);

    m_joint1 = cast getWorld().createJoint(pulleyDef);
  }

override public function step() : Void {
    super.step();
    var ratio : Float = m_joint1.getRatio();
    var L : Float = m_joint1.getLength1() + ratio * m_joint1.getLength2();
    if (L >= 36) {
      trace("Pulley is taught");
    }
  }

override public function getTestName() : String {
    return "Pulleys";
  }

}

