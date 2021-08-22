local http = require("http")
local timer = require("timer")

-- "A web dyno must bind to its assigned $PORT within 60 seconds of startup."
-- see https://devcenter.heroku.com/articles/dynos#web-dynos
local port = process.env["PORT"]

timer.setInterval(900000, function()
    http.get("https://rocky-eyrie-66874.herokuapp.com/")
end)

http.createServer(function(req, res)
    local body = "Hello world\n"
    res:setHeader("Content-Type", "text/plain")
    res:setHeader("Content-Length", #body)
    res:finish(body)
end):listen(port)

require("./bot")
