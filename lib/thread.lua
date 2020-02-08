-- A multitasking engine --

local tasks = {
  {
    name = "rednet",
    coro = coroutine.create(rednet.run),
    psinfo = {
      status = "running",
      data = {}
    }
  }
}

local thread = {}

local deadCoro = coroutine.resume(coroutine.create(loadfile("/lib/thread_deadCoroutine.lua")))

function thread.start() -- Begin running threads
  local eventData = { n = 0 }
  local filter = ""
  while true do
    eventData = { os.pullEventRaw() }
    for i=1, #tasks, 1 do
      local coro = tasks[i].coro
      if filter == "" or not filter or eventData[1] == filter or eventData[1] == "terminate" then
        local ok, param = coroutine.resume(coro, table.unpack( eventData ))
        if not ok then
          tasks[i].psinfo.status = "errored"
          tasks[i].psinfo.data.crash_reason = param
        else
          tasks[i].psinfo.status = "running"
          if param == "task_exit" then -- You can tell the scheduler that you've exited, and it'll register as exited
            tasks[i].coro = deadCoro
          else
            filter = param
          end
        end
        if coroutine.status(coro) == "dead" then
          tasks[i].psinfo.status = "exited"
        end
      end
    end
    eventData = { os.pullEventRaw() }
  end
end

function thread.init(func, name) -- Init a task
  table.insert(tasks, {name = name, coro = coroutine.create(func)})
end

function thread.kill(name, sig) -- Kill a task
  local sig = sig or "SIGQUIT"
  for i=1, #tasks, 1 do
    if tasks[i].name == name then
      local ok, param = coroutine.resume(tasks[i].coro, "signal", sig)
      if param == "task_exit" then
        tasks[i].coro = deadCoro
      end
      if sig == "SIGKILL" then
        tasks[i].coro = deadCoro
      end
    end
  end
end

function thread.getInfo(name)
  for i=1, #tasks, 1 do
    if tasks[i].name == name then
      return tasks[i].status, tasks[i].data
    end
  end
  return "exited", {}
end

return thread
