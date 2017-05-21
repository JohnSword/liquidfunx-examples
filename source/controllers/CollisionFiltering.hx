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
 * Created at 2:15:39 PM Jan 23, 2011
 */
package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.joints.PrismaticJointDef;

/**
 * @author Daniel Murphy
 */
 class CollisionFiltering extends TestbedTest {
	
	// This is a test of collision filtering.
	// There is a triangle, a box, and a circle.
	// There are 6 shapes. 3 large and 3 small.
	// The 3 small ones always collide.
	// The 3 large ones never collide.
	// The boxes don't collide with triangles (except if both are small).
	var k_smallGroup : Int = 1;
	var k_largeGroup : Int = -1;

	var k_defaultCategory : Int = 0x0001;
	var k_triangleCategory : Int = 0x0002;
	var k_boxCategory : Int = 0x0004;
	var k_circleCategory : Int = 0x0008;

	var k_triangleMask : Int = 0xFFFF;
	var k_boxMask : Int = 0xFFFF ^ 0x0002;
	var k_circleMask : Int = 0xFFFF;
	
	override public function isSaveLoadEnabled() : Bool {
	  return true;
	}

	override public function initTest() : Void {
		// Ground body
		var shape : EdgeShape = new EdgeShape();
		shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));

		var sd : FixtureDef = new FixtureDef();
		sd.shape = shape;
		sd.friction = 0.3;

		var bd : BodyDef = new BodyDef();
		var ground : Body = getWorld().createBody(bd);
		ground.createFixture(sd);

		// Small triangle
		var vertices : Vector<Vec2>  = new Vector<Vec2>(3);
		vertices[0] = new Vec2(-1.0, 0.0);
		vertices[1] = new Vec2(1.0, 0.0);
		vertices[2] = new Vec2(0.0, 2.0);
		var polygon : PolygonShape = new PolygonShape();
		polygon.set(vertices, 3);

		var triangleShapeDef : FixtureDef = new FixtureDef();
		triangleShapeDef.shape = polygon;
		triangleShapeDef.density = 1.0;

		triangleShapeDef.filter.groupIndex = k_smallGroup;
		triangleShapeDef.filter.categoryBits = k_triangleCategory;
		triangleShapeDef.filter.maskBits = k_triangleMask;

		var triangleBodyDef : BodyDef = new BodyDef();
		triangleBodyDef.type = BodyType.DYNAMIC;
		triangleBodyDef.position.set(-5.0, 2.0);
		
		var body1 : Body = getWorld().createBody(triangleBodyDef);
		body1.createFixture(triangleShapeDef);

		// Large triangle (recycle definitions)
		vertices[0].mulLocal(2.0);
		vertices[1].mulLocal(2.0);
		vertices[2].mulLocal(2.0);
		polygon.set(vertices, 3);
		triangleShapeDef.filter.groupIndex = k_largeGroup;
		triangleBodyDef.position.set(-5.0, 6.0);
		triangleBodyDef.fixedRotation = true;

		var body2 : Body = getWorld().createBody(triangleBodyDef);
		body2.createFixture(triangleShapeDef);

		var bd : BodyDef = new BodyDef();
		bd.type = BodyType.DYNAMIC;
		bd.position.set(-5.0, 10.0);
		var body : Body = getWorld().createBody(bd);

		var p : PolygonShape = new PolygonShape();
		p.setAsBox(0.5, 1.0);
		body.createFixtureShape(p, 1.0);

		var jd : PrismaticJointDef = new PrismaticJointDef();
		jd.bodyA = body2;
		jd.bodyB = body;
		jd.enableLimit = true;
		jd.localAnchorA.set(0.0, 4.0);
		jd.localAnchorB.setZero();
		jd.localAxisA.set(0.0, 1.0);
		jd.lowerTranslation = -1.0;
		jd.upperTranslation = 1.0;

		getWorld().createJoint(jd);

		// Small box
		polygon.setAsBox(1.0, 0.5);
		var boxShapeDef : FixtureDef = new FixtureDef();
		boxShapeDef.shape = polygon;
		boxShapeDef.density = 1.0;
		boxShapeDef.restitution = 0.1;

		boxShapeDef.filter.groupIndex = k_smallGroup;
		boxShapeDef.filter.categoryBits = k_boxCategory;
		boxShapeDef.filter.maskBits = k_boxMask;

		var boxBodyDef : BodyDef = new BodyDef();
		boxBodyDef.type = BodyType.DYNAMIC;
		boxBodyDef.position.set(0.0, 2.0);

		var body3 : Body = getWorld().createBody(boxBodyDef);
		body3.createFixture(boxShapeDef);

		// Large box (recycle definitions)
		polygon.setAsBox(2.0, 1.0);
		boxShapeDef.filter.groupIndex = k_largeGroup;
		boxBodyDef.position.set(0.0, 6.0);

		var body4 : Body = getWorld().createBody(boxBodyDef);
		body4.createFixture(boxShapeDef);

		// Small circle
		var circle : CircleShape = new CircleShape();
		circle.m_radius = 1.0;

		var circleShapeDef : FixtureDef = new FixtureDef();
		circleShapeDef.shape = circle;
		circleShapeDef.density = 1.0;

		circleShapeDef.filter.groupIndex = k_smallGroup;
		circleShapeDef.filter.categoryBits = k_circleCategory;
		circleShapeDef.filter.maskBits = k_circleMask;

		var circleBodyDef : BodyDef = new BodyDef();
		circleBodyDef.type = BodyType.DYNAMIC;
		circleBodyDef.position.set(5.0, 2.0);
		
		var body5 : Body = getWorld().createBody(circleBodyDef);
		body5.createFixture(circleShapeDef);

		// Large circle
		circle.m_radius *= 2.0;
		circleShapeDef.filter.groupIndex = k_largeGroup;
		circleBodyDef.position.set(5.0, 6.0);

		var body6 : Body = getWorld().createBody(circleBodyDef);
		body6.createFixture(circleShapeDef);
	}

	override public function getTestName() : String {
		return "Collision Filtering";
	}
	
}

