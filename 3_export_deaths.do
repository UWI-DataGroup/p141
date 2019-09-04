** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          0_master_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      28-AUG-2019
    // 	date last modified      28_AUG-2019
    //  algorithm task          Import death data and run associated dofiles
    //  status                  Completed
    //  objectve                To have one dataset with cleaned 2018 death data.
    //  note 1                  Duplicate 2017 deaths checked using 2018 dataset against 2008-2017 dataset 
    //                          (see '2017 deaths_combined_20190828.xlsx')
    //  note 2                  Duplicates within 2018 deaths checked and identified using conditioinal formatting and 
    //                          field 'namematch' in 2018 dataset (see 'BNRDeathData2018_DATA_2019-08-28_1101_excel.xlsx')
    //  note 3                  Cleaned 2018 dataset to be merged with 2008-2017 death dataset; 
    //                          Redcap database with ALL cleaned deaths to be created.

    
    ** General algorithm set-up
    version 15
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
    log using "`logpath'\0_master_deaths.smcl", replace
** HEADER -----------------------------------------------------


 ******************************************************
 *
 *	GA-C D R C      A N A L Y S I S         C O D E
 *                                                              
 *  DO FILE: 		3_export_deaths
 *					3rd dofile: Data Export
 *
 *  LAST UPDATE: 	26-Jun-2018
 *
 *	LAST RUN:		26-Jun-2018
 *
 *  ANALYSIS: 		Clean 2008-2017 deaths for import
 *					into DeathData REDCap
 *
 *  PRODUCT: 		STATA SE Version 15.1
 *
 *  DATA: 			Datasets prepared by J Campbell
 *
 *****************************************************


** Stata version control
version 15.1

** Initialising the STATA log and allow automatic page scrolling
capture {
    program drop _all
	drop _all
	log close
	}

** LOAD the imported dataset
cd "C:\Users\20004087\BNR_data\DM\data_cleaning\2008-2017\deaths\versions\version03\"
log using "logfiles\3_export_deaths.smcl", replace

** Automatic page scrolling of screen output
set more off

use "data\clean\2008-2017_deaths_cleaned.dta"

count //24,188

** REMOVE variables not needed in DeathData REDCap database;
** ORDER variables according to position in DeathData REDCap database
drop agetxt durtxt onsettxt dob1 dob2 dobyr dobmon dobday birthdate dob age2 ///
	 dodyr first_digit_dobyr today dob_dob1 dob_dob2 dup dupnrn dup2 dupnrn2
label drop _all
order record_id cfdate cfda certtype regnum district pname address parish sex age ///
	  nrnnd nrn mstatus occu durationnum durationtxt dod deathyear cod1a ///
	  onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b cod1c ///
	  onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d cod2a ///
	  onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b pod ///
	  deathparish regdate certifier certifieraddr namematch death_certificate_complete


***************
** DATA EXPORT  
***************
** REDCap will not import H:M:S format so had to change cfdate from %tcCCYY-NN-DD_HH:MM:SS to below format
format cfdate %tcCCYY-NN-DD_HH:MM

sort record_id
export_delimited record_id cfdate cfda certtype regnum district pname address parish ///
			 sex age nrnnd nrn mstatus occu durationnum durationtxt dod deathyear ///
			 cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
			 cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
			 cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
			 pod deathparish regdate certifier certifieraddr namematch death_certificate_complete ///
using "C:\Users\20004087\BNR_data\DM\data_cleaning\2008-2017\deaths\versions\version03\data\clean\2018-07-05_Cleaned_DeathData_REDCap_JC.csv"

/* 
export_excel record_id cfdate cfda certtype regnum district pname address parish ///
			 sex age nrnnd nrn mstatus occu durationnum durationtxt dod deathyear ///
			 cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
			 cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
			 cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
			 pod deathparish regdate certifier certifieraddr namematch death_certificate_complete ///
using "C:\Users\20004087\BNR_data\DM\data_cleaning\2008-2017\deaths\versions\version03\data\clean\2018-06-26_Cleaned_DeathData_REDCap_JC.xlsx", firstrow(variables)
datestring() not working well as cfdate=%tcCCYY-NN-DD_HH:MM:SS whereas dod and regdate=%tdCCYY-NN-DD so manually format dates in excel export as noted below:
	cfdate = yyyy-mm-dd h:mm:ss
	dod, regdate = yyyy-mm-dd
using "C:\Users\20004087\BNR_data\DM\data_cleaning\2008-2017\deaths\versions\version03\data\clean\2018-06-26_Cleaned_DeathData_REDCap_JC.xlsx", firstrow(variables) datestring(%tdCCYY-NN-DD)replace
*/
count //24,188

label data "BNR MORTALITY data 2008-2017"
notes _dta :These data prepared from BB national death register & BNR (MS Access) deathdata database
save "data\clean\2008-2017_deaths_exported.dta" ,replace

