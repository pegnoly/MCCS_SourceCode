list_iterator = {
    Any =
    ---comment
    ---@param table table Таблица, для которой проверяется условие
    ---@param predicate function Условие
    ---@return ok boolean Хотя бы для одного элемента выполняется условие?
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
    ---comment
    ---@param table table Таблица, для которой проверяется условие
    ---@param predicate function Условие
    ---@return ok boolean Условие выполняется для всех элементов?
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
    ---@return t table Таблица отфильтрованных значений
    function (table, predicate)
        local t, n = {}, 0
        for k, v in table do 
            if predicate(v) then
                t[n] = v
                n = n + 1
            end
        end
        return t
    end
}