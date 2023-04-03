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

;;;;;;;;;;;;;
; Add flight leg info
;;;;;;;;;;;;;

 ; Pass A information
 inds = ind(prof_num.ge.237.0 .and. prof_num.le.244.0)
 lat_A = lat(0,inds)
 lon_A = lon(0,inds)
 delete(inds)
  lat0a = 67.4502
  lon0a = -28.6954
  lat0b = 68.1047
  lon0b = -28.8993

 ; Pass B information
 inds = ind(prof_num.ge.257.0 .and. prof_num.le.277.0)
 lat_B = lat(0,inds)
 lon_B = lon(0,inds)
 delete(inds)
  lat1a = 68.1646
  lon1a = -28.4707
  lat1b = 67.3155
  lon1b = -26.8666

 ; Pass C information
 inds = ind(prof_num.ge.294.0 .and. prof_num.le.309.0)
; inds = ind(prof_num.ge.285.0 .and. prof_num.le.309.0)
 lat_C = lat(0,inds)
 lon_C = lon(0,inds)
 delete(inds)
  lat2a = 67.3767
  lon2a = -26.5592
  lat2b = 68.3504
  lon2b = -27.3979

 ; Pass D information
 inds = ind(prof_num.ge.314.0 .and. prof_num.le.324.0)
; inds = ind(prof_num.ge.314.0 .and. prof_num.le.341.0)
 lat_D = lat(0,inds)
 lon_D = lon(0,inds)
 delete(inds)
  lat3a = 68.4070
  lon3a = -27.1266
  lat3b = 67.5633
  lon3b = -25.4517

 ; Pass E information
 inds = ind(prof_num.ge.364.0 .and. prof_num.le.372.0)
; inds = ind(prof_num.ge.347.0 .and. prof_num.le.372.0)
 lat_E = lat(0,inds)
 lon_E = lon(0,inds)
 delete(inds)
  lat4a = 67.5965
  lon4a = -25.1573
  lat4b = 68.5318
  lon4b = -25.9628

 ; Pass F information
 inds = ind(prof_num.ge.378.0 .and. prof_num.le.389.0)
; inds = ind(prof_num.ge.378.0 .and. prof_num.le.405.0)
 lat_F = lat(0,inds)
 lon_F = lon(0,inds)
 delete(inds)
  lat5a = 68.5978
  lon5a = -25.6756
  lat5b = 67.6089
  lon5b = -23.6995

;;;;;;;;;;
; Plotting
;;;;;;;;;;
; set outdir and fout names
  outdir = "./"
  fout   = outdir+"polar_winds_lidar_legs-subset"

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
  lnres@gsLineColor               = "black"

; set text res to show start and end of cross section
  txres                           = True
  txres@txFontHeightF             = 0.01 
  txres@txFontThicknessF          = 2.0

; polymarker res
  mkres1                           = True
  mkres1@gsMarkerColor             = "black"
  mkres1@gsMarkerIndex             = 3
  mkres1@gsMarkerSizeF             = 0.01
  mkres1@gsMarkerThicknessF        = 1.5

; second polymarker res
  mkres2                           = True
  mkres2@gsMarkerColor             = "black"
  mkres2@gsMarkerIndex             = 9
  mkres2@gsMarkerSizeF             = 0.01
  mkres2@gsMarkerThicknessF        = 1.5

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                = "LatLon"
  opts@mpMinLatF                  = 66.0  ;64.0
  opts@mpMaxLatF                  = 68.5  ;71.0
  opts@mpMinLonF                  = -30.0 ;-35.0
  opts@mpMaxLonF                  = -20.0 ;-15.0

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
  dum1 = gsn_add_text(wks, cplot0, "A", -28.76+0.25, 67.65+0.15, txres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_text(wks, cplot0, "B", -27.73, 67.78+0.15, txres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_text(wks, cplot0, "C", -26.867+0.25, 67.744, txres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_text(wks, cplot0, "D", -26.266, 67.986+0.15, txres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_text(wks, cplot0, "E", -25.498+0.25, 68.0, txres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_text(wks, cplot0, "F", -24.879+0.25, 68.216, txres)

; add cross section start/end points

;  dum7 = new(1,graphic)
;  dum7 = gsn_add_polymarker(wks, cplot0, lon0a, lat0a, mkres1)

;  dum8 = new(1,graphic)
;  dum8 = gsn_add_polymarker(wks, cplot0, lon0b, lat0b, mkres1)

;  dum9 = new(1,graphic)
;  dum9 = gsn_add_polymarker(wks, cplot0, lon1a, lat1a, mkres1)

;  dum10 = new(1,graphic)
;  dum10 = gsn_add_polymarker(wks, cplot0, lon1b, lat1b, mkres1)

;  dum11 = new(1,graphic)
;  dum11 = gsn_add_polymarker(wks, cplot0, lon2a, lat2a, mkres1)

;  dum12 = new(1,graphic)
;  dum12 = gsn_add_polymarker(wks, cplot0, lon2b, lat2b, mkres1)

;  dum13 = new(1,graphic)
;  dum13 = gsn_add_polymarker(wks, cplot0, lon3a, lat3a, mkres1)

;  dum14 = new(1,graphic)
;  dum14 = gsn_add_polymarker(wks, cplot0, lon3b, lat3b, mkres1)

;  dum15 = new(1,graphic)
;  dum15 = gsn_add_polymarker(wks, cplot0, lon4a, lat4a, mkres1)

;  dum16 = new(1,graphic)
;  dum16 = gsn_add_polymarker(wks, cplot0, lon4b, lat4b, mkres1)

;  dum17 = new(1,graphic)
;  dum17 = gsn_add_polymarker(wks, cplot0, lon5a, lat5a, mkres1)

;  dum18 = new(1,graphic)
;  dum18 = gsn_add_polymarker(wks, cplot0, lon5b, lat5b, mkres1)

;  dum19 = new(1,graphic)
;  dum19 = gsn_add_polymarker(wks,cplot0, lon_A, lat_A, mkres2)

;  dum20 = new(1,graphic)
;  dum20 = gsn_add_polymarker(wks,cplot0, lon_B, lat_B, mkres2)

  dum21 = new(1,graphic)
  dum21 = gsn_add_polymarker(wks,cplot0, lon_C, lat_C, mkres2)

  dum22 = new(1,graphic)
  dum22 = gsn_add_polymarker(wks,cplot0, lon_D, lat_D, mkres2)

  dum23 = new(1,graphic)
  dum23 = gsn_add_polymarker(wks,cplot0, lon_E, lat_E, mkres2)

  dum24 = new(1,graphic)
  dum24 = gsn_add_polymarker(wks,cplot0, lon_F, lat_F, mkres2)

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
