import box2d.common.Vec2;
import box2d.dynamics.World;

class DefaultWorldCreator implements WorldCreator {
    public function new() {}

    public function createWorld(gravity:Vec2) : World {
        return new World(gravity);
    }
}