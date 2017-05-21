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
 * Created at 5:43:20 AM Jan 14, 2011
 */
package controllers;

import box2d.callbacks.TreeCallback;
import box2d.callbacks.TreeRayCastCallback;
import box2d.collision.AABB;
import box2d.collision.RayCastInput;
import box2d.collision.RayCastOutput;
import box2d.collision.broadphase.BroadPhaseStrategy;
import box2d.collision.broadphase.DynamicTree;
import box2d.common.Color3f;
import box2d.common.MathUtils;
import box2d.common.Settings;
import box2d.common.Vec2;
import box2d.common.Random;
import box2d.pooling.arrays.Vec2Array;

import haxe.ds.Vector;

/**
 * @author Daniel Murphy
 */
class DynamicTreeTest extends TestbedTest implements TreeCallback implements TreeRayCastCallback {

	var e_actorCount : Int = 128;
	var worldExtent : Float = 0;
	var m_proxyExtent : Float = 0;

	var m_tree : BroadPhaseStrategy;
	var m_queryAABB : AABB;
	var m_rayCastInput : RayCastInput;
	var m_rayCastOutput : RayCastOutput;
	var m_rayActor : Actor;
	var m_actors : Vector<Actor> = new Vector<Actor>(128);
	var m_stepCount : Int = 0;
	var m_automated : Bool;
	var rand : Random = new Random();

	override public function initTest() : Void {
		worldExtent = 15.0;
		m_proxyExtent = 0.5;

		m_tree = new DynamicTree();

		for(i in 0 ... e_actorCount) {
			var actor : Actor = m_actors[i] = new Actor();
			GetRandomAABB(actor.aabb);
			actor.proxyId = m_tree.createProxy(actor.aabb, actor);
		}

		m_stepCount = 0;

		var h : Float = worldExtent;
		m_queryAABB = new AABB();
		m_queryAABB.lowerBound.set(-3.0, -4.0 + h);
		m_queryAABB.upperBound.set(5.0, 6.0 + h);

		m_rayCastInput = new RayCastInput();
		m_rayCastInput.p1.set(-5.0, 5.0 + h);
		m_rayCastInput.p2.set(7.0, -4.0 + h);
		// m_rayCastInput.p1.set(0.0f, 2.0f + h);
		// m_rayCastInput.p2.set(0.0f, -2.0f + h);
		m_rayCastInput.maxFraction = 1.0;

		m_rayCastOutput = new RayCastOutput();

		m_automated = false;
	}

	override public function keyPressed(argKeyCode : Int) : Void {
		trace(argKeyCode);
		switch (argKeyCode) {
			case 65: //'a'
				m_automated = !m_automated;
			case 67: // 'c'
				CreateProxy();
			case 68: //'d'
				DestroyProxy();
			case 77: //'m'
				MoveProxy();
		}
	}

	private var vecPool : Vec2Array = new Vec2Array();

	override public function step() : Void {
		m_rayActor = null;
		for(i in 0 ... e_actorCount) {
			m_actors[i].fraction = 1.0;
			m_actors[i].overlap = false;
		}

		if (m_automated == true) {
			var actionCount : Int = MathUtils.max(1, e_actorCount >> 2);

			for(i in 0 ... actionCount) {
				Action();
			}
		}

		Query();
		RayCast();
		var vecs : Vector<Vec2> = vecPool.get(4);

		for(i in 0 ... e_actorCount) {
			var actor : Actor = m_actors[i];
			if (actor.proxyId == -1)
				continue;

			var c : Color3f = new Color3f(0.9, 0.9, 0.9);
			if (actor == m_rayActor && actor.overlap) {
				c.set(0.9, 0.6, 0.6);
			} else if (actor == m_rayActor) {
				c.set(0.6, 0.9, 0.6);
			} else if (actor.overlap) {
				c.set(0.6, 0.6, 0.9);
			}
			actor.aabb.getVertices(vecs);
			getDebugDraw().drawPolygon(vecs, 4, c);
		}

		var c : Color3f = new Color3f(0.7, 0.7, 0.7);
		m_queryAABB.getVertices(vecs);
		getDebugDraw().drawPolygon(vecs, 4, c);

		getDebugDraw().drawSegment(m_rayCastInput.p1, m_rayCastInput.p2, c);

		var c1 : Color3f = new Color3f(0.2, 0.9, 0.2);
		var c2 : Color3f = new Color3f(0.9, 0.2, 0.2);
		getDebugDraw().drawPoint(m_rayCastInput.p1, 6.0, c1);
		getDebugDraw().drawPoint(m_rayCastInput.p2, 6.0, c2);

		if (m_rayActor != null) {
			var cr : Color3f = new Color3f(0.2, 0.2, 0.9);
			var p : Vec2 = m_rayCastInput.p2.sub(m_rayCastInput.p1)
					.mulLocal(m_rayActor.fraction).addLocalVec(m_rayCastInput.p1);
			getDebugDraw().drawPoint(p, 6.0, cr);
		}

		++m_stepCount;

		if (TestbedSettings.DrawTree) {
			m_tree.drawTree(getDebugDraw());
		}

		getDebugDraw().drawString(5, 30,
				"(c)reate proxy, (d)estroy proxy, (a)utomate", Color3f.WHITE);
	}

