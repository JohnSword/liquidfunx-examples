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
 * Created at 7:47:37 PM Jan 12, 2011
 */
package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.PrismaticJoint;
import box2d.dynamics.joints.PrismaticJointDef;
import box2d.dynamics.joints.RevoluteJoint;
import box2d.dynamics.joints.RevoluteJointDef;

/**
 * @author Daniel Murphy
 */
class SliderCrankTest extends TestbedTest {

  private var m_joint1 : RevoluteJoint;
  private var m_joint2 : PrismaticJoint;

  override public function initTest() : Void {
    trace("Keys: (f) toggle friction, (m) toggle motor");

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var prevBody : Body = ground;

    // Define crank.
      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(0.5, 2.0);

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.0, 7.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(shape, 2.0);

      var rjd : RevoluteJointDef = new RevoluteJointDef();
      rjd.initialize(prevBody, body, new Vec2(0.0, 5.0));
      rjd.motorSpeed = 1.0 * MathUtils.PI;
      rjd.maxMotorTorque = 10000.0;
      rjd.enableMotor = true;
      m_joint1 = cast getWorld().createJoint(rjd);

      prevBody = body;

      // Define follower.
      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(0.5, 4.0);

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.0, 13.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(shape, 2.0);

      var rjd : RevoluteJointDef = new RevoluteJointDef();
      rjd.initialize(prevBody, body, new Vec2(0.0, 9.0));
      rjd.enableMotor = false;
      getWorld().createJoint(rjd);

      prevBody = body;

      // Define piston
      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(1.5, 1.5);

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.fixedRotation = true;
      bd.position.set(0.0, 17.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(shape, 2.0);

      var rjd : RevoluteJointDef = new RevoluteJointDef();
      rjd.initialize(prevBody, body, new Vec2(0.0, 17.0));
      getWorld().createJoint(rjd);

      var pjd : PrismaticJointDef = new PrismaticJointDef();
      pjd.initialize(ground, body, new Vec2(0.0, 17.0), new Vec2(0.0, 1.0));

      pjd.maxMotorForce = 1000.0;
      pjd.enableMotor = false;

      m_joint2 = cast getWorld().createJoint(pjd);

      // Create a payload
      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(1.5, 1.5);

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(0.0, 23.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixtureShape(shape, 2.0);
  }

  override public function step() : Void {
    super.step();
    // var torque : Float = m_joint1.getMotorTorque(1);
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    switch (argKeyCode) {
      case 70: //'f'
        m_joint2.enableMotor(!m_joint2.isMotorEnabled());
        getModel().getCodedKeys()[argKeyCode] = false;
      case 71: //'m'
        m_joint1.enableMotor(!m_joint1.isMotorEnabled());
        getModel().getCodedKeys()[argKeyCode] = false;
    }
  }

  override public function getTestName() : String {
    return "Slider Crank";
  }
}

