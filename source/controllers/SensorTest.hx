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
 * Created at 1:25:51 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.common.Settings;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.contacts.Contact;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class SensorTest extends TestbedTest {

  var e_count : Int = 7;
  var m_sensor : Fixture;
  var m_bodies : Vector<Body> = new Vector<Body>(7);
  var m_touching : Vector<BoolWrapper> = new Vector<BoolWrapper>(7);

  override public function initTest() : Void {

    for(i in 0 ... m_touching.length) {
      m_touching[i] = new BoolWrapper();
    }

    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 5.0;
    shape.m_p.set(0.0, 10.0);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.isSensor = true;
    m_sensor = ground.createFixture(fd);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 1.0;

    for(i in 0 ... e_count) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-10.0 + 3.0 * i, 20.0);
      bd.userData = m_touching[i];

      m_touching[i].tf = false;
      m_bodies[i] = getWorld().createBody(bd);

      m_bodies[i].createFixtureShape(shape, 1.0);
    }
  }

  // Implement contact listener.
  override public function beginContact(contact : Contact) : Void {
    var fixtureA : Fixture = contact.getFixtureA();
    var fixtureB : Fixture = contact.getFixtureB();

    if (fixtureA == m_sensor) {
      var userData : BoolWrapper = cast fixtureB.getBody().getUserData();
      if (userData != null) {
        userData.tf = true;
      }
    }

    if (fixtureB == m_sensor) {
      var userData : Dynamic = cast fixtureA.getBody().getUserData();
      if (userData != null) {
        userData.tf = true;
      }
    }
  }

  // Implement contact listener.
  override public function endContact(contact : Contact) : Void {
    var fixtureA : Fixture = contact.getFixtureA();
    var fixtureB : Fixture = contact.getFixtureB();

    if (fixtureA == m_sensor) {
      var userData : BoolWrapper = fixtureB.getBody().getUserData();
      if (userData != null) {
        userData.tf = false;
      }
    }

    if (fixtureB == m_sensor) {
      var userData : BoolWrapper = cast fixtureA.getBody().getUserData();
      if (userData != null) {
        userData.tf = false;
      }
    }
  }

  override public function step() : Void {
    super.step();

    // Traverse the contact results. Apply a force on shapes
    // that overlap the sensor.
    for(i in 0 ... e_count) {
      if (m_touching[i].tf == false) {
        continue;
      }

      var body : Body = m_bodies[i];
      var ground : Body = m_sensor.getBody();

      var circle : CircleShape = cast m_sensor.getShape();
      var center : Vec2 = ground.getWorldPoint(circle.m_p);

      var position : Vec2 = body.getPosition();

      var d : Vec2 = center.sub(position);
      if (d.lengthSquared() < Settings.EPSILON * Settings.EPSILON) {
        continue;
      }

      d.normalize();
      var F : Vec2 = d.mulLocal(100);
      body.applyForce(F, position);
    }
  }

  override public function getTestName() : String {
    return "Sensor Test";
  }
}

class BoolWrapper {
  public var tf : Bool;
  public function new() {}
}
