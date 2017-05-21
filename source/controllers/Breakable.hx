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
 * Created at 5:18:10 AM Jan 14, 2011
 */
package controllers;

import box2d.callbacks.ContactImpulse;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.contacts.Contact;

/**
 * @author Daniel Murphy
 */
 class Breakable extends TestbedTest {

  var m_body1 : Body;
  var m_velocity : Vec2 = new Vec2();
  var m_angularVelocity : Float;
  var m_shape1 : PolygonShape;
  var m_shape2 : PolygonShape;
  var m_piece1 : Fixture;
  var m_piece2 : Fixture;

  var m_broke : Bool;
  var m_break : Bool;

override public function initTest() : Void {
    // Ground body
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    // Breakable dynamic body
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 40.0);
    bd.angle = 0.25 * MathUtils.PI;
    m_body1 = getWorld().createBody(bd);

    m_shape1 = new PolygonShape();
    m_shape1.setAsBox2(0.5, 0.5, new Vec2(-0.5, 0.0), 0.0);
    m_piece1 = m_body1.createFixtureShape(m_shape1, 1.0);

    m_shape2 = new PolygonShape();
    m_shape2.setAsBox2(0.5, 0.5, new Vec2(0.5, 0.0), 0.0);
    m_piece2 = m_body1.createFixtureShape(m_shape2, 1.0);

    m_break = false;
    m_broke = false;
  }

override public function postSolve(contact : Contact, impulse : ContactImpulse) : Void {
    if (m_broke) {
      // The body already broke.
      return;
    }

    // Should the body break?
    var count : Int = contact.getManifold().pointCount;

    var maxImpulse : Float = 0.0;
    for(i in 0 ... count) {
      maxImpulse = MathUtils.max(maxImpulse, impulse.normalImpulses[i]);
    }

    if (maxImpulse > 40.0) {
      // Flag the body for breaking.
      m_break = true;
    }
  }

  public function Break() : Void {
    // Create two bodies from one.
    var body1 : Body = m_piece1.getBody();
    var center : Vec2 = body1.getWorldCenter();

    body1.destroyFixture(m_piece2);
    m_piece2 = null;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position = body1.getPosition();
    bd.angle = body1.getAngle();

    var body2 : Body = getWorld().createBody(bd);
    m_piece2 = body2.createFixtureShape(m_shape2, 1.0);

    // Compute consistent velocities for new bodies based on
    // cached velocity.
    var center1 : Vec2 = body1.getWorldCenter();
    var center2 : Vec2 = body2.getWorldCenter();

    var velocity1 : Vec2 = m_velocity.add(Vec2.crossFV(m_angularVelocity, center1.sub(center)));
    var velocity2 : Vec2 = m_velocity.add(Vec2.crossFV(m_angularVelocity, center2.sub(center)));

    body1.setAngularVelocity(m_angularVelocity);
    body1.setLinearVelocity(velocity1);

    body2.setAngularVelocity(m_angularVelocity);
    body2.setLinearVelocity(velocity2);
  }

override public function step() : Void {
    super.step();

    if (m_break) {
      Break();
      m_broke = true;
      m_break = false;
    }

    // Cache velocities to improve movement on breakage.
    if (m_broke == false) {
      m_velocity.setVec(m_body1.getLinearVelocity());
      m_angularVelocity = m_body1.getAngularVelocity();
    }
  }

override public function getTestName() : String {
    return "Breakable";
  }
}

