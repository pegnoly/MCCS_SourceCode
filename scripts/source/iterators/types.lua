---@alias IteratorPredicate fun(item: any): 1|nil
---@alias IteratorConverter fun(item: any): any
---@alias IteratorConverterNullable fun(item: any): any|nil
---@alias IteratorMethod fun(method: IteratorPredicate | IteratorConverter | IteratorConverterNullable): Iterator
---@alias IteratorCollector fun(): any[]

---@class Iterator
---@field private items any[]
---@field Filter IteratorMethod
---@field Map IteratorMethod
---@field FilterMap IteratorMethod
---@field Collect IteratorCollector
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
        
        Collect = function()
            local items = %items
            return items
        end
    }
end