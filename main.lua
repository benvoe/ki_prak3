require('Praktikum_3/hunt_the_wumpus')
math.randomseed( os.time() )

htw = hunt_the_wumpus:new( 1 )

input = true
input_buffer = {}

htw:Print()
reprint = true

while input do
  
  if #input_buffer == 0 then
    input_buffer = toChar( io.read() )
  end
  
  input = table.remove(input_buffer,1)
  
  if input == "F" or input == "f" then
    input = htw:Forward()
    reprint = true
  elseif input == "L" or input == "l" then
    input = htw:TurnLeft()
    reprint = true
  elseif input == "R" or input == "r" then
    input = htw:TurnRight()
    reprint = true
  elseif input == "G" or input == "g" then
    input = htw:Grab()
    reprint = true
  elseif input == "S" or input == "s" then
    input = htw:Shoot()
  elseif input == "C" or input == "c" then
    input = htw:Climb()
  elseif input == "?" then
    input = htw:ASK( read_facts( input_buffer ) )
    input_buffer = {}
    reprint = false
  elseif input == "P" or input == "p" then
    reprint = true
  else
    if htw.player.points < 0 or input == "q" then
      input = false
    end
  end
  
  if not input then 
    if htw.player.points > 0 then
      print("Möchten Sie weiter spielen? (Y/n)")
      input = io.read()
      if input == "y" or input == "Y" then
        htw:newWorld()
        htw.player:setBack()
        input = true
      else
        print("Das Spiel wird beendet.")
      end
    else
      print("Möchten Sie noch einmal spielen? (Y/n)")
      input = io.read()
      if input == "y" or input == "Y" then
        htw = hunt_the_wumpus:new()
        input = true
      else
        print("Das Spiel wird beendet.")
      end
    end
  end
  
  if reprint then htw:Print() reprint = false end
  
end

htw:PrintInfo() 

print( "FINITO!" )