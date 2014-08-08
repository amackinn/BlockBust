package  {
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class LevelMap {
		private const var EMPTYTILE:int		= -1;
		private const var REDBRICK:int		= 00;
		private const var GREENBRICK:int	= 01;
		private const var BLUEBRICK:int		= 02;
		private const var CYANBRICK:int		= 03;
		private const var YELLOWBRICK:int	= 04;
		private const var MAGENTABRICK:int	= 05;
		private const var GREYBRICK:int		= 06;
		private const var ORANGEBRICK:int	= 07;
		private const var SILVERBRICK:int	= 10;
		private const var GOLDBRICK:int		= 20;
		
		private const var BRICKCOLORS:Array = 
			[0xFF0000, 0x00FF00, 0x0000FF, 0x00FFFF, 
			 0xFFFF00, 0xFF00FF, 0xCCCCCC, 0xFF9900];
		
		
		private const var MAP_ROWS = 11;
		private const var MAP_COLS = 15;
		private const var MAP_BOT_BUFFER = 8;
		
		private var _mapXYOffset:Point;
		private var _mapHeight:Number;
		private var _mapWidth:Number;
		private var _tileHeight:Number;
		private var _tileWidth:Number;
		
		private var _levelMap:Array;
		
		_levelMap[0] = 
		[
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, 00, 01, 02, 04, 05, 03, 06, 00, 01, -1],
		 	[-1, 01, 02, 04, 05, 03, 06, 00, 01, 02, -1],
		 	[-1, 02, 04, 05, 03, 06, 00, 01, 02, 04, -1],
		 	[-1, 04, 05, 03, 06, 00, 01, 02, 04, 05, -1],
		 	[-1, 05, 03, 06, 00, 01, 02, 04, 05, 03, -1],
		 	[-1, 03, 06, 00, 01, 02, 04, 05, 03, 06, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, 10, 10, 10, 10, 10, 10, 10, 10, 10, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, 20, -1, 20, -1, 20, -1, 20, -1, 20, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
		];

		_levelMap[1] = 
		[
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[06, 06, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[04, 04, 04, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[05, 05, 05, 05, -1, -1, -1, -1, -1, -1, -1],
		 	[03, 03, 03, 03, 03, -1, -1, -1, -1, -1, -1],
		 	[00, 00, 00, 00, 00, 00, -1, -1, -1, -1, -1],
		 	[01, 01, 01, 01, 01, 01, 01, -1, -1, -1, -1],
		 	[02, 02, 02, 02, 02, 02, 02, 02, -1, -1, -1],
		 	[06, 06, 06, 06, 06, 06, 06, 06, 06, -1, -1],
		 	[20, 20, 20, 20, 20, 20, 20, 20, 20, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
		];
		
		_levelMap[2] = 
		[
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, 20, -1, 20, -1, 20, -1, 20, -1, 20, -1],
		 	[-1, 00, 10, 04, 10, 01, 10, 05, 10, 02, -1],
		 	[-1, 10, -1, 10, -1, 10, -1, 10, -1, 10, -1],
		 	[-1, 01, 10, 05, 10, 02, 10, 06, 10, 03, -1],
		 	[-1, 20, -1, 20, -1, 20, -1, 20, -1, 20, -1],
		 	[-1, 02, 10, 06, 10, 03, 10, 00, 10, 04, -1],
		 	[-1, 10, -1, 10, -1, 10, -1, 10, -1, 10, -1],
		 	[-1, 03, 10, 00, 10, 04, 10, 01, 10, 05, -1],
		 	[-1, 20, -1, 20, -1, 20, -1, 20, -1, 20, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
		];		
		
		_levelMap[3] = 
		[
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, 20, -1, -1, -1, -1, -1, -1, -1, 20, -1],
		 	[-1, 00, -1, -1, -1, -1, -1, -1, -1, 06, -1],
		 	[-1, 01, -1, 20, -1, -1, -1, 20, -1, 00, -1],
		 	[-1, 10, -1, 20, -1, -1, -1, 20, -1, 10, -1],
		 	[-1, -1, -1, 20, -1, 06, -1, 20, -1, -1, -1],
		 	[-1, -1, -1, 20, 10, 10, 10, 20, -1, -1, -1],
		 	[10, 03, 10, 20, 03, 04, 05, 20, 10, 01, 10],
		 	[02, 10, 04, 20, 02, 10, 01, 20, 02, 10, 03],
		 	[10, 05, 10, 20, 05, 06, 00, 20, 10, 04, 10],
		 	[-1, -1, -1, 20, 20, 20, 20, 20, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
		];		
		
//		_levelMap[4] = 
//		[
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
//		 	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
//		];
		
		private var currLevel: int;
		
		public function LevelMap(x:int = 0, y:int = 0, widthBG:Number, heightBG:Number) {
			_mapXYOffset.x = x;
			_mapXYOffset.y = y;
			_mapWidth = widthBG;
			_mapHeight = heightBG;
			_tileWidth = _mapWidth / MAP_COLS;
			_tileHeight = _mapHeight / (MAP_ROWS + MAP_BOT_BUFFER)
		}
		
		public function buildMap(map:Array):void {
			for (var mapCol:int=0; mapCol < _mapCols; mapCol++) {
				for (var mapRow:int=0; mapRow < _mapRows; mapRow++) {
					//Find current brick in 2D level map
					var currTile:int = map[mapRow][mapCol];
					
					// if tile == 0, means empty, so skip
					if (currTile > EMPTYTILE)
					{
						// Find and place correct object
						var currBrick:Brick;
						
						switch (currTile) {
							case GOLDBRICK:
								currBrick = new GoldBrick();
								break;
							case SILVERBRICK:
								currBrick = new SilverBrick();
								break;
							default:
								currBrick = new Brick(BRICKCOLORS[currTile]);
								break;
						}
						
						currBrick.x = _mapXYOffset.x + mapCol * _tileWidth;
						currBrick.y = _mapXYOffset.y + mapRow * _tileHeight;
						currBrick.width = _tileWidth;
						currBrick.height = _tileHeight;
						addChild(currBrick);
					}
				}
			}
		}

	}
	
}
