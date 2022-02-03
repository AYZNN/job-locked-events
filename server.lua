local Config = {
    frameWork = "ESX", -- or "QBCORE"
    getSharedObject = "esx:getSharedObject", -- or QBCore:getObject
    webHook = "https://discord.com/api/webhooks/xxx/xxx",

    jobLockedEvents = {
        {eventName = "esx_policejob:handcuff", authorizedJobs = {"police","sheriff"}},
        {eventName = "esx_jail:sendToJail", authorizedJobs = {"police","sheriff"}},
        --etc
    }
}

local function logToDiscord(source,eventName,currentJob)
    local source,eventName,currentJob = source,eventName,currentJob
    local embedContent = {
        ["color"] = 3447003,
        ["type"] = "rich",
        ['description'] = "",
        ["fields"] = {
            {
                ["name"] = "**A player tried to trigger a job locked event:**",
                ["value"] = "```"..
                    "Player Name: ".. GetPlayerName(source) .."\n"..
                    "Server ID: ".. tostring(source) .."\n"..
                    "\n"..
                    "Event Name: ".. eventName.."\n"..
                    "Player Job: ".. currentJob.."\n"..
                    "\n"..
                    "Date: ".. os.date("%A, %d %B %Y - %X") .."\n"
                .."```",
                ["inline"] = false,
            }
        },
    }

    PerformHttpRequest(Config.webHook,
        function(err, text, headers)end,
        "POST",
        json.encode({embeds = {embedContent}}),
        {["Content-Type"] = "application/json"}
    )

end

CreateThread(function()

    if Config.frameWork == "ESX" then
        while ESX == nil do
            TriggerEvent(Config.getSharedObject, function(obj)
                ESX = obj
            end)
            Wait(10)
        end
        Config.getJobName = function(source)
            return ESX.GetPlayerFromId(source).job.name
        end
    elseif Config.frameWork == "QBCORE" then
        QBCore = exports['qb-core']:GetCoreObject()
        if QBCore == nil then
            while QBCore == nil do
                TriggerEvent(Config.getSharedObject, function(obj)
                    QBCore = obj
                end)
                Wait(10)
            end
        end
        Config.getJobName = function(source)
            return QBCore.Functions.GetPlayer(source).PlayerData.job.name
        end
    end

    for i = 1, #Config.jobLockedEvents do

        AddEventHandler(Config.jobLockedEvents[i].eventName, function()

            local source = source
            local playerJob = Config.getJobName(source)

            for _,job in pairs(Config.jobLockedEvents[i].authorizedJobs) do
                if playerJob == job then
                    return
                end
            end

            logToDiscord(source,Config.jobLockedEvents[i].eventName,playerJob)

        end)
    end
end)
