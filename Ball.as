package 
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
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
		// Powerups
		private const NORMAL:uint = 1;
		private const MEGABALL:uint = 2;
		
		//Variables:
		private var _dx:Number;
		private var _vx:Number;
		private var _vy:Number;
		private var _vel:Number;
		private var _accelerationX:Number;
		private var _accelerationY:Number;
		private var _isOnPaddle:Boolean;
		private var _launch:Boolean;
		private var _isLost:Boolean;
		private var _paddleXOffset:Number;
		private var _bounceX:Number;
		private var _bounceY:Number;
		private var _collisionArea:MovieClip;
		private var _powerup:uint;

		public function Ball(startX:Number, startY:Number, startVel:Number)
		{
			this.x = startX;
			this.y = startY;
			_vel = startVel;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_dx = 0;
			_vx = 0;
			_vy = 0;
			_accelerationX = ACCELERATION;
			_accelerationY = ACCELERATION;
			_isOnPaddle = undefined;
			_launch = false;
			_isLost = false;
			_paddleXOffset = 5;
			_bounceX = 0;
			_bounceY = 0;
			_collisionArea = this;
			_powerup=NORMAL;
			gotoAndStop(_powerup);

			//Add stage event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			dispatchEvent(new Event("ballCreated", true));
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			trace("ball removed");
		}
		private function onEnterFrame(event:Event):void
		{
			//Initialize local variables
			var ballHalfWidth:uint = _collisionArea.width / 2;
			var ballHalfHeight:uint = _collisionArea.height / 2;

//			//Apply Acceleration
//			_vx *= _accelerationX;
//			_vy *= _accelerationY;
			
			if (Math.abs(_vx) < 0.1)
			{
				_vx = 0;
			}
			if (Math.abs(_vy) < 0.1)
			{
				_vy = 0;
			}
			
//			//Apply Bounce from collision with platforms
//			x += _bounceX;
//			y += _bounceY;
			
			//Move the ball
			x += _vx;
			y += _vy;
			
//			//Reset platform bounce values so that they 
//			//don't compound with the next collision
//			_bounceX = 0;
//			_bounceY = 0;

			
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
//				_vy *= BOUNCE;
//				y = PLAYAREA_BOT_LIMIT - ballHalfHeight;
				
				_isLost = true;
			}
		}
		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				if ((_isOnPaddle) && !(_launch))
				{
					_launch = true;
					//_isOnPaddle = false
				}
				trace("Launching ball with vx= " + _vx + " vy= " + _vy);
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
		public function set dx(dxValue:Number):void
		{
			_dx = dxValue;
		}
		public function get dx():Number
		{
			return _dx;
		}
		public function set vel(velValue:Number):void
		{
			_vel = velValue;
		}
		public function get vel():Number
		{
			return _vel;
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
		public function get collisionArea():MovieClip
		{
			return _collisionArea;
		}
		public function get powerup():String
		{
			switch (_powerup) 
			{
				case MEGABALL:
					return "Megaball";
				case NORMAL:
				default:
					return "Normal";
			}
		}
		public function set powerup(powerupString:String):void
		{
			switch (_powerup) 
			{
				case "Megaball":
					_powerup = MEGABALL;
				case "Normal":
				default:
					_powerup = NORMAL;
			}
			gotoAndStop(_powerup);
		}
	}
}