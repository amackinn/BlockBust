package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Brick extends MovieClip
	{
		private var _hits:int;
		private var _score:int;
		private var _isBreakable:Boolean;
		
		public function Brick()
		{
			// Initialize variables
			_hits = 1;
			_score = 10;
			_isBreakable = true;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		private function onAddedToStage(event:Event):void
		{
			//Add event listeners
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		private function onRemovedFromStage(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		//Each frame the brick objects send references of themselves to the
		//Main_BBB (the "parent") to be checked for a collision
		//with the ball(s)
		private function onEnterFrame(event:Event):void
		{
			MovieClip(parent).checkCollisionWithBrick(this);
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
		public function set isBreakable(canBreak:Boolean):void
		{
			_isBreakable = canBreak;
		}
		public function get isBreakable():Boolean
		{
			return _isBreakable;
		}
	}
}