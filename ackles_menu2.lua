local imgui = require("mimgui")

local menu = imgui.new.bool(false)
local tab_aberto = false
local current_lab = 1
local fonte = nil
local icone_inicial = nil
local icone_esp = nil
local icone_carro = nil
local icone_teleporte = nil
local icone_arma = nil

local id_arma = imgui.new.int(0)
local id_player = imgui.new.int(0)

local esp_linhas = false
local esp_linhas_t = imgui.new.bool(false)

local esp_name = false
local esp_name_t = imgui.new.bool(false)

local dist = false
local dist_t = imgui.new.bool(false)

local esp_id = false
local esp_id_t = imgui.new.bool(false)

local esp_t  = imgui.new.bool(false)
local esp_e = false

local socket = require("socket.http")
local ltn12 = require("ltn12")
local ffi = require('ffi')
local gta = ffi.load('GTASA')


local correr_sem_cansar_t = imgui.new.bool(false)
local correr_sem_cansar = false
local atravessar_player_t = imgui.new.bool(false)
local atravessar_player = false

local speed_hack = false
local speed_hack_t = imgui.new.bool(false)

local atravessar_carros = false
local atravessar_carros_t = imgui.new.bool(false)

local god_mod = false
local god_mod_t = imgui.new.bool(false)

local rgb_active = false
local rgb_t = imgui.new.bool(false)

-- Função rainbow que retorna 0xAARRGGBB

function rgbRainbowHex(speed, alpha)
    alpha = alpha or 1
    local t = os.clock() * speed
    local r = math.floor((math.sin(t + 0) * 127 + 128))
    local g = math.floor((math.sin(t + 2) * 127 + 128))
    local b = math.floor((math.sin(t + 4) * 127 + 128))
    local a = math.floor(alpha * 255)
    return string.format("0x%02X%02X%02X%02X", a, r, g, b)
end

function atravessar_player_f()
  if atravessar_player then
    for id = 0, sampGetMaxPlayerId(false) do
      if sampIsPlayerConnected(id) then
        local res, ped = sampGetCharHandleBySampPlayerId(id)
        if res and doesCharExist(ped) then
          local x,y,z = getCharCoordinates(PLAYER_PED)
          local xx,yy,zz = getCharCoordinates(ped)
          if getDistanceBetweenCoords3d(xx,yy,zz,x,y,z) < 1 then
            setCharCollision(ped, false)
          end
        end
      end
    end
  end
end
  
function atravessar_carros_f()
    myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
    resultc, vehHandle = findAllRandomVehiclesInSphere(myPosX, myPosY, myPosZ, 25, true, true)

    if atravessar_carros then
        local vehi = nil
        if isCharInAnyCar(PLAYER_PED) then
            vehi = storeCarCharIsInNoSave(PLAYER_PED)
        end

        if resultc and vehHandle and vehHandle ~= vehi then
            setCarCollision(vehHandle, false)
        end
    else
        if resultc and vehHandle then
            setCarCollision(vehHandle, true)
        end
    end
end

ffi.cdef[[
  typedef struct RwV3d {
    float x, y, z;
  } RwV3d;
  // void CPed::GetBonePosition(CPed *this, RwV3d *posn, uint32 bone, bool calledFromCam) - Mangled name
  void _ZN4CPed15GetBonePositionER5RwV3djb(void* thiz, RwV3d* posn, uint32_t bone, bool calledFromCam);
]]

function getBonePosition(ped, bone)
  local pedptr = ffi.cast('void*', getCharPointer(ped))
  local posn = ffi.new('RwV3d[1]')
  gta._ZN4CPed15GetBonePositionER5RwV3djb(pedptr, posn, bone, false)
  return posn[0].x, posn[0].y, posn[0].z
end

