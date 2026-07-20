---@alias EventPriorityLevel
---|`EVENT_PRIORITY_HIGH`
---|`EVENT_PRIORITY_DEFAULT`
---|`EVENT_PRIORITY_LOW`
EVENT_PRIORITY_HIGH = 1
EVENT_PRIORITY_DEFAULT = 2
EVENT_PRIORITY_LOW = 3

---@class NewDayEventListener
---@field func fun(day: number)
---@field priority EventPriorityLevel
NewDayEventListener = {}

NewDayEvent = {
}

---@type table<string, NewDayEventListener>
NewDayEvent.listeners = {}

NewDayEvent.AddListener =
---@param desc string
---@param func fun(day: number)
---@param priority? EventPriorityLevel
function(desc, func, priority)
  priority = priority or EVENT_PRIORITY_DEFAULT
  NewDayEvent.listeners[desc] = { func = func, priority = priority }
end

NewDayEvent.RemoveListener =
function(desc)
  NewDayEvent.listeners[desc] = nil
end

NewDayEvent.Invoke =
function(day)
  local hpe = {}
  local dpe = {}
  local lpe = {}
  ---@param listener_data NewDayEventListener
  for desc, listener_data in NewDayEvent.listeners do
    if listener_data.priority == EVENT_PRIORITY_HIGH then
      hpe[desc] = 1
    elseif listener_data.priority == EVENT_PRIORITY_DEFAULT then
      dpe[desc] = 1
    else
      lpe[desc] = 1 
    end
  end

  ---@param desc string
  for desc, _ in hpe do
    local listener = NewDayEvent.listeners[desc]
    listener.func(day)
  end

  ---@param desc string
  for desc, _ in dpe do
    local listener = NewDayEvent.listeners[desc]
    listener.func(day)
  end

  ---@param desc string
  for desc, _ in lpe do
    local listener = NewDayEvent.listeners[desc]
    listener.func(day)
  end
end

-- ����� ����������� ���
CombatResultsEvent = {
	fight_tag_for_player = {}
}
CombatResultsEvent.listeners = {}

CombatResultsEvent.AddListener =
function(desc, func)
  CombatResultsEvent.listeners[desc] = func
end

CombatResultsEvent.RemoveListener =
function(desc)
  CombatResultsEvent.listeners[desc] = nil
end

CombatResultsEvent.Invoke =
function(fight_id)
  for desc, func in CombatResultsEvent.listeners do
    startThread(func, fight_id)
  end
end

-- ����� ��������� ������
LevelUpEvent = {}
LevelUpEvent.listeners = {}

LevelUpEvent.AddListener =
function(desc, func)
  LevelUpEvent.listeners[desc] = func
end

LevelUpEvent.RemoveListener =
function(desc)
  LevelUpEvent.listeners[desc] = nil
end

LevelUpEvent.Invoke =
function(hero)
  for desc, func in LevelUpEvent.listeners do
    startThread(func, hero)
  end
end

-- ����� ��������� �����
XpTrackingEvent = {}
XpTrackingEvent.listeners = {}

XpTrackingEvent.AddListener =
function(desc, func)
  XpTrackingEvent.listeners[desc] = func
end

XpTrackingEvent.RemoveListener =
function(desc)
  XpTrackingEvent.listeners[desc] = nil
end

XpTrackingEvent.Invoke =
function(hero, curr_exp, new_exp)
  for desc, func in XpTrackingEvent.listeners do
    startThread(func, hero, curr_exp, new_exp)
  end
end

-- ����� �������� �����
MapLoadingEvent = {}
MapLoadingEvent.listeners = {}

MapLoadingEvent.AddListener =
function(desc, func)
  MapLoadingEvent.listeners[desc] = func
end

MapLoadingEvent.RemoveListener =
function(desc)
  MapLoadingEvent.listeners[desc] = nil
end

MapLoadingEvent.Invoke =
function()
  for desc, func in MapLoadingEvent.listeners do
    print("<color=red>MapLoadingEvent.Invoke: <color=green>", desc)
    startThread(func)
  end
end


AddHeroEvent = {
  already_invoked_listeners = {},
  listeners_waiting = {}
}

AddHeroEvent.listeners = {}

AddHeroEvent.AddListener =
function(desc, func)
  AddHeroEvent.listeners[desc] = func
end

AddHeroEvent.RemoveListener =
function(desc)
  AddHeroEvent.listeners[desc] = nil
end

AddHeroEvent.InvokeAfter = 
function (prev_listener, this_listener)
  if not AddHeroEvent.listeners_waiting[this_listener] then
    AddHeroEvent.listeners_waiting[this_listener] = {}
  end
  local length = AddHeroEvent.listeners_waiting[this_listener]
  AddHeroEvent.listeners_waiting[this_listener][length + 1] = prev_listener
end

AddHeroEvent.FinishInvoking = 
function (listener)
  AddHeroEvent.already_invoked_listeners[listener] = 1
end

AddHeroEvent.Invoke =
function(hero)
  AddHeroEvent.already_invoked_listeners = {}
  for desc, func in AddHeroEvent.listeners do
    if AddHeroEvent.listeners_waiting[desc] then
      startThread(
      function ()
        local desc = %desc
        while 1 do
          local listeners_done = 0
          local listeners_done_needed = len(AddHeroEvent.listeners_waiting[desc])
          for i, listener in AddHeroEvent.listeners_waiting[desc] do
            if AddHeroEvent.already_invoked_listeners[listener] then
              listeners_done = listeners_done + 1
            end
          end
          if listeners_done == listeners_done_needed then
            break
          end
          sleep()
        end
        startThread(%func, %hero)
      end)
    else
      startThread(func, hero)
    end
  end
end

-- ����� �������� �����
RespawnHeroEvent = {}
RespawnHeroEvent.listeners = {}

RespawnHeroEvent.AddListener =
function(desc, func)
  RespawnHeroEvent.listeners[desc] = func
end

RespawnHeroEvent.RemoveListener =
function(desc)
  RespawnHeroEvent.listeners[desc] = nil
end

RespawnHeroEvent.Invoke =
function(hero)
  for desc, func in RespawnHeroEvent.listeners do
    startThread(func, hero)
  end
end

-- ����� �������� �����
RemoveHeroEvent = {}
RemoveHeroEvent.listeners = {}

RemoveHeroEvent.AddListener =
function(desc, func)
  RemoveHeroEvent.listeners[desc] = func
end

RemoveHeroEvent.RemoveListener =
function(desc)
  RemoveHeroEvent.listeners[desc] = nil
end

RemoveHeroEvent.Invoke =
function(hero)
  for desc, func in RemoveHeroEvent.listeners do
    startThread(func, hero)
  end
end