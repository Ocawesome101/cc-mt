-- Check that the kernel is still running --

local prog = "/lib/amialive.lua" -- The filename, for convenience if I decide to move it

local function log(msg)
  term.setTextColor(colors.magenta)
  write("* ")
  term.setTextColor(colors.white)
  write(msg)
end

local function panic(reason)
  local reason = reason or "No reason given"
  local w,h = term.getSize()
  log(("="):rep(w - 2))
  log(prog .. ": Kernel panic detected")
  log("Panic reason: " .. reason)
  log(("="):rep(w - 2))
end

if thread then
  local status, psdata = thread.getStatus("kernel")
  if status == "running" then
    return -- We're not needed
  elseif status == "exited" then
    log(prog .. ": Kernel exited")
    sleep(1)
    log(prog .. ": Attempting system shutdown")
    sleep(1)
    os.shutdown()
  elseif status == "crashed" then
    panic(psdata.crash_reason or "Kernel crash")
    sleep(3)
    log(prog .. ": Attempting system restart")
    sleep(1)
    os.reboot()
  end
end
