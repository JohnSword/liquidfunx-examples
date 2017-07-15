package;

import box2d.callbacks.ContactImpulse;
import box2d.callbacks.ContactListener;
import box2d.callbacks.DebugDraw;
import box2d.callbacks.DestructionListener;
import box2d.callbacks.ParticleDestructionListener;
import box2d.callbacks.QueryCallback;
import box2d.collision.AABB;
import box2d.collision.Collision;
import box2d.collision.Collision.PointState;
import box2d.collision.Manifold;
import box2d.collision.WorldManifold;
import box2d.collision.shapes.CircleShape;
import box2d.collision.shapes.Shape;
import box2d.common.Color3f;
import box2d.common.Transform;
import box2d.common.Vec2;
import box2d.dynamics.Body;
import box2d.dynamics.BodyDef;
import box2d.dynamics.BodyType;
import box2d.dynamics.Fixture;
import box2d.dynamics.FixtureDef;
import box2d.dynamics.World;
import box2d.dynamics.contacts.Contact;
import box2d.dynamics.joints.Joint;
import box2d.dynamics.joints.MouseJoint;
import box2d.dynamics.joints.MouseJointDef;
import box2d.particle.ParticleGroup;

import haxe.ds.Vector;

class TestbedTest implements ContactListener {

  public static var MAX_CONTACT_POINTS : Int = 4048;
  public static var ZOOM_SCALE_DIFF : Float = .05;
  public static var TEXT_LINE_SPACE : Int = 13;
  public static var TEXT_SECTION_SPACE : Int = 3;
  public static var MOUSE_JOINT_BUTTON : Int = 1;
  public static var BOMB_SPAWN_BUTTON : Int = 10;

  public static var GROUND_BODY_TAG : Float = 1897450239847;
  public static var BOMB_TAG : Float = 98989788987;
  public static var MOUSE_JOINT_TAG : Float = 4567893364789;

  public var points : Vector<ContactPoint> = new Vector<ContactPoint>(MAX_CONTACT_POINTS);

  /**
   * Only visible for compatibility. Should use {@link #getWorld()} instead.
   */
  public var m_world : World;
  public var groundBody : Body;
  private var mouseJoint : MouseJoint;

  private var bomb : Body;
  private var bombMousePoint : Vec2 = new Vec2();
  private var bombSpawnPoint : Vec2 = new Vec2();
  private var bombSpawning : Bool = false;

  public var mouseTracing : Bool;
  private var mouseTracerPosition : Vec2 = new Vec2();
  private var mouseTracerVelocity : Vec2 = new Vec2();

  private var mouseWorld : Vec2 = new Vec2();
  private var pointCount : Int;
  private var stepCount : Int;

  private var model : TestbedModel;
  public var destructionListener : DestructionListener;
  public var particleDestructionListener : ParticleDestructionListener;


  private var title : String = null;
  public var m_textLine : Int;
  private var textList : List<String> = new List<String>();

  public var camera : TestbedCamera;

  private var identity : Transform = new Transform();

  public function new() {
    identity.setIdentity();
    for (i in 0 ... MAX_CONTACT_POINTS) {
      points[i] = new ContactPoint();
    }

    // destructionListener = new DestructionListener() {
    //   public void sayGoodbye(Fixture fixture) {
    //     fixtureDestroyed(fixture);
    //   }

    //   public void sayGoodbye(Joint joint) {
    //     if (mouseJoint == joint) {
    //       mouseJoint = null;
    //     } else {
    //       jointDestroyed(joint);
    //     }
    //   }
    // };

    // particleDestructionListener = new ParticleDestructionListener() {
    //   public void sayGoodbye(int index) {
    //     particleDestroyed(index);
    //   }

    //   public void sayGoodbye(ParticleGroup group) {
    //     particleGroupDestroyed(group);
    //   }
    // };
    camera = new TestbedCamera(getDefaultCameraPos(), getDefaultCameraScale(), ZOOM_SCALE_DIFF);
  }

  public function init(model : TestbedModel) : Void {
    this.model = model;

    var gravity : Vec2 = new Vec2(0, -10);
    m_world = model.getWorldCreator().createWorld(gravity);
    m_world.setParticleGravityScale(0.4);
    m_world.setParticleDensity(1.2);
    bomb = null;
    mouseJoint = null;

    mouseTracing = false;
    mouseTracerPosition.setZero();
    mouseTracerVelocity.setZero();

    var bodyDef : BodyDef = new BodyDef();
    groundBody = m_world.createBody(bodyDef);

    init2(m_world, false);
  }

