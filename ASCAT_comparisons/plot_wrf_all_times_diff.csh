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
set tags1  = ('PW-10-40-M-bn')
set tags2  = ('PW-10-40-M-b')
set tags3  = ('PW-10-40-M-cn')
set tags4  = ('PW-10-40-M-c')
set tags5  = ('PW-10-40-M-an')
set tags6  = ('PW-10-40-M-a')

##############
# Set directory paths and create output directory
##############
# Directory paths and creation
set maindir = '/data/duvivier/polar_winds/analysis/ASCAT_comparisons/'
set outdir = $maindir'figures/ASCAT_WRF_all_times'
mkdir -p $outdir
echo 'Now running for '$outdir

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
while ($t <= 1)

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
       'tag4           = "'$tags4[$t]'"' \
       'tag5           = "'$tags5[$t]'"' \
       'tag6           = "'$tags6[$t]'"' \
       ${maindir}ascat_wrf_all_times_diff.ncl
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

