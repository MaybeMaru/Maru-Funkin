function startTimer()
	dance();

function beatHit()
	dance();

function dance() {
	upperCrowd.playAnim("idle", true);
	bottomCrowd.playAnim("idle", true);
	santa.playAnim("idle", true);
}

function createPost() {
	floor.makeRect(FlxG.width * 2, FlxG.height * .5, 0xfff3f4f5);
}