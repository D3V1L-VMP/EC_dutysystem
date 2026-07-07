ESX = exports["es_extended"]:getSharedObject()

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local playerData = ESX.GetPlayerData()

        if playerData and playerData.job then
            local isOffDuty = (playerData.job.name == 'offduty')
            
            -- We use a trick: if off duty, we check the job from the server side or 
            -- simply check if the player is near their duty point.
            -- To avoid the 'getMeta' error, we will use the job name from the server via a small sync or check all points.
            
            local currentJobName = playerData.job.name
            local targetJobForMarker = currentJobName

            -- If offduty, we need to know what our real job was to show the marker.
            -- Since getMeta is not available on client, we check if the player is near ANY duty point 
            -- belonging to the jobs defined in Config.
            
            if isOffDuty then
                -- If off duty, we look for the marker of ANY job in Config
                -- We iterate through Config.DutyPoints to find the right one
                for jobName, pos in pairs(Config.DutyPoints) do
                    local distToPoint = #(coords - pos)
                    if distToPoint < 10.0 then
                        -- If we are near a duty point, we assume this is our job's point
                        -- We'll use this to allow the player to go back On Duty
                        targetJobForMarker = jobName
                        break
                    end
                end
            end

            if targetJobForMarker and Config.DutyPoints[targetJobForMarker] then
                local pos = Config.DutyPoints[targetJobForMarker]
                local dist = #(coords - pos)

                if dist < 10.0 then
                    wait = 0
                    -- Color logic: Green if On Duty, Red if Off Duty
                    local color = isOffDuty and {r=255, g=0, b=0} or {r=0, g=255, b=0}
                    
                    DrawMarker(1, pos.x, pos.y, pos.z - 1.0, 0,0,0,0,0,0, 1.2,1.2,0.6, color.r, color.g, color.b, 150, false,true,2, false,nil,nil,false)
                    
                    if dist < 1.5 then
                        local helpText = isOffDuty and "Press ~INPUT_CONTEXT~ to go ~g~On Duty" or "Press ~INPUT_CONTEXT~ to go ~r~Off Duty"
                        ESX.ShowHelpNotification(helpText)
                        
                        if IsControlJustReleased(0, 38) then
                            TriggerServerEvent('duty:toggleDuty', isOffDuty and "on" or "off")
                        end
                    end
                end
            end
        end
        Wait(wait)
    end
end)
