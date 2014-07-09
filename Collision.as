package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class Collision
	//0.2 (March 20, 2009)
	{
		public function Collision()
		{
		}
		
		//Block objects
		static public function block(objectA:MovieClip, objectB:MovieClip):void
		{
			var objectA_Halfwidth:Number = objectA.width / 2;
			var objectA_Halfheight:Number = objectA.height / 2;
			var objectB_Halfwidth:Number = objectB.width / 2;
			var objectB_Halfheight:Number = objectB.height / 2;
			var dx:Number = objectB.x - objectA.x;
			var ox:Number = objectB_Halfwidth + objectA_Halfwidth - Math.abs(dx);
			if (ox > 0)
			{
				var dy:Number = objectA.y - objectB.y;
				var oy:Number = objectB_Halfheight + objectA_Halfheight - Math.abs(dy);
				if (oy > 0)
				{
					if (ox < oy)
					{
						if (dx < 0)
						{
							//Collision on right
							oy = 0;
						}
						else
						{
							//Collision on left
							oy = 0;
							ox *= -1;
						}
					}
					else
					{
						if (dy < 0)
						{
							//Collision on Top
							ox = 0;
							oy *= -1;
						}
						else
						{
							//Collision on Bottom
							ox = 0;
						}
					}
					
					//Use the calculated x and y overlaps to 
					//Move objectA out of the collision
					
					objectA.x += ox;
					objectA.y += oy;
				}
			}
		}
		
		//General purpose method for testing Axis-based collisions. Returns true or False
		static public function test(objectA:Object,objectB:Object):Boolean
		{
			var objectA_Halfwidth=objectA.width/2;
			var objectA_Halfheight=objectA.height/2;
			var objectB_Halfwidth=objectB.width/2;
			var objectB_Halfheight=objectB.height/2;
			var dx=objectB.x-objectA.x;
			var ox=objectB_Halfwidth+objectA_Halfwidth-Math.abs(dx);
			if (0<ox)
			{
				var dy=objectA.y-objectB.y;
				var oy=objectB_Halfheight+objectA_Halfheight-Math.abs(dy);
				if (0<oy)
				{

					return true;
				}
			}
			else
			{

				return false;
			}
			return false;
		}
		
		static public function ballAndBrick(ball:MovieClip,objectB:MovieClip):Boolean
		{
			var ball_Halfwidth=ball.width/2;
			var ball_Halfheight=ball.height/2;
			var objectB_Halfwidth=objectB.width/2;
			var objectB_Halfheight=objectB.height/2;
			var dx=objectB.x-ball.x;
			var ox=objectB_Halfwidth+ball_Halfwidth-Math.abs(dx);
			if (ox > 0)
			{
				var dy=ball.y-objectB.y;
				var oy=objectB_Halfheight+ball_Halfheight-Math.abs(dy);
				if (oy > 0)
				{
					//Yes, a collision is occuring! 
					//Now you need to find out on which side 
					//of the platform it's occuring on.
					if (ox < oy)
					{
						if (dx < 0)
						{
							//Collision on right
							oy = 0;
						}
						else
						{
							//Collision on left
							oy = 0;
							ox *= -1;
						}
						ball.vx *= -1;
					}
					else
					{
						if (dy < 0)
						{
							//Collision on Top
							ox = 0;
							oy *= -1;
						}
						else
						{
							//Collision on Bottom
							ox = 0;
						}
						ball.vy *= -1;
					}

					//Move the ball out of the collision
					ball.x += ox;
					ball.y += oy;
					
					return true;
				}
			}
			else
			{

				return false;
			}
			return false;
		}

		static public function ballAndPlayer(ball:MovieClip,player:MovieClip):Boolean
		{
			const MIN_LAUNCH_ANGLE:int = 10;
			var ball_Halfwidth=ball.width/2;
			var ball_Halfheight=ball.height/2;
			var player_Halfwidth=player.width/2;
			var player_Halfheight=player.height/2;
			var dx=player.x-ball.x;
			var ox=player_Halfwidth+ball_Halfwidth-Math.abs(dx);
			if (ox > 0)
			{
				var dy=ball.y-player.y;
				var oy=player_Halfheight+ball_Halfheight-Math.abs(dy);
				if (oy > 0)
				{
					//Yes, a collision is occuring! 
					//Now you need to find out on which side 
					//of the platform it's occuring on.
					if (ox < oy)
					{
						if (dx < 0)
						{
							//Collision on right
							oy = 0;
						}
						else
						{
							//Collision on left
							oy = 0;
							ox *= -1;
						}
						ball.vx *= -1;
					}
					else
					{
						if (dy < 0)
						{
							//Collision on Top
							ox = 0;
							oy *= -1;
							// Find launch angle based on where ball hit paddle
							player.launchAngle = (1 + dx / player_Halfwidth) * (90-MIN_LAUNCH_ANGLE) + MIN_LAUNCH_ANGLE;
							// Constrain launch angle
							
							
							ball.dx = dx;
							//if catching is enabled set the ball's isOnTop 
							//property to true
							if (player.powerUp == "catch")
							{
								ball.objectIsOnTop = true;
								ball.vx = 0;
								ball.vy = 0;
							}
							else
							{
								var angleRadians:Number = player.launchAngle/180*Math.PI;
								ball.vx = ball.vel*Math.cos(angleRadians);
								ball.vy = -ball.vel*Math.sin(angleRadians);
							}
						}
						else
						{
							//Collision on Bottom
							ox = 0;
							ball.vy *= -1;
						}
					}

					//Move the ball out of the collision
					ball.x += ox;
					ball.y += oy;
					
					return true;
				}
			}
			else
			{

				return false;
			}
			return false;
		}

	}
}