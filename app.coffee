app = require 'app'
BrowserWindow = require 'browser-window'
path = require 'path'
fs = require 'fs-extra'

# Environment
global.ROOT = __dirname
global.EXECROOT = path.join(process.execPath, '..')

config = require './lib/config'
proxy = require './lib/proxy'
{log, warn, error} = require './lib/utils'

global.mainWindow = mainWindow = null

# Proxy setting
listenPort = config.get 'poi.port', 12450
app.commandLine.appendSwitch 'proxy-server', "127.0.0.1:#{listenPort}"
app.commandLine.appendSwitch 'ignore-certificate-errors'

# Pepper Flash
if process.platform == 'linux'
  try
    fs.accessSync path.join(EXECROOT, 'PepperFlash', 'linux', 'libpepflashplayer.so')
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(EXECROOT, 'PepperFlash', 'linux', 'libpepflashplayer.so')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.188'
  catch e
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(ROOT, 'PepperFlash', 'linux', 'libpepflashplayer.so')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.188'
else if process.platform == 'win32'
  try
    fs.accessSync path.join(EXECROOT, 'PepperFlash', 'win32', 'pepflashplayer32.dll')
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(EXECROOT, 'PepperFlash', 'win32', 'pepflashplayer32.dll')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.188'
  catch e
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(ROOT, 'PepperFlash', 'win32', 'pepflashplayer32.dll')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.188'
else if process.platform == 'darwin'
  try
    fs.accessSync path.join(EXECROOT, 'PepperFlash', 'darwin', 'PepperFlashPlayer.plugin')
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(EXECROOT, 'PepperFlash', 'darwin', 'PepperFlashPlayer.plugin')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.169'
  catch e
    app.commandLine.appendSwitch 'ppapi-flash-path', path.join(ROOT, 'PepperFlash', 'darwin', 'PepperFlashPlayer.plugin')
    app.commandLine.appendSwitch 'ppapi-flash-version', '17.0.0.169'

app.on 'window-all-closed', ->
  app.quit() unless process.platform == 'darwin'

app.on 'ready', ->
  screen = require 'screen'
  screenSize = screen.getPrimaryDisplay().workAreaSize
  global.mainWindow = mainWindow = new BrowserWindow
    x: config.get 'poi.window.x', 0
    y: config.get 'poi.window.y', 0
    width: config.get 'poi.window.width', screenSize.width
    height: config.get 'poi.window.height', screenSize.height
    'web-preferences':
      'web-security': false
      'plugins': true
  mainWindow.loadUrl "file://#{__dirname}/index.html"
  if process.env.DEBUG?
    mainWindow.openDevTools
      detach: true
  mainWindow.on 'close', ->
    # Save current position and size
    bounds = mainWindow.getBounds()
    config.set 'poi.window', bounds
    # Close all sub window
    require('./lib/window').closeWindows()
  mainWindow.on 'closed', ->
    mainWindow = null

# Uncaught error
process.on 'uncaughtException', (e) ->
  error e
