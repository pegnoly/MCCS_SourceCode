---@class Interaction
---@field private condition fun(hero: string, object: string): 1|nil
---@field action fun(hero: string, object: string): 1|nil
Interaction = {}

---@class Interactable
---@field private internal_name string
---@field interactions table<string, Interaction>
---@field private queued_interactions table<string, Interaction>
---@field private prioritizied_interactions table<string, Interaction>
---@field AsCreature fun(cursor: ObjectInteractionCursorType?, selection: integer?, name_override: string?)?
---@field AsBuilding fun(cursor: ObjectInteractionCursorType?, name_override: string?, desc_override: string?)?
---@field AsHero fun(cursor: ObjectInteractionCursorType?)?
---@field AddInteraction fun(id: string, value: Interaction|nil)?
Interactable = {}

---@type table<string, Interactable>
Interactables = {}

InteractionsRunner = {
    Execute = 
    function (hero, object)
        ---@type Interactable
        local interactable = Interactables[object]
        ---@param interaction Interaction
        for _, interaction in interactable.interactions do
            interaction.action(hero, object)
        end
    end
}

---@overload fun(name: string): Interactable
Interactable = function (name)
    local interactions = {}
    local queued_interactions = {}
    local prioritizied_interactions = {}
    ---@type Interactable
    local interactable = {
        internal_name = name,
        interactions = interactions,
        queued_interactions = queued_interactions,
        prioritizied_interactions = prioritizied_interactions,
    }

    Interactables[name] = interactable

    interactable.AsCreature =
    ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на монстра
    ---@param selection integer? тип выделения монстра
    ---@param name_override string? путь к файлу с новым именем монстра
    function (cursor, selection, name_override)
        local object = %name
        SetObjectEnabled(object, nil)
        if cursor then
            SetDisabledObjectMode(object, cursor)
        end
        if selection then
            startThread(
            function()
                sleep()
                local object = %object
                local selection= %selection
                SetMonsterSelectionType(object, selection)
            end)
        end
        if name_override then
            SetMonsterNames(object, MONSTER_NAME_SINGLE, name_override)
        end
    end

    interactable.AsBuilding =
    --- Выключает объект на карте приключений
    ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на объект
    ---@param name_override string? путь к файлу с новым именем объекта
    ---@param desc_override string? путь к файлу с новым описанием объекта
    function (cursor, name_override, desc_override)
        local object = %name
        SetObjectEnabled(object, nil)
        if cursor then
            SetDisabledObjectMode(object, cursor)
        end
        if name_override then
            OverrideObjectTooltipNameAndDescription(object, name_override, desc_override and desc_override or 'blank.txt')
        end
    end

    interactable.AsHero =
    --- Выключает героя на карте приключений
    ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на объект
    function (cursor)
        local object = %name
        SetObjectEnabled(object, nil)
        if cursor then
            SetDisabledObjectMode(object, cursor)
        end
    end

    interactable.AddInteraction =
    ---comment
    ---@param id string
    ---@param value Interaction|nil
    function (id, value)
        local object = %name
        local interactions = %interactions
        if len(interactions) == 0 then
            Trigger(OBJECT_TOUCH_TRIGGER, object, "InteractionsRunner.Execute")
        end
        interactions[id] = value
    end

    return interactable
end

---@type Interactable
Interactable("test1").AsCreature(DISABLED_INTERACT, 0)
local it1 = Interactables["test1"]
-- print("Trying to get function: ", it1.AddInteraction)
it1.AddInteraction("test", { action = function(hero, object) print"Interaction called" end,  condition = function (hero, object)
    return 1
end})

-- print("It1: ", it1)

-- local it2 = Interactable("test2")

-- print("Its: ", Interactables)

-- Npc = {
--     interactions = {},

--     queued_interactions = {},
--     prioritizied_interactions = {},

--     current_npc_finished_interactions = {},

--     Init = function (object)
--         Npc.interactions[object] = {}
--         Npc.queued_interactions[object] = {}
--         Npc.prioritizied_interactions[object] = {}
--     end,

--     AddInteraction = function (object, name, condition, interaction)
--         Npc.interactions[object][name] = {condition = condition, interaction = interaction}
--     end,

--     RemoveInteraction = function (object, name)
--         Npc.interactions[object][name] = nil
--         if Npc.queued_interactions[object][name] then
--             Npc.queued_interactions[object][name] = nil
--         end
--         if Npc.prioritizied_interactions[object][name] then
--             Npc.prioritizied_interactions[object][name] = nil
--         end
--     end,

--     FinishInteraction = function (name)
--         Npc.current_npc_finished_interactions[name] = 1
--     end,

--     -- Two functions below are supposed to organize a simple order interactions must be executed.
--     -- Priotitized interactions -> interactions without execution order -> queued interactions 

--     QueueInteraction =
--     --- Ensures that given interaction will have last execution priority
--     ---@param object string npc script name
--     ---@param interaction string label of interaction that must be set to the last priority
--     function (object, interaction)
--         Npc.queued_interactions[object][interaction] = 1
--     end,

--     PrioritizeInteraction =
--     --- Ensures that given interaction will have first execution priority
--     ---@param object string npc script name
--     ---@param interaction string label of interaction that must be set to the first priority
--     function (object, interaction)
--         Npc.prioritizied_interactions[object][interaction] = 1
--     end,

--     RunInteractions = function (hero, object)
--         print("Running interactions for ", object)
--         local interactions = Npc.interactions[object]
--         local actual_interactions, n = {}, 0
--         for name, interaction in interactions do
--             if interaction.condition(hero, object) then
--                 n = n + 1
--                 actual_interactions[n] = {name = name, interaction = interaction.interaction}
--             end
--         end
--         local prioritizied_interactions = list_iterator.Filter(actual_interactions,
--             function (interaction)
--                 local object = %object
--                 local resut = Npc.prioritizied_interactions[object][interaction.name]
--                 return resut
--             end
--         )
--         local default_interactions = list_iterator.Filter(actual_interactions,
--             function (interaction)
--                 local object = %object
--                 local result = (not Npc.prioritizied_interactions[object][interaction.name]) and (not Npc.queued_interactions[object][interaction.name])
--                 return result
--             end
--         )
--         local queued_interactions = list_iterator.Filter(actual_interactions,
--             function (interaction)
--                 local object = %object
--                 local resut = Npc.queued_interactions[object][interaction.name]
--                 return resut
--             end
--         )
--         print"First priority: "
--         for _, interaction in prioritizied_interactions do
--             print(interaction.name)
--             interaction.interaction(hero, object)
--             while not Npc.current_npc_finished_interactions[interaction.name] do
--                 sleep()
--             end
--         end
--         print"Default priority: "
--         for _, interaction in default_interactions do
--             print(interaction.name)
--             interaction.interaction(hero, object)
--             while not Npc.current_npc_finished_interactions[interaction.name] do
--                 sleep()
--             end
--         end
--         print"Last priority: "
--         for _, interaction in queued_interactions do
--             print(interaction.name)
--             interaction.interaction(hero, object)
--             while not Npc.current_npc_finished_interactions[interaction.name] do
--                 sleep()
--             end
--         end
--         Npc.current_npc_finished_interactions = {}
--     end
-- }