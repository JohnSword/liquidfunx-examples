import box2d.common.IViewportTransform;
import box2d.common.OBBViewportTransform;
import box2d.common.Vec2;
import box2d.common.Mat22;

enum ZoomType {
    ZOOM_IN;
    ZOOM_OUT;
} 

class TestbedCamera {

    private var transform : IViewportTransform;
    private var oldCenter : Vec2 = new Vec2();
    private var newCenter : Vec2 = new Vec2();
    private var worldDiff : Vec2 = new Vec2();
    private var initPosition : Vec2 = new Vec2();
    private var initScale : Float = 0;
    private var upScale : Mat22;
    private var downScale : Mat22;

    public function new(initPosition : Vec2, initScale : Float, zoomScaleDiff : Float) {
        this.transform = new OBBViewportTransform();
        transform.setCamera(initPosition.x, initPosition.y, initScale);
        this.initPosition.setVec(initPosition);
        this.initScale = initScale;
        upScale = Mat22.createScaleTransform(1 + zoomScaleDiff);
        downScale = Mat22.createScaleTransform(1 - zoomScaleDiff);
    }

    public function reset() : Void {
        setCamera2(initPosition, initScale);
    }

    public function setCamera(worldCenter : Vec2) : Void {
        transform.setCenterVec(worldCenter);
    }

    public function setCamera2(worldCenter : Vec2, scale : Float) : Void {
        transform.setCamera(worldCenter.x, worldCenter.y, scale);
    }

    public function zoomToPoint(screenPosition : Vec2, zoomType : ZoomType) : Void {
        var zoom : Mat22;
        switch (zoomType) {
            case ZOOM_IN:
                zoom = upScale;
            case ZOOM_OUT:
                zoom = downScale;
            default:
                return;
        }

        transform.getScreenToWorld(screenPosition, oldCenter);
        transform.mulByTransform(zoom);
        transform.getScreenToWorld(screenPosition, newCenter);

        var transformedMove = oldCenter.subLocal(newCenter);
        if(!transform.isYFlip()) {
            transformedMove.y = -transformedMove.y;
        }
        transform.setCenterVec(transform.getCenter().addLocalVec(transformedMove));
    }

    public function moveWorld(screenDiff : Vec2) {
        transform.getScreenVectorToWorld(screenDiff, worldDiff);
        if(!transform.isYFlip()) {
            worldDiff.y = -worldDiff.y;
        }
        transform.setCenterVec(transform.getCenter().addLocalVec(worldDiff));
    }

    public function getTransform() : IViewportTransform {
        return transform;
    }

    public function getScale() : Float {
        return this.initScale;
    }
 
}