function speed_hack_f()
  if speed_hack then
          local animationSpeed3 = 2.5 
            local all_anims = {
              "abseil",
              "arrestgun",
              "atm",
              "bike_elbowl",
              "bike_elbowr",
              "bike_fallr",
              "bike_fall_off",
              "bike_pickupl",
              "bike_pickupr",
              "bike_pullupl",
              "bike_pullupr",
              "bomber",
              "car_alignhi_lhs",
              "car_alignhi_rhs",
              "car_align_lhs",
              "car_align_rhs",
              "car_closedoorl_lhs",
              "car_closedoorl_rhs",
              "car_closedoor_lhs",
              "car_closedoor_rhs",
              "car_close_lhs",
              "car_close_rhs",
              "car_crawloutrhs",
              "car_dead_lhs",
              "car_dead_rhs",
              "car_doorlocked_lhs",
              "car_doorlocked_rhs",
              "car_fallout_lhs",
              "car_fallout_rhs",
              "car_getinl_lhs",
              "car_getinl_rhs",
              "car_getin_lhs",
              "car_getin_rhs",
              "car_getoutl_lhs",
              "car_getoutl_rhs",
              "car_getout_lhs",
              "car_getout_rhs",
              "car_hookertalk",
              "car_jackedlhs",
              "car_jackedrhs",
              "car_jumpin_lhs",
              "car_lb",
              "car_lb_pro",
              "car_lb_weak",
              "car_ljackedlhs",
              "car_ljackedrhs",
              "car_lshuffle_rhs",
              "car_lsit",
              "car_open_lhs",
              "car_open_rhs",
              "car_pulloutl_lhs",
              "car_pulloutl_rhs",
              "car_pullout_lhs",
              "car_pullout_rhs",
              "car_qjacked",
              "car_rolldoor",
              "car_rolldoorlo",
              "car_rollout_lhs",
              "car_rollout_rhs",
              "car_shuffle_rhs",
              "car_sit",
              "car_sitp",
              "car_sitplo",
              "car_sit_pro",
              "car_sit_weak",
              "car_tune_radio",
              "climb_idle",
              "climb_jump",
              "climb_jump2fall",
              "climb_jump_b",
              "climb_pull",
              "climb_stand",
              "climb_stand_finish",
              "cower",
              "crouch_roll_l",
              "crouch_roll_r",
              "dam_arml_frmbk",
              "dam_arml_frmft",
              "dam_arml_frmlt",
              "dam_armr_frmbk",
              "dam_armr_frmft",
              "dam_armr_frmrt",
              "dam_legl_frmbk",
              "dam_legl_frmft",
              "dam_legl_frmlt",
              "dam_legr_frmbk",
              "dam_legr_frmft",
              "dam_legr_frmrt",
              "dam_stomach_frmbk",
              "dam_stomach_frmft",
              "dam_stomach_frmlt",
              "dam_stomach_frmrt",
              "door_lhinge_o",
              "door_rhinge_o",
              "drivebyl_l",
              "drivebyl_r",
              "driveby_l",
              "driveby_r",
              "drive_boat",
              "drive_boat_back",
              "drive_boat_l",
              "drive_boat_r",
              "drive_l",
              "drive_lo_l",
              "drive_lo_r",
              "drive_l_pro",
              "drive_l_pro_slow",
              "drive_l_slow",
              "drive_l_weak",
              "drive_l_weak_slow",
              "drive_r",
              "drive_r_pro",
              "drive_r_pro_slow",
              "drive_r_slow",
              "drive_r_weak",
              "drive_r_weak_slow",
              "drive_truck",
              "drive_truck_back",
              "drive_truck_l",
              "drive_truck_r",
              "drown",
              "duck_cower",
              "endchat_01",
              "endchat_02",
              "endchat_03",
              "ev_dive",
              "ev_step",
              "facanger",
              "facgum",
              "facsurp",
              "facsurpm",
              "factalk",
              "facurios",
              "fall_back",
              "fall_collapse",
              "fall_fall",
              "fall_front",
              "fall_glide",
              "fall_land",
              "fall_skydive",
              "fight2idle",
              "fighta_1",
              "fighta_2",
              "fighta_3",
              "fighta_block",
              "fighta_g",
              "fighta_m",
              "fightidle",
              "fightshb",
              "fightshf",
              "fightsh_bwd",
              "fightsh_fwd",
              "fightsh_left",
              "fightsh_right",
              "flee_lkaround_01",
              "floor_hit",
              "floor_hit_f",
              "fucku",
              "gang_gunstand",
              "gas_cwr",
              "getup",
              "getup_front",
              "gum_eat",
              "guncrouchbwd",
              "guncrouchfwd",
              "gunmove_bwd",
              "gunmove_fwd",
              "gunmove_l",
              "gunmove_r",
              "gun_2_idle",
              "gun_butt",
              "gun_butt_crouch",
              "gun_stand",
              "handscower",
              "handsup",
              "hita_1",
              "hita_2",
              "hita_3",
              "hit_back",
              "hit_behind",
              "hit_front",
              "hit_gun_butt",
              "hit_l",
              "hit_r",
              "hit_walk",
              "hit_wall",
              "idlestance_fat",
              "idlestance_old",
              "idle_armed",
              "idle_chat",
              "idle_csaw",
              "idle_gang1",
              "idle_hbhb",
              "idle_rocket",
              "idle_stance",
              "idle_taxi",
              "idle_tired",
              "jetpack_idle",
              "jog_femalea",
              "jog_malea",
              "jump_glide",
              "jump_land",
              "jump_launch",
              "jump_launch_r",
              "kart_drive",
              "kart_l",
              "kart_lb",
              "kart_r",
              "kd_left",
              "kd_right",
              "ko_shot_face",
              "ko_shot_front",
              "ko_shot_stom",
              "ko_skid_back",
              "ko_skid_front",
              "ko_spin_l",
              "ko_spin_r",
              "pass_smoke_in_car",
              "phone_in",
              "phone_out",
              "phone_talk",
              "player_sneak",
              "player_sneak_walkstart",
              "roadcross",
              "roadcross_female",
              "roadcross_gang",
              "roadcross_old",
              "run_1armed",
              "run_armed",
              "run_civi",
              "run_csaw",
              "run_fat",
              "run_fatold",
              "run_gang1",
              "run_left",
              "run_old",
              "run_player",
              "run_right",
              "run_rocket",
              "run_stop",
              "run_stopr",
              "run_wuzi",
              "seat_down",
              "seat_idle",
              "seat_up",
              "shot_leftp",
              "shot_partial",
              "shot_partial_b",
              "shot_rightp",
              "shove_partial",
              "smoke_in_car",
              "sprint_civi",
              "sprint_panic",
              "sprint_wuzi",
              "swat_run",
              "swim_tread",
              "tap_hand",
              "tap_handp",
              "turn_180",
              "turn_l",
              "turn_r",
              "walk_armed",
              "walk_civi",
              "walk_csaw",
              "walk_doorpartial",
              "walk_drunk",
              "walk_fat",
              "walk_fatold",
              "walk_gang1",
              "walk_gang2",
              "walk_old",
              "walk_player",
              "walk_rocket",
              "walk_shuffle",
              "walk_start",
              "walk_start_armed",
              "walk_start_csaw",
              "walk_start_rocket",
              "walk_wuzi",
              "weapon_crouch",
              "woman_idlestance",
              "woman_run",
              "woman_runbusy",
              "woman_runfatold",
              "woman_runpanic",
              "woman_runsexy",
              "woman_walkbusy",
              "woman_walkfatold",
              "woman_walknorm",
              "woman_walkold",
              "woman_walkpro",
              "woman_walksexy",
              "woman_walkshop",
              "xpressscratch"
            }
    for _, animName in ipairs(all_anims) do
      setCharAnimSpeed(PLAYER_PED, animName, animationSpeed3)
    end
  end
