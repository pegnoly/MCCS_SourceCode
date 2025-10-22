list_iterator = {
    Any =
    ---@param table table Таблица, для которой проверяется условие
    ---@param predicate function Условие
    ---@return nil|1 ok Хотя бы для одного элемента выполняется условие?
    function (table, predicate)
        --print("Iterator any: table - ", table)
        local result = nil
        for k, v in table do
            if predicate(v) then
                --print("Smth is true...")
                result = 1
                break
            end
        end
        return result
    end,

    All = 
    ---@param table table Таблица, для которой проверяется условие
    ---@param predicate function Условие
    ---@return nil|1 ok Условие выполняется для всех элементов?
    function (table, predicate)
        for k, v in table do
            if not predicate(v) then
                return nil
            end
        end
        return 1
    end,

    Filter = 
    ---comment
    ---@param table table Таблица для фильтра значений
    ---@param predicate function Условие
    ---@return table t Таблица отфильтрованных значений
    function (table, predicate)
        local t, n = {}, 1
        for k, v in table do
            if k and v and predicate(v) then
                t[n] = v
                n = n + 1
            end
        end
        return t
    end,

    FilterMap = 
    --- Преобразует значения заданной таблицы t в новую, на основе указанного предиката predicate
    ---@param t table Исходная таблица
    ---@param convert function Преобразующая функция
    ---@return table v Новая таблица
    function (t, convert)
        local answer, n = {}, 0
        for k, v in t do
            local b = convert(v)
            if b then
                n = n + 1
                answer[n] = b
            end
        end
        return answer
    end,

    Join = 
    --- Джойнит две таблицы, которые имеют ключи-числа
    ---@param t1 table Первая таблица
    ---@param t2 table Вторая таблица
    function (t1, t2)
        local n = len(t1)
        for k, v in t2 do
            t1[n] = v
            n = n + 1
        end
        return t1
    end,

    MaxBy = 
    function (t, predicate)
        local current_max_value = math.nan
        local current_answer
        for k, v in t do
            if k and v then
                local value = predicate(v)
                if value and value > current_max_value then
                    current_max_value = value
                    current_answer = v
                end
            end 
        end
        return current_answer
    end,

    MinBy = 
    function (t, predicate)
        local current_min_value = math.huge
        local current_answer
        for k, v in t do
            if k and v then
                local value = predicate(v)
                if value and value < current_min_value then
                    current_min_value = value
                    current_answer = v
                end 
            end
        end
        return current_answer
    end,

    ToList =
    function (t)
        local answer, n = {}, 1
        for k, v in t do
            if k and v then
                answer[n] = v
                n = n + 1
            end
        end
        return answer
    end,

    Concat = 
    function (t, sep)
        local answer = ""
        for _, v in t do
            local stringified = v..""
            if answer ~= "" then
                if stringified ~= "" then
                    answer = answer..""..sep.." "..stringified
                end
            else
                answer = answer..stringified
            end
        end
        return answer
    end,

    TakeRandom = 
    function (t, count)
        local count = count >= length(t) and length(t) or count
        local result, n = {}, 0
        while n ~= count do
            local value = Random.FromTable(t)
            n = n + 1
            result[n] = value
            t = list_iterator.Filter(t, function (v)
                local result = %result
                if not contains(result, v) then
                    return 1
                end
                return nil
            end)
            sleep()
        end
        return result
    end
}