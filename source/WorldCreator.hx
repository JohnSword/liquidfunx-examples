import box2d.common.Vec2;
import box2d.dynamics.World;
interface WorldCreator {
    function createWorld(gravity:Vec2) : World;
}