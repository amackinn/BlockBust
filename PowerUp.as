package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	import flash.display.DisplayObject;

	public class PowerUp extends MovieClip
	{
		//Variables:
		private var _vy:Number;
		private var _powerUpType:String;
		private var _powerUpColor:uint;
		private var _score:uint;
		
		private const SCOREVAL = 50;

		public function PowerUp(powerUpType:String="X", powerUpCol:uint=0x000000, speed:Number=5)
		{
			_vy = speed;
			_score = SCOREVAL;

			//Set the powerup type
			_powerUpType = powerUpType;
			_powerUpColor = powerUpCol;
			letter.text = powerUpType.charAt(0);
			

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			changeColor(this.background, _powerUpColor);
			
			//Start animation
			this.play();
			
			// Only update powerup if it is moving
			if (_vy > 0)
			{
				//Add stage event listeners
				addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
				//Tell the game the a new powerup has been created
				dispatchEvent(new Event("powerUpCreated", true));
			}
			
			//Remove onAddedToStage listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//trace ("Powerup removed");
		}
		public function get powerUpType():String
		{
			return _powerUpType;
		}
		public function set powerUpType(powerUpTypeString:String):void
		{
			_powerUpType = powerUpTypeString;
		}
		public function get score():uint
		{
			return _score;
		}
		public function set score(scoreValue:uint):void
		{
			_score = scoreValue;
		}
		public function get vy():Number
		{
			return _vy;
		}
		
		public function setPowerUp(powerUpType:String, powerUpCol:uint):void
		{
			_powerUpType = powerUpType;
			_powerUpColor = powerUpCol;
			letter.text = powerUpType.charAt(0);

			changeColor(this.background, _powerUpColor);
			
			//Start animation
			this.play();
		}
		
		private function changeColor(mc:DisplayObject, val:Number)
		{
			var colorTransform:ColorTransform = new ColorTransform();
			colorTransform.color = val;
			mc.transform.colorTransform = colorTransform;
		}
	}
}