require("Class")
require( 'Praktikum_3/field' )
require( 'Praktikum_3/player' )
require( 'Praktikum_3/knowledge_base' )

hunt_the_wumpus = {}

function hunt_the_wumpus:Print() 
  --"clear output", top right
  
  local hr = "---------------------------"
  local blank = "     |"
  local bottom = "     1     2     3     4   "
  
  print( hr )
  
  for a = 1, 4 do
    local i = 5 - a
    local line1 = "  |"
    local line2 = i .. " |"
    local line3 = "  |"
    
    for j = 1, 4 do
      if self.world[i][j]:Visited() then
        line1 = line1 .. "  " .. self.world[i][j]:printGlitter() .. "  |"
        line2 = line2 .. self.world[i][j]:printStench() .. " " .. self.player:Print( i, j ) .. " " .. self.world[i][j]:printBreeze() .. "|"
        line3 = line3 .. "  V  |"
      else
        line1 = line1 .. blank
        line2 = line2 .. blank
        line3 = line3 .. blank
      end
    end
    
    print( line1 )
    print( line2 )
    print( line3 )
    print( hr )
  end
  print( bottom )
  print()
  print("Score: " .. self.player:getPoints())
  print("Percept: [" .. table.concat(self:percept(),", ") .. "]")
  print("Action: (F, L, R, G, S or C) ?")
end

function hunt_the_wumpus:PrintInfo() 
  --"clear output", top right
  
  local hr = "---------------------------"
  local blank = "     |"
  local bottom = "     1     2     3     4   "
  
  print( hr )
  
  for a = 1, 4 do
    local i = 5 - a
    local line1 = "  |"
    local line2 = i .. " |"
    local line3 = "  |"
    
    for j = 1, 4 do
        line1 = line1 .. "  " .. self.world[i][j]:printGlitter() .. "  |"
        line2 = line2 .. self.world[i][j]:printWumpus() .. "   " .. self.world[i][j]:printPit() .. "|"
        line3 = line3 .. blank
    end
    
    print( line1 )
    print( line2 )
    print( line3 )
    print( hr )
  end
  print( bottom )
end

function hunt_the_wumpus:Forward()
  local next_field = self.player:Forward()
  if next_field then
    self.world[ next_field[1] ][ next_field[2] ]:visit()
    if self.world[ next_field[1] ][ next_field[2] ]:getWumpus() or self.world[ next_field[1] ][ next_field[2] ]:getPit() then
      local points = self.player:kill()
      if points then
        print("Sie haben noch " .. points .. " Punkte zur Verfügung.")
      else
        print("GAME OVER !!!")
      end
      self.kb:TELL( self:sequence() )
      return false
    end
  else
    print("Keine Aktion möglich.")
  end
  self.kb:TELL( self:sequence() )
  return true
end

function hunt_the_wumpus:TurnLeft()
  self.player:TurnLeft()
  return true
end

function hunt_the_wumpus:TurnRight()
  self.player:TurnRight()
  return true
end

function hunt_the_wumpus:Grab()
  if self.world[ self.player.position_y ][ self.player.position_x]:getGold() then
    self.world[ self.player.position_y ][ self.player.position_x]:setGold( false )
    self.player:grab( true )
  end
  return true
end

function hunt_the_wumpus:Shoot()
  shoot_res = self.player:shoot()
  if not shoot_res then
    print("Kein Pfeil mehr verfügbar.")
    return
  end
  
  y = shoot_res[1]
  x = shoot_res[2]
  d = shoot_res[3]
  c = 0
  hit = false
  
  if d == "T" or d == "R" then
    c = 1
  else 
    c = -1
  end
  
  while x >= 1 and x <= 4 and y >= 1 and y <= 4 do
    hit = hit or self.world[y][x]:kill()
    
    if d == "T" or d == "D" then
      y = y + c
    else
      x = x + c
    end
  end
  
  if hit then 
    self.scream = true
  else
    self.bump = true
  end
  
 return true
end

function hunt_the_wumpus:Climb()
  if self.player:climb() then
    print("Herzlichen Glückwunsch!")
    return false
  end
  return true
end

function hunt_the_wumpus:percept()
  info = {}
  if self.world[ self.player.position_y ][ self.player.position_x ].stench then table.insert(info, "S") else table.insert(info, "N") end
  if self.world[ self.player.position_y ][ self.player.position_x ].breeze then table.insert(info, "B") else table.insert(info, "N") end
  if self.world[ self.player.position_y ][ self.player.position_x ].glitter then table.insert(info, "G") else table.insert(info, "N") end
  if self.bump then 
    table.insert(info, "Bump")
    self.bump = false
  else 
    table.insert(info, "N") 
  end
  if self.scream then 
    table.insert(info, "Scream") 
    self.scream = false
  else 
    table.insert(info, "N") 
  end
  return info
