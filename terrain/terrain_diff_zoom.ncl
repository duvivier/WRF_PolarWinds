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
zoom = 0  ; 1 = yes, zoom to DS, 0 = no, whole domain
;;;;;;;;;;
; Load Data
;;;;;;;;;;
f0 = addfile("/data/duvivier/polar_winds/DATA/PW-05-40-M-bn/wrfout-cf/wrf-2015-05-22_00-00.PW-05-40-M-bn-cf.nc","r")

hgt0 = f0->Z_sfc
lat2d = f0->lat
lon2d = f0->lon

dims = dimsizes(lat2d)     ; get lat/lon dimensions from second domain
nlat = dims(0)              ; get south/north points
nlon = dims(1)              ; get west/east points

f1 = addfile("/data/duvivier/polar_winds/DATA/PW-10-40-M-bn/wrfto05km/wrfto05km.2015-05-22_00-00.PW-10-40-M-bn-cf.nc","r")
hgt1 = f1->Z_sfc

f2 = addfile("/data/duvivier/polar_winds/DATA/PW-25-40-M-bn/wrfto05km/wrfto05km.2015-05-22_00-00.PW-25-40-M-bn-cf.nc","r")
hgt2 = f2->Z_sfc

f3 = addfile("/data/duvivier/polar_winds/DATA/PW-50-40-M-bn/wrfto05km/wrfto05km.2015-05-22_00-00.PW-50-40-M-bn-cf.nc","r")
hgt3 = f3->Z_sfc

; get differences
diff1 = hgt0 - hgt1
diff2 = hgt0 - hgt2
diff3 = hgt0 - hgt3

; set zero difference to missing
diff1 = where((diff1.lt.1.0 .and. diff1.ge.0.0), diff1@_FillValue, diff1)
diff1 = where((diff1.gt.-1.0 .and. diff1.le.0.0), diff1@_FillValue, diff1)
diff2 = where((diff2.lt.1.0 .and. diff2.ge.0.0), diff2@_FillValue, diff2)
diff2 = where((diff2.gt.-1.0 .and. diff2.le.0.0), diff2@_FillValue, diff2)
diff3 = where((diff3.lt.1.0 .and. diff3.ge.0.0), diff3@_FillValue, diff3)
diff3 = where((diff3.gt.-1.0 .and. diff3.le.0.0), diff3@_FillValue, diff3)

; assign lat/lon
hgt0@lat2d = lat2d
hgt0@lon2d = lon2d
copy_VarMeta(hgt0, hgt1)
copy_VarMeta(hgt0, hgt2)
copy_VarMeta(hgt0, hgt3)
copy_VarMeta(hgt0, diff1)
copy_VarMeta(hgt0, diff2)
copy_VarMeta(hgt0, diff3)

; set outdir and fout names
outdir = "./"
if (zoom .eq. 0)then
  fout   = outdir+"WRF_terrain_diffs"
end if
if (zoom .eq. 1) then
  fout   = outdir+"WRF_terrain_diffs_zoom"
end if

;;;;;;;;;;
; Plotting
;;;;;;;;;;
  wks = gsn_open_wks("ps" ,fout)
  print ("Plotting terrain differences")

  additional_colors = (/"gray85","yellow", "purple", "red"/)
  gsn_merge_colormaps(wks,"terrain.alice",additional_colors)

  plot = new(4, graphic)

; Set the contour interval for terrain only plot
    cmin1               = 0.
    cmax1               = 3500.
    clev1               = 50.
    stride1             = 10                 ; label stride for terrain plot
    spreadstart1        = 1                  ; start at color
    spreadend1          = 100                ; end at color
    cmin2               = -500.
    cmax2               = 500.
    clev2               = 50.
    stride2             = 2                 ; label stride for terrain plot
    spreadstart2        = 102                  ; start at color
    spreadend2          = 124                ; end at color
   
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -35. ;-30.              ; set the center lat/lon  ---changed by akd for Greenland
  res@mpCenterLatF                = 70.               ; -----changed by akd for Greenland
 
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner

  res@cnLinesOn                   = False             ; no contour lines
  res@cnLineLabelsOn              = False             ; don't want labels
  res@cnFillMode                  = "AreaFill"
  res@lbLabelFontHeightF          = 0.015              ; label bar font size
  res@tiMainFontHeightF           = 0.014
  res@tiMainFontThicknessF        = 1.5

