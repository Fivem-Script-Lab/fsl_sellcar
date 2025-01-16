local DB_VEHICLES = exports.DatabaseManager:GetDatabaseTableManager("owned_vehicles")

local DB_VEHICLES_SELECT = DB_VEHICLES.Prepare.Select({"owner"})
local DB_VEHICLES_UPDATE = DB_VEHICLES.Prepare.Update({ "owner" }, { "owner", "plate" })

local function FindVehicleWithPlate(tbl, plate)
    for i,v in pairs(tbl) do
        if v.plate == plate then
            return v
        end
    end
end


ESX.RegisterUsableItem("salecaragreement", function (source)
    local xPlayer = ESX.GetPlayerFromId(source)

    local player_identifier = xPlayer.getIdentifier()
    local player_ped = GetPlayerPed(source)
    local player_coords = GetEntityCoords(player_ped)
    
    local players = lib.getNearbyPlayers(player_coords, 10)

    local owned_vehicles = DB_VEHICLES_SELECT.execute(player_identifier)

    if owned_vehicles.plate then
        owned_vehicles = { owned_vehicles }
    end

    if not owned_vehicles then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "An error has appeared",
            description = "We didn't find any vehicle to your name!",
            type = "error"
        })
        return
    end

    local sale_data =  lib.callback.await("fsl:saleData", source, {
        players = players,
        vehicles = owned_vehicles,
        
    })

    if not sale_data then
        return
    end

    local xPlayer2 = ESX.GetPlayerFromId(sale_data[1])

    local account_name = sale_data[3] == "Cash" and "money" or "bank"
    local player_money = xPlayer2.getAccount(account_name).money
    if player_money < sale_data[4] then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "An error has appeared",
            description = ("Client doesn't have enough money in %s."):format(account_name),
            type = "error"
        })
        return
    end
    
    local sold_vehicle = FindVehicleWithPlate(owned_vehicles, sale_data[2])

    if not sold_vehicle then
        return
    end

    local offer_data = lib.callback.await("fsl:showOffer", sale_data[1], {
        price = sale_data[4],
        payType = sale_data[3],
        vehicle = sold_vehicle,

    })

    if not offer_data then
        TriggerClientEvent('ox_lib:notify', source, {
            title = "An error has appeared",
            description = "Client refused the offer!",
            type = "error"
        })
        return
    end

    local query = DB_VEHICLES_UPDATE.execute({ xPlayer2.getIdentifier() }, {player_identifier, sold_vehicle.plate})

    TriggerClientEvent('ox_lib:notify', source, {
        title = "Success",
        description = "Client has accepted an offer!",
        type = "success"
    })

    TriggerClientEvent('ox_lib:notify', sale_data[1], {
        title = "Success",
        description = "The vehicle got registered to your name succesfully!",
        type = "success"
    })

    xPlayer2.removeAccountMoney(account_name, sale_data[4])
    xPlayer.addAccountMoney(account_name, sale_data[4])


end)
