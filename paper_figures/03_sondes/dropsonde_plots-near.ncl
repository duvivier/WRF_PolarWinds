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
  name1  = "194625"
  tag1 = "D1"
  name2  = "203004"
  tag2 = "D3"
  name3  = "205909"
  tag3 = "D5"

numb   = "3"
title_fin = "Dropsondes along jet: near-coast"

; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Plotting polar winds dropsondes")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Get number of Dropsondes to plot (up to 4)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
en_num = stringtoint(numb)
names = new((/en_num/),"string")
do w = 0, en_num - 1
   if (w .eq. 0)
      dum1 = name1
   end if
   if (w .eq. 1)
      dum1 = name2
   end if
   if (w .eq. 2)
      dum1 = name3
   end if
   if (w .eq. 3)
      dum1 = name4
   end if
   names(w) = dum1
   delete([/dum1/])
end do

; select input directory
indir    = "/data/duvivier/polar_winds/DATA/Polar_Winds_Campaign2_Dropsondes_121015/"

; select preferences for figure title based on # of values
outdir = "./"
if (en_num .eq. 3) then
  fout   = outdir+"dropsondes_"+tag1+"_"+tag2+"_"+tag3
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Preallocate arrays for data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make new arrays to write to that have average
  head  = new((/en_num/),"string")
  pres  = new((/en_num,2000/),"float")
  temp  = new((/en_num,2000/),"float")
  ws    = new((/en_num,2000/),"float")
  wd    = new((/en_num,2000/),"float")
  hgt   = new((/en_num,2000/),"float")

w = 0
do w = 0, en_num -1
   ; get file name
   inname = indir+"/Drop_20150521-"+names(w)+"_L2_final.dat"
   ; load header
   head(w) = readAsciiHead(inname,1)
   ; load data
   dum = readAsciiTable(inname,19,"float",1)

   ; replace nans
   if (any(isnan_ieee(dum)))then
      fill = -9999999.99
      replace_ieeenan (dum,fill,0)
      dum@_FillValue = fill
   end if

   ; get the number of heights
   dims = dimsizes(dum)
   nh = dims(0)
   
   ; locations of all data determined by useing dropsonde_readme.txt
   pres(w,0:nh-1) = dum(:,1)   ; in mb
   temp(w,0:nh-1) = dum(:,2)   ; in degC
   ws(w,0:nh-1)   = dum(:,13)  ; in m/s
   wd(w,0:nh-1)   = dum(:,14)  ; in deg
   hgt(w,0:nh-1)  = dum(:,16)  ; in m above msl
   delete([/inname,dum,dims,nh/])
end do

