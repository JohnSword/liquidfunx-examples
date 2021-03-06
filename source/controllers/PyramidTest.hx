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
 * Created at 5:36:06 PM Jul 17, 2010
 */
package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;

/**
 * @author Daniel Murphy
 */
class PyramidTest extends TestbedTest {

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    var count : Int = 20;
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0), new Vec2(40.0, 0));
    ground.createFixtureShape(shape, 0.0);

    var a : Float = .5;
    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(a, a);

    var x : Vec2 = new Vec2(-7.0, 0.75);
    var y : Vec2 = new Vec2();
    var deltaX : Vec2 = new Vec2(0.5625, 1.25);
    var deltaY : Vec2 = new Vec2(1.125, 0.0);

    for(i in 0 ... count) {
      y.setVec(x);

      for (j in i ... count) {
        var bd : BodyDef = new BodyDef();
        bd.type = BodyType.DYNAMIC;
        bd.position.setVec(y);
        var body : Body = getWorld().createBody(bd);
        body.createFixtureShape(shape, 5.0);
        y.addLocalVec(deltaY);
      }

      x.addLocalVec(deltaX);
    }
  }

override public function getTestName() : String {
    return "Pyramid";
  }
}

