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
	/**厚度 以2端坐标最靠上的为起始点，
	 * 如果厚度值+最靠上的端点坐标后小于最靠下端点，
	 * 则厚度会自动补充到最靠下坐标为止*/
	public var thick:Number;
	/**是否允许往下穿过*/
	public var allowThrough:Boolean;
	/**标记*/
	public var tag:int;
	/**左边厚度坐标*/
	public var leftThick:Point;
	/**右边厚度坐标*/
	public var rightThick:Point;
}
}