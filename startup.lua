-- A startup script --

local ok, err = loadfile("/boot/kernel.lua")
if not ok then
  error(err)
end

local kernel = ok

local ok, err = loadfile("/lib/amialive.lua")
if not ok then
  error(err)
end

local alive = ok

local ok, err = loadfile("/lib/thread.lua") -- Load the multitasking engine
if not ok then
  error(err)
end

thread = ok()

if thread and kernel and alive then
-- TLCO for the win --
  local old_printError = printError 
  function printError(err)
    _G.printError = old_printError
    printError("Top-level Coroutine Override succeeded: Rednet errored with " .. err)
    thread.init(kernel, "kernel")
    thread.init(alive, "alive")
    thread.start()
  end
  local old_error = error 
  function _G.error(err)
    _G.error = old_error
    printError(err)
  end
  os.queueEvent("modem_message", 0, 0, 0, {})
end
