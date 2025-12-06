---@generic TSource, TProduct
---@alias IteratorPredicate fun(item: TSource): 1|nil
---@alias IteratorConverter fun(item: TSource): TProduct
---@alias IteratorConverterNullable fun(item: TSource): TProduct|nil
---@alias IteratorComparer fun(item: TSource): number
---@alias IteratorMethod fun(method: IteratorPredicate | IteratorConverter | IteratorConverterNullable): Iterator
---@alias IteratorChecker fun(method: IteratorPredicate): 1|nil
---@alias IteratorSelector fun(count: number): Iterator
---@alias IteratorConcatenator fun(separator: string): string
---@alias IteratorSingleItemSelector fun(comparer: IteratorComparer): TSource
---@alias IteratorCollector fun(): TSource[]

---@class Iterator<TSource>
---@field private items `TSource`[]
---@field Filter IteratorMethod Возвращает итератор отфильтрованных элементов исходного
---@field Map IteratorMethod Возвращает итератор элементов нового типа, полученных путем преобразования элементов исходного
---@field FilterMap IteratorMethod Возвращает итератор элементов нового типа, преобразованных только в случае, если базовые элементы соответствуют заданному условию
---@field Any IteratorChecker Возвращает 1, если хотя бы один из элементов итератора соответствуют заданному условию
---@field All IteratorChecker Возвращает 1, если все элементы итератора соответствуют заданному условию
---@field Collect IteratorCollector Возвращает таблицу элементов итератора, уничтожая его
---@field TakeFirst IteratorSelector Возвращает итератор из первых N элементов исходного итератора
---@field TakeRandom IteratorSelector Возвращает итератор из N случайных неповторяющихся элементов исходного итератора
---@field Concat IteratorConcatenator Преобразует элементы итератора в строку
---@field MaxBy IteratorSingleItemSelector Возвращает единственный элемент итератора, имеющий максимальное значение по заданному условию
---@field MinBy IteratorSingleItemSelector Возвращает единственный элемент итератора, имеющий минимальное значение по заданному условию
Iterator = {}

---@overload fun(items: any[]): Iterator
Iterator = function (items)
    local it = {
        items = items,

        ---@param predicate IteratorPredicate
        Filter = function(predicate)
            local items = %items
            local result, n = {}, 0
            for _, item in items do
                if predicate(item) then
                    result[n] = item
                    n = n + 1
                end
            end
            local it = Iterator(result)
            return it
        end,

        ---@param converter IteratorConverter
        Map = function(converter)
            local items = %items
            local result, n = {}, 0
            for _, item in items do
                local converted = converter(item)
                result[n] = converted
                n = n + 1
            end
            local it = Iterator(result)
            return it
        end, 

        ---@param converter_nullable IteratorConverterNullable
        FilterMap = function (converter_nullable)
            local items = %items
            local result, n = {}, 0
            for _, item in items do
                local converted = converter_nullable(item)
                if converted then
                    result[n] = converted
                    n = n + 1
                end
            end
            local it = Iterator(result)
            return it
        end,

        ---@param predicate IteratorPredicate
        Any = function (predicate)
            local items = %items
            local result = nil
            for _, v in items do
                if predicate(v) then
                    result = 1
                    break
                end
            end
            return result
        end,

        ---@param predicate IteratorPredicate
        All = function (predicate)
            local items = %items
            for _, v in items do
                if not predicate(v) then
                    return nil
                end
            end
            return 1
        end,

        ---@param count number
        TakeFirst = function (count)
            local items = %items
            local result, n = {}, 0
            for _, item in items do
                if n == count then
                    break
                end
                n = n + 1
                result[n] = item
            end
            ---@type Iterator
            local it = Iterator(result)
            return it
        end,

        ---@param count number
        TakeRandom = function (count)
            local items = %items
            local count = count >= length(items) and length(items) or count
            local result, n = {}, 0
            while n ~= count do
                local value = Random.FromTable(items)
                n = n + 1
                result[n] = value
                ---@type Iterator
                local it = Iterator(items)
                items = it.Filter(function(v)
                    local result = %result
                    if not contains(result, v) then
                        return 1
                    end
                    return nil
                end).Collect()
                sleep()
            end
            return result
        end,

        ---@param separator string
        Concat = function (separator)
            local items = %items
            local result = ""
            for _, v in items do
                local stringified = v..""
                if result ~= "" then
                    if stringified ~= "" then
                        result = result..""..separator..""..stringified
                    end
                else
                    result = result..stringified
                end
            end
            return result
        end,

        ---@param comparer IteratorComparer
        MaxBy = function (comparer)
            local items = %items
            local current_max_value = math.nan
            local current_answer
            for k, v in items do
                if k and v then
                    local value = comparer(v)
                    if value and value > current_max_value then
                        current_max_value = value
                        current_answer = v
                    end
                end 
            end
            return current_answer
        end,

        ---@param comparer IteratorComparer
        MinBy = function (comparer)
            local items = %items
            local current_min_value = math.huge
            local current_answer
            for k, v in items do
                if k and v then
                    local value = comparer(v)
                    if value and value < current_min_value then
                        current_min_value = value
                        current_answer = v
                    end 
                end
            end
            return current_answer
        end,
        
        Collect = function()
            local items = %items
            return items
        end
    }
    return it
end