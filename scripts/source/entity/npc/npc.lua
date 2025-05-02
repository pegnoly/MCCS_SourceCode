Npc = {
    interactions = {},

    Init = function (object)
        Npc.interactions[object] = {}
    end,

    AddInteraction = function (object, name, condition, interaction)
        Npc.interactions[object][name] = {condition = condition, interaction = interaction}
    end,

    RemoveInteraction = function (object, name)
        Npc.interactions[object][name] = nil
    end,

    RunInteractions = function (hero, object)
        local interactions = Npc.interactions[object]
        print("interactions: ", interactions)
        local actual_interactions, n = {}, 0
        for name, interaction in interactions do
            if interaction.condition(hero, object) then
                n = n + 1
                actual_interactions[n] = {name = name, interaction = interaction.interaction}
            end
        end
        print("actual_interactions: ", actual_interactions)
        for _, interaction in actual_interactions do
            print("Starting interaction: ", interaction.name)
            interaction.interaction(hero, object)
        end
    end
}