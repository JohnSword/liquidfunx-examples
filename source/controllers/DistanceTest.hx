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

import box2d.collision.SimplexCache;
import box2d.collision.DistanceInput;
import box2d.collision.DistanceOutput;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Settings;
import box2d.common.Transform;
import box2d.common.Vec2;

import haxe.ds.Vector;

class DistanceTest extends TestbedTest {
	
	var m_positionB : Vec2;
	var m_angleB : Float = 0;
	
	var m_transformA : Transform;
	var m_transformB : Transform;
	var m_polygonA : PolygonShape;
	var m_polygonB : PolygonShape;
	
	override public function getTestName() : String {
		return "Distance";
	}
	
	override public function initTest() : Void {
		input.transformA = new Transform();
		input.transformB = new Transform();
		m_transformA = new Transform();
		m_transformA.setIdentity();
		m_transformA.p.set(0.0, -0.2);
		m_polygonA = new PolygonShape();
		m_polygonA.setAsBox(10.0, 0.2);
		
		m_positionB = new Vec2();
		m_positionB.set(12.017401, 0.13678508);
		m_angleB = -0.0109265;
		
		m_transformB = new Transform();
		m_transformB.setVF(m_positionB, m_angleB);
		
		m_polygonB = new PolygonShape();
		m_polygonB.setAsBox(2.0, 0.1);

		for(i in 0 ... v2.length) {
			v2[i] = new Vec2();
		}
	}
	
	var input : DistanceInput = new DistanceInput();
	var cache : SimplexCache = new SimplexCache();
	var output : DistanceOutput = new DistanceOutput();
	var v2 : Vector<Vec2> = new Vector<Vec2>(Settings.maxPolygonVertices);
	var color : Color3f = new Color3f(0.9, 0.9, 0.9);
	var c1 : Color3f = new Color3f(1.0, 0.0, 0.0);
	var c2 : Color3f = new Color3f(1.0, 1.0, 0.0);
	
	override public function step() : Void {
		super.step();
		
		input.proxyA.set(m_polygonA,0);
		input.proxyB.set(m_polygonB,0);
		input.transformA.set(m_transformA);
		input.transformB.set(m_transformB);
		input.useRadii = true;
		cache.count = 0;
		getWorld().getPool().getDistance().distance(output, cache, input);
		
		for(i in 0 ... m_polygonA.m_count) {
			Transform.mulToOutUnsafe(m_transformA, m_polygonA.m_vertices[i], v2[i]);
		}
		getDebugDraw().drawPolygon(v2, m_polygonA.m_count, color);
		
		for(i in 0 ... m_polygonB.m_count) {
			Transform.mulToOutUnsafe(m_transformB, m_polygonB.m_vertices[i], v2[i]);
		}
		getDebugDraw().drawPolygon(v2, m_polygonB.m_count, color);
		
		var x1 : Vec2 = output.pointA;
		var x2 : Vec2 = output.pointB;
		
		getDebugDraw().drawPoint(x1, 4.0, c1);
		
		getDebugDraw().drawPoint(x2, 4.0, c2);
	}
	
	override public function keyPressed(argKeyCode : Int) : Void {
		switch (argKeyCode) {
			case 65: //'a'
				m_positionB.x -= 0.1;
			case 68: //'d'
				m_positionB.x += 0.1;
			case 83: //'s'
				m_positionB.y -= 0.1;
			case 87 : //'w'
				m_positionB.y += 0.1;
			case 81: //'q'
				m_angleB += 0.1 * MathUtils.PI;
			case 69: //'e'
				m_angleB -= 0.1 * MathUtils.PI;
		}
		
		trace(m_positionB.x);
		m_transformB.setVF(m_positionB, m_angleB);
	}
}

