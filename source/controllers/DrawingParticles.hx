package controllers;

import box2d.particle.ParticleGroupType;
import box2d.particle.ParticleType;
import haxe.ds.Vector;
import box2d.collision.shapes.PolygonShape;
import box2d.common.Transform;
import box2d.common.Vec2;
import box2d.particle.ParticleColor;
import box2d.particle.ParticleGroup;
import box2d.particle.ParticleGroupDef;

class DrawingParticles extends TestbedTest {

  var m_lastGroup : ParticleGroup;
  var m_drawing : Bool;
  var m_particleFlags : Int;
  var m_groupFlags : Int;
  var color : ParticleColor = new ParticleColor();

  override public function initTest() : Void {
    trace("Keys: (L) liquid, (E) elastic, (S) spring");
    trace("(F) rigid, (W) wall, (V) viscous, (T) tensile");
    trace("(Z) erase, (X) move");

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices.set(0, new Vec2(-40, -20));
    vertices.set(1, new Vec2(40, -20));
    vertices.set(2, new Vec2(40, 0));
    vertices.set(3, new Vec2(-40, 0));
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices.set(0, new Vec2(-40, -20));
    vertices.set(1, new Vec2(-20, -20));
    vertices.set(2, new Vec2(-20, 60));
    vertices.set(3, new Vec2(-40, 60));
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();

    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices.set(0, new Vec2(20, -20));
    vertices.set(1, new Vec2(40, -20));
    vertices.set(2, new Vec2(40, 60));
    vertices.set(3, new Vec2(20, 60));
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    var shape : PolygonShape = new PolygonShape();
    var vertices : Vector<Vec2> = new Vector<Vec2>(4);
    vertices.set(0, new Vec2(-40, 40));
    vertices.set(1, new Vec2(40, 40));
    vertices.set(2, new Vec2(40, 60));
    vertices.set(3, new Vec2(-40, 60));
    shape.set(vertices, 4);
    getGroundBody().createFixtureShape(shape, 0.0);

    m_world.setParticleRadius(0.5);
    m_lastGroup = null;
    m_drawing = true;
    m_groupFlags = 0;
  }

  override public function step() : Void {
    super.step();
  }

  override public function keyPressed(keyCode : Int) : Void {
    trace(keyCode);
    // m_drawing = keyCode != 'x';
    m_particleFlags = 0;
    m_groupFlags = 0;
    color.set(127, 127, 127, 50);
    switch (keyCode) {
      case 69: //'e'
        m_particleFlags = ParticleType.b2_elasticParticle;
        m_groupFlags = ParticleGroupType.b2_solidParticleGroup;
      case 80: //'p'
        m_particleFlags = ParticleType.b2_powderParticle;
      case 70: //'f'
        m_groupFlags =
            ParticleGroupType.b2_rigidParticleGroup | ParticleGroupType.b2_solidParticleGroup;
      case 83: //'s'
        m_particleFlags = ParticleType.b2_springParticle;
        m_groupFlags = ParticleGroupType.b2_solidParticleGroup;
      case 84: //'t'
        color.set(0, 127, 0, 50);
        m_particleFlags = ParticleType.b2_tensileParticle;
      case 86: //'v'
        color.set(0, 0, 127, 50);
        m_particleFlags = ParticleType.b2_viscousParticle;
      case 87: //'w'
        m_particleFlags = ParticleType.b2_wallParticle;
        m_groupFlags = ParticleGroupType.b2_solidParticleGroup;
      case 90: //'z'
        m_particleFlags = ParticleType.b2_zombieParticle;
    }
  }

  var pxf : Transform = new Transform();
  // var pshape : CircleShape = new CircleShape();
  var ppd : ParticleGroupDef = new ParticleGroupDef();

override public function mouseDrag(p : Vec2, button : Int) : Void {
    super.mouseDrag(p, button);
    if (m_drawing) {
      pshape.m_p.setVec(p);
      pshape.m_radius = 2.0;
      pxf.setIdentity();
      m_world.destroyParticlesInShape(pshape, pxf);
      ppd.shape = pshape;
      ppd.color = color;
      ppd.flags = m_particleFlags;
      ppd.groupFlags = m_groupFlags;
      var group : ParticleGroup = m_world.createParticleGroup(ppd);
      if (m_lastGroup != null && group.getGroupFlags() == m_lastGroup.getGroupFlags()) {
        m_world.joinParticleGroups(m_lastGroup, group);
      } else {
        m_lastGroup = group;
      }
      mouseTracing = false;
    }
  }

override public function mouseUp(p : Vec2, button : Int) : Void {
    super.mouseUp(p, button);
    m_lastGroup = null;
  }

override public function particleGroupDestroyed(group : ParticleGroup) : Void {
    super.particleGroupDestroyed(group);
    if (group == m_lastGroup) {
      m_lastGroup = null;
    }
  }

override public function getTestName() : String {
    return "Drawing Particles";
  }
}