end

function hunt_the_wumpus:sequence()
  seq = {}
  table.insert(seq, self.player.position_y)
  table.insert(seq, self.player.position_x)
  table.insert(seq, self.world[ self.player.position_y ][ self.player.position_x ].breeze )
  table.insert(seq, self.world[ self.player.position_y ][ self.player.position_x ].stench )
  return seq
end

function hunt_the_wumpus:ASK( question )
  --print( "Die Resolution ergab: " .. tostring( self.kb:Resolution( question ) ) )
  if self.kb:ASK( question ) then
    print( "Alpha folg aus der KB :-)" )
  else
    print( "Alpha folgt NICHT aus der KB" )
  end
  
  return true
end

function hunt_the_wumpus:newWorld()
  local world = {}
  
  for i = 1, 4 do
    table.insert(world, {})
    for j = 1, 4 do
      table.insert( world[i], field:new() )
    end
  end
  
  world[1][1]:visit()
  if world[1][1]:getPit() then world[1][1]:setPit( false ) end
  
  
  local x1 = 1
  local y1 = 1
  
  while x1 == 1 and y1 == 1 do
    x1 = math.random(4)
    y1 = math.random(4)
  end
  
  world[y1][x1]:setWumpus( true )
  
  if y1 < 4 then world[y1+1][x1]:setStench( true ) end
  if y1 > 1 then world[y1-1][x1]:setStench( true ) end
  if x1 < 4 then world[y1][x1+1]:setStench( true ) end
  if x1 > 1 then world[y1][x1-1]:setStench( true ) end
  
  if world[y1][x1]:getPit() then world[y1][x1]:setPit( false ) end  
  
  local x2 = 1
  local y2 = 1
  
  while x2 == 1 and y2 == 1 or x2 == x1 and y2 == y1 do
    x2 = math.random(4)
    y2 = math.random(4)
  end
  
  world[y2][x2]:setGold( true )
  if world[y2][x2]:getPit() then world[y2][x2]:setPit( false ) end
  
  for a = 1, 4 do
    i = 5 - a
    for j = 1, 4 do
      if world[i][j]:getPit() then
        y, x = i, j
        if y < 4 then world[y+1][x]:setBreeze( true ) end
        if y > 1 then world[y-1][x]:setBreeze( true ) end
        if x < 4 then world[y][x+1]:setBreeze( true ) end
        if x > 1 then world[y][x-1]:setBreeze( true ) end
      end
    end
  end
  
  self.world = world
end

local hunt_the_wumpus_mt = Class( hunt_the_wumpus )

function hunt_the_wumpus:new( kb_algorithm )
  
  local world = {}
  
  for i = 1, 4 do
    table.insert(world, {})
    for j = 1, 4 do
      table.insert( world[i], field:new() )
    end
  end
  
  world[1][1]:visit()
  if world[1][1]:getPit() then world[1][1]:setPit( false ) end
  
  
  local x1 = 1
  local y1 = 1
  
  while x1 == 1 and y1 == 1 do
    x1 = math.random(4)
    y1 = math.random(4)
  end
  
  world[y1][x1]:setWumpus( true )
  
  if y1 < 4 then world[y1+1][x1]:setStench( true ) end
  if y1 > 1 then world[y1-1][x1]:setStench( true ) end
  if x1 < 4 then world[y1][x1+1]:setStench( true ) end
  if x1 > 1 then world[y1][x1-1]:setStench( true ) end
  
  if world[y1][x1]:getPit() then world[y1][x1]:setPit( false ) end  
  
  local x2 = 1
  local y2 = 1
  
  while x2 == 1 and y2 == 1 or x2 == x1 and y2 == y1 do
    x2 = math.random(4)
    y2 = math.random(4)
  end
  
  world[y2][x2]:setGold( true )
  if world[y2][x2]:getPit() then world[y2][x2]:setPit( false ) end
  
  for a = 1, 4 do
    i = 5 - a
    for j = 1, 4 do
      if world[i][j]:getPit() then
        y, x = i, j
        if y < 4 then world[y+1][x]:setBreeze( true ) end
        if y > 1 then world[y-1][x]:setBreeze( true ) end
        if x < 4 then world[y][x+1]:setBreeze( true ) end
        if x > 1 then world[y][x-1]:setBreeze( true ) end
      end
    end
  end
  
  
  local player = player:new()
  local kb = knowledge_base:new( kb_algorithm )
  
  kb:TELL( { 1, 1, world[1][1].breeze, world[1][1].stench } )
  
  local bump = false
  local scream = false
  
  return setmetatable( { world = world, player = player, kb = kb, bump = bump, scream = scream }, hunt_the_wumpus_mt )
end
