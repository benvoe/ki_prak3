require('Class')
require('Praktikum_1/queue/fifo')

knowledge_base = {}

function knowledge_base:ASK( question )
  if self.resolution then
    return self:Resolution( question )
  else
    return self:ForwardChaining( question )
  end
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
  
  self:Insert{ Not( wump_yx ) }
  self:Insert{ Not( pit_yx ) }
  
  if breeze then 
    self:Insert{ breeze_yx }
  else 
    self:Insert{ Not( breeze_yx ) }
  end
  
  if stench then 
    self:Insert{ stench_yx }
  else 
    self:Insert{ Not( stench_yx ) }
  end
  
  local n = {} -- Neighbours
  
  if y < 4 then n[1] = y+1 .. x else n[1] = false end
  if x < 4 then n[2] = y .. x+1 else n[2] = false end
  if y > 1 then n[3] = y-1 .. x else n[3] = false end
  if x > 1 then n[4] = y .. x-1 else n[4] = false end
  
  local n_d = {}
  
  if y < 4 and x < 4 then n_d[1] = y+1 .. x+1 else n_d[1] = false end
  if y > 1 and x < 4 then n_d[2] = y-1 .. x+1 else n_d[2] = false end
  if y > 1 and x > 1 then n_d[3] = y-1 .. x-1 else n_d[3] = false end
  if y < 4 and x > 1 then n_d[4] = y+1 .. x-1 else n_d[4] = false end
  
  local wump_clausel = { Not( stench_yx ) }
  local pit_clausel = { Not( breeze_yx ) }
  
  
  if( self.resolution ) then
    for _,yx in pairs( n ) do 
      if yx then
        self:Insert{ breeze_yx, "-P"..yx }
        self:Insert{ stench_yx, "-W"..yx }
        
        table.insert( wump_clausel, "W"..yx )
        table.insert( pit_clausel, "P"..yx )
      end
    end
    
    self:Insert( wump_clausel )
    self:Insert( pit_clausel )
  else
    for i,yx in pairs( n ) do
      
      if yx and n[ i % 4 + 1 ] and n_d[i] then
        self:Insert{ "-W"..n[ i % 4 + 1 ], "S"..n_d[i], stench_yx.."=>W"..yx }
        self:Insert{ "-P"..n[ i % 4 + 1 ], "B"..n_d[i], breeze_yx.."=>P"..yx }
      end
      
      print( ( i+2 ) % 4 + 1 );
      
      if yx and n[ ( i+2 ) % 4 + 1 ] and n_d[ ( i+2 ) % 4 + 1 ] then
        self:Insert{ "-W"..n[ ( i+2 ) % 4 + 1 ], "S"..n_d[ ( i+2 ) % 4 + 1 ], stench_yx.."=>W"..yx }
        self:Insert{ "-P"..n[ ( i+2 ) % 4 + 1 ], "B"..n_d[ ( i+2 ) % 4 + 1 ], breeze_yx.."=>P"..yx }
      end
      
      if yx and ( n_d[ i % 4 + 1 ] or n_d[ ( i+1 ) % 4 + 1 ] ) then
        local w_term = {}
        local p_term = {}
        if n_d[ i % 4 + 1 ] then
          table.insert( w_term, "-S"..n_d[ i % 4 + 1 ] )
          table.insert( p_term, "-B"..n_d[ i % 4 + 1 ] )
        end
        if n_d[ ( i+1 ) % 4 + 1 ] then 
          table.insert( w_term, "-S"..n_d[ ( i+1 ) % 4 + 1 ] )
          table.insert( p_term, "-B"..n_d[ ( i+1 ) % 4 + 1 ] )
        end
        table.insert( w_term, stench_yx.."=>W"..yx )
        table.insert( p_term, breeze_yx.."=>P"..yx )
        
        self:Insert( w_term )
        self:Insert( p_term )
      end
      
      if yx and ( n[ i % 4 + 1 ] or n[ ( i+1 ) % 4 + 1 ] or n[ ( i+2 ) % 4 + 1 ] ) then
        local w_term = {}
        local p_term = {}
        
        if n[ i % 4 + 1 ] then
          table.insert( w_term, "-S"..n[ i % 4 + 1 ] )
          table.insert( p_term, "-B"..n[ i % 4 + 1 ] )
        end
        if n[ ( i+1 ) % 4 + 1 ] then
          table.insert( w_term, "-S"..n[ ( i+1 ) % 4 + 1 ] )
          table.insert( p_term, "-B"..n[ ( i+1 ) % 4 + 1 ] )
        end
        if n[ ( i+2 ) % 4 + 1 ] then
          table.insert( w_term, "-S"..n[ ( i+2 ) % 4 + 1 ] )
          table.insert( p_term, "-B"..n[ ( i+2 ) % 4 + 1 ] )
        end
        
        table.insert( w_term, stench_yx.."=>W"..yx )
        table.insert( p_term, breeze_yx.."=>P"..yx )
        
        self:Insert( w_term )
        self:Insert( p_term )
      end
    end
  end
  
 
  self:Print()
