
get_3d_slope = {}

--[[
minetest.register_entity("get_3d_slope:node", {
  collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
  visual = "cube",
  textures = {"default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png", "default_dirt.png"},
  physical = true,
  on_step = function(self, dtime, moveresult)
    local vel = self.object:get_velocity()
    self.object:set_acceleration(vector.new(0,-9.81,0))
    self.object:set_velocity(vector.new(vel.x*0.95, vel.y, vel.z*0.95))

    if moveresult.touching_ground then
      local slope = get_3d_slope.get_slope(self.object:get_pos(), 3)
      self.object:add_velocity(vector.multiply(slope, -slope.y))
    end
  end,
  on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    self.object:add_velocity(dir)
  end,
})
--TEST ENTITY ^^^^
]]

-- sz = list of all node names because I don't know how to use find nodes under air for all blocks without that
local sz = {}
minetest.register_on_mods_loaded(function()
  for _,node in pairs(minetest.registered_nodes) do
    table.insert(sz, node.name)
  end
end)


function get_3d_slope.get_slope(pos, rad)

  local nodes = minetest.find_nodes_in_area_under_air(vector.add(pos, vector.new(-rad,-rad,-rad)), vector.add(pos, vector.new(rad,rad,rad)), sz)
  for i,node in ipairs(nodes) do


    raycast = minetest.raycast(pos, node, false, false) -- only allow vectors from blocks we can see
    for hitpoint in raycast do
      if hitpoint.type == "node" then
        nodes[i] = hitpoint.under
      end
    end


    local node = minetest.registered_nodes[minetest.get_node(node)] -- only calculate with nodes that are solid
    if node and not node.walkable then
      table.remove(nodes, i)
    end
  end

  local dir = vector.new()
  for _,node in ipairs(nodes) do
    for _,node2 in ipairs(nodes) do
      if node.y > node2.y then -- only use downward vectors because gravity
        dir = vector.add(dir, vector.direction(node, node2))
      end
    end
  end
  return vector.normalize(dir) -- return the correct slope
end
