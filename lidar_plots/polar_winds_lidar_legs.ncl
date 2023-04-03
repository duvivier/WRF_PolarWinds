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
pass = "F"

;;;;;;;;;;;;;;;;;;;;;
; information about each pass. 
; Note that all passes "begin" on the landside. However, we aren't using these points to set the legs, instead use the lidar lat/lon data
if (pass .eq. "A")then
  ;st_lat = 68.1047
  ;st_lon = -28.8993
  ;ed_lat = 67.4502
  ;ed_lon = -28.6954
  n_s = 237.0
  n_e = 244.0
  npts = 20
end if
if (pass .eq. "B")then
  ;st_lat = 68.1646
  ;st_lon = -28.4707
  ;ed_lat = 67.3155
  ;ed_lon = -26.8666
  n_s = 257.0
  n_e = 277.0
  npts = 58
end if
if (pass .eq. "C")then
  ;st_lat = 68.3504
  ;st_lon = -27.3979
  ;ed_lat = 67.3767
  ;ed_lon = -26.5592
  n_s = 294.0
  n_e = 309.0
  npts = 35
end if
if (pass .eq. "D")then
  ;st_lat = 68.4070
  ;st_lon = -27.1266
  ;ed_lat = 67.5633
  ;ed_lon = -25.4517
  n_s = 314.0
  n_e = 324.0
  npts = 25
end if
if (pass .eq. "E")then
  ;st_lat = 68.5318
  ;st_lon = -25.9628
  ;ed_lat = 67.5965
  ;ed_lon = -25.1573
  n_s = 364.0
  n_e = 372.0
  npts = 19
end if
if (pass .eq. "F")then
  ;st_lat = 68.5978
  ;st_lon = -25.6756
  ;ed_lat = 67.6089
  ;ed_lon = -23.6995
  n_s = 378.0
  n_e = 389.0
  npts = 27
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Load lidar data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Loading data for flight leg "+pass)
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

; load only files for this particular leg
inds = ind(prof_num.ge.n_s .and. prof_num.le.n_e)