  public function init2(world : World, deserialized : Bool) : Void {
    m_world = world;
    pointCount = 0;
    stepCount = 0;
    bombSpawning = false;
    var draw = model.getDebugDraw();
    if(draw != null) {
      draw.setViewportTransform(camera.getTransform());
    }

    world.setDestructionListener(destructionListener);
    world.setParticleDestructionListener(particleDestructionListener);
    world.setContactListener(this);
    world.setDebugDraw(model.getDebugDraw());
    title = getTestName();

    var flags = 0;
    flags += TestbedSettings.DrawShapes ? DebugDraw.e_shapeBit : 0;
    flags += TestbedSettings.DrawJoints ? DebugDraw.e_jointBit : 0;
    flags += TestbedSettings.DrawAABBs ? DebugDraw.e_aabbBit : 0;
    flags += TestbedSettings.DrawCOMs ? DebugDraw.e_centerOfMassBit : 0;
    flags += TestbedSettings.DrawTree ? DebugDraw.e_dynamicTreeBit : 0;
    flags += TestbedSettings.DrawWireframe ? DebugDraw.e_wireframeDrawingBit : 0;
    var draw = model.getDebugDraw();
    if(draw != null) {
      draw.setFlags(flags);
    }

    m_world.setAllowSleep(TestbedSettings.AllowSleep);
    m_world.setWarmStarting(TestbedSettings.WarmStarting);
    m_world.setSubStepping(TestbedSettings.SubStepping);
    m_world.setContinuousPhysics(TestbedSettings.ContinuousCollision);

    initTest();
  }

  /**
   * Gets the current world
   */
  public function getWorld() : World {
    return m_world;
  }

  /**
   * Gets the testbed model
   */
  public function getModel() : TestbedModel {
    return model;
  }

  /**
   * Gets the contact points for the current test
   */
  public function getContactPoints() : Vector<ContactPoint> {
    return points;
  }

  /**
   * Gets the ground body of the world, used for some joints
   */
  public function getGroundBody() : Body {
    return groundBody;
  }

  /**
   * Gets the debug draw for the testbed
   */
  public function getDebugDraw() : DebugDraw {
    return model.getDebugDraw();
  }

  /**
   * Gets the world position of the mouse
   */
  public function getWorldMouse() : Vec2 {
    return mouseWorld;
  }

  public function getStepCount() : Int {
    return stepCount;
  }

  /**
   * The number of contact points we're storing
   */
  public function getPointCount() : Int {
    return pointCount;
  }

  public function getCamera() : TestbedCamera {
    return camera;
  }

  /**
   * Gets the 'bomb' body if it's present
   */
  public function getBomb() : Body {
    return bomb;
  }

  /**
   * Override for a different default camera position
   */
  public function getDefaultCameraPos() : Vec2 {
    return new Vec2(0, 20);
  }

  /**
   * Override for a different default camera scale
   */
  public function getDefaultCameraScale() : Float {
    return 10;
  }

  public function isMouseTracing() : Bool {
    return mouseTracing;
  }

  public function getMouseTracerPosition() : Vec2 {
    return mouseTracerPosition;
  }

  public function getMouseTracerVelocity() : Vec2 {
    return mouseTracerVelocity;
  }

  /**
   * Gets the filename of the current test. Default implementation uses the test name with no
   * spaces".
   */
  public function getFilename() : String {
    return getTestName().toLowerCase();
  }

  public function setCamera(argPos : Vec2) : Void {
    camera.setCamera(argPos);
  }

  /** @deprecated use {@link #getCamera()} */
  public function setCamera2(argPos : Vec2, scale : Float) : Void {
    camera.setCamera2(argPos, scale);
  }

  public function initTest() : Void {}

  /**
   * The name of the test
   */
  public function getTestName() : String {
      return "";
  }

  /**
   * Adds a text line to the reporting area
   */
  public function addTextLine(line : String) : Void {
    textList.add(line);
  }

  /**
   * called when the tests exits
   */
  public function exit() : Void {}

  private var color1 : Color3f = new Color3f(.3, .95, .3);
  private var color2 : Color3f = new Color3f(.3, .3, .95);
  private var color3 : Color3f = new Color3f(.9, .9, .9);
  private var color4 : Color3f = new Color3f(.6, .61, 1);
  private var color5 : Color3f = new Color3f(.9, .9, .3);
  private var mouseColor : Color3f = new Color3f(0, 1, 0);
  private var p1 : Vec2 = new Vec2();
  private var p2 : Vec2 = new Vec2();
  private var tangent : Vec2 = new Vec2();
  private var statsList : List<String> = new List<String>();

