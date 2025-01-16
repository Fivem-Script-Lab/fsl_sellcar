lib.callback.register("fsl:saleData", function (data)

    local players = {}
    local vehicles = {}

    for i,v in pairs(data.players) do
        players[i] = { label = ("ID: %d"):format(v.id), value = v.id}
    end

    for i, v in pairs(data.vehicles) do
        if Config.CheckIfVehicleIsInGarage then
            if not v.stored == Config.StoredValue then
                goto continue
            end
        end
        vehicles[i] = { label = ("%s - %s"):format(GetDisplayNameFromVehicleModel(json.decode(v.vehicle).model), v.plate), value = v.plate }
        ::continue::
    end

    if #vehicles == 0 then
        lib.notify({
            title = "An error has appeared",
            description = "You don't have any vehicle in a garage!",
            type = "error"
        })
        return false
    end

    local input = lib.inputDialog("Vehicle Sale", {
        {
            type = "select",
            label = "Player Server ID",
            options = players,
            description = "Choose a player who will receive an offer.",
            icon = "fa-solid fa-users",
            required = true,
            searchable = true,
        },
        {
            type = "select",
            label = "Vehicle",
            options = vehicles,
            description = "Which car do you want to sell.",
            icon = "fa-solid fa-car",
            required = true,
            searchable = true,
        },
        {
            type = "select",
            label = "Payment Method",
            options = { { value = "Cash" }, { value = "Bank Transfer" }},
            description = "Which payment option does the buyer have.",
            icon = "fa-solid fa-money-bill",
            required = true,
        },
        {
            type = "number",
            label = "Price",
            step = 1000,
            description = "The price of the vehicle.",
            icon = "fa-solid fa-tag",
            required = true,
        }
    }, {
        allowCancel = true
    })

    return input
end)


lib.callback.register("fsl:showOffer", function(data)
    local alert = lib.alertDialog({
        header = "Vehicle Sell",
        content = ("Do you want to purchase a %s for %d$? Payment: %s."):format(GetDisplayNameFromVehicleModel(json.decode(data.vehicle.vehicle).model), data.price, data.payType),
        centered = true,
        cancel = true,
        labels = {
            confirm = "Yes, I want to buy it.",
            cancel = "No, I am not intrested.",

        }
    })

    return alert
end)
