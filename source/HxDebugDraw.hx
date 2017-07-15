import box2d.collision.AABB;
import box2d.common.IViewportTransform;
import box2d.particle.ParticleColor;
import box2d.common.Transform;
import box2d.common.Color3f;
import box2d.common.Vec2;
import box2d.callbacks.DebugDraw;
import box2d.collision.shapes.Shape;
import openfl.display.Sprite;

import haxe.ds.Vector;

class HxDebugDraw extends DebugDraw {

	public var m_drawScale:Float;
	private var m_sprite:Sprite;
	private var m_lineThickness:Float;
	private var m_alpha:Float;
	private var m_fillAlpha:Float;
	private var m_xformScale:Float;
	private var pcolor : Color3f = new Color3f(1,1,1);
	private var yFlip : Bool = false;
	private var circle : Shape;
	private var sp1 : Vec2 = new Vec2();
  	private var sp2 : Vec2 = new Vec2();
	private var tr : Transform = new Transform();

	public static var edgeWidth : Float = 0.02;

    public function new(container:Sprite, yFlip : Bool) {
        super();
		this.yFlip = yFlip;
        m_drawScale = 10.0;
		m_lineThickness = 1.0;
		m_alpha = 1.0;
		m_fillAlpha = 1.0;
		m_xformScale = 1.0;
		m_drawFlags = 0;
        m_sprite = container;
    }

	override public function setViewportTransform(viewportTransform:IViewportTransform) : Void {
		super.setViewportTransform(viewportTransform);
		viewportTransform.setYFlip(yFlip);
	}

	override public function drawPoint(argPoint : Vec2, argRadiusOnScreen : Float, argColor : Color3f) : Void {
		getWorldToScreenToOut(argPoint, sp1);
		// sp1.x -= argRadiusOnScreen;
		// sp1.y -= argRadiusOnScreen;
		m_sprite.graphics.beginFill(argColor.color, m_fillAlpha);
		// m_sprite.graphics.drawCircle(sp1.x, sp1.y, argRadiusOnScreen * 2);
		// m_sprite.graphics.lineStyle(1, argColor.color, 1);
		m_sprite.graphics.drawCircle(sp1.x, sp1.y, argRadiusOnScreen);
		m_sprite.graphics.endFill();
	}

	private function transformGraphics(center : Vec2) : Void {
		// var e : Vec2 = viewportTransform.getExtents();
		// var vc : Vec2 = viewportTransform.getCenter();
		// var vt : Mat22 = viewportTransform.getMat22Representation();
		// var flip : Int = yFlip ? -1 : 1;
		// m_sprite.scaleY *= -0.2;
		// m_sprite.y = -300;
		// tr.setTransform(vt.ex.x, flip * vt.ex.y, vt.ey.x, flip * vt.ey.y, e.x, e.y);
		// tr.translate(-vc.x, -vc.y);
		// tr.translate(center.x, center.y);
		// g.transform(tr);
	}

	/**
	 * Draw a circle.
	 * 
	 * @param center
	 * @param radius
	 * @param color
	 */
	override public function drawCircle(center : Vec2, radius : Float, color : Color3f) : Void {
		getWorldToScreenToOut(center, sp1);
		m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
		m_sprite.graphics.drawCircle(sp1.x, sp1.y, radius * m_drawScale);
	}

	/**
	* Draw a circle.
	*/
	override public function drawCircle2(center:Vec2, radius:Float, axis : Vec2, color:Color3f) : Void {
		getWorldToScreenToOut(center, sp1);
		m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
		if (axis != null) {
			axis.y *= -1; // invert vertical axis to get correct rotation
			var avx = sp1.x + (axis.x * radius * m_drawScale);
			var avy = sp1.y + (axis.y * radius * m_drawScale);
			m_sprite.graphics.moveTo(sp1.x, sp1.y);
			m_sprite.graphics.lineTo(avx, avy);
		}
		m_sprite.graphics.drawCircle(sp1.x, sp1.y, radius * m_drawScale);
	}
	
