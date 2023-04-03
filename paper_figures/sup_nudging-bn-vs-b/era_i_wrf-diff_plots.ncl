;***************************************
; PROGRAM DESCRIPTION: This script plots single panel plots of 
;                      diagnostic variables
; INPUT DATA: WRF output or RACM-WRF output post processed with wrfout-to-cf.ncl
;             and then made into yearly seasonal mean files
; OUTPUT DATA: One Panel plot of specified variable
; Note: This can be looped with 01_wrfsinglepanel_akd_seasonal.csh 
;       to evaluate at multiple hours or variables
; CREATOR: Matt Higgins
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS
date = "21_18"
tagb = "PW-05-40-M-bn"
tagc = "PW-05-40-M-b"
varcode = "Z500"            ; "SLP" "Z500"

; BEGIN SCRIPT
print("Plotting "+varcode+" on May "+date+" 2015")

; get resolution from tag
dum = stringtochar(tagb)
res_km = chartostring(dum(3:4))
delete(dum)

 if (varcode.eq."SLP") then
    vartitle1 = "Sea Level Pressure"
    invar1 = "PMSL"
    invar2 = "slp"
    units = "hPa"
    cmin1               = 970. ;920.
    cmax1               = 1020. ;1064.
    clev1               = 2.
    cmin2               = -10.
    cmax2               = 10.
    clev2               = 1.
    clevd               = clev1*2
    stride1             = 4                 ; label stride
    stride2             = 2                 ; label stride for diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = False              ; lines for diff plot
    cntype              = "AreaFill"
    spreadstart1        = 2                 ; start at color
    spreadend1          = 74                ; end at color
    spreadstart2        = 76                ; start at color
    spreadend2          = 129               ; end at color
    colormap            = "slp_anoms.dave"
 end if
  if (varcode.eq."Z500") then
    vartitle1 = "Z at 500 mb"
    invar1 = "GHT"
    invar2 = "Z_p"
    units = "m"
    cmin1               = 5000. ;4500.
    cmax1               = 5500. ;6100.
    clev1               = 25.
    cmin2               = -100. ;-150.
    cmax2               = 100. ;150.
    clev2               = 5.
    clevd               = clev1*2
    stride1             = 8                 ; label stride
    stride2             = 2                 ; label stride diff plot
    plotlines           = True              ; lines for reg plot
    difflines           = True              ; lines for diff plot
    cntype              = "AreaFill"        ; type of contour fill
    spreadstart1        = 2                 ; start at color
    spreadend1          = 65                ; end at color
    spreadstart2        = 67                ; start at color
    spreadend2          = 118               ; end at color
    colormap            = "z500_anoms.dave"
  end if

; set directories based on WRF run type
outdir = "./"
dir = "/data/duvivier/polar_winds/DATA/"
dira = dir+"ERA_I/met_em/"+res_km+"km/"
fname0a = "met_em.d01.2015-05-"+date+":00:00.nc"

dirb = dir+tagb+"/wrfout-cf/"
fnameb = "wrf-2015-05-"+date+"-00."+tagb+"-cf.nc"

dirc = dir+tagc+"/wrfout-cf/"
fnamec = "wrf-2015-05-"+date+"-00."+tagc+"-cf.nc"

title_fin = "ERA_I and WRF ("+tagb+") "+varcode+" ("+units+") on 2015-05-"+date
fout = outdir+varcode+"-era_i-wrf-diff_"+date

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in ERA files
;;;;;;;;;;
; Load in first ERA file to compare
f0 = addfile(dira+fname0a,"r")
   ; latitude
   lat2d_a = f0->XLAT_M(0,:,:)
   ; longitude
   lon2d_a = f0->XLONG_M(0,:,:)
   ; terrain
   hgt_a = f0->HGT_M(0,:,:)
   ; get variable
   if (varcode.eq."SLP")then
     var0 = f0->$invar1$(0,:,:)/100.0
   end if
   if (varcode.eq."Z500")then
     var0 = f0->$invar1$(0,16,:,:)
   end if
   delete([/f0/])

;;;;;;;;;;
; load in WRF files
;;;;;;;;;;
; Load in first ERA file to compare
f1 = addfile(dirb+fnameb,"r")
f2 = addfile(dirc+fnamec,"r")
   ; latitude
   lat2d_b = f1->lat
   ; longitude
   lon2d_b = f1->lon
   ; terrain
   hgt_b = f1->Z_sfc
   ; get variable
   if (varcode.eq."SLP")then
     var1 = f1->$invar2$(0,:,:)
     var2 = f2->$invar2$(0,:,:)
   end if
   if (varcode.eq."Z500")then
     var1 = f1->$invar2$(0,2,:,:)
     var2 = f2->$invar2$(0,2,:,:)
   end if
   delete([/f1,f2/])

; calculate difference field
  diff_1 = var1 - var0
  diff_2 = var2 - var0

; assign lat/lon (should be the same for both files!!)
  var0@lat2d = lat2d_a
  var0@lon2d = lon2d_a
  var0@_FillValue = -999.99
  copy_VarMeta(var0, var1)
  copy_VarMeta(var0, var2)
  diff_1@lat2d = lat2d_a
  diff_1@lon2d = lon2d_a
  diff_1@_FillValue = -999.99
  copy_VarMeta(diff_1, diff_2)

