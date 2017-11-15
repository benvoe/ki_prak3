require('Class')

knowledge_base = {}

function knowledge_base:ASK( question )

end

function knowledge_base:TELL( sequence )
  local y = sequence[1]
  local x = sequence[2]
  local breeze = sequence[3]
  local stench = sequence[4]
  
  local wump_yx = "W" .. y .. x
  local pit_yx = "P" .. y .. x
  local breeze_yx = "B" .. y .. x
  local stench_yx = "S" .. y .. x
  
  ---[[
  self:Insert{ Not( wump_yx ) }
  self:Insert{ Not( pit_yx ) }
  --]]
  
  if breeze then 
    table.insert( self.kb, { breeze_yx } )
  else 
    table.insert( self.kb, { Not( breeze_yx ) } )
  end
  
  if stench then 
    table.insert( self.kb, { stench_yx } )
  else 
    table.insert( self.kb, { Not( stench_yx ) } )
  end
  
  local neightbours = {}
  
  if y > 1 then table.insert( neightbours, y-1 .. x ) end
  if y < 4 then table.insert( neightbours, y+1 .. x ) end
  if x > 1 then table.insert( neightbours, y .. x-1 ) end
  if x < 4 then table.insert( neightbours, y .. x+1 ) end
  
  local wump_clausel = { Not( stench_yx ) }
  local pit_clausel = { Not( breeze_yx ) }
  
  for _,yx in ipairs( neightbours ) do 
    self:Insert{ breeze_yx, "-P"..yx }
    self:Insert{ stench_yx, "-W"..yx }
    
    table.insert( wump_clausel, "W"..yx )
    table.insert( pit_clausel, "P"..yx )
  end
  
  self:Insert( wump_clausel )
  
  self:Insert( pit_clausel )
  
  --self:Print()
end

function knowledge_base:Validate( value )
  return self:contains_table( self.kb, value )
end

function knowledge_base:contains_table( Table, value )
  for _,v in ipairs( Table ) do
    if #v == #value then
      local equal = true
      local used_nodes = {}
      
      for _,k in ipairs( value ) do 
        equal = equal and self:contains( v, k ) and not self:contains( used_nodes, k )
        table.insert( used_nodes, k )
      end
      
      if equal then return true end
    end
  end
  return false
end

function knowledge_base:contains( table, value )
  for _,v in ipairs( table ) do
    if v == value then return true end
  end
  return false
end

function knowledge_base:unite( clausel1, clausel2 )
  local union = { unpack( clausel1 ) }
  for _,v in ipairs( clausel2 ) do
    if not self:contains( union, v ) then
      table.insert( union, v )
    end
  end
  return union
end

function knowledge_base:unite_table( table1, table2 )
  local union = { unpack( table1 ) }
  for _,v in ipairs( table2 ) do
    if not self:contains_table( union, v ) then
      table.insert( union, v )
    end
  end
  return union
end

function knowledge_base:subset( sub_set, upper_set )
  local is_subset = true
  for _,v in ipairs( sub_set ) do
    is_subset = is_subset and self:contains_table( upper_set, v )
  end
  return is_subset
end

function knowledge_base:Insert( value )
  if type( value ) == "table" and not self:Validate( value ) then
    table.insert( self.kb, value )
  end
end

function knowledge_base:Resolve( clausel1, clausel2 )
  local resolvent = {}
  
  for c1,v1 in ipairs( clausel1 ) do
    for c2,v2 in ipairs( clausel2 ) do
      if v1 == Not( v2 ) then
        local copy_clausel1 = { unpack( clausel1 ) }
        table.remove( copy_clausel1, c1 )
        
        local copy_clausel2 = { unpack( clausel2 ) }
        table.remove( copy_clausel2, c2 )
        
        table.insert( resolvent, self:unite( copy_clausel1, copy_clausel2 ) )
      end
    end
  end
  
  return resolvent
end

function knowledge_base:Resolution( alpha )
  local clauses = { unpack( self.kb ) }
  
  if not self:contains_table( clauses, alpha ) then
    table.insert( clauses, alpha )
  end
  
  --[[
  for _,v in ipairs( alpha ) do
    table.insert( clauses, { Not( v ) } )
  end
  --]]
  local new = {}
  
  while true do
    for i,c1 in ipairs( clauses ) do
      for j,c2 in ipairs( clauses ) do
        local resolvent = self:Resolve( c1, c2 )
        --print( type( resolvent ) )
        --[[
        for c,v in ipairs( resolvent ) do
          print("===== Resolved =====")
          print("[ " .. table.concat( v, ", ") .. " ]")
          print("====================")
        end
        --]]
        if self:contains_table( resolvent, {} ) then return true end
        
        new = self:unite_table( new, resolvent )
      end
    end
    if self:subset( new, clauses ) then return false end
    
    clauses = self:unite_table( clauses, new )
  end
end


function knowledge_base:Print()
  print("Knowledge-Base:")
  for _,v in ipairs( self.kb ) do
    print("{" .. table.concat(v, ", ") .. "}")
  end
end


knowledge_base_mt = Class(knowledge_base)

function knowledge_base:new()
  kb = {}
  
  table.insert( kb, { "-W11" } )
  table.insert( kb, { "-P11" } )
  
  return setmetatable( { kb = kb }, knowledge_base_mt )
end

--#####################################################################

function Not( fakt ) 
  fakt = toChar( fakt )
  
  local i = 1
  local invert = ""
  
  if fakt[1] == "-" then
    i = 2
  else
    invert = "-"
  end
  
  while i <= #fakt do
    invert = invert .. fakt[i]
    i = i + 1
  end
  
  return invert
end

function read_facts( buffer )
  local result = {}
  for i=1, #buffer - 2 do
    if      ( buffer[i-1] == " " or buffer[i-1] == "," or buffer[i-1] == nil ) 
        and ( buffer[i+3] == " " or buffer[i+3] == "," or buffer[i+3] == nil ) 
        and ( tonumber( buffer[i+1] ) ~= nil and tonumber( buffer[i+2] ) ~= nil ) then
      
      table.insert( result, "-" .. buffer[i] .. buffer[i+1] .. buffer[i+2] )
    elseif  ( buffer[i-1] == " " or buffer[i-1] == "," or buffer[i-1] == nil ) 
        and ( buffer[i+4] == " " or buffer[i+4] == "," or buffer[i+4] == nil ) 
        and ( buffer[i] == "-"and  tonumber( buffer[i+2] ) ~= nil and tonumber( buffer[i+3] ) ~= nil ) then
      
      table.insert( result, buffer[i+1] .. buffer[i+2] .. buffer[i+3] ) 
    end
  end
  return result
end

function toChar( string )
  res = {}
  for i = 1, #string do
    table.insert(res,string:sub(i,i))
  end
  return res
end