	/**
	* Draw a solid circle.
	*/
	override public function drawSolidCircle(center:Vec2, radius:Float, axis:Vec2, color:Color3f) : Void {
		
		m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
		m_sprite.graphics.moveTo(0,0);
		m_sprite.graphics.beginFill(color.color, m_fillAlpha);
		m_sprite.graphics.drawCircle(center.x * m_drawScale, center.y * m_drawScale, radius * m_drawScale);
		m_sprite.graphics.endFill();
		m_sprite.graphics.moveTo(center.x * m_drawScale, center.y * m_drawScale);
		m_sprite.graphics.lineTo((center.x + axis.x*radius) * m_drawScale, (center.y + axis.y*radius) * m_drawScale);
		
	}

    /**
	* Draw a closed polygon provided in CCW order.
	*/
	// override public function drawPolygon(vertices:Array<Vec2>, vertexCount:Int, color:Color) : Void{
		
	// 	m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
	// 	m_sprite.graphics.moveTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
	// 	for (i in 1...vertexCount){
	// 			m_sprite.graphics.lineTo(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale);
	// 	}
	// 	m_sprite.graphics.lineTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
		
	// }

	/**
	* Draw a solid closed polygon provided in CCW order.
	*/
	override public function drawSolidPolygon(vertices:Vector<Vec2>, vertexCount:Int, color:Color3f) : Void{
		m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
		m_sprite.graphics.moveTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
		m_sprite.graphics.beginFill(color.color, m_fillAlpha);
		for (i in 1...vertexCount){
				m_sprite.graphics.lineTo(vertices[i].x * m_drawScale, vertices[i].y * m_drawScale);
		}
		m_sprite.graphics.lineTo(vertices[0].x * m_drawScale, vertices[0].y * m_drawScale);
		m_sprite.graphics.endFill();
	}

	/**
	* Draw a line segment.
	*/
	override public function drawSegment(p1:Vec2, p2:Vec2, color:Color3f) : Void {
		getWorldToScreenToOut(p1, sp1);
    	getWorldToScreenToOut(p2, sp2);
		
		m_sprite.graphics.lineStyle(m_lineThickness, color.color, m_alpha);
		m_sprite.graphics.moveTo(sp1.x, sp1.y);
		m_sprite.graphics.lineTo(sp2.x, sp2.y);
		// m_sprite.graphics.moveTo(p1.x * m_drawScale, p1.y * m_drawScale);
		// m_sprite.graphics.lineTo(p2.x * m_drawScale, p2.y * m_drawScale);
		
	}

	public function drawAABB(argAABB : AABB, color : Color3f) : Void {
		var vecs : Vector<Vec2> = new Vector<Vec2>(4);
		argAABB.getVertices(vecs);
		drawPolygon(vecs, 4, color);
	}

	/**
	* Draw a transform. Choose your own length scale.
	* @param xf a transform.
	*/
	override public function drawTransform(xf:Transform) : Void{
		m_sprite.graphics.lineStyle(m_lineThickness, 0xff0000, m_alpha);
		m_sprite.graphics.moveTo(xf.p.x * m_drawScale, xf.p.y * m_drawScale);
        var tmpx : Float = xf.p.x + m_xformScale * xf.q.c;
        var tmpy : Float = xf.p.y + m_xformScale * xf.q.s;
		m_sprite.graphics.lineTo(tmpx * m_drawScale, tmpy * m_drawScale);
		
		m_sprite.graphics.lineStyle(m_lineThickness, 0x00ff00, m_alpha);
		m_sprite.graphics.moveTo(xf.p.x * m_drawScale, xf.p.y * m_drawScale);
        tmpx = xf.p.x + -m_xformScale * xf.q.s;
        tmpy = xf.p.y + m_xformScale * xf.q.c;
		m_sprite.graphics.lineTo(tmpx * m_drawScale, tmpy * m_drawScale);
		
	}

	override public function drawParticlesWireframe(centers : Vector<Vec2>, radius : Float, colors : Vector<ParticleColor>, count : Int) : Void {
		var color : Color3f = new Color3f();
		for(i in 0 ... count) {
			var center : Vec2 = centers[i];
			if(colors == null) {
				color = pcolor;
			} else {
				color.set(colors[i].r,colors[i].g,colors[i].b);
			}
			getWorldToScreenToOut(center, sp1);
			m_sprite.graphics.lineStyle(1, color.color, 1);
			m_sprite.graphics.drawCircle(sp1.x, sp1.y, radius * m_drawScale);
		}
  	}

    override public function flush() : Void {
    }

    override public function clear() : Void {
		m_sprite.graphics.clear();
    }

}
