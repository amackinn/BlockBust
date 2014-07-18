package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Ball extends MovieClip
	{
		//Constants
		private const ACCELERATION:Number = 1; 
		private const BOUNCE:Number = -1.0; 
		private const PLAYAREA_LEFT_LIMIT:uint = 14;
		private const PLAYAREA_RIGHT_LIMIT:uint = 450;
		private const PLAYAREA_TOP_LIMIT:uint = 16;
		private const PLAYAREA_BOT_LIMIT:uint = 415;
		private const MAX_SPEED:int = 20;
		private const MIN_SPEED:int = 4;
		// Powerups
		private const NORMAL:uint = 1;
		private const MEGABALL:uint = 2;
		
		//Variables:
		private var _vx:Number;
		private var _vy:Number;
		private var _speed:Number;
		private var _accelerationX:Number;
		private var _accelerationY:Number;
		private var _isOnPaddle:Boolean;
		private var _launch:Boolean;
		private var _isLost:Boolean;
		private var _paddleXOffset:Number;
		private var _bounceX:Number;
		private var _bounceY:Number;
		private var _powerup:uint;

		public function Ball(startX:Number, startY:Number, startSpeed:Number)
		{
			this.x = startX;
			this.y = startY;
			_speed = startSpeed;
			_vx = 0;
			_vy = 0;
			_accelerationX = ACCELERATION;
			_accelerationY = ACCELERATION;
			_isOnPaddle = undefined;
			_launch = false;
			_isLost = false;
			_paddleXOffset = 0;
			_bounceX = 0;
			_bounceY = 0;
			_powerup=NORMAL;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			gotoAndStop(_powerup);

			//Add stage event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
//			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			dispatchEvent(new Event("ballCreated", true));
			trace("ball added");
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			trace("ball removed");
		}
		private function onEnterFrame(event:Event):void
		{
			//Initialize local variables
			var ballHalfWidth:uint = this.width / 2;
			var ballHalfHeight:uint = this.height / 2;

			if (Math.abs(_vx) < 0.1)
			{
				_vx = 0;
			}
			if (Math.abs(_vy) < 0.1)
			{
				_vy = 0;
			}
			
			//Move the ball
			x += _vx;
			y += _vy;
			
			//Stage boundaries
			if (x + ballHalfWidth > PLAYAREA_RIGHT_LIMIT)
			{
				_vx *= BOUNCE;
				x=PLAYAREA_RIGHT_LIMIT - ballHalfWidth;
			}
			else if (x - ballHalfWidth < PLAYAREA_LEFT_LIMIT)
			{
				_vx *= BOUNCE;
				x = PLAYAREA_LEFT_LIMIT + ballHalfWidth;
			}
			if (y - ballHalfHeight < PLAYAREA_TOP_LIMIT)
			{
				_vy *= BOUNCE;
				y = PLAYAREA_TOP_LIMIT + ballHalfHeight;
			}
			else if (y + ballHalfHeight > PLAYAREA_BOT_LIMIT)
			{
				_vy *= BOUNCE;
				y = PLAYAREA_BOT_LIMIT - ballHalfHeight;
				
//				_isLost = true;
			}
		}

		//Getters and Setters
		public function get isOnPaddle():Boolean
		{
			return _isOnPaddle;
		}
		public function set isOnPaddle(onPaddle:Boolean):void
		{
			_isOnPaddle = onPaddle;
		}
		public function get launch():Boolean
		{
			return _launch;
		}
		public function set launch(launchNow:Boolean):void
		{
			_launch = launchNow;
		}
		public function get isLost():Boolean
		{
			return _isLost;
		}
		public function set isLost(lost:Boolean):void
		{
			_isLost = lost;
		}
		public function set speed(velValue:Number):void
		{
			var oldSpeed:Number = _speed;
			_speed = Math.min(Math.max(velValue, MIN_SPEED), MAX_SPEED);
			if (oldSpeed > 0 && (Math.abs(_vx) > 0 || Math.abs(_vy) > 0))
			{
				var ratio:Number = _speed / oldSpeed;
				_vx *= ratio;
				_vy *= ratio;
			}
		}
		public function get speed():Number
		{
			return _speed;
		}
		public function set vx(vxValue:Number):void
		{
			_vx = vxValue;
		}
		public function get vx():Number
		{
			return _vx;
		}
		public function set vy(vyValue:Number):void
		{
			_vy = vyValue;
		}
		public function get vy():Number
		{
			return _vy;
		}
		public function get bounceX():Number
		{
			return _bounceX;
		}
		public function set bounceX(bounceXValue:Number):void
		{
			_bounceX = bounceXValue;
		}
		public function get bounceY():Number
		{
			return _bounceY;
		}
		public function set bounceY(bounceYValue:Number):void
		{
			_bounceY = bounceYValue;
		}
		public function get powerup():String
		{
			switch (_powerup) 
			{
				case MEGABALL:
					return PUTypes.MEGABALL;
				case NORMAL:
				default:
					return "";
			}
		}
		public function set powerup(powerupString:String):void
		{
			switch (powerupString) 
			{
				case PUTypes.MEGABALL:
					_powerup = MEGABALL;
					break;
				case "":
				default:
					_powerup = NORMAL;
					break;
			}
			gotoAndStop(_powerup);
		}
		
		public function launchAtAngle(launchAngle:Number):void
		{
			var angleRadians:Number = launchAngle / 180 * Math.PI;
			vx = _speed * Math.cos(angleRadians);
			vy =  - _speed * Math.sin(angleRadians);
		}
	
		public function get angle():Number
		{
			return (Math.atan(vy/vx) * 180 / Math.PI);
		}
	
		public function get paddleXOffset():Number
		{
			return _paddleXOffset;
		}
		public function set paddleXOffset(offset:Number):void
		{
			_paddleXOffset = offset;
		}
	}
}