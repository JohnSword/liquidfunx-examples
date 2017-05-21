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
 * Created at 4:11:55 AM Jan 15, 2011
 */
package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.WeldJointDef;

/**
 * @author Daniel Murphy
 */
class Cantilever extends TestbedTest {

  var e_count : Int = 8;

  override public function isSaveLoadEnabled() : Bool {
      return true;
  }

  override public function initTest() : Void {
    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;

    var jd : WeldJointDef = new WeldJointDef();

    var prevBody : Body = ground;
    for(i in 0 ... e_count) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-14.5 + 1.0 * i, 5.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);

      var anchor : Vec2 = new Vec2(-15.0 + 1.0 * i, 5.0);
      jd.initialize(prevBody, body, anchor);
      getWorld().createJoint(jd);

      prevBody = body;
    }

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(1, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;

    var jd : WeldJointDef = new WeldJointDef();
    jd.frequencyHz = 5;
    jd.dampingRatio = .7;

    var prevBody : Body = ground;
    for(i in 0 ... 3) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-14.0 + 2.0 * i, 15.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);

      var anchor : Vec2 = new Vec2(-15.0 + 2.0 * i, 15.0);
      jd.initialize(prevBody, body, anchor);
      getWorld().createJoint(jd);

      prevBody = body;
    }

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;

    var jd : WeldJointDef = new WeldJointDef();

    var prevBody : Body = ground;
    for(i in 0 ... e_count) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-4.5 + 1.0 * i, 5.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);

      if (i > 0) {
        var anchor : Vec2 = new Vec2(-5.0 + 1.0 * i, 5.0);
        jd.initialize(prevBody, body, anchor);
        getWorld().createJoint(jd);
      }

      prevBody = body;
    }

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.125);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;

    var jd : WeldJointDef = new WeldJointDef();
    jd.frequencyHz = 8;
    jd.dampingRatio = .7;

    var prevBody : Body = ground;
    for(i in 0 ... e_count) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(5.5 + 1.0 * i, 10.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);

      if (i > 0) {
        var anchor : Vec2 = new Vec2(5.0 + 1.0 * i, 10.0);
        jd.initialize(prevBody, body, anchor);
        getWorld().createJoint(jd);
      }

      prevBody = body;
    }

    for(i in 0 ... 2) {
      var vertices : Vector<Vec2> = new Vector<Vec2>(3);
      vertices[0] = new Vec2(-0.5, 0.0);
      vertices[1] = new Vec2(0.5, 0.0);
      vertices[2] = new Vec2(0.0, 1.5);

      var shape : PolygonShape = new PolygonShape();
      shape.set(vertices, 3);

      var fd : FixtureDef = new FixtureDef();
      fd.shape = shape;
      fd.density = 1.0;

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-8.0 + 8.0 * i, 12.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);
    }

    for(i in 0 ... 2) {
      var shape : CircleShape = new CircleShape();
      shape.m_radius = 0.5;

      var fd : FixtureDef = new FixtureDef();
      fd.shape = shape;
      fd.density = 1.0;

      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-6.0 + 6.0 * i, 10.0);
      var body : Body = getWorld().createBody(bd);
      body.createFixture(fd);
    }
  }

override public function getTestName() : String {
    return "Cantilever";
  }
}

