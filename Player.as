package 
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	//import flash.ui.Mouse;
	import flash.events.Event;
	import flash.media.Sound;

	public class Player extends MovieClip
	{
		//Constants
		private const SPEED_LIMIT:int = 20;
//		private const ACCELERATION:Number = 3;
		private const PLAYAREA_LEFT_LIMIT:uint = 14;
		private const PLAYAREA_RIGHT_LIMIT:uint = 450;
		private const EXPAND_RATIO:Number = 1.50;
		private const SHRINK_RATIO:Number = 0.66;
		private const MAX_EXPAND:Number = 2.0;
		private const MIN_SHRINK:Number = 0.5;

		//Variables:
		private var _vx:Number;
		private var _accelerationX:Number;
		private var _collisionArea:MovieClip;
		private var _launchAngle:int;
		private var _powerUp:String;

		private var _shrinkSFX:PlayerShrinkSFX;
		private var _expandSFX:PlayerExpandSFX;
		private var _sfxToPlay:Sound;

		public function Player()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_shrinkSFX = new PlayerShrinkSFX;
			_expandSFX = new PlayerExpandSFX;
			_sfxToPlay = null;
		}
		private function onAddedToStage(event:Event):void
		{
			_vx = 0;
			_accelerationX = 0;
			_collisionArea = this;
			_launchAngle = 45;

			_powerUp = "";

			//Add stage event listeners
//			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
//			stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
//			removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
//			removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			//trace("player removed");
		}
//		private function onKeyDown(event:KeyboardEvent):void
//		{
//			if (event.keyCode == Keyboard.LEFT)
//			{
//				if (_vx > 0)
//				{
//					_accelerationX = 0;
//					_vx = 0;
//				}
//				_accelerationX =  -  ACCELERATION;
//			}
//			if (event.keyCode == Keyboard.RIGHT)
//			{
//				if (_accelerationX < 0)
//				{
//					_accelerationX = 0;
//					_vx = 0;
//				}
//				_accelerationX = ACCELERATION;
//			}
//		}
//		private function onKeyUp(event:KeyboardEvent):void
//		{
//			if (event.keyCode == Keyboard.LEFT)
//			{
//				if (_vx < 0)
//				{
//					_accelerationX = 0;
//					_vx = 0;
//				}
//			}
//			if (event.keyCode == Keyboard.RIGHT)
//			{
//				if (_vx > 0)
//				{
//					_accelerationX = 0;
//					_vx = 0;
//				}
//			}
////			if (event.keyCode == Keyboard.SPACE)
////			{
////				trace("Player Position: X=" + x + " Y=" + y);
////			}
//		}

		//Getters and Setters
		public function set vx(vxValue:Number):void
		{
			if (vxValue > SPEED_LIMIT)
			{
				_vx = SPEED_LIMIT;
			}
			else if (vxValue <  -  SPEED_LIMIT)
			{
				_vx =  -  SPEED_LIMIT;
			}
			else
			{
				_vx = vxValue;
			}
		}
		public function get vx():Number
		{
			return _vx;
		}
		public function set ax(accelVal:Number):void
		{
			_accelerationX = accelVal;
		}
		public function get ax():Number
		{
			return _accelerationX;
		}
		public function set launchAngle(launchAngleValue:Number):void
		{
			_launchAngle = launchAngleValue;
		}
		public function get launchAngle():Number
		{
			return _launchAngle;
		}
		public function get collisionArea():MovieClip
		{
			return _collisionArea;
		}
		public function get powerUp():String
		{
			return _powerUp;
		}
		public function get sfxToPlay():Sound
		{
			return _sfxToPlay;
		}
		public function set powerUp(powerUpType:String):void
		{
			_powerUp = powerUpType;

			switch (_powerUp)
			{
				case PUTypes.CATCH :
					break;
				case PUTypes.LASER :
					break;
				case PUTypes.EXPAND :
					this.scaleX = Math.min(MAX_EXPAND, this.scaleX * EXPAND_RATIO);
					_sfxToPlay = _expandSFX;
					dispatchEvent(new Event("playSFX", true));
					break;
				case PUTypes.SHRINK :
					this.scaleX = Math.max(MIN_SHRINK, this.scaleX * SHRINK_RATIO);
					_sfxToPlay = _shrinkSFX;
					dispatchEvent(new Event("playSFX", true));
					break;
			}

		}
	}
}