package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class Bullet extends MovieClip {
		
		private const PLAYAREA_TOP_LIMIT:uint = 16;

		private var _isLost:Boolean;
		private var _vy:Number;
		private var _bulletHalfHeight:uint;
		
		public function Bullet(startX:Number, startY:Number) {
			this.x = startX;
			this.y = startY;
			_vy = -8;
			_isLost = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			_bulletHalfHeight = this.height / 2;

			//Add stage event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			//Tell the game the a new powerup has been created
			dispatchEvent(new Event("bulletCreated", true));
			
			//Remove onAddedToStage listener
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//Start animation
			this.play();
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
//			trace ("Bullet removed");
		}
		
		private function onEnterFrame(event:Event):void
		{
			//Move the bullet
			y += _vy;
			
			if (y - _bulletHalfHeight < PLAYAREA_TOP_LIMIT)
			{
				_isLost = true;
			}

		}
		
		public function get isLost():Boolean
		{
			return _isLost;
		}
		public function set isLost(lost:Boolean):void
		{
			_isLost = lost;
		}
	}
	
}