end
  

local bones = { 3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2 }
local sw, sh = getScreenResolution()
local font = renderCreateFont("Arial", 12, 1 + 4) -- P.S. in MonetLoader only Arial Bold is available (every font is defaulted to it)

function esp_esqueleto()
    for _, char in ipairs(getAllChars()) do
      local result, id = sampGetPlayerIdByCharHandle(char)
      if result and isCharOnScreen(char) then
        local opaque_color = bit.bor(bit.band(sampGetPlayerColor(id), 0xFFFFFF), 0xFF000000)
        for _, bone in ipairs(bones) do
          local x1, y1, z1 = getBonePosition(char, bone)
          local x2, y2, z2 = getBonePosition(char, bone + 1)
          local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r1 and r2 and esp_e then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFF69B4)
          end
        end

        local x1, y1, z1 = getBonePosition(char, 2)
        local r1, sx1, sy1 = convert3DCoordsToScreenEx(x1, y1, z1)
        if r1 then
          local x2, y2, z2 = getBonePosition(char, 41)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r2 and esp_e then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFF69B4)
          end
        end
        if r1 then
          local x2, y2, z2 = getBonePosition(char, 51)
          local r2, sx2, sy2 = convert3DCoordsToScreenEx(x2, y2, z2)
          if r2 and esp_e then
            renderDrawLine(sx1, sy1, sx2, sy2, 3, 0xFFFF69B4)
          end
        end
      end
    end
