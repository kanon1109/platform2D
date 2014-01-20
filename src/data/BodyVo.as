package data 
{
/**
 * ...刚体数据
 * @author	Kanon
 */
public class BodyVo
{
	/**x速度*/
	public var vx:Number;
	/**y速度*/
	public var vy:Number;
	/**x坐标*/
	public var x:Number;
	/**y坐标*/
	public var y:Number;
	/**用户数据*/
	public var userData:*;
	/**下落时碰到的地板数据*/
	public var floor:FloorVo;
	/**上一帧x坐标*/
	public var prevX:Number;
	/**下一帧y坐标*/
	public var prevY:Number;
	/**宽度*/
	public var width:Number;
	/**高度*/
	public var height:Number;
}
}