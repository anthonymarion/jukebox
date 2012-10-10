###
Module dependencies.
###
express     =  require  "express"
routes      =  require  "./routes"
user        =  require  "./routes/user"
http        =  require  "http"
path        =  require  "path"
browserify  =  require  "browserify"
fileify     =  require  "fileify"

app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", __dirname + "/views"
  app.set "view engine", "ejs"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser("your secret here")
  app.use express.session()
  app.use app.router

  publicDir = "#{__dirname}/public"

  app.use require("less-middleware") {
    src: "#{publicDir}/less"
    dest: "#{publicDir}/stylesheets"
    prefix: '/stylesheets'
    compress: false
  }

  app.use require("express-coffee") {
    path: publicDir
  }

  bundle = browserify {
    cache: false
    ignore: [ 'templates' ]
    require: [
      './public/app/app.coffee'
    ]
  }

  fileifyTemplates = fileify('templates', "#{publicDir}/app/templates", {
    watch: true
    extension: '.mjs'
    removeExtension: true
  })
  bundle.use fileifyTemplates

  app.use bundle

  app.use express.static(publicDir)

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index
app.get "/users", user.list

http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")

