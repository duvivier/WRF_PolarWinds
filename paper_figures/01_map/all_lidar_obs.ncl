;***************************************
; PROGRAM DESCRIPTION: This NCL script regrids curvilinear WRf output
;                      from any domain to a 10km WRF domain using 
;                      a Cressman Weighting scheme
; INPUT DATA: WRF geo_em.d01.nc files for 10km grid spacing and 100km spacing
; OUTPUT DATA: plot of the terrain at 10km and labels for locations,
;              difference plot of wrf100 and wrf10 terrain height along southeast coast.
; CREATOR: Alice DuVivier - March 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************

begin
; MANUAL INPUTS
;;;;;;;;;;
; Load Data
;;;;;;;;;;
f1 = addfile("/data/duvivier/polar_winds/DATA/geo_em/geo_em.d01.05km.nc","r")

hgt = f1->HGT_M(0,:,:)
lat2d = f1->XLAT_M(0,:,:)
lon2d = f1->XLONG_M(0,:,:)

dims = dimsizes(lat2d)     ; get lat/lon dimensions from second domain
n_sn = dims(0)              ; get south/north points
n_we = dims(1)              ; get west/east points
n_tot = n_sn*n_we               ; get total number of points in high res domain

hgt@lat2d = lat2d
hgt@lon2d = lon2d
delete(f1)

;;;;;;;;;;;;;
; Load flight path lat/lon
;;;;;;;;;;;;;
data = asciiread("/data/duvivier/polar_winds/DATA/aircraft_track.txt", (/474,2/), "float")
lats_flt = data(:,0)
lons_flt = data(:,1)

;;;;;;;;;;;;;
; Add dropsonde info
;;;;;;;;;;;;;
  name1 = "194625"
  lat1 = 67.516306
  lon1 = -28.718051
  name2 = "201031"
  lat2 = 67.367052
  lon2 = -26.550869
  name3 = "203004"
  lat3 = 68.175776
  lon3 = -26.645214
  name4 = "204411"
  lat4 = 67.667818
  lon4 = -25.218717
  name5 = "205909"
  lat5 = 68.606772
  lon5 = -25.695999
  name6 = "211845"
  lat6 = 67.168047
  lon6 = -23.482644

;;;;;;;;;;;;;
; Load lidar location lat/lon
;;;;;;;;;;;;;
print("Loading data for flight legs ")
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

