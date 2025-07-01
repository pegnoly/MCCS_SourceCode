UNIT_COUNT_GENERATION_MODE_POWER_BASED = 0

while not UNIT_COUNT_GENERATION_MODE_POWER_BASED do
    sleep()
end

FightGenerator = {
    
    SetupNeutralsCombat =
    function (data)
        --print("Generation started on data: ", data)
        local diff = GetDifficulty()
        local week = GetDate(WEEK)

        local stacks_count = 0
        local stacks_info, s_n = {}, 1
        for i, stack_type in data.stack_count_generation_logic do
            stacks_count = stacks_count + 1
            local creature = data.army_getters[i]()
            if stack_type == UNIT_COUNT_GENERATION_MODE_POWER_BASED then
                local stack_power = data.army_base_count_data[i][diff]
                if data.army_counts_grow then
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

        return {stacks_count = stacks_count, stacks_info = stacks_info}
    end
}