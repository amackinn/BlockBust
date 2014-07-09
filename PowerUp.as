package 
{
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Transform;

	public class PowerUp extends MovieClip
	{
		
		//Variables:
		private var _vy:Number;
		private var _powerUpType:String;
		private var _powerUpColor:uint;
		private var _score:uint;
		
		private const SCOREVAL = 50;

		public function PowerUp(startX:Number, startY:Number, powerUpType:String, powerUpCol:uint)
		{
			//Assign start position using values
			//supplied to the parameters
			this.x = startX;
			this.y = startY;
			_vy = 5;

			//Set the bullet type
			this._powerUpType = powerUpType;
			this._powerUpColor = powerUpCol;
			
			_score = SCOREVAL;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			var colorTrans:ColorTransform = new ColorTransform();
			var trans:Transform = new Transform(this.background);
			trans.colorTransform = colorTrans;

			//Add stage event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//Tell the game the a new bullet has been created
			dispatchEvent(new Event("powerUpCreated", true));
			
			//Remove onAddedToStage listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			// Change to correct color
			colorTrans.color = this._powerUpColor;
			trans.colorTransform = colorTrans;
			
			//Start animation
			this.play();
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			trace("PowerUp removed");
		}
		private function onEnterFrame(event:Event):void
		{
			//Move the powerUp
			y += _vy;
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
	}
}