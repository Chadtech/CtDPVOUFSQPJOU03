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
    projectPath = projectTitle + '/' + projectTitle + '.json'
    fs.exists projectPath, (exists) ->
      return next() unless exists
      fs.readFile projectPath, 'utf8', (error, data) ->
        if error
          return next error
        response.json project: JSON.parse data

  .post (request, response, next) ->
    projectTitle = request.body.title
    fs.exists projectTitle, (exists) ->
      if exists
        JSONInPath = projectTitle + '/' + projectTitle + '.json'
        fs.writeFile JSONInPath, JSON.stringify request.body, null, 2
        response.json msg: 'WORKD'
      else
        fs.mkdir projectTitle, (error) ->
          if not error
            JSONInPath = projectTitle + '/' + projectTitle + '.json'
            fs.writeFile JSONInPath, JSON.stringify request.body, null, 2
            response.json msg: 'WORKD'
          else
            console.log 'DID NOT WORK'
            console.log error

router.route '/play/:project'
  .post (request, response, next) ->
    project = Nr.read request.params.project
    project = Nr.play project
    response.json {buffer: project}

app.use express.static join __dirname, 'public'

app.use '/api', router

app.get '/*', (request, response, next) ->
  htmlFileThroughWhichAllContentIsFunnelled = join __dirname, 'public/index.html'
  response.status 200
    .sendFile htmlFileThroughWhichAllContentIsFunnelled

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT