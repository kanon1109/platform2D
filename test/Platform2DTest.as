package 
{
import data.BodyVo;
import data.FloorVo;
import flash.display.DisplayObject;
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
	public function Platform2DTest() 
	{
		this.platform2D = new Platform2D(.98);
		
		var gap:Number = 50;
		var left:Point = new Point(0, 300);
		var right:Point = new Point(200, 350);
		var fVo:FloorVo = this.platform2D.createFloor(left, right);
		var foor:Sprite = new Floor();
		foor.x = left.x;
		foor.y = left.y;
		foor.width = this.platform2D.getFloorLength(fVo);
		foor.rotation = this.platform2D.getRotation(fVo);
		this.addChild(foor);
		
		left = new Point(200, 300);
		right = new Point(400, 250);
		fVo = this.platform2D.createFloor(left, right);
		foor = new Floor();
		foor.x = left.x;
		foor.y = left.y;
		foor.width = this.platform2D.getFloorLength(fVo);
		foor.rotation = this.platform2D.getRotation(fVo);
		this.addChild(foor);
		
		
		this.role = new Role();
		this.addChild(this.role);
		this.roleVo = this.platform2D.createBody(150, 100, 18, 50, this.role);
		
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
		this.platform2D.update();
		this.render();
	}
	
	/**
	 * 渲染
	 */
	private function render():void
	{
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
		if (event.keyCode == Keyboard.A || 
			event.keyCode == Keyboard.D)
			this.roleVo.vx = 0;
	}
	
	private function onKeyDownHandler(event:KeyboardEvent):void 
	{
		if (event.keyCode == Keyboard.A) this.roleVo.vx = -2;
		else if (event.keyCode == Keyboard.D) this.roleVo.vx = 2;
		else if (event.keyCode == Keyboard.SPACE) this.platform2D.jump(this.roleVo, -15);
		else if (event.keyCode == Keyboard.R) this.reset();
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