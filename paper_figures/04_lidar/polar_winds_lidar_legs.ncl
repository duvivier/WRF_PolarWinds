;***************************************
; PROGRAM DESCRIPTION: This NCL script makes cross section plots of WRF data
; INPUT DATA: WRF output of any resolution
; OUTPUT DATA: spatial plot of cross section location and cross section
; Note: loop this script with 02_21FEB_15Z.csh
; CREATORS: Alice DuVivier - April 2011
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
;MANUAL INPUTS - for testing purposes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load lidar data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Loading data for flight legs")
files = systemfunc("ls /data/duvivier/polar_winds/DATA/DAWN_PROFS_NOTFINAL/*.csv")
ndates = dimsizes(files)
prof_num = new((/ndates/),integer)
n = 0
do n = 0, ndates-1
   dum1 = stringtochar(files(n))
   dum2 = chartostring(dum1(75:77))
   dum3 = stringtoint(dum2)
   prof_num(n) = dum3
   delete([/dum1,dum2,dum3/])
end do

; set file info
nvert = 60
delim = ","

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate pass A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  n_s = 294.0 ;294.0
  n_e = 309.0
  npts = 35

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
hgt = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; reverse the start points for legs A, or C so that the side near land is the start of the cross section
   hgt = hgt(:,::-1)
   ws  = ws(:,::-1)
   lat = lat(:,::-1)
   lon = lon(:,::-1)

; get start and end points for legs. 
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  ws  = ws(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar_A = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar_A(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do
  y_A = dist_lidar_A
  y_A = 20.0

;;;;;;;;;;;;;;;;;;;;;
; Interpolate to regular grid
;;;;;;;;;;;;;;;;;;;;;
print("Interpolating to cross section line")
; NOTE: npts for each leg has been chosen above to lead to 2km spacing for each pass

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lat_leg = length@gclat          ; the lats of the points interpolating to
   lon_leg = length@gclon          ; the lons of the points interpolating to
   space_leg = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lat_leg)

  ; create regular horizontal distance array to plot values
   dist_grid = new((/n_cross/),"float")
   km = 0.
   n = 0
   do n = 0, n_cross-1
     dist_grid(n) = km
     km = km + space_leg
   end do
   dist_grid!0 = "Horizontal"
   dist_grid@units = "km" 

  ; create vertical spacing in meters
  n_lev = 5000
  n_space = 50  ;10   - spacing between levels, in m
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid before 2d interpolation
  ws_new_1 = new((/n_hgts,ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(:,n)))
    xi = hgt(inds,n)
    ws_sub = ws(inds,n)
    ws_new_1(:,n) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub/])
  end do
  
  ; now interpolate lidar data to regular horizontal grid
  ws_new_A = linint2_Wrap(dist_lidar_A,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)

