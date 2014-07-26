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
	import fl.containers.ScrollPane;

	public class Main_BBB extends MovieClip
	{
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
		private const ACCELERATION:Number = 3;
		private const INITIAL_LAUNCHANGLE:Number = 45;
		private const MIN_LAUNCH_ANGLE:int = 15;
		private const BOUNCE:Number = -1.0; 
		
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
		private var _bricks:Array;
		private var _lives:int;
		private var _launchTimer:Timer;
		private var _startTimer:Timer;

		private var _powerUpsTotProb: uint;

		private var _score:uint;
		private var _currLevel: uint;
		private var _bricksRemaining:uint;
		private var _msgScreen:MessageScreen;
		private var _helpScreen:HelpScreen;
		private var _helpScreenContent:HelpScreenContent;
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
			//Initialize _bricks arrays
			_bricks = new Array;
			_bricks = [];

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
			
			_helpScreen = new HelpScreen();
			_helpScreenContent = new HelpScreenContent();
			_helpScreen.scrollPane.source = _helpScreenContent;
			_helpScreen.scrollPane.setSize(530,370);
			_helpScreenContent.catchPU.setPowerUp(PUTypes.CATCH, PUTypes.COLOR_CATCH);
			_helpScreenContent.slowPU.setPowerUp(PUTypes.SLOW, PUTypes.COLOR_SLOW);
			_helpScreenContent.triplePU.setPowerUp(PUTypes.TRIPLE, PUTypes.COLOR_TRIPLE);
			_helpScreenContent.growPU.setPowerUp(PUTypes.EXPAND, PUTypes.COLOR_EXPAND);
			_helpScreenContent.reducePU.setPowerUp(PUTypes.SHRINK, PUTypes.COLOR_SHRINK);
			_helpScreenContent.megaPU.setPowerUp(PUTypes.MEGABALL, PUTypes.COLOR_MEGABALL);
			_helpScreenContent.laserPU.setPowerUp(PUTypes.LASER, PUTypes.COLOR_LASER);
			_helpScreenContent.extraLifePU.setPowerUp(PUTypes.EXTRALIFE, PUTypes.COLOR_EXTRALIFE);
			_helpScreenContent.warpPU.setPowerUp(PUTypes.WARP, PUTypes.COLOR_WARP);
			_helpScreen.visible = false;
			addChild(_helpScreen);

			_msgScreen.newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClick);
			_msgScreen.instructionsButton.addEventListener(MouseEvent.CLICK, onInstructionsButtonClick);
			_msgScreen.quitButton.addEventListener(MouseEvent.CLICK, onQuitButtonClick);

			mainHelpButton.addEventListener(MouseEvent.CLICK, onHelpButtonClick);
			mainCancelButton.addEventListener(MouseEvent.CLICK, onQuitButtonClick);
			stage.addEventListener(Event.ENTER_FRAME,onEnterFrameListener);
			stage.addEventListener("powerUpCreated",onPowerUpCreated);
			stage.addEventListener("ballCreated",onBallCreated);
			stage.addEventListener("bulletCreated",onBulletCreated);
			stage.addEventListener("playerMoved",onPlayerMoved);
			stage.addEventListener("playSFX",onPlaySFX);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDownListener);
			stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUpListener);
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
			
			// Empty bricks array
			_bricks.splice(0);
			
			// Count number of breakable blocks
			_bricksRemaining = 0;
			for (var i:int = 0; i < numChildren; i++)
			{
				var className:String = getQualifiedClassName(getChildAt(i));
				// Check if object is a brick
				if (className == "Brick" || className == "SilverBrick")
				{
					_bricks.push(getChildAt(i));
					_bricksRemaining++;
				}
				else if (className == "GoldBrick")
				{
					_bricks.push(getChildAt(i));
				}
			}

			// Play start theme
			_soundChannel = _theme.play();
			
			//var pu:PowerUp = new PowerUp(PUTypes.MEGABALL, PUTypes.COLOR_MEGABALL, PLAYER_STARTX,PLAYER_STARTY-200);
			var pu:PowerUp = new PowerUp(PUTypes.LASER, PUTypes.COLOR_LASER);
			pu.x=PLAYER_STARTX;
			pu.y=PLAYER_STARTY-200;
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
			{
				_player.vx = 0;
				_player.x=rightLimit - playerHalfWidth;
			}
			else if (_player.x - playerHalfWidth < leftLimit)
			{
				_player.vx = 0;
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
		
		private function onEnterFrameListener(event:Event):void
		{
			var i:int;
			var j:int;
			var k:int;
			
			// TODO: Move var set to onStageAdded
			var botLimit:Number = stageBackground.y + stageBackground.height;
			var topLimit:Number = stageBackground.y;
			var rightLimit:Number = stageBackground.x + stageBackground.width;
			var leftLimit:Number = stageBackground.x;
			
			// Move bullets
			for (j = 0; j < _bullets.length; j++)
			{
				//Move the bullet
				_bullets[j].y += _bullets[j].vy;
				
				if (_bullets[j].y - _bullets[j].height / 2 < topLimit)
				{
					_bullets[j].isLost = true;
				}
				
				// Checked separately from test above for going offscreen since
				// bullet can also be lost when hitting brick
				if (_bullets[j].isLost)
				{
					removeChild(_bullets[j]);
					_bullets.splice(j,1);
					j--;
				}
			}
			
			// Move balls
			var ballHalfWidth:uint;
			var ballHalfHeight:uint;
			if (_balls.length > 0)
			{
				ballHalfWidth = _balls[0].width / 2;
				ballHalfHeight = _balls[0].height / 2;
			}
			for (j = 0; j < _balls.length; j++)
			{
				
				if (Math.abs(_balls[j].vx) < 0.1)
				{
					_balls[j].vx = 0;
				}
				if (Math.abs(_balls[j].vy) < 0.1)
				{
					_balls[j].vy = 0;
				}
				
				//Move the ball
				_balls[j].x += _balls[j].vx;
				_balls[j].y += _balls[j].vy;
				
				//Stage boundaries
				if (_balls[j].x + ballHalfWidth > rightLimit)
				{
					_balls[j].vx *= BOUNCE;
					_balls[j].x=rightLimit - ballHalfWidth;
				}
				else if (_balls[j].x - ballHalfWidth < leftLimit)
				{
					_balls[j].vx *= BOUNCE;
					_balls[j].x = leftLimit + ballHalfWidth;
				}
				if (_balls[j].y - ballHalfHeight < topLimit)
				{
					_balls[j].vy *= BOUNCE;
					_balls[j].y = topLimit + ballHalfHeight;
				}
				else if (_balls[j].y + ballHalfHeight > botLimit)
				{
					_balls[j].vy *= BOUNCE;
					_balls[j].y = botLimit - ballHalfHeight;
					
//					_balls[j].isLost = true;
				}				
				
				if (_balls[j].isLost)
				{
					removeChild(_balls[j]);
					_balls.splice(j,1);
					j--;

					if (_balls.length == 0)
					{
						_lives--;
						removeChild(_player);
						
						// Remove any powerups
						for (k = 0; k < _powerUps.length; k++)
						{
							removeChild(_powerUps[k]);
						}
						_powerUps.splice(0);
							
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
							
							_startTimer.start();
							//startRound();
						}
					}
					continue;
				}
				// Test for collision between ball and player
				// Check for null _player reference since onEnterFrameListener can be called
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
				// Move powerup
				_powerUps[i].y += _powerUps[i].vy;
				
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
			
			// Move player paddle
			if (_player != null)
			{
				//Apply Acceleration
				_player.vx +=  _player.ax;
				
				if (Math.abs(_player.vx) < 0.1)
				{
					_player.vx = 0;
				}
				else
				{
					//Move the player
					_player.x +=  _player.vx;
		
					var playerHalfWidth:uint = _player.width / 2;
					
					//Stage boundaries
					if (_player.x + playerHalfWidth > rightLimit)
					{
						_player.vx = 0;
						_player.x=rightLimit - playerHalfWidth;
					}
					else if (_player.x - playerHalfWidth < leftLimit)
					{
						_player.vx = 0;
						_player.x = leftLimit + playerHalfWidth;
					}
					
					// Move balls on paddle along with paddle movement
					for (j = 0; j < _balls.length; j++)
					{
						if (_balls[j].isOnPaddle)
						{
							_balls[j].x = _player.x + _balls[j].paddleXOffset;
						}
					}
				}
			}
			
			// Check for brick collisions
			for (j = 0; j < _bricks.length; j++)
			{
				if(checkCollisionWithBrick(_bricks[j]))
				{
					_bricks.splice(j,1);
					j--;
				}
			}
		}
		
		// Test for collision between brick and bullets, balls
		public function checkCollisionWithBrick(brick:Brick): Boolean
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
						
						// Check if brick destroyed. If so, short-circuit return
						if (breakBrick(brick))
							return true;
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
						// Check if brick destroyed. If so, short-circuit return
						if (breakBrick(brick))
							return true;
					}
				}
			}
			// Return false if brick not destroyed
			return false;
		}
		
		private function breakBrick(brick:Brick): Boolean
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
					var pu:PowerUp = new PowerUp(POWERUP_LIST[pUChosen],
											  POWERUP_COLOR[pUChosen]);
					pu.x=brick.x;
					pu.y=brick.y;
					this.addChild(pu);
