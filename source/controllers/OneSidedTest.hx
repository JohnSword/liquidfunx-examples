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
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Settings;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.contacts.Contact;

enum State {
  e_unknown; 
  e_above; 
  e_below;
}

class OneSidedTest extends TestbedTest {

  private static var PLATFORM_TAG : Int = 10;
  private static var CHARACTER_TAG : Int = 11;

  var m_radius : Float = 0;
  var m_top : Float = 0; 
  var m_bottom : Float = 0;
  var m_state : State;
  var m_platform : Fixture;
  var m_character : Fixture;

  override public function getFixtureTag(fixture : Fixture) : Int {
    if (fixture == m_platform)
      return PLATFORM_TAG;
    if (fixture == m_character)
      return CHARACTER_TAG;
    return super.getFixtureTag(fixture);
  }

  override public function processFixture(fixture : Fixture, tag : Int) : Void {
    if (tag == PLATFORM_TAG) {
      m_platform = fixture;
    } else if (tag == CHARACTER_TAG) {
      m_character = fixture;
    } else {
      super.processFixture(fixture, tag);
    }
  }
  
  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function getTestName() : String {
    return "One Sided";
  }

  override public function initTest() : Void {
    m_state = State.e_unknown;
    // Ground
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    // Platform
    var bd : BodyDef = new BodyDef();
    bd.position.set(0.0, 10.0);
    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(3.0, 0.5);
    m_platform = body.createFixtureShape(shape, 0.0);

    m_bottom = 10.0 - 0.5;
    m_top = 10.0 + 0.5;

    // Actor
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 12.0);
    var body : Body = getWorld().createBody(bd);

    m_radius = 0.5;
    var shape : CircleShape = new CircleShape();
    shape.m_radius = m_radius;
    m_character = body.createFixtureShape(shape, 20.0);

    body.setLinearVelocity(new Vec2(0.0, -50.0));

    m_state = State.e_unknown;
  }

  override public function preSolve(contact : Contact, oldManifold : Manifold) : Void {
    super.preSolve(contact, oldManifold);

    var fixtureA : Fixture = contact.getFixtureA();
    var fixtureB : Fixture = contact.getFixtureB();

    if (fixtureA != m_platform && fixtureA != m_character) {
      return;
    }

    if (fixtureB != m_character && fixtureB != m_character) {
      return;
    }

    var position : Vec2 = m_character.getBody().getPosition();

    if (position.y < m_top + m_radius - 3.0 * Settings.linearSlop) {
      contact.setEnabled(false);
    }
  }
}

