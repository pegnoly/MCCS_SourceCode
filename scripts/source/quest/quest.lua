--------------------------------------------------------------------------------
-- ��� ��������� ������ � ��������
-- ������ ������� Q_NAMES = {['������ ��� ������'] = '��������'} ��� ���������� ������
-- (����� ����������� � ������)

Quest = {
	Names = {}
}
Quest.is_loaded = nil

Quest.Start =
function(obj, hero, player)
  player = player or PLAYER_1
  SetObjectiveState(obj, OBJECTIVE_ACTIVE, player)
  if hero then
    MessageQueue.AddMessage(player, {"/Text/Default/Quest/quest_started.txt"; q_name = Quest.Names[obj]}, hero, 6.0)
  end
end

Quest.Update =
function(obj, progress, hero, player)
  player = player or PLAYER_1
  SetObjectiveProgress(obj, progress, player)
  if hero then
    MessageQueue.AddMessage(player, {"/Text/Default/Quest/quest_updated.txt"; q_name = Quest.Names[obj]}, hero, 6.0)
  end
end

Quest.Finish =
function(obj, hero, player)
  player = player or PLAYER_1
  SetObjectiveState(obj, OBJECTIVE_COMPLETED, player)
  if hero then
    MessageQueue.AddMessage(player, {"/Text/Default/Quest/quest_finished.txt"; q_name = Quest.Names[obj]}, hero, 6.0)
  end
end

Quest.Fail =
function(obj, hero, player)
  player = player or PLAYER_1
  SetObjectiveState(obj, OBJECTIVE_FAILED, player)
  if hero then
    MessageQueue.AddMessage(player, {"/Text/Default/Quest/quest_failed.txt"; q_name = Quest.Names[obj]}, hero, 6.0)
  end
end

Quest.GetProgress =
function(obj, player)
  player = player or PLAYER_1
  local progress = GetObjectiveProgress(obj, player)
  return progress
end

Quest.IsUnknown =
function(obj, player)
  player = player or PLAYER_1
  return GetObjectiveState(obj, player) == OBJECTIVE_UNKNOWN
end

Quest.IsActive =
function(obj, player)
  player = player or PLAYER_1
  return GetObjectiveState(obj, player) == OBJECTIVE_ACTIVE
end

Quest.IsFailed =
function(obj, player)
  player = player or PLAYER_1
  return GetObjectiveState(obj, player) == OBJECTIVE_FAILED
end

Quest.IsCompleted =
function(obj, player)
  player = player or PLAYER_1
  return GetObjectiveState(obj, player) == OBJECTIVE_COMPLETED
end

--------------------------------------------------------------------------------
--

QUESTMARK_OBJ_NEW = 1
QUESTMARK_OBJ_IN_PROGRESS = 2
QUESTMARK_OBJ_NEW_PROGRESS = 3
QUESTMARK_NO_OBJ = 4

QUESTMARK_HEIGHT_TAVERN = 7
QUESTMARK_HEIGHT_ARTIFACT_MERCHANT = 3
QUESTMARK_HEIGHT_ELEMENTAL_STOCKPILE = 5

Quest.Questmarks = {
  [QUESTMARK_OBJ_NEW] = 'Art_blue', 
  [QUESTMARK_OBJ_IN_PROGRESS] = 'Art_gold', 
  [QUESTMARK_OBJ_NEW_PROGRESS] = 'Art_green', 
  [QUESTMARK_NO_OBJ] = 'Art_red'
}

Quest.SetObjectQuestmark =
function(object, mark, height)
  height = height or 2
  pcall(Quest.ResetObjectQuestmark, object)
  sleep()
  FX.Play(Quest.Questmarks[mark], object, object..'_questmark', 0, 0, height)
end

Quest.ResetObjectQuestmark =
function(object)
  StopVisualEffects(object..'_questmark')
end

Quest.is_loaded = 1