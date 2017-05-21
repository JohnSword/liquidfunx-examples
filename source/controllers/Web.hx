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
 * Created at 2:10:11 PM Jan 23, 2011
 */
package controllers;

import box2d.collision.shapes.EdgeShape;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.joints.DistanceJointDef;
import box2d.dynamics.joints.Joint;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class Web extends TestbedTest {

  var m_bodies : Vector<Body> = new Vector<Body>(4);
  var m_joints : Vector<Joint> = new Vector<Joint>(8);

  override public function initTest() : Void {
    trace("This demonstrates a soft distance joint.");
    trace("Press: (b) to delete a body, (j) to delete a joint");

    var ground : Body = null;
    var bd : BodyDef = new BodyDef();
    ground = getWorld().createBody(bd);

    var shape : EdgeShape = new EdgeShape();
    shape.set(new Vec2(-40.0, 0.0), new Vec2(40.0, 0.0));
    ground.createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    shape.setAsBox(0.5, 0.5);

    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;

    bd.position.set(-5.0, 5.0);
    m_bodies[0] = getWorld().createBody(bd);
    m_bodies[0].createFixtureShape(shape, 5.0);

    bd.position.set(5.0, 5.0);
    m_bodies[1] = getWorld().createBody(bd);
    m_bodies[1].createFixtureShape(shape, 5.0);

    bd.position.set(5.0, 15.0);
    m_bodies[2] = getWorld().createBody(bd);
    m_bodies[2].createFixtureShape(shape, 5.0);

    bd.position.set(-5.0, 15.0);
    m_bodies[3] = getWorld().createBody(bd);
    m_bodies[3].createFixtureShape(shape, 5.0);

    var jd : DistanceJointDef = new DistanceJointDef();
    var p1 : Vec2 = new Vec2();
    var p2 : Vec2 = new Vec2();
    var d : Vec2 = new Vec2();

    jd.frequencyHz = 4.0;
    jd.dampingRatio = 0.5;

    jd.bodyA = ground;
    jd.bodyB = m_bodies[0];
    jd.localAnchorA.set(-10.0, 0.0);
    jd.localAnchorB.set(-0.5, -0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[0] = getWorld().createJoint(jd);

    jd.bodyA = ground;
    jd.bodyB = m_bodies[1];
    jd.localAnchorA.set(10.0, 0.0);
    jd.localAnchorB.set(0.5, -0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[1] = getWorld().createJoint(jd);

    jd.bodyA = ground;
    jd.bodyB = m_bodies[2];
    jd.localAnchorA.set(10.0, 20.0);
    jd.localAnchorB.set(0.5, 0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[2] = getWorld().createJoint(jd);

    jd.bodyA = ground;
    jd.bodyB = m_bodies[3];
    jd.localAnchorA.set(-10.0, 20.0);
    jd.localAnchorB.set(-0.5, 0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[3] = getWorld().createJoint(jd);

    jd.bodyA = m_bodies[0];
    jd.bodyB = m_bodies[1];
    jd.localAnchorA.set(0.5, 0.0);
    jd.localAnchorB.set(-0.5, 0.0);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[4] = getWorld().createJoint(jd);

    jd.bodyA = m_bodies[1];
    jd.bodyB = m_bodies[2];
    jd.localAnchorA.set(0.0, 0.5);
    jd.localAnchorB.set(0.0, -0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[5] = getWorld().createJoint(jd);

    jd.bodyA = m_bodies[2];
    jd.bodyB = m_bodies[3];
    jd.localAnchorA.set(-0.5, 0.0);
    jd.localAnchorB.set(0.5, 0.0);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[6] = getWorld().createJoint(jd);

    jd.bodyA = m_bodies[3];
    jd.bodyB = m_bodies[0];
    jd.localAnchorA.set(0.0, -0.5);
    jd.localAnchorB.set(0.0, 0.5);
    p1 = jd.bodyA.getWorldPoint(jd.localAnchorA);
    p2 = jd.bodyB.getWorldPoint(jd.localAnchorB);
    d = p2.sub(p1);
    jd.length = d.length();
    m_joints[7] = getWorld().createJoint(jd);
  }

  override public function keyPressed(argKeyCode : Int) : Void {
    switch (argKeyCode) {
      case 66: //'b'
        for(i in 0 ... 4) {
          if (m_bodies[i] != null) {
            getWorld().destroyBody(m_bodies[i]);
            m_bodies[i] = null;
            break;
          }
        }
      case 74: //'j'
        for(i in 0 ... 8) {
          if (m_joints[i] != null) {
            getWorld().destroyJoint(m_joints[i]);
            m_joints[i] = null;
            break;
          }
        }
    }
  }

  override public function jointDestroyed(joint : Joint) : Void {
    for(i in 0 ... 8) {
      if (m_joints[i] == joint) {
        m_joints[i] = null;
        break;
      }
    }
  }

  override public function getTestName() : String {
    return "Web";
  }
}

