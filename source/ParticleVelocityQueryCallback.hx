import box2d.callbacks.ParticleQueryCallback;
import box2d.dynamics.World;
import box2d.collision.shapes.Shape;
import box2d.common.Vec2;
import box2d.common.Transform;

class ParticleVelocityQueryCallback implements ParticleQueryCallback {
  public var world : World;
  public var shape : Shape;
  public var velocity : Vec2;
  public var xf : Transform = new Transform();

  public function new() {
    xf.setIdentity();
  }

  public function init(world : World, shape : Shape, velocity : Vec2) : Void {
    this.world = world;
    this.shape = shape;
    this.velocity = velocity;
  }

  public function reportParticle(index : Int) : Bool {
    var p : Vec2 = world.getParticlePositionBuffer()[index];
    if (shape.testPoint(xf, p)) {
      var v : Vec2 = world.getParticleVelocityBuffer()[index];
      v.setVec(velocity);
    }
    return true;
  }
}