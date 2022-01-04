Approved_Vehicles = {
    'fpiu4',
    'cvpi1',
    'fpis1',
    'charger3',
    'tahoe2',
    'charger2',
    'ram1',
    'fpiu2',
    'cvpi2',
    'charger4',
    'tahoe1',
    'fpiu1',
    'charger1',
    'fpis2',
    'ram2',
    'camp16',
    'polar1',
    'um20silv',
    'um18durango',
    'um18chrg',
    'PD8',
    'PD1',
    'PD3',
    'PD2',
    'PD5',
    'PD4',
    'PD7',
    'PD6',
    'so1',
    'so2',
    'so3',
    'so4',
    'so5',
    'so6',
    'so7',
    'um17raptor',
    'um20fpiu',
    'um14chrg',
    'lcso1',
    'lcso2',
    'lcso3',
    'lcso4',
    'lcso5',
    'tru2',
    'sru1',
    'dps14charger',
    'dpsfpis',
    'dps3',
    'dpsfpiu',
    'tahoedps',
    'dps18charg',
    'dps6',
    'dps14chargerst',
    'dps4',
    'dps2',
    'dps5',
    'dpsfpiust',
    'dps18chargerst',
    'dpsfpisst',
    'dps1',
    'so20',
    'so21',
    'um19tundra',
    'um18stang',
    'um16fpiu',
    'um20tahoe',
    'chpvic',
    'chp1',
    'chp2',
    'chp3',
    'chp4',
    'chp5',
    'chp6',
    'hpun',
    '',
}

Citizen.CreateThread(function()
    while true do
        local plyPos = GetEntityCoords(PlayerPedId())
        local vehicle = GetPlayersLastVehicle(PlayerPedId) 
        local center = GetEntityBoneIndexByName(vehicle, 'boot')
        local coords = GetWorldPositionOfEntityBone(vehicle, hood)
        local selected_weapon = "weapon_carbinerifle"
        local weapon_hash = GetHashKey(selected_weapon)
        local current_weapon = GetSelectedPedWeapon(PlayerPedId(-1))
        local Weapon_away = IsPedSwappingWeapon(GetPlayerPed(-1))
        local weapon_got = HasPedGotWeapon(GetPlayerPed(-1), weapon_hash, false)
        local carModel = GetEntityModel(vehicle)
        local carName = GetDisplayNameFromVehicleModel(carModel)
        local isVehicleAllowed
        for _, allowed_car in pairs(Approved_Vehicles) do
            if carModel == GetHashKey(allowed_car) then
                isVehicleAllowed = true
            end
        end
        if IsPedInVehicle(PlayerPedId(-1), vehicle, true) then 
        else
            if isVehicleAllowed then
                if #(plyPos - coords) <= 3 then
                    if weapon_got then
                        DrawText3D(coords.x, coords.y, coords.z, '[~g~X~w~] Put Weapon Back')
                        if IsControlJustReleased(0, 73) then
                            removeWeapon(selected_weapon)
                        end
                    else 
                        DrawText3D(coords.x, coords.y, coords.z, '[~g~X~w~] Retrive Weapon')
                        if IsControlJustReleased(0, 73)then
                            giveWeapon(selected_weapon)
                        end
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)

function VehicleInFront()
    local plyPed = PlayerPedId()
    local pos = GetEntityCoords(plyPed)
    local entityWorld = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 3.0, 0.0)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, plyPed, 0)
    local a, b, c, d, result = GetRaycastResult(rayHandle)
    return result
end

function checkCar(car)
	if car then
		carModel = GetEntityModel(car)
		carName = GetDisplayNameFromVehicleModel(carModel)
	end
end

function giveWeapon(hash)

    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(hash), 150, false, true)
    GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(hash), GetHashKey('COMPONENT_AT_AR_FLSH'))
    GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(hash), GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'))
    GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey(hash), GetHashKey('COMPONENT_AT_AR_AFGRIP'))

end

function removeWeapon(hash)
    RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(hash))
    SetPedAmmo(GetPlayerPed(-1), GetHashKey(hash), 0)
end

function DrawText3D(x, y, z, text, linecount)
    if not linecount or linecount == nil or linecount == 0 then
        linecount = 0.7
    end
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 470
    ClearDrawOrigin()
end

local SETTINGS = {
    back_bone = 24818,
    x = 0.00,
    y = 0.2,
    z = -0.02,
    x_rotation = 0.0,
    y_rotation = 145.0,
    z_rotation = 0.0,
    compatable_weapon_hashes = {
      ["w_ar_carbinerifle"] = -2084633992,
    }
}

local attached_weapons = {}

Citizen.CreateThread(function()
  while true do
      local me = GetPlayerPed(-1)
      for wep_name, wep_hash in pairs(SETTINGS.compatable_weapon_hashes) do
          if HasPedGotWeapon(me, wep_hash, false) then
              if not attached_weapons[wep_name] and GetSelectedPedWeapon(me) ~= wep_hash then
                  AttachWeapon(wep_name, wep_hash, SETTINGS.back_bone, SETTINGS.x, SETTINGS.y, SETTINGS.z, SETTINGS.x_rotation, SETTINGS.y_rotation, SETTINGS.z_rotation, isMeleeWeapon(wep_name))
              end
          end
      end
      for name, attached_object in pairs(attached_weapons) do
          if GetSelectedPedWeapon(me) ==  attached_object.hash or not HasPedGotWeapon(me, attached_object.hash, false) then -- equipped or not in weapon wheel
            DeleteObject(attached_object.handle)
            attached_weapons[name] = nil
          end
      end
  Wait(0)
  end
end)

function AttachWeapon(attachModel,modelHash,boneNumber,x,y,z,xR,yR,zR, isMelee)
	local bone = GetPedBoneIndex(GetPlayerPed(-1), boneNumber)
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Wait(100)
	end

  attached_weapons[attachModel] = {
    hash = modelHash,
    handle = CreateObject(GetHashKey(attachModel), 1.0, 1.0, 1.0, true, true, false)
  }

  if isMelee then x = 0.11 y = -0.14 z = 0.0 xR = -75.0 yR = 185.0 zR = 92.0 end -- reposition for melee items
  if attachModel == "prop_ld_jerrycan_01" then x = x + 0.3 end
	AttachEntityToEntity(attached_weapons[attachModel].handle, GetPlayerPed(-1), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end

function isMeleeWeapon(wep_name)
    if wep_name == "prop_golf_iron_01" then
        return true
    elseif wep_name == "w_me_bat" then
        return true
    elseif wep_name == "prop_ld_jerrycan_01" then
      return true
    else
        return false
    end
end