end

function rgbRainbow(speed)
    local t = os.clock() * speed
    local r = math.floor(math.sin(t + 0) * 127 + 128)
    local g = math.floor(math.sin(t + 2) * 127 + 128)
    local b = math.floor(math.sin(t + 4) * 127 + 128)
    return r/255, g/255, b/255
end

function imgui.Theme()
  imgui.SwitchContext()
  imgui.GetStyle().FrameRounding = 44
  imgui.GetStyle().FramePadding = imgui.ImVec2(3.5,3.5)
  imgui.GetStyle().ChildRounding = 2
  imgui.GetStyle().WindowRounding = 25
  imgui.GetStyle().ItemSpacing = imgui.ImVec2(5.0,4.0)
  imgui.GetStyle().ScrollbarSize = 13.0
  imgui.GetStyle().ScrollbarRounding = 0
  imgui.GetStyle().WindowPadding = imgui.ImVec2(4.0,4.0)
  imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5,0.5)
  -- cores menu
  imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(1,0.4,0.7,1)
  imgui.GetStyle().Colors[imgui.Col.WindowBg].w = 0.2
  imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.8,0,0,1)
  -- fonte
  
  local io = imgui.GetIO()
  fonte = io.Fonts:AddFontFromFileTTF("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/a.ttf", 28)
  -- imagems
  icone_inicial = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/images.png")
  icone_esp = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/esp.jpg")
  icone_carro = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/carro2.jpeg")
  icone_teleporte = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/icone10.jpeg")
  icone_arma = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/arma.jpeg")
  icone_sair = imgui.CreateTextureFromFile("/storage/emulated/0/Android/media/ro.alyn_sampmobile.game/monetloader/lib/sair.png")
end

-- inicalizar design do menu
imgui.OnInitialize(function() imgui.Theme() end)



-- funcao esps 
function esps(cor)
  local myx,myy,myz = getCharCoordinates(PLAYER_PED)
  local mx,my = convert3DCoordsToScreen(myx,myy,myz)
  local font = renderCreateFont("Arial", 11, 0)
  for id = 0, 400 do
    local result, ped = sampGetCharHandleBySampPlayerId(id)
    if result and doesCharExist(ped) then
      local name = sampGetPlayerNickname(id)
      local text = string.format("%s", name)
      local x,y,z = getCharCoordinates(ped)
      local sx,sy = convert3DCoordsToScreen(x,y,z)
      if isPointOnScreen(x,y,z,1) then
        if esp_name then
          if rgb_active then
              cor = tonumber(rgbRainbowHex(2.0,1))
              renderFontDrawText(font, text, sx,sy, cor)
          end 
          if not rgb_active then
              renderFontDrawText(font, text, sx,sy, 0xFFFFFFFF)
          end
        end
        if esp_linhas then
          if rgb_active then
              renderDrawLine(mx,my,sx,sy,1.5, cor)
          end
          if not rgb_active then
            renderDrawLine(mx,my,sx,sy,1.5, 0xFFFFFFFF)
          end
        end
        if dist then
          local d = getDistanceBetweenCoords3d(x,y,z,myx,myy,myz)
          local font = renderCreateFont("Arial", 11, 0)
          local text = string.format("DIST: %d", tostring(d))
          if rgb_active then
            renderFontDrawText(font, text, sx+20,sy+30, cor)
          end
          if not rgb_active then
            renderFontDrawText(font, text, sx+20,sy+30, 0xFFFFFFFF)
          end
        end
      end
      if esp_id then
        local font = renderCreateFont("Arial", 11,0)
        if result then
          local result, id = sampGetPlayerIdByCharHandle(ped)
          local x,y,z = getCharCoordinates(ped)
          local text = string.format("%d", id)
          if isPointOnScreen(x,y,z,1) then
            if rgb_active then
              renderFontDrawText(font, text, sx+15,sy, cor)
            end
            if not rgb_active then
              renderFontDrawText(font, text, sx+15,sy, 0xFFFFFFFF)
            end
          end
        end
      end 
    end
  end
