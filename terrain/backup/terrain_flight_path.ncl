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

;;;;;;;;;;;;;
; Load flight path lat/lon
;;;;;;;;;;;;;
data = asciiread("/data/duvivier/polar_winds/DATA/aircraft_track.txt", (/474,2/), "float")
lats_flt = data(:,0)
lons_flt = data(:,1)

;;;;;;;;;;;;;
; Add dropsonde info
;;;;;;;;;;;;;
  name0 = "190950"
  lat0 = 67.662432
  lon0 = -31.29614
  name1 = "192456"
  lat1 = 68.646938
  lon1 = -32.501456
  name2 = "194625"
  lat2 = 67.516306
  lon2 = -28.718051
  name3 = "201031"
  lat3 = 67.367052
  lon3 = -26.550869
  name4 = "203004"
  lat4 = 68.175776
  lon4 = -26.645214
  name5 = "204411"
  lat5 = 67.667818
  lon5 = -25.218717
  name6= "205909"
  lat6 = 68.606772
  lon6 = -25.695999
  name7 = "211845"
  lat7 = 67.168047
  lon7 = -23.482644

;;;;;;;;;;
; Plotting
;;;;;;;;;;
; set outdir and fout names
  outdir = "./"
  fout   = outdir+"polar_winds_flight_denmark_strait"

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
  mkres                           = True
  mkres@gsMarkerColor             = "black"
  mkres@gsMarkerIndex             = 4
  mkres@gsMarkerSizeF             = 0.01
  mkres@gsMarkerThicknessF        = 1.5

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts                            = res               ; reset options
  opts@mpLimitMode                = "LatLon"
  opts@mpMinLatF                  = 64.0
  opts@mpMaxLatF                  = 71.0
  opts@mpMinLonF                  = -35.0
  opts@mpMaxLonF                  = -15.0

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
  dum1 = gsn_add_polymarker(wks, cplot0, lon0, lat0, mkres)

  dum2 = new(1,graphic)
  dum2 = gsn_add_polymarker(wks, cplot0, lon1, lat1, mkres)

  dum3 = new(1,graphic)
  dum3 = gsn_add_polymarker(wks, cplot0, lon2, lat2, mkres)

  dum4 = new(1,graphic)
  dum4 = gsn_add_polymarker(wks, cplot0, lon3, lat3, mkres)

  dum5 = new(1,graphic)
  dum5 = gsn_add_polymarker(wks, cplot0, lon4, lat4, mkres)

  dum6 = new(1,graphic)
  dum6 = gsn_add_polymarker(wks, cplot0, lon5, lat5, mkres)

  dum7 = new(1,graphic)
  dum7 = gsn_add_polymarker(wks, cplot0, lon6, lat6, mkres)

  dum8 = new(1,graphic)
  dum8 = gsn_add_polymarker(wks, cplot0, lon7, lat7, mkres)

  dum9 = new(1,graphic)
  dum9 = gsn_add_text(wks, cplot0, "1", lon0+0.35, lat0, txres)

  dum10 = new(1,graphic)
  dum10 = gsn_add_text(wks, cplot0, "2", lon1+0.2, lat1+0.2, txres)

  dum11 = new(1,graphic)
  dum11 = gsn_add_text(wks, cplot0, "3", lon2+0.35, lat2, txres)

  dum12 = new(1,graphic)
  dum12 = gsn_add_text(wks, cplot0, "4", lon3+0.35, lat3, txres)

  dum13 = new(1,graphic)
  dum13 = gsn_add_text(wks, cplot0, "5", lon4, lat4+0.35, txres)

  dum14 = new(1,graphic)
  dum14 = gsn_add_text(wks, cplot0, "6", lon5+0.35, lat5, txres)

  dum15 = new(1,graphic)
  dum15 = gsn_add_text(wks, cplot0, "7", lon6+0.35, lat6, txres)

  dum16 = new(1,graphic)
  dum16 = gsn_add_text(wks, cplot0, "8", lon7+0.35, lat7, txres)

  dum17 = new(1,graphic)
  dum17 = gsn_add_text(wks, cplot0, "A", -28.76+0.15, 67.65+0.15, txres)

  dum18 = new(1,graphic)
  dum18 = gsn_add_text(wks, cplot0, "B", -27.73, 67.78+0.15, txres)

  dum19 = new(1,graphic)
  dum19 = gsn_add_text(wks, cplot0, "C", -26.867+0.15, 67.744, txres)

  dum20 = new(1,graphic)
  dum20 = gsn_add_text(wks, cplot0, "D", -26.266, 67.986+0.15, txres)

  dum21 = new(1,graphic)
  dum21 = gsn_add_text(wks, cplot0, "E", -25.498+0.15, 68.0, txres)

  dum22 = new(1,graphic)
  dum22 = gsn_add_text(wks, cplot0, "F", -24.879+0.15, 68.216, txres)

  dum23 = new(1,graphic)
  dum23 = gsn_add_text(wks, cplot0, "Iceland", -17.5, 65.0, txres)

  dum24 = new(1,graphic)
  dum24 = gsn_add_text(wks, cplot0, "Keflavik", lons_flt(0), lats_flt(0)-0.15, txres)

  dum25 = new(1,graphic)
  dum25 = gsn_add_text(wks, cplot0, "Greenland", -33.0, 71.0, txres)

  dum26 = new(1,graphic)
  dum26 = gsn_add_text(wks, cplot0, "1 = "+name0, -17.0, 70.0, txres)

  dum27 = new(1,graphic)
  dum27 = gsn_add_text(wks, cplot0, "2 = "+name1, -17.0, 69.75, txres)

  dum28 = new(1,graphic)
  dum28 = gsn_add_text(wks, cplot0, "3 = "+name2, -17.0, 69.5, txres)

  dum29 = new(1,graphic)
  dum29 = gsn_add_text(wks, cplot0, "4 = "+name3, -17.0, 69.25, txres)

  dum30 = new(1,graphic)
  dum30 = gsn_add_text(wks, cplot0, "5 = "+name4, -17.0, 69.0, txres)

  dum31 = new(1,graphic)
  dum31 = gsn_add_text(wks, cplot0, "6 = "+name5, -17.0, 68.75, txres)

  dum32 = new(1,graphic)
  dum32 = gsn_add_text(wks, cplot0, "7 = "+name6, -17.0, 68.5, txres)

  dum33 = new(1,graphic)
  dum33 = gsn_add_text(wks, cplot0, "8 = "+name7, -17.0, 68.25, txres)

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
