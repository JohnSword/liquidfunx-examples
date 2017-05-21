package m;

@:include("./lib/vec.h")
@:native('m::vec')
extern class Vec {
    var x:Float;
    var y:Float;

    @:native('scale_by')
    function scale(scale:Float):Void;

    inline function square() : Void {
        x *= x;
        y *= y;
    }
}