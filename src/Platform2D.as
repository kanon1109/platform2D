package  
{
import data.BodyVo;
import data.FloorVo;
import flash.geom.Point;
import utils.MathUtil;
/**
 * ...2d平台引擎
 * @author Kanon
 */
public class Platform2D 
{
	//重力
	private var g:Number;
	//地板列表
	private var floorList:Array;
	//刚体列表
	private var _bodyList:Array;
	public function Platform2D(gravity:Number) 
	{
		this.g = gravity;
		this.initData();
	}
	
	/**
	 * 初始化数据
	 */
	private function initData():void
	{
		this.floorList = [];
		this._bodyList = [];
	}
	
	/**
	 * 搜索地面
	 * @param	bodyVo	刚体数据
	 */
	private function seachFloor(bodyVo:BodyVo):void
	{
		if (!bodyVo) return;
		if (bodyVo.floor) return;
		var length:int = this.floorList.length;
		var fVo:FloorVo;
		var floorY:Number;
		for (var i:int = 0; i < length; i += 1)
		{
			fVo = this.floorList[i];
			//判断x坐标是否在这个地板之内
			if (!this.isOutSide(bodyVo, fVo))
			{
				if (fVo.slope == 0) floorY = fVo.left.y;
				else floorY = this.getFloorTopY(fVo, bodyVo.x);
				//上一帧的位置在 地板y坐标上面，下一帧在地板y坐标下面 则表示是能够接触到的地板。
				if (bodyVo.prevY < floorY && bodyVo.y >= floorY)
				{
					bodyVo.vy = 0;
					bodyVo.y = floorY;
					bodyVo.floor = fVo;
					break;
				}
			}
		}
	}
	
	/**
	 * 链接地板
	 * @param	bodyVo		刚体
	 * @param	prevFloor	上一次的地板
	 */
	private function linkFloor(bodyVo:BodyVo, prevFloor:FloorVo):void
	{
		var isLeft:Boolean;
		if (bodyVo.x + bodyVo.width * .5 < prevFloor.left.x) isLeft = true;
		else if (bodyVo.x - bodyVo.width * .5 > prevFloor.right.x) isLeft = false;
		
	}
	
	//************************public function************************
	/**
	 * 创建一个地板
	 * @param	left	左边坐标
	 * @param	right	右边坐标
	 * @return	被创建的地板数据
	 */
	public function createFloor(left:Point, right:Point):FloorVo
	{
		var floorVo:FloorVo = new FloorVo();
		floorVo.left = left;
		floorVo.right = right;
		//不是水平的则计算斜率
		if (right.y != left.y) floorVo.slope = MathUtil.getSlope(right.x, right.y, left.x, left.y);
		else floorVo.slope = 0;
		this.floorList.push(floorVo);
		return floorVo;
	}
	
	/**
	 * 创建刚体
	 * @param	x				x坐标
	 * @param	y				y坐标
	 * @param	width			宽度
	 * @param	height			高度
	 * @param	userData		用户数据
	 * @return	刚体数据
	 */
	public function createBody(x:Number, y:Number, width:Number = 0, height:Number = 0, userData:*= null):BodyVo
	{
		if (this._bodyList.indexOf(bodyVo) != -1) return null;
		var bodyVo:BodyVo = new BodyVo();
		bodyVo.vx = 0;
		bodyVo.vy = 0;
		bodyVo.x = x;
		bodyVo.y = y;
		bodyVo.width = width;
		bodyVo.height = height;
		bodyVo.prevX = x;
		bodyVo.prevY = y;
		bodyVo.userData = userData;
		this._bodyList.push(bodyVo);
		return bodyVo;
	}
	
	/**
	 * 根据斜率获取角度
	 * @param	floorVo		地板数据
	 * @return	获取地板角度
	 */
	public function getRotation(floorVo:FloorVo):Number
	{
		if (!floorVo) return NaN;
		var rotation:Number;
		if (floorVo.slope == 0) rotation = 0;
		else rotation = MathUtil.rds2dgs(Math.atan2(floorVo.right.y - floorVo.left.y, 
													floorVo.right.x - floorVo.left.x));
		return rotation;
	}
	
	/**
	 * 获取地板长度
	 * @param	floorVo		地板数据
	 * @return	地板长度
	 */
	public function getFloorLength(floorVo:FloorVo):Number
	{
		if (!floorVo) return NaN;
		return MathUtil.distance(floorVo.left.x, floorVo.left.y, 
								 floorVo.right.x, floorVo.right.y);
	}
	
	/**
	 * 根据x坐标获取在地板上的y坐标
	 * @param	floorVo		地板数据
	 * @param	posX		x坐标位置
	 * @return	在地板上的y坐标
	 */
	public function getFloorTopY(floorVo:FloorVo, posX:Number):Number
	{
		if (!floorVo) return NaN;
		var posY:Number;
		//如果不是斜面
		if (floorVo.slope == 0) posY = floorVo.left.y;
		else
		{
			//如果是斜面
			//求出4个点中最大点和最小点坐标
			var minX:Number = Math.min(floorVo.left.x, floorVo.right.x);
			var minY:Number = Math.min(floorVo.left.y, floorVo.right.y);
			var maxX:Number = Math.max(floorVo.left.x, floorVo.right.x);
			var maxY:Number = Math.max(floorVo.left.y, floorVo.right.y);
			//如果是斜面
			var percent:Number;
			if (floorVo.slope > 0) percent = (maxX - posX) /  (maxX - minX); //如果是下坡
			else percent = (posX - minX) / (maxX - minX); //如果是上坡
			posY = maxY - percent * (maxY - minY);
		}
		return posY;
	}
	
	/**
	 * 判断x坐标是否在地板的x范围之内
	 * @param	bodyVo			刚体数据
	 * @param	floorVo			地板数据
	 * @return	是否在范围之内
	 */
	public function isOutSide(bodyVo:BodyVo, floorVo:FloorVo, offset:Number = .1):Boolean
	{
		if (!floorVo) return false;
		return bodyVo.x + bodyVo.width * .5 < floorVo.left.x - offset || 
				bodyVo.x - bodyVo.width * .5 > floorVo.right.x + offset;
	}
	
	/**
	 * 更新数据
	 */
	public function update():void
	{
		var length:int = this._bodyList.length;
		var bodyVo:BodyVo;
		for (var i:int = 0; i < length; i += 1) 
		{
			bodyVo = this._bodyList[i];
			bodyVo.prevX = bodyVo.x;
			bodyVo.prevY = bodyVo.y;
			bodyVo.x += bodyVo.vx;
			if (!bodyVo.floor)
			{
				//如果没有地板则搜索，设置重力效果
				bodyVo.vy += this.g;
				bodyVo.y += bodyVo.vy;
				this.seachFloor(bodyVo);
			}
			else
			{
				//获取在斜面上移动时的y坐标
				bodyVo.y = this.getFloorTopY(bodyVo.floor, bodyVo.x);
				//判断是否出界
				if (this.isOutSide(bodyVo, bodyVo.floor)) 
				{
					this.linkFloor(bodyVo, bodyVo.floor);
					bodyVo.floor = null;
				}
			}
		}
	}
	
	/**
	 * 移动某个刚体
	 * @param	bodyVo	刚体数据
	 * @param	vx		横向速度
	 * @param	vy		纵向速度
	 */
	public function moveBody(bodyVo:BodyVo, vx:Number = 0, vy:Number = 0):void
	{
		if (!bodyVo) return;
		bodyVo.vy = vx;
		bodyVo.vy = vy;
	}
	
	/**
	 * 跳跃
	 * @param	bodyVo	
	 * @param	vy
	 */
	public function jump(bodyVo:BodyVo, vy:Number = 0):void
	{
		if (!bodyVo || !bodyVo.floor) return;
		this.moveBody(bodyVo, bodyVo.vx, vy);
		bodyVo.floor = null;
	}
	
	/**
	 * 销毁
	 */
	public function distroy():void
	{
		this.floorList = null;
		this._bodyList = null;
	}
	
	/**
	 * 刚体列表
	 */
	public function get bodyList():Array { return _bodyList; };
}
}