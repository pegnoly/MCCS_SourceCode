---@alias InteractionPriority
---|`INTERACTION_PRIORITY_DEFAULT`
---|`INTERACTION_PRIORITY_HIGH`
---|`INTERACTION_PRIORITY_LOW`
INTERACTION_PRIORITY_DEFAULT = 1
INTERACTION_PRIORITY_HIGH = 2
INTERACTION_PRIORITY_LOW = 3

---@alias InteractionCondition fun(hero: string, object: string): 1|nil
---@alias InteractionAction fun(hero: string, object): 1|nil

---@class Interaction
---@field private condition fun(hero: string, object: string): 1|nil | nil
---@field private priority InteractionPriority
---@field GetPriority fun(): InteractionPriority
---@field SetPriority fun(new_priority: InteractionPriority): Interaction
---@field private action fun(hero: string, object: string): 1|nil
---@field Run fun(hero: string, object: string)
Interaction = {}

---@overload fun(action: InteractionAction, condition: InteractionCondition?, priority: InteractionPriority?)
Interaction = function (action, condition, priority)
    local priority = priority or INTERACTION_PRIORITY_DEFAULT
    ---@type Interaction
    local it = {
        priority = priority,
        condition = condition or nil,
        action = action,

        GetPriority = 
        function ()
            local result = %priority
            return result
        end,

        SetPriority = 
        ---comment
        ---@param new_priority InteractionPriority
        function (new_priority)
            local current = %priority
            current = new_priority
            local it = Interaction(%action, %condition, current)
            return it
        end,

        Run =
        ---comment
        ---@param hero string
        ---@param object string
        function (hero, object)
            local condition = %condition
            local action = %action
            if (not condition) or (condition and condition(hero, object)) then
                action(hero, object)
            end
        end
    }

    return it
end

---@class Interactable
---@field private internal_name string
---@field private interactions table<string, Interaction>
---@field AsCreature fun(cursor: ObjectInteractionCursorType?, selection: integer?, name_override: string?): Interactable
---@field AsBuilding fun(cursor: ObjectInteractionCursorType?, name_override: string?, desc_override: string?): Interactable
---@field AsHero fun(cursor: ObjectInteractionCursorType?): Interactable
---@field GetInteraction fun(id: string): Interaction
---@field AddInteraction fun(id: string, value: Interaction|nil): Interactable
---@field RemoveInteraction fun(id: string): Interactable
---@field RunInteractions fun(hero: string)
Interactable = {}

---@type table<string, Interactable>
Interactables = {}

---@meta
InteractionsRunner = {
    Execute = 
    function (hero, object)
        ---@type Interactable
        local interactable = Interactables[object]
        startThread(interactable.RunInteractions, hero)
    end
}

---@overload fun(name: string, interactions: Interaction[]?): Interactable
Interactable = function (name, interactions)
    local interactions = interactions and interactions or {}
    ---@type Interactable
    local interactable = {
        internal_name = name,
        interactions = interactions,

        AsCreature =
        ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на монстра
        ---@param selection integer? тип выделения монстра
        ---@param name_override string? путь к файлу с новым именем монстра
        function (cursor, selection, name_override)
            local object = %name
            local interactions = %interactions
            SetObjectEnabled(object, nil)
            while IsObjectEnabled(object) do
                sleep()
            end
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

            local it = Interactable(object, interactions)
            return it
        end,

        AsBuilding =
        --- Выключает объект на карте приключений
        ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на объект
        ---@param name_override string? путь к файлу с новым именем объекта
        ---@param desc_override string? путь к файлу с новым описанием объекта
        function (cursor, name_override, desc_override)
            local object = %name
            local interactions = %interactions
            SetObjectEnabled(object, nil)
            while IsObjectEnabled(object) do
                sleep()
            end
            if cursor then
                SetDisabledObjectMode(object, cursor)
            end
            if name_override then
                OverrideObjectTooltipNameAndDescription(object, name_override, desc_override and desc_override or 'blank.txt')
            end

            local it = Interactable(object, interactions)
            return it
        end,

        AsHero =
        --- Выключает героя на карте приключений
        ---@param cursor ObjectInteractionCursorType? тип курсора при наведении на объект
        function (cursor)
            local object = %name
            local interactions = %interactions
            SetObjectEnabled(object, nil)
            while IsObjectEnabled(object) do
                sleep()
            end
            if cursor then
                SetDisabledObjectMode(object, cursor)
            end

            local it = Interactable(object, interactions)
            return it
        end,

        GetInteraction =
        ---comment
        ---@param id string
        function (id)
            local interactions = %interactions
            local result = interactions[id]
            return result
        end,

        AddInteraction =
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

            local it = Interactable(object, interactions)
            return it
        end,

        RemoveInteraction =
        ---@param id string
        function (id)
            local object = %name
            local interactions = %interactions
            interactions[id] = nil
            local it = Interactable(object, interactions)
            return it
        end,

        RunInteractions =
        ---comment
        ---@param hero string
        function (hero)
            local object = %name
            local interactions = %interactions
            ---@param interaction Interaction
            for _, interaction in interactions do
                interaction.Run(hero, object)
            end
        end
    }

    if not Interactables[name] then
        Interactables[name] = interactable
    end

    return interactable
end

---@type Interactable
Interactable("test1")
    .AsCreature(DISABLED_INTERACT, 0)
    .AddInteraction("test", Interaction(function (hero, object)
        print("Hero ", hero, " interacted with ", object)
    end))
    .AddInteraction("test2", Interaction(function (hero, object)
        print("Hero ", hero, " interacted with ", object, " again")
    end))