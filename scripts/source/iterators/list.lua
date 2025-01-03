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
    end
}