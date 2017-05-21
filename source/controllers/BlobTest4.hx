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
/*
 * JBox2D - A Java Port of Erin Catto's Box2D
 * 
 * JBox2D homepage: http://jbox2d.sourceforge.net/ 
 * Box2D homepage: http://www.box2d.org
 * 
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not
 * claim that you wrote the original software. If you use this software
 * in a product, an acknowledgment in the product documentation would be
 * appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 * misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.ConstantVolumeJointDef;

class BlobTest4 extends TestbedTest {

  override public function getDefaultCameraScale() : Float {
      return 20;
    }

  override public function isSaveLoadEnabled() : Bool {
      return true;
    }

  override public function initTest() : Void {
    var ground : Body = null;
    var sd : PolygonShape = new PolygonShape();
    sd.setAsBox(50.0, 0.4);

    var bd : BodyDef = new BodyDef();
    bd.position.set(0.0, 0.0);
    ground = getWorld().createBody(bd);
    ground.createFixtureShape(sd, 0);

    sd.setAsBox2(0.4, 50.0, new Vec2(-10.0, 0.0), 0.0);
    ground.createFixtureShape(sd, 0);
    sd.setAsBox2(0.4, 50.0, new Vec2(10.0, 0.0), 0.0);
    ground.createFixtureShape(sd, 0);

    var cvjd : ConstantVolumeJointDef = new ConstantVolumeJointDef();

    var cx : Float = 0.0;
    var cy : Float = 10.0;
    var rx : Float = 5.0;
    var ry : Float = 5.0;
    var nBodies : Int = 20;
    var bodyRadius : Float = 0.5;
    for(i in 0 ... nBodies) {
      var angle : Float = MathUtils.map(i, 0, nBodies, 0, 2 * 3.1415);
      var bd : BodyDef = new BodyDef();
      // bd.isBullet = true;
      bd.fixedRotation = true;

      var x : Float = cx + rx * Math.sin(angle);
      var y : Float = cy + ry * Math.cos(angle);
      bd.position.setVec(new Vec2(x, y));
      bd.type = BodyType.DYNAMIC;
      var body : Body = getWorld().createBody(bd);

      var fd : FixtureDef = new FixtureDef();
      var cd : CircleShape = new CircleShape();
      cd.m_radius = bodyRadius;
      fd.shape = cd;
      fd.density = 1.0;
      body.createFixture(fd);
      cvjd.addBody(body);
    }

    cvjd.frequencyHz = 10.0;
    cvjd.dampingRatio = 1.0;
    cvjd.collideConnected = false;
    getWorld().createJoint(cvjd);

    var bd2 : BodyDef = new BodyDef();
    bd2.type = BodyType.DYNAMIC;
    var psd : PolygonShape = new PolygonShape();
    psd.setAsBox2(3.0, 1.5, new Vec2(cx, cy + 15.0), 0.0);
    bd2.position = new Vec2(cx, cy + 15.0);
    var fallingBox : Body = getWorld().createBody(bd2);
    fallingBox.createFixtureShape(psd, 1.0);
  }

  override public function getDefaultCameraPos() : Vec2 {
    return new Vec2(0, 10);
  }

  override public function getTestName() : String {
    return "Blob Joint";
  }
}

