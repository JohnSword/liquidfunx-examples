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
 * Created at 2:39:05 PM Jan 23, 2011
 */
package controllers;

import haxe.ds.Vector;
import box2d.collision.shapes.ChainShape;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.MathUtils;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.FixtureDef;

/**
 * @author Daniel Murphy
 */
 class CharacterCollision extends TestbedTest {
  private static var CHARACTER_TAG : Int = 1231;

  private var m_character : Body;

override public function getBodyTag(argBody : Body) : Int {
    if (argBody == m_character) {
      return CHARACTER_TAG;
    }
    return super.getBodyTag(argBody);
  }

override public function processBody(argBody : Body, argTag : Int) : Void {
    if (argTag == CHARACTER_TAG) {
      m_character = argBody;
      return;
    }
    super.processBody(argBody, argTag);
  }

override public function isSaveLoadEnabled() : Bool {
    return true;
  }

override public function initTest() : Void {
    trace("This tests various character collision shapes");
    trace("Limitation: square and hexagon can snag on aligned boxes.");
    trace("Feature: edge chains have smooth collision inside and out.");

    // Ground body
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-20.0, 0.0), new Vec2(20.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    // Collinear edges
    // This shows the problematic case where a box shape can hit
    // an internal vertex.
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.m_radius = 0.0;
    shape.set(new Vec2(-8.0, 1.0), new Vec2(-6.0, 1.0));
    ground.createFixtureShape(shape, 0.0);
    shape.set(new Vec2(-6.0, 1.0), new Vec2(-4.0, 1.0));
    ground.createFixtureShape(shape, 0.0);
    shape.set(new Vec2(-4.0, 1.0), new Vec2(-2.0, 1.0));
    ground.createFixtureShape(shape, 0.0);

    // Chain shape
    var bd : BodyDef = new BodyDef();
    bd.angle = 0.25 * MathUtils.PI;
    var ground : Body = getWorld().createBody(bd);

    var vs : Vector<Vec2> = new Vector<Vec2>(4);
    vs[0] = new Vec2(5.0, 7.0);
    vs[1] = new Vec2(6.0, 8.0);
    vs[2] = new Vec2(7.0, 8.0);
    vs[3] = new Vec2(8.0, 7.0);
    var shape : ChainShape = new ChainShape();
    shape.createChain(vs, 4);
    ground.createFixtureShape(shape, 0.0);

    // Square tiles. This shows that adjacency shapes may
    // have non-smooth collision. There is no solution
    // to this problem.
    var bd : BodyDef = new BodyDef();
    var ground : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox2(1.0, 1.0, new Vec2(4.0, 3.0), 0.0);
    ground.createFixtureShape(shape, 0.0);
    shape.setAsBox2(1.0, 1.0, new Vec2(6.0, 3.0), 0.0);
    ground.createFixtureShape(shape, 0.0);
    shape.setAsBox2(1.0, 1.0, new Vec2(8.0, 3.0), 0.0);
    ground.createFixtureShape(shape, 0.0);

    // Square made from an edge loop. Collision should be smooth.
    var bd : BodyDef = new BodyDef();
    var ground : Body = m_world.createBody(bd);

    var vs : Vector<Vec2> = new Vector<Vec2>(4);
    vs[0] = new Vec2(-1.0, 3.0);
    vs[1] = new Vec2(1.0, 3.0);
    vs[2] = new Vec2(1.0, 5.0);
    vs[3] = new Vec2(-1.0, 5.0);
    var shape : ChainShape = new ChainShape();
    shape.createLoop(vs, 4);
    ground.createFixtureShape(shape, 0.0);

    // Edge loop. Collision should be smooth.
    var bd : BodyDef = new BodyDef();
    bd.position.set(-10.0, 4.0);
    var ground : Body = getWorld().createBody(bd);

    var vs : Vector<Vec2> = new Vector<Vec2>(10);
    vs[0] = new Vec2(0.0, 0.0);
    vs[1] = new Vec2(6.0, 0.0);
    vs[2] = new Vec2(6.0, 2.0);
    vs[3] = new Vec2(4.0, 1.0);
    vs[4] = new Vec2(2.0, 2.0);
    vs[5] = new Vec2(0.0, 2.0);
    vs[6] = new Vec2(-2.0, 2.0);
    vs[7] = new Vec2(-4.0, 3.0);
    vs[8] = new Vec2(-6.0, 2.0);
    vs[9] = new Vec2(-6.0, 0.0);
    var shape : ChainShape = new ChainShape();
    shape.createLoop(vs, 10);
    ground.createFixtureShape(shape, 0.0);

    // Square character 1
    var bd : BodyDef = new BodyDef();
    bd.position.set(-3.0, 8.0);
    bd.type = BodyType.DYNAMIC;
    bd.fixedRotation = true;
    bd.allowSleep = false;

    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.5);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    body.createFixture(fd);

    // Square character 2
    var bd : BodyDef = new BodyDef();
    bd.position.set(-5.0, 5.0);
    bd.type = BodyType.DYNAMIC;
    bd.fixedRotation = true;
    bd.allowSleep = false;

    var body : Body = getWorld().createBody(bd);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.25, 0.25);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    body.createFixture(fd);

    // Hexagon character
    var bd : BodyDef = new BodyDef();
    bd.position.set(-5.0, 8.0);
    bd.type = BodyType.DYNAMIC;
    bd.fixedRotation = true;
    bd.allowSleep = false;

    var body : Body = getWorld().createBody(bd);

    var angle : Float = 0.0;
    var delta : Float = MathUtils.PI / 3.0;
    var vertices : Vector<Vec2>  = new Vector<Vec2>(6);
    for(i in 0 ... 6) {
      vertices[i] = new Vec2(0.5 * MathUtils.cos(angle), 0.5 * MathUtils.sin(angle));
      angle += delta;
    }

    var shape : PolygonShape = new PolygonShape();
    shape.set(vertices, 6);

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    body.createFixture(fd);

    // Circle character
    var bd : BodyDef = new BodyDef();
    bd.position.set(3.0, 5.0);
    bd.type = BodyType.DYNAMIC;
    bd.fixedRotation = true;
    bd.allowSleep = false;

    body = getWorld().createBody(bd);

    var shape = new CircleShape();
    shape.m_radius = 0.5;

    fd = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    body.createFixture(fd);

    // Circle character
    var bd : BodyDef = new BodyDef();
    bd.position.set(-7.0, 6.0);
    bd.type = BodyType.DYNAMIC;
    bd.allowSleep = false;

    m_character = getWorld().createBody(bd);

    var shape : CircleShape = new CircleShape();
    shape.m_radius = 0.25;

    var fd : FixtureDef = new FixtureDef();
    fd.shape = shape;
    fd.density = 20.0;
    fd.friction = 1;
    m_character.createFixture(fd);
  }

override public function step() : Void {
    var v : Vec2 = m_character.getLinearVelocity();
    v.x = -5;

    super.step();
  }

override public function getTestName() : String {
    return "Character Collision";
  }
}

