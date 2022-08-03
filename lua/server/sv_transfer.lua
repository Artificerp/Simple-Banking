RegisterServerEvent('qb-banking:server:Transfer')
AddEventHandler('qb-banking:server:Transfer', function(target, account, amount, note, fSteamID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    target = target ~= nil and tonumber(target) or nil
    if not target or target <= 0 or target == src then
        return
    end

    target = tonumber(target)
    amount = tonumber(amount)
    local targetPly = QBCore.Functions.GetPlayer(target)

    if not targetPly or targetPly == -1 then
        return
    end

    if (target == src) then
        return
    end

    if (not amount or amount <= 0) then
        return
    end

    if (account == "personal") then
        local balance = Player.PlayerData.money["bank"]--ply.getAccount("bank").money

        if amount > balance then
            return
        end

        Player.Functions.RemoveMoney('bank', amount)
        targetPly.Functions.AddMoney('bank', math.floor(amount))

        AddTransaction(src, "personal", -amount, "transfer", targetPly.PlayerData.charinfo.firstname, "Transfered $" .. format_int(amount) .. " to " .. targetPly.PlayerData.charinfo.firstname)
        AddTransaction(targetPly.PlayerData.source, "personal", amount, "transfer", Player.PlayerData.charinfo.firstname, "Received $" .. format_int(amount) .. " from " ..Player.PlayerData.charinfo.firstname)
    end

    if (account == "business") then
        local job = Player.PlayerData.job
        if (not QBCore.Shared.Jobs[job.name].grades[tostring(job.grade.level)].bankmanager) then
            return
        end

        TriggerEvent('qb-banking:society:server:WithdrawMoney', src, amount, job.name)
        Wait(50)
        targetPly.Functions.AddMoney('cash', amount)
        AddTransaction(src, "personal", -amount, "transfer", targetPly.PlayerData.charinfo.firstname, "Transfered $" .. format_int(amount) .. " to " .. targetPly.PlayerData.charinfo.firstname .. " from " .. job.label .. "'s account")
    end

    if (account == "organization") then
        local gang = Player.PlayerData.gang
        if (not QBCore.Shared.Gangs[gang.name].grades[tostring(gang.grade.level)].bankmanager) then
            return
        end


        TriggerEvent('qb-banking:society:server:WithdrawMoney', src, amount, gang.name)
        Wait(50)
        targetPly.Functions.AddMoney('cash', amount)
        AddTransaction(src, "personal", -amount, "transfer", targetPly.PlayerData.charinfo.firstname, "Transfered $" .. format_int(amount) .. " to " .. targetPly.PlayerData.charinfo.firstname .. " from " .. gang.label .. "'s account")
    end
end)
