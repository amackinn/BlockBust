package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class Bullet extends MovieClip {
		
		private const PLAYAREA_TOP_LIMIT:uint = 16;

		private var _isLost:Boolean;
		private var _vy:Number;
		
		public function Bullet(startX:Number, startY:Number) {
			this.x = startX;
			this.y = startY;
			_vy = -8;
			_isLost = false;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			//Add stage event listeners
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
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
//			trace ("Bullet removed");
		}
		
		public function get vy():Number
		{
			return _vy;
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
