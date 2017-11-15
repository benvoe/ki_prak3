require( 'Praktikum_3/knowledge_base' )


kb = knowledge_base:new(1)

print( kb:conclusion( { "-B34", "P12=>-W11" }, "-B34" ) )


---[[
a1 = { "a", "-b", "-c", "e", "-0" }
b1 = { "c", "b", "-e", "-g", "h", "i", "0"}

for i,v in ipairs( kb:Resolve( a1, b1 ) ) do
  print( unpack( v ) )
end
--]]

a2 = { "a", "b", "c", "d"}
b2 = { "c", "d", "e", "a"}

print( unpack( kb:unite( a2, b2 ) ) )


a3 = { {"a"}, {"b", "c"}, {"f"}}
b3 = { {"b", "c"}, {"d"}, {"e"}, {"a"}, {"f"}}

print( "A3 is a Subset of B3: " .. tostring( kb:subset( a3, b3 ) ) )

table.insert( kb.kb, {"-P21","B11"} )
table.insert( kb.kb, {"-B11","P12", "P21"} )
table.insert( kb.kb, {"-P12","B11"} )
table.insert( kb.kb, {"-B11"} )

--kb:TELL{1, 1, false, false}
--kb:TELL{2, 1, true, false}
--kb:TELL{1, 2, false, true}

kb:Print()

--print( "Validation: " .. tostring( kb:Validate{"W13", "W22", "W11"} ) )

--print( Not( "abcd" ) )


alpha = { "P12" }

print( "Resolution von { " .. table.concat( alpha, ", " ) .. " } mit KB ergiebt: " .. tostring( kb:Resolution( alpha ) ) )



print( "The End!" )