end
function god_mod_f()
    if god_mod then
      setCharProofs(playerPed, true, true, true, true, true)
   end  
end
-- Desenhar Menu
imgui.OnFrame(
    function()
      return menu[0]
    end, 
    function(player)
      imgui.SetNextWindowSize(imgui.ImVec2(800,650))
      local r, g, b = rgbRainbow(2.0)
      imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(r, g, b, 1))
      imgui.PushStyleColor(imgui.Col.MenuBarBg, imgui.ImVec4(r,g,b,1))
      imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(r,g,b,1))
      
      if imgui.Begin("Menu", menu, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize) then
        -- titulo ackles menu
        imgui.PushFont(fonte)
        
        local text = "ACKLES MENU"
        local WindowSize = imgui.GetWindowSize().x
        local TextSize = imgui.CalcTextSize(text).x
        imgui.SetCursorPosX((WindowSize-TextSize) / 2 - 55)
        imgui.SetWindowFontScale(1.8)
        imgui.TextColored(imgui.ImVec4(r,g,b,1), text)
        imgui.SetWindowFontScale(1.0)
        local w = imgui.GetWindowWidth()
        imgui.SameLine()
        imgui.SetCursorPosX(w - 60) 
        if imgui.ImageButton(icone_sair, imgui.ImVec2(48,48)) then
          menu[0] = false
        end
        imgui.Columns(2, "##Menu", false)
        imgui.SetColumnWidth(0,165)
        if imgui.ImageButton(icone_inicial, imgui.ImVec2(150,95)) then
          current_lab = 1
        end
        if imgui.ImageButton(icone_esp, imgui.ImVec2(150,95)) then
          current_lab = 2
        end
        if imgui.ImageButton(icone_carro, imgui.ImVec2(150,95)) then
          current_lab = 3
        end
        if imgui.ImageButton(icone_teleporte, imgui.ImVec2(150,95)) then
          current_lab = 4
        end
        if imgui.ImageButton(icone_arma, imgui.ImVec2(150,105)) then
          current_lab = 5
        end
        imgui.NextColumn()
        imgui.BeginChild("##teste", imgui.ImVec2(0,0), false)
        imgui.SetWindowFontScale(1.3)
        local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        local nick = sampGetPlayerNickname(id)
        local text1 =  string.format("BEM-VINDO, %s", nick)
        if current_lab == 1 then
          imgui.Text(text1)
          imgui.Spacing()
          if imgui.Button("PUXAR VIDA!") then
            setCharHealth(PLAYER_PED, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR COLETE!") then
            addArmourToChar(PLAYER_PED, 100)
          end
          if imgui.Button("SUICIDIO") then
            setCharHealth(PLAYER_PED, 0)
          end
          if imgui.Button("Logar") then
              sampSendChat("/logar 007T5542g")
          end
          imgui.Spacing()
          local speed = getCharSpeed(PLAYER_PED)
          local text2 = string.format("SUA VELOCIDADE: %d", speed)
          imgui.Text(text2)
          imgui.Separator()
          if imgui.Checkbox("GOD MODE", god_mod_t) then
            god_mod = god_mod_t[0]
          end
          if imgui.Checkbox("CORRER SEM CANSAR", correr_sem_cansar_t) then
            correr_sem_cansar = correr_sem_cansar_t[0]
          end
          if imgui.Checkbox("ATRAVESSAR PLAYERS", atravessar_player_t) then
            atravessar_player = atravessar_player_t[0]
          end
          if imgui.Checkbox("CORRER RAPIDO", speed_hack_t) then
            speed_hack = speed_hack_t[0]
          end
        elseif current_lab == 2 then
          imgui.Spacing()
          imgui.Text("ESPS DISPONIVEIS:")
          imgui.Spacing()
          if imgui.Checkbox("TODOS ESPS RGB", rgb_t) then
            rgb_active = rgb_t[0]
          end
        
          if imgui.Checkbox("ESP NAME", esp_name_t) then
            esp_name = esp_name_t[0]
          end
          imgui.Spacing()
          if imgui.Checkbox("ESP DISTANCIA", dist_t) then
            dist = dist_t[0]
          end
          imgui.Spacing()
          if imgui.Checkbox("ESP ID", esp_id_t) then
            esp_id = esp_id_t[0]
          end
          imgui.Spacing()
          if imgui.Checkbox("ESP LINHAS", esp_linhas_t) then
            esp_linhas = esp_linhas_t[0]
          end
          imgui.Spacing()
          if imgui.Checkbox("ESP ESQUELETO", esp_t) then
            esp_e = esp_t[0]
          end
        elseif current_lab == 3 then
          imgui.TextColored(imgui.ImVec4(1,0.4,0.7,1), "AREA DE CARROS :)")
          imgui.Text("ESTEJA DENTRO DE UM CARRO")
          if imgui.Button("REPARAR VEICULO") then
            local car = storeCarCharIsInNoSave(PLAYER_PED)
            setCarHealth(car, 1000)
          end
          imgui.Spacing()
          imgui.TextColored(imgui.ImVec4(r,g,b,1), "SOMENTE COM PLAYER DENTRO:")
          if imgui.Checkbox("ATRAVESSAR CARROS", atravessar_carros_t) then
            atravessar_carros = atravessar_carros_t[0]
          end
        elseif current_lab == 4 then
          imgui.Text("TELEPORTE JOGADOR POR ID")
          imgui.InputInt(" ", id_player)
          local id = id_player[0]
          local nick = sampGetPlayerNickname(id)
          local text = string.format("Player: %s", nick)
          imgui.Text(text)
          if imgui.Button("TELEPORTE") then
            if id > 0 then
              local res, ped = sampGetCharHandleBySampPlayerId(id)
              if res and doesCharExist(ped) then
                local x,y,z = getCharCoordinates(ped)
                setCharCoordinates(PLAYER_PED, x,y+2.0,z)
              end
            end
          end
        elseif current_lab == 5 then
          imgui.Text("RISCO DE BAN")
          if imgui.Button("PUXAR DESERT") then
            giveWeaponToChar(PLAYER_PED, 24, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR M4A1") then
            giveWeaponToChar(PLAYER_PED, 31, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR AK47") then
            giveWeaponToChar(PLAYER_PED, 30, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR SHOTGUN") then
            giveWeaponToChar(PLAYER_PED, 27, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR RPG") then
            giveWeaponToChar(PLAYER_PED, 35, 100)
          end
          imgui.Spacing()
          if imgui.Button("PUXAR MP5") then
            giveWeaponToChar(PLAYER_PED, 29, 100)
          end
          if imgui.Button(" REMOVER TODAS AS ARMAS") then
            removeAllCharWeapons(PLAYER_PED)
          end
          if imgui.Button(" SETAR MUNICAO (TODAS AS ARMAS)") then
            for weaponID = 24, 50 do 
                addAmmoToChar(PLAYER_PED, weaponID, 100) 
            end
          end
          imgui.Spacing()
          imgui.InputInt(" ", id_arma)
          local id_armaP = id_arma[0]
          if imgui.Button("PUXAR ARMA POR ID") then
            giveWeaponToChar(PLAYER_PED, id_armaP, 100)
          end
        end
        imgui.SetWindowFontScale(1.0)
        imgui.EndChild()
        imgui.End()
        imgui.PopFont()
      end
    end)
sampRegisterChatCommand("ack", function() sampAddChatMessage("[MENU] PINK MENU ATIVO ESPERO QUE SE DIVIRTA", 0xFFFF69B4) menu[0] = not menu[0] end)

function main()
  while not isSampAvailable() do wait(0) end
  sampAddChatMessage("[MENU] DIGITE /ack PARA ATIVAR", 0xFFFF69B4)
  while true do
    local color = rgbRainbowHex(2.0, 1)  -- muda automaticamente
      
    wait(0)
    esps(color)
    esp_esqueleto()
    atravessar_player_f()
    speed_hack_f()
    god_mod_f()
    atravessar_carros_f()
    if correr_sem_cansar then
      setPlayerNeverGetsTired(PLAYER_HANDLE, true)
    end
  end
end