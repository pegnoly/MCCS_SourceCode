---@alias AbilityStateDetector fun(hero: string): CustomAbilityMode
---@alias AbilityActivator fun(hero: string)

while not AddHeroEvent do
    sleep()
end

custom_ability_common = {
    ---@type table<number, AbilityStateDetector>
    ability_state_detectors = {},
    ---@type table<number, AbilityActivator>
    ability_activators = {},

    ability_states_for_heroes = {},

    RegisterAbility = 
    ---@param id number id спелла
    ---@param detector AbilityStateDetector 
    ---@param activator AbilityActivator
    function (id, detector, activator)
        custom_ability_common.ability_activators[id] = activator
        custom_ability_common.ability_state_detectors[id] = detector
        custom_ability_common.ability_states_for_heroes[id] = {}
    end,

    UnregisterAbility = 
    ---@param id number id спелла
    function (id)
        custom_ability_common.ability_activators[id] = nil
        custom_ability_common.ability_state_detectors[id] = nil
        custom_ability_common.ability_states_for_heroes[id] = nil
    end,

    AbilityUpdateThread = 
    function (hero)
        while 1 do
            if IsHeroAlive(hero) then
                ---@param ability number
                ---@param state_detector AbilityStateDetector
                for ability, state_detector in custom_ability_common.ability_state_detectors do
                    local new_state = state_detector(hero)
                    if not custom_ability_common.ability_states_for_heroes[ability][hero] then
                        custom_ability_common.ability_states_for_heroes[ability][hero] = new_state
                        ControlHeroCustomAbility(hero, ability, new_state)
                    else
                        if new_state ~= custom_ability_common.ability_states_for_heroes[ability][hero] then
                            custom_ability_common.ability_states_for_heroes[ability][hero] = new_state
                            ControlHeroCustomAbility(hero, ability, new_state)
                        end
                    end
                end
            end
            sleep(20)
        end
    end,

    ActivateAbility = 
    function (hero, id)
        if not custom_ability_common.ability_activators[id] then
            return
        end
        startThread(custom_ability_common.ability_activators[id], hero)
    end
}

while not custom_ability_common do
    sleep()
end

Trigger(CUSTOM_ABILITY_TRIGGER, 'custom_ability_common.ActivateAbility')

AddHeroEvent.AddListener("init_custom_abilities_loop_listener",
function (hero)
    startThread(custom_ability_common.AbilityUpdateThread, hero)
end)