nvert = 60
delim = ","
lat = new((/nvert,ndates/),"float")
lon = new((/nvert,ndates/),"float")
n = 0
do n = 0, ndates -1
   f1 = asciiread(files(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   lat(0:dimz-1,n) = tofloat(str_get_field(f1,10,delim))
   lon(0:dimz-1,n) = tofloat(str_get_field(f1,11,delim))
   delete([/f1,tmp,dimz/])
end do

; get index of lidar closest to dropsondes
length = gc_latlon(lat1,lon1,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 1")
delete([/length,loc/])

length = gc_latlon(lat2,lon2,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 2")
delete([/length,loc/])

length = gc_latlon(lat3,lon3,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 3")
print("second closest to point 3: "+length(loc-1)+" km")
delete([/length,loc/])

length = gc_latlon(lat4,lon4,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 4")
delete([/length,loc/])

length = gc_latlon(lat5,lon5,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 5")
delete([/length,loc/])

length = gc_latlon(lat6,lon6,lat(0,:),lon(0,:),2,4)
loc = ind(length .eq. min(length))
print("lidar profile num: "+prof_num(loc)+" is "+min(length)+" km away from dropsonde 6")
delete([/length,loc/])

;return

;;;;;;;;;;;;;
; Add flight leg info
;;;;;;;;;;;;;
 ; Pass A information
 inds = ind(prof_num.ge.294.0 .and. prof_num.le.309.0)
 lat_A = lat(0,:)
 lon_A = lon(0,:)
 delete(inds)

;;;;;;;;;;
; Plotting
;;;;;;;;;;
; set outdir and fout names
  outdir = "./"
  fout   = outdir+"all_lidar"

  wks = gsn_open_wks("ps" ,fout)
  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)
  plot = new(1, graphic)

; Set the contour interval for terrain only plot
  cmin1               = 0.
  cmax1               = 3500.
  clev1               = 50.
  stride1             = 10                 ; label stride for terrain plot
  spreadstart1        = 1                  ; start at color
  spreadend1          = 100                ; end at color
   
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -40. ;-30.              ; set the center lat/lon  ---changed by akd for Greenland
  res@mpCenterLatF                = 60.               ; -----changed by akd for Greenland
 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = False              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "AreaFill"
  res@lbLabelFontHeightF          = 0.015              ; label bar font size

; set line res to show box
  lnres                            = True
  lnres@gsLineThicknessF          = 2.5
  lnres@gsLineColor               = "grey"

; set text res to show start and end of cross section
  txres                           = True
  txres@txFontHeightF             = 0.01 
  txres@txFontThicknessF          = 2.0

; polymarker res
  mkres                           = True
  mkres@gsMarkerColor             = "firebrick" ;"black"
  mkres@gsMarkerIndex             = 16 ;4
  mkres@gsMarkerSizeF             = 0.01
  mkres@gsMarkerThicknessF        = 1.5

; polymarker res
  mkres2                           = True
  mkres2@gsMarkerColor             = "black"
  mkres2@gsMarkerIndex             = 1 ;3
  mkres2@gsMarkerSizeF             = 0.01
  mkres2@gsMarkerThicknessF        = 1.5

; second polymarker res
  mkres3                           = True
  mkres3@gsMarkerColor             = "black"
  mkres3@gsMarkerIndex             = 9
  mkres3@gsMarkerSizeF             = 0.01
  mkres3@gsMarkerThicknessF        = 1.5

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                = "LatLon"
  opts@mpMinLatF                  = 67.35
  opts@mpMaxLatF                  = 69.0 
  opts@mpMinLonF                  = -31.0
  opts@mpMaxLonF                  = -22.0

  opts@cnFillOn                   = True              ; turn on filled contours
  opts@gsnSpreadColors            = True              ; use full colormap
  opts@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts@cnMissingValFillColor      = "gray85"          ; missing value color
  opts@cnMissingValFillPattern    = 0                 ; fill in
  ;opts@tiMainString               = "Terrain Height (m) for 5km domain"
  ;opts@tiMainFontHeightF          = 0.014
  ;opts@tiMainFontThicknessF       = 1.5
  opts@lbLabelBarOn               = False
  ;opts@lbLabelStride              = stride1
  ;opts@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  ;opts@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
  cplot0 = gsn_csm_contour_map(wks, hgt, opts)      ; create second plot

  dum0 = new(1, graphic)      ; make dummy variable
  dum0 = gsn_add_polyline(wks,cplot0,lons_flt,lats_flt, lnres)

  dum1 = new(1,graphic)
  dum1 = gsn_add_polymarker(wks, cplot0, lon1, lat1, mkres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_polymarker(wks, cplot0, lon2, lat2, mkres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_polymarker(wks, cplot0, lon3, lat3, mkres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_polymarker(wks, cplot0, lon4, lat4, mkres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_polymarker(wks, cplot0, lon5, lat5, mkres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_polymarker(wks, cplot0, lon6, lat6, mkres)

  dum7 = new(1,graphic)
  dum7 = gsn_add_text(wks, cplot0, "1", lon1+0.15, lat1, txres)

  dum8 = new(1,graphic)
  dum8 = gsn_add_text(wks, cplot0, "2", lon2+0.15, lat2, txres)

  dum9 = new(1,graphic)
  dum9 = gsn_add_text(wks, cplot0, "3", lon3+0.15, lat3+0.02, txres)

  dum10 = new(1,graphic)
  dum10 = gsn_add_text(wks, cplot0, "4", lon4+0.15, lat4, txres)

  dum11 = new(1,graphic)
  dum11 = gsn_add_text(wks, cplot0, "5", lon5+0.15, lat5+0.02, txres)

  dum12 = new(1,graphic)
  dum12 = gsn_add_text(wks, cplot0, "6", lon6+0.15, lat6, txres)

  dum15 = new(1,graphic)
  dum15 = gsn_add_text(wks, cplot0, "A", -27.367, 68.1, txres)

  dum16 = new(1,graphic)
  dum16 = gsn_add_text(wks, cplot0, "B", -26.7, 68.3, txres)

  dum17 = new(1,graphic)
  dum17 = gsn_add_text(wks, cplot0, "C", -26.0, 68.4, txres)

  dum18 = new(1,graphic)
  dum18 = gsn_add_text(wks, cplot0, "D", -25.2, 68.5, txres)

  dum27 = new(1,graphic)
  dum27 = gsn_add_polymarker(wks,cplot0, lon_A, lat_A, mkres3)

  plot(0) = cplot0                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  ;pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 3                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/1,1/),pnlres)               ; create final panel plot
  
print("converting plot to png")
delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
