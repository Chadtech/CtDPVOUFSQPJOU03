express = require 'express'
app = express()
http = require 'http'
{join} = require 'path'

PORT = Number process.env.PORT or 8097

app.use express.static join __dirname, 'public'

app.get '/*', (request, response) ->
  htmlFileThroughWhichAllContentIsFunnelled = join __dirname, 'public/index.html'
  response.status 200
    .sendFile htmlFileThroughWhichAllContentIsFunnelled

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT