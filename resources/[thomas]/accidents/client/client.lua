ESX	= nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterCommand('accidents', function()

-- The belt
local isUiOpen = false 
local speedBuffer = {}
local velBuffer = {}
local SeatbeltON = false
local InVehicle = false

function Notify(string)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(string)
  DrawNotification(false, true)
end

AddEventHandler('seatbelt:sounds', function(soundFile, soundVolume)
  SendNUIMessage({
    transactionType = 'playSound',
    transactionFile = soundFile,
    transactionVolume = soundVolume
  })
end)

function IsCar(veh)
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end	

function Fwv(entity)
  local hr = GetEntityHeading(entity) + 90.0
  if hr < 0.0 then hr = 360.0 + hr end
  hr = hr * 0.0174533
  return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end
 
Citizen.CreateThread(function()
	while true do
	Citizen.Wait(0)
  
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(ped)

    if car ~= 0 and (InVehicle or IsCar(car)) then
      InVehicle = true
          if isUiOpen == false and not IsPlayerDead(PlayerId()) then
            if Config.Blinker then
              SendNUIMessage({displayWindow = 'true'})
            end
              isUiOpen = true
          end

      if SeatbeltON then 
        DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
        DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
	    end

      speedBuffer[2] = speedBuffer[1]
      speedBuffer[1] = GetEntitySpeed(car)

      if not SeatbeltON and speedBuffer[2] ~= nil and GetEntitySpeedVector(car, true).y > 1.0 and speedBuffer[1] > (Config.Speed / 3.6) and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
        local co = GetEntityCoords(ped)
        local fw = Fwv(ped)
        SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
        SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
        Citizen.Wait(1)
        SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
      end
        
      velBuffer[2] = velBuffer[1]
      velBuffer[1] = GetEntityVelocity(car)
        
      if IsControlJustReleased(0, Config.Control) and GetLastInputMethod(0) then
          SeatbeltON = not SeatbeltON 
          if SeatbeltON then
          Citizen.Wait(1)

            if Config.Sounds then  
            TriggerEvent("seatbelt:sounds", "buckle", Config.Volume)
            end
            if Config.Notification then
            Notify(Config.Strings.seatbelt_on)
            end
            
            if Config.Blinker then
            SendNUIMessage({displayWindow = 'false'})
            end
            isUiOpen = true 
          else 
            if Config.Notification then
            Notify(Config.Strings.seatbelt_off)
            end

            if Config.Sounds then
            TriggerEvent("seatbelt:sounds", "unbuckle", Config.Volume)
            end

            if Config.Blinker then
            SendNUIMessage({displayWindow = 'true'})
            end
            isUiOpen = true  
          end
    end
      
    elseif InVehicle then
      InVehicle = false
      SeatbeltON = false
      speedBuffer[1], speedBuffer[2] = 0.0, 0.0
          if isUiOpen == true and not IsPlayerDead(PlayerId()) then
            if Config.Blinker then
              SendNUIMessage({displayWindow = 'false'})
            end
            isUiOpen = false 
          end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(10)
    local Vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
    local VehSpeed = GetEntitySpeed(Vehicle) * 3.6

    if Config.AlarmOnlySpeed and VehSpeed > Config.AlarmSpeed then
      ShowWindow = true
    else
      ShowWindow = false
      SendNUIMessage({displayWindow = 'false'})
    end

      if IsPlayerDead(PlayerId()) or IsPauseMenuActive() then
        if isUiOpen == true then
          SendNUIMessage({displayWindow = 'false'})
        end
        elseif not SeatbeltON and InVehicle and not IsPauseMenuActive() and not IsPlayerDead(PlayerId()) and Config.Blinker then
          if Config.AlarmOnlySpeed and ShowWindow and VehSpeed > Config.AlarmSpeed then
            SendNUIMessage({displayWindow = 'true'})
          end
      end
  end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(3500)
    if not SeatbeltON and InVehicle and not IsPauseMenuActive() and Config.LoopSound and ShowWindow then
      TriggerEvent("seatbelt:sounds", "seatbelt", Config.Volume)
		end    
	end
end)

-- The accident effects

local effectActive = false            -- Blur screen effect active
local blackOutActive = false          -- Blackout effect active
local currAccidentLevel = 0           -- Level of accident player has effect active of
local wasInCar = false
local oldBodyDamage = 0.0
local oldSpeed = 0.0
local currentDamage = 0.0
local currentSpeed = 0.0
local vehicle
local disableControls = false

IsCar = function(veh)
        local vc = GetVehicleClass(veh)
        return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end 

function note(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

RegisterNetEvent("crashEffect")
AddEventHandler("crashEffect", function(countDown, accidentLevel)

    if not effectActive or (accidentLevel > currAccidentLevel) then
        currAccidentLevel = accidentLevel
        disableControls = true
        effectActive = true
        blackOutActive = true
		DoScreenFadeOut(10)
		Wait(Config.BlackoutTime)
        DoScreenFadeIn(25000)
        blackOutActive = false

        -- Starts screen effect
        StartScreenEffect('PeyoteEndOut', 0, true)
        StartScreenEffect('Dont_tazeme_bro', 0, true)
        StartScreenEffect('MP_race_crash', 0, true)
    
        while countDown > 0 do

            -- Adds screen moving effect while remaining countdown is 3 times the accident level,
            -- In order to stop screen shaking BEFORE the 'blur' effect finishes
            if countDown > (6.5*accidentLevel)   then 
                ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", (accidentLevel * Config.ScreenShakeMultiplier))
            end 
            Wait(900)
--[[             TriggerEvent('chatMessage', "countdown: " .. countDown) -- Debug printout ]]
            
            countDown = countDown - 1

            if countDown < Config.TimeLeftToEnableControls and disableControls then
                disableControls = false
            end
            -- Stops screen effect before countdown finishes
            if countDown <= 1 then
                StopScreenEffect('PeyoteEndOut')
                StopScreenEffect('Dont_tazeme_bro')
                StopScreenEffect('MP_race_crash')
            end
        end
        currAccidentLevel = 0
        effectActive = false
    end
end)




Citizen.CreateThread(function()
	while true do
        Citizen.Wait(10)
        
            -- If the damage changed, see if it went over the threshold and blackout if necesary
            vehicle = GetVehiclePedIsIn(PlayerPedId(-1), false)
            if DoesEntityExist(vehicle) and (wasInCar or IsCar(vehicle)) then
                wasInCar = true
                oldSpeed = currentSpeed
                oldBodyDamage = currentDamage
                currentDamage = GetVehicleBodyHealth(vehicle)
                currentSpeed = GetEntitySpeed(vehicle) * 2.23

                if currentDamage ~= oldBodyDamage then
                    print("crash")
                    if not effect and currentDamage < oldBodyDamage then
                        print("effect")
                        print(oldBodyDamage - currentDamage)
                        if (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel5 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel5
                        then
                            --[[ note("lv5") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel5, 5)
                            --[[ note(oldSpeed - currentSpeed)
                            note(oldBodyDamage - currentDamage) ]]
                            
                            
                            

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel4 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel4
                        then
                            --[[ note("lv4") ]]
                            TriggerEvent("crashEffect", Config.EffectTimeLevel4, 4)
                            oldBodyDamage = currentDamage
                           --[[  note(oldSpeed - currentSpeed)
                            note(oldBodyDamage - currentDamage) ]]
                            
                        

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel3 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel3
                        then   
                            --[[ note(oldSpeed - currentSpeed)
                            note(oldBodyDamage - currentDamage)
                            note("lv3") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel3, 3)
                            
                        

                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel2 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel2
                        then
                            --[[ note(-(oldSpeed - currentSpeed))
                            note(oldBodyDamage - currentDamage)
                            note("lv2") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel2, 2)


                        elseif (oldBodyDamage - currentDamage) >= Config.BlackoutDamageRequiredLevel1 or
                        (oldSpeed - currentSpeed)  >= Config.BlackoutSpeedRequiredLevel1
                        then
                            --[[ note(-(oldSpeed - currentSpeed))
                            note(oldBodyDamage - currentDamage)
                            note("lv1") ]]
                            oldBodyDamage = currentDamage
                            TriggerEvent("crashEffect", Config.EffectTimeLevel1, 1)
                        end
                    end
                end
            elseif wasInCar then
                wasInCar = false
                beltOn = false
                currentDamage = 0
                oldBodyDamage = 0
                currentSpeed = 0
                oldSpeed = 0
            end
            
        if disableControls and Config.DisableControlsOnBlackout then
            -- Controls to disable while player is on blackout
			DisableControlAction(0,71,true) -- veh forward
			DisableControlAction(0,72,true) -- veh backwards
			DisableControlAction(0,63,true) -- veh turn left
			DisableControlAction(0,64,true) -- veh turn right
			DisableControlAction(0,75,true) -- disable exit vehicle
		end
	end
end)

-- Vehicles disable air controls

local vehicleClassDisableControl = {
  [0] = true,     --compacts
  [1] = true,     --sedans
  [2] = true,     --SUV's
  [3] = true,     --coupes
  [4] = true,     --muscle
  [5] = true,     --sport classic
  [6] = true,     --sport
  [7] = true,     --super
  [8] = false,    --motorcycle
  [9] = true,     --offroad
  [10] = true,    --industrial
  [11] = true,    --utility
  [12] = true,    --vans
  [13] = false,   --bicycles
  [14] = false,   --boats
  [15] = false,   --helicopter
  [16] = false,   --plane
  [17] = true,    --service
  [18] = true,    --emergency
  [19] = false    --military
}

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
      local player = GetPlayerPed(-1)
      local vehicle = GetVehiclePedIsIn(player, false)
      local vehicleClass = GetVehicleClass(vehicle)
      if ((GetPedInVehicleSeat(vehicle, -1) == player) and vehicleClassDisableControl[vehicleClass]) then
          if IsEntityInAir(vehicle) then
              DisableControlAction(2, 59)
              DisableControlAction(2, 60)
          end
      end
  end
end)

end)
