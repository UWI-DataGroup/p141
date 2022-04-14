** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1b_prep_electoral.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-APR-2022
    // 	date last modified      14-APR-2022
    //  algorithm task          Prep and format electoral data
    //  status                  Completed
    //  objectve                To have one dataset with formatted electoral data for matching with death dataset.
    //  note                    Data from this dataset used to update and clean the death dataset. 
    //                          Data obtained from the Barbados Electoral and Boundaries Commission

    
    ** General algorithm set-up
    version 17.0
    clear all
    macro drop _all
    set more off

    ** Initialising the STATA log and allow automatic page scrolling
    capture {
            program drop _all
    	drop _all
    	log close
    	}

    ** Set working directories: this is for DATASET and LOGFILE import and export
    ** DATASETS to encrypted SharePoint folder
    local datapath "X:/The University of the West Indies/DataGroup - repo_data/data_p141"
    ** LOGFILES to unencrypted OneDrive folder (.gitignore set to IGNORE log files on PUSH to GitHub)
    local logpath X:/OneDrive - The University of the West Indies/repo_datagroup/repo_p141

    ** Close any open log file and open a new log file
    capture log close
    log using "`logpath'\1b_prep_electoral_2021.smcl", replace
** HEADER -----------------------------------------------------

***************
** DATA IMPORT  
***************
** LOAD the national registry deaths 2008-2017 excel dataset
/*
import excel using "`datapath'\version07\1-input\Register_Electoral List II.xlsx" , firstrow case(lower)

save "`datapath'\version07\2-working\2019_electoral_imported_dp" ,replace

count //508,930
*/

use "`datapath'\version07\2-working\2019_electoral_imported_dp" ,clear

** Create pname variable for matching with death data
gen pname=firstname+" "+middlename+" "+lastname

** Create unique ID variable
gen id=_n
order id

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*

label data "BNR ELECTORAL data 2019"
notes _dta :These data prepared from EBC register
save "`datapath'\version07\2-working\2019_electoral_prepped_dp" ,replace
