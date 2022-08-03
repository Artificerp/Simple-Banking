QBCore = exports['qb-core']:GetCoreObject()
QBCore.Functions.CreateCallback("qb-banking:server:GetBankData", function(source, cb)
    local src = source
    if not src then return end

    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    local PlayerMoney = Player.PlayerData.money["bank"] or 0 
    local CitizenId = Player.PlayerData.citizenid 

    local TransactionHistory = {}
    local TransactionRan = false
    local tbl = {}
    tbl[1] = {
        type = "personal",
        amount = PlayerMoney
    }

    local job = Player.PlayerData.job
    
    if (job.name and job.grade.name) then
        if (QBCore.Shared.Jobs[job.name].grades[tostring(job.grade.level)].bankmanager) then
            local account = exports["qb-management"]:GetAccount(job.name)

            if account ~= nil then
                tbl[#tbl + 1] = {
                    type = "business",
                    name = job.label,
                    amount = format_int(account) or 0
                }
            end
        end
    end

    local gang = Player.PlayerData.gang

    if (gang.name and gang.grade.name) then
        if(QBCore.Shared.Gangs[gang.name].grades[tostring(gang.grade.level)].bankmanager) then

            local account = exports["qb-management"]:GetGangAccount(gang.name)

            if account ~= nil then
                tbl[#tbl + 1] = {
                    type = "organization",
                    name = gang.label,
                    amount = format_int(account) or 0
                }
            end
        end
    end

    local result = MySQL.Sync.fetchAll("SELECT * FROM transaction_history WHERE citizenid =  ? AND DATE(date) > (NOW() - INTERVAL "..SimpleBanking.Config["Days_Transaction_History"].." DAY)", {Player.PlayerData.citizenid})

    if result ~= nil then
        TransactionRan = true
        TransactionHistory = result
    end


    repeat
        Wait(0)
    until 
        TransactionRan
    cb(tbl, TransactionHistory)
end)
