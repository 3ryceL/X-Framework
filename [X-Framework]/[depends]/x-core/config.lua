XConfig = {}

XConfig.MaxPlayers = GetConvarInt('sv_maxclients', 4) -- Gets max players from config file, default 32
XConfig.DefaultSpawn = vector4(-1035.71, -2731.87, 12.86, 0.0)

XConfig.Money = {}
XConfig.Money.MoneyTypes = {['cash'] = 500, ['bank'] = 5000, ['crypto'] = 0 } -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
XConfig.Money.DontAllowMinus = {'cash', 'crypto'} -- Money that is not allowed going in minus
XConfig.Money.PayCheckTimeOut = 10 -- The time in minutes that it will give the paycheck

XConfig.Player = {}
XConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
XConfig.Player.MaxInvSlots = 41 -- Max inventory slots for a player
XConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

XConfig.Server = {} -- General server config
XConfig.Server.closed = true -- Set server closed (no one can join except people with ace permission 'qbadmin.join')
XConfig.Server.closedReason = "Server Closed" -- Reason message to display when people can't join the server
XConfig.Server.uptime = 0 -- Time the server has been up.
XConfig.Server.whitelist = false -- Enable or disable whitelist on the server
XConfig.Server.discord = "" -- Discord invite link
XConfig.Server.PermissionList = {} -- permission list
