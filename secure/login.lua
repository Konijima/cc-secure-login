local sha256 = require('/secure/sha256')

local credentials

local function clear()
    term.clear()
    term.setCursorPos(1, 1)
end

local function writeError(message)
    term.setTextColour(colors.red)
    term.write('(' .. message .. ')')
    term.setTextColour(colors.white)
end

local function recoveryLogin()
    local sides = peripheral.getNames()
    for i, side in ipairs(sides) do
        if disk.isPresent(side) then
            local recoveryPath = fs.combine(disk.getMountPath(side), '.recovery')
            if fs.exists(recoveryPath) then

                local function safeRead()
                    local reader = fs.open(recoveryPath, 'r')
                    local json = reader.readAll()
                    reader.close()

                    return sha256.digest(json):toHex()
                end

                local status, recovery = pcall(safeRead)
                if status then
                    return recovery == sha256.digest(textutils.serialiseJSON(credentials)):toHex()
                end
            end
        end
    end
end

local function login()
    local status, username, password, message

    -- Prompt username
    while username ~= credentials.username or not status do
        clear()
        io.write('SECURE LOGIN ')
        if message then writeError(message) end
        io.write('\nUsername > ')
        status, username = pcall(read)
        if username ~= credentials.username then message = 'User ' .. username .. ' not found!' end
        if username == '' then message = 'Username cannot be empty!' end
        if status == false then message = 'Cannot terminate during login!' end
    end

    message = nil -- clear previous message

    -- Prompt password
    while not passwordMatch or not status do
        clear()
        io.write('SECURE LOGIN ')
        if message then writeError(message) end
        print('\nUsername > ' .. username)
        io.write('Password > ')
        status, password = pcall(read)
        passwordMatch = sha256.hmac(os.getComputerID(), password):toHex() == credentials.password
        if not passwordMatch then message = 'Password do not match!' end
        if password == '' then message = 'Password cannot be empty!' end
        if status == false then message = 'Cannot terminate during login!' end
    end

    clear()
    print('Welcome ' .. username)
end

-- Login if secure is setup
if fs.exists('.login') then
    local reader = fs.open('.login', 'r')
    local json = reader.readAll()
    reader.close()

    credentials = textutils.unserialiseJSON(json)

    if not recoveryLogin() then
        login()
    end
end
