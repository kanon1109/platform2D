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
import flash.utils.getTimer;
import net.hires.debug.Stats;

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
	private var fVo6:FloorVo;
	public function Platform2DTest() 
	{
		this.shape = new Shape();
		this.addChild(this.shape);
		
		this.platform2D = new Platform2D(.8);
		
		var left:Point = new Point(0, 120);
		var right:Point = new Point(100, 120);
		var fVo:FloorVo = this.platform2D.createFloor(left, right, 180, 0, true);
		fVo.tag = 0;
		
		left = new Point(100, 160);
		right = new Point(200, 260);
		fVo = this.platform2D.createFloor(left, right, 30, .8, true);
		fVo.tag = 1;
		
		left = new Point(200, 260);
		right = new Point(300, 260);
		fVo = this.platform2D.createFloor(left, right, 30, 0, true, true);
		fVo.tag = 2;
		
		left = new Point(300, 200);
		right = new Point(400, 260);
		fVo = this.platform2D.createFloor(left, right, 30, 0, true);
		fVo.tag = 3;
		
		left = new Point(400, 220);
		right = new Point(600, 220);
		fVo = this.platform2D.createFloor(left, right, 30, 0, true);
		fVo.tag = 4;
		
		left = new Point(200, 110);
		right = new Point(400, 110);
		fVo = this.platform2D.createFloor(left, right, 30, 0, true);
		fVo.tag = 5;
		//this.fVo6 = fVo;
		//this.fVo6.vx = 2;
		
		left = new Point(200, 260);
		right = new Point(300, 360);
		fVo = this.platform2D.createFloor(left, right, 30, 0, true);
		fVo.tag = 6;
		
		//this.platform2D.createFloorChain(0, 300, 100, [0, 20, 0, 30, -40, 0, 60]);
		
		//this.role = new Role();
		//this.addChild(this.role);
		this.roleVo = this.platform2D.createBody(150, 100, 36, 50, this.role);
		
		this.addChild(new Stats());
		
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
		/*if (this.fVo6.left.x > 300 || 
			this.fVo6.left.x < 100)
			this.fVo6.vx *= -1;*/
			
		//var t:Number = getTimer();
		this.roleVo.vx = this.speed;
		this.platform2D.update();
		this.platform2D.drawDebug(this.shape);
		//trace(getTimer() - t);
		//this.render();
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
		if (event.keyCode == Keyboard.SPACE) this.platform2D.jump(this.roleVo, -13);
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