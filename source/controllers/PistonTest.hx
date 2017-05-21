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

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.World;
import box2d.dynamics.joints.PrismaticJointDef;
import box2d.dynamics.joints.RevoluteJointDef;

class PistonTest extends TestbedTest {
  
  private var bullet : Bool = false;

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var world : World = getWorld();
    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(5.0, 100.0);
    bd = new BodyDef();
    bd.type = BodyType.STATIC;
    var sides : FixtureDef = new FixtureDef();
    sides.shape = shape;
    sides.density = 0;
    sides.friction = 0;
    sides.restitution = .8;
    sides.filter.categoryBits = 4;
    sides.filter.maskBits = 2;

    bd.position.set(-10.01, 50.0);
    var bod : Body = world.createBody(bd);
    bod.createFixture(sides);
    bd.position.set(10.01, 50.0);
    bod = world.createBody(bd);
    bod.createFixture(sides);

    // turney
    var cd : CircleShape;
    var fd : FixtureDef = new FixtureDef();
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var numPieces : Int = 5;
    var radius : Float = 4;
    bd.position = new Vec2(0.0, 25.0);
    var body : Body = getWorld().createBody(bd);
    for(i in 0 ... numPieces) {
      cd = new CircleShape();
      cd.m_radius = .5;
      fd.shape = cd;
      fd.density = 25;
      fd.friction = .1;
      fd.restitution = .9;
      var xPos : Float = radius * Math.cos(2 * Math.PI * (i / (numPieces)));
      var yPos : Float = radius * Math.sin(2 * Math.PI * (i / (numPieces)));
      cd.m_p.set(xPos, yPos);

      body.createFixture(fd);
    }

    var rjd : RevoluteJointDef = new RevoluteJointDef();
    rjd.initialize(body, getGroundBody(), body.getPosition());
    rjd.motorSpeed = MathUtils.PI;
    rjd.maxMotorTorque = 1000000.0;
    rjd.enableMotor = true;
    getWorld().createJoint(rjd);


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
    rjd.maxMotorTorque = 20000;
    rjd.enableMotor = true;
    getWorld().createJoint(rjd);

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
    shape.setAsBox(7, 2);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 17.0);
    var body : Body = getWorld().createBody(bd);
    var piston : FixtureDef = new FixtureDef();
    piston.shape = shape;
    piston.density = 2;
    piston.filter.categoryBits = 1;
    piston.filter.maskBits = 2;
    body.createFixture(piston);
    body.setBullet(false);
    
    var rjd : RevoluteJointDef = new RevoluteJointDef();
    rjd.initialize(prevBody, body, new Vec2(0.0, 17.0));
    getWorld().createJoint(rjd);

    var pjd : PrismaticJointDef = new PrismaticJointDef();
    pjd.initialize(ground, body, new Vec2(0.0, 17.0), new Vec2(0.0, 1.0));

    pjd.maxMotorForce = 1000.0;
    pjd.enableMotor = true;

    getWorld().createJoint(pjd);
    
    // Create a payload
    var sd : PolygonShape = new PolygonShape();
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var fixture : FixtureDef = new FixtureDef();
    var body : Body;
    for(i in 0 ... 100) {
      sd.setAsBox(0.4, 0.3);
      bd.position.set(-1.0, 23.0 + i);

      bd.bullet = bullet;
      body = world.createBody(bd);
      fixture.shape = sd;
      fixture.density = .1;
      fixture.filter.categoryBits = 2;
      fixture.filter.maskBits = 1 | 4 | 2;
      body.createFixture(fixture);
    }

    var cd : CircleShape = new CircleShape();
    cd.m_radius = 0.36;
    for(i in 0 ... 100) {
      bd.position.set(1.0, 23.0 + i);
      bd.bullet = bullet;
      fixture.shape = cd;
      fixture.density = 2;
      fixture.filter.categoryBits = 2;
      fixture.filter.maskBits = 1 | 4 | 2;
      body = world.createBody(bd);
      body.createFixture(fixture);
    }
        
    var angle : Float = 0.0;
    var delta : Float = MathUtils.PI / 3.0;
    var vertices : Vector<Vec2> = new Vector<Vec2>(6);
    for(i in 0 ... 6) {
      vertices[i] = new Vec2(0.3 * MathUtils.cos(angle), 0.3 * MathUtils.sin(angle));
      angle += delta;
    }

    var shape : PolygonShape = new PolygonShape();
    shape.set(vertices, 6);

    for(i in 0 ... 100) {
      bd.position.set(0, 23.0 + i);
      bd.type = BodyType.DYNAMIC;
      bd.fixedRotation = true;
      bd.bullet = bullet;
      fixture.shape = shape;
      fixture.density = 1;
      fixture.filter.categoryBits = 2;
      fixture.filter.maskBits = 1 | 4 | 2;
      body = world.createBody(bd);
      body.createFixture(fixture);
    }
  }

  override public function getTestName() : String {
    return "Piston Stress Test";
  }
}

