require( 'Class' )

  
  player = {}
  
  function player:Forward()
    
    if self.direction == "R" and self.position_x < 4 then
      self.position_x = self.position_x + 1;
    elseif self.direction == "L" and self.position_x > 1 then
      self.position_x = self.position_x - 1;
    elseif self.direction == "T" and self.position_y < 4 then
      self.position_y = self.position_y + 1;
    elseif self.direction == "D" and self.position_y > 1 then
      self.position_y = self.position_y - 1;
    else
      return false
    end
    
    self.points = self.points - 1
    
    return { self.position_y, self.position_x }
  end
  
  function player:TurnLeft()
    self.points = self.points - 1
    
    if self.direction == "R" then
      self.direction = "T"
      return self.direction
    elseif self.direction == "L" then
      self.direction = "D"
      return self.direction
    elseif self.direction == "T" then
      self.direction = "L"
      return self.direction
    elseif self.direction == "D" then
      self.direction = "R"
      return self.direction
    end
    
  end
  
  function player:TurnRight()
    self.points = self.points - 1
    
    if self.direction == "R" then
      self.direction = "D"
      return self.direction
    elseif self.direction == "L" then
      self.direction = "T"
      return self.direction
    elseif self.direction == "T" then
      self.direction = "R"
      return self.direction
    elseif self.direction == "D" then
      self.direction = "L"
      return self.direction
    end
    
  end
  
  function player:grab( bool )
    if bool then
      self.has_gold = true
      self.points = self.points - 1
    end
  end
  
  function player:climb()
    if self.has_gold and self.position_x == 1 and self.position_y == 1 then
      self.points = self.points - 1
      self.points = self.points + 1000
      self.has_gold = false
      return true
    else
      return false
    end
  end
  
  function player:shoot()
    if self.arrow then
      self.arrow = false
      self.points = self.points - 10
      
      return { self.position_y, self.position_x, self.direction }
    end
    return self.arrow
  end
  
  function player:Print( y, x )
    if self.position_x == x and self.position_y == y then
      if self.points < 0 then
        return "X"
      elseif self.direction == "R" then
        return ">"
      elseif self.direction == "L" then
        return "<"
      elseif self.direction == "T" then
        return "^"
      elseif self.direction == "D" then
        return "v"
      end
    end
    return " "
  end
  
  function player:getPoints()
    return self.points
  end
  
  function player:kill()
    self.points = self.points - 1000
    if self.points < 0 then
      return false
    else
      return self.points
    end
  end
  
  function player:setBack()
    self.position_x = 1
    self.position_y = 1
    self.arrow = true
    self.has_gold = false
  end
  
  local player_mt = Class( player )
  
  function player:new()
    
    local direction = "R" -- R[ight], L[left], T[op], D[own]
    local points = 1000
    local position_x = 1
    local position_y = 1
    local arrow = true
    local has_gold = false
  
    return setmetatable( { direction = direction, points = points, position_x = position_x, position_y = position_y, arrow = arrow, has_gold = has_gold }, player_mt )
  end
  