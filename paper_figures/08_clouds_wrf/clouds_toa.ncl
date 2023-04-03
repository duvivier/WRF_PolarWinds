;**************************************
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
; MANUAL INPUTS - for testing purposes
date = "2015-05-21_18-00"   ; "21_18-00", "21_20-00", "21_20-20", "21_22-00"
varcode = "SWUT"
tag0 = "PW-05-40-M-bn"
tag1 = "PW-10-40-M-bn"
tag2 = "PW-25-40-M-bn"
tag3 = "PW-50-40-M-bn"
tag4 = "PW-05-60-M-bn"
tag5 = "PW-05-40-U-bn"
tag6 = "PW-05-60-U-bn"

; BEGIN SCRIPT
; set directory
  dir = "/data/duvivier/polar_winds/DATA/"
; set outdir and fout names
outdir = "./"

; plot whole domain:
fout  = outdir+varcode+"_wrf_all-"+date

print("Running Four panel for " + date)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Set preferences for vartypes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  if (varcode.eq."SWUT") then
    vartitle1 = "Shortwave up at TOA"
    invar1 = "SWUPT"
    cmaptype = "swflux"
  end if
  if (varcode.eq."CLDF") then
    vartitle1 = "Cloud Fraction"
    invar1 = "CLDFRA"
    cmaptype = "frac"
  end if

; Set the contour interval for each input variable   
  if (cmaptype.eq."swflux")then
    if (date.eq."2015-05-21_18-00")then
       cmin1               = 0.0
       cmax1               = 500.0
       clev1               = 20.
    end if
    if (date.eq."2015-05-21_20-00" .or. date.eq."2015-05-21_20-20")then
       cmin1               = 0.0
       cmax1               = 300.0
       clev1               = 10.
    end if
    if (date.eq."2015-05-21_22-00")then
       cmin1               = 0.0
       cmax1               = 150.0
       clev1               = 5.
    end if
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 128                 ; start at color
    spreadend1          = 2                ; end at color
    colormap            = "MPL_Greys"
  end if
  if (cmaptype.eq."frac")then
    cmin1               = 0.0
    cmax1               = 1.0
    clev1               = 0.05
    stride1             = 2                 ; label stride
    plotlines           = False              ; lines for reg plot
    cntype              = "AreaFill"      ; type of contour fill
    spreadstart1        = 128                 ; start at color
    spreadend1          = 2                ; end at color
    colormap            = "MPL_Greys"
  end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Data Processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;
; load in wrf files
;;;;;;;;;;
; Load in first file to compare
f0 = addfile(dir+tag0+"/wrfcloud/wrf-"+date+"."+tag0+"-clouds.nc","r")
lat2d_0 = f0->XLAT(0,:,:)
lon2d_0 = f0->XLONG(0,:,:)

; Load in second file to compare
f1 = addfile(dir+tag1+"/wrfcloud/wrf-"+date+"."+tag1+"-clouds.nc","r")
lat2d_1 = f1->XLAT(0,:,:)
lon2d_1 = f1->XLONG(0,:,:)

; Load in third file to compare
f2 = addfile(dir+tag2+"/wrfcloud/wrf-"+date+"."+tag2+"-clouds.nc","r")
lat2d_2 = f2->XLAT(0,:,:)
lon2d_2 = f2->XLONG(0,:,:)

; Load in fourth file to compare
f3 = addfile(dir+tag3+"/wrfcloud/wrf-"+date+"."+tag3+"-clouds.nc","r")
lat2d_3 = f3->XLAT(0,:,:)
lon2d_3 = f3->XLONG(0,:,:)

; Load in fourth file to compare
f4 = addfile(dir+tag4+"/wrfcloud/wrf-"+date+"."+tag4+"-clouds.nc","r")
lat2d_4 = f4->XLAT(0,:,:)
lon2d_4 = f4->XLONG(0,:,:)

; Load in fourth file to compare
f5 = addfile(dir+tag5+"/wrfcloud/wrf-"+date+"."+tag5+"-clouds.nc","r")
lat2d_5 = f5->XLAT(0,:,:)
lon2d_5 = f5->XLONG(0,:,:)

; Load in fourth file to compare
f6 = addfile(dir+tag6+"/wrfcloud/wrf-"+date+"."+tag6+"-clouds.nc","r")
lat2d_6 = f6->XLAT(0,:,:)
lon2d_6 = f6->XLONG(0,:,:)

;;;;;;;;;;
; load in wrf variables
;;;;;;;;;;
print("Loading "+varcode+" from each file")
; file 0
if (varcode.eq."SWUT")
  var0 = f0->$invar1$(0,:,:)
  var1 = f1->$invar1$(0,:,:)
  var2 = f2->$invar1$(0,:,:)
  var3 = f3->$invar1$(0,:,:)
  var4 = f4->$invar1$(0,:,:)
  var5 = f5->$invar1$(0,:,:)
  var6 = f6->$invar1$(0,:,:)
end if
if (varcode.eq."CLDF")
  var0 = dim_sum_n_Wrap(f0->$invar1$(0,:,:,:),0)
  var1 = dim_sum_n_Wrap(f1->$invar1$(0,:,:,:),0)
  var2 = dim_sum_n_Wrap(f2->$invar1$(0,:,:,:),0)
  var3 = dim_sum_n_Wrap(f3->$invar1$(0,:,:,:),0)
  var4 = dim_sum_n_Wrap(f4->$invar1$(0,:,:,:),0)
