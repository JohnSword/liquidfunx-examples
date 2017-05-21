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

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

class VaryingFrictionTest extends TestbedTest {

  override public function getTestName() : String {
    return "Varying Friction";
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(13.0, 0.25);

    var bd : BodyDef = new BodyDef();
    bd.position.set(-4.0, 22.0);
    bd.angle = -0.25;

    var ground : Body = getWorld().createBody(bd);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.25, 1.0);

    var bd : BodyDef = new BodyDef();
    bd.position.set(10.5, 19.0);

    var ground : Body = getWorld().createBody(bd);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(13.0, 0.25);

    var bd : BodyDef = new BodyDef();
    bd.position.set(4.0, 14.0);
    bd.angle = 0.25;

    var ground : Body = getWorld().createBody(bd);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.25, 1.0);

    var bd : BodyDef = new BodyDef();
    bd.position.set(-10.5, 11.0);

    var ground : Body = getWorld().createBody(bd);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(13.0, 0.25);

    var bd : BodyDef = new BodyDef();
    bd.position.set(-4.0, 6.0);
    bd.angle = -0.25;

    var ground : Body = getWorld().createBody(bd);
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.5);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 25.0;

    var friction : Array<Float> = [ 0.75, 0.5, 0.35, 0.1, 0.0 ];

    for(i in 0 ... 5) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-15.0 + 4.0 * i, 28.0);
      var body : Body = getWorld().createBody(bd);

      fd.friction = friction[i];
      body.createFixture(fd);
    }
  }

}

