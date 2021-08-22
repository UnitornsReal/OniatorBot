local discordia = require("discordia")
local coro = require("coro-http")
local json = require("json")
local timer = require("timer")
local client = discordia.Client()

local prefix = "!"

local commands = {
	{command = "cmds", description = "Tells you this!"},
	{command = "ping", description = "Replys Pong!"},
	{command = "cool", description = "Tells how cool you are!"},
	{command = "meme", description = "Sends a random meme!"},
	{command = "pizza", description = "Sends a random picture of picture from reddit!"},
	{command = "makeline", description = "Get money for working makeline!"},
	{command = "landing", description = "Get money for working landing!"},
	{command = "crime", description = "Get money for doing crimes or get caught and get fined!"},
	{command = "front", description = "Get money for working fronts!"},
	{command = "balance", description = "Tells you the balance of your cash from working!"}
}

local crimes = {
	{"stealing from the safe", "stealing from the till", "pickpocketing a co-worker", "breaking the TV"},
	{"stole from the safe", "took money from the till", "scammed a customer"}
}

local function Set(list)
	local set = {}
	for k, v in pairs(list) do 
		set[v] = true
	end
	return set
end
local allowedChannels = Set{"878807110761209856", "874359046008868865"}

local wait = {}

local function delay(id, c)
    for i,v in pairs(wait) do
        if type(v) == "table" then
            if v.ID == id then
                if v.cmd == c then
                    return true, v
                end
            end
        end
    end
    return false
end

