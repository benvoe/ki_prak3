require( 'Class' )

field = {}

function field:visit()
  self.visited = true
end

function field:Visited()
  return self.visited
end

function field:setStench( bool )
  self.stench = bool
end

function field:printStench()
  if self.stench then 
    return "S" 
  else 
    return " " 
  end
end

function field:setBreeze( bool )
  self.breeze = bool
end

function field:printBreeze()
  if self.breeze then 
    return "B" 
  else 
    return " " 
  end
end

function field:setGold( bool )
  self.gold = bool
  self.glitter = bool
end

function field:getGold()
  return self.gold
end

function field:printGlitter()
  if self.gold then 
    return "G" 
  else 
    return " " 
  end
end

function field:setWumpus( bool )
  self.wumpus = bool
end

function field:getWumpus()
  return self.wumpus
end

function field:printWumpus()
  if self.wumpus then
    return "W"
  else
    return " "
  end
end

function field:getPit()
  return self.pit
end

function field:setPit( bool )
  self.pit = bool
end

function field:printPit()
  if self.pit then 
    return "P"
  else
    return " "
  end
end

function field:kill()
  if self.wumpus then
    self.wumpus = false
    print("***** SCREAM *****")
    return true
  end
  return false
end

function field:status()
  return { self.visited, self.stench, self.breeze, self.glitter }
end

local field_mt = Class( field )

function field:new()
  
  local wumpus = false
  local gold = false
  local pit = false
  if math.random() < 0.2 then
    pit = true
  end
  
  local visited = false
  local stench = false
  local breeze = false
  local glitter = false
  
  return setmetatable( { wumpus = wumpus, gold = gold, pit = pit, visited = visited, stench = stench, breeze = breeze, glitter = glitter }, field_mt )
end