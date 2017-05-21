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

import box2d.collision.Manifold;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.contacts.Contact;

class ConveyorBelt extends TestbedTest {

  private static var platformTag : Int = 98752;
  private var m_platform : Fixture;
  
  override public function getFixtureTag(argFixture : Fixture) : Int {
      if (argFixture == m_platform) {
        return platformTag;
      }
      return super.getFixtureTag(argFixture);
    }
  
override public function processFixture(argFixture : Fixture, argTag : Int) : Void {
    if(argTag == platformTag) {
      m_platform = argFixture;
      return;
    }
    super.processFixture(argFixture, argTag);
  }

override public function isSaveLoadEnabled() : Bool {
    return true;
  }
  
override public function initTest() : Void {
    // Ground

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));
    getGroundBody().createFixtureShape(shape, 0.0);

    // Platform
    var bd : BodyDef = new BodyDef();
    bd.position.set(-5.0, 5.0);
    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(10.0, 0.5);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.friction = 0.8;
    m_platform = body.createFixture(fd);

    // Boxes
    for(i in 0 ... 5) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-10.0 + 2.0 * i, 7.0);
      var body : Body = m_world.createBody(bd);

      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(0.5, 0.5);
      body.createFixtureShape(shape, 20.0);
    }
  }

override public function preSolve(contact : Contact, oldManifold : Manifold) : Void {
    super.preSolve(contact, oldManifold);

    var fixtureA : Fixture = contact.getFixtureA();
    var fixtureB : Fixture = contact.getFixtureB();

    if (fixtureA == m_platform || fixtureB == m_platform) {
      contact.setTangentSpeed(5.0);
    }
  }

override public function getTestName() : String {
    return "Conveyor Belt";
  }
}

