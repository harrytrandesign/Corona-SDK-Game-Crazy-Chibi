-----------------------------------------------------------------------------------------
-- ABSTRACT - CRAZY CHIBI WALL JUMP
-- CREATED BY PICKION GAMES
-- HTTP://PICKLEANDONIONS.COM/

-- VERSION - 1.0
-- 
-- COPYRIGHT (C) 2014 PICKLE & ONIONS. ALL RIGHTS RESERVED.
-----------------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-----------------------------------------------
--*** Set up our variables and group ***
-----------------------------------------------

--	CONSTANT VARIABLES
local _W = display.contentWidth
local _H = display.contentHeight
local screenLeft = display.screenOriginX
local screenWidth = display.contentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.contentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local mSin = math.sin
local mAtan2 = math.atan2
local mPi = math.pi 
local mRand = math.random
local mCeil = math.ceil
local mSqrt = math.sqrt
local mPow = math.pow

--	COLOR PALETTE
local colorFontDark =			{R = 12/255,	G = 3/255,		B = 4/255,		A = 255/255}
local colorBlueFillerFront =	{R = 192/255,	G = 216/255,	B = 216/255,	A = 255/255}
local colorMiscStuff =			{R = 0/255,		G = 0/255,		B = 0/255,		A = 255/255}

-- Display Groups
local menuGroup
local menuUiGroup

