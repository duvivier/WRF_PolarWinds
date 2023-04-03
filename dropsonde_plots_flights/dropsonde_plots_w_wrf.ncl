;***************************************
; PROGRAM DESCRIPTION: This script plots frequency information for
;                      a SOM trained with three data sets
; INPUT DATA: SOM date and visual files for three data types
; OUTPUT DATA: One  plot of frequency comparisons
; CREATOR: Matt Higgins(Oct 2008), Melissa Nigro (Aug 2011)
;          Modified by Alice DuVivier - April 2012
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes
; ******************************************************
;  name  = "190950"
  vert = "40"   ; "40" or "60"
;  pbl = "U"     ; "U" or "M"
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting polar winds dropsondes and wrf simulations")
; get wrf date to load - nearest in time to the actual dropsonde time
if (name .eq. "190950")then
   date = "2015-05-21_19-00"
   lat = 67.662432
   lon = -31.29614
end if
if (name .eq. "192456")then
   date = "2015-05-21_19-20"
   lat = 68.646938
   lon = -32.501456
end if
if (name .eq. "194625")then
   date = "2015-05-21_19-40"
   lat = 67.516306
   lon = -28.718051
end if
if (name .eq. "201031")then
   date = "2015-05-21_20-00"
   lat = 67.367052
   lon = -26.550869
end if
if (name .eq. "203004")then
   date = "2015-05-21_20-20"
   lat = 68.175776
   lon = -26.645214
end if
if (name .eq. "204411")then
   date = "2015-05-21_20-40"
   lat = 67.667818
   lon = -25.218717
end if
if (name .eq. "205909")then
   date = "2015-05-21_21-00"
   lat = 68.606772
   lon = -25.695999
end if
if (name .eq. "211845")then
   date = "2015-05-21_21-20"
   lat = 67.168047
   lon = -23.482644
end if

; select preferences for figure title based on # of values
outdir = "./"
fout1   = outdir+"dropsondes_wrf_closest_pt_"+name+"-"+pbl
fout2   = outdir+"dropsondes_wrf_avg_4_pts_"+name+"-"+pbl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Get data for dropsonde comparisons
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; select input directory
indir    = "/data/duvivier/polar_winds/DATA/"

;;;;;;;;
; dropsonde
;;;;;;;;
print("Loading dropsonde data")
inname  = indir+"Polar_Winds_Campaign2_Dropsondes_121015/Drop_20150521-"+name+"_L2_final.dat"
; load header
head = readAsciiHead(inname,1)
; load data
dum = readAsciiTable(inname,19,"float",1)
; replace nans
if (any(isnan_ieee(dum)))then
   fill = -9999999.99
   replace_ieeenan (dum,fill,0)
   dum@_FillValue = fill
end if
; locations of all data determined by useing dropsonde_readme.txt
temp_ds = dum(:,2)   ; in degC
ws_ds   = dum(:,13)  ; in m/s
wd_ds   = dum(:,14)  ; in deg
hgt_ds  = dum(:,16)  ; in m above msl
delete([/inname,dum/])

; number of heights in dropsonde
dims = dimsizes(hgt_ds)
nhgt_ds = dims(0)
delete(dims)

;;;;;;;;
; WRF values - loop through all resolutions
;;;;;;;;
tags = (/"PW-50", "PW-25", "PW-10", "PW-05"/)  ; polar wind simulation names
rads = (/50.0, 25.0, 10.0, 5.0/)          ; radii associated with resolutions
dims = dimsizes(tags)
nwrf = dims(0)
delete(dims)
nhgt = stringtoint(vert) -1 ;39  ; number of vertical levels in all WRF sims

; preallocate arrays
hgt_w_pt  = new((/nwrf,nhgt/),"float")
temp_w_pt = new((/nwrf,nhgt/),"float")
ws_w_pt   = new((/nwrf,nhgt/),"float")
wd_w_pt   = new((/nwrf,nhgt/),"float")
hgt_w_av  = new((/nwrf,nhgt/),"float")
temp_w_av = new((/nwrf,nhgt/),"float")
ws_w_av   = new((/nwrf,nhgt/),"float")
wd_w_av   = new((/nwrf,nhgt/),"float")

