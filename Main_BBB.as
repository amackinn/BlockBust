package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	import flash.utils.getQualifiedClassName;
	import fl.controls.TextArea;
	import flash.events.MouseEvent;
	import flash.system.fscommand;

	public class Main_BBB extends MovieClip
	{
//		private const PLAYAREA_LEFT_LIMIT:uint = 14;
//		private const PLAYAREA_RIGHT_LIMIT:uint = 450;
//		private const PLAYAREA_TOP_LIMIT:uint = 16;
//		private const PLAYAREA_BOT_LIMIT:uint = 415;
		private const MAX_LIVES:int = 9;
		private const TIMER_LENGTH:int = 6;
		private const START_VELOCITY:int = 8;
		private const VELOCITY_INCR:int = 0.25;
		private const POWERUP_CHANCE:Number = 0.15;
		private const LAUNCH_DELAY:uint = 1000;
		private const START_DELAY:uint = 200;
		private const INITIAL_VOLUME:uint = 5;
		private const PLAYER_STARTX:Number = 134;
		private const PLAYER_STARTY:Number = 388;
		private const INITIAL_LAUNCHANGLE:Number = 45;
		private const MIN_LAUNCH_ANGLE:int = 15;
		
		private const MAX_LEVEL:uint = 5;

		private const POWERUP_LIST:Array = [PUTypes.CATCH, PUTypes.SLOW, PUTypes.TRIPLE,
											PUTypes.EXPAND, PUTypes.SHRINK, PUTypes.MEGABALL,
											PUTypes.LASER, PUTypes.EXTRALIFE, PUTypes.WARP];
		private const POWERUP_COLOR:Array = [PUTypes.COLOR_CATCH, PUTypes.COLOR_SLOW, PUTypes.COLOR_TRIPLE,
											PUTypes.COLOR_EXPAND, PUTypes.COLOR_SHRINK, PUTypes.COLOR_MEGABALL,
											PUTypes.COLOR_LASER, PUTypes.COLOR_EXTRALIFE, PUTypes.COLOR_WARP];
		private const POWERUP_PDIST:Array = [PUTypes.PROB_CATCH, PUTypes.PROB_SLOW, PUTypes.PROB_TRIPLE,
											PUTypes.PROB_EXPAND, PUTypes.PROB_SHRINK, PUTypes.PROB_MEGABALL,
											PUTypes.PROB_LASER, PUTypes.PROB_EXTRALIFE, PUTypes.PROB_WARP];

		private var _player:Player;
		private var _balls:Array;
		private var _powerUps:Array;
		private var _bullets:Array;
		private var _lives:int;
		private var _launchTimer:Timer;
		private var _startTimer:Timer;

		private var _powerUpsTotProb: uint;

		private var _score:uint;
		private var _currLevel: uint;
		private var _bricksRemaining:uint;
		private var _msgScreen:MessageScreen;
		private var _isPaused:Boolean;
		private var _levelDisplayed:MovieClip;

		// Sound Resources
		private var _theme:StartTheme;
		private var _bounceHi:BounceHi;
		private var _bounceMid:BounceMid;
		private var _bounceLo:BounceLo;
		private var _lifeLost:LifeLost;
		private var _gameOver:GameOver;
		private var _teleportSFX:TeleportSFX;
		private var _laserSFX:LaserSFX;
		private var _soundChannel:SoundChannel;
		private var _soundMasterVolume:Number;

		public function Main_BBB()
		{
			// Init powerup probability
			_powerUpsTotProb = 0;
			for (var i:int = 0; i < POWERUP_PDIST.length; i++)
			{
				_powerUpsTotProb +=  POWERUP_PDIST[i];
			}

			//Initialize _balls arrays
			_balls = new Array;
			_balls = [];
			//Initialize _powerUps arrays
			_powerUps = new Array;
			_powerUps = [];
			//Initialize _bullets arrays
			_bullets = new Array;
			_bullets = [];

			//Initialize sound effects
			_theme = new StartTheme;
			_bounceHi = new BounceHi;
			_bounceMid = new BounceMid;
			_bounceLo = new BounceLo;
			_lifeLost = new LifeLost;
			_gameOver = new GameOver;
			_teleportSFX = new TeleportSFX;
			_laserSFX = new LaserSFX;
			_soundChannel = new SoundChannel;

			// Set volume controls
			volumeOff.visible = false;
			volumeOn.visible = true;
			volumeSlider.value = INITIAL_VOLUME;
			_soundMasterVolume = volumeSlider.value/10.0;
			SoundMixer.soundTransform = new SoundTransform(_soundMasterVolume); // Sets the volume to 50%

			//Initialize timers
			_launchTimer = new Timer(LAUNCH_DELAY);
			_launchTimer.addEventListener(TimerEvent.TIMER,onUpdateTime);

			_startTimer = new Timer(START_DELAY);
			_startTimer.addEventListener(TimerEvent.TIMER,onStartRound);
			
			// Prep game over/continue screen
			_msgScreen = new MessageScreen();
			_msgScreen.x = stage.width/2 - _msgScreen.width/2;
			_msgScreen.y = stage.height/2 - _msgScreen.height/2;
			_msgScreen.visible = false;
			addChild(_msgScreen);

			_msgScreen.newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClick);
			_msgScreen.instructionsButton.addEventListener(MouseEvent.CLICK, onInstructionsButtonClick);
			_msgScreen.quitButton.addEventListener(MouseEvent.CLICK, onQuitButtonClick);

			stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			stage.addEventListener("powerUpCreated",onPowerUpCreated);
			stage.addEventListener("ballCreated",onBallCreated);
			stage.addEventListener("bulletCreated",onBulletCreated);
			stage.addEventListener("playerMoved",onPlayerMoved);
			stage.addEventListener("playSFX",onPlaySFX);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			volumeSlider.addEventListener(SliderEvent.CHANGE, onVolumeChanged);

//			_msgScreen.visible = true;
//			gotoAndStop(1);
			newGame();
//			_levelDisplayed = new Levels();
//			this.addChild(_levelDisplayed);
		}

		private function newGame():void
		{
			_lives = 3;
			_score = 0;
			_currLevel = 1;
			for (var i:uint = _lives; i < MAX_LIVES; i++)
			{
				this["extraLife" + i].visible = false;
			}
			StartLevel(_currLevel);
		}

		private function StartLevel(level:uint = 1):void
		{
			// Start timer to begin round
			_startTimer.start();

			// Load level
			gotoAndStop(level);
			//_levelDisplayed.gotoAndStop(level);
			gameLevel.text = "" + _currLevel;
			
			// Count number of breakable blocks
			_bricksRemaining = 0;
			for (var i:int = 0; i < numChildren; i++)
			{
				var className:String = getQualifiedClassName(getChildAt(i));
				if (className == "Brick" || className == "SilverBrick")
				{
					_bricksRemaining++;
				}
			}

			// Play start theme
			_soundChannel = _theme.play();
			
			// TODO: test code
			var pu:PowerUp = new PowerUp(PLAYER_STARTX,PLAYER_STARTY-200,PUTypes.MEGABALL, PUTypes.COLOR_MEGABALL);
			this.addChild(pu);
	
		}
		
		private function onStartRound(event:Event):void
		{
			_startTimer.reset();

			_player = new Player();
			_player.x = PLAYER_STARTX;
			_player.y = PLAYER_STARTY;
			this.addChild(_player);

			var ball:Ball = new Ball(_player.x,_player.y,START_VELOCITY);
			this.addChild(ball);
			setIsOnPaddle(ball);
			ball.paddleXOffset = 0.25*_player.width;
			ball.x = _player.x + ball.paddleXOffset;

			_launchTimer.start();

		}
		
		private function onPowerUpCreated(event:Event)
		{
			//Add new powerUp to the _powerUps array
			_powerUps.push(MovieClip(event.target));
			//trace(event.target.name);
		}
		
		private function onBulletCreated(event:Event)
		{
			//Add new bullet to the _bullets array
			_bullets.push(MovieClip(event.target));
			//trace(event.target.name);
		}
		
		private function onBallCreated(event:Event)
		{
			//Add new ball to the _balls array
			_balls.push(MovieClip(event.target));
			trace("Ball created as " + event.target.name);
		}
		
		private function onPlayerMoved(event:Event)
		{
			var playerHalfWidth:uint = _player.width / 2;
			
			var rightLimit:Number = stageBackground.x + stageBackground.width;
			var leftLimit:Number = stageBackground.x;
			//Stage boundaries
			if (_player.x + playerHalfWidth > rightLimit)
//			if (_player.x + playerHalfWidth > PLAYAREA_RIGHT_LIMIT)
			{
				_player.vx = 0;
				_player.x=rightLimit - playerHalfWidth;
//				_player.x=PLAYAREA_RIGHT_LIMIT - playerHalfWidth;
			}
//			else if (_player.x - playerHalfWidth < PLAYAREA_LEFT_LIMIT)
			else if (_player.x - playerHalfWidth < leftLimit)
			{
				_player.vx = 0;
//				_player.x = PLAYAREA_LEFT_LIMIT + playerHalfWidth;
				_player.x = leftLimit + playerHalfWidth;
			}
			for (var j:int = 0; j < _balls.length; j++)
			{
				if (_balls[j].isOnPaddle)
				{
					_balls[j].x = _player.x + _balls[j].paddleXOffset;
				}
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			var i:int;
			var j:int;
			var k:int;
			
			for (j = 0; j < _bullets.length; j++)
			{
				if (_bullets[j].isLost)
				{
					removeChild(_bullets[j]);
					_bullets.splice(j,1);
					j--;
				}
			}
			
			for (j = 0; j < _balls.length; j++)
			{
				if (_balls[j].isLost)
				{
					removeChild(_balls[j]);
					_balls.splice(j,1);
					j--;

					if (_balls.length == 0)
					{
						_lives--;
						removeChild(_player);
						if (_lives == 0)
						{
							_msgScreen.output_txt.text = "You lose.";
							_soundChannel = _gameOver.play();
							displayMessageScreen();
						}
						else
						{
							_soundChannel = _lifeLost.play();
							this["extraLife" + _lives].visible = false;
							
							// Remove any powerups
							for (k = 0; k < _powerUps.length; k++)
							{
								removeChild(_powerUps[k]);
							}
							_powerUps.splice(0);
							
							_startTimer.start();
							//startRound();
						}
					}
					continue;
				}
				// Test for collision between ball and player
				// Check for null _player reference since onEnterFrame can be called
				// while no _player exists, before it is created in onStartRound
				if (_player != null &&
//					Collision.ballAndPlayer(_balls[j],_player) && 
					Collision.test(_balls[j],_player) &&
					!_balls[j].isOnPaddle)
				{
					// Play sound
					_soundChannel = _bounceMid.play();
					
					if (Collision.hitTop(_balls[j],_player))
					{
						//if catching is enabled set the ball's isOnTop 
						//property to true
						if (_player.powerUp == PUTypes.CATCH)
						{
							setIsOnPaddle(_balls[j]);
						}
						else
						{
							var launchAngle = findLaunchAngle(_player.x - _balls[j].x);
							_balls[j].launchAtAngle(launchAngle);
						}
					}
					
					
//					if (_player.powerUp == PUTypes.CATCH)
//					{
//						setIsOnPaddle(_balls[j]);
//					}
				}
			}

			//Check for powerup fall offscreen, collision with player
			for (i = 0; i < _powerUps.length; i++)
			{
				var botLimit:Number = stageBackground.y + stageBackground.height;
//				if (_powerUps[i].y > PLAYAREA_BOT_LIMIT)
				if (_powerUps[i].y > botLimit)
				{
					// Remove powerUp from Stage
					removeChild(_powerUps[i]);

					// Remove powerUp from array
					_powerUps.splice(i,1);
					i--;
				}
				else if (_player != null && _player.hitTestObject(_powerUps[i]))
				{
					// Counter variables defined outside for loops to avoid AS3
					// warning about multiple variable definitions
					
					trace("Player caught powerup: " + _powerUps[i].powerUpType);
					switch (_powerUps[i].powerUpType)
					{
						case PUTypes.CATCH :
						case PUTypes.LASER :
						case PUTypes.EXPAND :
						case PUTypes.SHRINK :
							_player.powerUp = _powerUps[i].powerUpType;
							break;
						case PUTypes.EXTRALIFE : 
							this["extraLife" + _lives].visible = true;
							_lives = Math.min(_lives+1, MAX_LIVES);
							break;
						case PUTypes.SLOW :
							for (j = 0; j < _balls.length; j++)
							{
								_balls[j].speed = START_VELOCITY/2;
							}
							break;
						case PUTypes.MEGABALL :
							for (j = 0; j < _balls.length; j++)
							{
								_balls[j].powerup = _powerUps[i].powerUpType;
							}
							break;
						case PUTypes.TRIPLE :
							var numBalls = _balls.length;
							for (j = 0; j < numBalls; j++)
							{
								for (k = 0; k < 2; k++)
								{
									var ball:Ball = new Ball(_balls[j].x,_balls[j].y,START_VELOCITY);
									ball.powerup = _balls[j].powerup;
									this.addChild(ball);
									ball.launchAtAngle(_balls[j].angle - 15 + 30*k);
								}
								
							}
							break;
						case PUTypes.WARP:
							_soundChannel = _teleportSFX.play();
							winLevel();
							break;
						default :
							_player.powerUp = "";
							for (j = 0; j < _balls.length; j++)
							{
								_balls[j].powerup = "";
							}
							break;
					}
					
					incrementScore(_powerUps[i].score);
					//_score +=  _powerUps[i].score;

					// Remove powerUp from Stage
					removeChild(_powerUps[i]);

					// Remove powerUp from array
					_powerUps.splice(i,1);
					i--;
				}
			}
		}
		
		// Test for collision between brick and bullets, balls
		public function checkCollisionWithBrick(brick:Brick)
		{
			var j:int;
			for (j = 0; j < _bullets.length; j++)
			{
//				if (_bullets[j] != null)
				{
					if (Collision.test(_bullets[j], brick))
					{
						_bullets[j].isLost = true;
						
						brick.hits--;
						breakBrick(brick);
					}
				}
			}
			
			for (j = 0; j < _balls.length; j++)
			{
//				if (_balls[j] != null)
				{
					if (Collision.test(_balls[j], brick))
					{
						for (var k:int = 0; k < _balls.length; k++)
						{
							_balls[k].speed += VELOCITY_INCR;
						}
						if (_balls[j].powerup == PUTypes.MEGABALL)
						{
							brick.hits = 0;
						}
						else
						{
							Collision.bounce(_balls[j],brick);
							brick.hits--;
						}
						breakBrick(brick);
					}
				}
			}
		}
		
		private function breakBrick(brick:Brick):void
		{
			if (brick.hits <= 0)
			{
				// Check for power up
				if (Math.random() <= POWERUP_CHANCE)
				{
					// Create new power up
					var pUpRoll = Math.ceil(Math.random() * _powerUpsTotProb);
					var cumPUChance:uint = 0;
					var pUChosen:uint;
					for (var i:int = 0; i < POWERUP_PDIST.length; i++)
					{
						cumPUChance +=  POWERUP_PDIST[i];
						if (pUpRoll < cumPUChance)
						{
							pUChosen = i;
							break;
						}
					}
					this.addChild(new PowerUp(brick.x,brick.y,POWERUP_LIST[pUChosen],
											  POWERUP_COLOR[pUChosen]));
				}

				// Update score
				incrementScore(brick.score);

				// Play sound
				_soundChannel = _bounceLo.play();

				// Remove brick
				removeChild(brick);
							
				// Check for end of level
				if (brick.isBreakable)
				{
					_bricksRemaining--;
							
					if (_bricksRemaining == 0)
					{
						winLevel();
					}
				}
			}
			else
			{
				// Play sound
				_soundChannel = _bounceHi.play();
				brick.play();
			}
		}
		
		private function findLaunchAngle(dx:Number):Number
		{
			// Find launch angle based on where ball hit paddle
			var angle:Number = (1 + dx / (_player.width/2)) * (90-MIN_LAUNCH_ANGLE) + MIN_LAUNCH_ANGLE;

			// Clamp angle
			angle = Math.min(Math.max(angle, MIN_LAUNCH_ANGLE), 180-MIN_LAUNCH_ANGLE);
//			if ((angle < MIN_LAUNCH_ANGLE) || (180-angle < MIN_LAUNCH_ANGLE))
//			{
//				trace("Launch angle " + angle + " below minimun angle " + MIN_LAUNCH_ANGLE);
//				trace("dx = " + dx + ", halfwidth = " + _player.width/2);
//				trace("First op = " + (1 + dx / (_player.width/2)));
//			}
			
			return (angle);
		}
		
		private function setIsOnPaddle(ball:MovieClip):void
		{
			ball.isOnPaddle = true;
			ball.vx = 0;
			ball.vy = 0;
			_launchTimer.start();

			ball.paddleXOffset = ball.x - _player.x;
			ball.y = _player.y - _player.height / 2 - ball.height / 2;
		}
		
		private function launchBall(ball:MovieClip):void
		{
			ball.isOnPaddle = false;

			var launchAngle = findLaunchAngle(_player.x - ball.x);
			ball.launchAtAngle(launchAngle);
			trace("Launching ball with vx= " + ball.vx + " vy= " + ball.vy, "Angle= " + launchAngle);
			
		}
		
		private function onUpdateTime(event:Event):void
		{
			if (_launchTimer.currentCount == TIMER_LENGTH)
			{
				_launchTimer.reset();
				for (var j:int = 0; j < _balls.length; j++)
				{
					if (_balls[j].isOnPaddle)
					{
						launchBall(_balls[j]);
					}
				}
			}
		}

		private function winLevel():void
		{
			var j:int;
			
			// Remove all balls
			for (j = 0; j < _balls.length; j++)
			{
				removeChild(_balls[j]);
			}
			_balls.splice(0);
			
			// Remove player paddle
			removeChild(_player);
			
			// Remove all powerups
			for (j = 0; j < _powerUps.length; j++)
			{
				removeChild(_powerUps[j]);
			}
			_powerUps.splice(0);
			
			// Start next level
			if (_currLevel < MAX_LEVEL)
			{
				_currLevel++;
				StartLevel(_currLevel);
			}
			else
			{
				_msgScreen.output_txt.text = "You win!";
				displayMessageScreen();
			}
			
		}
		
		private function onVolumeChanged(event:SliderEvent):void
		{
			stage.focus = null;
			applyVolume();
		}
		
		private function applyVolume():void{
			_soundMasterVolume = volumeSlider.value/10.0;
			if (volumeSlider.value == 0)
			{
				volumeOff.visible = true;
				volumeOn.visible = false;
			}
			else
			{
				volumeOff.visible = false;
				volumeOn.visible = true;
			}
			SoundMixer.soundTransform = new SoundTransform(_soundMasterVolume); // Sets the volume to 50%
		}

		private function onKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.NUMBER_0) // '0': mute volume
			{
				volumeOff.visible = !volumeOff.visible;
				volumeOn.visible = !volumeOn.visible;
				if (volumeOff.visible)
				{
					SoundMixer.soundTransform = new SoundTransform(0);
				}
				else
				{
					SoundMixer.soundTransform = new SoundTransform(_soundMasterVolume);
				}
			}
			else if (event.keyCode == Keyboard.MINUS) // '-': reduce volume
			{
				volumeSlider.value = Math.max(0,volumeSlider.value-1);
				applyVolume();
			}
			else if (event.keyCode == Keyboard.EQUAL) // '+': increase volume
			{
				volumeSlider.value = Math.min(10,volumeSlider.value+1);
				applyVolume();
			}
			else if (event.keyCode == Keyboard.P) // 'p': pause
			{
				_isPaused = !_isPaused;
				applyPause();
			}
			else if (event.keyCode == Keyboard.SPACE)
			{
				for (var j:int = 0; j < _balls.length; j++)
				{
					if (_balls[j].isOnPaddle)
					{
						launchBall(_balls[j]);
					}
				}
				
				if (_player.powerUp == PUTypes.LASER)
				{
					this.addChild(new Bullet(_player.x, _player.y - _player.height/2));
					_soundChannel = _laserSFX.play();
				}
				
			}
		}

		private function applyPause():void
		{
			if (_isPaused)
			{
				stage.frameRate = 0;
			}
			else
			{
				stage.frameRate = 30;
			}			
		}

		private function onPlaySFX(event:Event):void
		{
			if (event.target.sfxToPlay != null)
			{
				_soundChannel = event.target.sfxToPlay.play();
			}
		}
		
		private function incrementScore(incr:uint):void
		{
			var multiplier:Number = Math.max(1.0,1.0/_player.scaleX);
			_score += incr * multiplier;
			gameScore.text = "" + _score;
		}
		
		private function displayMessageScreen():void
		{
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(TimerEvent.TIMER,onStartRound);
			removeEventListener("powerUpCreated",onPowerUpCreated);
			removeEventListener("ballCreated",onBallCreated);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			
			_msgScreen.visible = true;
		}
		
		private function onNewGameButtonClick(event:MouseEvent):void
		{
			newGame();
			_msgScreen.visible = false;
		}
		
		private function onInstructionsButtonClick(event:MouseEvent):void
		{
			
		}
		
		private function onQuitButtonClick(event:MouseEvent):void
		{
			fscommand("quit");
		}
	}
}