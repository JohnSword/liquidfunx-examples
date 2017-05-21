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
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Settings;
import box2d.common.Vec2;

import haxe.ds.Vector;

class ConvexHull extends TestbedTest {

  private var e_count : Int = Settings.maxPolygonVertices;

  private var m_auto : Bool = false;
  private var m_points : Vector<Vec2> = new Vector<Vec2>(Settings.maxPolygonVertices);
  private var m_count : Int;

  override public function initTest() : Void {
    trace("Press g to generate a new random convex hull");
    color2 = new Color3f(.9, .5, .5);
    generate();
  }

  private function generate() : Void {
    var lowerBound : Vec2 = new Vec2(-8, -8);
    var upperBound : Vec2 = new Vec2(8, 8);

    for(i in 0 ... e_count) {
      var x : Float = MathUtils.randomFloat(-8, 8);
      var y : Float = MathUtils.randomFloat(-8, 8);

      var v : Vec2 = new Vec2(x, y);
      MathUtils.clampToOut(v, lowerBound, upperBound, v);
      m_points[i] = v;
    }
    m_count = e_count;
  }

override public function keyPressed(argKeyCode : Int) : Void {
    trace(argKeyCode);
    if (argKeyCode == 71) { /// g
      generate();
    } else if (argKeyCode == 65) { // a
      m_auto = !m_auto;
    }
  }

  var shape : PolygonShape = new PolygonShape();
  var color : Color3f = new Color3f(.9, .9, .9);

  override public function step() : Void {
    super.step();

    shape.set(m_points, m_count);

    getDebugDraw().drawPolygon(shape.m_vertices, shape.m_count, color);

    for(i in 0 ... m_count) {
      getDebugDraw().drawPoint(m_points[i], 2.0, color2);
      // getDebugDraw().drawString(m_points[i].add(new Vec2(0.05, 0.05)), i + "", Color3f.WHITE);
    }

    if (m_auto) {
      generate();
    }
  }

override public function getTestName() : String {
    return "Convex Hull";
  }

}

