package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class GoldBrick extends MovieClip
	{
		private var _hits:int;
		private var _score:int;
		
		public function GoldBrick()
		{
			// Initialize variables
			_hits = 999;
			_score = 500;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			//Add event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			
			gotoAndStop(1);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		//Each frame of the wall objects send references of themselves to the
		//DungeonOne_Manager (the "parent") to be checked for a collision
		//with the player
		private function onEnterFrame(event:Event):void
		{
			MovieClip(parent).checkCollisionWithBall(this);
		}
		//Getters and Setters
		public function set hits(hitsValue:Number):void
		{
			_hits = hitsValue;
		}
		public function get hits():Number
		{
			return _hits;
		}
		public function set score(scoreValue:Number):void
		{
			_score = scoreValue;
		}
		public function get score():Number
		{
			return _score;
		}
	}
}