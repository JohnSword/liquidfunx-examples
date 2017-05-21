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
 * Created at 7:50:04 AM Jan 20, 2011
 */
package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Rot;
import box2d.common.Transform;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.FrictionJointDef;

/**
 * @author Daniel Murphy
 */
class ApplyForce extends TestbedTest {

  private static var BODY_TAG : Int = 12;

  var m_body : Body;

  override public function initTest() : Void {

    getWorld().setGravity(new Vec2(0.0, 0.0));

    var k_restitution : Float = 0.4;

    var ground : Body;
    var bd : BodyDef = new BodyDef();
    bd.position.set(0.0, 20.0);
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();

    var sd : FixtureDef = new FixtureDef();
    sd.shape = shape;
    sd.density = 0.0;
    sd.restitution = k_restitution;

    // Left vertical
    shape.set(new Vec2(-20.0, -20.0), new Vec2(-20.0, 20.0));
    ground.createFixture(sd);

    // Right vertical
    shape.set(new Vec2(20.0, -20.0), new Vec2(20.0, 20.0));
    ground.createFixture(sd);

    // Top horizontal
    shape.set(new Vec2(-20.0, 20.0), new Vec2(20.0, 20.0));
    ground.createFixture(sd);

    // Bottom horizontal
    shape.set(new Vec2(-20.0, -20.0), new Vec2(20.0, -20.0));
    ground.createFixture(sd);

    var xf1 : Transform = new Transform();
    xf1.q.set(0.3524 * MathUtils.PI);
    Rot.mulToOutUnsafe(xf1.q, new Vec2(1.0, 0.0), xf1.p);

    var vertices : Vector<Vec2> = new Vector<Vec2>(3);
    vertices[0] = Transform.mul(xf1, new Vec2(-1.0, 0.0));
    vertices[1] = Transform.mul(xf1, new Vec2(1.0, 0.0));
    vertices[2] = Transform.mul(xf1, new Vec2(0.0, 0.5));

    var poly1 : PolygonShape = new PolygonShape();
    poly1.set(vertices, 3);

    var sd1 : FixtureDef = new FixtureDef();
    sd1.shape = poly1;
    sd1.density = 4.0;

    var xf2 : Transform = new Transform();
    xf2.q.set(-0.3524 * MathUtils.PI);
    Rot.mulToOut(xf2.q, new Vec2(-1.0, 0.0), xf2.p);

    vertices[0] = Transform.mul(xf2, new Vec2(-1.0, 0.0));
    vertices[1] = Transform.mul(xf2, new Vec2(1.0, 0.0));
    vertices[2] = Transform.mul(xf2, new Vec2(0.0, 0.5));

    var poly2 : PolygonShape = new PolygonShape();
    poly2.set(vertices, 3);

    var sd2 : FixtureDef = new FixtureDef();
    sd2.shape = poly2;
    sd2.density = 2.0;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.angularDamping = 2.0;
    bd.linearDamping = 0.5;

    bd.position.set(0.0, 2.0);
    bd.angle = MathUtils.PI;
    bd.allowSleep = false;
    m_body = getWorld().createBody(bd);
    m_body.createFixture(sd1);
    m_body.createFixture(sd2);
  

  
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.5);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 1.0;
    fd.friction = 0.3;

    for(i in 0 ... 10) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;

      bd.position.set(0.0, 5.0 + 1.54 * i);
      var body : Body = getWorld().createBody(bd);

      body.createFixture(fd);

      var gravity : Float = 10.0;
      var I : Float = body.getInertia();
      var mass : Float = body.getMass();

      // For a circle: I = 0.5 * m * r * r ==> r = sqrt(2 * I / m)
      var radius : Float = MathUtils.sqrt(2.0 * I / mass);

      var jd : FrictionJointDef = new FrictionJointDef();
      jd.localAnchorA.setZero();
      jd.localAnchorB.setZero();
      jd.bodyA = ground;
      jd.bodyB = body;
      jd.collideConnected = true;
      jd.maxForce = mass * gravity;
      jd.maxTorque = mass * radius * gravity;

      getWorld().createJoint(jd);
      
    }
  }

override public function keyPressed(keyCode : Int) : Void {
    super.keyPressed(keyCode);
  }
  
override public function step() : Void {
    super.step();

    trace("Use 'wasd' to move, 'e' and 's' drift.");

    // TODO Auto-generated method stub
    if (getModel().getCodedKeys()[87]) { // W
      var f : Vec2 = m_body.getWorldVector(new Vec2(0.0, -30.0));
      var p : Vec2 = m_body.getWorldPoint(m_body.getLocalCenter().add(new Vec2(0.0, 2.0)));
      m_body.applyForce(f, p);
    } else if (getModel().getCodedKeys()[81]) { // Q
      var f : Vec2 = m_body.getWorldVector(new Vec2(0.0, -30.0));
      var p : Vec2 = m_body.getWorldPoint(m_body.getLocalCenter().add(new Vec2(-.2, 0)));
      m_body.applyForce(f, p);
    } else if (getModel().getCodedKeys()[69]) { // E
      var f : Vec2 = m_body.getWorldVector(new Vec2(0.0, -30.0));
      var p : Vec2 = m_body.getWorldPoint(m_body.getLocalCenter().add(new Vec2(.2, 0)));
      m_body.applyForce(f, p);
    } else if (getModel().getCodedKeys()[83]) { // S
      var f : Vec2 = m_body.getWorldVector(new Vec2(0.0, 30.0));
      var p : Vec2 = m_body.getWorldCenter();
      m_body.applyForce(f, p);
    }

    if (getModel().getCodedKeys()[65]) { // A
      m_body.applyTorque(20.0);
    }

    if (getModel().getCodedKeys()[68]) { // D
      m_body.applyTorque(-20.0);
    }
  }

override public function isSaveLoadEnabled() : Bool {
    return true;
  }

override public function getBodyTag(body : Body) : Int {
    if (body == m_body) {
      return BODY_TAG;
    }
    return super.getBodyTag(body);
  }

override public function processBody(body : Body, tag : Int) : Void {
    if (tag == BODY_TAG) {
      m_body = body;
    }
    super.processBody(body, tag);
  }

override public function getTestName() : String {
    return "Apply Force";
  }
}

