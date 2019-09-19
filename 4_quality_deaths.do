** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          4_quality_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      19-SEP-2019
    // 	date last modified      19-SEP-2019
    //  algorithm task          Report on data entry quality
    //  status                  Completed

    
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
    log using "`logpath'\4_quality_deaths.smcl", replace
** HEADER -----------------------------------------------------

***************
** LOAD DATASET  
***************
use "`datapath'\version01\3-output\2018_deaths_cleaned_dqi_dc"

count //2,719


*****************
** DATA QUALITY  
*****************
** Create quality report - per DA
** TOTAL records entered
//gen fieldtot=44 per record
gen rectot=_N
egen abstot_AH=count(ddda) if ddda==25
egen abstot_KG=count(ddda) if ddda==4
egen abstot_NR=count(ddda) if ddda==20
egen abstot_KWG=count(ddda) if ddda==13
egen abstot_TH=count(ddda) if ddda==14
egen abstot_intern=count(ddda) if ddda==98

** PERCENTAGE records entered
gen absper_AH=abstot_AH/rectot*100
gen absper_KG=abstot_KG/rectot*100
gen absper_NR=abstot_NR/rectot*100
gen absper_KWG=abstot_KWG/rectot*100
gen absper_TH=abstot_TH/rectot*100
gen absper_intern=abstot_intern/rectot*100

** TOTAL corrections
/*
egen corrtot_AH=total(corr_AH)
egen corrtot_KG=total(corr_KG)
egen corrtot_NR=total(corr_NR)
egen corrtot_KWG=total(corr_KWG)
egen corrtot_TH=total(corr_TH)
egen corrtot_intern=total(corr_intern)
gen corr_tot=corrtot_AH + corrtot_KG + corrtot_NR + corrtot_KWG + corrtot_TH + corrtot_intern
*/
egen rowtot=rowtotal(flag*) 
egen corrtot=total(rowtot) //224
egen rowtot_AH=rowtotal(flag*) if ddda==25 | tfddda==25
egen corrtot_AH=total(rowtot_AH) //105
egen rowtot_KG=rowtotal(flag*) if ddda==4 | tfddda==4
egen corrtot_KG=total(rowtot_KG) //60
egen rowtot_NR=rowtotal(flag*) if ddda==20 | tfddda==20
egen corrtot_NR=total(rowtot_NR) //22
egen rowtot_KWG=rowtotal(flag*) if ddda==13 | tfddda==13
egen corrtot_KWG=total(rowtot_KWG) //3
egen rowtot_TH=rowtotal(flag*) if ddda==14 | tfddda==14
egen corrtot_TH=total(rowtot_TH) //12
egen rowtot_intern=rowtotal(flag*) if ddda==98 | tfddda==98
egen corrtot_intern=total(rowtot_intern) //22

** PERCENTAGE corrections
gen corrper_AH=corrtot_AH/corrtot*100
gen corrper_KG=corrtot_KG/corrtot*100
gen corrper_NR=corrtot_AH/corrtot*100
gen corrper_KWG=corrtot_AH/corrtot*100
gen corrper_TH=corrtot_AH/corrtot*100
gen corrper_intern=corrtot_AH/corrtot*100

** TOTAL records with corrections
egen corrrectot=count(rowtot) if rowtot!=0 & rowtot!=.
egen corrrectot_AH=count(rowtot_AH) if rowtot_AH!=0 & rowtot_AH!=.
egen corrrectot_KG=count(rowtot_KG) if rowtot_KG!=0 & rowtot_KG!=.
egen corrrectot_NR=count(rowtot_NR) if rowtot_NR!=0 & rowtot_NR!=.
egen corrrectot_KWG=count(rowtot_KWG) if rowtot_KWG!=0 & rowtot_KWG!=.
egen corrrectot_TH=count(rowtot_TH) if rowtot_TH!=0 & rowtot_TH!=.
egen corrrectot_intern=count(rowtot_intern) if rowtot_intern!=0 & rowtot_intern!=.

STOPPED HERE
** PERCENTAGE records with corrections
** TOTAL records with no errors
** PERCENTAGE records with no errors
see L:\BNR_data\DM\data_review\2019\cr5\versions\version01\dofiles
** TOTAL records - TUMOUR table
preserve
drop if ttdoa<d(01jan2019) | ttdoa>d(30jun2019)
contract tid ttda ttdoa, freq(count) percent(percentage)
total count //758
egen tttot=total(count)
egen ttkwg=total(count) if ttda=="13"
egen ttth=total(count) if ttda=="14"
collapse tttot ttkwg ttth
gen ttkwgper=ttkwg/tttot*100
gen ttthper=ttth/tttot*100
save "data\raw\2019_p1appraisals_cancer_TT_figs1.dta" ,replace
restore