//					this.addChild(new PowerUp(POWERUP_LIST[pUChosen],
//											  POWERUP_COLOR[pUChosen], 
//											  brick.x,brick.y));
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
				// Broke a brick
				return true;
			}
			//else
			{
				// Play sound
				_soundChannel = _bounceHi.play();
				brick.play();
				// Didn't break a brick
				return false;
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

		private function onKeyDownListener(event:KeyboardEvent):void
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
			else if (event.keyCode == Keyboard.LEFT)
			{
				if (_player.vx > 0)
				{
					_player.ax = 0;
					_player.vx = 0;
				}
				_player.ax = - ACCELERATION;
			}
			else if (event.keyCode == Keyboard.RIGHT)
			{
				if (_player.vx < 0)
				{
					_player.ax = 0;
					_player.vx = 0;
				}
				_player.ax = ACCELERATION;
			}
		}
		private function onKeyUpListener(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.LEFT)
			{
				//if (_player.vx < 0)
				{
					_player.ax = 0;
					_player.vx = 0;
				}
			}
			if (event.keyCode == Keyboard.RIGHT)
			{
				//if (_player.vx > 0)
				{
					_player.ax = 0;
					_player.vx = 0;
				}
			}
		}

		private function applyPause():void
		{
			if (_isPaused)
			{
				//stage.frameRate = 0;
				stage.removeEventListener(Event.ENTER_FRAME,onEnterFrameListener);
			}
			else
			{
				//stage.frameRate = 30;
				stage.addEventListener(Event.ENTER_FRAME,onEnterFrameListener);
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
			removeEventListener(Event.ENTER_FRAME,onEnterFrameListener);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(TimerEvent.TIMER,onStartRound);
			removeEventListener("powerUpCreated",onPowerUpCreated);
			removeEventListener("ballCreated",onBallCreated);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDownListener);
			
			setChildIndex(_msgScreen, numChildren - 1);
			_msgScreen.visible = true;
		}
		
		private function onNewGameButtonClick(event:MouseEvent):void
		{
			newGame();
			_msgScreen.visible = false;
		}
		
		private function onQuitButtonClick(event:MouseEvent):void
		{
			fscommand("quit");
		}
		
		private function onInstructionsButtonClick(event:MouseEvent):void
		{
//			addChild(_helpScreen);
			// Move help screen to front of all other objects
			setChildIndex(_helpScreen, numChildren - 1);
			_helpScreen.visible = true;
			_helpScreen.cancelButton.addEventListener(MouseEvent.CLICK, onHelpCancelButtonClick);
		}
		
		private function onHelpButtonClick(event:MouseEvent):void
		{
			_isPaused = true;
			applyPause();

//			addChild(_helpScreen);
			// Move help screen to front of all other objects
			setChildIndex(_helpScreen, numChildren - 1);
			_helpScreen.visible = true;
			_helpScreen.cancelButton.addEventListener(MouseEvent.CLICK, onHelpCancelButtonClick);
		}
		
		private function onHelpCancelButtonClick(event:MouseEvent):void
		{
			_helpScreen.cancelButton.removeEventListener(MouseEvent.CLICK, onHelpCancelButtonClick);
			_helpScreen.visible = false;
//			removeChild(_helpScreen);
		}
	}
}