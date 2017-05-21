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
 * Created at 7:59:38 PM Jan 12, 2011
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
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;

/**
 * @author Daniel Murphy
 */
class RevoluteTest extends TestbedTest {
  private static var JOINT_TAG : Int = 1;
  private var m_joint : RevoluteJoint;
  private var isLeft : Bool = false;

  override public function getJointTag(joint : Joint) : Int {
    if (joint == m_joint)
      return JOINT_TAG;
    return super.getJointTag(joint);
  }

  override public function processJoint(joint : Joint, tag : Int) : Void {
    if (tag == JOINT_TAG) {
      m_joint = cast joint;
      isLeft = m_joint.getMotorSpeed() > 0;
    } else {
      super.processJoint(joint, tag);
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    trace("Keys: (l) limits, (m) motor, (a) left, (d) right");

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 0.5;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    var rjd : RevoluteJointDef = new RevoluteJointDef();

    bd.position.set(-10, 20.0);
    var body : Body = getWorld().createBody(bd);
    body.createFixtureShape(shape, 5.0);

    var w : Float = 100.0;
    body.setAngularVelocity(w);
    body.setLinearVelocity(new Vec2(-8.0 * w, 0.0));

    rjd.initialize(ground, body, new Vec2(-10.0, 12.0));
    rjd.motorSpeed = -1.0 * MathUtils.PI;
    rjd.maxMotorTorque = 10000.0;
    rjd.enableMotor = false;
    rjd.lowerAngle = -0.25 * MathUtils.PI;
    rjd.upperAngle = 0.5 * MathUtils.PI;
    rjd.enableLimit = true;
    rjd.collideConnected = true;

    m_joint = cast getWorld().createJoint(rjd);

    var circle_shape : CircleShape = new CircleShape();
    circle_shape.m_radius = 3.0;

    var circle_bd : BodyDef = new BodyDef();
    circle_bd.type = BodyType.DYNAMIC;
    circle_bd.position.set(5.0, 30.0);

    var fd : FixtureDef = new FixtureDef();
    fd.density = 5.0;
    fd.filter.maskBits = 1;
    fd.shape = circle_shape;

    var ball : Body = m_world.createBody(circle_bd);
    ball.createFixture(fd);

    var polygon_shape : PolygonShape = new PolygonShape();
    polygon_shape.setAsBox2(10.0, 0.2, new Vec2(-10.0, 0.0), 0.0);

    var polygon_bd : BodyDef = new BodyDef();
    polygon_bd.position.set(20.0, 10.0);
    polygon_bd.type = BodyType.DYNAMIC;
    polygon_bd.bullet = true;
    var polygon_body : Body = m_world.createBody(polygon_bd);
    polygon_body.createFixtureShape(polygon_shape, 2.0);

    var rjd : RevoluteJointDef = new RevoluteJointDef();
    rjd.initialize(ground, polygon_body, new Vec2(20.0, 10.0));
    rjd.lowerAngle = -0.25 * MathUtils.PI;
    rjd.upperAngle = 0.0 * MathUtils.PI;
    rjd.enableLimit = true;
    m_world.createJoint(rjd);

    // Tests mass computation of a small object far from the origin
    var bodyDef : BodyDef = new BodyDef();
    bodyDef.type = BodyType.DYNAMIC;
    var body : Body = m_world.createBody(bodyDef);

    var polyShape : PolygonShape = new PolygonShape();
    var verts : Vector<Vec2> = new Vector<Vec2>(3);
    verts[0] = new Vec2(17.63, 36.31);
    verts[1] = new Vec2(17.52, 36.69);
    verts[2] = new Vec2(17.19, 36.36);
    polyShape.set(verts, 3);

    var polyFixtureDef : FixtureDef = new FixtureDef();
    polyFixtureDef.shape = polyShape;
    polyFixtureDef.density = 1;

    body.createFixture(polyFixtureDef);
  }

  override public function step() : Void {
    super.step();
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    trace(argKeyCode);
    switch (argKeyCode) {
      case 76: //'l'
        m_joint.enableLimit(!m_joint.isLimitEnabled());
      case 77: //'m'
        m_joint.enableMotor(!m_joint.isMotorEnabled());
      case 65: //'a'
        m_joint.setMotorSpeed(1.0 * MathUtils.PI);
        isLeft = true;
      case 68: //'d'
        m_joint.setMotorSpeed(-1.0 * MathUtils.PI);
        isLeft = false;
    }
  }

  override public function getTestName() : String {
    return "Revolute";
  }
}