  private var acceleration : Vec2 = new Vec2();
  private var pshape : CircleShape = new CircleShape();
  private var pcallback : ParticleVelocityQueryCallback = new ParticleVelocityQueryCallback();
  private var paabb : AABB = new AABB();

  public function step() : Void {
    var hz = TestbedSettings.Hz;
    var timeStep = hz > 0 ? 1 / hz : 0;


    var debugDraw : DebugDraw = model.getDebugDraw();
    m_textLine = 20;

    if (TestbedSettings.pause) {
      if (TestbedSettings.singleStep) {
        TestbedSettings.singleStep = false;
      } else {
        timeStep = 0;
      }
    }

    pointCount = 0;
    m_world.step(timeStep, TestbedSettings.VelocityIterations, TestbedSettings.PositionIterations);
    if(debugDraw != null) {
      debugDraw.clear();
      m_world.drawDebugData();
    }

    if (timeStep > 0) {
      ++stepCount;
    }

    // debugDraw.drawString(5, m_textLine, "Engine Info", color4);
    // m_textLine += TEXT_LINE_SPACE;
    // debugDraw.drawString(5, m_textLine, "Framerate: " + model.getCalculatedFps(), Color3f.WHITE);
    // m_textLine += TEXT_LINE_SPACE;

    // if (TestbedSettings.DrawStats) {
    //   var particleCount = m_world.getParticleCount();
    //   var groupCount = m_world.getParticleGroupCount();
    //   debugDraw.drawString(
    //       5,
    //       m_textLine,
    //       "bodies/contacts/joints/proxies/particles/groups = " + m_world.getBodyCount() + "/"
    //           + m_world.getContactCount() + "/" + m_world.getJointCount() + "/"
    //           + m_world.getProxyCount() + "/" + particleCount + "/" + groupCount, Color3f.WHITE);
    //   m_textLine += TEXT_LINE_SPACE;

    //   debugDraw.drawString(5, m_textLine, "World mouse position: " + mouseWorld.toString(), Color3f.WHITE);
    //   m_textLine += TEXT_LINE_SPACE;


    //   statsList.clear();
    //   var p : Profile = getWorld().getProfile();
    //   p.toDebugStrings(statsList);

    //   for (s in statsList) {
    //     debugDraw.drawString(5, m_textLine, s, Color3f.WHITE);
    //     m_textLine += TEXT_LINE_SPACE;
    //   }
    //   m_textLine += TEXT_SECTION_SPACE;
    // }

    // if (TestbedSettings.DrawHelp) {
    //   debugDraw.drawString(5, m_textLine, "Help", color4);
    //   m_textLine += TEXT_LINE_SPACE;
    //   var help : List<String> = model.getImplSpecificHelp();
    //   for (item in help) {
    //     debugDraw.drawString(5, m_textLine, item, Color3f.WHITE);
    //     m_textLine += TEXT_LINE_SPACE;
    //   }
    //   m_textLine += TEXT_SECTION_SPACE;
    // }

    // if (!textList.isEmpty()) {
    //   debugDraw.drawString(5, m_textLine, "Test Info", color4);
    //   m_textLine += TEXT_LINE_SPACE;
    //   for (s in textList) {
    //     debugDraw.drawString(5, m_textLine, s, Color3f.WHITE);
    //     m_textLine += TEXT_LINE_SPACE;
    //   }
    //   textList.clear();
    // }

    if (mouseTracing && mouseJoint == null) {
      var delay : Float = 0.1;
      acceleration.x = 2 / delay * (1 / delay * (mouseWorld.x - mouseTracerPosition.x) - mouseTracerVelocity.x);
      acceleration.y = 2 / delay * (1 / delay * (mouseWorld.y - mouseTracerPosition.y) - mouseTracerVelocity.y);
      mouseTracerVelocity.x += timeStep * acceleration.x;
      mouseTracerVelocity.y += timeStep * acceleration.y;
      mouseTracerPosition.x += timeStep * mouseTracerVelocity.x;
      mouseTracerPosition.y += timeStep * mouseTracerVelocity.y;
      pshape.m_p.setVec(mouseTracerPosition);
      pshape.m_radius = 2;
      pcallback.init(m_world, pshape, mouseTracerVelocity);
      pshape.computeAABB(paabb, identity, 0);
      m_world.queryParticleAABB2(pcallback, paabb);
    }

    if (mouseJoint != null) {
      mouseJoint.getAnchorB(p1);
      var p2 : Vec2 = mouseJoint.getTarget();

      debugDraw.drawSegment(p1, p2, mouseColor);
    }

    if (bombSpawning) {
      debugDraw.drawSegment(bombSpawnPoint, bombMousePoint, Color3f.WHITE);
    }

    if (TestbedSettings.DrawContactPoints) {
      var k_impulseScale : Float = 0.1;
      var axisScale : Float = 0.3;

      for (i in 0 ... pointCount) {

        var point : ContactPoint = points[i];

        if (point.state == PointState.ADD_STATE) {
          debugDraw.drawPoint(point.position, 10, color1);
        } else if (point.state == PointState.PERSIST_STATE) {
          debugDraw.drawPoint(point.position, 5, color2);
        }

        if (TestbedSettings.DrawContactNormals) {
          p1.setVec(point.position);
          p2.setVec(point.normal).mulLocal(axisScale).addLocalVec(p1);
          debugDraw.drawSegment(p1, p2, color3);

        } else if (TestbedSettings.DrawContactImpulses) {
          p1.setVec(point.position);
          p2.setVec(point.normal).mulLocal(k_impulseScale).mulLocal(point.normalImpulse).addLocalVec(p1);
          debugDraw.drawSegment(p1, p2, color5);
        }

        if (TestbedSettings.DrawFrictionImpulses) {
          Vec2.crossToOutUnsafe(point.normal, 1, tangent);
          p1.setVec(point.position);
          p2.setVec(tangent).mulLocal(k_impulseScale).mulLocal(point.tangentImpulse).addLocalVec(p1);
          debugDraw.drawSegment(p1, p2, color5);
        }
      }
    }
  }

