fs = require 'fs'
express = require 'express'
app = express()
http = require 'http'
{join} = require 'path'
bodyParser = require 'body-parser'
Nr = require './noideread'


app.use bodyParser.urlencoded {extended: true}
app.use bodyParser.json()

PORT = Number process.env.PORT or 8097

router = express.Router()

router.use (request, response, next) ->
  console.log 'SOMETHIGN HAPPEN'
  next()

router.route '/:project'
  .get (request, response, next) ->
    projectTitle = request.params.project
    projectTitle = projectTitle + '/' + projectTitle + '.json'
    fs.exists projectTitle, (exists) ->
      return next() unless exists
      fs.readFile projectTitle, 'utf8', (error, data) ->
        if error
          return next error
        response.json project: JSON.parse data

  .post (request, response, next) ->
    projectTitle = request.body.title
    fs.mkdir projectTitle, (error) ->
      if not error
        JSONInPath = projectTitle + '/' + projectTitle + '.json'
        fs.writeFile JSONInPath, JSON.stringify request.body, null, 2
        response.json msg: 'WORKD'

router.route '/play/:project'
  .post (request, response, next) ->
    Nr.read request.params.project, request.body
    response.json {msg: 'WANT PLAY PROJECT'}

app.use express.static join __dirname, 'public'

app.use '/api', router

app.get '/*', (request, response, next) ->
  htmlFileThroughWhichAllContentIsFunnelled = join __dirname, 'public/index.html'
  response.status 200
    .sendFile htmlFileThroughWhichAllContentIsFunnelled

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT