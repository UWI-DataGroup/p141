** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3_export_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      19-SEP-2019
    // 	date last modified      19-SEP-2019
    //  algorithm task          Export death data for import to Redcap BNRDeathData_2008-2018 database
    //  status                  Completed
    //  objectve                To have one dataset with cleaned 2018 death data.
    //  note 1                  Duplicate 2017 deaths checked using 2018 dataset against 2008-2017 dataset 
    //                          (see '2017 deaths_combined_20190828.xlsx')
    //  note 2                  Duplicates within 2018 deaths checked and identified using conditioinal formatting and 
    //                          field 'namematch' in 2018 dataset (see 'BNRDeathData2018_DATA_2019-08-28_1101_excel.xlsx')
    //  note 3                  Cleaned 2018 dataset to be merged with 2008-2017 death dataset; 
    //                          Redcap database with ALL cleaned deaths to be created.

    
    ** General algorithm set-up
    version 16
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
    log using "`logpath'\3_export_deaths.smcl", replace
** HEADER -----------------------------------------------------

***************
** LOAD DATASET  
***************
use "`datapath'\version01\3-output\2018_deaths_cleaned_export_dc"

count //3,315


***************
** DATA EXPORT  
***************

sort record_id
export_delimited record_id event dddoa ddda odda certtype regnum district pname address parish ///
	  sex age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
	  cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
	  cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
	  cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
	  pod deathparish regdate certifier certifieraddr namematch recstatdc ///
	  tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf ///
using "`datapath'\version01\3-output\2019-09-19_Cleaned_2018_DeathData_REDCap_JC.csv", replace

count //2,719

label data "BNR MORTALITY data 2008-2018"
notes _dta :These data prepared from BB national death register & BNR (Redcap) deathdata database
save "`datapath'\version01\3-output\2018_deaths_exported_dc" ,replace