** QUALITY REPORT


				***************************
				*	    PDF REPORT  	  *
				*	   QUANTITY: AH 	  *
				***************************

putpdf clear
putpdf begin

//Create a paragraph
putpdf paragraph
putpdf text ("Quantity Report"), bold
putpdf paragraph
putpdf text ("Appraisal Period: 1"), font(Helvetica,10)
putpdf paragraph
putpdf text ("Date Prepared: 30 May 2019"),  font(Helvetica,10)
putpdf paragraph
putpdf text ("Prepared by: JC using Stata & main CR5"),  font(Helvetica,10)
putpdf paragraph
putpdf text ("KWG"), bgcolor("pink") font(Helvetica,10)
putpdf paragraph, halign(center)
putpdf text ("QUANTITY"), bold font(Helvetica,20,"blue")
putpdf paragraph
qui sum pttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Patient Table(PT): `sum'")
putpdf paragraph
qui sum ptkwg
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in PT by KWG: `sum'")
putpdf paragraph
qui sum ptkwgper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in PT by KWG: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum ptuptot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in Patient Table(PT): `sum'")
putpdf paragraph
qui sum ptupkwg
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in PT by KWG: `sum'")
putpdf paragraph
qui sum ptupkwgper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL updated in PT by KWG: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum tttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Tumour Table(TT): `sum'")
putpdf paragraph
qui sum ttkwg
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in TT by KWG: `sum'")
putpdf paragraph
qui sum ttkwgper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in TT by KWG: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum ttuptot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in Tumour Table(TT): `sum'")
putpdf paragraph
qui sum ttupkwg
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in TT by KWG: `sum'")
putpdf paragraph
qui sum ttupkwgper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL updated in TT by KWG: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum sttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Source Table(ST): `sum'")
putpdf paragraph
qui sum stkwg
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in ST by KWG: `sum'")
putpdf paragraph
qui sum stkwgper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in ST by KWG: `sum'%"), bold bgcolor("yellow")
putpdf paragraph

putpdf save "L:\BNR_data\DM\data_review\2019\cr5\versions\version01\data\clean\2019-05-30_P1_2019_quantKWG.pdf", replace
putpdf clear


				***************************
				*	    PDF REPORT  	  *
				*	   QUANTITY: TH 	  *
				***************************

putpdf clear
putpdf begin

//Create a paragraph
putpdf paragraph
putpdf text ("Quantity Report"), bold
putpdf paragraph
putpdf text ("Appraisal Period: 1"), font(Helvetica,10)
putpdf paragraph
putpdf text ("Date Prepared: 30 May 2019"),  font(Helvetica,10)
putpdf paragraph
putpdf text ("Prepared by: JC using Stata & main CR5"),  font(Helvetica,10)
putpdf paragraph
putpdf text ("TH"), bgcolor("pink") font(Helvetica,10)
putpdf paragraph, halign(center)
putpdf text ("QUANTITY"), bold font(Helvetica,20,"blue")
putpdf paragraph
qui sum pttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Patient Table(PT): `sum'")
putpdf paragraph
qui sum ptth
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in PT by TH: `sum'")
putpdf paragraph
qui sum ptthper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in PT by TH: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum ptuptot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in Patient Table(PT): `sum'")
putpdf paragraph
qui sum ptupth
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in PT by TH: `sum'")
putpdf paragraph
qui sum ptupthper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL updated in PT by TH: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum tttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Tumour Table(TT): `sum'")
putpdf paragraph
qui sum ttth
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in TT by TH: `sum'")
putpdf paragraph
qui sum ttthper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in TT by TH: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum ttuptot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in Tumour Table(TT): `sum'")
putpdf paragraph
qui sum ttupth
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL updated in TT by TH: `sum'")
putpdf paragraph
qui sum ttupthper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL updated in TT by TH: `sum'%"), bold bgcolor("yellow")
putpdf paragraph
qui sum sttot
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in Source Table(ST): `sum'")
putpdf paragraph
qui sum stth
local sum : display %3.0f `r(sum)'
putpdf text ("TOTAL entered in ST by TH: `sum'")
putpdf paragraph
qui sum stthper
local sum : display %2.0f `r(sum)'
putpdf text ("TOTAL entered in ST by TH: `sum'%"), bold bgcolor("yellow")
putpdf paragraph

putpdf save "L:\BNR_data\DM\data_review\2019\cr5\versions\version01\data\clean\2019-05-30_P1_2019_quantTH.pdf", replace
putpdf clear


save "`datapath'\version01\3-output\2018_deaths_report_dqi_da" ,replace
notes _dta :These data prepared from BB national death register & BNR (Redcap) deathdata database
label data "BNR Death Data Quality Report"
