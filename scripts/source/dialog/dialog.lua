---@alias DialogEffect fun(player: PlayerID, state: any, answer: number, next_state: any): number

---@class DialogOption
---@field answer string
---@field next_state any
---@field is_enabled 1|nil
---@field is_custom_path 1|nil
DialogOption = {}

---@class DialogDefinition
---@field state any
---@field path string
---@field icon string
---@field effect DialogEffect
---@field title string
---@field select_text string
---@field options table<number, DialogOption[]>
---@field Open fun(player: PlayerID)
---@field Reset fun(player: PlayerID)
DialogDefinition = {}

Dialog =
{
    -- текущий активный диалог для игрока
    ---@type table<PlayerID, DialogDefinition>
    active_dialog_for_player = {},

    string_to_parse = "",

    -- текущий герой, использующий диалог для конкретного игрока
    ---@type table<PlayerID, string>
    active_hero_for_player =
    {
        [PLAYER_1] = '',
        [PLAYER_2] = '',
        [PLAYER_3] = '',
        [PLAYER_4] = '',
        [PLAYER_5] = '',
        [PLAYER_6] = '',
        [PLAYER_7] = '',
        [PLAYER_8] = ''
    },

    -- текущий ответ, выбранный конкретным игроком
    ---@type table<PlayerID, number>
    answer_for_player =
    {
        [PLAYER_1] = 6,
        [PLAYER_2] = 6,
        [PLAYER_3] = 6,
        [PLAYER_4] = 6,
        [PLAYER_5] = 6,
        [PLAYER_6] = 6,
        [PLAYER_7] = 6,
        [PLAYER_8] = 6
    },

    --- Открывает новый диалог
    ---@param dialog DialogDefinition
    ---@param hero string
    ---@param player PlayerID
    NewDialog = function(dialog, hero, player)
        local new_dialog = {}
        for k, v in dialog do
            new_dialog[k] = v
        end
        Dialog.Open(new_dialog, hero, player)
    end,

    --- Получает текущий активный диалог для игрока
    ---@param player PlayerID id игрока
    ---@return DialogDefinition dialog диалог
    GetActiveDialogForPlayer = function(player)
        local answer = Dialog.active_dialog_for_player[player]
        return answer
    end,

    ---@param player PlayerID
    ---@return string
    GetActiveHeroForPlayer = function (player)
        local answer = Dialog.active_hero_for_player[player]
        return answer
    end,

    ---@param dialog DialogDefinition
    ---@param hero string
    ---@param player PlayerID
    Open = function(dialog, hero, player)
        Dialog.active_dialog_for_player[player] = dialog
        Dialog.active_hero_for_player[player] = hero
        Dialog.active_dialog_for_player[player].Open(player)
    end,

    ---@param player PlayerID
    Action = function(player)
        local active_dialog = Dialog.GetActiveDialogForPlayer(player)
        -- print("Dialog.Action called for dialog: ", active_dialog)
        ---@type DialogOption|nil[]
        local options = {nil, nil, nil, nil, nil}
        local ans_num = 0
        for i = 1, length(active_dialog.options[active_dialog.state]) - 1 do
            if active_dialog.options[active_dialog.state][i] then
                ---@type DialogOption | string
                local option = active_dialog.options[active_dialog.state][i]
                if option.is_enabled then
                    ans_num = ans_num + 1
                    if type(option.answer) == "string" then
                        options[ans_num] = option.is_custom_path and option.answer..".txt" or active_dialog.path..option.answer..".txt"
                    else
                        local t = option.is_custom_path and option.answer[1]..".txt" or active_dialog.path..option.answer[1]..".txt"
                        local p = {}
                        for k, v in option.answer do
                            if k ~= 1 then
                                table.push(p, ""..k.." = "..v) 
                            end
                        end
                        ---@type Iterator
                        local it = Iterator(p)
                        local s = 'Dialog.string_to_parse = {"'..t..'"; '..it.Concat(", ")..'}'
                        parse(s)()
                        options[ans_num] = Dialog.string_to_parse
                    end
                end
            end
        end

        local text = type(active_dialog.options[active_dialog.state][0]) == "string" and
            active_dialog.path..active_dialog.options[active_dialog.state][0]..".txt" or 
            active_dialog.options[active_dialog.state][0]
            
        Dialog.answer_for_player[player] = 6
        TalkBoxForPlayers(GetPlayerFilter(player), active_dialog.icon, nil,
                        text, nil,
                        'Dialog.Callback', 1,
                        active_dialog.path..active_dialog.title..'.txt',
                        active_dialog.path..active_dialog.select_text..'.txt', 
                        0,
                        options[1],
                        options[2],
                        options[3],
                        options[4],
                        options[5])
        while Dialog.answer_for_player[player] == 6 do
            sleep()
        end
        local ans = Dialog.answer_for_player[player]
        -- print("Answer: ", ans)
        local next_state
        if ans < 1 then
            next_state = 0
        else
            local check = 0
            for i = 1, 5 do
                if active_dialog.options[active_dialog.state][i] then
                    ---@type DialogOption | string
                    local option = active_dialog.options[active_dialog.state][i]
                    -- print("Validating option: ", option)
                    if option.is_enabled then
                        check = check + 1
                        if check == ans then
                            -- print("Option was checked")
                            next_state = option.next_state
                            ans = i
                            break
                        end
                    end
                end
            end
        end
        -- print("Next state: ", next_state)
        next_state = active_dialog.effect(player, active_dialog.state, ans, next_state)
        if next_state == 0 then
            return
        else
            if next_state > 0 then
                active_dialog.state = next_state
            end
            Dialog.Action(player)
        end
    end,

    ---@param dialog DialogDefinition
    ---@param new_state any
    SetState = function(dialog, new_state)
        dialog.state = new_state
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param text any
    SetText = function(dialog, state, text)
        dialog.options[state][0] = text
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param option number
    ---@param answer DialogOption
    SetAnswer = function(dialog, state, option, answer)
        answer.is_enabled = answer.is_enabled or 1
        answer.is_custom_path = answer.is_custom_path or nil
        dialog.options[state][option] = answer ---@diagnostic disable-line
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param option number
    ---@param predef_answer DialogOption
    SetPredefAnswer = function(dialog, state, option, predef_answer)
        dialog.options[state][option] = predef_answer ---@diagnostic disable-line
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param option number
    DisableAnswer = function(dialog, state, option)
        ---@type DialogOption | string
        local option = dialog.options[state][option]
        option.is_enabled = nil
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param option number
    EnableAnswer = function(dialog, state, option)
        ---@type DialogOption | string
        local option = dialog.options[state][option]
        option.is_enabled = 1
    end,

    ---@param dialog DialogDefinition
    ---@param state any
    ---@param option number
    IsAnswerEnabled = function(dialog, state, option)
        ---@type DialogOption | string
        local option = dialog.options[state][option]
        local answer = option.is_enabled
        return answer
    end,

    Callback = function(player, answer)
        Dialog.answer_for_player[player] = answer
    end,

    Reset = function(player)
        Dialog.GetActiveDialogForPlayer(player).Reset(player)
    end
}