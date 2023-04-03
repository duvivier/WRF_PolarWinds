#! /bin/tcsh -f

# Script to create node average netcdf files
# This is specific to my som study but could be modified fairly easily
# Alice DuVivier- July 2013
#################################################
##############
# Choose location
##############
set days  = ('20' '21')
set pass  = ('ASC' 'DES')
set sat   = ('A' 'B')
set tags1 = ('PW-50-40-M-a' 'PW-25-40-M-a' 'PW-10-40-M-a' 'PW-05-40-M-a' 'PW-50-40-M-an' 'PW-25-40-M-an' 'PW-10-40-M-an' 'PW-05-40-M-an')
set tags2 = ('PW-50-40-M-b' 'PW-25-40-M-b' 'PW-10-40-M-b' 'PW-05-40-M-b' 'PW-50-40-M-bn' 'PW-25-40-M-bn' 'PW-10-40-M-bn' 'PW-05-40-M-bn')
set tags3 = ('PW-50-40-M-c' 'PW-25-40-M-c' 'PW-10-40-M-c' 'PW-05-40-M-c' 'PW-50-40-M-cn' 'PW-25-40-M-cn' 'PW-10-40-M-cn' 'PW-05-40-M-cn')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/sim_start_comparison/ASCAT/'

##############
# start variable loop
##############
set d = 1
while ($d <= 2)
set p = 1
while ($p <= 2)
set s = 1
while ($s <= 2)
set t = 1
while ($t <= 8)

#set outdir = $maindir'figures/'$tags1[$t]'-vs-'$tags2[$t]'-vs-'$tags3[$t]
set outdir = $maindir'figures/4panel_start_compare'
mkdir -p $outdir
echo 'Now running for '$outdir

##############
# Input into ncl
##############
        echo 'Processing plots for '$days[$d]' '$pass[$p]' '$sat[$s]
   ncl 'day            = "'$days[$d]'"'\
       'pass           = "'$pass[$p]'"' \
       'sat            = "'$sat[$s]'"' \
       'tag1           = "'$tags1[$t]'"' \
       'tag2           = "'$tags2[$t]'"' \
       'tag3           = "'$tags3[$t]'"' \
       ${maindir}ascat_4panel.ncl
   mv *.png $outdir
   rm *.ps

@ t ++
end
@ s ++
end
@ p ++
end
@ d ++
end

