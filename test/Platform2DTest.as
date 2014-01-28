package 
{
import data.BodyVo;
import data.FloorVo;
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.ui.Keyboard;

/**
 * ...2d平台测试
 * @author Kanon
 */
public class Platform2DTest extends Sprite 
{
	private var platform2D:Platform2D;
	private var role:Sprite;
	private var roleVo:BodyVo;
	private var speed:Number = 0;
	private var shape:Shape;
	public function Platform2DTest() 
	{
		this.shape = new Shape();
		this.addChild(this.shape);
		
		this.platform2D = new Platform2D(.8);
		
		
		var left:Point = new Point(100, 110);
		var right:Point = new Point(200, 160);
		var fVo:FloorVo = this.platform2D.createFloor(left, right, 30, true);
		fVo.tag = 0;
		this.shape.graphics.lineStyle(1, 0);
		this.shape.graphics.moveTo(fVo.left.x, fVo.left.y);
		this.shape.graphics.lineTo(fVo.right.x, fVo.right.y);
		this.shape.graphics.lineTo(fVo.rightThick.x, fVo.rightThick.y);
		this.shape.graphics.lineTo(fVo.leftThick.x, fVo.leftThick.y);
		this.shape.graphics.lineTo(fVo.left.x, fVo.left.y);
		
		left = new Point(200, 160);
		right = new Point(300, 110);
		fVo = this.platform2D.createFloor(left, right, 30, true);
		fVo.tag = 1;
		this.shape.graphics.lineStyle(1, 0);
		this.shape.graphics.moveTo(fVo.left.x, fVo.left.y);
		this.shape.graphics.lineTo(fVo.right.x, fVo.right.y);
		this.shape.graphics.lineTo(fVo.rightThick.x, fVo.rightThick.y);
		this.shape.graphics.lineTo(fVo.leftThick.x, fVo.leftThick.y);
		this.shape.graphics.lineTo(fVo.left.x, fVo.left.y);
		
		left = new Point(300, 100);
		right = new Point(400, 160);
		fVo = this.platform2D.createFloor(left, right, 30, true);
		fVo.tag = 2;
		this.shape.graphics.lineStyle(1, 0);
		this.shape.graphics.moveTo(fVo.left.x, fVo.left.y);
		this.shape.graphics.lineTo(fVo.right.x, fVo.right.y);
		this.shape.graphics.lineTo(fVo.rightThick.x, fVo.rightThick.y);
		this.shape.graphics.lineTo(fVo.leftThick.x, fVo.leftThick.y);
		this.shape.graphics.lineTo(fVo.left.x, fVo.left.y);
		
		/*var floorList:Array = this.platform2D.createFloorChain(0, 300, 100, [0, 20, 0, 30, -40, 0, 60]);
		var length:int = floorList.length;
		for (var i:int = 0; i < length; i += 1)
		{
			fVo = floorList[i];
			floor = new Floor();
			floor.x = fVo.left.x;
			floor.y = fVo.left.y;
			floor.width = this.platform2D.getFloorDistance(fVo);
			floor.rotation = this.platform2D.getRotation(fVo);
			this.addChild(floor);
		}*/
		
		this.role = new Role();
		this.addChild(this.role);
		this.roleVo = this.platform2D.createBody(150, 100, 36, 50, this.role);
		
		this.initEvent();
	}
	
	/**
	 * 初始化事件
	 */
	private function initEvent():void
	{
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpHandler);
		this.addEventListener(Event.ENTER_FRAME, loop);
	}
	
	private function loop(event:Event):void 
	{
		this.roleVo.vx = this.speed;
		this.platform2D.update();
		this.render();
	}
	
	/**
	 * 渲染
	 */
	private function render():void
	{
		if (!this.platform2D.bodyList) return;
		var length:int = this.platform2D.bodyList.length;
		var bVo:BodyVo;
		for (var i:int = 0; i < length; i += 1)
		{
			bVo = this.platform2D.bodyList[i];
			if (bVo.userData && bVo.userData is DisplayObject)
			{
				DisplayObject(bVo.userData).x = bVo.x;
				DisplayObject(bVo.userData).y = bVo.y;
			}
		}
	}
	
	private function onKeyUpHandler(event:KeyboardEvent):void 
	{
		if (event.keyCode == Keyboard.A || event.keyCode == Keyboard.D) this.speed = 0;
		if (event.keyCode == Keyboard.SPACE) this.platform2D.releaseJump(this.roleVo);
	}
	
	private function onKeyDownHandler(event:KeyboardEvent):void 
	{
		if (event.keyCode == Keyboard.A) this.speed = -5;
		else if (event.keyCode == Keyboard.D) this.speed = 5;
		else if (event.keyCode == Keyboard.R) this.reset();
		else if (event.keyCode == Keyboard.Q) this.platform2D.distroy();
		if (event.keyCode == Keyboard.SPACE) this.platform2D.jump(this.roleVo, -15);
		if (event.keyCode == Keyboard.S) this.platform2D.throughFloor(this.roleVo);
	}
	
	/**
	 * 重置
	 */
	private function reset():void
	{
		this.roleVo.x = 150;
		this.roleVo.y = 100;
	}
}
}