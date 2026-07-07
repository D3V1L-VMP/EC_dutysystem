ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('duty:toggleDuty', function(targetStatus)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if targetStatus == "off" then
        -- Save current job and grade to metadata before switching
        xPlayer.setMeta('original_job', xPlayer.job.name)
        xPlayer.setMeta('original_grade', xPlayer.job.grade)
        
        -- Change job to offduty
        xPlayer.setJob('offduty', 0)
        TriggerClientEvent('esx:showNotification', src, '~r~You are now Off Duty')
        
    else
        -- Retrieve original job from metadata
        local savedJob = xPlayer.getMeta('original_job')
        local savedGrade = xPlayer.getMeta('original_grade')

        if savedJob and savedJob ~= 'offduty' then
            xPlayer.setJob(savedJob, savedGrade)
            TriggerClientEvent('esx:showNotification', src, '~g~You are now On Duty')
        else
            TriggerClientEvent('esx:showNotification', src, '~y~No job data found!')
        end
    end
end)
