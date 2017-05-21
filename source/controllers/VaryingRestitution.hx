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
 * Created at 1:59:32 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

/**
 * @author Daniel Murphy
 */
class VaryingRestitution extends TestbedTest {

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 1.0;

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 1.0;

    var restitution : Array<Float> = [0.0, 0.1, 0.3, 0.5, 0.75, 0.9, 1.0];

    for(i in 0 ... 7) {
      var bd : BodyDef = new BodyDef();
      bd.type = BodyType.DYNAMIC;
      bd.position.set(-10.0 + 3.0 * i, 20.0);

      var body : Body = getWorld().createBody(bd);

      fd.restitution = restitution[i];
      body.createFixture(fd);
    }
  }

  override public function getTestName() : String {
    return "Varying Restitution";
  }
}

