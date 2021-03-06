local LOGLEVEL = 'debug'

-- List of modules to load (found in modules/ dir)
local modules = {
  'appwindows',
  'battery',
  'browser',
  'caffeine',
  'cheatsheet',
  'hazel',
  'notational',
  'scratchpad',
  'songs',
  'timer',
  'weather',
  'wifi',
  'worktime',
}

-- global modules namespace (short for easy console use)
hsm = {}

-- load module configuration
local cfg = require('config')
hsm.cfg = cfg.global

-- log for init.lua only
local log = hs.logger.new(hs.host.localizedName(), LOGLEVEL)

-- load a module from modules/ dir, and set up a logger for it
local function loadModuleByName(modName)
  hsm[modName] = require('modules.' .. modName)
  hsm[modName].name = modName
  hsm[modName].log = hs.logger.new(modName, LOGLEVEL)
  log.i(hsm[modName].name .. ': module loaded')
end

-- save the configuration of a module in the module object
local function configModule(mod)
  mod.cfg = mod.cfg or {}
  if (cfg[mod.name]) then
    for k,v in pairs(cfg[mod.name]) do mod.cfg[k] = v end
    log.i(mod.name .. ': module configured')
  end
end

-- start a module
local function startModule(mod)
  if mod.start == nil then return end
  mod.start()
  log.i(mod.name .. ': module started')
end

-- stop a module
local function stopModule(mod)
  if mod.stop == nil then return end
  mod.stop()
  log.i(mod.name .. ': module stopped')
end

-- load, configure, and start each module
hs.fnutils.each(modules, loadModuleByName)
hs.fnutils.each(hsm, configModule)
hs.fnutils.each(hsm, startModule)

-- global function to stop modules and reload hammerspoon config
function hs_reload()
  hs.fnutils.each(hsm, stopModule)
  hs.reload()
end

-- load and bind key bindings
local bindings = require('bindings')
bindings.bind()

-- Disable all window animations
hs.window.animationDuration = 0

hs.alert.show('Hammerspoon Config Loaded', 1)
