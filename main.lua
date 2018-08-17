-----------------------------------------------------------------------------------------
-- ABSTRACT - CRAZY CHIBI WALL JUMP
-- CREATED BY PICKION GAMES
-- HTTP://PICKLEANDONIONS.COM/

-- VERSION - 1.0
-- 
-- COPYRIGHT (C) 2014 PICKLE & ONIONS. ALL RIGHTS RESERVED.
-----------------------------------------------------------------------------------------
-- Initial Settings
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

display.setDefault("background", 1, 1, 1, 1)

local storyboard = require( "storyboard" )
storyboard.purgeOnSceneChange = true --So storyboard automatically purges for us.

connection = require("testconnection")
local gameNetwork = require("gameNetwork")
local loadsave = require("loadsave")

math.randomseed( os.time() )
math.random()
math.random()

_G.soundAllowed = true
_G.songAllowed = true
_G.isAdsAllowed = true

--Our global play sound function.
local sounds = {}
sounds["music"] = audio.loadStream("sounds/AquaticCircus.wav")
sounds["click"] = audio.loadSound("sounds/click.wav")
sounds["crash"] = audio.loadSound("sounds/scifiSplat.wav")
sounds["score"] = audio.loadSound("sounds/scored.wav")
sounds["jump"] = audio.loadSound("sounds/jump.wav")
audio.setVolume(0.1, {channel = 1})
audio.setVolume(1, {channel = 2})
audio.setVolume(0.2, {channel = 3})
audio.setVolume(1, {channel = 4})
audio.setVolume(0.2, {channel = 5})
function playSound(name) --Just pass a name to it. e.g. "select"
	if name == "music" then
		audio.stop(1)
		audio.play(sounds["music"], {channel=1, loops=-1})
	elseif name == "click" then
		audio.stop(2)
		audio.play(sounds["click"], {channel=2})
	elseif name == "crash" then
		audio.stop(3)
		audio.play(sounds["crash"], {channel=3})
	elseif name == "score" then
		audio.stop(4)
		audio.play(sounds["score"], {channel=4})
	elseif name == "jump" then
		audio.stop(5)
		audio.play(sounds["jump"], {channel=5})
	end
end

-- Set up global variables
customFont = "RoundsBlack" -- font name
if system.getInfo("platformName") == "Android" then
	customFont = "RoundsBlack"
end

local fbAppID = "xxxxxxxxxxxxxx"  --replace with your Facebook App ID

local AdMob = require("ads")
local adMobId = "xxxxxxxxxxxxxx" --replace with AdMob ID here
local adMobIdInter = "xxxxxxxxxxxxxx" --replace with AdMob ID here
local adMobListener = function(event) print("ADMOB AD - Event: " .. event.response) end
AdMob.init( "admob", adMobId, adMobListener )

function showAdMobbAd(position)
	if (connection.test()) then
		if isAdsAllowed then
			hideAdMobAd()
			AdMob.show( "banner", {x=0, y=position})
			print("showing banner ad")
		end
	end
end

-- put showAdMobbAdInter() in the location I want to have a pop up ad show.
function showAdMobbAdInter( event )
	if (connection.test()) then
		if isAdsAllowed then
			hideAdMobAd()
			AdMob.show( "interstitial", {testMode=false, appId=adMobIdInter} )
			print("showing popup ad")
		end
	end
end

function hideAdMobAd()
	AdMob.hide()
end

function requestCallback( event )
	if event.type == "setHighScore" then
		local function alertCompletion() gameNetwork.request( "loadScores", { leaderboard={ category="CrazyChibiHighScores", playerScope="Global", timeScope="AllTime", range={1,25} }, listener=requestCallback } ); end
--			native.showAlert( "High Score Reported!", "", { "OK" }, alertCompletion )
	end
end

function initCallback( event )
	if event.type == "showSignIn" then
	elseif event.data then
		loggedIntoGC = true
		native.showAlert( "Success!", "", { "OK" } )
	end
end

function offlineAlert() 
	native.showAlert( "GameCenter Offline", "Please Sign In To Submit Your Score.", { "OK" } )
end

function onSystemEvent(event)
	if ( event.type == "applicationStart" ) then
		gameNetwork.init( "gamecenter", { listener=initCallback } )
		print("Game Center Initiated.")
		return true
	end
end

function checkIfDataExists()
	if gameData.gameHighScore == nil 	then gameData.gameHighScore = 0 	else print("Data Already Exists, No Table Created.") end
	if gameData.gamePlayCount == nil 	then gameData.gamePlayCount = 0		else end
end

gameData = loadsave.loadTable("dataFile01.json")

if gameData == nil then
	gameData = {}
	loadsave.saveTable(gameData, "dataFile01.json")
	print("Game Data Nil So Create Game Data.")
else
	print("Game Data Not Nil.")
end

checkIfDataExists()
Runtime:addEventListener("system", onSystemEvent)

-- Now change scene to go to the menu.
storyboard.gotoScene( "menu", "crossFade", 500 )