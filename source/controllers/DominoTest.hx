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

import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

class DominoTest extends TestbedTest {

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    // Floor
    var fd : FixtureDef = new FixtureDef();
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(50.0, 10.0);
    fd.shape = sd;

    var bd : BodyDef = new BodyDef();
    bd.position = new Vec2(0.0, -10.0);
    getWorld().createBody(bd).createFixture(fd);

    // Platforms
    for(i in 0 ... 4) {
      var fd : FixtureDef = new FixtureDef();
      var sd : PolygonShape = new PolygonShape();
      sd.setAsBox(15.0, 0.125);
      fd.shape = sd;

      var bd : BodyDef = new BodyDef();
      bd.position = new Vec2(0.0, 5 + 5 * i);
      getWorld().createBody(bd).createFixture(fd);
    }

    var fd : FixtureDef = new FixtureDef();
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(0.125, 2);
    fd.shape = sd;
    fd.density = 25.0;

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    var friction : Float = .5;
    var numPerRow : Int = 25;

    for(i in 0 ... 4) {
      for (j in 0 ... numPerRow) {
        fd.friction = friction;
        bd.position = new Vec2(-14.75 + j * (29.5 / (numPerRow - 1)), 7.3 + 5 * i);
        if (i == 2 && j == 0) {
          bd.angle = -0.1;
          bd.position.x += .1;
        } else if (i == 3 && j == numPerRow - 1) {
          bd.angle = .1;
          bd.position.x -= .1;
        } else
          bd.angle = 0;
        var myBody : Body = getWorld().createBody(bd);
        myBody.createFixture(fd);
      }
    }
  }

override public function getTestName() : String {
    return "Dominos";
  }
}

