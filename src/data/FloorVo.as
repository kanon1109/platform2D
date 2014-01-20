package data
{
import flash.geom.Point;
/**
 * ...地板数据
 * @author Kanon
 */
public class FloorVo 
{
	/**斜率 为0 则表示平面 下坡为正，上坡为负*/
	public var slope:Number;
	/**左边位置坐标*/
	public var left:Point;
	/**右边位置坐标*/
	public var right:Point;
}
}