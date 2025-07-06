-- ����� ������ ���
NewDayEvent = {
  this_day_already_invoked_listeners = {},
  listeners_waiting = {}
}

NewDayEvent.listeners = {}

NewDayEvent.AddListener =
function(desc, func)
  NewDayEvent.listeners[desc] = func
end

NewDayEvent.RemoveListener =
function(desc)
  NewDayEvent.listeners[desc] = nil
end

NewDayEvent.InvokeAfter = 
function (prev_listener, this_listener)
  if not NewDayEvent.listeners_waiting[this_listener] then
    NewDayEvent.listeners_waiting[this_listener] = {}
  end
  local length = NewDayEvent.listeners_waiting[this_listener]
  NewDayEvent.listeners_waiting[this_listener][length + 1] = prev_listener
end

NewDayEvent.FinishInvoking = 
function (listener)
  NewDayEvent.this_day_already_invoked_listeners[listener] = 1
end

NewDayEvent.Invoke =
function(day)
  NewDayEvent.this_day_already_invoked_listeners = {}
  for desc, func in NewDayEvent.listeners do
    if NewDayEvent.listeners_waiting[desc] then
      startThread(
      function ()
        local desc = %desc
        while 1 do
          local listeners_done = 0
          local listeners_done_needed = len(NewDayEvent.listeners_waiting[desc])
          for i, listener in NewDayEvent.listeners_waiting[desc] do
            if NewDayEvent.this_day_already_invoked_listeners[listener] then
              listeners_done = listeners_done + 1
            end
          end
          if listeners_done == listeners_done_needed then
            break
          end
          sleep()
        end
        startThread(NewDayEvent.RunHandler, desc, %func, %day)
      end)
    else
      startThread(NewDayEvent.RunHandler, desc, func, day)
    end
  end
end

NewDayEvent.RunHandler = 
function(desc, func, day)
	func(day)
	NewDayEvent.this_day_already_invoked_listeners[desc] = 1
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