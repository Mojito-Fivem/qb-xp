## Implementation Example

qb-vehicleshop/showroom.lua
```lua
if IsDisabledControlJustPressed(0, Keys["7"]) then
    if buySure then
        rank = exports["qb-xp"]:qb_xpxpGetRank()
        displayName = QBCore.Shared.Vehicles[QB.ShowroomVehicles[ClosestVehicle].chosenVehicle]["model"]
        print(displayName)
        print(rank)
        if QBCore.Shared.Vehicles[displayName]["minrank"] ~= nil then
            if QBCore.Shared.Vehicles[displayName]["minrank"] <= rank then
                local class = QBCore.Shared.Vehicles[QB.ShowroomVehicles[ClosestVehicle].chosenVehicle]["category"]
                TriggerServerEvent('qb-vehicleshop:server:buyShowroomVehicle', QB.ShowroomVehicles[ClosestVehicle].chosenVehicle, class)
                buySure = false
            else
                QBCore.Functions.Notify("You are not a high enough rank to buy this vehicle", 'error', 3500)
                buySure = false
            end
        else
            local class = QBCore.Shared.Vehicles[QB.ShowroomVehicles[ClosestVehicle].chosenVehicle]["category"]
            TriggerServerEvent('qb-vehicleshop:server:buyShowroomVehicle', QB.ShowroomVehicles[ClosestVehicle].chosenVehicle, class)
            buySure = false
        end
    end
end
```
### FOR THIS EXAMPLE YOU WILL NEED TO ADD A MINRANK VALUE TO YOUR CARS IN YOUR SHARED.LUA
