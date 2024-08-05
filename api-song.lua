---@diagnostic disable: param-type-mismatch
-- Credits to _6b by the original code
-- https://mods.sm64coopdx.com/members/_6b.207/

-- This is an super edited version of the code by JasminDreasond. The code was rewritten to behave like an API.

--Don't know what course ID to put for a map? No worries. Just turn this to true, and the pause menu will show the course number in the corner.
--Feel free to turn this off if (you don't want to show the music name in the pause menu
local pauseMenuShouldShowSongData = false
local pauseMenuMusicRGBA = { 200, 200, 200, 255 }

--Below here is just a bunch of internal stuff.
local curMap = -1
local curAreaSeqId = -1
local curCourseNum = -1
local curActNum = -1
local curAreaIndex = -1

local audioMainPaused = false
local forceStopGameSongs = false
local stopSongOnSelectStars = false

local activeMainId = nil
local audioMain = nil
-- Used for the main audio
local audioSpecial = nil          -- Used for things like cap music
local sampleSelectStarSound = nil -- Used for the select star audio
local sampleLoseSound = nil       -- Used for the mario die time


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

-- Set if it forces to stop all the original songs of the game.
--- @param value boolean
function tsjSongs.setForceStopGameSongs(value)
	forceStopGameSongs = value
end

-- Set if it forces to stop all the original songs of the select star screen.
--- @param value boolean
function tsjSongs.setStopSongOnSelectStars(value)
	stopSongOnSelectStars = value
end

-- Registers a new song
--- @param id string | number | integer
--- @param data ObjectList
function tsjSongs.addSong(id, stream, data)
	bgms[id] = data
	---@diagnostic disable-next-line: undefined-field
	streams[id] = stream
end

-- Registers a new sub song
--- @param id string | number | integer
--- @param areaIndex string | number | integer
--- @param actNum string | number | integer
--- @param courseNum string | number | integer
--- @param areaSeqId string | number | integer
--- @param data ObjectList
function tsjSongs.addSubSong(id, areaIndex, actNum, courseNum, areaSeqId, stream, data)
	local superId = tostring(id) ..
		"-" .. tostring(areaIndex) "-" .. tostring(actNum) "-" .. tostring(courseNum) "-" .. tostring(areaSeqId)
	bgms[superId] = data
	---@diagnostic disable-next-line: undefined-field
	streams[superId] = stream
end

-- Load the song
---@param index number
function tsjSongs.loadSong(index)
	if (audioMain == nil) then
		audioMain = streams[index]
		if (audioMain ~= nil) then
			audio_stream_set_looping(audioMain, true)
			audio_stream_play(audioMain, true, bgms[index].volume)
			activeMainId = index
		else
			djui_popup_create('Missing audio!: ' .. bgms[index].name, 10)
			print("Attempted to load filed audio file, but couldn't find it on the system: " .. bgms[index].name)
			activeMainId = nil
		end
	end
end

-- Stop the song
function tsjSongs.stopSong()
	if (audioMain ~= nil) then
		audio_stream_stop(audioMain)
		audioMain = nil
		activeMainId = nil
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
			djui_popup_create('Missing audio!: ' .. bgms[index].name, 10)
			print("Attempted to load filed audio file, but couldn't find it on the system: " .. bgms[index].name)
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
			audio_stream_play(audioMain, false, bgms[activeMainId].volume)
		else
			set_background_music(0, audioCurSeq, 10)
		end
	end
end

local function handleMusic()
	------------------------------------------------------
	--          Force stop game songs                   --
	------------------------------------------------------
	if forceStopGameSongs then
		for i = 0, 38, 1 do
			stop_background_music(SEQ_LEVEL_INSIDE_CASTLE)
			stop_background_music(SEQ_LEVEL_GRASS)
			stop_background_music(SEQ_EVENT_BOSS)
			stop_background_music(SEQ_EVENT_POWERUP)
			stop_background_music(SEQ_EVENT_METAL_CAP)
			stop_background_music(SEQ_EVENT_RACE)
			stop_background_music(SEQ_LEVEL_SLIDE)
			stop_background_music(SEQ_LEVEL_SNOW)
			stop_background_music(SEQ_LEVEL_KOOPA_ROAD)
			stop_background_music(SEQ_LEVEL_BOSS_KOOPA_FINAL)
			stop_background_music(SEQ_LEVEL_HOT)
			stop_background_music(SEQ_LEVEL_SPOOKY)
			stop_background_music(SEQ_LEVEL_WATER)
			stop_background_music(SEQ_LEVEL_BOSS_KOOPA)
			stop_background_music(SEQ_LEVEL_UNDERGROUND)
			stop_background_music(SEQ_LEVEL_BOSS_KOOPA_FINAL)
		end
	end

	------------------------------------------------------
	--          Selec start music                       --
	------------------------------------------------------
	if sampleSelectStarSound ~= nil and get_current_background_music() == SEQ_MENU_STAR_SELECT then
		stop_background_music(SEQ_MENU_STAR_SELECT)
		if (stopSongOnSelectStars) then
			tsjSongs.stopSpecialSong()
			tsjSongs.stopSong()
		end
		audio_sample_play(sampleSelectStarSound, gMarioStates[0].marioObj.header.gfx.cameraToObject, 2)
	end
	------------------------------------------------------
	--          Handle stopping/starting of music       --
	------------------------------------------------------
	--Handle main course music
	local newIndex = nil
	local needChangeSong = false
	local needPrepareChangeSong = false

	-- Check curMap
	if (gMarioStates[marioIndex].area.macroObjects ~= nil) then
		if (curMap ~= gNetworkPlayers[marioIndex].currLevelNum) then
			curMap = gNetworkPlayers[marioIndex].currLevelNum
			newIndex = curMap
			needChangeSong = true
		end

		-- Check areaSqId
		if (curAreaSeqId ~= gNetworkPlayers[marioIndex].currLevelAreaSeqId) then
			curAreaSeqId = gNetworkPlayers[marioIndex].currLevelAreaSeqId
			needPrepareChangeSong = true
		end

		-- Check curseNumber
		if (curCourseNum ~= gNetworkPlayers[marioIndex].currCourseNum) then
			curCourseNum = gNetworkPlayers[marioIndex].currCourseNum
			needPrepareChangeSong = true
		end

		-- Check actNum
		if (curActNum ~= gNetworkPlayers[marioIndex].currActNum) then
			curActNum = gNetworkPlayers[marioIndex].currActNum
			needPrepareChangeSong = true
		end

		-- Check areaIndex
		if (curAreaIndex ~= gNetworkPlayers[marioIndex].currAreaIndex) then
			curAreaIndex = gNetworkPlayers[marioIndex].currAreaIndex
			needPrepareChangeSong = true
		end
	end

	-- Exist sub song?
	if (needPrepareChangeSong) then
		local superId = tostring(curMap) ..
			"-" ..
			tostring(curAreaSeqId) ..
			"-" .. tostring(curCourseNum) .. "-" .. tostring(curActNum) .. "-" .. tostring(curAreaIndex)
		if (superId ~= activeMainId) then
			if (bgms[superId] ~= nil and bgms[superId].name ~= nil) then
				newIndex = superId
				needChangeSong = true
			elseif (curMap ~= activeMainId) then
				newIndex = curMap
				needChangeSong = true
			end
		end
	end

	-- Request new song
	if (needChangeSong) then
		audioCurSeq = get_current_background_music()
		tsjSongs.stopSong()
		if (bgms[newIndex] ~= nil and bgms[newIndex].name ~= nil) then
			set_background_music(0, 0, 0)
			tsjSongs.loadSong(newIndex)
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
		if (curPosition >= bgms[activeMainId].loopEnd) then
			local minus = bgms[activeMainId].loopStart - bgms[activeMainId].loopEnd
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
		djui_hud_print_text("Tiny Script - Song API", x, y, scale);
		djui_hud_print_text("Level ID: " .. curMap, x, y - 30, scale);
		djui_hud_print_text("Level  Area Seq ID: " .. curAreaSeqId, x, y - 60, scale);
		djui_hud_print_text("Course Number: " .. curCourseNum, x, y - 90, scale);
		djui_hud_print_text("Current Act Number: " .. curActNum, x, y - 120, scale);
		djui_hud_print_text("Current Area Index: " .. curAreaIndex, x, y - 150, scale);

		if (audioMain ~= nil) then
			djui_hud_print_text("Song: " .. bgms[activeMainId].name, x, y - 180, scale);
			djui_hud_print_text("Song loaded: " .. tostring(audioMain.loaded), x, y - 210, scale);
		end

		if (audioSpecial ~= nil) then
			djui_hud_print_text("Special Song: " .. bgms[-2].name, x, y - 240, scale);
			djui_hud_print_text("Special Song loaded: " .. tostring(audioSpecial.loaded), x, y - 270, scale);
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
		audio_sample_play(sampleLoseSound, { x = 0, y = 0, z = 0 }, 2)
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

hook_chat_command("lvlinfodebug", "[on|off] ", song_debug_command)
