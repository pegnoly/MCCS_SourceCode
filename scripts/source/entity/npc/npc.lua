Npc = {
    interactions = {},

    queued_interactions = {},
    prioritizied_interactions = {},

    current_npc_finished_interactions = {},

    Init = function (object)
        Npc.interactions[object] = {}
        Npc.queued_interactions[object] = {}
        Npc.prioritizied_interactions[object] = {}
    end,

    AddInteraction = function (object, name, condition, interaction)
        Npc.interactions[object][name] = {condition = condition, interaction = interaction}
    end,

    RemoveInteraction = function (object, name)
        Npc.interactions[object][name] = nil
        if Npc.queued_interactions[object][name] then
            Npc.queued_interactions[object][name] = nil
        end
        if Npc.prioritizied_interactions[object][name] then
            Npc.prioritizied_interactions[object][name] = nil
        end
    end,

    FinishInteraction = function (name)
        Npc.current_npc_finished_interactions[name] = 1
    end,

    -- Two functions below are supposed to organize a simple order interactions must be executed.
    -- Priotitized interactions -> interactions without execution order -> queued interactions 

    QueueInteraction =
    --- Ensures that given interaction will have last execution priority
    ---@param object string npc script name
    ---@param interaction string label of interaction that must be set to the last priority
    function (object, interaction)
        Npc.queued_interactions[object][interaction] = 1
    end,

    PrioritizeInteraction =
    --- Ensures that given interaction will have first execution priority
    ---@param object string npc script name
    ---@param interaction string label of interaction that must be set to the first priority
    function (object, interaction)
        Npc.prioritizied_interactions[object][interaction] = 1
    end,

    RunInteractions = function (hero, object)
        print("Running interactions for ", object)
        local interactions = Npc.interactions[object]
        local actual_interactions, n = {}, 0
        for name, interaction in interactions do
            if interaction.condition(hero, object) then
                n = n + 1
                actual_interactions[n] = {name = name, interaction = interaction.interaction}
            end
        end
        local prioritizied_interactions = list_iterator.Filter(actual_interactions,
            function (interaction)
                local object = %object
                local resut = Npc.prioritizied_interactions[object][interaction.name]
                return resut
            end
        )
        local default_interactions = list_iterator.Filter(actual_interactions,
            function (interaction)
                local object = %object
                local result = (not Npc.prioritizied_interactions[object][interaction.name]) and (not Npc.queued_interactions[object][interaction.name])
                return result
            end
        )
        local queued_interactions = list_iterator.Filter(actual_interactions,
            function (interaction)
                local object = %object
                local resut = Npc.queued_interactions[object][interaction.name]
                return resut
            end
        )
        print"First priority: "
        for _, interaction in prioritizied_interactions do
            print(interaction.name)
            interaction.interaction(hero, object)
            while not Npc.current_npc_finished_interactions[interaction.name] do
                sleep()
            end
        end
        print"Default priority: "
        for _, interaction in default_interactions do
            print(interaction.name)
            interaction.interaction(hero, object)
            while not Npc.current_npc_finished_interactions[interaction.name] do
                sleep()
            end
        end
        print"Last priority: "
        for _, interaction in queued_interactions do
            print(interaction.name)
            interaction.interaction(hero, object)
            while not Npc.current_npc_finished_interactions[interaction.name] do
                sleep()
            end
        end
        Npc.current_npc_finished_interactions = {}
    end
}