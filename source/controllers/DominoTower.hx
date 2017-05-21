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
 * Created at 8:41:50 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.World;

/**
 * @author Daniel Murphy
 */
class DominoTower extends TestbedTest {
  var dwidth : Float = .20;
  var dheight : Float = 1.0;
  var ddensity : Float = 0;// : Float = 10f;
  var dfriction : Float = 0.1;
  var baseCount : Int = 25;

  public function makeDomino(x : Float, y : Float, horizontal : Bool, world : World) : Void {
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(.5 * dwidth, .5 * dheight);
    var fd : FixtureDef = new FixtureDef();
    fd.shape = sd;
    fd.density = ddensity;
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    fd.friction = dfriction;
    fd.restitution = 0.65;
    bd.position = new Vec2(x, y);
    bd.angle = horizontal ? (Math.PI / 2.0) : 0;
    var myBody : Body = getWorld().createBody(bd);
    myBody.createFixture(fd);
  }

  override public function getDefaultCameraPos() : Vec2 {
    return new Vec2(0,12);
  }
  
  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    // Floor
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(50.0, 10.0);

    var bd : BodyDef = new BodyDef();
    bd.position = new Vec2(0.0, -10.0);
    getWorld().createBody(bd).createFixtureShape(sd, 0);

    ddensity = 10;
    // Make bullet
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(.7, .7);
    var fd : FixtureDef = new FixtureDef();
    fd.density = 35;
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    fd.shape = sd;
    fd.friction = 0;
    fd.restitution = 0.85;
    bd.bullet = true;
    // bd.addShape(sd);
    bd.position = new Vec2(30, 50);
    var b : Body = getWorld().createBody(bd);
    b.createFixture(fd);
    b.setLinearVelocity(new Vec2(-25, -25));
    b.setAngularVelocity(6.7);

    fd.density = 25;
    bd.position = new Vec2(-30, 25);
    b = getWorld().createBody(bd);
    b.createFixture(fd);
    b.setLinearVelocity(new Vec2(35, -10));
    b.setAngularVelocity(-8.3);

    var currX : Float;
    // Make base
    for(i in 0 ... baseCount) {
      currX = i * 1.5 * dheight - (1.5 * dheight * baseCount / 2);
      makeDomino(currX, dheight / 2.0, false, m_world);
      makeDomino(currX, dheight + dwidth / 2.0, true, m_world);
    }
    currX = baseCount * 1.5 * dheight - (1.5 * dheight * baseCount / 2);
    // Make 'I's
    for (j in 1 ... baseCount) {
      if (j > 3)
        ddensity *= .8;
      var currY : Float = dheight * .5 + (dheight + 2 * dwidth) * .99 * j; // y at center of 'I'
                                                                        // structure

      for (i in 0 ... (baseCount - j)) {
        currX = i * 1.5 * dheight - (1.5 * dheight * (baseCount - j) / 2);// +
                                                                              // parent.random(-.05f,
                                                                              // .05f);
        ddensity *= 2.5;
        if (i == 0) {
          makeDomino(currX - (1.25 * dheight) + .5 * dwidth, currY - dwidth, false, m_world);
        }
        if (i == baseCount - j - 1) {
          // if (j != 1) //djm: why is this here? it makes it off balance
          makeDomino(currX + (1.25 * dheight) - .5 * dwidth, currY - dwidth, false, m_world);
        }
        ddensity /= 2.5;
        makeDomino(currX, currY, false, m_world);
        makeDomino(currX, currY + .5 * (dwidth + dheight), true, m_world);
        makeDomino(currX, currY - .5 * (dwidth + dheight), true, m_world);
      }
    }
  }

  override public function getTestName() : String {
    return "Domino Tower";
  }

}

