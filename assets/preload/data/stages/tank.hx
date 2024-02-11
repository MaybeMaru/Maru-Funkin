var boppers = [];

function createPost()
{
	State.camGame.bgColor = 0xfff5ca51;

	clouds.x = FlxG.random.int(-800, -300);
	clouds.velocity.x = FlxG.random.float(5, 15);
	
	var boppersData = [
		['tank5', [1620, 700], 	[1.5, 1.5], 'fg tankhead far right instance 1'],
		['tank4', [1300, 900], 	[1.5, 1.5], 'fg tankman bobbin 3 instance 1'],
		['tank2', [450, 940], 	[1.5, 1.5], 'foreground man 3 instance 1'],
		['tank1', [-300, 750], 	[2, 0.2], 	'fg tankhead 5 instance 1'],
		['tank0', [-500, 650], 	[1.7, 1.5], 'fg tankhead far right instance 1'],
		['tank3', [1300, 1200], [3.5, 2.5], 'fg tankhead 4 instance 1']
	];

	for (i in 0...boppersData.length)
	{
		var arr = boppersData[i];

		var bopper:FunkinSprite = new FunkinSprite(arr[0], arr[1], arr[2]);
		bopper.addAnim('idle', Std.string(arr[3]));
		bopper.playAnim('idle', true);
		
		boppers.push(bopper);
		addSpr(bopper, 'bopper' + i, true);
	}
}

function dance()
{
	watchtower.playAnim('idle', true);
	for (i in boppers)
		i.playAnim('idle', true);
}

function startTimer()
	dance();

function beatHit()
	dance();

// Move tank
var pi:Float = 0.01745329251;
var angle:Float = FlxG.random.int(-90, 45);
var speed:Float = FlxG.random.float(5, 7);

function update(elapsed)
{
	if (!State.inCutscene) {
		tank.visible = true;
		angle += speed * elapsed;
		tank.angle = (angle - 90 + 15);
		tank.x = 400 + 1500 * CoolUtil.cos(pi * (angle + 180));
		tank.y = 1300 + 1100 * CoolUtil.sin(pi * (angle + 180));
	}
	else {
		tank.visible = false;
	}
}