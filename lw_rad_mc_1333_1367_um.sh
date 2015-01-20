#!/bin/bash
#
# 
# For running on Cirruc C
#
#$ -q radar
#$ -l h_rt=36000
#$ -pe mpi 16

#######################################################################################

#The lw_mc_rad script here is the master script for running jobs on Cirrus-c. 

#Copy it to folder where all input and config files are and set the scene. Run!

#For new wavelengths copy new xml files in that dir and then change it in the
#master script too.

#Igor, 19.05.2014.

########################################################################################
#
#==============================================================================================
#					
# Test End-to-End Flux clousure script
#
#		Script to automatically simulate some sessions with ECSIM implemented also 
#		ground-based radar and lidar measurements.
#
# The main steps are as follows:
#----------------------------------------------------------------------------------------------
# 1)  Runs scene_creator_xml to produce a uff file
# 2)  Runs extract_env on the uff file to produce an atmos_env_file
# 3)  Runs lid_filter
# 4)  Runs lidar
# 5)  Runs lid_l2a
# 6)  Runs rad_filter
# 7)  Runs radar
# 8)  Runs rad_l2a
# 9)  Runs lid_rad_l2b
# 10) Runs lw_rad to produce TOA MSI Radiances
# 11) Runs msi
# 12) Runs lw_msi_lid_rad_l2b_3d
# 13) Runs scene_creator_xml to produce a `reconstructed' scene.
############## Flux Clousure part ########################
# 14) Runs sw_rad to produce TOA BBR SW radiances and SW-BB TOA flux for the original scene.
# 15) Runs lw_rad to produce TOA BBR LW radiances for the original scene.
# 16) Runs lw_rad to produce TOA LW-BB TOA flux for the original scene.
# 17) Runs sw_rad to produce TOA BBR SW radiances and SW-BB TOA flux for the reconstructed scene.
# 18) Runs lw_rad to produce TOA BBR LW radiances for the reconstructed scene.
# 19) Runs lw_rad to produce TOA LW-BB TOA flux for the reconstructed scene.
#==============================================================================================
#
#
#----------------------------------------------------------------------------------------------
# The following variables must be adapted for the system
# (usually only ECSIM_HOME has to be changed. However, check for pgpplot too.)
#------------------------------------------------------------
#################### Set in which machine you are running the script #########################
run_on_tud=0
run_on_knmi=0
run_on_laptop=0
run_on_TUD_igor=0          #ig
run_on_HP4330s_igor=0      #ig
run_on_cirrus_c1=1         #ig
#
#
#
############## Select the variables and PATH to be exported #####################
if [ "$run_on_tud" -gt "0" ] 
   then
   echo '  '	
   echo '--------------------------------------------------------------------------------'
   echo '------------- setting configuration for running on TUD machine -----------------'
   echo '  '	
   export  ECSIM_HOME="/home/igor/ECSIM_v16/"
   export  PGPLOT_FONT="/usr/local/pgplot/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#----------------------- Run on KNMI machine --------------------------------------
#
if [ "$run_on_knmi" -gt "0" ] 
   then
   echo '  '
   echo '--------------------------------------------------------------------------------'
   echo '------------setting configuration for running on KNMI machine  -----------------'
   echo '  '	
   export  ECSIM_HOME="/nobackup/users/placidi/ECSIM_121/"
   export  PGPLOT_FONT="/usr/local/free/pgplot/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#----------------------- Run on LAPTOP machine --------------------------------------
#
if [ "$run_on_laptop" -gt "0" ] 
   then
   echo '  '
   echo '--------------------------------------------------------------------------------'
   echo '-------------- setting configuration for running on LAPTOP ---------------------'
   echo '  '
   export  ECSIM_HOME="/home/simone/ECSIM/"
   export  PGPLOT_FONT="/opt/pgplot/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#----------------------- Run on TUD Igor --------------------------------------
#
if [ "$run_on_TUD_igor" -gt "0" ]     #ig
   then
   echo '  '
   echo '--------------------------------------------------------------------------------'
   echo '--------setting configuration for running on TUD_igor machine  -----------------'
   echo '  '    
   export  ECSIM_HOME="/data/ECSIMv15/"
   export  PGPLOT_FONT="/usr/lib/pgplot/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#----------------------- Run on HP4330s Igor --------------------------------------
#
if [ "$run_on_HP4330s_igor" -gt "0" ]      #ig
   then
   echo '  '
   echo '--------------------------------------------------------------------------------'
   echo '----setting configuration for running on HP4330s_igor machine  -----------------'
   echo '  '    
   export  ECSIM_HOME="/nobackup/users/placidi/ECSIM_121/"
   export  PGPLOT_FONT="/usr/local/free/pgplot/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#----------------------- Run on Cirrus C1 16 core CPU Igor --------------------------------------
#
if [ "$run_on_cirrus_c1" -gt "0" ]      #ig
   then
   echo '  '
   echo '--------------------------------------------------------------------------------'
   echo '------------setting configuration for running on Cirrus C1  machine  -----------'
   echo '  '    
   export  ECSIM_HOME="/home/igor/v1.6/"
   export  PGPLOT_FONT="/nfs/packages/suse-12.3/x86_64/pgplot-5.2.2/grfont.dat"
   export  SURF_FILES="$ECSIM_HOME/models/aux/surface_files/"
   export  STD_ATMOS="$ECSIM_HOME/models/aux/standard_atmos_profiles/"
   export  SCATT_LIB="$ECSIM_HOME/models/aux/scattering_libraries/"
fi
#
#
cd $ECSIM_HOME
#-------------------------------------------------------------------------
# For multi-processor/core systems the following variables should be set
# if the openmp option was chosen at compile time.
# In particular, OMP_NUM_THREADS should be set to the number 
# of cores/processors one has avaiable.
#--------------------------------------------------------------------------
#
export OMP_NUM_THREADS=16
export KMP_STACKSIZE=750M
ulimit -s unlimited 
#
# ---------- ####### CHECK THE DATE AND TIME OF THE DATE OF RUN ############### 
#
time_sys=`date +"%Y%m%d%H%M%S"`
#   FLAGS FOR OUTPUT FOLDER NAMES
th=$1
echo $th
#exit
#
#
#----------------------------------------------------
# Select the scene you want to use for the simulation
#----------------------------------------------------
#
chess_board_vert_hom_reff_partial=0                             #ig 25.10.2013, for checking extract_quantity_reff
chess_board_vert_hom_reff=0                             #ig 30.10.2013, the same
chess_board_vert_hom_reff_full_no_clear_sky_PP=0        #ig 05.11.2013, PP water clouds, 8x8km (same as chess board)
standard_test_scene=0                                   #ig
test_scene_drizzle=0                                    #ig
scene_1re=0
scene_2lay=0
scene_4pts=0
scene_fire=0
scene_AS3_1=0
scene_AS3_2=0
scene_AS3_3=0
scene_AS3_4=0
les_import_hr18_ecsimreff=0      #ig
les_import_hr18_ecsimreff_N_eq_10=0      #ig
les_import_hr18_ecsimreff_N_eq_50=0      #ig
les_import_hr18_ecsimreff_N_eq_150=0      #ig
#
# Varible N, for Gordon Research Conference 2013, New London, NH
##############################################################################################
les_import_hr18_N_eq_50=0           #ig, for GRC variable solar zenith angles. solevve=70deg 
les_import_hr20_N_eq_100=0           #ig, for GRC variable solar zenith angles. solevve=70deg 
les_import_hr22_N_eq_250=0           #ig, for GRC variable solar zenith angles. solevve=70deg 
les_import_hr24_N_eq_500=0           #ig, for GRC variable solar zenith angles. solevve=70deg 
les_import_hr26_N_eq_2000=0           #ig, for GRC variable solar zenith angles. solevve=70deg
############################################################################################### 
#
# Scenes LES ASTEX 02-40 hours with N=100#/cm3, started an organized list on 14.08.2013.
###############################################################################################
les_import_hr02=1
les_import_hr04=0
les_import_hr06=0
les_import_hr08=0
les_import_hr10=0
les_import_hr12=0
les_import_hr14=0
les_import_hr16=0
les_import_hr18=0
les_import_hr20=0         #  ALL SCENES HAVE 100#/cm3 droplet number contentration here  #
les_import_hr22=0
les_import_hr24=0
les_import_hr26=0
les_import_hr28=0
les_import_hr30=0
les_import_hr32=0
les_import_hr34=0
les_import_hr36=0
les_import_hr38=0
les_import_hr40=0
###############################################################################################

