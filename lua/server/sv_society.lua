RegisterNetEvent('qb-banking:society:server:WithdrawMoney')
AddEventHandler('qb-banking:society:server:WithdrawMoney', function(pSource, a, n)
    local src = pSource
    if not src then return end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    if not a then return end
    if not n then return end

    local societyType = MySQL.scalar.await("SELECT type FROM management_funds WHERE job_name = ?", {n})

    if societyType == 'boss' then
        local s = exports["qb-management"]:GetAccount(n)
        local amount = tonumber(a)
        exports["qb-management"]:RemoveMoney(n, amount)
    else
        local s = exports["qb-management"]:GetGangAccount(n)
        local amount = tonumber(a)
        exports["qb-management"]:RemoveGangMoney(n, amount)
    end
end)

RegisterServerEvent('qb-banking:society:server:DepositMoney')
AddEventHandler('qb-banking:society:server:DepositMoney', function(pSource, a, n)
    local src = pSource
    if not src then return end

    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    if not a then return end
    if not n then return end

    local societyType = MySQL.scalar.await("SELECT type FROM management_funds WHERE job_name = ?", {n})

    if societyType == 'boss' then
        local s = exports["qb-management"]:GetAccount(n)
        local amount = tonumber(a)
        exports["qb-management"]:AddMoney(n, amount)
    else
        local s = exports["qb-management"]:GetGangAccount(n)
        local amount = tonumber(a)
        exports["qb-management"]:AddGangMoney(n, amount)
    end
end)