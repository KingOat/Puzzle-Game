local utils = {}

function utils.normalize(v1, v2)
    if v1 == 0 and v2 == 0 then
        return {x = 0, y = 0}
    end
    norm = math.sqrt(v1^2 + v2^2)
    return {x = v1 / norm, y = v2 / norm}
end

return utils
