/*
	Use this as a template when creating a custom state
	Make sure to add the hx file in data/scripts/customStates and use switchCustomState()!!
	Make sure to remember to call the super function!!
 */
function create()
{
	super_create();
}

function update(elapsed)
{
	super_update(elapsed);
}

function stepHit(curStep)
{
	super_stepHit();
}

function beatHit(curBeat)
{
	super_beatHit();
}

function sectionHit(curSection)
{
	super_sectionHit();
}

function destroy()
{
	super_destroy();
}
/*
	CUSTOM STATE VARIABLES
 */
Parent // FlxState instance
add();
insert();
remove();
