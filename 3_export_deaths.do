** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          3_export_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      09-SEP-2020
    // 	date last modified      09-SEP-2020
    //  algorithm task          Export death data for import to Redcap BNRDeathData_2008-2020 database
    //  status                  Completed
    //  objectve                To have one dataset with cleaned 2018 death data.
    //  note                    Cleaned 2019 dataset to be merged with 2008-2019 death dataset; 
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
    log using "`logpath'\3_export_deaths_2020.smcl", replace
** HEADER -----------------------------------------------------

***************
** LOAD DATASET  
***************
use "`datapath'\version04\3-output\2020_deaths_cleaned_export_dc"

count //984


***************
** FORMATTING  
***************
drop event
gen str4 regnum2 = string(regnum,"%04.0f")
drop regnum
rename regnum2 regnum
replace regnum="" if regnum=="."
rename recstatdc death_certificate_complete
drop tfddda
rename tfddda2 tfddda
rename recstattf tracking_complete

order record_id	redcap_event_name dddoa	ddda odda certtype regnum district pname address ///
	  parish sex age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
	  cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
	  cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
	  cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b pod deathparish ///
	  regdate certifier certifieraddr namematch duprec cleaned death_certificate_complete ///
	  tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt tracking_complete


***************
** DATA EXPORT  
***************
sort record_id
export_delimited record_id	redcap_event_name dddoa	ddda odda certtype regnum district pname address ///
	  parish sex age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
	  cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
	  cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
	  cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b pod deathparish ///
	  regdate certifier certifieraddr namematch duprec cleaned death_certificate_complete ///
	  tfdddoa tfdddoatstart tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend ///
	  tfdddoaend tfdddoatend tfddelapsedh tfddelapsedm tfddtxt tracking_complete ///
using "`datapath'\version04\3-output\2020-09-09_Cleaned_2020_DeathData_REDCap_JC_V01.csv", replace

**************************
** PERFORM MANUAL UPDATES
** TO ABOVE EXPORT
** BEFORE IMPORT TO REDCAP
**************************
/*
	(1) Right-click in the selected area of 'variable' and select 'Format cells'
	(2)	Click 'Custom' and in the bar under 'Type:', enter the below customizations:
		dddoa:			yyyy-mm-dd hh:mm
		ddda:			00
		regnum:			0000
		nrn:			0000000000
		dod:			yyyy-mm-dd
		regdate:		yyyy-mm-dd
		tfdddoa:		yyyy-mm-dd
		tfdddoatstart:	hh:mm
		tfregnumstart:	0000
		tfregnumend:	0000
		tfdddoaend:		yyyy-mm-dd hh:mm
		tfdddoatend:	hh:mm
	(3) Check last record_id used in REDCap 2008-2020 database
	(4) Overwrite record_id starting with next sequential number
	(5) Add '_V02' to export file above
*/


count //1388

label data "BNR MORTALITY data 2020"
notes _dta :These data prepared from BB national death register & BNR (Redcap) deathdata database
save "`datapath'\version04\3-output\2020_deaths_exported_dc" ,replace

