CustomAbility = {}

while not CustomAbility do
    sleep()
  end
  
doFile('/scripts/source/event/custom_ability/artifact_custom.lua')
doFile('/scripts/source/event/custom_ability/hero_custom.lua')

while not ((CustomAbility.Hero and CustomAbility.Hero.is_loaded) and
            (CustomAbility.Artifact and CustomAbility.Artifact.is_loaded)) do
    sleep()
end
  
CustomAbility.EnableArtifactAbility =
function()
    while 1 do
        for player = PLAYER_1, PLAYER_8 do
            if Player.IsActive(player) then
                for i, hero in GetPlayerHeroes(player) do
                    --
                    if not CustomAbility.Artifact.AbilitiesByHero[hero] then
                        CustomAbility.Artifact.AbilitiesByHero[hero] = {}
                    end
                    --
                    if not CustomAbility.Artifact.EnabledForHero[hero] then
                        if len(CustomAbility.Artifact.AbilitiesByHero[hero]) > 0 then
                            if IsObjectExists(hero) then
                                ControlHeroCustomAbility(hero, CUSTOM_ABILITY_3, CUSTOM_ABILITY_ENABLED)
                                CustomAbility.Artifact.EnabledForHero[hero] = 1
                            end
                        end
                    else
                        if len(CustomAbility.Artifact.AbilitiesByHero[hero]) == 0 or (not IsObjectExists(hero)) then
                            ControlHeroCustomAbility(hero, CUSTOM_ABILITY_3, CUSTOM_ABILITY_NOT_PRESENT)
                            CustomAbility.Artifact.EnabledForHero[hero] = nil
                        end
                    end
                end
            end
        end
        sleep()
    end
end

CustomAbility.EnableHeroAbility =
function()
    while 1 do
        for player = PLAYER_1, PLAYER_8 do
            if Player.IsActive(player) then
                for i, hero in GetPlayerHeroes(player) do
                    --
                    if not CustomAbility.Hero.AbilitiesByHero[hero] then
                        CustomAbility.Hero.AbilitiesByHero[hero] = {}
                    end
                    --
                    if not CustomAbility.Hero.EnabledForHero[hero] then
                        if len(CustomAbility.Hero.AbilitiesByHero[hero]) > 0 then
                            if IsObjectExists(hero) then
                                ControlHeroCustomAbility(hero, CUSTOM_ABILITY_4, CUSTOM_ABILITY_ENABLED)
                                CustomAbility.Hero.EnabledForHero[hero] = 1
                            end
                        end
                    else
                        if len(CustomAbility.Hero.AbilitiesByHero[hero]) == 0 or (not IsObjectExists(hero)) then
                            ControlHeroCustomAbility(hero, CUSTOM_ABILITY_4, CUSTOM_ABILITY_NOT_PRESENT)
                            CustomAbility.Hero.EnabledForHero[hero] = nil
                        end
                    end
                end
            end
        end
        sleep()
    end
end

Trigger(CUSTOM_ABILITY_TRIGGER, 'CustomAbility.Main')

CustomAbility.Main =
function(hero, ability_id)
    if ability_id == CUSTOM_ABILITY_3 then
        Dialog.NewDialog(CustomAbility.Artifact.MainDialog, hero, GetObjectOwner(hero))
    elseif ability_id == CUSTOM_ABILITY_4 then
        Dialog.NewDialog(CustomAbility.Hero.MainDialog, hero, GetObjectOwner(hero))
    end
end