client:on("messageCreate", function(Msg)
	local content = Msg.content
	local Member = Msg.member
	local ID = Msg.member.id
	local guildID = Msg.guild.id
	local channelID= Msg.channel.id

	if string.sub(content:lower(), 1, #prefix) == prefix then
		local split = {}

		for str in string.gmatch(string.sub(content:lower(), #prefix + 1), "%S+") do
			table.insert(split, str)
		end

		local command = string.lower(split[1])
		local arguments = {table.unpack(split, 2)}

		local function ecoCommands(command, rand1, rand2)
			local isCool, Table = delay(ID, command) 
			if not isCool then
				local open = io.open("eco.json", "r")
				local parse = json.parse(open:read())
				local earned = math.random(rand1, rand2)
				open:close()
			
				table.insert(wait, {ID = Member.id, cmd = command, time = 3600})
			
				if parse[ID] then
					parse[ID] = parse[ID] + earned
				else
					parse[ID] = earned
				end
			
				Msg:reply("<@!"..ID.."> has earned $"..earned.." from working "..command.."!")
			
				open = io.open("eco.json", "w")
				open:write(json.stringify(parse))
				open:close()
			elseif Table ~= nil then
				local hours = math.floor(Table.time / (60*60))
				local minutes = math.floor(Table.time / 60)
				local seconds = math.floor(Table.time%60)
				Msg:reply("<@!"..ID.."> sorry but you still have to wait **"..string.format("%.2d:%.2d:%.2d", hours, minutes, seconds).."**!")
			end
		end

		if allowedChannels[channelID] then
			if command:lower() == "cool" then
				timer.sleep(1)
		
				local mentioned = Msg.mentionedUsers
		
				if #mentioned == 1 then
					local mentionedId =  mentioned[1][1]
		
					if mentionedId == "296451028428259328" then
						Msg:reply("<@!"..mentioned[1][1].."> is 100% cool! :sunglasses:")
					else
						Msg:reply("<@!"..mentioned[1][1].."> is "..math.random(1,100).."% cool! :sunglasses:")
					end
				elseif #mentioned == 0 then
					if ID == "296451028428259328" then
						Msg:reply("<@!"..ID.."> is 100% cool! :sunglasses:")
					else
						Msg:reply("<@!"..ID.."> is "..math.random(1,100).."% cool! :sunglasses:")
					end
				end
			end
		
			if command:lower() == "ping" then
				Msg:reply("Pong!")
		
			end
		
			if command:lower() == "cmd" or command:lower() == "cmds" then
				local lists = "```"
		
				for k,v in pairs(commands) do 
					lists = lists..v.command..": "..v.description.."\n"
				end
				lists = lists.."```"

				Msg:reply{  
					embed = {
						title = "Commands",
						fields = {
							{name = "Cmds", value = "Tells you this!", inline = false},
							{name = "Meme", value = "Sends a random meme!", inline = true},
							{name = "Pizza", value = "Sends you pizza!", inline = true},
							{name = "Cool", value = "Tells how cool you are!", inline = false},
							{name = "Makeline", value = "Get money for working makeline!", inline = true},
							{name = "Landing", value = "Get money for working landing!", inline = true},
							{name = "Crime", value = "Get money for doing crimes or get caught and get fined!", inline = true},
							{name = "Front", value = "Get money for working front!", inline = true},
							{name = "Balance", value = "Tells you the balance of your cash from working!", inline = true}
						},
						color = discordia.Color.fromRGB(235, 100, 52).value,
						timestamp = discordia.Date():toISO('T', 'Z')
					}
				}
		
			end

			if command:lower() == "meme" then
				Msg:reply("Fetching you a meme!")

				local subReddits = {"memes", "dankmemes"}
				local subreddit = subReddits[math.random(1, #subReddits)]
				local link = "https://meme-api.herokuapp.com/gimme/"..subreddit
				local result, body = coro.request("GET", link)
				
				body = json.parse(body)
				Msg:reply{  
					embed = {
						title = body["title"],
						image = {
							url = body["url"]
						},
						fields = {
							{name = "Subreddit", value = body["subreddit"], inline = true},
							{name = "Upvotes", value = body["ups"], inline = true},
							{name = "Author", value = body["author"], inline = true}
						},
						color = discordia.Color.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)).value,
						timestamp = discordia.Date():toISO('T', 'Z')
					}
				}
			elseif command:lower() == "pizza" then
				Msg:reply("Fetching you pizza!")

				local link = "https://meme-api.herokuapp.com/gimme/littlecaesars"
				local result, body = coro.request("GET", link)
				
				body = json.parse(body)
				Msg:reply{  
					embed = {
						title = body["title"],
						image = {
							url = body["url"]
						},
						fields = {
							{name = "Subreddit", value = body["subreddit"], inline = true},
							{name = "Upvotes", value = body["ups"], inline = true},
							{name = "Author", value = body["author"], inline = true}
						},
						color = discordia.Color.fromRGB(235, 100, 52).value,
						timestamp = discordia.Date():toISO('T', 'Z')
					}
				}
			end

			if command:lower() == "makeline"  then
				ecoCommands("makeline", 7.5, 12)
			elseif command:lower() == "landing" then
				ecoCommands("landing", 7.5, 12)
			elseif command:lower() == "front" then
				ecoCommands("front", 8, 15)
			elseif command:lower() == "crime" then
				local isCool, Table = delay(ID, command) 

				if not isCool then
					local open = io.open("eco.json", "r")
					local parse = json.parse(open:read())
					local chances = {1, 2, 3, 4}
					local chance = chances[math.random(1, #chances)]
					local EoT = math.random(10, 20)
					open:close()
					table.insert(wait, {ID = Member.id, cmd = "crime", time = 1800})

					if chance == 1 then
						if parse[ID] then
							parse[ID] = parse[ID] + EoT
						else
							parse[ID] = EoT
						end

						local chosenSafe = crimes[2][math.random(1, #crimes[2])]
						Msg:reply("<@!"..ID..">You " ..chosenSafe.. " and got $"..EoT)

						open = io.open("eco.json", "w")
						open:write(json.stringify(parse))
						open:close()
					else
						if parse[ID] then
							parse[ID] = parse[ID] - EoT
						else
							parse[ID] = -EoT
						end

						local chosenUnSafe = crimes[1][math.random(1, #crimes[1])]
						Msg:reply("<@!"..ID.."> You got caught "..chosenUnSafe.." and was fined $"..EoT)

						open = io.open("eco.json", "w")
						open:write(json.stringify(parse))
						open:close()
					end
				else
					local hours = math.floor(Table.time / (60*60))
					local minutes = math.floor(Table.time / 60)
					local seconds = math.floor(Table.time%60)
					Msg:reply("<@!"..ID.."> sorry but you still have to wait **"..string.format("%.2d:%.2d:%.2d", hours, minutes, seconds).."** before you can use crime!")
				end
			elseif command:lower() == "bal" or command:lower() == "balance" then
				local mentioned = Msg.mentionedUsers

				if #mentioned == 1 then
					local open = io.open("eco.json", "r")
					local parse = json.parse(open:read())
					open:close()
					Msg:reply("<@!"..mentioned[1][1].."> has $"..(parse[mentioned[1][1]] or 0))
				elseif #mentioned == 0 then
					local open = io.open("eco.json", "r")
					local parse = json.parse(open:read())
					open:close()
					Msg:reply("<@!"..ID.."> has $"..(parse[ID] or 0))
				end
			end

			if command:lower() == "leave" then
				if ID == "296451028428259328" then
					Msg.guild:leave()
				end
			end
		else
			Msg:reply("Please do commands in <#878807110761209856> !")
		end
	end
end)

timer.setInterval(1000, function()
    for k,v in pairs(wait) do
        if type(v) == "table" then
            if v.time > 0 then
                wait[k].time = wait[k].time - 1
            else
                wait[k] = nil
            end
        end
    end
end)

client:run("Bot ".."NzIxNzg4MDA0NjYxOTg1MzIw.XuZndg.0aSnYsOU6rUWrH-YQtRFSS9WL6M")
