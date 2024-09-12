
cls
** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name			BNRDeathData_merge_2022.do
    //  project:				Mergeing BNR Death datasets
    //  analysts:				Kern ROCKE
    // 	date last modified:	    10-SEPT-2024
    //  algorithm task:			To merge 2022 death data with 2008-2021 death data in redcap		

    ** General algorithm set-up
    version 17
    clear all
	frames reset
    macro drop _all
    set more 1
    set linesize 80

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted folder
    local datapath "/Users/kernrocke/Downloads"

*Run redcap do file for inital data cleaning	
do "`datapath'/BNRDeathData2022_STATA_2024-03-01_0844.do"

*Check to see death data year
tab dodyear

*Adjust coding to be 2 digits for codes less than 10
gen ddda_new = ddda
tostring ddda_new, replace
replace ddda_new = "01" if ddda_new == "1"
replace ddda_new = "04" if ddda_new == "4"
replace ddda_new = "09" if ddda_new == "9"
order ddda_new, after(ddda)
drop ddda
rename ddda_new ddda

*Re-format dates to YYYY-MM-DD
format %tdCCYY-NN-DD dod
format %tdCCYY-NN-DD regdate
format %tCCCYY-NN-DD_HH:MM_AM dddoa
format %tdCCYY-NN-DD tfdddoa
format %tdCCYY-NN-DD tfdddoaend

*Remove . for missing 
replace ddda = "" if ddda=="." & redcap_event_name == "tracking_arm_2"

*Export data to csv tab format for import into redcap project
export delimited using "`datapath'/DeathData_2022_new.csv", delimiter(tab) nolabel replace