files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
nvert = 60
delim = ","
hgt = new((/nvert,ndates_sub/),"float")
wd = new((/nvert,ndates_sub/),"float")
ws = new((/nvert,ndates_sub/),"float")
u  = new((/nvert,ndates_sub/),"float")
v  = new((/nvert,ndates_sub/),"float")
lat = new((/nvert,ndates_sub/),"float")
lon = new((/nvert,ndates_sub/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt(0:dimz-1,n) = tofloat(str_get_field(f1,1,delim))
   wd(0:dimz-1,n) = tofloat(str_get_field(f1,2,delim))
   ws(0:dimz-1,n) = tofloat(str_get_field(f1,3,delim))
   u(0:dimz-1,n) = tofloat(str_get_field(f1,4,delim))
   v(0:dimz-1,n) = tofloat(str_get_field(f1,5,delim))
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; reverse the start points for legs A, C, or E so that the side near land is the start of the cross section
if (pass.eq."A" .or. pass.eq."C" .or. pass.eq."E")then
   hgt = hgt(:,::-1)
   wd  = wd(:,::-1)
   ws  = ws(:,::-1)
   u   = u(:,::-1)
   v   = v(:,::-1)
   lat = lat(:,::-1)
   lon = lon(:,::-1)
end if

; get start and end points for legs. If it's leg A,C,or E then flip the arrays so landside is the start
  st_lat = lat(0,0)
  st_lon = lon(0,0)
  ed_lat = lat(0,ndates_sub-1)
  ed_lon = lon(0,ndates_sub-1)

; flip these around so that the lowest heights are at the bottom of the arrays (missing data is nearer surface)
  hgt = hgt(::-1,:)
  wd  = wd(::-1,:)
  ws  = ws(::-1,:)
  u   = u(::-1,:)
  v   = v(::-1,:)

; get distances of each lidar profile along this cross section
  dist_lidar = new((/ndates_sub/),"float")
  n = 0
  do n = 0, ndates_sub -1
     dist_lidar(n) = gc_latlon(st_lat, st_lon,lat(0,n),lon(0,n),2,4)
  end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Create regular grid to interpolate to
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
  hgt_grid = ispan(0,n_lev,10)
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
  ws_new = linint2_Wrap(dist_lidar,hgt_grid,ws_new_1,False,dist_grid,hgt_grid,0)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting cross section for leg "+pass)
; set outdir and fout names
   outdir = "./"
   fout   = outdir+"lidar_sfc_windspeed_leg_"+pass

;;;;;;;;;;
; Set contour information for totalwind
;;;;;;;;;;
    units = "m s-1"
    cmin1 = 0
    cmax1 = 30.
    clev1 = 2.
    stride1             = 2                  ; label stride
    spreadstart1        = 2                  ; start at color- cross section
    spreadend1          = 21                 ; end at color
    colormap            = "winds.alice"

;;;;;;;;;;;;;
; Cross Section Plot Resources
;;;;;;;;;;;;;

 opts                              = True              ; plot mods desired
  opts@gsnRightString              = ""
  opts@gsnLeftString               = ""
  opts@gsnFrame                    = False             ; Do not draw plot 
  opts@gsnDraw                     = False             ; Do not advance frame
  ;opts@gsnXAxisIrregular2Linear    = True
  ;opts@gsnYAxisIrregular2Linear    = True

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
  opts@cnLineLabelsOn              = False             ; line labels on specified above
  opts@cnMissingValFillColor       = "gray85"          ; missing value color
  opts@cnMissingValFillPattern     = 0                 ; fill in 
  
  opts@tiXAxisString               = "Distance (km)"
  opts@tiXAxisOffsetYF             = 0.13
  opts@tiYAxisString               = "Height (m)"
  opts@tiXAxisFontHeightF          = 0.015             ; set font size for x axis
  opts@tmXBLabelFontHeightF        = 0.015             ; set tick mark label size for x axis
  opts@tiYAxisFontHeightF          = 0.015             ; set font size for y axis
  opts@tmYLLabelFontHeightF        = 0.015             ; set tick mark label size for y axis
  opts@trYMaxF                     = 1500.0

  opts@lbLabelStride               = stride1
  opts@pmLabelBarOrthogonalPosF    = 0.05              ; move label bar closer
  opts@pmLabelBarHeightF           = 0.075             ; set height of labelbar
  opts@lbTitleString               = units
  opts@lbTitlePosition             = "Right"
  opts@lbTitleDirection            = "Across"
  opts@lbTitleFontHeightF          = 0.01

  opts@tmXBMode                    = "Automatic"      ; specify the tick label spacing myself
  opts@tmXBMinorOn                 = True              
  opts@tmXBMinorPerMajor           = 5

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

 plot = new(1, graphic)    ; one cross section plot and one spatial plot

 cplot1 = gsn_csm_contour(wks,ws_new,opts)

 ; add polymarkers where the lidar obs are located
 dum0 = gsn_add_polymarker(wks,cplot1,dist_lidar(0),20.0,polyres)
 dum1 = gsn_add_polymarker(wks,cplot1,dist_lidar(1),20.0,polyres)
 dum2 = gsn_add_polymarker(wks,cplot1,dist_lidar(2),20.0,polyres)
 dum3 = gsn_add_polymarker(wks,cplot1,dist_lidar(3),20.0,polyres)
 dum4 = gsn_add_polymarker(wks,cplot1,dist_lidar(4),20.0,polyres)
 dum5 = gsn_add_polymarker(wks,cplot1,dist_lidar(5),20.0,polyres)
 if(ndates_sub .ge. 7)then
 dum6 = gsn_add_polymarker(wks,cplot1,dist_lidar(6),20.0,polyres)
 end if
 if(ndates_sub .ge. 8)then
   dum7 = gsn_add_polymarker(wks,cplot1,dist_lidar(7),20.0,polyres)
 end if
 if(ndates_sub .ge. 9)then
   dum8 = gsn_add_polymarker(wks,cplot1,dist_lidar(8),20.0,polyres)
 end if
 if(ndates_sub .ge. 10)then
   dum9 = gsn_add_polymarker(wks,cplot1,dist_lidar(9),20.0,polyres)
 end if
 if(ndates_sub .ge. 11)then
   dum10 = gsn_add_polymarker(wks,cplot1,dist_lidar(10),20.0,polyres)
 end if
 if(ndates_sub .ge. 12)then
   dum11 = gsn_add_polymarker(wks,cplot1,dist_lidar(11),20.0,polyres)
 end if
 if(ndates_sub .ge. 13)then
   dum12 = gsn_add_polymarker(wks,cplot1,dist_lidar(12),20.0,polyres)
   dum13 = gsn_add_polymarker(wks,cplot1,dist_lidar(13),20.0,polyres)
   dum14 = gsn_add_polymarker(wks,cplot1,dist_lidar(14),20.0,polyres)
   dum15 = gsn_add_polymarker(wks,cplot1,dist_lidar(15),20.0,polyres)
   dum16 = gsn_add_polymarker(wks,cplot1,dist_lidar(16),20.0,polyres)
 end if

 plot(0) = cplot1
;;;;;;;;;;;;;
; Final Plots
;;;;;;;;;;;;;

  title4 = "Wind Speed Lidar flight leg "+pass+" (St:"+st_lat+","+st_lon+"; Ed:"+ed_lat+","+ed_lon+")"

  pnlres                            = True
  pnlres@txString                   = title4           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel 

  delete(wks)
  print("converting to png")
;  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
;         "-trim -border 10 "+fout+".ps "+fout+".png")


  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")


;;;;;;;;;;;;;;;;;;;;;; END script
end

