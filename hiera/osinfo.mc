inventory do
     format "%s:\t%s\t%s\t%s\t%s\t%s"
 
     fields { [ identity, facts["osfamily"], facts["operatingsystem"], facts["lsbmajdistrelease"], facts["operatingsystemrelease"],facts["architecture"] ] }
 end
