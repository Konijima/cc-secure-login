local url = 'https://raw.githubusercontent.com/Konijima/cc-secure-login/master/'
local files = {
    'secure/login.lua',
    'secure/setup.lua',
    'secure/sha256.lua',
    'secure/startup.lua',
}

local downloads = {}
for i,file in ipairs(files) do
    local function download()
        local request = http.get(url .. file)
        local script = request.readAll()
        request.close()
        
        if fs.exists(file) then fs.delete(file) end
        local writer = fs.open(file, 'w')
        writer.write(script)
        writer.close()
    end
    table.insert(downloads, download)
end

-- Start
parallel.waitForAll(table.unpack(downloads))

print('Secure Login installed, run `secure/setup.lua` to secure your computer!')
