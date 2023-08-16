/*
    HOW TO MIGRATE MODS MADE IN CLOSED ALPHA 1 TO ALPHA 2

    ``FlxSprite`` in alpha 1 used to have animation offsets and other util functions like loadImage();
    This has been changed, if your mod used ``FlxSprite`` using any of those functions
    change all instances of ``FlxSprite`` to ``FlxSpriteExt``

    A variable called ``notesGroup`` has been added to PlayState. This group now contains variables like curSong, notes, unspawnNotes, etc...
    These variables can still be obtained using PlayState for backwards compatiblity, but for the future id recommend using PlayState.notesGroup
*/