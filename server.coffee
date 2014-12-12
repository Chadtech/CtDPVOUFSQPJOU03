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
        response.json project: data

  .post (request, response, next) ->
    project = request.body.project
    project = JSON.parse project
    fs.exists project.title, (exists) ->
      if exists
        JSONInPath = project.title + '/' + project.title + '.json'
        fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
        response.json msg: 'WORKD'
      else
        fs.mkdir project.title, (error) ->
          if not error
            JSONInPath = project.title + '/' + project.title + '.json'
            fs.writeFileSync JSONInPath, JSON.stringify project, null, 2
            response.json msg: 'WORKD'
          else
            console.log 'DID NOT WORK'
            console.log error

router.route '/play/:project'
  .post (request, response, next) ->
    #console.log 'a', Nr.judgeNewest request.body.project
    #project = Nr.read request.params.project
    #project = Nr.play project
    response.json {buffer: Nr.judgeNewest request.body.project}

app.use express.static join __dirname, 'public'

app.use '/api', router

app.get '/*', (request, response, next) ->
  htmlFileThroughWhichAllContentIsFunnelled = join __dirname, 'public/index.html'
  response.status 200
    .sendFile htmlFileThroughWhichAllContentIsFunnelled

httpServer = http.createServer app

httpServer.listen PORT, ->
  console.log 'SERVER RUNNING ON ' + PORT