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
local colorBlueLinks =			{R = 64/255,	G = 71/255,		B = 73/255,		A = 255/255}
local colorBlueTextFont =		{R = 32/255,	G = 41/255,		B = 63/255,		A = 255/255}
local colorBlueFillerFront =	{R = 192/255,	G = 216/255,	B = 216/255,	A = 255/255}

-- Display Groups
local creditGroup

-- Functions
local createCreditScreen
local creditButtonIndex

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
	local creditScreenGroup = self.view

	creditGroup = display.newGroup();										creditScreenGroup:insert(creditGroup)

	function createCreditScreen()
		creditDecorBackground = display.newRect(creditGroup, 0, 0, screenWidth, screenHeight)
		creditDecorBackground:setFillColor(colorBlueFillerFront.R, colorBlueFillerFront.G, colorBlueFillerFront.B, colorBlueFillerFront.A)
		creditDecorBackground.anchorX = 0.5;									creditDecorBackground.x = centerX;
		creditDecorBackground.anchorY = 1;										creditDecorBackground.y = screenHeight;

		creditTextHeaderTitle = display.newText(creditGroup, "CREDITS", 0, 0, customFont, 28 * 2)
		creditTextHeaderTitle:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextHeaderTitle.xScale = 0.5;										creditTextHeaderTitle.yScale = 0.5;
		creditTextHeaderTitle.anchorX = 0.5;									creditTextHeaderTitle.x = centerX;
		creditTextHeaderTitle.anchorY = 0.5;									creditTextHeaderTitle.y = screenHeight * 0.2;

		creditDecorDividerTop = display.newRect(creditGroup, 0, 0, screenWidth * 0.8, 2)
		creditDecorDividerTop:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditDecorDividerTop.anchorX = 0.5;									creditDecorDividerTop.x = centerX;
		creditDecorDividerTop.anchorY = 0.5;									creditDecorDividerTop.y = centerY - 100;

		creditTextCreator = display.newText(creditGroup, "Game Design by Harry Tran", 0, 0, customFont, 14 * 2)
		creditTextCreator:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextCreator.xScale = 0.5;											creditTextCreator.yScale = 0.5;
		creditTextCreator.anchorX = 0.5;										creditTextCreator.x = centerX;
		creditTextCreator.anchorY = 0.5;										creditTextCreator.y = centerY - 60;

		creditTextProgrammer = display.newText(creditGroup, "Programmed by Harry Tran", 0, 0, customFont, 14 * 2)
		creditTextProgrammer:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextProgrammer.xScale = 0.5;										creditTextProgrammer.yScale = 0.5;
		creditTextProgrammer.anchorX = 0.5;										creditTextProgrammer.x = centerX;
		creditTextProgrammer.anchorY = 0.5;										creditTextProgrammer.y = centerY - 40;

		creditTextArtist = display.newText(creditGroup, "Artwork by Harry Tran", 0, 0, customFont, 14 * 2)
		creditTextArtist:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextArtist.xScale = 0.5;											creditTextArtist.yScale = 0.5;
		creditTextArtist.anchorX = 0.5;											creditTextArtist.x = centerX;
		creditTextArtist.anchorY = 0.5;											creditTextArtist.y = centerY - 20;

		creditTextFontDesign = display.newText(creditGroup, "Rounds Black by Jovanny Lemonad", 0, 0, customFont, 14 * 2)
		creditTextFontDesign:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextFontDesign.xScale = 0.5;										creditTextFontDesign.yScale = 0.5;
		creditTextFontDesign.anchorX = 0.5;										creditTextFontDesign.x = centerX;
		creditTextFontDesign.anchorY = 0.5;										creditTextFontDesign.y = centerY;

		creditTextMusicName = display.newText(creditGroup, "Song Name Aquatic Circus", 0, 0, customFont, 14 * 2)
		creditTextMusicName:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextMusicName.xScale = 0.5;										creditTextMusicName.yScale = 0.5;
		creditTextMusicName.anchorX = 0.5;										creditTextMusicName.x = centerX;
		creditTextMusicName.anchorY = 0.5;										creditTextMusicName.y = centerY + 20;

		creditTextMusicCreator = display.newText(creditGroup, "Music Track by PlayOnLoop", 0, 0, customFont, 14 * 2)
		creditTextMusicCreator:setFillColor(colorBlueLinks.R, colorBlueLinks.G, colorBlueLinks.B, colorBlueLinks.A)
		creditTextMusicCreator.xScale = 0.5;									creditTextMusicCreator.yScale = 0.5;
		creditTextMusicCreator.anchorX = 0.5;									creditTextMusicCreator.x = centerX;
		creditTextMusicCreator.anchorY = 0.5;									creditTextMusicCreator.y = centerY + 40;
		creditTextMusicCreator.myLabel = "musicSource"

		creditTextSoundCreator = display.newText(creditGroup, "Sound Effects by NoiseForFun", 0, 0, customFont, 14 * 2)
		creditTextSoundCreator:setFillColor(colorBlueLinks.R, colorBlueLinks.G, colorBlueLinks.B, colorBlueLinks.A)
		creditTextSoundCreator.xScale = 0.5;									creditTextSoundCreator.yScale = 0.5;
		creditTextSoundCreator.anchorX = 0.5;									creditTextSoundCreator.x = centerX;
		creditTextSoundCreator.anchorY = 0.5;									creditTextSoundCreator.y = centerY + 60;
		creditTextSoundCreator.myLabel = "soundSource"

		creditDecorDividerBottom = display.newRect(creditGroup, 0, 0, screenWidth * 0.8, 2)
		creditDecorDividerBottom:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditDecorDividerBottom.anchorX = 0.5;								creditDecorDividerBottom.x = centerX;
		creditDecorDividerBottom.anchorY = 0.5;								creditDecorDividerBottom.y = centerY + 100;

		creditTextPickionSite = display.newText(creditGroup, "http://www.pickleandonions.com/", 0, 0, customFont, 14 * 2)
		creditTextPickionSite:setFillColor(colorBlueLinks.R, colorBlueLinks.G, colorBlueLinks.B, colorBlueLinks.A)
		creditTextPickionSite.xScale = 0.5;									creditTextPickionSite.yScale = 0.5;
		creditTextPickionSite.anchorX = 0.5;								creditTextPickionSite.x = centerX;
		creditTextPickionSite.anchorY = 0.5;								creditTextPickionSite.y = screenHeight * 0.8;
		creditTextPickionSite.myLabel = "ourWebpage"

		creditTextCopyrightLine = display.newText(creditGroup, "© Copyright 2014 Pickion Games", 0, 0, customFont, 14 * 2)
		creditTextCopyrightLine:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextCopyrightLine.xScale = 0.5;								creditTextCopyrightLine.yScale = 0.5;
		creditTextCopyrightLine.anchorX = 0.5;								creditTextCopyrightLine.x = centerX;
		creditTextCopyrightLine.anchorY = 0.5;								creditTextCopyrightLine.y = screenHeight * 0.8 + 20;

		creditTextMiscLine = display.newText(creditGroup, "All Rights Reserved.", 0, 0, customFont, 14 * 2)
		creditTextMiscLine:setFillColor(colorBlueTextFont.R, colorBlueTextFont.G, colorBlueTextFont.B, colorBlueTextFont.A)
		creditTextMiscLine.xScale = 0.5;									creditTextMiscLine.yScale = 0.5;
		creditTextMiscLine.anchorX = 0.5;									creditTextMiscLine.x = centerX;
		creditTextMiscLine.anchorY = 0.5;									creditTextMiscLine.y = screenHeight * 0.8 + 40;

		creditButtonMenu = display.newImageRect(creditGroup, "images/buttons/brownButtonMenu.png", 80, 80)
		creditButtonMenu.xScale = 0.5;										creditButtonMenu.yScale = 0.5;
		creditButtonMenu.anchorX = 1;										creditButtonMenu.x = screenWidth - 10;
		creditButtonMenu.anchorY = 1;										creditButtonMenu.y = screenHeight - 10;
		creditButtonMenu.myLabel = "menu"
	end

	createCreditScreen()
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
	-- Completely remove the previous scene/all scenes.
	-- Handy in this case where we want to keep everything simple.
	storyboard.removeAll()

	function creditButtonIndex(event)
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
					if t.myLabel == "menu" then
						if soundAllowed then playSound("click") end
						storyboard.gotoScene("menu", "crossFade", 500)

					elseif t.myLabel == "musicSource" then
						if soundAllowed then playSound("click") end
						system.openURL( "http://www.playonloop.com/" )

					elseif t.myLabel == "soundSource" then
						if soundAllowed then playSound("click") end
						system.openURL( "http://www.noiseforfun.com/" )

					elseif t.myLabel == "ourWebpage" then
						if soundAllowed then playSound("click") end
						system.openURL( "http://www.pickion.com/" )

					end
					print(t.myLabel, " has been pressed")
				end
			end
		end
		return true
	end

-- Timers and Transitions
creditButtonMenu:addEventListener("touch", creditButtonIndex)
creditTextSoundCreator:addEventListener("touch", creditButtonIndex)
creditTextMusicCreator:addEventListener("touch", creditButtonIndex)
creditTextPickionSite:addEventListener("touch", creditButtonIndex)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
creditButtonMenu:removeEventListener("touch", creditButtonIndex)
creditTextSoundCreator:removeEventListener("touch", creditButtonIndex)
creditTextMusicCreator:removeEventListener("touch", creditButtonIndex)
creditTextPickionSite:removeEventListener("touch", creditButtonIndex)
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