  /************ INPUT ************/

  /**
   * Called for mouse-up
   */
  public function mouseUp(p : Vec2, button : Int) : Void {
    mouseTracing = false;
    if (button == MOUSE_JOINT_BUTTON) {
      destroyMouseJoint();
    }
    completeBombSpawn(p);
  }

  public function keyPressed(keyCode : Int) : Void {
    trace(keyCode + " pressed");
  }

  public function keyReleased(keyCode : Int) : Void {
    trace(keyCode + " released");
  }

  public function mouseDown(p : Vec2, button : Int) : Void {
    mouseWorld.setVec(p);
    mouseTracing = true;
    mouseTracerVelocity.setZero();
    mouseTracerPosition.setVec(p);

    if (button == BOMB_SPAWN_BUTTON) {
      beginBombSpawn(p);
    }

    if (button == MOUSE_JOINT_BUTTON) {
      spawnMouseJoint(p);
    }
  }

  public function mouseMove(p : Vec2) : Void {
    mouseWorld.setVec(p);
  }

  public function mouseDrag(p : Vec2, button : Int) : Void {
    mouseWorld.setVec(p);
    if (button == MOUSE_JOINT_BUTTON) {
      updateMouseJoint(p);
    }
    if (button == BOMB_SPAWN_BUTTON) {
      bombMousePoint.setVec(p);
    }
  }

  /************ MOUSE JOINT ************/

  private var queryAABB : AABB = new AABB();
  private var callback : TestQueryCallback = new TestQueryCallback();

  private function spawnMouseJoint(p : Vec2) : Void {
    if (mouseJoint != null) {
      return;
    }
    queryAABB.lowerBound.set(p.x - .001, p.y - .001);
    queryAABB.upperBound.set(p.x + .001, p.y + .001);
    callback.point.setVec(p);
    callback.fixture = null;
    m_world.queryAABB(callback, queryAABB);

    if (callback.fixture != null) {
      var body : Body = callback.fixture.getBody();
      var def : MouseJointDef = new MouseJointDef();
      def.bodyA = groundBody;
      def.bodyB = body;
      def.collideConnected = true;
      def.target.setVec(p);
      def.maxForce = 1000 * body.getMass();
      mouseJoint = cast m_world.createJoint(def);
      body.setAwake(true);
    }
  }

  private function updateMouseJoint(target : Vec2) : Void{
    if (mouseJoint != null) {
      mouseJoint.setTarget(target);
    }
  }

  private function destroyMouseJoint() : Void {
    if (mouseJoint != null) {
      m_world.destroyJoint(mouseJoint);
      mouseJoint = null;
    }
  }

  /********** BOMB ************/

  private var p : Vec2 = new Vec2();
  private var v : Vec2 = new Vec2();

  public function lanchBomb() : Void {
    p.set((Math.random() * 30 - 15), 30);
    v.setVec(p).mulLocal(-5);
    launchBomb(p, v);
  }

  private var aabb : AABB = new AABB();

