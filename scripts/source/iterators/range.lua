range_generator = {
    FromTop =
    --- Возвращает числовую последовательность от start до top
    ---@param base number Нижний порог значения
    ---@param top number Верхний порог значения
    ---@param predicate function? Опциональное условие, при котором элемент вставляет в последовательность
    ---@return number [] range Последовательность чисел
    function (base, top, predicate)
        local answer, n = {}, 0
        for value = base, top do
            if predicate then
                if predicate(value) then
                    n = n + 1
                    answer[n] = value
                end
            else
                n = n + 1
                answer[n] = value
            end
        end
        return answer
    end
}