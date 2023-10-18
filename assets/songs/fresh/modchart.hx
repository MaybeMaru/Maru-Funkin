function startSong() {
	State.camZooming = false;
}

function beatHit(curBeat) {
	switch (curBeat) {
		case 16:
			State.camZooming = true;
			State.gfSpeed = 2;
		case 48: State.gfSpeed = 1;
		case 80: State.gfSpeed = 2;
		case 112: State.gfSpeed = 1;
	}
}