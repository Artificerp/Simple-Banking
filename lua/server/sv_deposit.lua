RegisterServerEvent('qb-banking:server:Deposit')
AddEventHandler('qb-banking:server:Deposit', function(account, amount, note, fSteamID)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player == -1 then
        return
    end

    if not amount or tonumber(amount) <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Invalid Amount!") 
        return
    end

    local amount = tonumber(amount)
    if amount > Player.PlayerData.money["cash"] then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "You can't afford this!") 
        return
    end

    if account == "personal"  then
        local amt = math.floor(amount)

        Player.Functions.RemoveMoney('cash', amt)
        Wait(500)
        Player.Functions.AddMoney('bank', amt)
        RefreshTransactions(src)
        AddTransaction(src, "personal", amount, "deposit", "N/A", (note ~= "" and note or "Deposited $"..format_int(amount).." cash."))
        return
    end

    if account == "business"  then
        local job = Player.PlayerData.job
        if (not QBCore.Shared.Jobs[job.name].grades[tostring(job.grade.level)].bankmanager) then
            return
        end

        local deposit = math.floor(amount)
        Player.Functions.RemoveMoney('cash', deposit)
        TriggerEvent('qb-banking:society:server:DepositMoney', src, deposit, job.name)
        AddTransaction(src, "business", amount, "deposit", job.label, (note ~= "" and note or "Deposited $"..format_int(amount).." cash into ".. job.label .."'s business account."))
    end

    if account == "organization"  then
        local gang = Player.PlayerData.gang
        if (not QBCore.Shared.Gangs[gang.name].grades[tostring(gang.grade.level)].bankmanager) then
            return
        end

        local deposit = math.floor(amount)
        Player.Functions.RemoveMoney('cash', deposit)
        TriggerEvent('qb-banking:society:server:DepositMoney',src, deposit, gang.name)
        AddTransaction(src, "organization", amount, "deposit", gang.label, (note ~= "" and note or "Deposited $"..format_int(amount).." cash into ".. gang.label .."'s account."))
    end
end)
