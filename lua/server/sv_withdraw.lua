RegisterServerEvent('qb-banking:server:Withdraw')
AddEventHandler('qb-banking:server:Withdraw', function(account, amount, note, fSteamID)
    local src = source
    if not src then return end
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player or Player == -1 then
        return
    end

    if not amount or tonumber(amount) <= 0 then
        TriggerClientEvent("qb-banking:client:Notify", src, "error", "Invalid amount!") 
        return
    end

    amount = tonumber(amount)

    if account == "personal" then
        if amount > Player.PlayerData.money["bank"] then
            TriggerClientEvent("qb-banking:client:Notify", src, "error", "Your bank doesn't have this much money!") 
            return
        end
        local withdraw = math.floor(amount)

        Player.Functions.AddMoney('cash', withdraw)
        Player.Functions.RemoveMoney('bank', withdraw)

        AddTransaction(src, "personal", -amount, "withdraw", "N/A", (note ~= "" and note or "Withdrew $"..format_int(amount).."."))
        RefreshTransactions(src)
    end

    if(account == "business") then
        local job = Player.PlayerData.job
        if (not QBCore.Shared.Jobs[job.name].grades[tostring(job.grade.level)].bankmanager) then
            return
        end

        local sM = exports["qb-management"]:GetAccount(job.name)
        if sM >= amount then
            TriggerEvent('qb-banking:society:server:WithdrawMoney',src, amount, job.name)

            AddTransaction(src, "business", -amount, "deposit", job.label, (note ~= "" and note or "Withdrew $"..format_int(amount).." from ".. job.label .."'s account."))
            Player.Functions.AddMoney('cash', amount)
        else
            TriggerClientEvent("qb-banking:client:Notify", src, "error", "Not enough money current balance: $"..sM) 
        end
    end

    if(account == "organization") then
        local gang = Player.PlayerData.gang
        if (not QBCore.Shared.Gangs[gang.name].grades[tostring(gang.grade.level)].bankmanager) then
            return
        end

        local sM = exports["qb-management"]:GetGangAccount(gang.name)
        if sM >= amount then
            TriggerEvent('qb-banking:society:server:WithdrawMoney',src, amount, gang.name)

            AddTransaction(src, "organization", -amount, "deposit", gang.label, (note ~= "" and note or "Withdrew $"..format_int(amount).." from ".. gang.label .."'s account."))
            Player.Functions.AddMoney('cash', amount)
        else
            TriggerClientEvent("qb-banking:client:Notify", src, "error", "Not enough money current balance: $"..sM) 
        end
    end
end)