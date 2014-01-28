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
	//物体列表
	private var _bodyList:Array;
	//地板链接之间的最小距离
	private const distance = 3;
	/**
	 * @param	gravity		全局重力
	 */
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
	 * @param	bodyVo	物体数据
	 */
	private function seachFloor(bodyVo:BodyVo):void
	{
		if (!bodyVo) return;
		if (bodyVo.floor) return;
		var length:int = this.floorList.length;
		var fVo:FloorVo;
		var floorY:Number;
		var prevY:Number;
		for (var i:int = 0; i < length; i += 1)
		{
			fVo = this.floorList[i];
			//判断x坐标是否在这个地板之内
			if (!this.isOutSide(bodyVo, fVo))
			{
				//根据body的prevX求出prevY。
				prevY = this.getFloorTopY(fVo, bodyVo.prevX);
				//当前body的x求出当前应该掉落在floor上的floorY。
				floorY = this.getFloorTopY(fVo, bodyVo.x);
				//上一个帧在 地板y坐标上面，下一帧在地板y坐标下面 则表示是能够接触到的地板。
				if (bodyVo.prevY <= prevY && bodyVo.y >= floorY)
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
	 * 链接到另一个地板
	 * @param	bodyVo		物体
	 * @param	prevFloor	上一次的地板
	 */
	private function linkFloor(bodyVo:BodyVo, prevFloor:FloorVo):FloorVo
	{
		//是往左还是往右
		var isLeft:Boolean;
		if (bodyVo.x < prevFloor.left.x) isLeft = true;
		else if (bodyVo.x > prevFloor.right.x) isLeft = false;
		var length:int = this.floorList.length;
		var fVo:FloorVo;
		//上一次地板的坐标
		var prevPoint:Point;
		if (isLeft) prevPoint = prevFloor.left;
		else prevPoint = prevFloor.right;
		//新的地标坐标
		var newPoint:Point;
		//新的地标数据
		var newFloor:FloorVo;
		//上下坡位置有加成权重
		var offsetY:Number = 0;
		//最大高度 用于找到允许连接的地板内最小高度的地板
		var topY:Number = Infinity;
		for (var i:int = 0; i < length; i += 1)
		{
			fVo = this.floorList[i];
			//不是上一次的地步
			if (fVo != prevFloor)
			{
				//在x范围内
				if (!this.isOutSide(bodyVo, fVo))
				{
					//如果是往左出边界则获取新的地板的右坐标。
					if (isLeft) newPoint = fVo.right;
					else newPoint = fVo.left;
					//如果是斜面 上坡比下坡
					if (fVo.slope > 0) offsetY = -.5; //下坡
					else if (fVo.slope < 0) offsetY = .5; //上坡
					//找到2个地板链接处距离小于最短距离并且y坐标高度最小的
					if (Point.distance(prevPoint, newPoint) <= this.distance)
					{
						//找到所有（地板Y坐标+offsetY）的值中最小的跳出循环。
						if (topY > newPoint.y + offsetY)
						{
							topY = newPoint.y + offsetY;
							newFloor = fVo;
						}
						else break;
					}
				}
			}
		}
		return newFloor;
	}
	
	/**
	 * 判断地板锁定物体
	 * @param	bodyVo 物体数据
	 */
	private function checkBlock(bodyVo:BodyVo):void
	{
		if (!bodyVo.floor)
		{
			var fVo:FloorVo;
			var length:int = this.floorList.length;
			for (var i:int = 0; i < length; i += 1)
			{
				fVo = this.floorList[i];
				if (!this.isOutSide(bodyVo, fVo))
					this.blockFloor(bodyVo, fVo);
			}
		}
		else this.blockFloor(bodyVo, bodyVo.floor);
	}

	/**
	 * 地板锁定物体
	 * @param	bodyVo			物体数据
	 * @param	floorVo			地板数据
	 */
	private function blockFloor(bodyVo:BodyVo, floorVo:FloorVo):void
	{
		if (!bodyVo || !floorVo) return; 
		var lHeightY:Number = floorVo.left.y - floorVo.lBlockHeight;
		var rHeightY:Number = floorVo.right.y - floorVo.rBlockHeight;
		if (floorVo.lBlockHeight > 0 && bodyVo.y > lHeightY && 
			bodyVo.x - bodyVo.width * .5 < floorVo.left.x)
			bodyVo.x = floorVo.left.x + bodyVo.width * .5;
		else if (floorVo.rBlockHeight > 0 && bodyVo.y > rHeightY && 
				bodyVo.x + bodyVo.width * .5 > floorVo.right.x)
				bodyVo.x = floorVo.right.x - bodyVo.width * .5;
	}
	
	
	//************************public function************************
	/**
	 * 创建一个地板
	 * @param	left			左边坐标
	 * @param	right			右边坐标
	 * @param	lBlockHeight	左边阻碍高度
	 * @param	rBlockHeight	右边阻碍高度
	 * @param	allowThrough	是否允许向下穿透
	 * @return	被创建的地板数据
	 */
	public function createFloor(left:Point, right:Point, 
								lBlockHeight:Number = 0, 
								rBlockHeight:Number = 0, 
								allowThrough:Boolean=false):FloorVo
	{
		if (!this.floorList) return null;
		var floorVo:FloorVo = new FloorVo();
		floorVo.left = left;
		floorVo.right = right;
		if (lBlockHeight < 0) lBlockHeight = 0;
		if (rBlockHeight < 0) rBlockHeight = 0;
		floorVo.lBlockHeight = lBlockHeight;
		floorVo.rBlockHeight = rBlockHeight;
		floorVo.allowThrough = allowThrough;
		//不是水平的则计算斜率
		if (right.y != left.y) floorVo.slope = MathUtil.getSlope(right.x, right.y, left.x, left.y);
		else floorVo.slope = 0;
		this.floorList.push(floorVo);
		return floorVo;
	}
	
	/**
	 * 创建物体
	 * @param	x				x坐标
	 * @param	y				y坐标
	 * @param	width			宽度
	 * @param	height			高度
	 * @param	userData		用户数据
	 * @return	物体数据
	 */
	public function createBody(x:Number, y:Number, width:Number = 0, height:Number = 0, userData:*= null):BodyVo
	{
		if (!this._bodyList || this._bodyList.indexOf(bodyVo) != -1) return null;
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
	public function getFloorDistance(floorVo:FloorVo):Number
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
			if (posY < minY) posY = minY;
			else if (posY > maxY) posY = maxY;
		}
		return posY;
	}
	
	/**
	 * 判断x坐标是否在地板的x范围之内
	 * @param	bodyVo				物体数据
	 * @param	floorVo				地板数据
	 * @param	offset				误差
	 * @param	checkFloorHeight	是否对floor进行高度判断
	 * @return	是否在范围之内
	 */
	public function isOutSide(bodyVo:BodyVo, floorVo:FloorVo, 
								offset:Number = 1, checkFloorHeight:Boolean=false):Boolean
	{
		if (!floorVo) return false;
		if (!checkFloorHeight)
		{
			return bodyVo.x < floorVo.left.x - offset || bodyVo.x > floorVo.right.x + offset;
		}
		else
		{
			if (bodyVo.x < floorVo.left.x - offset && bodyVo.y < floorVo.lBlockHeight) 
			{
				//出左边界
				if (floorVo.lBlockHeight == 0) return true;
			}
			else if (bodyVo.x > floorVo.right.x + offset && bodyVo.y < floorVo.rBlockHeight) 
			{
				//出右边界
				if (floorVo.rBlockHeight == 0) return true;
			}
		}
		return false;
	}
	
	/**
	 * 更新数据
	 */
	public function update():void
	{
		if (!this._bodyList) return;
		var length:int = this._bodyList.length;
		var bodyVo:BodyVo;
		for (var i:int = 0; i < length; i += 1) 
		{
			bodyVo = this._bodyList[i];
			bodyVo.prevX = bodyVo.x;
			bodyVo.prevY = bodyVo.y;
			bodyVo.x += bodyVo.vx;
			this.checkBlock(bodyVo);
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
					bodyVo.floor = this.linkFloor(bodyVo, bodyVo.floor);
			}
		}
	}
	
	/**
	 * 移动某个物体
	 * @param	bodyVo	物体数据
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
	 * @param	bodyVo	物体数据
	 * @param	vy		跳跃速度
	 */
	public function jump(bodyVo:BodyVo, vy:Number = 0):void
	{
		if (!bodyVo || !bodyVo.floor) return;
		this.moveBody(bodyVo, bodyVo.vx, vy);
		bodyVo.floor = null;
	}
	
	/**
	 * 释放跳跃
	 * @param	bodyVo	物体数据
	 * @param	p		物体跳跃速度减量百分比（0-1），越大跳跃速度下降的就越慢。
	 */
	public function releaseJump(bodyVo:BodyVo, p:Number = .3):void
	{
		if (bodyVo) 
		{
			if (p < 0) p = 0;
			else if (p > 1) p = 1;
			if (bodyVo.vy < 0) bodyVo.vy *= p;
		}
	}
	
	/**
	 * 创建一连串地板
	 * @param	x				起始x坐标
	 * @param	y				起始y坐标
	 * @param	distance		地板的长度
	 * @param	angleList		地板的坡度列表（存放的是角度值）
	 * @return	地板列表
	 */
	public function createFloorChain(x:Number, y:Number, distance:Number, angleList:Array):Array
	{
		var floorList:Array = [];
		var fVo:FloorVo;
		var left:Point;
		var right:Point;
		var length:int = angleList.length;
		var degrees:Number;//弧度
		var posX:Number;
		var posY:Number;
		for (var i:int = 0; i < length; i += 1) 
		{
			if (i > 0) left = right.clone();
			else left = new Point(x, y);
			degrees = MathUtil.dgs2rds(angleList[i]);
			posX = left.x + Math.cos(degrees) * distance;
			posY = left.y + Math.sin(degrees) * distance;
			right = new Point(posX, posY);
			fVo = this.createFloor(left, right);
			floorList.push(fVo);
		}
		return floorList;
	}
	
	/**
	 * 创建阶梯式的地板
	 * @param	x				起始x坐标
	 * @param	y				起始y坐标
	 * @param	distance		地板的长度	
	 * @param	angleList		地板的坡度列表（存放的是角度值）
	 * @param	heightList		地板阻碍高度[-10, 10, 0] 负数为向上的高度，正数为向下，0为无高度。
	 * @return	地板列表
	 */
	public function createLadderFloor(x:Number, y:Number, distance:Number, 
									angleList:Array, heightList:Array):Array
	{
		var floorList:Array = [];
		var fVo:FloorVo;
		var length:int = angleList.length;
		var left:Point; 
		var right:Point;
		var lBlockHeight:Number = 0;
		var rBlockHeight:Number = 0;
		var degrees:Number;//弧度
		var height:Number = 0;
		var prevHeight:Number = 0;
		var posX:Number;
		var posY:Number;
		for (var i:int = 0; i < length; i += 1)
		{
			degrees = MathUtil.dgs2rds(angleList[i]);
			//大于0 为向下，小于0为向上
			height = heightList[i];
			lBlockHeight = 0;
			rBlockHeight = 0;
			if (i == 0) 
			{
				left = new Point(x, y);
			}
			else
			{
				if (prevHeight > 0)
				{
					//如果上一个线段的右侧锁定高度向下
					left = right.clone();
					left.y += prevHeight;
					lBlockHeight = prevHeight;
				}
				else if (prevHeight < 0)
				{
					//如果上一个线段的右侧锁定高度向上
					left = right.clone();
					left.y += prevHeight;
				}
				else
				{
					left = right.clone(); //没有高度
				}
			}
			posX = left.x + Math.cos(degrees) * distance;
			posY = left.y + Math.sin(degrees) * distance;
			right = new Point(posX, posY);
			
			if (height >= 0) rBlockHeight = 0; //线段右边高度如果大于0则 不设置右边锁定高度
			else if (height < 0) rBlockHeight = Math.abs(height); //线段的右边如果 高度小于0 则设置右边锁定高度
			
			prevHeight = height;
			fVo = this.createFloor(left, right, lBlockHeight, rBlockHeight);
			floorList.push(fVo);
		}
		return floorList;
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
	 * 穿透地板
	 * @param	bodyVo	需要穿透脚下地板的物体
	 */
	public function throughFloor(bodyVo:BodyVo):void 
	{
		if (bodyVo && 
			bodyVo.floor && 
			bodyVo.floor.allowThrough)
		{
			bodyVo.y += 1;
			bodyVo.floor = null;
		}
	}
	
	/**
	 * 物体列表
	 */
	public function get bodyList():Array { return _bodyList; };
}
}