-- Functions
local createMenu
local menuButtonIndex
local soundsSongsMusicToggle

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
	local mainMenuGroup = self.view

	menuDecorGroup = display.newGroup();										mainMenuGroup:insert(menuDecorGroup)
	menuUiGroup = display.newGroup();											mainMenuGroup:insert(menuUiGroup)

	function createMenu()
		menuDecorBackground = display.newRect(menuDecorGroup, 0, 0, screenWidth, screenHeight)
		menuDecorBackground:setFillColor(colorBlueFillerFront.R, colorBlueFillerFront.G, colorBlueFillerFront.B, colorBlueFillerFront.A)
		menuDecorBackground.anchorX = 0.5;										menuDecorBackground.x = centerX;
		menuDecorBackground.anchorY = 0.5;										menuDecorBackground.y = centerY;

		menuGameLogo = display.newImageRect(menuUiGroup, "images/graphics/gameLogoChibi.png", 300, 150)
		menuGameLogo.anchorX = 0.5;												menuGameLogo.x = centerX;
		menuGameLogo.anchorY = 0.5;												menuGameLogo.y = centerY - 100;

		menuButtonPlay = display.newImageRect(menuUiGroup, "images/buttons/brownButtonPlay.png", 120, 120)
		menuButtonPlay.xScale = 0.5;											menuButtonPlay.yScale = 0.5;
		menuButtonPlay.anchorX = 0.5;											menuButtonPlay.x = centerX;
		menuButtonPlay.anchorY = 0.5;											menuButtonPlay.y = centerY + 40;
		menuButtonPlay.myLabel = "play"

		menuButtonTwitterFollow = display.newImageRect(menuUiGroup, "images/buttons/brownButtonTwitter.png", 80, 80)
		menuButtonTwitterFollow.xScale = 0.5;									menuButtonTwitterFollow.yScale = 0.5;
		menuButtonTwitterFollow.anchorX = 1;									menuButtonTwitterFollow.x = centerX - 10;
		menuButtonTwitterFollow.anchorY = 0;									menuButtonTwitterFollow.y = centerY + 100;
		menuButtonTwitterFollow.myLabel = "twitter"

		menuButtonFacebookLike = display.newImageRect(menuUiGroup, "images/buttons/brownButtonFacebook.png", 80, 80)
		menuButtonFacebookLike.xScale = 0.5;									menuButtonFacebookLike.yScale = 0.5;
		menuButtonFacebookLike.anchorX = 1;										menuButtonFacebookLike.x = centerX - 70;
		menuButtonFacebookLike.anchorY = 0;										menuButtonFacebookLike.y = centerY + 100;
		menuButtonFacebookLike.myLabel = "facebook"

		if soundAllowed then
			menuButtonSoundAdjust = display.newImageRect(menuUiGroup, "images/buttons/brownButtonSoundOn.png", 80, 80)
		else
			menuButtonSoundAdjust = display.newImageRect(menuUiGroup, "images/buttons/brownButtonSoundOff.png", 80, 80)
		end
			menuButtonSoundAdjust.xScale = 0.5;										menuButtonSoundAdjust.yScale = 0.5;
			menuButtonSoundAdjust.anchorX = 0;										menuButtonSoundAdjust.x = centerX + 10;
			menuButtonSoundAdjust.anchorY = 0;										menuButtonSoundAdjust.y = centerY + 100;
			menuButtonSoundAdjust.myLabel = "sound"

		if songAllowed then
			menuButtonMusicAdjust = display.newImageRect(menuUiGroup, "images/buttons/brownButtonMusicOn.png", 80, 80)
		else
			menuButtonMusicAdjust = display.newImageRect(menuUiGroup, "images/buttons/brownButtonMusicOff.png", 80, 80)
		end
			menuButtonMusicAdjust.xScale = 0.5;										menuButtonMusicAdjust.yScale = 0.5;
			menuButtonMusicAdjust.anchorX = 0;										menuButtonMusicAdjust.x = centerX + 70;
			menuButtonMusicAdjust.anchorY = 0;										menuButtonMusicAdjust.y = centerY + 100;
			menuButtonMusicAdjust.myLabel = "music"

		menuButtonShowCredits = display.newImageRect(menuUiGroup, "images/buttons/brownButtonCredit.png", 80, 80)
		menuButtonShowCredits.xScale = 0.5;										menuButtonShowCredits.yScale = 0.5;
		menuButtonShowCredits.anchorX = 1;										menuButtonShowCredits.x = screenWidth - 10;
		menuButtonShowCredits.anchorY = 1;										menuButtonShowCredits.y = screenHeight - 10;
		menuButtonShowCredits.myLabel = "credits"

		menuTextGameCount = display.newText(menuUiGroup, "Games Played : " .. gameData.gamePlayCount, 0, 0, customFont, 18 * 2)
		menuTextGameCount:setFillColor(colorFontDark.R, colorFontDark.G, colorFontDark.B, colorFontDark.A)
		menuTextGameCount.xScale = 0.5;											menuTextGameCount.yScale = 0.5;
		menuTextGameCount.anchorX = 0.5;										menuTextGameCount.x = centerX;
		menuTextGameCount.anchorY = 1;											menuTextGameCount.y = screenHeight - 5;

		menuTextHighScore = display.newText(menuUiGroup, "Best Score : " .. gameData.gameHighScore, 0, 0, customFont, 18 * 2)
		menuTextHighScore:setFillColor(colorFontDark.R, colorFontDark.G, colorFontDark.B, colorFontDark.A)
		menuTextHighScore.xScale = 0.5;											menuTextHighScore.yScale = 0.5;
		menuTextHighScore.anchorX = 0.5;										menuTextHighScore.x = centerX;
		menuTextHighScore.anchorY = 1;											menuTextHighScore.y = menuTextGameCount.y - 20;
	end

	createMenu()
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
	-- Completely remove the previous scene/all scenes.
	-- Handy in this case where we want to keep everything simple.
	storyboard.removeAll()

	function menuButtonIndex(event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.alpha = 0.7
		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1

				--Check bounds. If we are in it then click!
				local b = t.contentBounds

				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
					if t.myLabel == "play" then
						hideAdMobAd()
						if soundAllowed then playSound("click") end
						storyboard.gotoScene("game", "crossFade", 500)

					elseif t.myLabel == "twitter" then
						if soundAllowed then playSound("click") end
						system.openURL( "https://twitter.com/pickiongames" )

					elseif t.myLabel == "facebook" then
						if soundAllowed then playSound("click") end
						system.openURL( "https://www.facebook.com/pages/Pickion-Games/497675963658121" )

					elseif t.myLabel == "credits" then
						hideAdMobAd()
						if soundAllowed then playSound("click") end
						storyboard.gotoScene("infoCredit", "crossFade", 500)
					end
					print(t.myLabel, " has been pressed")
				end
			end
		end
		return true
	end

	function soundsSongsMusicToggle(event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true

			if t.myLabel == "music" then
				if songAllowed then
					t:removeSelf()
					t = nil
					songAllowed = false
					audio.stop(1)
					t = display.newImageRect(menuUiGroup, "images/buttons/brownButtonMusicOff.png", 80, 80)
					t.xScale = 0.5;								t.yScale = 0.5;
					t.anchorX = 0;								t.x = centerX + 70;
					t.anchorY = 0;								t.y = centerY + 100;
					t.myLabel = "music"
					t:addEventListener("touch", soundsSongsMusicToggle)
				else
					t:removeSelf()
					t = nil
					songAllowed = true
					if songAllowed then playSound("music") end
					t = display.newImageRect(menuUiGroup, "images/buttons/brownButtonMusicOn.png", 80, 80)
					t.xScale = 0.5;								t.yScale = 0.5;
					t.anchorX = 0;								t.x = centerX + 70;
					t.anchorY = 0;								t.y = centerY + 100;
					t.myLabel = "music"
					t:addEventListener("touch", soundsSongsMusicToggle)
				end

			elseif t.myLabel == "sound" then
				if soundAllowed then
					t:removeSelf()
					t = nil
					soundAllowed = false
					t = display.newImageRect(menuUiGroup, "images/buttons/brownButtonSoundOff.png", 80, 80)
					t.xScale = 0.5;								t.yScale = 0.5;
					t.anchorX = 0;								t.x = centerX + 10;
					t.anchorY = 0;								t.y = centerY + 100;
					t.myLabel = "sound"
					t:addEventListener("touch", soundsSongsMusicToggle)
				else
					t:removeSelf()
					t = nil
					soundAllowed = true
					t = display.newImageRect(menuUiGroup, "images/buttons/brownButtonSoundOn.png", 80, 80)
					t.xScale = 0.5;								t.yScale = 0.5;
					t.anchorX = 0;								t.x = centerX + 10;
					t.anchorY = 0;								t.y = centerY + 100;
					t.myLabel = "sound"
					t:addEventListener("touch", soundsSongsMusicToggle)
				end

			end
			print(t.myLabel, " has been pressed")

		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
			end
		end
		return true
	end

-- Timers and Transitions
showAdMobbAd(0)
if songAllowed then playSound("music") end
menuButtonPlay:addEventListener("touch", menuButtonIndex)
menuButtonTwitterFollow:addEventListener("touch", menuButtonIndex)
menuButtonFacebookLike:addEventListener("touch", menuButtonIndex)
menuButtonShowCredits:addEventListener("touch", menuButtonIndex)
menuButtonSoundAdjust:addEventListener("touch", soundsSongsMusicToggle)
menuButtonMusicAdjust:addEventListener("touch", soundsSongsMusicToggle)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
menuButtonPlay:removeEventListener("touch", menuButtonIndex)
menuButtonTwitterFollow:removeEventListener("touch", menuButtonIndex)
menuButtonFacebookLike:removeEventListener("touch", menuButtonIndex)
menuButtonShowCredits:removeEventListener("touch", menuButtonIndex)
end

--Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	
end

-----------------------------------------------
-- Add the story board event listeners
-----------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene