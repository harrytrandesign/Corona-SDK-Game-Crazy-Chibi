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
local GGTwitter = require("GGTwitter")
local json = require("json")
local physics = require ("physics")	--Require physics
local loadsave = require("loadsave")
local gameNetwork = require("gameNetwork")

local gravityX = 0;
local gravityY = 10;

physics.start()
physics.setGravity(gravityX, gravityY)
physics.setScale(60)
physics.setDrawMode("normal") -- normal hybrid debug
physics.setPositionIterations(16) 
physics.setVelocityIterations(6)
physics.setContinuous( false )

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

local isGameActive = false
local projectileFired = false

--	VARIABLES FOR CONTROL
local gameScore = 0;
local safeyGap = 90;
local heroSpeed = 2;
local branchSpeed = 2;
local obstacleSpeed = 6;

--	COLOR PALETTE
local colorFontlight =			{R = 238/255,	G = 253/255,	B = 210/255,	A = 255/255}
local colorFontDark =			{R = 20/255,	G = 20/255,		B = 20/255,		A = 255/255}
local colorBlueFillerFront =	{R = 192/255,	G = 216/255,	B = 216/255,	A = 255/255}
local colorRedLight =			{R = 188/255,	G = 1/255,		B = 0/255,		A = 255/255}
local colorRedShader =			{R = 149/255,	G = 4/255,		B = 11/255,		A = 255/255}
local colorRedDarkest =			{R = 83/255,	G = 13/255,		B = 13/255,		A = 255/255}
local colorWallDark =			{R = 64/255,	G = 71/255,		B = 73/255,		A = 255/255}
local colorWallShade =			{R = 3/255,		G = 12/255,		B = 34/255,		A = 255/255}
local colorBrownBlastFX = {}
		colorBrownBlastFX[1] =	{R = 79/255,	G = 64/255,		B = 11/255, 	A = 255/255}
		colorBrownBlastFX[2] =	{R = 129/255,	G = 98/255,		B = 25/255,		A = 255/255}
		colorBrownBlastFX[3] =	{R = 85/255,	G = 68/255,		B = 24/255,		A = 255/255}
		colorBrownBlastFX[4] =	{R = 139/255,	G = 125/255,	B = 45/255,		A = 255/255}
local colorFrame =				{R = 20/255,	G = 20/255,		B = 20/255,		A = 255/255}
local colorDisplay =			{R = 235/255,	G = 243/255,	B = 235/255,	A = 255/255}
local colorOrangeInGame =		{R = 255/255,	G = 127/255,	B = 42/255,		A = 255/255}
local colorMiscStuff =			{R = 32/255,	G = 41/255,		B = 63/255,		A = 255/255}
local colorBrownFillerRear =	{R = 156/255,	G = 107/255,	B = 65/255,		A = 255/255}

-- Sprite Sheet Images
local chibiSequenceData = {name = "eyeBlink", start = 1, count = 4, time = 1000}
local chibiSpriteSheet = graphics.newImageSheet("images/graphics/chibiMonkeySpriteSheet.png", {width = 180, height = 180, numFrames = 4, sheetContentWidth = 720, sheetContentHeight = 180})

local heroCollisionFilter = { categoryBits = 1, maskBits = 2 }
local allotherCollisionFilter = { categoryBits = 2, maskBits = 1 }

--	DISPLAY GROUPS
local decorGroup
local enemyGroup
local coinGroup
local blockGroup
local heroGroup
local uiGroup
local endGroup

local blockerTop = {}
local blockerBottom = {}
local bananaCoin = {}
local sideBranch = {}

--	FUNCTIONS LIST
local createStageSetting
local createReadyInstruction
local createPlayerHero
local onSubmitScore
local saveGameData
local updateScore
local checkForNewHighScore
local createBlastEffect
local spawnEnemyBranch
local spawnEnemyObject
local gameOverButtonIndex
local onCollision
local launchHeroAcross
local destroyGameObjects
local gameOverEvent
local gameLoop
local startTheGame
local onSystemEvent

-----------------------------------------------
-- *** STORYBOARD SCENE EVENT FUNCTIONS ***
------------------------------------------------
-- Called when the scene's view does not exist:
-- Create all your display objects here.
function scene:createScene( event )
	local gameGroup = self.view

	decorGroup = display.newGroup();												gameGroup:insert(decorGroup)
	enemyGroup = display.newGroup();												gameGroup:insert(enemyGroup)
	coinGroup = display.newGroup();													gameGroup:insert(coinGroup)
	blockGroup = display.newGroup();												gameGroup:insert(blockGroup)
	heroGroup = display.newGroup();													gameGroup:insert(heroGroup)
	uiGroup = display.newGroup();													gameGroup:insert(uiGroup)
	endGroup = display.newGroup();													gameGroup:insert(endGroup)

	function createStageSetting()
		decorBackground = display.newRect(decorGroup, 0, 0, screenWidth, screenHeight)
		decorBackground:setFillColor(colorBlueFillerFront.R, colorBlueFillerFront.G, colorBlueFillerFront.B, colorBlueFillerFront.A)
		decorBackground.anchorX = 0.5;												decorBackground.x = centerX;
		decorBackground.anchorY = 0.5;												decorBackground.y = centerY;

		------------------------------------------------

		decorLavaGround = display.newRect(decorGroup, 0, 0, screenWidth, screenHeight * 0.1)
		decorLavaGround:setFillColor(colorRedLight.R, colorRedLight.G, colorRedLight.B, colorRedLight.A)
		decorLavaGround.anchorX = 0.5;												decorLavaGround.x = centerX;
		decorLavaGround.anchorY = 1;												decorLavaGround.y = screenHeight;
		decorLavaGround.alpha = 0.5;

		decorLavaShade = display.newRect(decorGroup, 0, 0, screenWidth, screenHeight * 0.07)
		decorLavaShade:setFillColor(colorRedShader.R, colorRedShader.G, colorRedShader.B, colorRedShader.A)
		decorLavaShade.anchorX = 0.5;												decorLavaShade.x = centerX;
		decorLavaShade.anchorY = 1;													decorLavaShade.y = screenHeight;
		decorLavaShade.alpha = 0.5;

		decorLavaFire = display.newRect(decorGroup, 0, 0, screenWidth, screenHeight * 0.04)
		decorLavaFire:setFillColor(colorRedDarkest.R, colorRedDarkest.G, colorRedDarkest.B, colorRedDarkest.A)
		decorLavaFire.anchorX = 0.5;												decorLavaFire.x = centerX;
		decorLavaFire.anchorY = 1;													decorLavaFire.y = screenHeight;
		decorLavaFire.alpha = 0.5;
		decorLavaFire.myLabel = "dangerZones"
		physics.addBody(decorLavaFire, "static", {filter = allotherCollisionFilter})

		decorWallRoofTop = display.newRect(decorGroup, 0, 0, screenWidth, 8)
		decorWallRoofTop:setFillColor(colorBlueFillerFront.R, colorBlueFillerFront.G, colorBlueFillerFront.B, colorBlueFillerFront.A)
		decorWallRoofTop.anchorX = 0.5;												decorWallRoofTop.x = centerX;
		decorWallRoofTop.anchorY = 0.5;												decorWallRoofTop.y = 0;
		physics.addBody(decorWallRoofTop, "static", {bounce = 0.1, filter = allotherCollisionFilter})

		------------------------------------------------

		decorWallLeftShading = display.newRect(decorGroup, 0, 0, 20, screenHeight * 2)
		decorWallLeftShading:setFillColor(colorWallShade.R, colorWallShade.G, colorWallShade.B, colorWallShade.A)
		decorWallLeftShading.anchorX = 0.5;											decorWallLeftShading.x = 0;
		decorWallLeftShading.anchorY = 0.5;											decorWallLeftShading.y = centerY;

		decorWallRightShading = display.newRect(decorGroup, 0, 0, 20, screenHeight * 2)
		decorWallRightShading:setFillColor(colorWallShade.R, colorWallShade.G, colorWallShade.B, colorWallShade.A)
		decorWallRightShading.anchorX = 0.5;										decorWallRightShading.x = screenWidth;
		decorWallRightShading.anchorY = 0.5;										decorWallRightShading.y = centerY;

		decorWallLeftWallBlock = display.newRect(decorGroup, 0, 0, 14, screenHeight * 2)
		decorWallLeftWallBlock:setFillColor(colorWallDark.R, colorWallDark.G, colorWallDark.B, colorWallDark.A)		
		decorWallLeftWallBlock.anchorX = 0.5;										decorWallLeftWallBlock.x = 0;
		decorWallLeftWallBlock.anchorY = 0.5;										decorWallLeftWallBlock.y = centerY;
		decorWallLeftWallBlock.alpha = 0.5;
		decorWallLeftWallBlock.myLabel = "stickyWalls"
		physics.addBody(decorWallLeftWallBlock, "static", {bounce = 0.1, filter = allotherCollisionFilter})

		decorWallRightWallBlock = display.newRect(decorGroup, 0, 0, 14, screenHeight * 2)
		decorWallRightWallBlock:setFillColor(colorWallDark.R, colorWallDark.G, colorWallDark.B, colorWallDark.A)		
		decorWallRightWallBlock.anchorX = 0.5;										decorWallRightWallBlock.x = screenWidth;
		decorWallRightWallBlock.anchorY = 0.5;										decorWallRightWallBlock.y = centerY;
		decorWallRightWallBlock.alpha = 0.5;
		decorWallRightWallBlock.myLabel = "stickyWalls"
		physics.addBody(decorWallRightWallBlock, "static", {bounce = 0.1, filter = allotherCollisionFilter})

		------------------------------------------------

		gameButtonTapLaunch = display.newRect(decorGroup, 0, 0, screenWidth, screenHeight)
		gameButtonTapLaunch:setFillColor(colorMiscStuff.R, colorMiscStuff.G, colorMiscStuff.B, colorMiscStuff.A)
		gameButtonTapLaunch.anchorX = 0.5;											gameButtonTapLaunch.x = centerX;
		gameButtonTapLaunch.anchorY = 0.5;											gameButtonTapLaunch.y = centerY;
		gameButtonTapLaunch.alpha = 0.01;

		------------------------------------------------
		-- SET UP UI INTERFACE SCORE AND HIGH SCORE ----
		------------------------------------------------

		uiTextScore = display.newText(uiGroup, "" .. gameScore, 0, 0, customFont, 64 * 2)
		uiTextScore:setFillColor(colorWallShade.R, colorWallShade.G, colorWallShade.B, colorWallShade.A)		
		uiTextScore.xScale = 0.5;													uiTextScore.yScale = 0.5;
		uiTextScore.anchorX = 0.5;													uiTextScore.x = centerX;
		uiTextScore.anchorY = 0;													uiTextScore.y = 0;
		uiTextScore.isVisible = false;

		uiTextHighScore = display.newText(uiGroup, "High Score: " .. gameData.gameHighScore, 0, 0, customFont, 12 * 2)
		uiTextHighScore:setFillColor(colorFontlight.R, colorFontlight.G, colorFontlight.B, colorFontlight.A)
		uiTextHighScore.xScale = 0.5;												uiTextHighScore.yScale = 0.5;
		uiTextHighScore.anchorX = 0.5;												uiTextHighScore.x = centerX;
		uiTextHighScore.anchorY = 1;												uiTextHighScore.y = screenHeight - 4;
		uiTextHighScore.isVisible = false;

		gameButtonTapLaunch:toFront()
	end

	function createReadyInstruction()
		uiImageiPhoneFrame = display.newRect(uiGroup, 0, 0, 260, 400)
		uiImageiPhoneFrame:setFillColor(colorFrame.R, colorFrame.G, colorFrame.B, colorFrame.A)		
		uiImageiPhoneFrame.anchorX = 0.5;											uiImageiPhoneFrame.x = centerX;
		uiImageiPhoneFrame.anchorY = 0.5;											uiImageiPhoneFrame.y = centerY;

		uiImageiPhoneDisplay = display.newRect(uiGroup, 0, 0, 240, 350)
		uiImageiPhoneDisplay:setFillColor(colorDisplay.R, colorDisplay.G, colorDisplay.B, colorDisplay.A)	
		uiImageiPhoneDisplay.anchorX = 0.5;											uiImageiPhoneDisplay.x = centerX;
		uiImageiPhoneDisplay.anchorY = 0.5;											uiImageiPhoneDisplay.y = centerY - 15;

		uiImageiPhoneHome = display.newRect(uiGroup, 0, 0, 40, 10)
		uiImageiPhoneHome:setFillColor(colorDisplay.R, colorDisplay.G, colorDisplay.B, colorDisplay.A)	
		uiImageiPhoneHome.anchorX = 0.5;											uiImageiPhoneHome.x = centerX;
		uiImageiPhoneHome.anchorY = 0.5;											uiImageiPhoneHome.y = centerY + 180;

		uiImageiPhoneShadow = display.newRect(uiGroup, 0, 0, 130, 400)
		uiImageiPhoneShadow:setFillColor(colorMiscStuff.R, colorMiscStuff.G, colorMiscStuff.B, colorMiscStuff.A)
		uiImageiPhoneShadow.anchorX = 1;											uiImageiPhoneShadow.x = centerX;
		uiImageiPhoneShadow.anchorY = 0.5;											uiImageiPhoneShadow.y = centerY;
		uiImageiPhoneShadow.alpha = 0.03;

		------------------------------------------------

		uiGameInstruction = display.newImageRect(uiGroup, "images/graphics/instructionsHeatMap.png", 240, 350)
		uiGameInstruction.anchorX = 0.5;											uiGameInstruction.x = centerX;
		uiGameInstruction.anchorY = 0.5;											uiGameInstruction.y = centerY - 15;
	end

	function createPlayerHero()
		playerHero = display.newSprite(chibiSpriteSheet, chibiSequenceData)
		playerHero.xScale = 0.2;													playerHero.yScale = 0.2;
		playerHero.anchorX = 0.5;													playerHero.x = 25;
		playerHero.anchorY = 0.5;													playerHero.y = screenHeight * 0.1;
		physics.addBody(playerHero, "dynamic", {density = 10, radius = 14, filter = heroCollisionFilter})
		projectileFired = false
		playerHero.isBullet = true
		playerHero.isBodyActive = false
		playerHero.position = "left";
		playerHero.rotation = 90;
		playerHero.collision = onCollision
		playerHero:addEventListener("collision", playerHero)

		heroGroup:insert(playerHero)

		return playerHero
	end
end

-- Called immediately after scene has moved onscreen:
-- Start timers/transitions etc.
function scene:enterScene( event )
	storyboard.removeAll()

	function onSubmitScore(event) -- NEED TO CHANGE CATEGORY TO THE ONE I SET FOR THIS GAME IN GAME CENTER
		if loggedIntoGC then gameNetwork.request( "setHighScore", { localPlayerScore={ category="UglyFishHighestScore", value=gameData.gameHighScore }, listener=requestCallback } ); else offlineAlert(); end
		print("Score submitted to game center")
	end

	function saveGameData()
		loadsave.saveTable(gameData, "dataFile01.json")
		print("Game data has been saved.")
	end

	function updateScore(amount)
		gameScore = gameScore + amount
		uiTextScore.text = "" .. gameScore
	end

	function checkForNewHighScore()
		if gameScore > gameData.gameHighScore then
			gameData.gameHighScore = gameScore
			onSubmitScore()
			saveGameData()
			uiTextHighScore.text = "High Score: " .. gameData.gameHighScore
			print("The last high score was beat, the new high score is now " .. gameData.gameHighScore)
		end
	end

	function createBlastEffect(params)
		local sparks = {}
		local radius = 100

		for i = 1, 40 do
			local cosCounter = mRand(-10, 10)
			local colorPick = mRand(1, 4)
			local blastSize = mRand(3, 14)

			sparks[i] = display.newCircle(0, 0, blastSize)
			sparks[i]:setFillColor(colorBrownBlastFX[colorPick].R, colorBrownBlastFX[colorPick].G, colorBrownBlastFX[colorPick].B, colorBrownBlastFX[colorPick].A)
			sparks[i].x = params.x or centerX;
			sparks[i].y = params.y or centerY;
			transition.to(sparks[i], {x = math.sin(cosCounter) * radius + params.x, y = math.cos(cosCounter) * radius + params.y, alpha = 0, time = mRand(100, 700), delay = 150, onComplete = function() if sparks[i] then sparks[i]:removeSelf() end end})
		end

		if soundAllowed then playSound("crash") end
		return sparks[i]
	end

	function spawnEnemyBranch()
		local i
		local branchShape = {-26,6, 26,6, 26,-6, -26,-6}

		for i = 1, 1 do
			local randomDiceRoll = mRand(1, 100)

			sideBranch[i] = display.newImageRect("images/graphics/sideBlockCliff.png", 60, 20)
			sideBranch[i].anchorX = 0.5;
			sideBranch[i].anchorY = 0.5;											sideBranch[i].y = -60;
			physics.addBody(sideBranch[i], "static", {filter = allotherCollisionFilter, shape = branchShape})
			sideBranch[i].myLabel = "dangerZones"
			blockGroup:insert(sideBranch[i])
		
			if randomDiceRoll < 50 then			sideBranch[i].xScale = 1;	sideBranch[i].x = 40;
			elseif randomDiceRoll >= 50 then	sideBranch[i].xScale = -1;	sideBranch[i].x = screenWidth - 40; end
			
			return sideBranch[i]
		end
	end

	function spawnEnemyObject()
		local i

		for i = 1, 1 do
			blockerBottom[i] = display.newImageRect("images/graphics/bigBlueSpikeBlock.png", 30, 60)
			blockerBottom[i].anchorX = 0.5;											blockerBottom[i].x = mRand(120, screenWidth - 120)
			blockerBottom[i].anchorY = 0.5;											blockerBottom[i].y = -60;
			physics.addBody(blockerBottom[i], "static", {filter = allotherCollisionFilter})
			blockerBottom[i].myLabel = "dangerZones"

			bananaCoin[i] = display.newImageRect("images/graphics/scoreCoin.png", 80, 80)
			bananaCoin[i].xScale = 0.5;												bananaCoin[i].yScale = 0.5;
			bananaCoin[i].anchorX = 0.5;											bananaCoin[i].x = blockerBottom[i].x;
			bananaCoin[i].anchorY = 0.5;											bananaCoin[i].y = blockerBottom[i].y - safeyGap;
			physics.addBody(bananaCoin[i], "static", {filter = allotherCollisionFilter, isSensor = true})
			bananaCoin[i].myLabel = "fruit"

			blockerTop[i] = display.newImageRect("images/graphics/bigBlueSpikeBlock.png", 30, 60)
			blockerTop[i].anchorX = 0.5;											blockerTop[i].x = blockerBottom[i].x;
			blockerTop[i].anchorY = 0.5;											blockerTop[i].y = bananaCoin[i].y - safeyGap;
			physics.addBody(blockerTop[i], "static", {filter = allotherCollisionFilter})
			blockerTop[i].myLabel = "dangerZones"

			enemyGroup:insert(blockerBottom[i])
			enemyGroup:insert(blockerTop[i])
			coinGroup:insert(bananaCoin[i])

			return blockerBottom[i], bananaCoin[i], blockerTop[i]
		end
	end

	function gameOverButtonIndex(event)
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
						hideAdMobAd()
						if soundAllowed then playSound("click") end
						storyboard.gotoScene("menu", "crossFade", 500)

					elseif t.myLabel == "leaderboard" then
						function onShowBoards( event )
							if loggedIntoGC then gameNetwork.show( "leaderboards", { leaderboard={ category="CrazyChibiHighScores", timeScope="Week" } } ); else offlineAlert(); end
						end

						if soundAllowed then playSound("click") end
						timer.performWithDelay(250, onShowBoards, 1)

					elseif t.myLabel == "twitter" then
						function tw_listener(event)
							if event.phase == "authorised" then
								twitter:post( "omg! that was retardedly hard. Play Crazy Chibi Wall Jump #MyScore is " .. gameScore .. " #Impossible #iOS #iPhone #Pickion #Games https://itunes.apple.com/us/app/id921854188?mt=8" )
							elseif event.phase == "posted" then
								native.showAlert("Twitter", "Thanks for Sharing Your Score.", {"ok"})
							elseif event.phase == "deauthorised" then
								twitter:destroy()
								twitter = nil
							end
						end

						if soundAllowed then playSound("click") end
						twitter = GGTwitter:new( "Ejqf8ltuqwbv0Buz991TerCfG", "1GkgyIgIBGnrjooRX4Ldzu8JkXdpzsQrOiYTLRuY1XSS9sK37D", tw_listener )
						twitter:authorise()

					elseif t.myLabel == "retry" then
						hideAdMobAd()
						if soundAllowed then playSound("click") end

						-- Removing display objects
						if gameOverOuterBox then gameOverOuterBox:removeSelf() gameOverOuterBox = nil end
						if gameOverInnerBox then gameOverInnerBox:removeSelf() gameOverInnerBox = nil end
						if gameOverHeaderTitle then gameOverHeaderTitle:removeSelf() gameOverHeaderTitle = nil end
						if gameOverGameScore then gameOverGameScore:removeSelf() gameOverGameScore = nil end
						if gameOverHighScore then gameOverHighScore:removeSelf() gameOverHighScore = nil end
						if gameOverButtonMenu then gameOverButtonMenu:removeSelf() gameOverButtonMenu = nil end
						if gameOverButtonReplay then gameOverButtonReplay:removeSelf() gameOverButtonReplay = nil end
						if gameOverButtonLeader then gameOverButtonLeader:removeSelf() gameOverButtonLeader = nil end
						if gameOverButtonTwitter then gameOverButtonTwitter:removeSelf() gameOverButtonTwitter = nil end
						if gameOverSoundButton then gameOverSoundButton:removeSelf() gameOverSoundButton = nil end
						if gameOverMusicButton then gameOverMusicButton:removeSelf() gameOverMusicButton = nil end

						gameScore = 0
						uiTextScore.text = "" .. gameScore
				
						createReadyInstruction()

						uiImageiPhoneFrame:addEventListener("touch", startTheGame)
					end
					print(t.myLabel, " has been pressed")
				end
			end
		end
		return true
	end

	function onCollision(self, event)
		local id = event.other.myLabel

		if event.phase == "began" then
			if id == "stickyWalls" then
				--delay function to resolve collision
				local function resolveColl( timerRef )
					if ( timerRef.source.action == "makeJoint" ) then
						weldJoint = physics.newJoint( "weld", self, event.other, self.x, self.y )
					end
					projectileFired = false
					self.isBodyActive = false
					if self.position == "left" then
						self.position = "right"
						self.rotation = -90;
					elseif self.position == "right" then
						self.position = "left"
						self.rotation = 90;
					end
					weldJoint:removeSelf()
				end

				--check if velocity of projectile is sufficient to "stick"
				local vx,vy = self:getLinearVelocity()
				self:setLinearVelocity(0, 0)
				local t = timer.performWithDelay( 10, resolveColl, 1 )
				t.action = "makeJoint"
				print("Stick to the wall.")

			elseif id == "fruit" then
				updateScore(1)
				event.other:removeSelf()
				event.other = nil
				spawnEnemySetTimer = timer.performWithDelay(mRand(600,1500), spawnEnemyObject, 1)
				print("Ate the coin, got a point, spawn a new banana.")
				if soundAllowed then playSound("score") end

			elseif id == "dangerZones" then
				gameButtonTapLaunch:removeEventListener("touch", launchHeroAcross)
				Runtime:removeEventListener("enterFrame", gameLoop)
				createBlastEffect({x = self.x, y = self.y})
				self:removeSelf()
				self = nil
				gameOverTimer = timer.performWithDelay(750, gameOverEvent, 1)
				print("Collided into Object, End the Game.")
			end
		end
		return true
	end

	function launchHeroAcross(event)
		if event.phase == "began" and not projectileFired and playerHero.y >= 120 then
			local px = event.x-playerHero.x
			local py

			if event.y < centerY then py = -22
			elseif event.y >= centerY then py = -17 end

			projectileFired = true
			playerHero.isBodyActive = true
			playerHero:applyLinearImpulse( px/12, py, playerHero.x, playerHero.y )
			playerHero:applyTorque( 40 )

			if soundAllowed then playSound("jump") end
		end
		return true
	end

	function destroyGameObjects()
		for i = enemyGroup.numChildren, 1, -1 do
			local obstacles = enemyGroup[i]
			if obstacles ~= nil then
				obstacles:removeSelf()
				obstacles = nil
			end
		end

		for i = coinGroup.numChildren, 1, -1 do
			local coinPoints = coinGroup[i]
			if coinPoints ~= nil then
				coinPoints:removeSelf()
				coinPoints = nil
			end
		end

		for i = blockGroup.numChildren, 1, -1 do
			local sideEnemy = blockGroup[i]
			if sideEnemy ~= nil then
				sideEnemy:removeSelf()
				sideEnemy = nil
			end
		end
	end

	function gameOverEvent()
		print("Game is Over, Showing Game Over Menu.")
		local function delay() display.getCurrentStage():setFocus(nil) end
		timer.performWithDelay(100, delay, 1)

		showAdMobbAd(0)
		isGameActive = false

		checkForNewHighScore()
		destroyGameObjects()

		if spawnEnemySetTimer ~= nil then timer.cancel(spawnEnemySetTimer) end
		if spawnNewSideObject ~= nil then timer.cancel(spawnNewSideObject) end
		if firstEnemySpawn ~= nil then timer.cancel(firstEnemySpawn) end
		if firstBranchSpawn ~= nil then timer.cancel(firstBranchSpawn) end

		uiTextScore.isVisible = false;
		uiTextHighScore.isVisible = false;

		gameOverOuterBox = display.newRect(endGroup, 0, 0, 278, 422)
		gameOverOuterBox:setFillColor(colorWallDark.R, colorWallDark.G, colorWallDark.B, colorWallDark.A)
		gameOverOuterBox:setStrokeColor(colorWallShade.R, colorWallShade.G, colorWallShade.B, colorWallShade.A)
		gameOverOuterBox.strokeWidth = 3;
		gameOverOuterBox.anchorX = 0.5;											gameOverOuterBox.x = centerX;
		gameOverOuterBox.anchorY = 0.5;											gameOverOuterBox.y = centerY;

		gameOverInnerBox = display.newRect(endGroup, 0, 0, 244, 388)
		gameOverInnerBox:setFillColor(colorDisplay.R, colorDisplay.G, colorDisplay.B, colorDisplay.A)
		gameOverInnerBox.anchorX = 0.5;											gameOverInnerBox.x = centerX;
		gameOverInnerBox.anchorY = 0.5;											gameOverInnerBox.y = centerY;

		gameOverHeaderTitle = display.newText(endGroup, "AGAIN?", 0, 0, customFont, 36 * 2)
		gameOverHeaderTitle:setFillColor(colorMiscStuff.R, colorMiscStuff.G, colorMiscStuff.B, colorMiscStuff.A)
		gameOverHeaderTitle.xScale = 0.5;										gameOverHeaderTitle.yScale = 0.5;
		gameOverHeaderTitle.anchorX = 0.5;										gameOverHeaderTitle.x = centerX;
		gameOverHeaderTitle.anchorY = 0.5;										gameOverHeaderTitle.y = centerY - 140;

		gameOverGameScore = display.newText(endGroup, "Score " .. gameScore, 0, 0, customFont, 24 * 2)
		gameOverGameScore:setFillColor(colorMiscStuff.R, colorMiscStuff.G, colorMiscStuff.B, colorMiscStuff.A)
		gameOverGameScore.xScale = 0.5;											gameOverGameScore.yScale = 0.5;
		gameOverGameScore.anchorX = 0.5;										gameOverGameScore.x = centerX;
		gameOverGameScore.anchorY = 0.5;										gameOverGameScore.y = centerY - 85;

		gameOverHighScore = display.newText(endGroup, "High Score: " .. gameData.gameHighScore, 0, 0, customFont, 14 * 2)
		gameOverHighScore:setFillColor(colorMiscStuff.R, colorMiscStuff.G, colorMiscStuff.B, colorMiscStuff.A)
		gameOverHighScore.xScale = 0.5;											gameOverHighScore.yScale = 0.5;
		gameOverHighScore.anchorX = 0.5;										gameOverHighScore.x = centerX;
		gameOverHighScore.anchorY = 1;											gameOverHighScore.y = centerY + 185;

		gameOverButtonMenu = display.newImageRect(endGroup, "images/buttons/brownButtonMenu.png", 80, 80)
		gameOverButtonMenu.xScale = 0.5;										gameOverButtonMenu.yScale = 0.5;
		gameOverButtonMenu.anchorX = 0.5;										gameOverButtonMenu.x = centerX;
		gameOverButtonMenu.anchorY = 0;											gameOverButtonMenu.y = centerY + 60;
		gameOverButtonMenu.myLabel = "menu"

		gameOverButtonReplay = display.newImageRect(endGroup, "images/buttons/brownButtonReplay.png", 80, 80)
		gameOverButtonReplay.xScale = 0.8;										gameOverButtonReplay.yScale = 0.8;
		gameOverButtonReplay.anchorX = 0.5;										gameOverButtonReplay.x = centerX;
		gameOverButtonReplay.anchorY = 0.5;										gameOverButtonReplay.y = centerY;
		gameOverButtonReplay.myLabel = "retry"

		gameOverButtonLeader = display.newImageRect(endGroup, "images/buttons/brownButtonLeaderboard.png", 80, 80)
		gameOverButtonLeader.xScale = 0.5;										gameOverButtonLeader.yScale = 0.5;
		gameOverButtonLeader.anchorX = 0.5;										gameOverButtonLeader.x = centerX - 68;
		gameOverButtonLeader.anchorY = 0;										gameOverButtonLeader.y = centerY + 60;
		gameOverButtonLeader.myLabel = "leaderboard"

		gameOverButtonTwitter = display.newImageRect(endGroup, "images/buttons/brownButtonTwitter.png", 80, 80)
		gameOverButtonTwitter.xScale = 0.5;										gameOverButtonTwitter.yScale = 0.5;
		gameOverButtonTwitter.anchorX = 0.5;									gameOverButtonTwitter.x = centerX + 68;
		gameOverButtonTwitter.anchorY = 0;										gameOverButtonTwitter.y = centerY + 60;
		gameOverButtonTwitter.myLabel = "twitter"

		function gameOverSoundToggle(event)
			if soundAllowed then
				gameOverSoundButton:removeSelf()
				gameOverSoundButton = nil
				soundAllowed = false
				gameOverSoundButton = display.newImageRect(endGroup, "images/buttons/brownButtonSoundOff.png", 80, 80)
				gameOverSoundButton.xScale = 0.4;								gameOverSoundButton.yScale = 0.4;
				gameOverSoundButton.anchorX = 0.5;								gameOverSoundButton.x = centerX - 30;
				gameOverSoundButton.anchorY = 0;								gameOverSoundButton.y = centerY + 120;
				gameOverSoundButton:addEventListener("tap", gameOverSoundToggle)
			else
				gameOverSoundButton:removeSelf()
				gameOverSoundButton = nil
				soundAllowed = true
				gameOverSoundButton = display.newImageRect(endGroup, "images/buttons/brownButtonSoundOn.png", 80, 80)
				gameOverSoundButton.xScale = 0.4;								gameOverSoundButton.yScale = 0.4;
				gameOverSoundButton.anchorX = 0.5;								gameOverSoundButton.x = centerX - 30;
				gameOverSoundButton.anchorY = 0;								gameOverSoundButton.y = centerY + 120;
				gameOverSoundButton:addEventListener("tap", gameOverSoundToggle)
			end
			return true
		end

		if soundAllowed then
			gameOverSoundButton = display.newImageRect(endGroup, "images/buttons/brownButtonSoundOn.png", 80, 80)
		else
			gameOverSoundButton = display.newImageRect(endGroup, "images/buttons/brownButtonSoundOff.png", 80, 80)
		end
		gameOverSoundButton.xScale = 0.4;										gameOverSoundButton.yScale = 0.4;
		gameOverSoundButton.anchorX = 0.5;										gameOverSoundButton.x = centerX - 30;
		gameOverSoundButton.anchorY = 0;										gameOverSoundButton.y = centerY + 120;
		gameOverSoundButton:addEventListener("tap", gameOverSoundToggle)

		function gameOverMusicToggle(event)
			if songAllowed then
				gameOverMusicButton:removeSelf()
				gameOverMusicButton = nil
				songAllowed = false
				audio.stop(1)
				gameOverMusicButton = display.newImageRect(endGroup, "images/buttons/brownButtonMusicOff.png", 80, 80)
				gameOverMusicButton.xScale = 0.4;								gameOverMusicButton.yScale = 0.4;
				gameOverMusicButton.anchorX = 0.5;								gameOverMusicButton.x = centerX + 30;
				gameOverMusicButton.anchorY = 0;								gameOverMusicButton.y = centerY + 120;
				gameOverMusicButton:addEventListener("tap", gameOverMusicToggle)
			else
				gameOverMusicButton:removeSelf()
				gameOverMusicButton = nil
				songAllowed = true
				if songAllowed then playSound("music") end
				gameOverMusicButton = display.newImageRect(endGroup, "images/buttons/brownButtonMusicOn.png", 80, 80)
				gameOverMusicButton.xScale = 0.4;								gameOverMusicButton.yScale = 0.4;
				gameOverMusicButton.anchorX = 0.5;								gameOverMusicButton.x = centerX + 30;
				gameOverMusicButton.anchorY = 0;								gameOverMusicButton.y = centerY + 120;
				gameOverMusicButton:addEventListener("tap", gameOverMusicToggle)
			end
			return true
		end

		if songAllowed then
			gameOverMusicButton = display.newImageRect(endGroup, "images/buttons/brownButtonMusicOn.png", 80, 80)
		else
			gameOverMusicButton = display.newImageRect(endGroup, "images/buttons/brownButtonMusicOff.png", 80, 80)
		end
		gameOverMusicButton.xScale = 0.4;										gameOverMusicButton.yScale = 0.4;
		gameOverMusicButton.anchorX = 0.5;										gameOverMusicButton.x = centerX + 30;
		gameOverMusicButton.anchorY = 0;										gameOverMusicButton.y = centerY + 120;
		gameOverMusicButton:addEventListener("tap", gameOverMusicToggle)

		gameOverButtonMenu:addEventListener("touch", gameOverButtonIndex)
		gameOverButtonReplay:addEventListener("touch", gameOverButtonIndex)
		gameOverButtonLeader:addEventListener("touch", gameOverButtonIndex)
		gameOverButtonTwitter:addEventListener("touch", gameOverButtonIndex)
	end

	function gameLoop()
		if isGameActive then
			for i = heroGroup.numChildren, 1, -1 do
				local protagonist = heroGroup[i]

				if protagonist ~= nil and protagonist.y ~= nil and protagonist.y <= (screenHeight * 0.96) then
					protagonist:translate(0, heroSpeed)
				else
					gameButtonTapLaunch:removeEventListener("touch", launchHeroAcross)
					Runtime:removeEventListener("enterFrame", gameLoop)
					createBlastEffect({x = protagonist.x, y = protagonist.y})
					protagonist:removeSelf()
					protagonist = nil
					gameOverTimer = timer.performWithDelay(750, gameOverEvent, 1)
					print("Game Over - Player Fell Into the Lava.")
				end
			end

			for i = enemyGroup.numChildren, 1, -1 do
				local obstacles = enemyGroup[i]

				if obstacles ~= nil and obstacles.y ~= nil and obstacles.y <= screenHeight then
					obstacles:translate(0, obstacleSpeed)
				else
					obstacles:removeSelf()
					obstacles = nil
					print("Enemy Objects Reached the Lava - Destroying Obstacle Set.")
				end
			end

			for i = coinGroup.numChildren, 1, -1 do
				local coinPoints = coinGroup[i]

				if coinPoints ~= nil and coinPoints.y ~= nil and coinPoints.y <= screenHeight then
					coinPoints:translate(0, obstacleSpeed)
				else
					coinPoints:removeSelf()
					coinPoints = nil
					spawnEnemySetTimer = timer.performWithDelay(mRand(200,1500), spawnEnemyObject, 1)
					print("Coins Reached the Lava - Destroying Coin - Calling New Enemy Set.")
				end
			end

			for i = blockGroup.numChildren, 1, -1 do
				local sideEnemy = blockGroup[i]

				if sideEnemy ~= nil and sideEnemy.y ~= nil and sideEnemy.y <= screenHeight then
					sideEnemy:translate(0, branchSpeed)
				else
					sideEnemy:removeSelf()
					sideEnemy = nil
					spawnNewSideObject = timer.performWithDelay(mRand(1200,3500), spawnEnemyBranch, 1)
					print("Side Object Reached Lava - Destroy - Call New Side Object.")
				end
			end
		end
	end

	function startTheGame(event)
		local t = event.target

		if event.phase == "began" then 
			display.getCurrentStage():setFocus( t )
			t.isFocus = true
			t.alpha = 0.7
			uiImageiPhoneDisplay.alpha = 0.7
			uiImageiPhoneHome.alpha = 0.7
			uiGameInstruction.alpha = 0.7

		elseif t.isFocus then 
			if event.phase == "ended"  then 
				display.getCurrentStage():setFocus( nil )
				t.isFocus = false
				t.alpha = 1
				uiImageiPhoneDisplay.alpha = 1
				uiImageiPhoneHome.alpha = 1
				uiGameInstruction.alpha = 1

				--Check bounds. If we are in it then click!
				local b = t.contentBounds
				if event.x >= b.xMin and event.x <= b.xMax and event.y >= b.yMin and event.y <= b.yMax then
					hideAdMobAd()
					if soundAllowed then playSound("click") end

					gameData.gamePlayCount = gameData.gamePlayCount + 1
					saveGameData()
					
					uiTextScore.isVisible = true;
					uiTextHighScore.isVisible = true;
					isGameActive = true

					-- Dump all the instructions displayed
					if uiImageiPhoneFrame then uiImageiPhoneFrame:removeSelf(); uiImageiPhoneFrame = nil end
					if uiImageiPhoneDisplay then uiImageiPhoneDisplay:removeSelf(); uiImageiPhoneDisplay = nil end
					if uiImageiPhoneHome then uiImageiPhoneHome:removeSelf(); uiImageiPhoneHome = nil end
					if uiImageiPhoneShadow then uiImageiPhoneShadow:removeSelf(); uiImageiPhoneShadow = nil end
					if uiGameInstruction then uiGameInstruction:removeSelf(); uiGameInstruction = nil end

					-- Call the timers
					createPlayerHero()

					gameButtonTapLaunch:addEventListener("touch", launchHeroAcross)
					firstEnemySpawn = timer.performWithDelay(1000, spawnEnemyObject, 1)
					firstBranchSpawn = timer.performWithDelay(mRand(2500,3500), spawnEnemyBranch, 1)
					Runtime:addEventListener("enterFrame", gameLoop)

					playerHero:setSequence("eyeBlink")
					playerHero:play()
				end
			end
		end
		return true
	end

	function onSystemEvent(event)
		if ( event.type == "applicationOpen" ) then
			checkIfDataExists()
			print("Application Opened.")
		elseif ( event.type == "applicationSuspend" ) then
			saveGameData()
			print("Application Paused.")
		elseif ( event.type == "applicationExit" ) then
			saveGameData()
			print("Application Exited.")
		end
	end

showAdMobbAd(0)
createStageSetting()
createReadyInstruction()
uiImageiPhoneFrame:addEventListener("touch", startTheGame)
Runtime:addEventListener("system", onSystemEvent)
end

-- Called when scene is about to move offscreen:
-- Cancel Timers/Transitions and Runtime Listeners etc.
function scene:exitScene( event )
	if spawnEnemySetTimer ~= nil then timer.cancel(spawnEnemySetTimer) end
	if spawnNewSideObject ~= nil then timer.cancel(spawnNewSideObject) end
	if firstEnemySpawn ~= nil then timer.cancel(firstEnemySpawn) end
	if firstBranchSpawn ~= nil then timer.cancel(firstBranchSpawn) end
	if gameOverTimer ~= nil then timer.cancel(gameOverTimer) end
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