
#~ edwinhs@srv5.bullx:/scratch-shared/edwinhs/hydrosheds_ldd/process$ ls -lah ../grid_format/ 
#~ total 252K
#~ drwxr-xr-x 9 edwinhs edwinhs 4.0K Feb 21 10:05 .
#~ drwxr-xr-x 5 edwinhs edwinhs 4.0K Feb 21 10:05 ..
#~ -rw-r--r-- 1 edwinhs edwinhs 180K Feb 21 10:05 HydroSHEDS_TechDoc_v10.pdf
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 af_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 as_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 au_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 ca_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 eu_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 na_dir_30s
#~ drwxr-xr-x 4 edwinhs edwinhs 4.0K Feb 21 10:05 sa_dir_30s

set -x

rm -r per_continent_but_global_extent/*.tif

# from hydrosheds website
gdalwarp -te -180 -90 180 90 ../grid_format/af_dir_30s/af_dir_30s per_continent_but_global_extent/af_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/as_dir_30s/as_dir_30s per_continent_but_global_extent/as_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/au_dir_30s/au_dir_30s per_continent_but_global_extent/au_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/ca_dir_30s/ca_dir_30s per_continent_but_global_extent/ca_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/eu_dir_30s/eu_dir_30s per_continent_but_global_extent/eu_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/na_dir_30s/na_dir_30s per_continent_but_global_extent/na_dir_30s_global.tif
gdalwarp -te -180 -90 180 90 ../grid_format/sa_dir_30s/sa_dir_30s per_continent_but_global_extent/sa_dir_30s_global.tif

# from Bernhard Lehner
gdalwarp -te -180 -90 180 90 /scratch-shared/edwinhs/hydrosheds_ldd/northern_part/tiff_processed_by_edwin_20181127/dir/n60_dir_30s per_continent_but_global_extent/n60_dir_30s_global.tif


# the following aguila operation is too heavy 
#~ aguila per_continent_but_global_extent/*.tif

# checking the overlap in cells above n60
# - using aguila
aguila per_continent_but_global_extent/n60_dir_30s_global.tif per_continent_but_global_extent/na_dir_30s_global.tif per_continent_but_global_extent/eu_dir_30s_global.tif per_continent_but_global_extent/as_dir_30s_global.tif
# - using pcrcalc
cd per_continent_but_global_extent/
pcrcalc check_n60_dir_30s.map = "                             n60_dir_30s_global.tif - na_dir_30s_global.tif "
aguila  check_n60_dir_30s.map
pcrcalc check_n60_dir_30s.map = "cover(check_n60_dir_30s.map, n60_dir_30s_global.tif - eu_dir_30s_global.tif)"
aguila  check_n60_dir_30s.map
pcrcalc check_n60_dir_30s.map = "cover(check_n60_dir_30s.map, n60_dir_30s_global.tif - as_dir_30s_global.tif)"
aguila  check_n60_dir_30s.map
cd -

# - merge all ldd
cd per_continent_but_global_extent/
pcrcalc hydrosheds_ldd.ori.map = "cover(n60_dir_30s_global.tif, af_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, as_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, au_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, ca_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, eu_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, na_dir_30s_global.tif)"
pcrcalc hydrosheds_ldd.ori.map = "cover(hydrosheds_ldd.ori.map, sa_dir_30s_global.tif)"
 aguila hydrosheds_ldd.ori.map
cd -

# convert to pcraster ldd values
cd per_continent_but_global_extent/
rm hydrosheds_ldd.map
pcrcalc hydrosheds_ldd.map = "                          if(hydrosheds_ldd.ori.map eq   -1, ldd(5)) "
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq    0, ldd(5)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq    8, ldd(1)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq    4, ldd(2)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq    2, ldd(3)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq   16, ldd(4)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq    1, ldd(6)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq   32, ldd(7)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq   64, ldd(8)))"
pcrcalc hydrosheds_ldd.map = "cover(hydrosheds_ldd.map, if(hydrosheds_ldd.ori.map eq  128, ldd(9)))"
 aguila hydrosheds_ldd.map
mv hydrosheds_ldd.map hydrosheds_ldd_without_repair.map
cd -

# ldd repair
cd per_continent_but_global_extent/
pcrcalc global_hydrosheds_ldd.map = "lddrepair(hydrosheds_ldd_without_repair.map)"
 aguila global_hydrosheds_ldd.map
cd -

# check ldd
cd per_continent_but_global_extent/
pcrcalc check_ldd.map = "cover(scalar(hydrosheds_ldd_without_repair.map), 0.0) - cover(scalar(global_hydrosheds_ldd.map), 0.0)"
cd -

# get the catchment area
cd per_continent_but_global_extent/
pcrcalc global_catchment_hydrosheds_ldd.map = "catchment(global_hydrosheds_ldd.map, pit(global_hydrosheds_ldd.map))"
pcrcalc global_catchment_hydrosheds_ldd.sca.map = "scalar(global_catchment_hydrosheds_ldd.map)"
pcrcalc global_catchment_hydrosheds_ldd.100.map = "nominal(roundup(areauniform(global_catchment_hydrosheds_ldd.map) * 100))"
 aguila global_catchment_hydrosheds_ldd.sca.map global_catchment_hydrosheds_ldd.100.map
cd -

set +x

