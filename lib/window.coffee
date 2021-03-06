_ = require 'underscore'
BrowserWindow = require 'browser-window'
global.windows = windows = []
forceClose = false
module.exports =
  createWindow: (options) ->
    options = _.extend options,
      show: false
      'web-preferences':
        'web-security': false
        'plugins': true
    current = new BrowserWindow options
    current.on 'close', (e) ->
      current.hide()
      e.preventDefault() unless forceClose
    windows.push current
    return current
  # Warning: Don't call this method manually
  # It will be called before mainWindow closed
  closeWindows: ->
    forceClose = true
    for win, i in windows
      win.close()
      windows[i] = null