w = 0
do w = 0, nwrf-1
   print("Loading"+tags(w)+"data")
   inname = indir+tags(w)+"-"+vert+"-"+pbl+"/wrfout-cf/wrf-"+date+"."+tags(w)+"-"+vert+"-"+pbl+"-cf.nc"
   f1 = addfile(inname,"r")
   lat2d = f1->lat
   lon2d = f1->lon

   ;;; single nearest point
   ; get nearest ij
   ij = getind_latlon2d(lat2d, lon2d, lat, lon)
   i = ij(0,0)
   j = ij(0,1)

   ; load data at single point
   hgt_w_pt(w,:)     = f1->Z_e(0,:,i,j)
   temp_w_pt(w,:)    = (f1->T_e(0,:,i,j)) - 273.15   ; in degC
   u_dum           = f1->u_tr_e(0,:,i,j)   ; in m/s
   v_dum           = f1->v_tr_e(0,:,i,j)   ; in m/s
   ws_w_pt(w,:)      = sqrt(u_dum^2 + v_dum^2)
   wd_w_pt(w,:)      = wind_direction(u_dum,v_dum,0)
   delete([/u_dum,v_dum/])

   ;;; weighted average of 4 nearest points
   ; get lat/lon of nearest 9
   lat_sub = lat2d(i-1:i+1,j-1:j+1)
   lon_sub = lon2d(i-1:i+1,j-1:j+1)

   ; get great circle distance between the different grids in km
   dist = gc_latlon(lat,lon,lat_sub,lon_sub,5,4) 
   dist@_FillValue = -999999.9
   dist1d = ndtooned(dist)
   qsort(dist1d)

   ; mask all but the 4 closest points
   dist = where(dist.eq.dist1d(0) .or. dist.eq.dist1d(1) .or. dist.eq.dist1d(2) .or. dist.eq.dist1d(3), dist, dist@_FillValue)
   rad = rads(w)
   weight = exp(-(dist^2)/(2*rad^2))

   ; load data at 9 points
   hgt_dum        = f1->Z_e(0,:,i-1:i+1,j-1:j+1)
   temp_dum       = (f1->T_e(0,:,i-1:i+1,j-1:j+1)) - 273.15   ; in degC
   u_dum          = f1->u_tr_e(0,:,i-1:i+1,j-1:j+1)   ; in m/s
   v_dum          = f1->v_tr_e(0,:,i-1:i+1,j-1:j+1)   ; in m/s

   ; get averages of closest points
   n = 0
   do n = 0, nhgt-1
      hgt_w_av(w,n)    = sum(hgt_dum(n,:,:)*weight)/sum(weight)
      temp_w_av(w,n)   = sum(temp_dum(n,:,:)*weight)/sum(weight)   
      u_dum1         = sum(u_dum(n,:,:)*weight)/sum(weight)  
      v_dum1         = sum(v_dum(n,:,:)*weight)/sum(weight)  
      ws_w_av(w,n)     = sqrt(u_dum1^2 + v_dum1^2)
      wd_w_av(w,n)     = wind_direction(u_dum1, v_dum1,0)
      delete([/u_dum1,v_dum1/])
   end do
   delete([/inname,f1,lat2d,lon2d,ij,i,j,lat_sub,lon_sub,dist,dist1d,rad,weight,hgt_dum,temp_dum,u_dum,v_dum/])
end do

;;;;;;;;
; combine arrays into ones for plotting
;;;;;;;;
; points
hgt_pt  = new((/nwrf+1,nhgt_ds/),"float")
temp_pt = new((/nwrf+1,nhgt_ds/),"float")
ws_pt   = new((/nwrf+1,nhgt_ds/),"float")
wd_pt   = new((/nwrf+1,nhgt_ds/),"float")
hgt_pt(0,:) = hgt_ds
hgt_pt(1,0:nhgt-1) = hgt_w_pt(0,:)
hgt_pt(2,0:nhgt-1) = hgt_w_pt(1,:)
hgt_pt(3,0:nhgt-1) = hgt_w_pt(2,:)
hgt_pt(4,0:nhgt-1) = hgt_w_pt(3,:)
temp_pt(0,:) = temp_ds
temp_pt(1,0:nhgt-1) = temp_w_pt(0,:)
temp_pt(2,0:nhgt-1) = temp_w_pt(1,:)
temp_pt(3,0:nhgt-1) = temp_w_pt(2,:)
temp_pt(4,0:nhgt-1) = temp_w_pt(3,:)
ws_pt(0,:) = ws_ds
ws_pt(1,0:nhgt-1) = ws_w_pt(0,:)
ws_pt(2,0:nhgt-1) = ws_w_pt(1,:)
ws_pt(3,0:nhgt-1) = ws_w_pt(2,:)
ws_pt(4,0:nhgt-1) = ws_w_pt(3,:)
wd_pt(0,:) = wd_ds
wd_pt(1,0:nhgt-1) = wd_w_pt(0,:)
wd_pt(2,0:nhgt-1) = wd_w_pt(1,:)
wd_pt(3,0:nhgt-1) = wd_w_pt(2,:)
wd_pt(4,0:nhgt-1) = wd_w_pt(3,:)

