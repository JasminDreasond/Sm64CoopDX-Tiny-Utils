# Sm64CoopDX Tiny Utils
Tiny lib of useful API codes to start moding Sm64CoopDX.

https://github.com/coop-deluxe/sm64coopdx

## Song API
This API controls which songs you want to play in the game stages.

```lua
-- Force game stop the all default songs
_G.tsjSongs.setForceStopGameSongs(true)

-- Stop custom songs in the star selector
_G.tsjSongs.setStopSongOnStarSelector(true)

-- Add custom song into power up
_G.tsjSongs.addSong(-2, audio_stream_load('prototype.ogg'),
	{ loopEnd = 441144, loopStart = 0.5, volume = 1.25, name = "Prototype" })

-- Add custom song (id)
_G.tsjSongs.addSong(9, audio_stream_load('strangetown.ogg'),
	{ loopEnd = 3175889, loopStart = 0.5, volume = 1, name = "Strangetown" })

-- Add custom song (id, areaIndex, actNum, courseNum)
_G.tsjSongs.addSubSong(6, 3, 0, 0, audio_stream_load('strangetown_beta.ogg'),
	{ loopEnd = 3175430, loopStart = 0.5, volume = 1, name = "Strangetown Prototype" })

-- Add custom sound into the select star sound effect
_G.tsjSongs.addSelectStarSound('SAMPLE_STAR_SELECT_SIMS', audio_sample_load('star_select_sims.ogg'))
_G.tsjSongs.setSelectStarSound('SAMPLE_STAR_SELECT_SIMS')

-- Add custom sound into the mario lose sound effect (Beta)
_G.tsjSongs.addLoseSound('SAMPLE_LOSE', audio_sample_load('lose.ogg'))
_G.tsjSongs.setLoseSound('SAMPLE_LOSE')

```

### Coming Soon
Songs for each type of power up.

The song calms down when the mario sleeps.

Test the plant sleep theme moment.

Test in boss battle.