  private function launchBomb(position : Vec2, velocity : Vec2) : Void {
    if (bomb != null) {
      m_world.destroyBody(bomb);
      bomb = null;
    }
    // todo optimize this
    var bd : BodyDef = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.setVec(position);
    bd.bullet = true;
    bomb = m_world.createBody(bd);
    bomb.setLinearVelocity(velocity);

    var circle : CircleShape = new CircleShape();
    circle.m_radius = 0.3;

    var fd : FixtureDef = new FixtureDef();
    fd.shape = circle;
    fd.density = 20;
    fd.restitution = 0;

    var minV : Vec2 = new Vec2().setVec(position);
    var maxV : Vec2 = new Vec2().setVec(position);

    minV.subLocal(new Vec2(.3, .3));
    maxV.addLocalVec(new Vec2(.3, .3));

    aabb.lowerBound.setVec(minV);
    aabb.upperBound.setVec(maxV);

    bomb.createFixture(fd);
  }

  private function beginBombSpawn(worldPt : Vec2) : Void {
    bombSpawnPoint.setVec(worldPt);
    bombMousePoint.setVec(worldPt);
    bombSpawning = true;
  }

  private var vel : Vec2 = new Vec2();

  private function completeBombSpawn(p : Vec2) : Void {
    if (bombSpawning == false) {
      return;
    }
    var multiplier = 30;
    vel.setVec(bombSpawnPoint).subLocal(p);
    vel.mulLocal(multiplier);
    launchBomb(bombSpawnPoint, vel);
    bombSpawning = false;
  }

  /************ SERIALIZATION *************/

  /**
   * Override to enable saving and loading. Remember to also override the {@link ObjectListener} and
   * {@link ObjectSigner} methods if you need to
   * 
   * @return
   */
  public function isSaveLoadEnabled() : Bool {
    return false;
  }

  public function getBodyTag(body : Body) : Int {
    return 0;
  }

  public function getFixtureTag(fixture : Fixture) : Int {
    return 0;
  }

  public function getJointTag(joint : Joint) : Int {
    return 0;
  }

  public function getTag(shape : Shape) : Int {
    return 0;
  }

  public function getWorldTag(world : World) : Int {
    return 0;
  }

  public function processBody(body : Body, tag : Int) : Void {}

  public function processFixture(fixture : Fixture, tag : Int) : Void {}

  public function processJoint(joint : Joint, tag : Int) : Void {}

  public function processShape(shape : Shape, tag : Int) : Void {}

  public function processWorld(world : World, tag : Int) : Void {}

  public function isUnsupported(exception : Dynamic) : Bool {
    return true;
  }

  public function fixtureDestroyed(fixture : Fixture) : Void{}

  public function jointDestroyed(joint : Joint) : Void {}

  public function beginContact(contact : Contact) : Void {}

  public function endContact(contact : Contact) : Void {}

  public function particleDestroyed(particle : Int) : Void {}

  public function particleGroupDestroyed(group : ParticleGroup) : Void {}

  public function postSolve(contact : Contact, impulse : ContactImpulse) : Void {}

  private var state1 : Array<PointState> = new Array<PointState>();
  private var state2 : Array<PointState> = new Array<PointState>();
  private var worldManifold : WorldManifold = new WorldManifold();

  public function preSolve(contact : Contact, oldManifold : Manifold) : Void {
    var manifold : Manifold = contact.getManifold();

    if (manifold.pointCount == 0) {
      return;
    }

    var fixtureA : Fixture = contact.getFixtureA();
    var fixtureB : Fixture = contact.getFixtureB();

    Collision.getPointStates(state1, state2, oldManifold, manifold);

    contact.getWorldManifold(worldManifold);

    var i : Int = 0;
    while (i < manifold.pointCount && pointCount < MAX_CONTACT_POINTS) {
      var cp : ContactPoint = points[pointCount];
      cp.fixtureA = fixtureA;
      cp.fixtureB = fixtureB;
      cp.position.setVec(worldManifold.points[i]);
      cp.normal.setVec(worldManifold.normal);
      cp.state = state2[i];
      cp.normalImpulse = manifold.points[i].normalImpulse;
      cp.tangentImpulse = manifold.points[i].tangentImpulse;
      cp.separation = worldManifold.separations[i];
      ++pointCount;
      i++;
    }
  }
}


class TestQueryCallback implements QueryCallback {

  public var point : Vec2;
  public var fixture : Fixture;

  public function new() {
    point = new Vec2();
    fixture = null;
  }

  public function reportFixture(argFixture : Fixture) : Bool {
    var body : Body = argFixture.getBody();
    if (body.getType() == BodyType.DYNAMIC) {
      var inside : Bool = argFixture.testPoint(point);
      if (inside) {
        fixture = argFixture;
        return false;
      }
    }
    return true;
  }


}
