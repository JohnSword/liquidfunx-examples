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
 * Created at 2:04:52 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;

/**
 * @author Daniel Murphy
 */
class ShapeEditing extends TestbedTest {

  var m_body : Body;
  var m_fixture1 : Fixture;
  var m_fixture2 : Fixture;

  override public function initTest() : Void {
    trace("Press: (c) create a shape, (d) destroy a shape.");

    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(0.0, 10.0);
    m_body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(4.0, 4.0, new Vec2(0.0, 0.0), 0.0);
    m_fixture1 = m_body.createFixtureShape(shape, 10.0);

    m_fixture2 = null;
  }

override public function keyPressed(argKeyCode : Int) : Void {
  trace(argKeyCode);
    switch (argKeyCode) {
      case 67: //'c'
        if (m_fixture2 == null) {
          var shape : CircleShape = new CircleShape();
          shape.m_radius = 3.0;
          shape.m_p.set(0.5, -4.0);
          m_fixture2 = m_body.createFixtureShape(shape, 10.0);
          m_body.setAwake(true);
        }

      case 68: //'d'
        if (m_fixture2 != null) {
          m_body.destroyFixture(m_fixture2);
          m_fixture2 = null;
          m_body.setAwake(true);
        }
    }
  }

  override public function step() : Void {
    super.step();
  }

  override public function getTestName() : String {
    return "Shape Editing";
  }
}