if (zoom .eq. 0) then
  ; whole domain
  res@mpLimitMode                 = "Corners"
  res@mpLeftCornerLatF            = lat2d(0,0)        ; set the lat/lon sides
  res@mpLeftCornerLonF            = lon2d(0,0)
  res@mpRightCornerLatF           = lat2d(nlat-1,nlon-1)
  res@mpRightCornerLonF           = lon2d(nlat-1,nlon-1)
end if
if (zoom .eq. 1) then
  ; zoom
  res@mpLimitMode                = "LatLon"
  res@mpMinLatF                  = 64.0
  res@mpMaxLatF                  = 71.0
  res@mpMinLonF                  = -35.0
  res@mpMaxLonF                  = -15.0
end if

; terrain plot
  opts1                            = res               ; reset options
  opts1@cnFillOn                   = True              ; turn on filled contours
  opts1@gsnSpreadColors            = True              ; use full colormap
  opts1@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  opts1@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  opts1@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts1@cnMinLevelValF             = cmin1             ; set min contour level specified above
  opts1@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  opts1@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  opts1@cnMissingValFillColor      = "gray85"          ; missing value color
  opts1@cnMissingValFillPattern    = 0                 ; fill in
  opts1@lbLabelBarOn               = True
  opts1@lbLabelStride              = stride1
  ;opts1@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  ;opts1@pmLabelBarHeightF          = 0.075             ; set height of labelbar
      
; terrain difference plot
  opts2                            = res               ; reset options
  opts2@cnFillOn                   = True              ; turn on filled contours
  opts2@gsnSpreadColors            = True              ; use full colormap
  opts2@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  opts2@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  opts2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  opts2@cnMinLevelValF             = cmin2             ; set min contour level specified above
  opts2@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  opts2@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  opts2@cnMissingValFillColor      = "gray85"          ; missing value color
  opts2@cnMissingValFillPattern    = 0                 ; fill in
  opts2@lbLabelBarOn               = True
  opts2@lbLabelStride              = stride2
  ;opts2@pmLabelBarOrthogonalPosF   = -0.01             ; move label bar closer
  ;opts2@pmLabelBarHeightF          = 0.075             ; set height of labelbar

;;;;;;;;;;;;;
; Plot 0 - terrain
;;;;;;;;;;;;;
  opts1@tiMainString               = "5km Terrain Height (m)"  ; title string 
  cplot0 = gsn_csm_contour_map(wks, hgt0, opts1)      ; create second plot
  plot(0) = cplot0                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 1 - terrain difference
;;;;;;;;;;;;;
  opts2@tiMainString               = "5km - 10km"  ; title string 
  cplot1 = gsn_csm_contour_map(wks, diff1, opts2)      ; create second plot
  plot(1) = cplot1                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 2 - terrain difference
;;;;;;;;;;;;;
  opts2@tiMainString               = "5km - 25km"  ; title string 
  cplot2 = gsn_csm_contour_map(wks, diff2, opts2)      ; create second plot
  plot(2) = cplot2                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot 3 - terrain difference
;;;;;;;;;;;;;
  opts2@tiMainString               = "5km - 50km"  ; title string 
  cplot3 = gsn_csm_contour_map(wks, diff3, opts2)      ; create second plot
  plot(3) = cplot3                              ; make panel section of this plot

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
  pnlres                            = True
  ;pnlres@txString                   = title5           ; set title for whole panel plot. specified above     
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 1                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 1                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnMaximize                = True	       ; fill the page
  gsn_panel(wks,(/plot/),(/2,2/),pnlres)               ; create final panel plot
  
print("converting plot to png")
delete(wks)
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
