script_author('Andrey Sinyak')
script_version('1.0')

local dlstatus = require('moonloader').download_status
local ev = require "lib.samp.events"
local imgui = require "imgui"
local encoding = require "encoding"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local active = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local respect = 0
local money = 0

local tag = "[GTH]:"


function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand('getinfo', function()
    active.v = not active.v
    end)


    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)
    imgui.Process = true

    update()
    while true do
        wait(0)

    end
end


function imgui.OnDrawFrame()
imgui.ShowCursor = false
if active.v then
    imgui.SetNextWindowSize(imgui.ImVec2(150,100), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowPos(imgui.ImVec2((sw / 1.08),(sh / 3)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.Begin('info', active ,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    imgui.Text('money: '..money)
    imgui.Text('respect: '..respect)
    imgui.End()
end
end

function ev.onServerMessage(color, text)
  if text:find(nick) and text:find('сделал объезд') and text:find('бандитские респекты.(%d+)') then
  sampAddChatMessage('нашло респекты', -1)
    new_respect = text:match('бандитские респекты.(%d+)')
    respect = respect + new_respect
  end
  if text:find(nick) and text:find('сделал объезд') and text:find('деньги: $(%d+)') then
    new_money = text:match('деньги: $(%d+)')
    money = money + new_money
  end
end

--[[AUTOUPDATE]]
function update()
  local fpath = os.getenv('TEMP') .. '\\'..thisScript().name..'_version.json' -- куда будет качаться наш файлик для сравнения версии
  downloadUrlToFile('https://raw.githubusercontent.com/AndreySinyak/GhettoTerriroryHelper/main/update.ini?token=AURIDR5PRRLAVT363VVKHVTAZW5W4', fpath, function(id, status, p1, p2) -- ссылку на ваш гитхаб где есть строчки которые я ввёл в теме или любой другой сайт
    if status == dlstatus.STATUS_ENDDOWNLOADDATA then
    local f = io.open(fpath, 'r') -- открывает файл
    if f then
      local info = decodeJson(f:read('*a')) -- читает
      updatelink = info.updateurl
      if info and info.latest then
        version = tonumber(info.latest) -- переводит версию в число
        if version > tonumber(thisScript().version) then -- если версия больше чем версия установленная то...
          lua_thread.create(goupdate) -- апдейт
        else -- если меньше, то
          update = false -- не даём обновиться
          sampAddChatMessage((tag..' Текущая версия скрипта: '..thisScript().script_version..'. Обновление не требуется.'), -1)
        end
      end
    end
  end
end)
end
--скачивание актуальной версии
function goupdate()
sampAddChatMessage((tag..' Обнаружено новое обновление, загружаю.'), -1)
wait(300)
downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23) -- качает ваш файлик с latest version
  if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
  sampAddChatMessage((tag..' Обновление завершено!'), -1)
  thisScript():reload()
end
end)
end