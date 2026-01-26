--- Выясняет, есть ли у героя артефакт
---@param hero string скриптовое имя героя
---@param artefact ArtifactID id артефакта
---@param is_equipped? 1|nil надет артефакт/нет
---@return 1|nil has имеется артефакт/нет
function HasArtefact(hero, artefact, is_equipped)
end

--- Определяет, есть ли у игрока ключ определенного цвета
---@param player PlayerID id игрока
---@param key BorderguardKeyColor цвет ключа
---@return 1|nil has имеется ключ/нет
function HasBorderguardKey(player, key)
    return nil
end

--- Проверяет наличие навыка у героя
---@param hero string скриптовое имя героя
---@param skill HeroSkillType id навыка
---@return 1|nil has имеется скилл/нет
function HasHeroSkill(hero, skill)
end

--- Определяет, есть ли у героя боевая машина заданного типа
---@param hero string скриптовое имя героя
---@param type WarMachineType тип машины
---@return 1|nil has имеется машина/нет
function HasHeroWarMachine(hero, type)
end

