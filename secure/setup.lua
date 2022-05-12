local sha256 = require('/secure/sha256')

local function clear(step)
    sleep(0.25)
    term.clear()
    term.setCursorPos(1, 1)
    print('LOGIN SETUP (' .. step .. ')')
end

local credentials = {
    username = '',
    password = '',
}

while credentials.username == '' do
    clear('Credentials')
    io.write('Username > ')
    credentials.username = read()
end

while credentials.password == '' do
    clear('Credentials')
    print('Username > ' .. credentials.username)
    io.write('Password > ')
    credentials.password = read()
end

credentials.password = sha256.hmac(os.getComputerID(), credentials.password):toHex()

-- Save credential to .login on root
local json = textutils.serialiseJSON(credentials)
local fw = fs.open('.login', 'w')
fw.write(json)
fw.close()

-- Delete existing startup.lua
if fs.exists('/startup.lua') then
    clear('Copying Startup')
    print('Startup file found, do you want to keep a backup?')
    io.write('y/N > ')
    local prompt = read()
    if string.lower(prompt) == 'y' then
        fs.move('/startup.lua', '/startup' .. os.epoch() .. '.lua.backup')
    else
        fs.delete('/startup.lua')
    end
end

-- Copy secure startup.lua on root
fs.copy('/secure/startup.lua', '/startup.lua')

-- Check for disk
local sides, peripherals = {}, peripheral.getNames()
for i, side in ipairs(peripherals) do
    if disk.isPresent(side) then table.insert(sides, side) end
end
if #sides > 0 then
    clear('Recovery Disk')
    print('Disk found, do you want to create a recovery disk?')
    io.write('y/N > ')
    local prompt = read()

    if string.lower(prompt) == 'y' then
        local selected
        while not selected and prompt ~= 'exit' do
            clear('Recovery Disk')
            print('Select disk: [ ' .. table.concat(sides, ', ') .. ' ]')
            io.write('side > ')
            prompt = read()
            if prompt ~= 'exit' then
                for i, side in ipairs(sides) do
                    if side == prompt then
                        selected = side
                    end
                end
            end
        end

        if selected then
            local savePath = fs.combine(disk.getMountPath(selected), '.recovery')
            if fs.exists(savePath) then fs.delete(savePath) end
            fs.copy('.login', savePath)
            local computerName = os.getComputerLabel() or os.getComputerID()
            disk.setLabel(selected, 'Recovery Disk [' .. computerName .. ']')
        end
    end
end

clear('Completed')
print('Setup completed, you will need to login after reboot, to disable, delete startup.lua')