; averages
hgt_av  = new((/nwrf+1,nhgt_ds/),"float")
temp_av = new((/nwrf+1,nhgt_ds/),"float")
ws_av   = new((/nwrf+1,nhgt_ds/),"float")
wd_av   = new((/nwrf+1,nhgt_ds/),"float")
hgt_av(0,:) = hgt_ds
hgt_av(1,0:nhgt-1) = hgt_w_av(0,:)
hgt_av(2,0:nhgt-1) = hgt_w_av(1,:)
hgt_av(3,0:nhgt-1) = hgt_w_av(2,:)
hgt_av(4,0:nhgt-1) = hgt_w_av(3,:)
temp_av(0,:) = temp_ds
temp_av(1,0:nhgt-1) = temp_w_av(0,:)
temp_av(2,0:nhgt-1) = temp_w_av(1,:)
temp_av(3,0:nhgt-1) = temp_w_av(2,:)
temp_av(4,0:nhgt-1) = temp_w_av(3,:)
ws_av(0,:) = ws_ds
ws_av(1,0:nhgt-1) = ws_w_av(0,:)
ws_av(2,0:nhgt-1) = ws_w_av(1,:)
ws_av(3,0:nhgt-1) = ws_w_av(2,:)
ws_av(4,0:nhgt-1) = ws_w_av(3,:)
wd_av(0,:) = wd_ds
wd_av(1,0:nhgt-1) = wd_w_av(0,:)
wd_av(2,0:nhgt-1) = wd_w_av(1,:)
wd_av(3,0:nhgt-1) = wd_w_av(2,:)
wd_av(4,0:nhgt-1) = wd_w_av(3,:)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plotting dropsonde data")

;;;;;;;;;;;;;
; Set Resources
;;;;;;;;;;;;;
; set resources used for all plots
  res                             = True              ; plot mods desired
  res@gsnFrame                    = False             ; Do not draw plot 
  res@gsnDraw                     = False             ; Do not advance frame
  res@gsnMaximize                 = True              ; maximize plot
  res@vpHeightF                   = 1.5               ; change aspect ratio of plot (viewport)
  res@vpWidthF                    = 1.0          

; set title resources
  res@tiMainOn                    = True              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.03              ; set size of font for main plot
  res@tiMainFontThicknessF        = 1.5

; set x axis tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trYMaxF                     = 2500.0  ;max(hgt_pt(0,:))          ; maximum height to plot to
  res@trYMinF                     = 0.
  res@tiYAxisString               = "Height (m above MSL)"
  res@tiXAxisFontHeightF          = 0.03            ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.03             ; set tick mark label size for x axis
  res@tiYAxisFontHeightF          = 0.03             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.03             ; set tick mark label size for y axis

; arrays for different colors, etc.(requires a single array of data)
  res@xyMarkLineModes             = (/"MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines","MarkLines"/)
  res@xyMarkers                   = (/16,16,16,16,16,16,16/)
  res@xyMarkerSizes               = (/0.005,0.01,0.01,0.01,0.01,0.005,0.005/)
  res@xyLineColors                = (/"black","blue","cyan1","pink2","firebrick","green"/)
  res@xyMarkerColors              = (/"black","blue","cyan1","pink2","firebrick","green"/)
  res@xyMonoLineColor             =  False                 ; allow other line colors
  res@xyDashPatterns              = (/0,0,0,0,0,0,0/)
  res@xyLineThicknesses           = (/1.5,1.5,1.5,1.5,1.5,1.5,1.5/)
  res@gsnYRefLine                 = 0.0           ; create a reference line
  res@gsnYRefLineColor            = "grey15"
  res@gsnYRefLineDashPattern      = 16

; panel resources
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False  
  pnlres@txFontHeightF              = 0.013
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 2                ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelBottom             = 0.13             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page

