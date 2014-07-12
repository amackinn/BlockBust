﻿package 
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
	import fl.controls.Slider;
	import fl.events.SliderEvent;

	public class Main_BBB extends MovieClip
	{
		//Constants
		private const PLAYAREA_LEFT_LIMIT:uint = 14;
		private const PLAYAREA_RIGHT_LIMIT:uint = 450;
		private const PLAYAREA_TOP_LIMIT:uint = 16;
		private const PLAYAREA_BOT_LIMIT:uint = 415;
		private const MAX_LIVES:int = 9;
		private const TIMER_LENGTH:int = 6;
		private const START_VELOCITY:int = 8;
		private const VELOCITY_INCR:int = .25;
		private const POWERUP_CHANCE:Number = 0.1;
		private const LAUNCH_DELAY:uint = 1000;
		private const START_DELAY = 200;
		private const INITIAL_VOLUME = 5;

		private const POWERUP_LIST:Array = [PUTypes.CATCH, PUTypes.SLOW, PUTypes.TRIPLE,
											PUTypes.EXPAND, PUTypes.SHRINK, PUTypes.MEGABALL,
											PUTypes.LASER, PUTypes.EXTRALIFE, PUTypes.WARP];
		private const POWERUP_COLOR:Array = [PUTypes.COLOR_CATCH, PUTypes.COLOR_SLOW, PUTypes.COLOR_TRIPLE,
											PUTypes.COLOR_EXPAND, PUTypes.COLOR_SHRINK, PUTypes.COLOR_MEGABALL,
											PUTypes.COLOR_LASER, PUTypes.COLOR_EXTRALIFE, PUTypes.COLOR_WARP];
		private const POWERUP_PDIST:Array = [PUTypes.PROB_CATCH, PUTypes.PROB_SLOW, PUTypes.PROB_TRIPLE,
											PUTypes.PROB_EXPAND, PUTypes.PROB_SHRINK, PUTypes.PROB_MEGABALL,
											PUTypes.PROB_LASER, PUTypes.PROB_EXTRALIFE, PUTypes.PROB_WARP];

		private var _lives:int;
		private var _balls:Array;
		private var _player:Player;
		private var _launchTimer:Timer;
		private var _startTimer:Timer;
		private var _score:uint;
		private var _powerUps:Array;
		private var _powerUpsTotProb;

		// Sound Resources
		private var _theme:StartTheme;
		private var _bounceHi:BounceHi;
		private var _bounceMid:BounceMid;
		private var _bounceLo:BounceLo;
		private var _lifeLost:LifeLost;
		private var _gameOver:GameOver;
		private var _teleportSFX:TeleportSFX;
		private var _soundChannel:SoundChannel;
		private var _soundMasterVolume:Number;

		public function Main_BBB()
		{
			initGame();

			stage.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			stage.addEventListener("powerUpCreated",onPowerUpCreated);
			stage.addEventListener("ballCreated",onBallCreated);
			stage.addEventListener("playerMoved",onPlayerMoved);
			stage.addEventListener("playSFX",onPlaySFX);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			volumeSlider.addEventListener(SliderEvent.CHANGE, onVolumeChanged);
		}
		
		private function initGame():void
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

			//Initialize sound effects
			_theme = new StartTheme;
			_bounceHi = new BounceHi;
			_bounceMid = new BounceMid;
			_bounceLo = new BounceLo;
			_lifeLost = new LifeLost;
			_gameOver = new GameOver;
			_teleportSFX = new TeleportSFX;
			_soundChannel = new SoundChannel;

			
			volumeOff.visible = false;
			volumeOn.visible = true;
			volumeSlider.value = INITIAL_VOLUME;
			_soundMasterVolume = volumeSlider.value/10.0;
			SoundMixer.soundTransform = new SoundTransform(_soundMasterVolume); // Sets the volume to 50%

			//Initialize objects
			_lives = 3;
			_score = 0;
			for (i = _lives; i < MAX_LIVES; i++)
			{
				this["extraLife" + i].visible = false;
			}
			_launchTimer = new Timer(LAUNCH_DELAY);
			_launchTimer.addEventListener(TimerEvent.TIMER,onUpdateTime);

			_startTimer = new Timer(START_DELAY);
			_startTimer.addEventListener(TimerEvent.TIMER,onStartRound);
			_startTimer.start();

			// Play start theme
			_soundChannel = _theme.play();
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
			if (event.keyCode == 48) // '0': mute volume
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
			else if (event.keyCode == 189) // '-': reduce volume
			{
				volumeSlider.value = Math.max(0,volumeSlider.value-1);
				applyVolume();
			}
			else if (event.keyCode == 187) // '+': increase volume
			{
				volumeSlider.value = Math.min(10,volumeSlider.value+1);
				applyVolume();
			}
		}


		private function onStartRound(event:Event):void
		{
			_startTimer.reset();

			_player = new Player();
			_player.x = 134;
			_player.y = 388;
			_player.launchAngle = 45;
			this.addChild(_player);

			var ball:Ball = new Ball(_player.x,_player.y,START_VELOCITY);
			this.addChild(ball);
			ball.isOnPaddle = true;
			ball.x = _player.x - ball.dx;
			ball.y = _player.y - _player.height / 2 - ball.height / 2;

			_launchTimer.start();

		}
		
		private function onPowerUpCreated(event:Event)
		{
			//Add new powerUp to the _powerUps array
			_powerUps.push(MovieClip(event.target));
			trace(event.target.name);
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
			
			//Stage boundaries
			if (_player.x + playerHalfWidth > PLAYAREA_RIGHT_LIMIT)
			{
				_player.vx = 0;
				_player.x=PLAYAREA_RIGHT_LIMIT - playerHalfWidth;
			}
			else if (_player.x - playerHalfWidth < PLAYAREA_LEFT_LIMIT)
			{
				_player.vx = 0;
				_player.x = PLAYAREA_LEFT_LIMIT + playerHalfWidth;
			}
			for (var j:int = 0; j < _balls.length; j++)
			{
				if (_balls[j].isOnPaddle)
				{
					_balls[j].x = _player.x - _balls[j].dx;
					_balls[j].y = _player.y - _player.height / 2 - _balls[j].height / 2;
				}
			}
		}
		
		private function onPlaySFX(event:Event)
		{
			if (event.target.sfxToPlay != null)
			{
				_soundChannel = event.target.sfxToPlay.play();
			}
		}
		
		private function onEnterFrame(event:Event):void
		{
			for (var j:int = 0; j < _balls.length; j++)
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
							endGame();
						}
						else
						{
							_soundChannel = _lifeLost.play();
							this["extraLife" + _lives].visible = false;
							
							// Remove any powerups
							for (var j:int = 0; j < _powerUps.length; j++)
							{
								removeChild(_powerUps[j]);
							}
							_powerUps.splice(0);
							
							_startTimer.start();
							//startRound();
						}
					}
					continue;
				}
				// Test for collision between ball and player
				if (Collision.ballAndPlayer(_balls[j],_player) && !_balls[j].isOnPaddle)
				{
					// Play sound
					_soundChannel = _bounceMid.play();
					if (_player.powerUp == PUTypes.CATCH)
					{
						_balls[j].isOnPaddle = true;
					}
				}
				if (_balls[j].isOnPaddle)
				{
					_balls[j].vx = 0;
					_balls[j].vy = 0;
				}
				// Get ball moving when launched from paddle
				if (_balls[j].launch)
				{
					_balls[j].isOnPaddle = false;
					_balls[j].launch = false;
					_balls[j].launchAtAngle(_player.launchAngle);
					//trace("Launching ball, vel=" + _balls[j].vel);
				}
			}

			//Check for powerup fall offscreen, collision with player
			for (var i:int = 0; i < _powerUps.length; i++)
			{
				if (_powerUps[i].y > PLAYAREA_BOT_LIMIT)
				{
					// Remove powerUp from Stage
					removeChild(_powerUps[i]);

					// Remove powerUp from array
					_powerUps.splice(i,1);
					i--;
				}
				else if (_player.hitTestObject(_powerUps[i]))
				{
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
							for (var k:int = 0; k < _balls.length; k++)
							{
								_balls[k].vel = START_VELOCITY/2;
							}
							break;
						case PUTypes.MEGABALL :
							for (var j:int = 0; j < _balls.length; j++)
							{
								_balls[j].powerup = _powerUps[i].powerUpType;
							}
							break;
						case PUTypes.TRIPLE :
							var numBalls = _balls.length;
							for (var j:int = 0; j < numBalls; j++)
							{
								for (var k:int = 0; k < 2; k++)
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
							for (var j:int = 0; j < _balls.length; j++)
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
		// Test for collision between ball and bricks
		//A. Allow the wall objects to check for a collison
		//with the player
		public function checkCollisionWithBall(brick:MovieClip)
		{
			var cumPUChance:uint;
			var pUChosen:uint;

			for (var j:int = 0; j < _balls.length; j++)
			{
				if (_balls[j] != null)
				{
					//if (Collision.test(_balls[j], brick))
					if (Collision.ballAndBrick(_balls[j], brick, _balls[j].powerup != PUTypes.MEGABALL))
					{
						for (var k:int = 0; k < _balls.length; k++)
						{
							_balls[k].vel += VELOCITY_INCR;
						}
						if (_balls[j].powerup == PUTypes.MEGABALL)
						{
							brick.hits = 0;
						}
						else
						{
							Collision.block(_balls[j],brick);
							brick.hits--;
						}
						if (brick.hits <= 0)
						{
							// Check for power up
							if (Math.random() <= POWERUP_CHANCE)
							{
								// Create new power up
								var pUpRoll = Math.ceil(Math.random() * _powerUpsTotProb);
								cumPUChance = 0;
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
							//_score +=  brick.score;

							// Remove brick
							removeChild(brick);
							brick = null;

							// Play sound
							_soundChannel = _bounceLo.play();
						}
						else
						{
							// Play sound
							_soundChannel = _bounceHi.play();
							brick.play();
						}
					}
				}
			}
		}
		private function onUpdateTime(event:Event):void
		{
			for (var j:int = 0; j < _balls.length; j++)
			{
				if (_balls[j].isOnPaddle && _launchTimer.currentCount == TIMER_LENGTH)
				{
					_launchTimer.reset();
					_balls[j].isOnPaddle = false;
					_balls[j].launch = true;
				}
			}
		}


		private function endGame():void
		{
			_soundChannel = _gameOver.play();
			removeEventListener(Event.ENTER_FRAME,onEnterFrame);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(TimerEvent.TIMER,onStartRound);
			removeEventListener("powerUpCreated",onPowerUpCreated);
			removeEventListener("ballCreated",onBallCreated);
			removeEventListener(TimerEvent.TIMER,onUpdateTime);
			removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		
		private function winLevel():void
		{
			// Remove all balls
			for (var j:int = 0; j < _balls.length; j++)
			{
				removeChild(_balls[j]);
			}
			_balls.splice(0);
			
			// Remove player paddle
			removeChild(_player);
			
			// Remove any powerups
			for (var j:int = 0; j < _powerUps.length; j++)
			{
				removeChild(_powerUps[j]);
			}
			_powerUps.splice(0);
		}
		
		private function incrementScore(incr:uint):void
		{
			var multiplier:Number = Math.max(1.0,1.0/_player.scaleX);
			_score += incr * multiplier;
			gameScore.text = "" + _score;
		}
	}
}