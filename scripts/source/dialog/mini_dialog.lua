SPEAKER_TYPE_HERO = 1
SPEAKER_TYPE_CREATURE = 2

MiniDialog = {}
MiniDialog.Sets = {}
MiniDialog.Paths = {}
MiniDialog.answer_for_player = {[PLAYER_1] = 6, [PLAYER_2] = 6, [PLAYER_3] = 6, [PLAYER_4] = 6, [PLAYER_5] = 6, [PLAYER_6] = 6, [PLAYER_7] = 6, [PLAYER_8] = 6}

doFile(GetMapDataPath().."dialogs_paths.lua")

MiniDialog.Start =
---@param name string
---@param alt_set string|nil
---@param player PlayerID|number|nil
---@param speakers_replace table<string|number, string|number>|nil
function(name, alt_set, player, speakers_replace)
  player = player or PLAYER_1
  alt_set = alt_set or "main"
  local dialog_file = MiniDialog.Paths[name].."/script.lua"
  doFile(dialog_file)
  while not MiniDialog.Sets[name] do
    sleep()
  end
  local steps_count = -1
  for step, _ in MiniDialog.Sets[name] do
    steps_count = steps_count + 1
  end
  --
  MiniDialog.Step(MiniDialog.Paths[name].."/", MiniDialog.Sets[name], 0, steps_count, alt_set, player, speakers_replace)
end

MiniDialog.Step =
---@param path string
---@param set string
---@param curr_step number
---@param max_step number
---@param alt_set string|nil
---@param player PlayerID|number
---@param speakers_replace table<string|number, string|number>|nil
function(path, set, curr_step, max_step, alt_set, player, speakers_replace)
  local answers = {"/Text/next.txt", "/Text/back.txt"}
  MiniDialog.answer_for_player[player] = 6
  if curr_step == 0 then
    answers[2] = nil
  elseif curr_step == max_step then
    answers = {"/Text/finish.txt", "/Text/back.txt"}
  end
  local saved_state = curr_step
  local curr_set, text
  if alt_set and set[curr_step.."_"..alt_set] then
    curr_set = set[curr_step.."_"..alt_set]
    text = path..curr_step.."_"..alt_set..".txt"
  else
    curr_set = set[curr_step.."_main"]
    text = path..curr_step.."_main.txt"
  end
  if speakers_replace and speakers_replace[curr_set.speaker] then
    curr_set.speaker = speakers_replace[curr_set.speaker]
  end
  local icon = ""
  if curr_set.speaker_type == SPEAKER_TYPE_HERO then
    icon = Hero.Params.Icon(curr_set.speaker) ---@diagnostic disable-line
  else
    icon = Creature.Params.Icon(curr_set.speaker)
  end
  if string.spread(icon)[1] ~= '/' then
    icon = '/'..icon
  end
  TalkBoxForPlayers(GetPlayerFilter(player), icon, nil,
                 text, nil,
                 'MiniDialog.Callback', 1,
                 nil,
                 nil, 0,
                 answers[1],
                 answers[2],
                 nil,
                 nil,
                 nil)
  while MiniDialog.answer_for_player[player] == 6 do
    sleep()
  end
  local ans = MiniDialog.answer_for_player[player]
  if ans < 1 then
    return
  else
    if ans == 1 then
      if saved_state == max_step then
        return
      else
        saved_state = saved_state + 1
      end
    else
      saved_state = saved_state - 1
    end
  end
  MiniDialog.Step(path, set, saved_state, max_step, alt_set, player)
end

MiniDialog.Callback =
function(player, answer)
  MiniDialog.answer_for_player[player] = answer
end