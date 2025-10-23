doFile('/scripts/source/iterators/list.lua')

---@alias UnitCountGenerationMode
---| `UNIT_COUNT_GENERATION_MODE_POWER_BASED`
---| `UNIT_COUNT_GENERATION_MODE_RAW`
UNIT_COUNT_GENERATION_MODE_POWER_BASED = 0
UNIT_COUNT_GENERATION_MODE_RAW = 1

while not UNIT_COUNT_GENERATION_MODE_POWER_BASED and not UNIT_COUNT_GENERATION_MODE_RAW and not list_iterator do
    sleep()
end

---@alias ArmyGetter fun(): number

---@class FightGenerationModel
---@field stack_count_generation_logic UnitCountGenerationMode []
---@field army_base_count_data table<DifficultyLevel, number> []
---@field army_counts_grow table<DifficultyLevel, number> []?
---@field army_getters ArmyGetter []
---@field required_artifacts number []?
---@field optional_artifacts table<ArtifactSlot, number[]>?
---@field artifacts_base_costs table<DifficultyLevel, number>?
---@field artifacts_costs_grow table<DifficultyLevel, number>?
FightGenerationModel = {}

---@class FightStacksModel
---@field stacks_count number
---@field stacks_info number[]
FightStacksModel = {}

---@class FightSingleStackModel
---@field creature number
---@field count number
FightSingleStackModel = {}

---@class FightHeroSetupModel
---@field stacks_data number[]
---@field artifacts_data number[]?
FightHeroSetupModel = {}

FightGenerator = {
    
    SetupNeutralsCombat =
    -- Генерирует инфу о битве с нейтралами в форме, данных, которая может быть сразу передана в MCCS_StartCombat
    ---@param data FightGenerationModel
    ---@return FightStacksModel
    function (data)
        local diff = GetDifficulty()
        local week = GetDate(WEEK)
        ---@type FightStacksModel
        local result
        ---@type number
        local stacks_count = 0
        local stacks_info, s_n = {}, 1
        ---@param stack_type UnitCountGenerationMode
        for i, stack_type in data.stack_count_generation_logic do
            stacks_count = stacks_count + 1
            local creature = data.army_getters[i]()
            if stack_type == UNIT_COUNT_GENERATION_MODE_POWER_BASED then
                local stack_power = data.army_base_count_data[i][diff]
                if data.army_counts_grow and length(data.army_counts_grow) > 0 then
                    stack_power = stack_power + data.army_counts_grow[i][diff] * week
                end
                stacks_info[s_n] = creature
                stacks_info[s_n + 1] = ceil(stack_power / Creature.Params.Power(creature))
                s_n = s_n + 2
            else
                local count = data.army_base_count_data[i][diff]
                if data.army_counts_grow then
                    count = count + data.army_counts_grow[i][diff] * week
                end
                stacks_info[s_n] = creature
                stacks_info[s_n + 1] = count
                s_n = s_n + 2
            end
        end

        result = { stacks_count = stacks_count, stacks_info = stacks_info }
        return result
    end,

    GenerateStacksData = 
    -- Генерирует информацию о стеках юнитов в форме, удобной для добавления их в армию некоторого объекта
    ---@param data FightGenerationModel
    ---@return FightSingleStackModel[]
    function (data)
        local diff = GetDifficulty()
        local week = GetDate(WEEK)
        ---@type FightSingleStackModel[]
        local stacks_data, n = {}, 1
        for i, stack_type in data.stack_count_generation_logic do
            local creature = data.army_getters[i]()
            local count
            if stack_type == UNIT_COUNT_GENERATION_MODE_POWER_BASED then
                local stack_power = data.army_base_count_data[i][diff]
                if data.army_counts_grow and length(data.army_counts_grow) > 0 and data.army_counts_grow[i] and data.army_counts_grow[i][diff] then
                    stack_power = stack_power + data.army_counts_grow[i][diff] * week
                end
                count = ceil(stack_power / Creature.Params.Power(creature)) 
            else 
                count = data.army_base_count_data[i][diff]
                if data.army_counts_grow and data.army_counts_grow[i] and data.army_counts_grow[i][diff] then
                    count = count + data.army_counts_grow[i][diff] * week
                end
            end
            stacks_data[n] = {creature = creature, count = count}
            n = n + 1
        end

        return stacks_data
    end,

    GenerateHeroSetupData = 
    -- Генерирует полную модель данных для настройки героя
    ---@param data FightGenerationModel
    ---@return FightHeroSetupModel
    function (data)
        local diff = GetDifficulty()
        local week = GetDate(WEEK)
        ---@type FightHeroSetupModel
        local result
        local stacks_data = FightGenerator.GenerateStacksData(data)
        if not data.artifacts_base_costs then
            result = { stacks_data = stacks_data }
            return result
        end
        --
        local artifacts_data, a_n = {}, 1
        if data.required_artifacts and length(data.required_artifacts) > 0 then
            for _, art in data.required_artifacts do
                artifacts_data[a_n] = art
                a_n = a_n + 1
            end
        end
        local used_slots = {}
        local weight = data.artifacts_base_costs[diff]
        if data.artifacts_costs_grow and data.artifacts_costs_grow[diff] then
            weight = weight + data.artifacts_costs_grow[diff] * week
        end
        local possible_arts, n = {}, 1
        for _, arts in data.optional_artifacts do
            for i, art in arts do 
                if art ~= "," then
                    possible_arts[n] = art
                    n = n + 1 
                end
            end
        end
        while 1 do
            local artifacts = list_iterator.Filter(possible_arts, 
                function (art)
                    local used_slots = %used_slots
                    local weight = %weight
                    local artifacts_data = %artifacts_data
                    local slot = Art.Params.Slot(art)
                    if used_slots[slot] then
                        return nil
                    end
                    if Art.Params.Cost(art) <= weight and (not contains(artifacts_data, art)) then
                        return 1
                    end
                end
            )
            if length(artifacts) == 0 then
                break
            end
            local art = Random.FromTable(artifacts)
            artifacts_data[a_n] = art
            local slot = Art.Params.Slot(art)
            used_slots[slot] = 1
            possible_arts = artifacts
            weight = weight - Art.Params.Cost(art)
            sleep()
        end
        result = { stacks_data = stacks_data, artifacts_data = artifacts_data }
        return result
    end,

    ProcessHeroSetup = 
    -- Настраивает героя
    ---@param hero string
    ---@param data FightHeroSetupModel
    function(hero, data) 
        -- startThread(
        -- function ()
        --     local stacks_data = %data.stacks_data
        --     local hero = %hero
        if data.stacks_data then
            local placeholder_removed
            for _, stack in data.stacks_data do
                AddHeroCreatures(hero, stack.creature, stack.count)
                if not placeholder_removed then
                    while GetHeroCreatures(hero, stack.creature) ~= stack.count do
                        sleep()
                    end
                    RemoveHeroCreatures(hero, CREATURE_PLACEHOLDER, 99999)
                    while GetHeroCreatures(hero, CREATURE_PLACEHOLDER) ~= 0 do
                        sleep()
                    end
                    placeholder_removed = 1
                end
            end
        end
        -- end)

        if data.artifacts_data then
            startThread(
            function ()
                local artifacts_data = %data.artifacts_data
                local hero = %hero
                for _, art in artifacts_data do
                    GiveArtefact(hero, art, 1)
                end
            end) 
        end
    end,

    ProcessObjectSetup = 
    -- Настраивает объект на карте
    ---@param object string
    ---@param data FightStacksModel
    function (object, data)
        for _, stack in data do
            AddObjectCreatures(object, stack.creature, stack.count)
        end
    end
}