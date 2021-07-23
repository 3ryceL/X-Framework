RegisterNetEvent('XCore:NotifyClient:OnPlayerLoaded')
AddEventHandler('XCore:NotifyClient:OnPlayerLoaded', function()
    TriggerServerEvent("x-admin:server:loadCompanies")
end)

RegisterNetEvent('x-companies:client:setCompanies')
AddEventHandler('x-companies:client:setCompanies', function(companiesList)
	Config.Companies = companiesList
end)

function GetCompanies()
	local companyList = {}
	if Config.Companies ~= nil then 
		for name, company in pairs(Config.Companies) do
			if company.owner == XCore.Functions.GetPlayerData().citizenid then
				companyList[company.name] = {
					name = company.name,
					label = company.label,
					rank = Config.MaxRank,
				}
			elseif company.employees ~= nil then 
				if company.employees[XCore.Functions.GetPlayerData().citizenid] ~= nil then 
					companyList[company.name] = {
						name = company.name,
						label = company.label,
						rank = company.employees[XCore.Functions.GetPlayerData().citizenid].rank,
					}
				end
			end
		end
	end
	return companyList
end

function GetCompanyRank(companyName)
	local rank = 0
	if Config.Companies[companyName] ~= nil then 
		if Config.Companies[companyName].employees ~= nil then 
			if Config.Companies[companyName].employees[XCore.Functions.GetPlayerData().citizenid] ~= nil then 
				rank = Config.Companies[companyName].employees[XCore.Functions.GetPlayerData().citizenid].rank
			elseif Config.Companies[companyName].owner == XCore.Functions.GetPlayerData().citizenid then
				rank = Config.MaxRank
			end
		else
			if Config.Companies[companyName].owner == XCore.Functions.GetPlayerData().citizenid then
				rank = Config.MaxRank
			end
		end
	end
	return rank
end

function IsEmployee(companyName)
	local retval = false
	if Config.Companies[companyName] ~= nil then 
		if Config.Companies[companyName].employees ~= nil then 
			if Config.Companies[companyName].employees[XCore.Functions.GetPlayerData().citizenid] ~= nil then 
				retval = true
			elseif Config.Companies[companyName].owner == XCore.Functions.GetPlayerData().citizenid then
				retval = true
			end
		else
			if Config.Companies[companyName].owner == XCore.Functions.GetPlayerData().citizenid then
				retval = true
			end
		end
	end
	return retval
end

function GetCompanyInfo(companyName)
	local retval = nil
	if Config.Companies[companyName] ~= nil then 
		retval = Config.Companies[companyName]
	end
	return retval
end

