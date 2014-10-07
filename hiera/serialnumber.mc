inventory do
     format "|%s|%s|%s|"
 
     fields { [ facts["productname"], facts["hostname"], facts["serialnumber"] ] }
end

