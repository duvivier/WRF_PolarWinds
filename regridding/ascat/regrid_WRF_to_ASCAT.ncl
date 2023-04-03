;***************************************
; PROGRAM DESCRIPTION: Script to use ESMF weights and interpolate
;                      data from WRF to POP RASM grid (Regional)
; INPUT DATA: WRF netcdf file and ESMF mapping file
; OUTPUT DATA: Netcdf file with WRF data on POP grid
; CREATOR: Alice DuVivier (July 2015)
;***************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;***************************************
begin
; MANUAL INPUTS - for testing purposes. Otherwise loaded from csh script
; ******************************************************
;tag = "PW-50-40-M-bn"
;date = "2015-05-21_20-20"  
; ******************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
; BEGIN SCRIPT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setfileoption("nc","Format","LargeFile")
setfileoption("nc","SuppressClose",False)

dir_ascat   = "/data/duvivier/polar_winds/DATA/ASCAT/from_copernicus/"
; load ASCAT geo file
geo_ascat = "KNMI-GLO-WIND_L3-OBS_METOP-A_ASCAT_12_ASC_1458684163976.nc"  ; all ASCAT have same grid
f0 = addfile(dir_ascat+geo_ascat,"r") 
  ; latitude
  dum1 = f0->lat
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lat = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; longitude
  dum1 = f0->lon
  dum2 = dum1@scale_factor
  dum3 = int2dble(dum1)
  lon = dum3*dum2
  delete([/dum1, dum2, dum3/])
  ; wind speed (for dimensions)
  dum1 = f0->wind_speed(0,0,:,:)
  ws_0 = short2flt(dum1)
  delete([/dum1/])
  ; make 2d lat/lon values for regridding
  dims = dimsizes(ws_0)
  lat_ascat = new((/dims(0),dims(1)/),"double")
  lon_ascat = new((/dims(0),dims(1)/),"double")
  ; make 2d lats
  n = 0
  do n = 0, dims(1)-1
     lat_ascat(:,n) = lat
  end do
  ; make 2d lons
  n = 0
  do n = 0, dims(0)-1
     lon_ascat(n,:) = lon
  end do
  lat_ascat@units = "degrees"
  lon_ascat@units = "degrees"
  delete([/lat,lon,dims,ws_0,f0/])

dir_in = "/data/duvivier/polar_winds/DATA/"+tag+"/wrfout-cf/"
dir_out = "/data/duvivier/polar_winds/DATA/"+tag+"/wrf2ascat/"
; set WRF input file and load variables for interpolation
fin = "wrf-"+date+"."+tag+"-cf.nc"
f = addfile(dir_in+fin,"r")
lat_wrf = f->lat
lon_wrf = f->lon
hgt_wrf = f->Z_sfc
u_wrf = f->u_10m_tr
v_wrf = f->v_10m_tr
ws_wrf = f->ws_10m

; set Regridded output file
fout = "wrf2ascat."+date+"."+tag+"-cf.nc"
outfile = addfile(dir_out+fout,"c")

; write lat/lon to new file
outfile ->lat_ascat = lat_ascat
outfile ->lon_ascat = lon_ascat
print("Wrote lat/lon info")

; set Weight File (must be in same directory as script)
WgtFile = "ESMF_wgt-WRF_to_ASCAT.nc"

; set options for regridding
  optESMF                     = True
  optESMF@InterpMethod        = "bilinear"
  optESMF@WgtFileName         = WgtFile
  optESMF@Debug               = False ;True
  optESMF@CopyVarAtts         = False ;True
  optESMF@CopyVarCoords       = False ;True
  optESMF@RemoveSrcFile       = True  ;False   
  optESMF@RemoveDstFile       = True  ;False   
  optESMF@RemoveWgtFile       = False 
  optESMF@ForceOverwrite      = True  
  optESMF@SrcGridLat          = lat_wrf
  optESMF@SrcGridLon          = lon_wrf
  optESMF@SrcInputFileName    = fin
  optESMF@DstGridLat          = lat_ascat
  optESMF@DstGridLon          = lon_ascat
  optESMF@DstInputFileName    = geo_ascat
  optESMF@SrcTitle            = "WRF domain"
  optESMF@DstTitle            = "ASCAT domain - Greenland subset"
  optESMF@SrcRegional         = True     ; source data is regional
  optESMF@DstRegional         = True     ; destination grid is regional
  optESMF@SrcGridType         = "curvilinear"   ; WRF is a curvilinear grid
  optESMF@DstGridType         = "curvilinear"   ; ASCAT is a curvilinear grid

; regrid the height and create weight file
hgt_ascat = ESMF_regrid(hgt_wrf,optESMF)
print("Weights generated successfully")
copy_VarCoords(lat_ascat, hgt_ascat)
outfile ->Z_sfc = hgt_ascat
print("Regridded terrain")

u_10m_ascat = ESMF_regrid_with_weights(u_wrf,WgtFile,optESMF)
copy_VarCoords(lat_ascat, u_10m_ascat)
outfile ->u_10m = u_10m_ascat
print("Regridded u wind component")

v_10m_ascat = ESMF_regrid_with_weights(v_wrf,WgtFile,optESMF)
copy_VarCoords(lat_ascat, v_10m_ascat)
outfile ->v_10m = v_10m_ascat
print("Regridded v wind component")

ws_10m_ascat = ESMF_regrid_with_weights(ws_wrf,WgtFile,optESMF)
copy_VarCoords(lat_ascat, ws_10m_ascat)
outfile ->ws_10m = ws_10m_ascat
print("Regridded wind speed")

print("Completed gridding of WRF to ASCAT gradients for: "+date)
;;;;;;;;;;;;;;;;;;;;;; END script
end

