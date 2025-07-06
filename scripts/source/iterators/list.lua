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
            if predicate(v) then
                t[n] = v
                n = n + 1
            end
        end
        return t
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
    end
}