; reverse all the arrays vertically
hgt = hgt(:,::-1)
ws = ws(:,::-1)
wd = wd(:,::-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Get matching lidar data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print("Loading relevant lidar data")
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

  n_s = 294.0 ;294.0
  n_e = 309.0

; load only files for the relevant comparisons
inds = ind((prof_num.eq.237.0) .or. (prof_num.eq.322.0) .or. (prof_num.eq.378.0))
files_sub = files(inds)
delete(inds)
ndates_sub = dimsizes(files_sub)
hgt_lidar = new((/ndates_sub,nvert/),"float")
ws_lidar = new((/ndates_sub,nvert/),"float")
wd_lidar = new((/ndates_sub,nvert/),"float")

n = 0
do n = 0, ndates_sub -1
   f1 = asciiread(files_sub(n),-1,"string")
   tmp = tofloat(str_get_field(f1,1,delim))
   dimz = dimsizes(tmp)
   hgt_lidar(n,0:dimz-1) = tofloat(str_get_field(f1,1,delim))
   wd_lidar(n,0:dimz-1) = tofloat(str_get_field(f1,2,delim))
   ws_lidar(n,0:dimz-1) = tofloat(str_get_field(f1,3,delim))
   delete([/f1,tmp,dimz/])
end do

; mask below 200m ASL because it looks odd in WS and WD
wd_lidar = where(hgt_lidar .lt. 200.0, wd_lidar@_FillValue, wd_lidar)
ws_lidar = where(hgt_lidar .lt. 200.0, ws_lidar@_FillValue, ws_lidar)

; mask above 1500m ASL because not showing this in figures
wd_lidar = where(hgt_lidar .gt. 1500.0, wd_lidar@_FillValue, wd_lidar)
ws_lidar = where(hgt_lidar .gt. 1500.0, ws_lidar@_FillValue, ws_lidar)

; anywhere that the wind direction is large (+300)
wd_lidar = where(wd_lidar .gt. 300.0, wd_lidar-360.0, wd_lidar)

; reverse all the arrays vertically
hgt_lidar = hgt_lidar(:,::-1)
ws_lidar = ws_lidar(:,::-1)
wd_lidar = wd_lidar(:,::-1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Calculate statistics between lidar and dropsondes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; to do this, interpolate to the same height array
  n_lev = 5000
  n_space = 10  ;50   - spacing between levels, in m
  hgt_grid = ispan(0,n_lev,n_space)
  hgt_grid!0 = "Vertical"
  hgt_grid@units = "m"
  n_hgts = dimsizes(hgt_grid)

  ; interpolate lidar data to regular vertical grid 
  ws_lidar_grid = new((/ndates_sub,n_hgts/),"float")
  wd_lidar_grid = new((/ndates_sub,n_hgts/),"float")
  n = 0
  do n = 0, ndates_sub-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt_lidar(n,:)))
    xi = hgt_lidar(n,inds)
    ws_sub = ws_lidar(n,inds)
    ws_lidar_grid(n,:) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    wd_sub = wd_lidar(n,inds)
    wd_lidar_grid(n,:) = linint1_Wrap(xi,wd_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub,wd_sub/])
  end do

  ; interpolate sonde data to regular vertical grid 
  ws_sonde_grid = new((/en_num,n_hgts/),"float")
  wd_sonde_grid = new((/en_num,n_hgts/),"float")
  n = 0
  do n = 0, en_num-1
    ; use only indicies where heights are not missing
    inds = ind(.not.ismissing(hgt(n,:)))
    xi = hgt(n,inds)
    ws_sub = ws(n,inds)
    ws_sonde_grid(n,:) = linint1_Wrap(xi,ws_sub,False,hgt_grid,0)
    wd_sub = wd(n,inds)
    wd_sonde_grid(n,:) = linint1_Wrap(xi,wd_sub,False,hgt_grid,0)
    delete([/inds,xi,ws_sub,wd_sub/])
  end do

; ignore dropsonde 1 because no data below 2km ASL

