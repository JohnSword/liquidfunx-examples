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

import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

class ConfinedTest extends TestbedTest {

	var e_columnCount : Int = 0;
	var e_rowCount : Int = 0;
	
	override public function isSaveLoadEnabled() : Bool {
	  return true;
	}
	
	override public function getTestName() : String {
		return "Confined";
	}

	override public function initTest() : Void {
		trace("Press 'c' to create a circle");

		var bd : BodyDef = new BodyDef();
		var ground : Body = getWorld().createBody(bd);

		var shape : EdgeShape = new EdgeShape();

		// Floor
		shape.set(new Vec2(-10.0, 0.0), new Vec2(10.0, 0.0));
		ground.createFixtureShape(shape, 0.0);

		// Left wall
		shape.set(new Vec2(-10.0, 0.0), new Vec2(-10.0, 20.0));
		ground.createFixtureShape(shape, 0.0);

		// Right wall
		shape.set(new Vec2(10.0, 0.0), new Vec2(10.0, 20.0));
		ground.createFixtureShape(shape, 0.0);

		// Roof
		shape.set(new Vec2(-10.0, 20.0), new Vec2(10.0, 20.0));
		ground.createFixtureShape(shape, 0.0);

		var radius : Float = 0.5;
		var shape : CircleShape = new CircleShape();
		shape.m_p.setZero();
		shape.m_radius = radius;

		var fd : FixtureDef = new FixtureDef();
		fd.shape = shape;
		fd.density = 1.0;
		fd.friction = 0.1;

		for (j in 0 ... e_columnCount) {
			for (i in 0 ... e_rowCount) {
				var bd : BodyDef = new BodyDef();
				bd.type = BodyType.DYNAMIC;
				bd.position.set(-10.0 + (2.1 * j + 1.0 + 0.01 * i) * radius, (2.0 * i + 1.0) * radius);
				var body : Body = getWorld().createBody(bd);

				body.createFixture(fd);
			}
		}

		getWorld().setGravity(new Vec2(0.0, 0.0));
	}
	
	public function createCircle() : Void {
		var radius : Float = 2.0;
		var shape : CircleShape = new CircleShape();
		shape.m_p.setZero();
		shape.m_radius = radius;

		var fd : FixtureDef = new FixtureDef();
		fd.shape = shape;
		fd.density = 1.0;
		fd.friction = 0.0;

		var p : Vec2 = new Vec2(Math.random(), 3.0 + Math.random());
		var bd : BodyDef = new BodyDef();
		bd.type = BodyType.DYNAMIC;
		bd.position = p;
		//bd.allowSleep = false;
		var body : Body = getWorld().createBody(bd);

		body.createFixture(fd);
	}
	
	override public function step() : Void {
		super.step();
		var b : Body = getWorld().getBodyList();
		while (b != null) {
			if (b.getType() != BodyType.DYNAMIC) {
				b = b.getNext();
				continue;
			}
			var p : Vec2 = b.getPosition();
			if (p.x <= -10.0 || 10.0 <= p.x || p.y <= 0.0 || 20.0 <= p.y) {
				p.x += 0.0;
			}
			b = b.getNext();
		}
	}

	override public function keyPressed(argKeyCode : Int) : Void {
		trace(argKeyCode);
		switch(argKeyCode) {
		case 67: // 'c'
			createCircle();
		}
	}
}