end if
print("Loaded variables")

; assign 2d lat and lon attributes for plotting:
  var0@lat2d  = lat2d_0
  var0@lon2d  = lon2d_0
  var1@lat2d  = lat2d_1
  var1@lon2d  = lon2d_1
  var2@lat2d  = lat2d_2
  var2@lon2d  = lon2d_2
  var3@lat2d  = lat2d_3
  var3@lon2d  = lon2d_3
  var4@lat2d  = lat2d_4
  var4@lon2d  = lon2d_4
  var5@lat2d  = lat2d_5
  var5@lon2d  = lon2d_5
  var6@lat2d  = lat2d_6
  var6@lon2d  = lon2d_6

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
  res@mpCenterLonF                = -25. ;-40.              ; set the center lat/lon  ---set by akd for Greenland
  res@mpCenterLatF                = 65.  ;60.               ; -----set by akd for Greenland
  res@mpGridAndLimbOn             = True              ; Turn on lat/lon grid
  res@mpGridLineDashPattern       = 2                 ; Change dash pattern
  res@mpFillOn                    = True              ; Enables map fill
  res@mpGeophysicalLineColor      = "black"           ; Color of continents
  res@mpGeophysicalLineThicknessF = 0.75              ; Make continents thinner
  res@tiMainFontHeightF          = 0.025 ;0.014
  res@tiMainFontThicknessF       = 1.5
  res@lbLabelBarOn               = False             ; turn off individual label bars

  ; contour res
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

; set text res for labels
  txres                           = True
  txres@txFontHeightF             = 0.025 
  txres@txFontThicknessF          = 2.
  txres@txFont                    = 22
  txres@txBackgroundFillColor     = "white"
  lat_txt                         = 70.5
  lon_txt                         = -33.0 

  ; panel resources
  pnlres                            = True
  pnlres@txFontHeightF              = 0.01 ;0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelLabelBar           = True
  pnlres@lbTitleString              = var0@units
  pnlres@lbTitlePosition            = "Right"
  pnlres@lbTitleDirection           = "Across"
  pnlres@lbTitleJust                = "CenterLeft"
  pnlres@lbTitleFontHeightF         = 0.0125
  pnlres@lbLabelStride              = stride1
  pnlres@lbLabelFontHeightF         = 0.0125
  pnlres@pmLabelBarWidthF           = 0.95
  pnlres@pmLabelBarHeightF          = 0.1
  pnlres@gsnMaximize                = True             ; fill the page

;;;;;;;;;
;; Denmark Strait Only plotted 
;;;;;;;;;
print("Plotting Denmark Strait")
wks = gsn_open_wks("ps" ,fout)
additional_colors = (/"gray85","yellow", "purple", "red"/)
gsn_merge_colormaps(wks,colormap,additional_colors)
plot = new(8, graphic)

opts1 = res1
opts1@mpLimitMode                 = "LatLon"
opts1@mpMinLatF                   = 64.0
opts1@mpMaxLatF                   = 71.0
opts1@mpMinLonF                   = -35.0
opts1@mpMaxLonF                   = -15.0

;;;;;;;;;;;;;
; Plot 0 
  cplot0 = gsn_csm_contour_map(wks, var0, opts1) 
  dum0 = gsn_add_text(wks,cplot0,"b) W05-40-M",lon_txt,lat_txt,txres)
  plot(1) = cplot0

;;;;;;;;;;;;;
; Plot 1 
  cplot1 = gsn_csm_contour_map(wks, var1, opts1) 
  dum1 = gsn_add_text(wks,cplot1,"c) W10-40-M",lon_txt,lat_txt,txres)
  plot(2) = cplot1

;;;;;;;;;;;;;
; Plot 2 
  cplot2 = gsn_csm_contour_map(wks, var2, opts1) 
  dum2 = gsn_add_text(wks,cplot2,"d) W25-40-M",lon_txt,lat_txt,txres)
  plot(3) = cplot2

;;;;;;;;;;;;;
; Plot 3 
  cplot3 = gsn_csm_contour_map(wks, var3, opts1) 
  dum3 = gsn_add_text(wks,cplot3,"e) W50-40-M",lon_txt,lat_txt,txres)
  plot(4) = cplot3

;;;;;;;;;;;;;
; Plot 4 
  cplot4 = gsn_csm_contour_map(wks, var4, opts1) 
  dum4 = gsn_add_text(wks,cplot4,"f) W05-60-M",lon_txt,lat_txt,txres)
  plot(5) = cplot4

;;;;;;;;;;;;;
; Plot 5 
  cplot5 = gsn_csm_contour_map(wks, var5, opts1) 
  dum5 = gsn_add_text(wks,cplot5,"g) W05-40-U",lon_txt,lat_txt,txres)
  plot(6) = cplot5

;;;;;;;;;;;;;
; Plot 6 
  cplot6 = gsn_csm_contour_map(wks, var6, opts1) 
  dum6 = gsn_add_text(wks,cplot6,"h) W05-60-U",lon_txt,lat_txt,txres)
  plot(7) = cplot6

;;;;;;;;;;;;;
; Plot final - panel plot set 
;;;;;;;;;;;;; 
;  pnlres@txString                   = varcode+ " WRF Denmark Strait comparison: "+date
  gsn_panel(wks,(/plot/),(/2,4/),pnlres)               ; create final panel plot

; Finally - make plot
print("converting plot to png")
delete(wks)
system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