; mask based on height (>100m)
  if (varcode.eq."SLP" .or. varcode.eq."WS")then
    var0 = where(hgt_a.lt.100.0, var0, var0@_FillValue)
    var1 = where(hgt_a.lt.100.0, var1, var1@_FillValue)
    var2 = where(hgt_a.lt.100.0, var2, var2@_FillValue)
    diff_1 = where(hgt_a.lt.100.0, diff_1, diff_1@_FillValue)
    diff_2 = where(hgt_a.lt.100.0, diff_2, diff_2@_FillValue)
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Making plots")
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnRightString              = ""
  res@gsnLeftString               = ""
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance fr
  res@gsnAddCyclic                = False             ; regional - not cyclic 
  res@mpProjection                = "Stereographic"   ; map projection
  res@mpCenterLonF                = -25.              ; set the center lat/lon  ---set by akd for Greenland
  res@mpCenterLatF                = 65.               ; -----set by akd for Greenland
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner
  res@mpLimitMode                 = "LatLon"
  res@mpMinLatF                   = 59.0  ;64.0
  res@mpMaxLatF                   = 75.0  ;71.0
  res@mpMinLonF                   = -50.0 ;-35.0
  res@mpMaxLonF                   = -15.0 ;-15.0
  res@tiMainFontHeightF           = 0.025
  res@tiMainFontThicknessF        = 1.5
  res@lbLabelBarOn                = True             ; turn off individual label bars

  ; contour resources
  res1                           = res
  res1@cnFillMode                 = cntype
  res1@cnFillOn                   = True              ; turn on filled contours
  res1@gsnSpreadColors            = True              ; use full colormap
  res1@gsnSpreadColorStart        = spreadstart1      ; start at color specified for each variable above
  res1@gsnSpreadColorEnd          = spreadend1        ; end at color specified above
  res1@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res1@cnMinLevelValF             = cmin1             ; set min contour level specified above
  res1@cnMaxLevelValF             = cmax1             ; set max contour level specified above
  res1@cnLevelSpacingF            = clev1             ; set contour spacing specified above
  res1@cnLinesOn                  = plotlines         ; contour lines specified above
  res1@cnLineLabelsOn             = plotlines         ; line labels on specified above
  res1@cnMissingValFillColor      = "gray85"          ; missing value color
  res1@cnMissingValFillPattern    = 0                 ; fill in

  ; difference resources
  res2                           = res
  res2@cnFillMode                 = cntype
  res2@cnFillOn                   = True              ; turn on filled contours
  res2@gsnSpreadColors            = True              ; use full colormap
  res2@gsnSpreadColorStart        = spreadstart2      ; start at color specified for each variable above
  res2@gsnSpreadColorEnd          = spreadend2        ; end at color specified above
  res2@cnLevelSelectionMode       = "ManualLevels"    ; set manual contour
  res2@cnMinLevelValF             = cmin2             ; set min contour level specified above
  res2@cnMaxLevelValF             = cmax2             ; set max contour level specified above
  res2@cnLevelSpacingF            = clev2             ; set contour spacing specified above
  res2@cnLinesOn                  = difflines         ; contour lines specified above
  res2@cnLineLabelsOn             = difflines         ; line labels on specified above
  res2@cnMissingValFillColor      = "gray85"          ; missing value color
  res2@cnMissingValFillPattern    = 0                 ; fill in

  ; overlay resources
  res3                          = res
  res3@cnLineColor               = "black"
  res3@cnLevelSelectionMode      = "ManualLevels"
  res3@cnMinLevelValF            = cmin1
  res3@cnMaxLevelValF            = cmax1
  res3@cnLevelSpacingF           = clevd
  res3@cnInfoLabelOn             = False
  res3@cnLineLabelFontColor      = res3@cnLineColor
  res3@cnLineLabelBackgroundColor = "Transparent"

  res4                          = res3
  res4@cnLineColor              = "blue"
  res4@cnLineLabelFontColor     = res4@cnLineColor
  res4@gsnRightString           = ""

; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  ;pnlres@gsnPanelLabelBar           = True
  ;pnlres@lbTitleString              = "m s-1"
  ;pnlres@lbTitlePosition            = "Right"
  ;pnlres@lbTitleDirection           = "Across"
  ;pnlres@lbTitleJust                = "CenterLeft"
  ;pnlres@lbTitleFontHeightF         = 0.0075
  ;pnlres@lbLabelStride              = stride1
  ;pnlres@lbLabelFontHeightF         = 0.0095
  ;pnlres@pmLabelBarWidthF           = 0.65
  ;pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page

;;;;;;;;;
;; Actual plots!
;;;;;;;;;
print("Plotting "+varcode)
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(3, graphic)

; ERA I plot
  opts                             = res1
  opts@tiMainString                = "ERA on May "+date+"UTC"
  plot(0) = gsn_csm_contour_map(wks, var0, opts)
  delete(opts)

;;;; ROW 2: Difference
  opts                             = res2
  opts@tiMainString                = "W05-40 - ERA"
  plot(1) = gsn_csm_contour_map(wks, diff_1, opts)
  delete(opts)
  opts                             = res2
  opts@tiMainString                = "W05-nonudge - ERA"
  plot(2) = gsn_csm_contour_map(wks, diff_2, opts)
  delete(opts)

; Plot final panel plot 
;  pnlres@txString                   = title_fin
  gsn_panel(wks,(/plot/),(/1,3/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
