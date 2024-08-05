---@diagnostic disable: param-type-mismatch
-- Credits to _6b by the original code
-- https://mods.sm64coopdx.com/members/_6b.207/

-- This is an super edited version of the code by JasminDreasond. The code was rewritten to behave like an API.

--Don't know what course ID to put for a map? No worries. Just turn this to true, and the pause menu will show the course number in the corner.
--Feel free to turn this off if (you don't want to show the music name in the pause menu
local pauseMenuShouldShowSongData = true
local pauseMenuMusicRGBA = { 200, 200, 200, 255 }

--Below here is just a bunch of internal stuff.
local curMap = -1
local audioMainPaused = false

local audioMain = nil    -- Used for the main audio
local audioSpecial = nil -- Used for things like cap music
local sampleSelectStarSound = nil -- Used for the select star audio
local sampleLoseSound = nil -- Used for the mario die time

local audioCurSeq = nil
local marioIndex = 0

_G.tsjSongs = {}

--- @class TinySongBgms
--- @field public audio string
--- @field public name string
--- @field public loopEnd number
--- @field public loopStart number
--- @field public volume number

--- @type TinySongBgms
local bgms = {}
local streams = {}
local streamsStar = {}
local streamsLose = {}

-- Registers the select star sound
--- @param id string
function tsjSongs.addSelectStarSound(id, stream)
	streamsStar[id] = stream
end

function tsjSongs.setSelectStarSound(id)
	sampleSelectStarSound = streamsStar[id]
end

-- Registers the mario die sound
--- @param id string
function tsjSongs.addLoseSound(id, stream)
	streamsLose[id] = stream
end

function tsjSongs.setLoseSound(id)
	sampleLoseSound = streamsLose[id]
end

-- Registers a new song
--- @param id string | number | integer
--- @param data ObjectList
function tsjSongs.addSong(id, stream, data)
	bgms[id] = data
---@diagnostic disable-next-line: undefined-field
	streams[id] = stream
end

-- Load the song
---@param index number
function tsjSongs.loadSong(index)
	if (audioMain == nil) then
		audioMain = streams[index]
		if (audioMain ~= nil) then
			audio_stream_set_looping(audioMain, true)
			audio_stream_play(audioMain, true, bgms[index].volume)
		else
			djui_popup_create('Missing audio!: ' .. bgms[curMap].audio, 10)
			print("Attempted to load filed audio file, but couldn't find it on the system: " .. bgms[curMap].audio)
		end
	end
end

-- Stop the song
function tsjSongs.stopSong()
	if (audioMain ~= nil) then
		audio_stream_stop(audioMain)
		audioMain = nil
	end
end

-- Load the special song
---@param index number
function tsjSongs.loadSpecialSong(index)
	if (audioSpecial == nil) then
		audioSpecial = streams[index]
		if (audioSpecial ~= nil) then
			audio_stream_set_looping(audioSpecial, true)
			audio_stream_play(audioSpecial, true, bgms[index].volume)
		else
			djui_popup_create('Missing audio!: ' .. bgms[curMap].audio, 10)
			print("Attempted to load filed audio file, but couldn't find it on the system: " .. bgms[curMap].audio)
		end
	end
end

-- Stop the special song
function tsjSongs.stopSpecialSong()
	if (audioSpecial ~= nil) then
		audio_stream_stop(audioSpecial)
		audioSpecial = nil

		if (audioMain ~= nil and audioMainPaused == true) then
			audioMainPaused = false
			audio_stream_play(audioMain, false, bgms[curMap].volume)
		else
			set_background_music(0, audioCurSeq, 10)
		end
	end
end

local function handleMusic()
	------------------------------------------------------
	--          Selec start music                       --
	------------------------------------------------------
	if sampleSelectStarSound ~= nil and get_current_background_music() == SEQ_MENU_STAR_SELECT then
		stop_background_music(SEQ_MENU_STAR_SELECT)
		audio_sample_play(sampleSelectStarSound, gMarioStates[0].marioObj.header.gfx.cameraToObject, 2)
    end
	------------------------------------------------------
	--          Handle stopping/starting of music       --
	------------------------------------------------------
	--Handle main course music
	if (curMap ~= gNetworkPlayers[marioIndex].currLevelNum and gMarioStates[marioIndex].area.macroObjects ~= nil) then
		curMap = gNetworkPlayers[marioIndex].currLevelNum
		audioCurSeq = get_current_background_music()
		tsjSongs.stopSong()
		if (bgms[curMap] ~= nil and bgms[curMap].audio ~= nil) then
			set_background_music(0, 0, 0)
			tsjSongs.loadSong(curMap)
		else
			print("No audio for this map, so not stopping default: " .. curMap)
		end
	end

	--Handle cap music
	if (gMarioStates[marioIndex].capTimer > 0 and bgms[-2] ~= nil) then
		--Handle pausing main streamed music, if applicable.
		if (audioMain ~= nil and audioMainPaused == false) then
			audioMainPaused = true
			audio_stream_pause(audioMain)
		end
		--Start up cap music if it's defined.
		if (audioSpecial == nil) then
			set_background_music(0, 0, 0)
			stop_cap_music()
			tsjSongs.loadSpecialSong(-2)
		end
	else
		tsjSongs.stopSpecialSong()
	end

	------------------------------------------------------
	--                Handle music looping              --
	------------------------------------------------------
	if (audioMain ~= nil and audioMain.loaded) then
		local curPosition = audio_stream_get_position(audioMain)
		if (curPosition >= bgms[curMap].loopEnd) then
			local minus = bgms[curMap].loopStart - bgms[curMap].loopEnd
			audio_stream_set_position(audioMain, curPosition - math.abs(minus))
		end
	end
	if (audioSpecial ~= nil) then
		local curPosition = audio_stream_get_position(audioSpecial)
		if (curPosition >= bgms[-2].loopEnd) then
			local minus = bgms[-2].loopStart - bgms[-2].loopEnd
			audio_stream_set_position(audioSpecial, curPosition - math.abs(minus))
		end
	end
end

local function hud_render()
	if (pauseMenuShouldShowSongData == true and is_game_paused()) then
		djui_hud_set_resolution(RESOLUTION_DJUI);
		djui_hud_set_font(FONT_NORMAL);

		local screenHeight = djui_hud_get_screen_height()
		local height = 64
		local y = screenHeight - height
		local x = 30
		local scale = 1

		djui_hud_set_color(pauseMenuMusicRGBA[1], pauseMenuMusicRGBA[2], pauseMenuMusicRGBA[3], pauseMenuMusicRGBA[4]);
		djui_hud_print_text("Level ID: " .. gNetworkPlayers[0].currLevelNum, x, y, scale);

		if (audioMain ~= nil) then
			djui_hud_print_text("Song: " .. bgms[curMap].name, x, y - 30, scale);
			djui_hud_print_text("Song loaded: " .. tostring(audioMain.loaded), x, y - 60, scale);
		end

		if (audioSpecial ~= nil) then
			djui_hud_print_text("Special Song: " .. bgms[-2].name, x, y - 90, scale);
			djui_hud_print_text("Special Song loaded: " .. tostring(audioSpecial.loaded), x, y - 120, scale);
		end
	end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_UPDATE, handleMusic)


local deathTable = {
	[ACT_DEATH_ON_STOMACH] = true,
	[ACT_DEATH_ON_BACK] = true,
	[ACT_EATEN_BY_BUBBA] = true,
	[ACT_SUFFOCATION] = true,
	[ACT_STANDING_DEATH] = true,
	[ACT_QUICKSAND_DEATH] = true,
	[ACT_DROWNING] = true,
}

local function on_set_mario_action(m)
	if sampleLoseSound ~= nil and deathTable[m.action] then
			audio_sample_play(sampleLoseSound, {x = 0, y = 0, z = 0}, 2)
	end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)
-----------------------------------------------------------------------------
--                           Music Mod End                                 --
-----------------------------------------------------------------------------

------------------------------------------------------
--                Debug commands                    --
------------------------------------------------------
local function song_debug_command(msg)
	if msg == "on" then
		djui_chat_message_create("Song Debug: enabled")
		pauseMenuShouldShowSongData = true
		return true
	elseif msg == "off" then
		djui_chat_message_create("Song Debug: disabled")
		pauseMenuShouldShowSongData = false
		return true
	end
	return false
end

hook_chat_command("songdebug", "[on|off] ", song_debug_command)