delete([/n_s,n_e,npts,files_sub,hgt,ws,lat,lon,length,lat_leg,lon_leg,space_leg,n_cross,dist_grid,hgt_grid,n_hgts,ws_new_1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate pass B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  n_s = 314.0
  n_e = 324.0
  npts = 25

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
hgt = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; get start and end points for legs. 
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  ws  = ws(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar_B = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar_B(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do
  y_B = dist_lidar_B
  y_B = 20.0

;;;;;;;;;;;;;;;;;;;;;
; Interpolate to regular grid
;;;;;;;;;;;;;;;;;;;;;
print("Interpolating to cross section line")
; NOTE: npts for each leg has been chosen above to lead to 2km spacing for each pass

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lat_leg = length@gclat          ; the lats of the points interpolating to
   lon_leg = length@gclon          ; the lons of the points interpolating to
   space_leg = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lat_leg)

  ; create regular horizontal distance array to plot values
   dist_grid = new((/n_cross/),"float")
   km = 0.
   n = 0
   do n = 0, n_cross-1
     dist_grid(n) = km
     km = km + space_leg
   end do
   dist_grid!0 = "Horizontal"
   dist_grid@units = "km" 

  ; create vertical spacing in meters
  n_lev = 5000
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid before 2d interpolation
  ws_new_1 = new((/n_hgts,ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(:,n)))
    xi = hgt(inds,n)
    ws_sub = ws(inds,n)
    ws_new_1(:,n) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub/])
  end do
  
  ; now interpolate lidar data to regular horizontal grid
  ws_new_B = linint2_Wrap(dist_lidar_B,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)

delete([/n_s,n_e,npts,files_sub,hgt,ws,lat,lon,length,lat_leg,lon_leg,space_leg,n_cross,dist_grid,hgt_grid,n_hgts,ws_new_1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate pass C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  n_s = 364.0
  n_e = 372.0
  npts = 19

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
hgt = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; reverse the start points for legs A, or C so that the side near land is the start of the cross section
   hgt = hgt(:,::-1)
   ws  = ws(:,::-1)
   lat = lat(:,::-1)
   lon = lon(:,::-1)

; get start and end points for legs. 
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  ws  = ws(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar_C = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar_C(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do
  y_C = dist_lidar_C
  y_C = 20.0

;;;;;;;;;;;;;;;;;;;;;
; Interpolate to regular grid
;;;;;;;;;;;;;;;;;;;;;
print("Interpolating to cross section line")
; NOTE: npts for each leg has been chosen above to lead to 2km spacing for each pass

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lat_leg = length@gclat          ; the lats of the points interpolating to
   lon_leg = length@gclon          ; the lons of the points interpolating to
   space_leg = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lat_leg)

  ; create regular horizontal distance array to plot values
   dist_grid = new((/n_cross/),"float")
   km = 0.
   n = 0
   do n = 0, n_cross-1
     dist_grid(n) = km
     km = km + space_leg
   end do
   dist_grid!0 = "Horizontal"
   dist_grid@units = "km" 

  ; create vertical spacing in meters
  n_lev = 5000
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid before 2d interpolation
  ws_new_1 = new((/n_hgts,ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(:,n)))
    xi = hgt(inds,n)
    ws_sub = ws(inds,n)
    ws_new_1(:,n) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub/])
  end do
  
  ; now interpolate lidar data to regular horizontal grid
  ws_new_C = linint2_Wrap(dist_lidar_C,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)

delete([/n_s,n_e,npts,files_sub,hgt,ws,lat,lon,length,lat_leg,lon_leg,space_leg,n_cross,dist_grid,hgt_grid,n_hgts,ws_new_1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Interpolate pass D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  n_s = 377.0 ;378.0
  n_e = 389.0 ;387.0
  npts = 22

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
hgt = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; get start and end points for legs. 
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  ws  = ws(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar_D = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar_D(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do
  y_D = dist_lidar_D
  y_D = 20.0

;;;;;;;;;;;;;;;;;;;;;
; Interpolate to regular grid
;;;;;;;;;;;;;;;;;;;;;
print("Interpolating to cross section line")
; NOTE: npts for each leg has been chosen above to lead to 2km spacing for each pass

  ; get great circle distance of cross section line and make distance array
   length = gc_latlon(st_lat, st_lon, ed_lat, ed_lon, npts, 4)
   lat_leg = length@gclat          ; the lats of the points interpolating to
   lon_leg = length@gclon          ; the lons of the points interpolating to
   space_leg = length@spacing       ; the spacing of the points in integer km 
   n_cross = dimsizes(lat_leg)

  ; create regular horizontal distance array to plot values
   dist_grid = new((/n_cross/),"float")
   km = 0.
   n = 0
   do n = 0, n_cross-1
     dist_grid(n) = km
     km = km + space_leg
   end do
   dist_grid!0 = "Horizontal"
   dist_grid@units = "km" 

  ; create vertical spacing in meters
  n_lev = 5000
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid before 2d interpolation
  ws_new_1 = new((/n_hgts,ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(:,n)))
    xi = hgt(inds,n)
    ws_sub = ws(inds,n)
    ws_new_1(:,n) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub/])
  end do
  
  ; now interpolate lidar data to regular horizontal grid
  ws_new_D = linint2_Wrap(dist_lidar_D,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)

delete([/n_s,n_e,npts,files_sub,hgt,ws,lat,lon,length,lat_leg,lon_leg,space_leg,n_cross,dist_grid,hgt_grid,n_hgts,ws_new_1/])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting cross section for flight legs")
; set outdir and fout names
   outdir = "./"
   fout   = outdir+"lidar_sfc_windspeed_all_legs"

;;;;;;;;;;
; Set contour information for totalwind
;;;;;;;;;;
    units = "m s-1"
    cmin1 = 0
    cmax1 = 30.
    clev1 = 2.
    stride1             = 1                  ; label stride
    spreadstart1        = 2                  ; start at color- cross section
    spreadend1          = 129                 ; end at color
    colormap            = "MPL_BuPu"

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame

  opts@cnFillMode                  = "AreaFill"
  opts@cnFillOn                    = True              ; Turn on filled contours
  opts@gsnSpreadColors             = True              ; use full colormap
  opts@gsnSpreadColorStart         = spreadstart1      ; start at color specified for variable
  opts@gsnSpreadColorEnd           = spreadend1        ; end at color specified for variable
  opts@cnLevelSelectionMode        = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF              = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF              = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF             = clev1             ; set contour spacing specified above
  opts@cnLinesOn                   = False             ; contour lines specified above  
  opts@cnInfoLabelOn               = False             ; turn off label bar at bottom
  opts@cnLineLabelsOn              = False             ; line labels on specified above
  opts@cnMissingValFillColor       = "gray85"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 

  opts@tiMainFontHeightF           = 0.025
  opts@tiMainFontThicknessF        = 1.5  
  opts@tiXAxisString               = "Distance (km)"
;  opts@tiXAxisOffsetYF             = 0.0 ;0.13
  opts@tiYAxisString               = "Height (m)"
  opts@tmXBOn                      = True
  opts@tmXBMode                    = "Explicit"
  opts@tmXBValues                  = (/0,10,20,30,40,50,60,70/)
  opts@tmXBLabels                  = (/"0","10","20","30","40","50","60","70"/)
  opts@tmXBMinorOn                 = True
;  opts@tmXBMinorMode               = "Explicit"
  opts@tmXBMinorValues             = (/5,15,25,35,45,55,65/)              
;  opts@tmXBMinorPerMajor           = 2

  opts@tmYROn                      = False
  opts@tmXTOn                      = False
  opts@tiXAxisFontHeightF          = 0.03              ; set font size for x axis
  opts@tmXBLabelFontHeightF        = 0.03              ; set tick mark label size for x axis
  opts@tiYAxisFontHeightF          = 0.03              ; set font size for y axis
  opts@tmYLLabelFontHeightF        = 0.03              ; set tick mark label size for y axis
  opts@trYMaxF                     = 1800.0
  opts@trXMaxF                     = 71.0 
  opts@vpWidthF                    = 1.0               ; set aspect ratio
  opts@vpHeightF                   = 0.55

  opts@lbLabelBarOn                = False

; Set panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = units
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbTitleDirection           = "Across"
  pnlres@lbTitleJust                = "CenterLeft"
  pnlres@lbTitleFontHeightF         = 0.0125
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.0125
  pnlres@pmLabelBarWidthF           = 0.95
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page

; set text res for labels
  txres                           = True
  txres@txFontHeightF             = 0.025 
  txres@txFontThicknessF          = 2.
  txres@txFont                    = 22
  txres@txBackgroundFillColor     = "white"
  x_txt                           = 8.0
  y_txt                           = 1650.0


; set polyres to show eta levels
   polyres                         = True
   polyres@gsMarkerIndex           = 7               ; polymarker style
   polyres@gsMarkerSizeF           = 25.               ; polymarker size
   polyres@gsMarkerColor           = "black"          ; polymarker color

;;;;;;;;;;;;;
; Make plots
;;;;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","forestgreen"/)
  gsn_merge_colormaps(wks,colormap,additional_colors)

 plot = new(4, graphic)    ; one cross section plot and one spatial plot

; Flight leg A
 cplot1 = gsn_csm_contour(wks,ws_new_A,opts)
 dum0a = gsn_add_polymarker(wks,cplot1,dist_lidar_A,y_A,polyres)
 dum0b = gsn_add_text(wks,cplot1,"a) Leg A", x_txt,y_txt,txres)
 plot(0) = cplot1

; Flight leg B
 cplot1 = gsn_csm_contour(wks,ws_new_B,opts)
 dum1a = gsn_add_polymarker(wks,cplot1,dist_lidar_B,y_B,polyres)
 dum1b = gsn_add_text(wks,cplot1,"b) Leg B", x_txt,y_txt,txres)
 plot(1) = cplot1

; Flight leg C
 cplot1 = gsn_csm_contour(wks,ws_new_C,opts)
 dum2a = gsn_add_polymarker(wks,cplot1,dist_lidar_C(:),y_C,polyres)
 dum2b = gsn_add_text(wks,cplot1,"c) Leg C", x_txt,y_txt,txres)
 plot(2) = cplot1

; Flight leg D
 cplot1 = gsn_csm_contour(wks,ws_new_D,opts)
 dum3a = gsn_add_polymarker(wks,cplot1,dist_lidar_D(:),y_D,polyres)
 dum3b = gsn_add_text(wks,cplot1,"d) Leg D", x_txt,y_txt,txres)
 plot(3) = cplot1

;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel 

  delete(wks)
  print("converting to png")
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")


;;;;;;;;;;;;;;;;;;;;;; END script
end

