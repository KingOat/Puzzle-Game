local collision = {}

function collision.createCollider(x, y, w, h) 
    return {x=x, y=y, w=w, h=h}
end

function collision.AABBCollision(c1, c2)
    return c1.x < c2.x + c2.w and
        c2.x < c1.x + c1.w and
        c1.y < c2.y + c2.h and
        c2.y < c1.y + c1.h 
end

function collision.getCollisionDir(c1, c2)
    local center1 = {x=c1.x + c1.w / 2, y=c1.y + c1.h / 2}
    local center2 = {x=c2.x + c2.w / 2, y=c2.y + c2.h / 2}
    local d = {x=center1.x - center2.x, y=center1.y - center2.y}
    if d.x > 0 and math.abs(d.x) > c2.w / 2 then
        return "right"
    end
    if d.x < 0 and math.abs(d.x) > c2.w / 2 then
        return "left"
    end
    if d.y > 0 and math.abs(d.y) > c2.h / 2 then
        return "bottom"
    end
    if d.y < 0 and math.abs(d.y) > c2.h / 2 then
        return "top"
    end
end

function collision.drawCollider(c)
    love.graphics.rectangle('line', c.x, c.y, c.w, c.h)
end

return collision