; legend resources for all the plots
  lgres                     = True
  ;lgres@pmLegendWidthF     = 0.03
  ;lgres@pmLegendHeightF    = 0.01
  lgres@vpWidthF            = 0.75               ; width of legend (NDC)
  lgres@vpHeightF           = 0.05               ; height of legend (NDC)
  lgres@lgLabelFontHeightF  = 0.0075 ;0.01
  lgres@lgAutoManage        = False              ; false allows me to set the legend directly
  lgres@lgOrientation       = "horizontal" 
  lgres@lgMonoLineColor     = False
  lgres@lgMonoItemType      = False
  lgres@lgItemTypes         = res@xyMarkLineModes
  lgres@lgDashIndexes       = res@xyDashPatterns
  lgres@lgMarkerIndexes     = res@xyMarkers
  lgres@lgMonoMarkerSize    = False
  lgres@lgMarkerSizes       = res@xyMarkerSizes
  lgres@lgMonoLineThickness = False
  lgres@lgLineThicknesses   = res@xyLineThicknesses
  lgres@lgLineColors        = res@xyLineColors   ; make the colors for the legend
  lgres@lgMarkerColors      = res@xyMarkerColors
  xpos                      = 0.15   ; xposition 
  ypos                      = 0.3  ; yposition (below figures)

; temperature resources
  optst                   = res
  optst@trXMaxF           = max(temp_pt(0,:))+5.0
  optst@trXMinF           = min(temp_pt(0,:))-5.0
  optst@tiMainString      = "Temperature (deg C)"
  optst@tiXAxisString     = "Temperature (deg C)"

; wind speed resources
  optsws                   = res
  optsws@trXMaxF           = max(ws_pt(0,:))+5.0
  optsws@trXMinF           = 0.0
  optsws@tiMainString      = "Wind Speed (m/s)"
  optsws@tiXAxisString     = "Wind Speed (m/s)"

; wind direction resources
  optswd                   = res
  optswd@trXMaxF           = 360.0
  optswd@trXMinF           = 0.0
  optswd@tiMainString      = "Wind Direction (deg)"
  optswd@tiXAxisString     = "Wind Direction (deg)"

;;;;;;;;;;;;;
; Plot of single point
;;;;;;;;;;;;
  wks = gsn_open_wks("ps", outdir+fout1)
  plot = new(3,graphic)

  ; Plot 0 - Temperature
  plot(0) = gsn_csm_xy(wks,temp_pt,hgt_pt,optst)  
  ; Plot 1 - Wind speed
  plot(1) = gsn_csm_xy(wks,ws_pt,hgt_pt,optsws)  
  ; Plot 1 - Wind Direction
  plot(2) = gsn_csm_xy(wks,wd_pt,hgt_pt,optswd)  
  print("DS and WRF point plots complete- panneling")
  ; Panel regular plots
  pnlres@txString                   = name+" Polar Winds Dropsonde "+name+" Comparison with WRF sims (nearest point)"
  gsn_panel(wks,(/plot/),(/1,3/),pnlres)
  gsn_legend_ndc(wks,nwrf+1,(/"PW Drop",tags(0),tags(1),tags(2),tags(3)/),xpos ,ypos ,lgres) 
  frame(wks)
  delete(wks)
  print("converting to png")
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout1+".ps "+fout1+".png")

;;;;;;;;;;;;;
; Plot of single point
;;;;;;;;;;;;
  wks = gsn_open_wks("ps", outdir+fout2)
  plot = new(3,graphic)

  ; Plot 0 - Temperature
  plot(0) = gsn_csm_xy(wks,temp_av,hgt_av,optst)  
  ; Plot 1 - Wind speed
  plot(1) = gsn_csm_xy(wks,ws_av,hgt_av,optsws)  
  ; Plot 1 - Wind Direction
  plot(2) = gsn_csm_xy(wks,wd_av,hgt_av,optswd)  
  print("DS and WRF point plots complete- panneling")
  ; Panel regular plots
  pnlres@txString                   = "Polar Winds Dropsonde "+name+" Comparison with WRF sims (weighted avg of 4 nearest points)"
  gsn_panel(wks,(/plot/),(/1,3/),pnlres)
  gsn_legend_ndc(wks,nwrf+1,(/"PW Drop",tags(0),tags(1),tags(2),tags(3)/),xpos ,ypos ,lgres) 
  frame(wks)
  delete(wks)
  print("converting to png")
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout2+".ps "+fout2+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