;;;;;;
; dropsonde 3 - stats
; compare with proceeding lidar
 ; wind speed
 dum1 = ws_lidar_grid(1,:)-ws_sonde_grid(1,:)
 tot_pts = dimsizes(ind(.not.ismissing(dum1)))
 bias = avg(dum1)
 rmse = sqrt((sum(dum1^2)/tot_pts))
 corr = escorc(ws_lidar_grid(1,:),ws_sonde_grid(1,:))
 print("sonde3a wind speed: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
 delete([/dum1,bias,rmse,corr,tot_pts/])
 ; wind direction
 dum1 = wd_lidar_grid(1,:)-wd_sonde_grid(1,:)
 tot_pts = dimsizes(ind(.not.ismissing(dum1)))
 bias = avg(dum1)
 rmse = sqrt((sum(dum1^2)/tot_pts))
 corr = escorc(wd_lidar_grid(1,:),wd_sonde_grid(1,:))
 print("sonde3a wind dir: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
 delete([/dum1,bias,rmse,corr,tot_pts/])

;; compare with following lidar
; ; wind speed
; dum1 = ws_lidar_grid(2,:)-ws_sonde_grid(1,:)
; tot_pts = dimsizes(ind(.not.ismissing(dum1)))
; bias = avg(dum1)
; rmse = sqrt((sum(dum1^2)/tot_pts))
; corr = escorc(ws_lidar_grid(2,:),ws_sonde_grid(1,:))
; print("sonde3b wind speed: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
; delete([/dum1,bias,rmse,corr,tot_pts/])
; ; wind direction
; dum1 = wd_lidar_grid(2,:)-wd_sonde_grid(1,:)
; tot_pts = dimsizes(ind(.not.ismissing(dum1)))
; bias = avg(dum1)
; rmse = sqrt((sum(dum1^2)/tot_pts))
; corr = escorc(wd_lidar_grid(2,:),wd_sonde_grid(1,:))
; print("sonde3b wind dir: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
; delete([/dum1,bias,rmse,corr,tot_pts/])

;;;;;;
; dropsonde 5 - stats
; compare with concurrent lidar
 ; wind speed
 dum1 = ws_lidar_grid(2,:)-ws_sonde_grid(2,:)
 tot_pts = dimsizes(ind(.not.ismissing(dum1)))
 bias = avg(dum1)
 rmse = sqrt((sum(dum1^2)/tot_pts))
 corr = escorc(ws_lidar_grid(2,:),ws_sonde_grid(2,:))
 print("sonde5 wind speed: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
 delete([/dum1,bias,rmse,corr,tot_pts/])
 ; wind direction
 dum1 = wd_lidar_grid(2,:)-wd_sonde_grid(2,:)
 tot_pts = dimsizes(ind(.not.ismissing(dum1)))
 bias = avg(dum1)
 rmse = sqrt((sum(dum1^2)/tot_pts))
 corr = escorc(wd_lidar_grid(2,:),wd_sonde_grid(2,:))
 print("sonde5 wind dir: bias: "+bias+", rmse: "+rmse+", corr:"+corr)
 delete([/dum1,bias,rmse,corr,tot_pts/])

;return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; Plotting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  print("Plotting dropsonde data")
  wks = gsn_open_wks("ps", outdir+fout)
  plot = new(3,graphic)

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
  res@tiMainOn                    = False              ; turn on main title for each plot
  res@tiMainFontHeightF           = 0.03              ; set size of font for main plot
  res@tiMainFontThicknessF        = 1.5

; set x axis tick marks
  res@tmXTOn                      = False             ; delete top and right ticks
  res@tmYROn                      = False
  res@trYMaxF                     = 1500.0            ; maximum height to plot to
  res@trYMinF                     = 0.
  res@tiYAxisString               = "Height (m ASL)"
  res@tiXAxisFont                 = 22
  res@tmXBLabelFont               = 22
  res@tiXAxisFontHeightF          = 0.035            ; set font size for x axis
  res@tmXBLabelFontHeightF        = 0.035             ; set tick mark label size for x axis
  res@tiYAxisFont                 = 22
  res@tmYLLabelFont               = 22
  res@tiYAxisFontHeightF          = 0.035             ; set font size for y axis
  res@tmYLLabelFontHeightF        = 0.035             ; set tick mark label size for y axis

; arrays for different colors, etc.(requires a single array of data)
  res@xyMarkLineModes             = (/"Markers","Markers","Markers","Markers","Markers","Markers"/)
  res@xyMarkers                   = (/16,16,16,16,16,16,16/)
  res@xyMarkerSizes               = (/0.005,0.005,0.005,0.005,0.005,0.005,0.005,0.005/)
  res@xyLineColors                = (/"black","blue","firebrick","grey","cyan1","pink2"/)
  res@xyMarkerColors              = (/"black","blue","firebrick","grey","cyan1","pink2"/)
  res@xyMonoLineColor             =  False                 ; allow other line colors
  res@gsnYRefLine                 = 0.0           ; create a reference line
  res@gsnYRefLineColor            = "grey15"
  res@gsnYRefLineDashPattern      = 16

; lidar resources
  res2                            = res
  delete([/res2@xyMarkLineModes,res2@xyMarkers,res2@xyMarkerSizes,res2@xyLineColors,res2@xyMarkerColors/])
  res2@xyMarkLineModes             = (/"MarkLines","MarkLines","MarkLines","MarkLines"/)
  res2@xyMarkers                   = (/16,16,16,16/)
  res2@xyMarkerSizes               = (/0.01,0.01,0.01,0.01/)
  res2@xyDashPatterns              = (/0,0,0,0/)
  res2@xyLineThicknesses           = (/1.5,1.5,1.5,1.5/)
  res2@xyLineColors                = (/"grey","steelblue2","pink2"/)
  res2@xyMarkerColors              = (/"grey","steelblue2","pink2"/)

; panel resources
  pnlres                            = True
  pnlres@gsnMaximize                = True
  pnlres@gsnFrame                   = False  
  pnlres@txFontHeightF              = 0.013
;  pnlres@txString                   = title_fin 
  pnlres@gsnPaperOrientation        = "landscape"      ; landscape mode
  pnlres@gsnPanelYWhiteSpacePercent = 0.5                ; Add white space b/w plots.
  pnlres@gsnPanelXWhiteSpacePercent = 0.5               ; Add white space b/w plots.
  pnlres@gsnPanelScalePlotIndex     = 1
  pnlres@gsnPanelRight              = 0.95             ; leave room for legend at bottom
  pnlres@gsnMaximize                = True	       ; fill the page

; legend resources for all the plots
  lgres                     = True
  lgres@vpWidthF            = 0.04               ; width of legend (NDC)
  lgres@vpHeightF           = 0.4               ; height of legend (NDC)
  lgres@lgLabelFontHeightF  = 0.1
  lgres@lgLabelFont         = 22
  lgres@lgAutoManage        = False              ; false allows me to set the legend directly
  lgres@lgOrientation       = "Vertical"
  lgres@lgMonoLineColor     = False
  lgres@lgMonoItemType      = False
  lgres@lgMonoMarkerSize    = False
;  lgres@lgItemTypes         = res@xyMarkLineModes
;  lgres@lgMarkerIndexes     = res@xyMarkers
;  lgres@lgMarkerSizes       = res@xyMarkerSizes
;  lgres@lgMarkerColors      = res@xyMarkerColors

  lgres@lgItemTypes         = (/"Markers","Markers","Markers","MarkLines","MarkLines","MarkLines"/)
  lgres@lgMarkerIndexes     = (/16,16,16,16,16,16/)
  lgres@lgMarkerSizes       = (/0.01,0.01,0.01,0.01,0.01,0.01/)
  lgres@lgMarkerColors      = (/"black","blue","firebrick","steelblue2","pink2"/)

  xpos                      = 0.95   ; xposition 
  ypos                      = 0.695  ; yposition 

;;;;;;;;;;;;;
; Plot 0 - Wind speed
;;;;;;;;;;;;
  opts                   = res
  opts@trXMaxF           = 28.0 ;max(ws(:,:))+3.0
  opts@trXMinF           = 0.0
  opts@tiXAxisString     = "Wind Speed (m s-1)"
  plot0 = gsn_csm_xy(wks,ws,hgt,opts)  
  plot0a = gsn_csm_xy(wks,ws_lidar,hgt_lidar,res2)
  overlay(plot0,plot0a)
  plot(0) = plot0
  delete(opts)

;;;;;;;;;;;;;
; Plot 1 - Wind Direction
;;;;;;;;;;;;
  opts                   = res
;  delete(opts@tiYAxisString)
  opts@trXMaxF           = 100  ;360.0
  opts@trXMinF           = 0.0
  opts@tiXAxisString     = "Wind Direction (deg)"
  delete(res2@xyMarkLineModes)
  res2@xyMarkLineModes             = (/"Markers","Markers","Markers","Markers"/)
  delete(res2@xyMarkerSizes)
  res2@xyMarkerSizes               = (/0.015,0.015,0.015,0.015/)
  plot1 = gsn_csm_xy(wks,wd,hgt,opts) 
  plot1a = gsn_csm_xy(wks,wd_lidar,hgt_lidar,res2)
  overlay(plot1,plot1a)
  plot(1) = plot1
  delete(opts)

;;;;;;;;;;;;;
; Plot 0 - Temperature
;;;;;;;;;;;;
  opts                   = res
;  delete(opts@tiYAxisString)
  opts@trXMaxF           = 4.0 ;max(temp)+5.0
  opts@trXMinF           = -8.0 ;min(temp)-5.0
  opts@tiXAxisString     = "Temperature (deg C)"
  plot(2) = gsn_csm_xy(wks,temp,hgt,opts)  
  delete(opts)

print("Individual plots complete- panneling")

;;;;;;;;;;;;;
; Panel regular plots
;;;;;;;;;;;;; 
; regular plot
  gsn_panel(wks,(/plot/),(/1,3/),pnlres)
  if (en_num .eq. 3)then 
     gsn_legend_ndc(wks,5,(/" D1"," D3"," D5"," L3"," L5"/),xpos ,ypos ,lgres) 
;     gsn_legend_ndc(wks,en_num,(/" "+tag1," "+tag2," "+tag3/),xpos ,ypos ,lgres) 
  end if
  frame(wks)
  delete(wks)
  print("converting to png")
  system("convert -trim -border 10 -bordercolor white -density 300 "+  \
         "-rotate -90 -trim -border 10 "+fout+".ps "+fout+".png")

;;;;;;;;;;;;;;;;;;;;;; END script
end