les_import_hr02_ecsimreff=0      #ig
les_import_hr18_drizzle=0        #ig
les_import_hr18_lwater=0         #ig
les_import_hr18_lwater_lidar=0   #ig
les_import_hr24_ecsimreff=0      #ig
wc_scene_igor=0                  #ig
#
################################ CONFIGURATION INPUTS BLOCK###############################
#
############################### configuring the scenes ##################################
if [ "$les_import_hr02" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr02 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr02.xml"
	scene_dir="sessions/lw_rad_mc.02/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr04" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr04 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr04.xml"
	scene_dir="sessions/lw_rad_mc.04/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr06" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr06 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr06.xml"
	scene_dir="sessions/lw_rad_mc.06/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr08" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr08 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr08.xml"
	scene_dir="sessions/lw_rad_mc.08/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr10" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr10 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr10.xml"
	scene_dir="sessions/lw_rad_mc.10/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr12" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr12 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr12.xml"
	scene_dir="sessions/lw_rad_mc.12/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr14" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr14 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr14.xml"
	scene_dir="sessions/lw_rad_mc.14/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr16" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr16 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr16.xml"
	scene_dir="sessions/lw_rad_mc.16/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr18" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr18 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr18.xml"
	scene_dir="sessions/lw_rad_mc.18/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr20" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr20 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr20.xml"
	scene_dir="sessions/lw_rad_mc.20/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr22" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr22 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr22.xml"
	scene_dir="sessions/lw_rad_mc.22/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr24" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr24 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr24.xml"
	scene_dir="sessions/lw_rad_mc.24/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr26" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr26 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr26.xml"
	scene_dir="sessions/lw_rad_mc.26/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr28" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr28 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr28.xml"
	scene_dir="sessions/lw_rad_mc.28/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr30" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr30 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr30.xml"
	scene_dir="sessions/lw_rad_mc.30/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr32" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr32 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr32.xml"
	scene_dir="sessions/lw_rad_mc.32/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr34" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr34 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr34.xml"
	scene_dir="sessions/lw_rad_mc.34/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr36" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr36 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr36.xml"
	scene_dir="sessions/lw_rad_mc.36/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr38" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr38 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr38.xml"
	scene_dir="sessions/lw_rad_mc.38/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr40" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr40 '  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=0
	scene_file_in="les_import_hr40.xml"
	scene_dir="sessions/lw_rad_mc.40/"
	scene_file_out="$scene_dir/scene.uff"
	fi      
###########
if [ "$les_import_hr26_N_eq_2000" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'	
       	echo ' Scene:  les import hr26 N eq 2000'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr26_N_eq_2000.xml"
	scene_file_out="sessions/hr26_N_eq_2000/scene.uff"
	scene_dir="sessions/hr26_N_eq_2000"
	fi      
###########
if [ "$les_import_hr24_N_eq_500" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr24 N eq 500'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr24_N_eq_500.xml"
	scene_file_out="sessions/hr24_N_eq_500/scene.uff"
	scene_dir="sessions/hr24_N_eq_500"
	fi      
###########
if [ "$les_import_hr22_N_eq_250" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr22 N eq 250'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr22_N_eq_250.xml"
	scene_file_out="sessions/hr22_N_eq_250/scene.uff"
	scene_dir="sessions/hr22_N_eq_250"
fi
###########
if [ "$les_import_hr20_N_eq_100" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr20 N eq 100'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr20_N_eq_100.xml"
	scene_file_out="sessions/hr20_N_eq_100/scene.uff"
	scene_dir="sessions/hr20_N_eq_100"
fi
###########
if [ "$les_import_hr18_N_eq_50" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr18 N eq 50'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr18_N_eq_50.xml"
	scene_file_out="sessions/hr18_N_eq_50/scene.uff"
	scene_dir="sessions/hr18_N_eq_50"
fi
###########
if [ "$les_import_hr18_ecsimreff_N_eq_10" -gt "0" ]     # ig
then
echo ' -------------------------------------------------------------------'
echo ' Scene:  les import hr18 ecsimreff N eq 10'  
echo ' -------------------------------------------------------------------'
run_scene_creator=1
scene_file_in="scenes/les_import_hr18_N_eq_10.xml"
scene_file_out="sessions/hr18_ecsimreff_up_N_eq_10/scene.uff"					       
scene_dir="sessions/hr18_ecsimreff_up_N_eq_10"
fi
###########
if [ "$les_import_hr18_ecsimreff_N_eq_50" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr18 ecsimreff N eq 50'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr18_N_eq_50.xml"
	scene_file_out="sessions/hr18_ecsimreff_up_N_eq_50/scene.uff"
	scene_dir="sessions/hr18_ecsimreff_up_N_eq_50"
fi
###########
if [ "$les_import_hr18_ecsimreff_N_eq_150" -gt "0" ]     # ig
then
	echo ' -------------------------------------------------------------------'
	echo ' Scene:  les import hr18 ecsimreff N eq 150'  
	echo ' -------------------------------------------------------------------'
	run_scene_creator=1
	scene_file_in="scenes/les_import_hr18_N_eq_150.xml"
	scene_file_out="sessions/hr18_ecsimreff_up_N_eq_150/scene.uff"
	scene_dir="sessions/hr18_ecsimreff_up_N_eq_150"
fi
###########
if [ "$les_import_hr24_ecsimreff" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr24 ecsimreff'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr24_ecsimreff.xml"
    scene_file_out="sessions/hr24_ecsimreff/scene.uff"
    scene_dir="sessions/hr24_ecsimreff"
fi
###########
if [ "$les_import_hr02_ecsimreff" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr02 ecsimreff'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr02_ecsimreff.xml"
    scene_file_out="sessions/hr02_ecsimreff/scene.uff"
    scene_dir="sessions/hr02_ecsimreff"
fi
###########
if [ "$wc_scene_igor" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  water cloud only scene igor'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/wc_scene_igor.xml"
    scene_file_out="sessions/wc_scene/scene.uff"
    scene_dir="sessions/wc_scene"
fi
##########
#if [ "$les_import_hr02" -gt "0" ]     # ig
#   then
#    echo ' -------------------------------------------------------------------'
#    echo ' Scene:  les import hr02 max res'  
#    echo ' -------------------------------------------------------------------'
#    run_scene_creator=1
#    scene_file_in="scenes/les_import_hr02_ecsimreff.xml"
#    scene_file_out="sessions/hr02_ecsimreff/scene.uff"
#    scene_dir="sessions/hr02_ecsimreff/"
#fi
###########
if [ "$test_scene_drizzle" -gt "0" ] 
   then
    echo ' ------------------------------------------------------------------'
    echo ' Scene:  test scene drizzle '
    echo '-------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/test_scene_drizzle.xml"
    scene_file_out="sessions/test_scene_drizzle/scene.uff"
    scene_dir="sessions/test_scene_drizzle/"
fi
##############################################################################################
if [ "$standard_test_scene" -gt "0" ]   
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  standard test scene '
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/standard_test_scene_knmi.xml"
    scene_file_out="sessions/stand_test_scene_lidar/scene.uff"
    scene_dir="sessions/stand_test_scene_lidar"
fi
################################################################################################
if [ "$chess_board_vert_hom_reff_partial" -gt "0" ]
then
echo ' -------------------------------------------------------------------'
echo ' Scene:  CHESS BOARD vertical homogeneous effective radius PARTLY chess board, PARTLY PP cloud'
echo ' -------------------------------------------------------------------'
run_scene_creator=1
scene_file_in="scenes/chess_board_vert_hom_reff_partial.xml"
scene_file_out="sessions/chess_board_vert_hom_reff_partial/scene.uff"
scene_dir="sessions/chess_board_vert_hom_reff_partial"
fi
################################################################################################
if [ "$chess_board_vert_hom_reff_full_no_clear_sky_PP" -gt "0" ]
then
echo ' -------------------------------------------------------------------'
echo ' Scene:  CHESS BOARD FULL SIZE vertical homogeneous effective radius Plane Parallel Cloud'
echo ' -------------------------------------------------------------------'
run_scene_creator=1
scene_file_in="scenes/chess_board_vert_hom_reff_full_no_clear_sky_PP.xml"
scene_file_out="sessions/chess_board_vert_hom_reff_full_no_clear_sky_PP/scene.uff"
scene_dir="sessions/chess_board_vert_hom_reff_full_no_clear_sky_PP"
fi
################################################################################################
if [ "$chess_board_vert_hom_reff" -gt "0" ]
then
echo ' -------------------------------------------------------------------'
echo ' Scene:  CHESS BOARD FULL SIZE vertical homogeneous effective radius '
echo ' -------------------------------------------------------------------'
run_scene_creator=1
scene_file_in="scenes/chess_board_vert_hom_reff_full.xml"
scene_file_out="sessions/chess_board_vert_hom_reff_full/scene.uff"
scene_dir="sessions/chess_board_vert_hom_reff_full"
fi
################################################################################################
if [ "$les_import_hr18_lwater_lidar" -gt "0" ]     # ig, specialy made for lidar runs
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr18 lwater lidar only'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr18_lwater.xml"
    scene_file_out="sessions/hr18_lwater_lidar_up/scene.uff"
    scene_dir="sessions/hr18_lwater_lidar_up"
fi
###############################################################################################
if [ "$les_import_hr18_lwater" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr18 lwater'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr18_lwater.xml"
    scene_file_out="sessions/hr18_lwater_up/scene.uff"
    scene_dir="sessions/hr18_lwater_up"
fi
##########
if [ "$les_import_hr18_drizzle" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr18 drizzle'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr18_drizzle.xml"
    scene_file_out="sessions/hr18_drizzle_up/scene.uff"
    scene_dir="sessions/hr18_drizzle_up"
fi
###########
if [ "$les_import_hr18_ecsimreff" -gt "0" ]     # ig
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  les import hr18 ecsimreff'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/les_import_hr18_ecsimreff.xml"
    scene_file_out="sessions/hr18_ecsimreff_up/scene.uff"
    scene_dir="sessions/hr18_ecsimreff_up"
fi
###########
if [ "$scene_1re" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  scene with 1 Reff'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/selected_scenes/stratus_1re/stratus_1re.xml"
    scene_file_out="scenes/selected_scenes/stratus_1re/scene.uff"
    scene_dir="sessions/str_1re"
fi
############
if [ "$scene_2lay" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  scene with 2 Reff'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_in="scenes/selected_scenes/stratus_2layers/stratus_2layers.xml"
    scene_file_out="scenes/selected_scenes/stratus_2layers/scene.uff"
    scene_dir="sessions/str_2lay"
fi
###########
if [ "$scene_4pts" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:   scene with  4 points'  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=1
    scene_file_out="scenes/selected_scenes/stratus_2layers/scene.uff"
    scene_file_in="scenes/selected_scenes/stratus_4pt/stratus_4pt.xml"
    scene_dir="sessions/str_4pt"
fi
###########
if [ "$scene_fire" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  Scene FIRE '  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=0
#    scene_file_out="scenes/selected_scenes/fire/fire_scene.uff"
    scene_file_out="scenes/selected_scenes/fire/fire_scene.uff"
    scene_dir="sessions/fire"
fi
############
if [ "$scene_AS3_1" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene:  ASTEX3 1 B '  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=0
    scene_file_out="scenes/selected_scenes/ASTEX3_1_B/ASTEX3_1_B.uff"
    scene_dir="sessions/astex3_1_b"
fi
###########
if [ "$scene_AS3_2" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene: ASTEX3 2 B '  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=0
    scene_file_out="scenes/selected_scenes/ASTEX3_2_B/ASTEX3_2_B.uff"
    scene_dir="sessions/astex3_2_b"
fi
###########
if [ "$scene_AS3_3" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene: ASTEX3 3 B '  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=0
    scene_file_out="scenes/selected_scenes/ASTEX3_3_B/ASTEX3_3_B.uff"
    scene_dir="sessions/astex3_3_b"
fi
###########
if [ "$scene_AS3_4" -gt "0" ]
   then
    echo ' -------------------------------------------------------------------'
    echo ' Scene: ASTEX3 4 B '  
    echo ' -------------------------------------------------------------------'
    run_scene_creator=0
    scene_file_out="scenes/selected_scenes/ASTEX3_4_B/ASTEX3_4_B.uff"
    scene_dir="sessions/astex3_4_b"
fi
###########
# -----------------------------------
# Select which configuration you want to use for Radar and Lidar
# -----------------------------------

run_ARM_config=0
run_ground_config=0
run_DAVE_config_up=0     # ground view
run_DAVE_config_down=0   # satellite view
run_Satellite_config=1
#
#
#
################################### DAVE GROUND CONFIGURATION ##############
if [ "$run_DAVE_config_up" -gt "0" ] 
   then
   echo '--------------------------------------------------------------------------------'
   echo '------- setting configuration input files for DAVE GROUND parameters --------'
   echo '  '
   orbit_file_in="dave_upwards_xml_files/orbit_user_knmi_up.xml"     #this one is set up with Simo for ground observations
   rad_filter_config="dave_upwards_xml_files/rad_filter_config.xml"
   radar_config="dave_upwards_xml_files/radar_config_up.xml"   #proper Dave's for looking up, 32GHz
#   radar_config="dave_upwards_xml_files/radar_config_up_94GHz_TO.xml"   #proper Dave's for looking up, 94GHz T.O.
   lid_filter_config="models/dave_upwards_xml_files/lid_filter_config_up.xml"
#   lidar_config="models/dave_upwards_xml_files/lidar_config_up.xml"       # standard one
   lidar_config="models/dave_upwards_xml_files/lidar_config_up_dave_elastic.xml"       # elastic backscatter Dave 2012 March
   mkdir "$scene_dir/dave_"$time_sys_$1
   outdir="$scene_dir/dave_"$time_sys_$1 
#   orbit_file_out="$outdir/ecsim_orbit.xml"   #(for all default runs use this)
   orbit_file_out="dave_upwards_xml_files/orbit_user_knmi_up.xml"     #this one is set up with Simo for ground observations
#  orbit_file_out="dave_upwards_xml_files/orbit_user_knmi_up_wc_scene.xml"     #(specific to lid_l2k module testing for wc scene)
fi
#
################################### DAVE SATELLITE CONFIGURATION #############
if [ "$run_DAVE_config_down" -gt "0" ]
   then
   echo '--------------------------------------------------------------------------------'
   echo '------- setting configuration input files for DAVE SATELLITE parameters --------'
   echo '  '
   orbit_file_in="models/orbit_dms/conf/orbit_user_knmi_down.xml"     #this one is set up with Simo for satellite
   rad_filter_config="models/rad_filter/conf/rad_filter_config.xml"
   radar_config="models/dave_upwards_xml_files/radar_config_down.xml"   #Simo & Igor down
   lid_filter_config="models/lid_filter/conf/lid_filter_config.xml"
   lidar_config="models/lidar/conf/lidar_config.xml"
   mkdir "$scene_dir/dave_"$time_sys
   outdir="$scene_dir/dave_"$time_sys
   orbit_file_out="$outdir/ecsim_orbit.xml"
fi
#
################################ arm configuration ############################
if [ "$run_ARM_config" -gt "0" ] 
   then
   echo '--------------------------------------------------------------------------------'
   echo '------- setting configuration input files for ARM parameters --------'
   echo '  '
   orbit_file_in="models/upward/config_files/ecsim_orbit_ground_config.xml"
   rad_filter_config="models/upward/config_files/rad_filter_ARM_config.xml"
   radar_config="models/upward/config_files/radar_ARM_config.xml"
   lid_filter_config="models/upward/config_files/lid_filter_ARM_config.xml"
   lidar_config="models/upward/config_files/lidar_ARM_config.xml"
   mkdir "$scene_dir/arm_"$time_sys
   outdir="$scene_dir/arm_"$time_sys 
   orbit_file_out="$outdir/ecsim_orbit.xml"
fi
#
################################ ground configuration ############################
if [ "$run_ground_config" -gt "0" ] 
   then
   echo '--------------------------------------------------------------------------------'
   echo '------- setting configuration input files for generic ground parameters --------'
   echo '  '
   #orbit_file_in="models/orbit_dms/conf/ecsim_orbit_config_user.xml"
   #orbit_file_in="models/orbit_dms/conf/ecsim_orbit_config_up.xml"
   #orbit_file_in="models/upward/config_files/ecsim_orbit_ground_config.xml"       #looks fine, ig
   orbit_file_in="models/orbit_dms/conf/orbit_user_knmi_up.xml"       #Dave's version
   #rad_filter_config="models/upward/config_files/rad_filter_ground_config.xml"    #replacing this one with Dave's, igor
   rad_filter_config="models/upward/rad_filter_up/conf/rad_filter_config.xml"     #ig and Dave#########################
   #rad_filter_config="models/upward/rad_filter_up/conf/rad_filter_config_bckp_igor.xml"
   #radar_config="models/upward/config_files/radar_ground_config.xml"     #replacing this one with Dave's, Igor
   radar_config="models/upward/radar_up/conf/radar_config.xml"   # new Dave's radar module, after copying the whole folder "radar"
   #radar_config="models/upward/radar_up/conf/radar_config_bckp_igor.xml"
   #radar_config="models/radar/conf/radar_config.xml"
   #lid_filter_config="models/upward/config_files/lid_filter_ground_config.xml"
   #lid_filter_config="models/upward/lid_filter_up/conf/lid_filter_config.xml"     #Dave, Simo & Igor updated upwards module
   lid_filter_config="models/upward/lid_filter_up/conf/lid_filter_config_up_Dave2.xml"     #ig and Dave 2 #############
   #lid_filter_config="models/lid_filter/conf/lid_filter_config.xml"
   #lidar_config="models/upward/config_files/lidar_ground_config.xml" 
   #lidar_config="models/lidar/conf/lidar_config.xml"       # the old one, igor has replaced it
   lidar_config="models/upward/lidar_up/conf/lidar_config_up.xml"    #ig and Dave ###########################
   mkdir "$scene_dir/ground_"$time_sys
   outdir="$scene_dir/ground_"$time_sys
   orbit_file_out="$outdir/ecsim_orbit.xml"
fi
#
################## Satellite configuration #############################
if [ "$run_Satellite_config" -gt "0" ]
   then
   echo '--------------------------------------------------------------------------------'
   echo '------- setting configuration input files for Satellite parameters --------'
   echo '  '
#   orbit_file_in="models/orbit_dms/conf/ecsim_orbit_config.xml"    #ig
#   orbit_file_in="models/orbit_dms/conf/ecsim_orbit_config_igor_lw_rad_no_up_down.xml"    #ig
#   orbit_file_in="models/orbit_dms/conf/ecsim_orbit_config_igor_sw_rad_no_up_down_mc.xml"    #ig
   orbit_file_in="$scene_dir/orbit_config_igor_lw_rad_mc.xml"    #ig new for GRC conference
   rad_filter_config="models/rad_filter/conf/rad_filter_config.xml"    #ig
   radar_config="models/radar/conf/radar_config.xml"   #ig
   lid_filter_config="models/upward/config_files/lid_filter_ARM_config.xml"
   lidar_config="models/upward/config_files/lidar_ARM_config.xml"
   mkdir "$scene_dir/satellite_"$time_sys_$1
   outdir="$scene_dir/satellite_"$time_sys_$1
   orbit_file_out="$outdir/ecsim_orbit.xml"
fi
#

#outdir="test"
reference=0
##-------------------------
# What will be run ?
# Set to one to run 
# the appropriate 
# segment of the script
#--------------------------
#
run_scene_creator=0
run_extract_prop=0
run_orbit_dms=0
run_radar_block=0
run_lidar_block=0
run_radar_block_dave=0       # NEW DAVE CODE
run_lidar_block_dave=0        # NEW DAVE CODE
run_lidar_block_up_dave=0      # LATEST LIDAR UPWARDS L2K
run_lidar_radar_block=0
run_sw_rad_block=0            #igor add-on, 1.6.2012., use it 2013 too
run_lw_rad_block=1
run_msi_block=0
run_msi_l2a_block=0           #igor, use after GRC
run_merger_block=0
run_lid_mie_ray_ext_block=0
run_lw_msi_lid_rad_block=0
run_reconstuction_block=0
run_lw_orig_flux_block=0
run_sw_orig_flux_block=0
run_lw_recon_flux_block=0
run_sw_recon_flux_block=0
#----------------------------------
# Input and output files to use
#----------------------------------
#
# scene_creator_block 
# Here please set which input scene.xml file to use
#
#scene_file_in="scenes/not_used/standard_test_scene/standard_test_scene.xml"
#scene_file_in="scenes/selected_scenes/stratus_1re/stratus_1re.xml"
#scene_file_in="scenes/selected_scenes/stratus_2layers/stratus_2layers.xml"
#scene_file_in="scenes/selected_scenes/stratus_4pt/stratus_4pt.xml"

# Select the scene_file_out

#scene_file_out="scenes/selected_scenes/fire/fire_scene.uff"
#scene_file_out="scenes/selected_scenes/ASTEX3_1_B/ASTEX3_1_B.uff"
#scene_file_out="scenes/selected_scenes/ASTEX3_2_B/ASTEX3_2_B.uff"
#scene_file_out="scenes/selected_scenes/ASTEX3_3_B/ASTEX3_3_B.uff"
#scene_file_out="scenes/selected_scenes/ASTEX3_4_B/ASTEX3_4_B.uff"
#scene_file_out="$outdir/scene.uff"
#adjust_file="products/uff_adjust.xml"      #ig commented
adjust_file="$scene_dir/uff_adjust.xml"

env_file="$outdir/env_data.nc"
#
# Orbit block
#orbit_file_in="$user_orbit_file"
#orbit_file_out="$user_orbit_file_out"
#
# Radar block
#rad_filter_config="models/rad_filter/conf/rad_filter_config.xml"
rad_filter_output="$outdir/rad_filter_output.nc"
#rad_filter_output="$outdir/nan_rad_filter_output.nc"
#radar_config="models/radar/conf/radar_config.xml"
radar_output="$outdir/radar_output.nc"
rad_l2a_config="models/rad_l2a/conf/rad_l2a_config.xml"
rad_l2a_output="$outdir/rad_l2a_output.nc"
#
# Lidar block
#lid_filter_config="models/lid_filter/conf/lid_filter_config.xml"
lid_filter_output="$outdir/lid_filter_output.nc"
#lidar_config="models/lidar/conf/lidar_config.xml"
#lidar_config="models/TEST/lidar_config_nonoise.xml"
#lidar_config="models/TEST/lidar_config_nonoise_noms.xml"
lidar_output="$outdir/lidar_output.nc"
#lidar_output="$outdir/lidar_output_nonoise.nc"
#lidar_output="$outdir/lidar_output_nonoise_noms.nc"
lid_l2a_config="models/lid_l2a/conf/lid_l2a_config.xml"
lid_l2a_output="$outdir/lid_l2a_output.nc"
lid_l2k_output="$outdir/lid_l2k_output.nc"
#
# Lidar_Radar block
lid_rad_l2b_config="models/lid_rad_l2b/conf/lid_rad_l2b_config.xml"
lid_rad_l2b_output="$outdir/lid_rad_l2b_output.nc"
#
#
# LW_rad block
#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_mc.xml"
#lw_rad_output="$outdir/lw_mc_output_mc_all.nc"
#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_ica.xml"             # default, August 2013
#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_mc_channel_6.xml"              # only channel 6, at 19um
#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_mc_channel_6_and_added_channel_4um.xml"        # channel at 4 and 11um, like in van Zanten 2005
#
#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_mc_channel_6_and_added_channel_4um.xml"         # channel at 4 and 11um, like in van Zanten 2005. fixed
#lw_rad_output="$outdir/lw_output_mc_all.nc"
#lw_rad_output="$outdir/lw_ica_output_ica_all.nc"


#lw_rad_config="models/lw_rad/conf/lw_rad_config_msi_mc_added_13_4um_as_LW_69_and_LW_70.xml"         # channel at 13.33um (LW_69) and 13.69um (LW_70)
#lw_rad_output="$outdir/lw_output_mc_13_3_and_13_7um_as_LW_69_and_LW_70um.nc"


lw_rad_config="$scene_dir/lw_rad_config_msi_mc_added_13_4um_as_LW_69_and_LW_70.xml"         # channel at 13.33um (LW_69) and 13.69um (LW_70)
lw_rad_output="$outdir/lw_output_mc_13_3_and_13_7um_as_LW_69_and_LW_70um.nc"


# SW_rad block
#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_ica.xml"
#sw_rad_output="$outdir/sw_msi_output_ica_4_channels.nc"

#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc.xml"    #finished this one!
#sw_rad_output="$outdir/sw_msi_output_mc_4_channels.nc"


#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc_channel_1.xml"    # New! (June 18 2013), for variable SOLELEV angles and one channel
#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc_channel_4.xml"    # New! (June 18 2013), for variable SOLELEV angles and channel 4 (2.2um)
#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc.xml"    # 
#sw_rad_output="$outdir/sw_msi_output_mc_channel_4.nc"

# ECSIM v16:
#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc_660nm_only.xml"    # New! (June 18 2013), for variable SOLELEV angles and channel 4 (2.2um)
#sw_rad_output="$outdir/sw_msi_output_mc_660nm_only.nc"

sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_mc_660_865nm.xml"    # New! (June 18 2013), for variable SOLELEV angles and channel 4 (2.2um)
sw_rad_output="$outdir/sw_msi_output_mc_660_865nm.nc"

#sw_rad_config="models/sw_rad/conf/sw_rad_config_msi_ica_5_channels.xml"
#sw_rad_output="$outdir/sw_msi_output_ica_5_channels.nc"


#sw_rad_config="models/sw_rad/conf/sw_rad_config_bbr_mc.xml"
#sw_rad_output="$outdir/sw_msi_output_mc_bbr_channel.nc"

#sw_rad_config="models/sw_rad/conf/sw_rad_config_bbr_ica.xml"    # switched these 2 off 18 June 2013
#sw_rad_output="$outdir/sw_msi_output_ica_bbr_channel.nc"




#
# MSI block
msi_config="models/msi/conf/msi_ch_1.xml"
msi_output="$outdir/msi_output.nc"

# MSI_L2A block
msi_l2a_config="models/msi_l2a/conf/msi_l2a.xml"
msi_l2a_output="$outdir/msi_l2a_output.nc"

#
# Merger block
atlid_mask_config="models/A-FeatureMask-KNMI/conf/featuremask-atlid.xml"
atlid_mask_output="$outdir/atlid_mask.nc"
merger_config="models/merged_lid_rad_msi/conf/merged_lid_rad_msi_config.xml"
merger_output="$outdir/merger_output.nc"
#
#
# lid_mie_ray_ext block
lid_mie_ray_ext_config="models/lid_mie_ray_ext/conf/lid_mie_ray_ext.xml"
lid_mie_ray_ext_output="$outdir/lid_mie_ray_ext_output.nc"
#
# lw_msi_lid_rad_l2b_3d block 
lw_msi_lid_rad_l2b_3d_config="models/lw_msi_lid_rad_l2b_3d/conf/lw_msi_lid_rad_l2b_3d_config.xml"
lw_msi_lid_rad_l2b_3d_output="$outdir/recon_scene_config.xml"
#
# scene reconstruction block
recon_scene_file_in="$lw_msi_lid_rad_l2b_3d_output"
recon_scene_file_out="$outdir/reconstructed_scene.uff"
#
# Flux comparision block
#
sw_flux_bbr_config="models/sw_rad/conf/sw_rad_config_bbr_mc.xml"
sw_flux_bbr_orig_out="$outdir/sw_rad_flux_bbr_orig.nc"
sw_flux_bbr_recon_out="$outdir/sw_rad_flux_bbr_recon.nc"
#
lw_bbr_config="models/lw_rad/conf/lw_rad_config_bbr_mc.xml"
lw_bbr_orig_out="$outdir/lw_rad_bbr_orig.nc"
lw_bbr_recon_out="$outdir/lw_rad_bbr_recon.nc"
#
lw_flux_config="models/lw_rad/conf/lw_rad_config_toa_flux_mc.xml"
lw_flux_orig_out="$outdir/lw_rad_flux_orig.nc"
lw_flux_recon_out="$outdir/lw_rad_flux_recon.nc"
#
###############################Scene creation block ###########################
if [ "$run_scene_creator" -gt "0" ] 
   then
   echo '------- run scene creator --------'
   models/scene_creator/bin/scene_creator_xml $scene_file_in $scene_file_out
#
fi
# ------------ Extract some quantities ---------------------------
#
if [ "$run_extract_prop" -gt "0" ] 
   then
   echo '-------run extract_env------------'
   tools/product_tools/bin/extract_env $scene_file_out $env_file -5.0 15.0 -5.0 15.0 1.0 0.0 100.0 0.1 
#  
# 
#
    echo "----------- extract 2d ideal reflectivity --"
    tools/product_tools/bin/extract_quantity $scene_file_out \
	$outdir/ideal_Ze.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 100 0
#
# Plot the ideal reflectivity
#
    echo "----------- plot 2d ideal reflectivity --"
    tools/pgplot_tools/bin/plot_slice  $outdir/ideal_Ze.nc \
	Unattenuated_Reflectivity_94_GHz 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 $outdir/ze_ideal.ps/vcps
	
	rm -f $outdir/ideal_Ze.nc

        echo "----------- extract 2d extinction --"
     tools/product_tools/bin/extract_quantity $scene_file_out \
 	$outdir/ext.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 13 0
#
        echo "----------- plot 2d extinction --"
#
     tools/pgplot_tools/bin/plot_slice  $outdir/ext.nc \
 	Extinction 0.0 10.0 0.0 14.0 1.0e-6 1.0e-2 1 $outdir/ext.ps/vcps
#	
	rm -f $outdir/ext.nc
#
        echo "----------- extract mass content--"
     tools/product_tools/bin/extract_quantity $scene_file_out \
 	$outdir/mass.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 10 0
#
        echo "----------- plot 2d mass content --"
#
     tools/pgplot_tools/bin/plot_slice  $outdir/mass.nc \
 	Mass_content 0.0 10.0 0.0 14.0 1 1 1 $outdir/mass.ps/vcps
#	
	rm -f $outdir/mass.nc
#
	echo "----------- extract reff content--"
     tools/product_tools/bin/extract_quantity $scene_file_out \
 	$outdir/reff.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 11 0
#
        echo "----------- plot 2d reff content --"
#
     tools/pgplot_tools/bin/plot_slice  $outdir/reff.nc \
 	R_eff 0.0 10.0 0.0 14.0 1 1 1 $outdir/reff.ps/vcps
#	
	rm -f $outdir/reff.nc
#        echo "----------- extract 2d backscatetr --"
#     tools/product_tools/bin/extract_quantity $scene_file_out \
# 	$outdir/beta.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 15 0
#
#        echo "----------- plot 2d backscatter --"
#
#     tools/pgplot_tools/bin/plot_slice  $outdir/beta.nc \
# 	Backscatter 0.0 10.0 0.0 14.0 1.0e-7 1.0e-3 1 $outdir/beta.ps/vcps
#
#        echo "extract 2d adb ----------------"
#     tools/product_tools/bin/extract_quantity $scene_file_out \
# 	$outdir/adb.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 14 0
#
#     echo "plot 2d extinction backscatter ratio"
#     tools/pgplot_tools/bin/plot_slice  $outdir/adb.nc \
#	Extinction_Backscatter_ratio 0.0 10.0 0.0 14.0 10.0 40.0 0 $outdir/adb.ps/vcps
#
#
#   Plot the extinction and the adb profile
#
#     echo "plot extinction profile"
#
#     tools/pgplot_tools/bin/plot_profile \
#	 $outdir/ext.nc,'Extinction','Extinction[1/m]',1,1,5 \
#         6.0 0.0 14.0 1.0e-4 0.02 1 0.35 0.4 0.8 \
#         $outdir/extinction_profile.ps/vcps
#
#     echo "plot adb profile"
#
#     tools/pgplot_tools/bin/plot_profile \
#	 $outdir/adb.nc,'Extinction_Backscatter_ratio','alpha/beta',1,1,5 \
#         6.0 0.0 14.0 0.0 50.0 0 0.35 0.4 0.8 \
#         $outdir/adb_profile.ps/vcps
#
    echo "----------- extract 3d extinction --"
    tools/product_tools/bin/extract_quantity_3d $scene_file_out $outdir/ext_vol.nc 0.0 10.0 0.0 10.0 0.0 14.0 0.1 13 0   
#
# Plot a 3D plot of Extinction with 2D slice
#
    echo "----------- plot 3d ideal reflectivity --"
    tools/pgplot_tools/bin/plot_3d $outdir/ext_vol.nc Extinction 0.0 10.0 0.0 10.0 0 13.995 0.8 1.0e-5 1.0e-1 1 0.02 1 $outdir/ext_3d.ps/vcps        
#
	rm -f $outdir/ext_vol.nc
# Extract the visable optical depth
#
#    echo "--------extract the optical depth---------"
   # tools/product_tools/bin/extract_quantity_hor $scene_file_out $outdir/scene_tau.nc 13 0
#
#   echo "-----------plot the optical depth-----------"
#   tools/pgplot_tools/bin/plot_hor $outdir/scene_tau.nc optical_depth_353 0.0 10.0 0.0 10.0 0.0 10.0 0 $outdir/scene_tau.ps/vcps
#	
#	rm -f $outdir/scene_tau.nc
# Extract the effective radius
#
 #   echo "--------extract the scene effective radius---------"
  #  tools/product_tools/bin/extract_quantity_hor $scene_file_out $outdir/scene_reff.nc 11 0
#
  # echo "-----------plot the scene effective radius -----------"
   #tools/pgplot_tools/bin/plot_hor $outdir/scene_reff.nc reff 0.0 10.0 0.0 10.0 0.0 0.0 2 $outdir/scene_reff.ps/vcps
#	
   	# rm -f $outdir/scene_reff.nc
fi





################################ORBIT DMS BLOCK###############################
if [ "$run_orbit_dms" -gt "0" ]
   then
   echo '------- run orbit dms --------'
   models/orbit_dms/bin/orbit_dms  $orbit_file_in $scene_file_out $orbit_file_out
fi
################################RADAR BLOCK DAVE###############################
if [ "$run_radar_block_dave" -gt "0" ]
then
#
# Run rad_filter
#
    echo '------- run rad_filter_dave -------'
   models/rad_filter/bin/rad_filter $rad_filter_config $orbit_file_in,$adjust_file,$scene_file_out $rad_filter_output
     #models/rad_filter/bin/rad_filter $rad_filter_config $orbit_file_out,$adjust_file,$scene_file_out $rad_filter_output
     # models/rad_filter/bin/rad_filter $rad_filter_config $orbit_file_in,$adjust_file,$scene_file_out $rad_filter_output

#
# Run radar up
#
    echo "----------- run radar_dave --"
    models/radar/bin/radar $radar_config $orbit_file_in,$rad_filter_output $radar_output
        #models/radar/bin/radar $radar_config $orbit_file_out,$rad_filter_output $radar_output
# Plot the result of radar
#
    echo "----------- plot radar_dave --------"
    tools/pgplot_tools/bin/plot_slice $radar_output \
    CPR_Reflectivity 0.0 25.6 0.0 3.0 1.0e-4 1.0 2 $outdir/cpr_z.ps/vcps

#    tools/pgplot_tools/bin/plot_slice $radar_output \
#    Doppler_Velocity 0.0 10.0 0.0 14.0 -0.5 2.0 0 $outdir/Dop_test_instrument.ps/vcps

#
# Run Rad_l2a
#
    echo "----------- run rad_l2a dave --------"
    models/rad_l2a/bin/rad_l2a $rad_l2a_config $orbit_file_in,$radar_output  $rad_l2a_output
#
# Plot the results of rad_l2a
#
#    echo "--------plotting------------"
#    tools/pgplot_tools/bin/plot_slice $rad_l2a_output Radar_cloud_mask 0.0 10.0 0.0 14.0 -1.0 2.0 0 \
#       $outdir/rad_l2a_cld_mask.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $rad_l2a_output IWC 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 \
#       $outdir/rad_l2a_iwc.ps/vcps
#
fi

################################ LIDAR BLOCK DAVE  ###############################
#
if [ "$run_lidar_block_dave" -gt "0" ]
    then
#
    echo '------- run lid_filter_dave -------'
    models/lid_filter/bin/lid_filter $lid_filter_config $orbit_file_in,$adjust_file,$scene_file_out $lid_filter_output

#    lid_filter_out="/home/simone/ECSIM/test/dave_20090219161753/lid_filter_output.nc"
#    orbit_file_out="/home/simone/ECSIM/test/dave_20090219161753/ecsim_orbit.xml"
#    lidar_config="/home/simone/ECSIM/models/lidar/conf/lidar_config.xml"
#    lidar_output="/home/simone/ECSIM/test/dave_20090219161753/lidar_output.nc"
#    lid_l2a_output="/home/simone/ECSIM/test/dave_20090219161753/lid_l2a_output.nc"
#   
    echo '------- run lidar_dave -------'
    models/lidar/bin/lidar $lidar_config $orbit_file_in,$lid_filter_output $lidar_output

#    echo '---- run lid_l2a_up -------'
#    models/lid_l2a/bin/lid_l2a $lid_l2a_config $orbit_file_in,$lidar_output $lid_l2a_output


fi


################################RADAR BLOCK UPWARD###############################
if [ "$run_radar_block" -gt "0" ] 
then
#
# Run rad_filter
#
    echo '------- run rad_filter_up -------'
    models/upward/rad_filter_up/bin/rad_filter_up $rad_filter_config $orbit_file_in,$adjust_file,$scene_file_out $rad_filter_output
     #models/rad_filter/bin/rad_filter $rad_filter_config $orbit_file_out,$adjust_file,$scene_file_out $rad_filter_output
#
# Run radar up
#
    echo "----------- run radar_up --"
    models/upward/radar_up/bin/radar_up $radar_config $orbit_file_in,$rad_filter_output $radar_output
	#models/radar/bin/radar $radar_config $orbit_file_out,$rad_filter_output $radar_output
# Plot the result of radar
#
    echo "----------- plot radar_up --------"
    tools/pgplot_tools/bin/plot_slice $radar_output \
    CPR_Reflectivity 0.0 25.6 0.0 2.8 1.0e-4 1.0 2 $outdir/cpr_z.ps/vcps

#    tools/pgplot_tools/bin/plot_slice $radar_output \
#    Doppler_Velocity 0.0 10.0 0.0 14.0 -0.5 2.0 0 $outdir/Dop_test_instrument.ps/vcps

#
# Run Rad_l2a
#
#    echo "----------- run rad_l2a_up --------"
#    models/upward/rad_l2a_up/bin/rad_l2a_up $rad_l2a_config $orbit_file_out,$radar_output  $rad_l2a_output
#
# Plot the results of rad_l2a
#
#    echo "--------plotting------------"
#    tools/pgplot_tools/bin/plot_slice $rad_l2a_output Radar_cloud_mask 0.0 10.0 0.0 14.0 -1.0 2.0 0 \
# 	$outdir/rad_l2a_cld_mask.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $rad_l2a_output IWC 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 \
# 	$outdir/rad_l2a_iwc.ps/vcps
#
fi
#
################################LIDAR BLOCK  UPWARD  ###############################
#
if [ "$run_lidar_block" -gt "0" ] 
    then
#
    echo '------- run lid_filter_up -------'
   models/upward/lid_filter_up/bin/lid_filter_up $lid_filter_config $orbit_file_in,$adjust_file,$scene_file_out $lid_filter_output

#    lid_filter_out="/home/simone/ECSIM/test/dave_20090219161753/lid_filter_output.nc"
#    orbit_file_out="/home/simone/ECSIM/test/dave_20090219161753/ecsim_orbit.xml"
#    lidar_config="/home/simone/ECSIM/models/lidar/conf/lidar_config.xml"
#    lidar_output="/home/simone/ECSIM/test/dave_20090219161753/lidar_output.nc"
#    lid_l2a_output="/home/simone/ECSIM/test/dave_20090219161753/lid_l2a_output.nc"
#   
    echo '------- run lidar_up -------'
    models/upward/lidar_up/bin/lidar_up $lidar_config $orbit_file_in,$lid_filter_output $lidar_output
#
#    echo '---- plotting -------'
#     tools/pgplot_tools/bin/plot_slice $lidar_output Mie_co_polar\(ch1\) 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/ch1.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $lidar_output Cross_polar\(ch3\) 0.0 10.0 0.0 14.0 0.01 10.0 1 $outdir/ch3.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $lidar_output Mie_para 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/Mie_para.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $lidar_output Mie_para_err 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/Mie_para_err.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $lidar_output Rayleigh_co_polar\(ch2\) 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/ch2.ps/vcps
#     tools/pgplot_tools/bin/plot_slice $lidar_output Ray_para 0.0 10.0 0.0 14.0 0.1 1000.0 1 $outdir/Ray_para.ps/vcps
#
#     tools/pgplot_tools/bin/plot_profile \
#	 "$lidar_output",'Mie_para','Mie Para corr',2,3,5,"$lidar_output",'Ray_para','Co-Polar Ray corr',1,1,4,"$lidar_output",Mie_co_polar\(ch1\),'Mie Para',3,3,5,"$lidar_output",Rayleigh_co_polar\(ch2\),'Co-Polar Ray',4,1,4 \
#         10.0 0.0 14.0 0.1 1.0e+2 1 0.35 0.4 0.8 \
#         $outdir/lidar_x_talk_removed.ps/vcps
#
 
    echo '---- run lid_l2a_up -------'
#    models/upward/lid_l2a_up/bin/lid_l2a $lid_l2a_config $orbit_file_out,$lidar_output $lid_l2a_output
#
    echo '---- plotting -------'
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Extinction_3 0.0 10.0 0.0 14.0 1.0e-6 1.0e-2 1 $outdir/extinction_3.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Apparent_extinction_1 0.0 10.0 0.0 14.0 1.0e-5 1.0 1 $outdir/extinction_1.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Cloud_mask 0.0 10.0 0.0 14.0 -1.0 2.0 0 $outdir/lid_cld_mask.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Depol_ratio 0.0 10.0 0.0 14.0 0.0 1.0 0 $outdir/lid_depol_ratio.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Mie_backscatter_ratio_1 0.0 10.0 0.0 14.0 0.9 20.0 0 $outdir/lid_backscatter_ratio.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output d_Mie_backscatter_ratio_1 0.0 10.0 0.0 14.0 0.9 20.0 0 $outdir/d_lid_backscatter_ratio.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Signal_mie_para 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/lid_l2a_mie.ps/vcps
     tools/pgplot_tools/bin/plot_slice  $lid_l2a_output Signal_ray_para 0.0 10.0 0.0 14.0 0.0 50.0 0 $outdir/lid_l2a_ray.ps/vcps
#
#tools/pgplot_tools/bin/plot_profile \
##$lid_l2a_output,'Signal_mie_para','Mie',1,1,4,\
##$lid_l2a_output,'Signal_ray_para','Rayleigh',2,1,4 \
#7.5 0.0 14.0 0.1 1.0e+2 1 0.57 0.4 1.1 $outdir/lid_2d_sig_profile.ps/vcps  
# 
fi
#
################################  LIDAR BLOCK UPWARD L2K DAVE  ###############################
#
if [ "$run_lidar_block_up_dave" -gt "0" ]
    then
#
    echo '---------------------------------'
    echo '------- run lid_filter_up -------'
    echo '---------------------------------'
   models/lid_filter/bin/lid_filter $lid_filter_config $orbit_file_in,$adjust_file,$scene_file_out $lid_filter_output

#    lid_filter_out="/home/simone/ECSIM/test/dave_20090219161753/lid_filter_output.nc"
#    orbit_file_out="/home/simone/ECSIM/test/dave_20090219161753/ecsim_orbit.xml"
#    lidar_config="/home/simone/ECSIM/models/lidar/conf/lidar_config.xml"
   lidar_out="$outdir/lidar_output.nc"
#    lid_l2a_output="/home/simone/ECSIM/test/dave_20090219161753/lid_l2a_output.nc"
#   
    echo '----------------------------'
    echo '------- run lidar_up -------'
    echo '----------------------------'
#    models/lidar/bin/lidar $lidar_config $orbit_file_in,$lid_filter_output $lidar_output
     models/lidar/bin/lidar $lidar_config $orbit_file_in,$lid_filter_output $outdir/lidar_output.nc
    
    echo '---------------------------'
    echo '---- run lid_L2K_up -------'
    echo '---------------------------'
#    models/lid_L2K/bin/lid_l2k $lid_l2k_config $orbit_file_out,$lidar_output $lid_l2k_output  #default, needs to be adapted
     models/lid_L2K/bin/lid_l2k models/lid_L2K/conf/lid_l2k_config.xml $orbit_file_out,$lidar_output $lid_l2k_output


#
fi
#
############################### Lidar+Radar BLOCK UPWARD #################################
#
if [ "$run_lidar_radar_block" -gt "0" ] 
    then
#
    echo '---- run lid_rad_l2b_up -------'
    models/upward/lid_rad_l2b_up/bin/lid_rad_l2b_up $lid_rad_l2b_config $orbit_file_out,$lid_l2a_output,$rad_l2a_output $lid_rad_l2b_output
#
     echo '-----------plotting-rpeff-------------'
     tools/pgplot_tools/bin/plot_slice $lid_rad_l2b_output Rpeff 0.0 10.0 0.0 14.0 0.0 200.0 0 $outdir/lidar_radar_rpeff.ps/vcps

      echo '-----------plotting-lid_rad cld mask-------------'
     tools/pgplot_tools/bin/plot_slice $lid_rad_l2b_output Lidar_radar_cloud_mask 0.0 10.0 0.0 14.0 -1.0 2.0 0 \
 	$outdir/lidar_radar_cld_mask.ps/vcps

     echo '-----------plotting-masked extinction-------------'
     tools/pgplot_tools/bin/plot_slice $lid_rad_l2b_output Extinction_4 0.0 10.0 0.0 14.0 1.0e-5 1.0 1 \
 	$outdir/lidar_radar_extinction.ps/vcps

     echo '-----------plotting-Ze-------------'
     tools/pgplot_tools/bin/plot_slice $lid_rad_l2b_output Ze 0.0 10.0 0.0 14.0 1.0e-3 1.0e-1 1 \
 	$outdir/lidar_radar_ze.ps/vcps
#
fi
###############################LW_MSI BLOCK######################################
#
if [ "$run_lw_rad_block" -gt "0" ] 
then
#====================================
# First run a the code for a msi
# configuration in MC mode
# do not use many photons per column
# low SNR but quick
#=====================================
# 
    echo '---- run lw_rad in mc mode -------'
#    ../lw_rad/bin/lw_rad $lw_rad_config $orbit_file,$adjust_file,$scene_file_out $lw_rad_output
#   models/lw_rad/bin/lw_rad $lw_rad_config $orbit_file_in,$adjust_file,$scene_file_out $lw_rad_output

   $scene_dir/bin/lw_rad $lw_rad_config $orbit_file_in,$adjust_file,$scene_file_out $lw_rad_output


#
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_5_8.85_um_BT_0180  0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch5.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_5_8.85_um_BT_0180  0.0 10.0 -5.0 5.0 220.0 290.0 0 $outdir/bt_mc_ch5_old.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_6_10.85_um_BT_0180 0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch6.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_7_11.85_um_BT_0180 0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch7.ps/vcps
#
fi
###############################SW_MSI BLOCK######################################
#
if [ "$run_sw_rad_block" -gt "0" ] 
then
#====================================
# First run a the code for a msi
# configuration in MC mode
# do not use many photons per column
# low SNR but quick
#=====================================
# 
    echo '---- run lw_rad in ica or mc mode -------'
#    ../lw_rad/bin/lw_rad $lw_rad_config $orbit_file,$adjust_file,$scene_file_out $lw_rad_output
   models/sw_rad/bin/sw_rad $sw_rad_config $orbit_file_in,$adjust_file,$scene_file_out $sw_rad_output

#
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_5_8.85_um_BT_0180  0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch5.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_5_8.85_um_BT_0180  0.0 10.0 -5.0 5.0 220.0 290.0 0 $outdir/bt_mc_ch5_old.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_6_10.85_um_BT_0180 0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch6.ps/vcps
#    ../../tools/pgplot_tools/bin/plot_hor $lw_rad_output MSI_7_11.85_um_BT_0180 0.0 10.0 -5.0 5.0 240.0 300.0 0 $outdir/bt_mc_ch7.ps/vcps
#
fi
################################msi#################################################
if [ "$run_msi_block" -gt "0" ] 
    then
    echo '------run msi --------'
    models/msi/bin/msi $msi_config $orbit_file,$sw_rad_output $msi_output
#
#     ../../tools/pgplot_tools/bin/plot_hor $msi_output MSI_5_8.85_um_BT_0180 0.0 10.0 -5.0 5.0 220.0 290.0 0 $outdir/bt_mc_ch5_wn.ps/vcps
#     ../../tools/pgplot_tools/bin/plot_hor $msi_output MSI_6_10.85_um_BT_0180 0.0 10.0 -5.0 5.0 220.0 290.0 0 $outdir/bt_mc_ch6_wn.ps/vcps
#     ../../tools/pgplot_tools/bin/plot_hor $msi_output MSI_7_11.85_um_BT_0180 0.0 10.0 -5.0 5.0 220.0 290.0 0 $outdir/bt_mc_ch7_wn.ps/vcps
#
fi
#
############################## MSI_L2 ############################################  Igor, 26.07.2013
if [ "$run_msi_l2a_block" -gt "0" ]
    then
    echo '------- msi_l2a -------'   
    
    models/msi_l2a/bin/msi_l2a $msi_l2a_config $sw_rad_output $msi_l2a_output
#    models/msi_l2a/bin/msi_l2a $msi_l2a_config /ECSIM/sessions/chess_board_vert_hom_reff_full_no_clear_sky_PP/satellite_lw_rad_MC_chess_board_scene_full_no_clear_sky_PP_1_3_to_1_6km_solelev_55/lw_output_mc_all.nc $msi_l2a_output

fi    
##############################MERGER BLOCK #################################
if [ "$run_merger_block" -gt "0" ] 
    then
#
    echo '------run atlid featuremask block --------'
    ../A-FeatureMask-KNMI/bin/a-featuremask $atlid_mask_config $lidar_output $atlid_mask_output
    ../../tools/pgplot_tools/bin/plot_slice  $atlid_mask_output Featuremask 0.0 10.0 0.0 14.0 -1.0 10.0 0 $outdir/Featuremask.ps/vcps
#
    echo '------run merger --------'
    ../merged_lid_rad_msi/bin/merged_lid_rad_msi $merger_config $orbit_file,$env_file,$lidar_output,$radar_output,null,$lw_rad_output,$atlid_mask_output $merger_output
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output cloud_mask_lid 0.0 10.0 0.0 14.0 -1.0 2.0 0 $outdir/merger_lid_mask.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output aerosol_mask 0.0 10.0 0.0 14.0 0.0 2.0 0 $outdir/aerosol_mask.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output cloud_mask_rad 0.0 10.0 0.0 14.0 -1.0 2.0 0 $outdir/merger_rad_mask.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output cloud_mask_lid_rad 0.0 10.0 0.0 14.0 -1.0 2.0 0 $outdir/merger_lid_rad_mask.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Ze 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 $outdir/ze_merged.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Ze_err 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 $outdir/d_ze_merged.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Vd 0.0 10.0 0.0 14.0 -0.5 1.0 0 $outdir/Vd_merged.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Vd_err 0.0 10.0 0.0 14.0 -0.5 1.0 0 $outdir/d_Vd_merged.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Mie_para 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/merged_Mie_para.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Ray_para 0.0 10.0 0.0 14.0 0.1 100.0 1 $outdir/merged_Ray_para.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Lidar_FM_coverage 0.0 10.0 0.0 14.0 0.0 1.0 0 $outdir/Lidar_FM_coverage.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $merger_output Lidar_FM_average 0.0 10.0 0.0 14.0 -1.0 10.0 0 $outdir/Lidar_FM_average.ps/vcps
fi
#
##############################lid_mie_ray_ext BLOCK #################################

if [ "$run_lid_mie_ray_ext_block" -gt "0" ]
    then
    
    echo '-------------run casper ext lid only--------------'
    ../lid_mie_ray_ext/bin/lid_mie_ray_ext $lid_mie_ray_ext_config $orbit_file,$merger_output $lid_mie_ray_ext_output
    #
    ../../tools/pgplot_tools/bin/plot_slice  $lid_mie_ray_ext_output 'Extinction' 0.0 10.0 0.0 14.0 1.0e-6 10.0e-3 1 $outdir/extinction_ao.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $lid_mie_ray_ext_output 'Backscatter' 0.0 10.0 0.0 14.0 1.0e-7 10.0e-4 1 $outdir/Backscatter_ao.ps/vcps
    ../../tools/pgplot_tools/bin/plot_slice  $lid_mie_ray_ext_output 'S' 0.0 10.0 0.0 14.0 0.0 100.0 0 $outdir/S_ao.ps/vcps
fi
#
##############################lw_msi_lid_rad_l2b_3d BLOCK #################################
#
if [ "$run_lw_msi_lid_rad_block" -gt "0" ]
    then
    echo '---------run lw_msi_lid_rad_l2b_3d------'
    ../lw_msi_lid_rad_l2b_3d/bin/lw_msi_lid_rad_l2b_3d $lw_msi_lid_rad_l2b_3d_config \
	$orbit_file,$scene_file_out,$lid_l2a_output,$lid_rad_l2b_output,$lw_rad_output \
	$lw_msi_lid_rad_l2b_3d_output
#
fi
#
###############################Run scene creator to reconstruct the scene####################
#
if [ "$run_reconstuction_block" -gt "0" ]
    then
#
    ../scene_creator/bin/scene_creator_xml $recon_scene_file_in $recon_scene_file_out
# Extract some quantities
# 
#
    echo "----------- extract 2d ideal reflectivity --"
     ../../tools/product_tools/bin/extract_quantity $recon_scene_file_out \
 	$outdir/ideal_Ze_reconstructed.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 100 0
#
# Plot the ideal reflectivity
#
    echo "----------- plot 2d ideal reflectivity --"
     ../../tools/pgplot_tools/bin/plot_slice  $outdir/ideal_Ze_reconstructed.nc \
 	Unattenuated_Reflectivity_94_GHz 0.0 10.0 0.0 14.0 1.0e-4 1.0 1 $outdir/ze_ideal_reconstructed.ps/vcps
#
        echo "----------- extract 2d extinction --"
     ../../tools/product_tools/bin/extract_quantity $recon_scene_file_out \
 	$outdir/ext_reconstructed.nc 0.0 5.0 10.0 5.0 0.0 14.0 0.1 13 0
#
        echo "----------- plot 2d extinction --"
#
     ../../tools/pgplot_tools/bin/plot_slice  $outdir/ext_reconstructed.nc \
 	Extinction 0.0 10.0 0.0 14.0 1.0e-5 1.0 1 $outdir/ext_reconstructed.ps/vcps
#
    echo "----------- extract 3d extinction --"
     ../../tools/product_tools/bin/extract_quantity_3d $recon_scene_file_out $outdir/reconstructed_ext_vol.nc 0.0 10.0 0.0 10.0 0.0 14.0 0.1 13 0   
 #
# Plot a 3D plot of Extinction with 2D slice
#
    echo "----------- plot 3d ideal reflectivity --"
    ../../tools/pgplot_tools/bin/plot_3d $outdir/reconstructed_ext_vol.nc Extinction 0.0 10.0 0.0 10.00 0 13.995 0.8 1.0e-5 1.0e-1 1 0.005 1 $outdir/ext_3d_reconstructed.ps/vcps        

    echo "--------extract the optical depth---------"
    ../../tools/product_tools/bin/extract_quantity_hor $recon_scene_file_out $outdir/recon_scene_tau.nc 13 0
#
   echo "-----------plot the optical depth-----------"
   ../../tools/pgplot_tools/bin/plot_hor $outdir/recon_scene_tau.nc optical_depth_353 0.0 10.0 0.0 10.0 0.0 10.0 0 $outdir/recon_scene_tau.ps/vcps
 
#
# Echo finished 
#
    if [ "$reference" -eq "1" ] 
	then
#
	cp *.ps reference
	cp reconstructed_ext_vol.nc reference
#
    fi
#
    ncdump reconstructed_ext_vol.nc > reconstructed_ext_vol.cdf
    ncdump reference/reconstructed_ext_vol.nc > reference_reconstructed_ext_vol.cdf
#
    diff reconstructed_ext_vol.cdf reference_reconstructed_ext_vol.cdf > ext_vol.diff
    line_count=$(wc -l < "ext_vol.diff")
#
#
    if [ "$line_count" -gt "4" ] 
	then
	echo "TEST FAILED !! (Examine ext_vol.diff)"
    else
	echo "TEST PASSED !!"
    fi
#
fi
#
#####################
# FLUX COMPARISON !
##################### 
#
#
if [ "$run_lw_recon_flux_block" -gt "0" ]
    then
    echo "--------------running lw_rad to produce bbr BBR radiancs for input scene---------"
    ../lw_rad/bin/lw_rad $lw_bbr_config $orbit_file,$adjust_file,$recon_scene_file_out $lw_bbr_recon_out
#
    echo "--------------running lw_rad to produce TOA Flux for input scene---------"
    ../lw_rad/bin/lw_rad $lw_flux_config $orbit_file,$adjust_file,$recon_scene_file_out $lw_flux_recon_out
#
fi
#
if [ "$run_sw_recon_flux_block" -gt "0" ]
    then
    #
    echo "--------------running sw_rad to produce TOA Flux and BBR radiances for input scene---------"
    ../sw_rad/bin/sw_rad $sw_flux_bbr_config $orbit_file,$adjust_file,$recon_scene_file_out $sw_flux_bbr_recon_out
    #
fi
#
#
#
#
if [ "$run_lw_orig_flux_block" -gt "0" ]
    then
    echo "--------------running lw_rad to produce bbr BBR radiancs for input scene---------"
#    ../lw_rad/bin/lw_rad $lw_bbr_config $orbit_file,$adjust_file,$scene_file_out $lw_bbr_orig_out
    /home/igor/ECSIM/models/lw_rad/bin/lw_rad $lw_bbr_config $orbit_file,$adjust_file,$scene_file_out $lw_bbr_orig_out
#
    echo "--------------running lw_rad to produce TOA Flux for input scene---------"
#    ../lw_rad/bin/lw_rad $lw_flux_config $orbit_file,$adjust_file,$scene_file_out $lw_flux_orig_out
    /home/igor/ECSIM/models/lw_rad/bin/lw_rad $lw_flux_config $orbit_file,$adjust_file,$scene_file_out $lw_flux_orig_out
#
fi
#
if [ "$run_sw_orig_flux_block" -gt "0" ]
    then
    #
    echo "--------------running sw_rad to produce TOA Flux and BBR radiancers for input scene---------"
#    ../sw_rad/bin/sw_rad $sw_flux_bbr_config $orbit_file,$adjust_file,$scene_file_out $sw_flux_bbr_orig_out
    /home/igor/ECSIM/models/sw_rad/bin/sw_rad $sw_flux_bbr_config $orbit_file,$adjust_file,$scene_file_out $sw_flux_bbr_orig_out
    #
fi
#
# PRINT OUT RESULTS
#    
#ncdump ../../$lw_bbr_orig_out > lw_bbr_orig_out.cdf
#ncdump ../../$lw_flux_orig_out > lw_flux_orig_out.cdf
#ncdump ../../$sw_flux_bbr_orig_out > sw_flux_bbr_orig_out.cdf
#
#sed -n '/LW_4.0-400.0_um_ave_Radiance/{p}' lw_bbr_orig_out.cdf > temp1
#sed -n '/LW_4.0-400.0_um_ave_flux/{p}' lw_flux_orig_out.cdf > temp2
#sed -n '/SW_0.2-4.0_um_toa_albedo/{n;p}'  sw_flux_bbr_orig_out.cdf > temp3
#sed -n '/brdf_ave/{n;p;n;p;n;p}'  sw_flux_bbr_orig_out.cdf > temp4
#
echo '============================================================================================='
#echo '| original scene LW Radiances'
#tail -1 temp1
#echo '-----------------------------------------------------------------------'
#echo '| original scene LW TOA Flux'
#tail -1 temp2
#echo '-----------------------------------------------------------------------'
#echo '| original scene SW BRDF'
#tail -3 temp4
#echo '-----------------------------------------------------------------------'
#echo '| original scene SW Albedo'
#tail -2 temp3 | head -1
#
#
#
#    
#ncdump ../../$lw_bbr_recon_out > lw_bbr_recon_out.cdf
#ncdump ../../$lw_flux_recon_out > lw_flux_recon_out.cdf
#ncdump ../../$sw_flux_bbr_recon_out > sw_flux_bbr_recon_out.cdf
#
#sed -n '/LW_4.0-400.0_um_ave_Radiance/{p}' lw_bbr_recon_out.cdf > temp1
#sed -n '/LW_4.0-400.0_um_ave_flux/{p}' lw_flux_recon_out.cdf > temp2
#sed -n '/SW_0.2-4.0_um_toa_albedo/{n;p}'  sw_flux_bbr_recon_out.cdf > temp3
#sed -n '/brdf_ave/{n;p;n;p;n;p}'  sw_flux_bbr_recon_out.cdf > temp4
#
echo '============================================================================================='
#echo '| reconstructed scene LW Radiances'
#tail -1 temp1
#echo '-----------------------------------------------------------------------'
#echo '| reconstructed scene LW TOA Flux'
#tail -1 temp2
#echo '-----------------------------------------------------------------------'
#echo '| reconstructed scene SW Radiances'
#tail -3 temp4
#echo '-----------------------------------------------------------------------'
#echo '| reconstructed scene SW Albedo'
#tail -2 temp3 | head -1
#
echo '--------- CHECK THE OUTPUT FILES IN '$ECSIM_HOME$outdir ' ---------------------------'
echo '---------------------------------------------------------------------------------------------'
echo '-------------------------THE END-------------------------------------------------------------'

