package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class GoldBrick extends Brick
	{
		private var _hits:int;
		private var _score:int;
		
		public function GoldBrick()
		{
			// Initialize variables
			hits = 999;
			score = 500;
			isBreakable = false;
		}
	}
}