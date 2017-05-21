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
 * Created at 4:25:03 AM Jan 15, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.GearJoint;
import box2d.dynamics.joints.GearJointDef;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.PrismaticJoint;
import box2d.dynamics.joints.PrismaticJointDef;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;

/**
 * @author Daniel Murphy
 */
class Gears extends TestbedTest {

  var m_joint1 : RevoluteJoint;
  var m_joint2 : RevoluteJoint;
  var m_joint3 : PrismaticJoint;
  var m_joint4 : GearJoint;
  var m_joint5 : GearJoint;

  override public function initTest() : Void {
    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(50.0, 0.0), new Vec2(-50.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var circle1 : CircleShape = new CircleShape();
    circle1.m_radius = 1.0;

    var box : PolygonShape = new PolygonShape();
    box.setAsBox(0.5, 5.0);

    var circle2 : CircleShape = new CircleShape();
    circle2.m_radius = 2.0;

    var bd1 : BodyDef = new BodyDef();
    bd1.type = BodyType.STATIC;
    bd1.position.set(10.0, 9.0);
    var body1 : Body = m_world.createBody(bd1);
    body1.createFixtureShape(circle1, 5.0);

    var bd2 : BodyDef = new BodyDef();
    bd2.type = BodyType.DYNAMIC;
    bd2.position.set(10.0, 8.0);
    var body2 : Body = m_world.createBody(bd2);
    body2.createFixtureShape(box, 5.0);

    var bd3 : BodyDef = new BodyDef();
    bd3.type = BodyType.DYNAMIC;
    bd3.position.set(10.0, 6.0);
    var body3 : Body = m_world.createBody(bd3);
    body3.createFixtureShape(circle2, 5.0);

    var jd1 : RevoluteJointDef = new RevoluteJointDef();
    jd1.initialize(body2, body1, bd1.position);
    var joint1 : Joint = m_world.createJoint(jd1);

    var jd2 : RevoluteJointDef = new RevoluteJointDef();
    jd2.initialize(body2, body3, bd3.position);
    var joint2 : Joint = m_world.createJoint(jd2);

    var jd4 : GearJointDef = new GearJointDef();
    jd4.bodyA = body1;
    jd4.bodyB = body3;
    jd4.joint1 = joint1;
    jd4.joint2 = joint2;
    jd4.ratio = circle2.m_radius / circle1.m_radius;
    m_world.createJoint(jd4);

    var circle1 : CircleShape = new CircleShape();
    circle1.m_radius = 1.0;

    var circle2 : CircleShape = new CircleShape();
    circle2.m_radius = 2.0;

    var box : PolygonShape = new PolygonShape();
    box.setAsBox(0.5, 5.0);

    var bd1 : BodyDef = new BodyDef();
    bd1.type = BodyType.DYNAMIC;
    bd1.position.set(-3.0, 12.0);
    var body1 : Body = m_world.createBody(bd1);
    body1.createFixtureShape(circle1, 5.0);

    var jd1 : RevoluteJointDef = new RevoluteJointDef();
    jd1.bodyA = ground;
    jd1.bodyB = body1;
    ground.getLocalPointToOut(bd1.position, jd1.localAnchorA);
    body1.getLocalPointToOut(bd1.position, jd1.localAnchorB);
    jd1.referenceAngle = body1.getAngle() - ground.getAngle();
    m_joint1 = cast m_world.createJoint(jd1);

    var bd2 : BodyDef = new BodyDef();
    bd2.type = BodyType.DYNAMIC;
    bd2.position.set(0.0, 12.0);
    var body2 : Body = m_world.createBody(bd2);
    body2.createFixtureShape(circle2, 5.0);

    var jd2 : RevoluteJointDef = new RevoluteJointDef();
    jd2.initialize(ground, body2, bd2.position);
    m_joint2 = cast m_world.createJoint(jd2);

    var bd3 : BodyDef = new BodyDef();
    bd3.type = BodyType.DYNAMIC;
    bd3.position.set(2.5, 12.0);
    var body3 : Body = m_world.createBody(bd3);
    body3.createFixtureShape(box, 5.0);

    var jd3 : PrismaticJointDef = new PrismaticJointDef();
    jd3.initialize(ground, body3, bd3.position, new Vec2(0.0, 1.0));
    jd3.lowerTranslation = -5.0;
    jd3.upperTranslation = 5.0;
    jd3.enableLimit = true;

    m_joint3 = cast m_world.createJoint(jd3);

    var jd4 : GearJointDef = new GearJointDef();
    jd4.bodyA = body1;
    jd4.bodyB = body2;
    jd4.joint1 = m_joint1;
    jd4.joint2 = m_joint2;
    jd4.ratio = circle2.m_radius / circle1.m_radius;
    m_joint4 = cast m_world.createJoint(jd4);

    var jd5 : GearJointDef = new GearJointDef();
    jd5.bodyA = body2;
    jd5.bodyB = body3;
    jd5.joint1 = m_joint2;
    jd5.joint2 = m_joint3;
    jd5.ratio = 1 / circle2.m_radius;
    m_joint5 = cast m_world.createJoint(jd5);
  }

  override public function step() : Void {
    super.step();

    var ratio, value;

    ratio = m_joint4.getRatio();
    value = m_joint1.getJointAngle() + ratio * m_joint2.getJointAngle();

    // addTextLine("theta1 + " + ratio + " * theta2 = " + value);

    ratio = m_joint5.getRatio();
    value = m_joint2.getJointAngle() + ratio * m_joint3.getJointTranslation();
    // addTextLine("theta2 + " + ratio + " * delta = " + value);
  }

  override public function getTestName() : String {
    return "Gears";
  }
}

