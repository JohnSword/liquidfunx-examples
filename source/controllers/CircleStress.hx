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
 * Created at 8:02:54 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
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
 class CircleStress extends TestbedTest {

  private static var JOINT_TAG : Int = 1;

  private var joint : RevoluteJoint;

  override public function getJointTag(argJoint : Joint) : Int {
      if (argJoint == joint) {
        return JOINT_TAG;
      }
      return 0;
    }

  override public function processJoint(argJoint : Joint, argTag : Int) : Void {
    if (argTag == JOINT_TAG) {
      joint = cast argJoint;
    }
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function getDefaultCameraPos() : Vec2 {
    return new Vec2(0, 20);
  }

  override public function getDefaultCameraScale() : Float {
    return 5;
  }

  override public function initTest() : Void {
    trace("Press 's' to stop, and '1' - '5' to change speeds");

    var leftWall : Body = null;
    var rightWall : Body = null;

    // Ground
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(50.0, 10.0);
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position = new Vec2(0.0, -10.0);
    var b : Body = getWorld().createBody(bd);
    var fd : FixtureDef = new FixtureDef();
    fd.shape = sd;
    fd.friction = 1.0;
    b.createFixture(fd);

    // Walls
    sd.setAsBox(3.0, 50.0);
    bd = new BodyDef();
    bd.position = new Vec2(45.0, 25.0);
    rightWall = getWorld().createBody(bd);
    rightWall.createFixtureShape(sd, 0);
    bd.position = new Vec2(-45.0, 25.0);
    leftWall = getWorld().createBody(bd);
    leftWall.createFixtureShape(sd, 0);

    // Corners
    bd = new BodyDef();
    sd.setAsBox(20.0, 3.0);
    bd.angle = (-Math.PI / 4.0);
    bd.position = new Vec2(-35, 8.0);
    var myBod : Body = getWorld().createBody(bd);
    myBod.createFixtureShape(sd, 0);
    bd.angle = (Math.PI / 4.0);
    bd.position = new Vec2(35, 8.0);
    myBod = getWorld().createBody(bd);
    myBod.createFixtureShape(sd, 0);

    // top
    sd.setAsBox(50.0, 10.0);
    bd.type = BodyType.STATIC;
    bd.angle = 0;
    bd.position = new Vec2(0.0, 75.0);
    b = getWorld().createBody(bd);
    fd.shape = sd;
    fd.friction = 1.0;
    b.createFixture(fd);

    var cd : CircleShape;
    var fd : FixtureDef = new FixtureDef();

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var numPieces : Int = 5;
    var radius : Float = 6;
    bd.position = new Vec2(0.0, 10.0);
    var body : Body = getWorld().createBody(bd);
    for(i in 0 ... numPieces) {
      cd = new CircleShape();
      cd.m_radius = 1.2;
      fd.shape = cd;
      fd.density = 25;
      fd.friction = .1;
      fd.restitution = .9;
      var xPos : Float = radius * Math.cos(2 * Math.PI * (i / (numPieces)));
      var yPos : Float = radius * Math.sin(2 * Math.PI * (i / (numPieces)));
      cd.m_p.set(xPos, yPos);

      body.createFixture(fd);
    }

    body.setBullet(false);

    var rjd : RevoluteJointDef = new RevoluteJointDef();
    rjd.initialize(body, getGroundBody(), body.getPosition());
    rjd.motorSpeed = MathUtils.PI;
    rjd.maxMotorTorque = 1000000.0;
    rjd.enableMotor = true;
    joint = cast getWorld().createJoint(rjd);

    var loadSize : Int = 41;
    for (j in 0 ... 15) {
      for(i in 0 ... loadSize) {
        var circ : CircleShape = new CircleShape();
        var bod : BodyDef = new BodyDef();
        bod.type = BodyType.DYNAMIC;
        circ.m_radius = 1.0 + (i % 2 == 0 ? 1.0 : -1.0) * .5 * MathUtils.randomFloat(.5, 1);
        var fd2 : FixtureDef = new FixtureDef();
        fd2.shape = circ;
        fd2.density = circ.m_radius * 1.5;
        fd2.friction = 0.5;
        fd2.restitution = 0.7;
        var xPos : Float = -39 + 2 * i;
        var yPos : Float = 50 + j;
        bod.position = new Vec2(xPos, yPos);
        var myBody : Body = getWorld().createBody(bod);
        myBody.createFixture(fd2);
      }
    }

    getWorld().setGravity(new Vec2(0, -50));
  }

override public function keyPressed(argKeyCode : Int) : Void {
  trace(argKeyCode);
    switch (argKeyCode) {
      case 83: //'s'
        joint.setMotorSpeed(0);
      case 49: //'1'
        joint.setMotorSpeed(MathUtils.PI);
      case 50: //'2'
        joint.setMotorSpeed(MathUtils.PI * 2);
      case 51: //'3'
        joint.setMotorSpeed(MathUtils.PI * 3);
      case 52: //'4'
        joint.setMotorSpeed(MathUtils.PI * 6);
      case 53: //'5'
        joint.setMotorSpeed(MathUtils.PI * 10);
    }
  }

override public function getTestName() : String {
    return "Circle Stress Test";
  }

}