end

function knowledge_base:Validate( value )
  if not self.resolution and #value == 1 then
    return self:contains_table( self.agenda, value )
  else
    return self:contains_table( self.kb, value )
  end
end

function knowledge_base:contains( table, value )
  for _,v in ipairs( table ) do
    if v == value then return true end
  end
  return false
end

function knowledge_base:contains_table( Table, value )
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
    if not self.resolution and #value == 1 then
      table.insert( self.agenda, value )
    else
      table.insert( self.kb, value )
    end
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

function knowledge_base:ForwardChaining( q ) 
  if #q > 1 then print( "Eingabe konnte nicht bearbeitet werden." ) return false end
  
  q = q[1]
  
  local count = {}
  local inferred = {}
  local agenda = FIFO:new()
  for _,v in ipairs( self.agenda ) do
    table.insert( agenda, v[1] )
    inferred[ v[1] ] = false
  end
  
  local kb = {}
  for _,v in ipairs( self.kb ) do
    table.insert( kb, { unpack( v ) } )
    table.insert( count, #v )
  end
  
  
  while #agenda > 0 do
    local p = agenda:pop()
    if p == q then return true end
    
    if inferred[ p ] == false then 
      inferred[ p ] = true
      for i,clause in ipairs( kb ) do
        if self:clause_contains( clause, p ) then
          count[i] = count[i] - 1
          if count[i] == 0 then 
            agenda:push( conclusion( clause ) )
          end
        end
      end
    end
  end
  return false
end

function clause_contains( clause, p )
  
  for i,v in ipairs( clause ) do
    if i < #clause and v == p then
      return true
    else
      char_v = toChar( v )
      if p == char_v[1]..char_v[2]..char_v[3] or p == char_v[1]..char_v[2]..char_v[3]..char_v[4] then
        return true
      end
    end
  end
  
  return false
end

function conclusion( clause ) 
  local cc =  toChar( clause[ #clause ] )
  return cc[#cc-2] .. cc[#cc-1] .. cc[#cc]
end




function knowledge_base:Print()
  print("***  Knowledge-Base:  ***")
  
  if not self.resolution then
    print( "Agenda:" )
    for _,v in ipairs( self.agenda ) do
      print( "{" .. table.concat(v, ", ") .. "}")
    end
    print("\nHorn-Klauseln:")
  end
  
  for _,v in ipairs( self.kb ) do
    print("{" .. table.concat(v, ", ") .. "}")
  end
end


knowledge_base_mt = Class(knowledge_base)

function knowledge_base:new( algorithm )
  
  local resolution = algorithm == 1
  
  local kb = {}
  local agenda = {}
  
  return setmetatable( { kb = kb, agenda = agenda, resolution = resolution }, knowledge_base_mt )
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