	public function treeCallback(proxyId : Int) : Bool {
		var actor : Actor = cast m_tree.getUserData(proxyId);
		actor.overlap = AABB.testOverlap(m_queryAABB, actor.aabb);
		return true;
	}

	public function raycastCallback(input : RayCastInput, proxyId : Int) : Float {
		var actor : Actor = cast m_tree.getUserData(proxyId);

		var output : RayCastOutput = new RayCastOutput();
		var hit : Bool = actor.aabb.raycast(output, input, getWorld().getPool());

		if (hit) {
			m_rayCastOutput = output;
			m_rayActor = actor;
			m_rayActor.fraction = output.fraction;
			return output.fraction;
		}

		return input.maxFraction;
	}

	public function GetRandomAABB(aabb : AABB) : Void {
		var w : Vec2 = new Vec2();
		w.set(2.0 * m_proxyExtent, 2.0 * m_proxyExtent);
		// aabb.lowerBound.x = -m_proxyExtent;
		// aabb.lowerBound.y = -m_proxyExtent + worldExtent;
		aabb.lowerBound.x = MathUtils.randomFloat2(rand, -worldExtent, worldExtent);
		aabb.lowerBound.y = MathUtils.randomFloat2(rand, 0.0, 2.0 * worldExtent);
		aabb.upperBound.setVec(aabb.lowerBound).addLocalVec(w);
	}

	public function MoveAABB(aabb : AABB) : Void {
		var d : Vec2 = new Vec2();
		d.x = MathUtils.randomFloat2(rand, -0.5, 0.5);
		d.y = MathUtils.randomFloat2(rand, -0.5, 0.5);
		// d.x = 2.0f;
		// d.y = 0.0f;
		aabb.lowerBound.addLocalVec(d);
		aabb.upperBound.addLocalVec(d);

		var c0 : Vec2 = aabb.lowerBound.add(aabb.upperBound).mulLocal(.5);
		var min : Vec2 = new Vec2();
		min.set(-worldExtent, 0.0);
		var max : Vec2 = new Vec2();
		max.set(worldExtent, 2.0 * worldExtent);
		var c : Vec2 = MathUtils.clampVec(c0, min, max);

		aabb.lowerBound.addLocalVec(c.sub(c0));
		aabb.upperBound.addLocalVec(c.sub(c0));
	}

	public function CreateProxy() : Void {
		for(i in 0 ... e_actorCount) {
			var j : Int = MathUtils.abs(rand.next() % e_actorCount);
			var actor : Actor = m_actors[j];
			if (actor.proxyId == -1) {
				GetRandomAABB(actor.aabb);
				actor.proxyId = m_tree.createProxy(actor.aabb, actor);
				return;
			}
		}
	}

	public function DestroyProxy() : Void {
		for(i in 0 ... e_actorCount) {
			var j : Int = MathUtils.abs(rand.next() % e_actorCount);
			var actor : Actor = m_actors[j];
			if (actor.proxyId != -1) {
				m_tree.destroyProxy(actor.proxyId);
				actor.proxyId = -1;
				return;
			}
		}
	}

	public function MoveProxy() : Void {
		for(i in 0 ... e_actorCount) {
			var j : Int = MathUtils.abs(rand.next() % e_actorCount);
			var actor : Actor = m_actors[j];
			if (actor.proxyId == -1) {
				continue;
			}
			var aabb0 : AABB = new AABB(actor.aabb);
			MoveAABB(actor.aabb);
			var displacement : Vec2 = actor.aabb.getCenter().sub(aabb0.getCenter());
			m_tree.moveProxy(actor.proxyId, new AABB(actor.aabb), displacement);
			return;
		}
	}

	public function Action() : Void {
		var choice : Int = MathUtils.abs(rand.next() % 20);
		switch (choice) {
		case 0:
			CreateProxy();
		case 1:
			DestroyProxy();
		default:
			MoveProxy();
		}
	}

	public function Query() : Void {
		m_tree.query(this, m_queryAABB);

		for(i in 0 ... e_actorCount) {
			if (m_actors[i].proxyId == -1) {
				continue;
			}

			var overlap : Bool = AABB.testOverlap(m_queryAABB, m_actors[i].aabb);
		}
	}

	public function RayCast() : Void {
		m_rayActor = null;

		var input : RayCastInput = new RayCastInput();
		input.set(m_rayCastInput);

		// Ray cast against the dynamic tree.
		m_tree.raycast(this, input);

		// Brute force ray cast.
		var bruteActor : Actor = null;
		var bruteOutput : RayCastOutput = new RayCastOutput();
		for(i in 0 ... e_actorCount) {
			if (m_actors[i].proxyId == -1) {
				continue;
			}

			var output : RayCastOutput = new RayCastOutput();
			var hit : Bool = m_actors[i].aabb.raycast(output, input, getWorld().getPool());
			if (hit) {
				bruteActor = m_actors[i];
				bruteOutput = output;
				input.maxFraction = output.fraction;
			}
		}

		if (bruteActor != null) {
		  if(MathUtils.abs(bruteOutput.fraction - m_rayCastOutput.fraction) > Settings.EPSILON) {
		    trace("wrong!");
		  }
			
		}
	}

	override public function getTestName() : String {
		return "Dynamic Tree";
	}

}

class Actor {
	public var aabb : AABB = new AABB();
	public var fraction : Float = 0;
	public var overlap : Bool;
	public var proxyId : Int = 0;
	public function new() {}
}
