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
 * Created at 4:56:29 AM Jan 14, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

/**
 * @author Daniel Murphy
 */
class VerticalStack extends TestbedTest {
  private static var BULLET_TAG : Int = 1;

  public static var e_columnCount : Int = 5;
  public static var e_rowCount : Int = 15;

  var m_bullet : Body;

  override public function getBodyTag(argBody : Body) : Int {
    if (argBody == m_bullet) {
      return BULLET_TAG;
    }
    return super.getBodyTag(argBody);
  }

  override public function processBody(argBody : Body, argTag : Int) : Void {
    if (argTag == BULLET_TAG) {
      m_bullet = argBody;
      return;
    }
    super.processBody(argBody, argTag);
  }

  override public function isSaveLoadEnabled() : Bool {
    return true;
  }

  override public function initTest() : Void {
    trace("Press ',' to launch bullet.");

    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    // shape.setAsBox(40, 10, new Vec2(0,-10), 0);
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    shape.set(new Vec2(20.0, 0.0), new Vec2(20.0, 20.0));
    ground.createFixtureShape(shape, 0.0);

    var xs : Array<Float> = [0.0, -10.0, -5.0, 5.0, 10.0];

    for (j in 0 ... e_columnCount) {
      var shape : PolygonShape = new PolygonShape();
      shape.setAsBox(0.5, 0.5);

      var fd : FixtureDef = new FixtureDef();
      fd.shape = shape;
      fd.density = 1.0;
      fd.friction = 0.3;

      for(i in 0 ... e_rowCount) {
        var bd : BodyDef = new BodyDef();
        bd.type = BodyType.DYNAMIC;

        var n : Int = j * e_rowCount + i;

        var x : Float = 0.0;
        // float x = RandomFloat(-0.02f, 0.02f);
        // float x = i % 2 == 0 ? -0.025f : 0.025f;
        bd.position.set(xs[j] + x, 0.752 + 1.54 * i);
        var body : Body = getWorld().createBody(bd);

        body.createFixture(fd);
      }
    }

    m_bullet = null;
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    trace(argKeyCode);
    switch (argKeyCode) {
      case 188: //','
        if (m_bullet != null) {
          getWorld().destroyBody(m_bullet);
          m_bullet = null;
        }
        var shape : CircleShape = new CircleShape();
        shape.m_radius = 0.25;

        var fd : FixtureDef = new FixtureDef();
        fd.shape = shape;
        fd.density = 20.0;
        fd.restitution = 0.05;

        var bd : BodyDef = new BodyDef();
        bd.type = BodyType.DYNAMIC;
        bd.bullet = true;
        bd.position.set(-31.0, 5.0);

        m_bullet = getWorld().createBody(bd);
        m_bullet.createFixture(fd);

        m_bullet.setLinearVelocity(new Vec2(400.0, 0.0));
    }
  }

  override public function getTestName() : String {
    return "Vertical Stack";
  }
}

