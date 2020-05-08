local tParams = {}
local speedLimit = 50.0
local justIn = false
local tParams = {tyresPopped = 0, isSpeedLimited = false, t0 = false, t1 = false, t4 = false, t5 = false}
local speedLimitTwoTires = 12.0  --Speed limit when 2 or more tires get bursted
local speedLimitOneTire = 17.0   --Speed limit when 1 tire gets bursted
local speedLimitDelay = 1000     --How long it takes (in milliseconds) for speed limit kicks in after tire bursts
local vehicleSpeedMax = 0

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(10)
        local me = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(me, false)
        
        if DoesEntityExist(veh) then
            vehicleSpeedMax = GetVehicleHandlingFloat(veh,"CHandlingData","fInitialDriveMaxFlatVel") -- Gets vehicle's maximum possible speed from handling file
            --[[ RegisterCommand('burst', function() -- Debug command
                SetVehicleTyreBurst(veh, 4, true, 1000.0)
                StartVehicleAlarm(veh)
                speed = GetEntitySpeed(veh)
            end, false) ]]
        --------------------------------------------------------------------------
        ------Checks if any tyres are poped and adds it to popped tyres amount----
        --------------------------------------------------------------------------
        --Left Front
            if IsVehicleTyreBurst(veh, 0, true)and tParams.t0 == false then
                tParams.t0 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Right Front
            if IsVehicleTyreBurst(veh, 1, true) and tParams.t1 == false then
                tParams.t1 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Left Rear
            if IsVehicleTyreBurst(veh, 4, true) and tParams.t4 == false then
                tParams.t4 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end
            --Right Rear
            if IsVehicleTyreBurst(veh, 5, true) and tParams.t5 == false then
                tParams.t5 = true
                tParams.tyresPopped = tParams.tyresPopped + 1
            end

        end

        --Wheel id's on 6-wheeler: middle right - 3
        -------------------------- middle left - 2

        --If two or more tyres burst max drivavle speed is set to speedLimitTwoTires
        if tParams.tyresPopped >= 2 then
            local maxSpeedAfterBurst = speedLimitTwoTires
            Wait(speedLimitDelay)

            while speedLimit >= maxSpeedAfterBurst do
                SetVehicleMaxSpeed(veh, speedLimit)
                speedLimit = speedLimit - 4.0
                Wait(200)
            end

        --If one tire is burst max drivable speed set to speedLimitOneTire
        elseif tParams.tyresPopped > 0 then
            local maxSpeedAfterBurst = speedLimitOneTire

            Wait(speedLimitDelay)

            while speedLimit >= maxSpeedAfterBurst do
                SetVehicleMaxSpeed(veh, speedLimit)
                speedLimit = speedLimit - 3.0
                Wait(200)
            end

        else
            SetVehicleMaxSpeed(veh, vehicleSpeedMax)
        end

        --Refreshes variables when person gets to a new vehicle
        if IsPedInAnyVehicle(me, false) then
            if justIn == false then
                speedLimit = vehicleSpeedMax
                tParams.t0 = false
                tParams.t1 = false
                tParams.t4 = false
                tParams.t5 = false
                tParams.tyresPopped = 0
				justIn = true
            end
        else
            if justIn == true then
                justIn = false
            end
		end
    end
end)
