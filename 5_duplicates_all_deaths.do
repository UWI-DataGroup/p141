** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          5_duplicates_all_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-APR-2022
    // 	date last modified      14-APR-2022
    //  algorithm task          Import death data from multi-year death database and check for duplicates
    //  status                  Completed
    //  objectve                To have one dataset with cleaned 2008-2021 death data.
    //                          To have one dataset with formatted 2008-2021 death data in prep for matching with cancer and CVD incidence datasets.
    //  note                    Updating the name match field for any duplicates found. 
    //                          Any updates to be imported to multi-year REDCap database.               

    
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
    log using "`logpath'\5_duplicates_all_deaths_2008-2021.smcl", replace
** HEADER -----------------------------------------------------
