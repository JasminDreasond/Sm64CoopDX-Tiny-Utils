-- name: The Sims 2 NDS & GBA Soundtrack
-- description: Music from \\FFFFFF\\The Sims \\0CFF00\\2 \\808B96\\DS \\FFFFFF\\& \\808B96\\GBA \\FFFFFF\\ \nmod by \\FF0000\\6b.

--This is where streamed audios are defined.
--You can find the Level ID by turning on pauseMenuShowLevelID and going to the area, then pausing.
--'Level ID' -2 is uniquely used for the cap music in this mod as well. So assign audio to -2 to change the cap music.
--The audio file is expected to be under %ThisModFolder%/sound/
--This might sound weird, but SM64ex-coop has a weird issue with filenames that are too similar. So try making the audio files very differently named from eachother.

_G.tsjSongs.setForceStopGameSongs(true)
_G.tsjSongs.setStopSongOnStarSelector(true)

_G.tsjSongs.addSong(-2, audio_stream_load('prototype.ogg'),
	{ loopEnd = 441144, loopStart = 0.5, volume = 1.25, name = "Prototype" })

_G.tsjSongs.addSong(9, audio_stream_load('strangetown.ogg'),
	{ loopEnd = 3175889, loopStart = 0.5, volume = 1, name = "Strangetown" })

_G.tsjSongs.addSong(6, audio_stream_load('strange_day.ogg'),
	{ loopEnd = 5096766, loopStart = 0.5, volume = 1.25, name = "stange_day" })

_G.tsjSongs.addSong(24, audio_stream_load('strangetown_beta.ogg'),
	{ loopEnd = 3175430, loopStart = 0.5, volume = 1, name = "Strangetown Prototype" })

_G.tsjSongs.addSong(27, audio_stream_load('chug-chug_cola.ogg'),
	{ loopEnd = 1638991, loopStart = 0.5, volume = 1.1, name = "Chug-Chug Cola" })

_G.tsjSongs.addSong(18, audio_stream_load('create_sim.ogg'),
	{ loopEnd = 4403606, loopStart = 0.5, volume = 1.25, name = "Create Sim" })

_G.tsjSongs.addSong(29, audio_stream_load('strangetown_beta.ogg'),
	{ loopEnd = 3175430, loopStart = 0.5, volume = 1, name = "Strangetown Prototype (wing cap)" })

_G.tsjSongs.addSong(12, audio_stream_load('walk_the_plank.ogg'),
	{ loopEnd = 3387542, loopStart = 0.5, volume = 1.2, name = "Walk the plank" })

_G.tsjSongs.addSong(23, audio_stream_load('bloom.ogg'),
	{ loopEnd = 3175889, loopStart = 0.5, volume = 1.45, name = "bloom (swim)" })

_G.tsjSongs.addSong(20, audio_stream_load('inverstigate.ogg'),
	{ loopEnd = 5087486, loopStart = 0.5, volume = 1.45, name = "investigate (swim)" })

_G.tsjSongs.addSong(17, audio_stream_load('ratticator.ogg'),
	{ loopEnd = 3763353, loopStart = 0.5, volume = 1.1, name = "Ratticator (bowser 1)" })

_G.tsjSongs.addSong(5, audio_stream_load('friendship.ogg'),
	{ loopEnd = 3024246, loopStart = 0.5, volume = 1, name = "Friendship" })

_G.tsjSongs.addSong(4, audio_stream_load('alien.ogg'),
	{ loopEnd = 1913647, loopStart = 0.5, volume = 1.15, name = "Alien Invasion!" })

_G.tsjSongs.addSong(19, audio_stream_load('heavy_metal.ogg'),
	{ loopEnd = 5096766, loopStart = 0.5, volume = 1.15, name = "Heavy Metal (bowser2)" })

_G.tsjSongs.addSong(22, audio_stream_load('razor_burn.ogg'),
	{ loopEnd = 4182354, loopStart = 0.5, volume = 1.45, name = "investigate (hot)" })

_G.tsjSongs.addSong(8, audio_stream_load('inverstigate.ogg'),
	{ loopEnd = 5087486, loopStart = 0.5, volume = 1.45, name = "investigate (dessert)" })

_G.tsjSongs.addSong(7, audio_stream_load('strange_night.ogg'),
	{ loopEnd = 3256880, loopStart = 0.5, volume = 1.25, name = "strange_night" })

_G.tsjSongs.addSong(28, audio_stream_load('strange_night.ogg'),
	{ loopEnd = 3256880, loopStart = 0.5, volume = 1.25, name = "strange_night" })

_G.tsjSongs.addSong(36, audio_stream_load('moogoo_monkey.ogg'),
	{ loopEnd = 3175430, loopStart = 0.5, volume = 1.15, name = "Moogoo Monkey" })

_G.tsjSongs.addSong(13, audio_stream_load('title.ogg'),
	{ loopEnd = 1355414, loopStart = 0.5, volume = 1.2, name = "The Sims 2 NDS - Title Screen (tiny-big)" })

_G.tsjSongs.addSong(11, audio_stream_load('edge_of_town.ogg'),
	{ loopEnd = 4705021, loopStart = 0.5, volume = 1.25, name = "Edge of Town" })

_G.tsjSongs.addSong(10, audio_stream_load('title.ogg'),
	{ loopEnd = 1355414, loopStart = 0.5, volume = 1.2, name = "The Sims 2 NDS - Title Screen (snow)" })

_G.tsjSongs.addSong(31, audio_stream_load('strangetown_beta.ogg'),
	{ loopEnd = 3175430, loopStart = 0.5, volume = 1, name = "Strangetown Prototype (cloud)" })

_G.tsjSongs.addSong(14, audio_stream_load('bigfoot.ogg'),
	{ loopEnd = 2945832, loopStart = 0.5, volume = 1.2, name = "bigfoot" })

_G.tsjSongs.addSong(15, audio_stream_load('create_sim.ogg'),
	{ loopEnd = 4403606, loopStart = 0.5, volume = 1.25, name = "Create Sim (level-sky)" })

_G.tsjSongs.addSong(21, audio_stream_load('speed_metal.ogg'),
	{ loopEnd = 3848866, loopStart = 0.5, volume = 1.15, name = "Speed Metal (bowser3)" })

_G.tsjSongs.addSelectStarSound('SAMPLE_STAR_SELECT_SIMS', audio_sample_load('star_select_sims.ogg'))
_G.tsjSongs.setSelectStarSound('SAMPLE_STAR_SELECT_SIMS')

_G.tsjSongs.addLoseSound('SAMPLE_LOSE', audio_sample_load('lose.ogg'))
_G.tsjSongs.setLoseSound('SAMPLE_LOSE')
