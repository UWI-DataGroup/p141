** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          2_clean_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      05-SEP-2019
    // 	date last modified      19-SEP-2019
    //  algorithm task          Clean death data
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
    log using "`logpath'\2_clean_deaths.smcl", replace
** HEADER -----------------------------------------------------

***************
** LOAD DATASET  
***************
use "`datapath'\version01\2-working\2018_deaths_prepped_dp"

count //3,344


*****************
** DATA QUALITY  
*****************
** Create quality report - corrections per DA
forvalues j=1/55 {
	gen flag`j'=0
}

label var flag1 "Record ID"
label var flag2 "Redcap Event"
label var flag3 "ABS DateTime"
label var flag4 "ABS DA"
label var flag5 "ABS Other DA"
label var flag6 "Certificate Type"
label var flag7 "ABS Reg Dept #"
label var flag8 "ABS District"
label var flag9 "Pt Name"
label var flag10 "Pt Address"
label var flag11 "Pt Parish"
label var flag12 "Sex"
label var flag13 "Age"
label var flag14 "Age (time period)"
label var flag15 "Date of Death"
label var flag16 "Death Year"
label var flag17 "NRN documented?"
label var flag18 "NRN"
label var flag19 "Marital Status"
label var flag20 "Occupation"
label var flag21 "Duration"
label var flag22 "Duration (time period)"
label var flag23 "COD 1a"
label var flag24 "Onset 1a"
label var flag25 "Onset 1a (time period)"
label var flag26 "COD 1b"
label var flag27 "Onset 1b"
label var flag28 "Onset 1b (time period)"
label var flag29 "COD 1c"
label var flag30 "Onset 1c"
label var flag31 "Onset 1c (time period)"
label var flag32 "COD 1d"
label var flag33 "Onset 1d"
label var flag34 "Onset 1d (time period)"
label var flag35 "COD 2a"
label var flag36 "Onset 2a"
label var flag37 "Onset 2a (time period)"
label var flag38 "COD 2b"
label var flag39 "Onset 2b"
label var flag40 "Onset 2b (time period)"
label var flag41 "Place of Death"
label var flag42 "Death Parish"
label var flag43 "Reg Date"
label var flag44 "Certifier"
label var flag45 "Certifer Address"
label var flag46 "Name Match"
label var flag47 "ABS Complete?"
label var flag48 "TF DateTime"
label var flag49 "TF DA"
label var flag50 "TF Reg # START"
label var flag51 "TF District START"
label var flag52 "TF Reg # END"
label var flag53 "TF District END"
label var flag54 "TF Comments"
label var flag55 "TF Complete?"

/*
gen corr_AH=0 //DA code=25
gen corr_KG=0 //DA code=04
gen corr_NR=0 //DA code=20
gen corr_KWG=0 //DA code=13
gen corr_TH=0 //DA code=14
gen corr_intern=0 //DA code=98
*/

*****************
** DATA CLEANING  
*****************
** CLEAN each variable according to below consistency checks and the quality rules in DeathData REDCap database

** Corrections found manually in excel input file prior to import to Stata as some dates were not valid for inclusion in 2019 Redcap deathdb
replace dod=d(09mar2018) if record_id==382 //1 change
replace dod=d(12aug2018) if record_id==2963 //1 change
replace flag15=flag15+1 if record_id==382|record_id==1909|record_id==600|record_id==2963 //5 changes
//replace corr_intern=corr_intern+1 if record_id==382|record_id==1909 //2 changes
replace dod=d(31dec2018) if record_id==600 //1 change
//replace corr_NR=corr_NR+1 if record_id==600 //1 change
replace dod=d(19jan2018) if record_id==1909 //1 change
//replace corr_AH=corr_AH+1 if record_id==2963 //1 change

************************
**  DEATH CERTIFICATE **
**        FORM        **
************************
sort record_id
** record_id (auto-generated by REDCap): FLAG 1
** (1) missing/duplicate
count if record_id==. //0
duplicates list record_id, nolabel sepby(record_id) //1 - record_id=29
replace record_id=3344 if record_id==29 & event==1 //1 change

** event (auto-generated by REDCap): FLAG 2
** (2) missing
count if event==. //0


** dddoa: Y-M-D H:M, readonly: FLAG 3
** (3) missing
count if event==1 & dddoa==. //0


** ddda: FLAG 4
** (4) missing
count if event==1 & ddda==. //0
count if event==1 & (ddda!=4 & ddda!=13 & ddda!=14 & ddda!=20 & ddda!=25 & ddda!=98) //0


** odda: FLAG 5
** (5) missing
count if ddda==98 & odda=="" //0
** (6) invalid
count if ddda!=98 & odda!="" //8
//list record_id event dddoa ddda odda if ddda!=98 & odda!=""
replace ddda=25 if ddda!=98 & odda!="" //8 changes; no quality assessment as this field initially didn't have AH's code
replace odda="" if ddda!=98 & odda!="" //8 changes


** certtype: 1=MEDICAL 2=POST MORTEM 3=CORONER 99=ND, required: FLAG 6
** (7) missing
count if event==1 & certtype==. //1
//list record_id event dddoa ddda certtype if event==1 & certtype==.
replace certtype=1 if record_id==659 //1 change
replace flag6=flag6+1 if record_id==659 //1 change
//replace corr_AH=corr_AH+1 if record_id==659 //1 change


** regnum: integer, if missing=9999: FLAG 7
** (8) missing
count if event==1 & regnum==.|event==1 & regnum==0 //0
** (9) invalid
count if event==1 & regnum>9999 //0


** district: 1=A 2=B 3=C 4=D 5=E 6=F: FLAG 8
** (10) missing
count if event==1 & district==. //0


** pname: Text, if missing=99: FLAG 9
** (11) missing
count if event==1 & pname=="" //0
** (12) invalid
count if event==1 & regexm(pname, "[a-z]") //3
//list record_id event ddda pname if event==1 & regexm(pname, "[a-z]")
replace pname=subinstr(pname,"Suspected to be ","",.) if record_id==2766
replace flag9=flag9+1 if record_id==2766|record_id==360|record_id==1122 //3 changes
//replace corr_intern=corr_intern+1 if record_id==2766 //1 change
replace pname=upper(pname) //2 changes
//replace corr_KG=corr_KG+1 if record_id==360 //1 change
//replace corr_AH=corr_AH+1 if record_id==1122 //1 change
count if event==1 & regexm(pname,"NIL")|event==1 & regexm(pname,"ND") //291 - all correct
//list record_id ddda pname if event==1 & regexm(pname,"NIL")|event==1 & regexm(pname,"ND")
** (13) duplicate
sort pname
quietly by pname:  gen dup = cond(_N==1,0,_n)
sort pname
count if event==1 & dup>0  //90 - some are exact replicas as AH seem to import data twice from Redcap BNRDeathData db into BNRDeathData_2018 db
sort pname record_id
//list record_id dddoa ddda pname regnum district nrn if event==1 & dup>0
replace namematch=1 if record_id==1807|record_id==2489|record_id==2876|record_id==3015|record_id==2147|record_id==2811 ///
					   |record_id==909|record_id==2003|record_id==272|record_id==1544|record_id==1046|record_id==3078 ///
					   |record_id==437|record_id==2936|record_id==2004|record_id==2910|record_id==23|record_id==3066 ///
					   |record_id==1869|record_id==2300|record_id==1631|record_id==3337|record_id==1287|record_id==1887 ///
					   |record_id==1385|record_id==2812|record_id==317|record_id==3159|record_id==438|record_id==1308 ///
					   |record_id==1723|record_id==1726 //32 changes

drop if record_id==420|record_id==822|record_id==1027|record_id==404|record_id==421|record_id==416|record_id==457 ///
		|record_id==412|record_id==405|record_id==413|record_id==411|record_id==408|record_id==937|record_id==454 ///
		|record_id==458|record_id==3064|record_id==410|record_id==417|record_id==456|record_id==406|record_id==402 ///
		|record_id==455|record_id==419|record_id==415|record_id==409|record_id==418|record_id==407|record_id==414 ///
		|record_id==403 //29 deleted
//dropped 937 vs 1099 as AH's had errors with dod and cod; dropped 3064 vs 3060 as TH's had missing field comments
drop dup


** address: Text, if missing=99: FLAG 10
** (14) missing
count if event==1 & address=="" //0
** (15) invalid 
count if event==1 & regexm(address, "[a-z]") //3
//list record_id event ddda address if event==1 & regexm(address, "[a-z]")
replace address=upper(address) //3 changes
replace flag10=flag10+1 if record_id==38|record_id==318|record_id==654 //3 changes
//replace corr_KG=corr_KG+1 if record_id==38|record_id==318 //2 changes
//replace corr_AH=corr_AH+1 if record_id==654 //1 change
count if event==1 & regexm(address,"NIL")|event==1 & regexm(address,"ND") //573 - all correct
//list record_id ddda address if event==1 & regexm(address,"NIL")|event==1 & regexm(address,"ND")


** parish: FLAG 11
** (16) missing
count if event==1 & parish==. //0


** sex:	1=Male 2=Female 99=ND: FLAG 12
** (17) missing
count if event==1 & sex==. //1
//list record_id event ddda pname sex if event==1 & sex==.
replace sex=2 if record_id==186 //1 change
replace flag12=flag12+1 if record_id==186|record_id==698|record_id==1311|record_id==1309|record_id==891|record_id==1723|record_id==2682 //7 changes
//replace corr_KG=corr_KG+1 if record_id==186 //1 change
** (18) invalid - female with prostate
count if sex==2 & (regexm(cod1a, "PROSTAT")|regexm(cod1b, "PROSTAT")|regexm(cod1c, "PROSTAT") ///
		|regexm(cod1d, "PROSTAT")|regexm(cod2a, "PROSTAT")|regexm(cod2b, "PROSTAT")) //1
//list record_id ddda pname nrn sex cod* if (regexm(cod1a, "PROSTAT")|regexm(cod1b, "PROSTAT")|regexm(cod1c, "PROSTAT")|regexm(cod1d, "PROSTAT")|regexm(cod2a, "PROSTAT")|regexm(cod2b, "PROSTAT")) & sex==2
recode sex 2=1 if record_id==698 //1 change
//replace corr_AH=corr_AH+1 if record_id==698 //1 change
** (19) visual check - first names for those missing nrn
count if sex==1 & nrn==. //112 - check if there is a stata check for this e.g. soundex,etc - 4 changes
//list record_id ddda pname sex if sex==1 & nrn==.
recode sex 1=2 if record_id==1311|record_id==891|record_id==1309|record_id==1723 //4 changes
//replace corr_AH=corr_AH+1 if record_id==1311|record_id==1309 //2 changes
//replace corr_KG=corr_KG+1 if record_id==891 //1 change
//replace corr_NR=corr_NR+1 if record_id==1723 //1 change
** (20) invalid - male with female genital cod
count if sex==1 & (regexm(cod1a, "UTER") | regexm(cod1a, "OMA OF THE VULVA") | ///
			regexm(cod1a, "CHORIOCARCIN") | regexm(cod1a, "ENDOMETRIAL CARCINOMA") | ///
			regexm(cod1a, "ENDOMETRIAL CANC") | regexm(cod1a, "OF ENDOMETRIUM") | ///
			regexm(cod1a, "OF THE ENDOMETRIUM") | regexm(cod1a, "VULVA CARCINOMA") | ///
			regexm(cod1a, "VULVAL CANCER") | regexm(cod1a, "VAGINAL CARCINOMA")) //1
/*list record_id ddda pname nrn sex cod* if sex==1 & (regexm(cod1a, "UTER") | regexm(cod1a, "OMA OF THE VULVA") | ///
			regexm(cod1a, "CHORIOCARCIN") | regexm(cod1a, "ENDOMETRIAL CARCINOMA") | ///
			regexm(cod1a, "ENDOMETRIAL CANC") | regexm(cod1a, "OF ENDOMETRIUM") | ///
			regexm(cod1a, "OF THE ENDOMETRIUM") | regexm(cod1a, "VULVA CARCINOMA") | ///
			regexm(cod1a, "VULVAL CANCER") | regexm(cod1a, "VAGINAL CARCINOMA"))
*/
recode sex 1=2 if record_id==2682 //1 change
//replace corr_KG=corr_KG+1 if record_id==2682 //1 change
** (21) visual check - first names for those missing nrn
count if sex==2 & nrn==. //67 - check if there is a stata check for this e.g. soundex,etc - 0 changes
//list record_id ddda pname sex if sex==2 & nrn==.


** age: Integer - min=0, max=999: FLAG 13
** (22) missing
count if event==1 & age==. //0
** (23) missing - NRN not missing
count if (age==.|age==0) & nrn!=. //0


** agetxt - 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks" 5 "Months" 6 "Years" 99 "ND": FLAG 14
** (25) missing
count if age!=. & agetxt==. //0
** (26) invalid
count if age==999 & agetxt!=99 //0
** (27) visual check - NRN vs agetxt
count if nrn!=. & age!=. & agetxt!=6 //22
list record_id ddda dod nrn age agetxt if nrn!=. & age!=. & agetxt!=6 //checked these using redcap db & electoral list
replace age=69 if record_id==1722 //1 change
replace age=86 if record_id==334 //1 change
replace age=95 if record_id==2523 //1 change
replace age=81 if record_id==1239 //1 change
replace age=100 if record_id==480 //1 change
replace age=83 if record_id==981 //1 change
replace age=71 if record_id==660 //1 change
replace age=75 if record_id==969 //1 change
replace age=85 if record_id==269 //1 change
replace agetxt=6 if record_id==1722|record_id==334|record_id==96|record_id==141|record_id==1378 ///
					|record_id==499|record_id==484|record_id==1146|record_id==2523|record_id==220 ///
					|record_id==1239|record_id==480|record_id==981|record_id==660|record_id==969 ///
					|record_id==353|record_id==2639|record_id==269 //18 changes
replace flag13=flag13+1 if record_id==1722|record_id==1378|record_id==1146|record_id==1239|record_id==480 ///
					  	   |record_id==981|record_id==660|record_id==969|record_id==334|record_id==96 ///
						   |record_id==141|record_id==499|record_id==484|record_id==220|record_id==353 ///
						   |record_id==269|record_id==2523|record_id==2639 //18 changes
replace agetxt=6 if record_id==268 //1 change - correct nrn found in electoral list and changed in below nrn checks
replace flag14=flag14+1 if record_id==268 //1 change
/*replace corr_AH=corr_AH+1 if record_id==1722|record_id==1378|record_id==1146|record_id==1239|record_id==480 ///
					  |record_id==981|record_id==660|record_id==969 //8 changes
replace corr_KG=corr_KG+1 if record_id==334|record_id==96|record_id==141|record_id==499|record_id==484 ///
					  |record_id==268|record_id==220|record_id==353|record_id==269 //9 changes
replace corr_NR=corr_NR+1 if record_id==2523 //1 change
replace corr_intern=corr_intern+1 if record_id==2639 //1 change
*/

** dod: Y-M-D (need to clean dod before other checks): FLAG 15
** (28) missing
count if event==1 & dod==. //0
** (29) invalid - future date
gen currentd=c(current_date)
gen double today=date(currentd, "DMY")
drop currentd
format today %tdCCYY-NN-DD
count if event==1 & dod>today //5
sort record_id
//list record_id ddda dod regdate pname if event==1 & dod>today
replace dod=dod-328718 if record_id==669|record_id==675|record_id==1296|record_id==1304
replace dod=dod-365 if record_id==2708
replace dodyear=2018 if record_id==669 //1 change
replace dodyear=2018 if record_id==675 //1 change
replace dodyear=2018 if record_id==1296 //1 change
replace dodyear=2018 if record_id==1304 //1 change
replace dodyear=2018 if record_id==2708 //1 change
replace flag15=flag15+1 if record_id==669|record_id==675|record_id==1296|record_id==1304|record_id==2708 //5 changes
//replace corr_AH=corr_AH+1 if record_id==669|record_id==675|record_id==1296|record_id==1304 //4 changes
//replace corr_KG=corr_KG+1 if record_id==2708 //1 change
** (30) invalid - after reg date
count if event==1 & dod>regdate //25 (check redcapdb for if any coroner cases; 2019 TF redcap report for 'true' 2019 cases)
//list record_id ddda dod regdate pname if event==1 & dod>regdate
replace dod=regdate if record_id==330 //1 change
replace regdate=d(04mar2018) if record_id==330 //1 change
replace dod=regdate if record_id==357 //1 change
replace regdate=d(08mar2018) if record_id==357 //1 change
replace dod=regdate if record_id==369 //1 change
replace regdate=d(21aug2018) if record_id==369 //1 change
replace dod=regdate if record_id==1009 //1 change
replace regdate=d(14jul2018) if record_id==1009 //1 change
replace dod=regdate if record_id==1026 //1 change
replace regdate=d(11jun2018) if record_id==1026 //1 change
replace dod=regdate if record_id==1031 //1 change
replace regdate=d(22jul2018) if record_id==1031 //1 change
replace dod=regdate if record_id==1095 //1 change
replace regdate=d(17jul2018) if record_id==1095 //1 change
replace dod=regdate if record_id==1218 //1 change
replace regdate=d(05nov2018) if record_id==1218 //1 change
replace dod=regdate if record_id==1303 //1 change
replace regdate=d(18aug2018) if record_id==1303 //1 change
replace dod=regdate if record_id==1316 //1 change
replace regdate=d(20aug2018) if record_id==1316 //1 change
replace dod=regdate if record_id==1318 //1 change
replace regdate=d(04jan2019) if record_id==1318 //1 change
replace dod=regdate if record_id==1357 //1 change
replace regdate=d(08dec2018) if record_id==1357 //1 change
replace dod=regdate if record_id==1460 //1 change
replace regdate=d(26aug2018) if record_id==1460 //1 change
replace dod=regdate if record_id==1622 //1 change
replace regdate=d(16mar2018) if record_id==1622 //1 change
replace dod=regdate if record_id==1952 //1 change
replace regdate=d(17feb2018) if record_id==1952 //1 change
replace dod=regdate if record_id==2180 //1 change
replace regdate=d(30jul2018) if record_id==2180 //1 change
replace dod=regdate if record_id==2576 //1 change
replace regdate=d(23jan2019) if record_id==2576 //1 change
replace dod=regdate if record_id==2657 //1 change
replace regdate=d(11feb2019) if record_id==2657 //1 change
replace dod=regdate if record_id==2774 //1 change
replace regdate=d(27feb2019) if record_id==2774 //1 change
replace dod=regdate if record_id==2805 //1 change
replace regdate=d(21feb2019) if record_id==2805 //1 change
replace dod=regdate if record_id==3056 //1 change
replace regdate=d(09may2019) if record_id==3056 //1 change
replace regdate=d(08mar2019) if record_id==3095 //1 change
replace regdate=d(27mar2019) if record_id==3178 //1 change
replace regdate=regdate+365 if event==1 & dod>regdate //2 changes
replace flag15=flag15+1 if record_id==11|record_id==330|record_id==357|record_id==1318 ///
						   |record_id==369|record_id==1622|record_id==1952|record_id==2657|record_id==2774 ///
						   |record_id==1009|record_id==1026|record_id==1031|record_id==1095|record_id==1303 ///
						   |record_id==1316|record_id==1357|record_id==2576|record_id==2805|record_id==3095 ///
						   |record_id==3178|record_id==1218|record_id==1460|record_id==3056|record_id==600|record_id==2180 //25 changes
replace flag43=flag43+1 if record_id==11|record_id==330|record_id==357|record_id==1318 ///
						   |record_id==369|record_id==1622|record_id==1952|record_id==2657|record_id==2774 ///
						   |record_id==1009|record_id==1026|record_id==1031|record_id==1095|record_id==1303 ///
						   |record_id==1316|record_id==1357|record_id==2576|record_id==2805|record_id==3095 ///
						   |record_id==3178|record_id==1218|record_id==1460|record_id==3056|record_id==600|record_id==2180 //25 changes
/*replace corr_KG=corr_KG+1 if record_id==11|record_id==330|record_id==357|record_id==1318 //4 changes
replace corr_intern=corr_intern+1 if record_id==369|record_id==1622|record_id==1952|record_id==2657|record_id==2774 //5 changes
replace corr_AH=corr_AH+1 if record_id==1009|record_id==1026|record_id==1031|record_id==1095|record_id==1303 ///
							 |record_id==1316|record_id==1357|record_id==2576|record_id==2805|record_id==3095 ///
							 |record_id==3178 //11 changes
replace corr_TH=corr_TH+1 if record_id==1218|record_id==1460|record_id==3056 //3 changes
replace corr_NR=corr_NR+1 if record_id==600|record_id==2180 //2 changes
*/

** dodyear (not included in single year Redcap db but done for multi-year Redcap db): FLAG 16
** (31) missing
count if event==1 & dodyear==. //0
//list record_id ddda dod regdate if event==1 & dodyear==.
** (32) invalid - deaths after 2018
count if event==1 & dodyear>2018 //596
//list record_id ddda dod dodyear regdate if event==1 & dodyear>2018
//tab dodyear if event==1,m
/*
    Year of |
      Death |      Freq.     Percent        Cum.
------------+-----------------------------------
       2017 |        121        3.73        3.73 - Checked these against previously-collected 2017 deaths and 0 matches
       2018 |      2,525       77.88       81.62
       2019 |        596       18.38      100.00
------------+-----------------------------------
      Total |      3,242      100.00
*/
//drop if event==1 & dodyear>2018 - forgot to drop at this point but need to do so for next year's cleaning

** nrnnd: 1=Yes 2=No: FLAG 17
** (33) missing
count if event==1 & nrnnd==. //1
//list record_id ddda nrn if event==1 & nrnnd==.
replace nrnnd=2 if record_id==659 //1 change
replace flag17=flag17+1 if record_id==659 //1 change
//replace corr_AH=corr_AH+1 if record_id==659 //1 change
** (34) invalid
count if event==1 & nrn==. & nrnnd==1 //0
** (35) invalid
count if nrn!=. & nrnnd==2 //0

** nrn: dob-####, partial missing=dob-9999, if missing=.: FLAG 18
tostring nrn, gen(natregno) format("%15.0f")
replace natregno="" if natregno=="." //252 changes
** (36) missing
count if event==1 & nrnnd==1 & (natregno==""|natregno=="9999999999") //0
** (37) invalid - length (checked against electoral list; no error for DA if leading zero was in redcap db)
count if natregno!="" & length(natregno)!=10 //39
//list record_id ddda pname nrn natregno if natregno!="" & length(natregno)!=10
replace natregno=subinstr(natregno,"09","009",.) if record_id==3019 //1 change
replace natregno=subinstr(natregno,"903","0903",.) if record_id==2018 //1 change
replace natregno=subinstr(natregno,"000","00",.) if record_id==1423 //1 change
replace natregno=natregno + "0057" if record_id==1581 //1 change
replace natregno=subinstr(natregno,"204","0204",.) if record_id==612 //1 change
replace natregno=subinstr(natregno,"4","",.) if record_id==701 //1 change
replace natregno=subinstr(natregno,"12","0012",.) if record_id==321 //1 change
replace natregno=subinstr(natregno,"30","310",.) if record_id==2004 //1 change
replace natregno=subinstr(natregno,"2","23",.) if record_id==268 //1 change
replace natregno=natregno + "0087" if record_id==2941 //1 change
replace natregno=subinstr(natregno,"31","311",.) if record_id==2492 //1 change
replace natregno=subinstr(natregno,"7","77",.) if record_id==2204 //1 change
replace natregno=subinstr(natregno,"1","01",.) if record_id==379 //1 change
replace natregno="000" + natregno if record_id==3208 //1 change
replace natregno=natregno + "0018" if record_id==1924 //1 change
replace natregno=subinstr(natregno,"7","07",.) if record_id==845 //1 change
replace natregno=subinstr(natregno,"4","48",.) if record_id==1257 //1 change
replace natregno="0" + natregno if record_id==2709 //1 change
replace natregno=subinstr(natregno,"80","8",.) if record_id==1562 //1 change
replace natregno=subinstr(natregno,"2","02",.) if record_id==3344 //1 change
replace natregno=subinstr(natregno,"702","70",.) if record_id==120 //1 change
replace pname=subinstr(pname,"EN","ER",.) if record_id==120 //1 change
replace flag9=flag9+1 if record_id==120 //1 change
//replace corr_KG=corr_KG+1 if record_id==120 //1 change
replace natregno=subinstr(natregno,"80","080",.) if record_id==230 //1 change
replace natregno="0" + natregno if record_id==3085 //1 change
replace natregno=subinstr(natregno,"29","9",.) if record_id==1073 //1 change
replace natregno="000" + natregno if record_id==782 //1 change
replace natregno="0" + natregno if record_id==1815 //1 change
replace natregno="00" + natregno if record_id==2540 //1 change
replace natregno=subinstr(natregno,"43","4",.) if record_id==951 //1 change
replace natregno=natregno + "0045" if record_id==3138 //1 change
replace natregno="0" + natregno if record_id==1740 //1 change
replace natregno="0" + natregno if record_id==85 //1 change
replace natregno=subinstr(natregno,"5","",.) if record_id==1268 //1 change
replace natregno=subinstr(natregno,"1","",.) if record_id==914 //1 change
replace natregno=subinstr(natregno,"01","001",.) if record_id==128 //1 change
replace natregno="" if record_id==1578 //1 change - cannot find on electoral list
replace natregno="0" + natregno if record_id==17 //1 change
replace natregno="0" + natregno if record_id==2723 //1 change
replace natregno=subinstr(natregno,"000","00",.) if record_id==1530 //1 change
replace natregno=subinstr(natregno,"7","",.) if record_id==1304 //1 change
replace pname= subinstr(pname,"AM","AMS",.) if record_id==1304 //1 change
//first and last names are inverted so switch these
replace pname=pname + " " + pname if record_id==1304 //1 change
gen n = regexs(2)+", "+regexs(1) if regexm(pname, "([a-zA-Z]+)[ ]*([a-zA-Z]+)")
replace n= subinstr(n,",","",.) if record_id==1304 //1 change
replace pname=n if record_id==1304 //1 change
drop n
replace flag18=flag18+1 if record_id==3019|record_id==951|record_id==1423|record_id==701|record_id==2004 ///
						   |record_id==2492|record_id==1257|record_id==1562|record_id==1530|record_id==1304 ///
						   |record_id==1581|record_id==321|record_id==268|record_id==3344|record_id==120 ///
						   |record_id==230|record_id==1073|record_id==85|record_id==128|record_id==17 ///
						   |record_id==2941|record_id==2204|record_id==379|record_id==1924|record_id==1268|record_id==914 //26 changes
/*replace corr_NR=corr_NR+1 if record_id==3019|record_id==951 //2 changes
replace corr_AH=corr_AH+1 if record_id==1423|record_id==701|record_id==2004|record_id==2492|record_id==1257 ///
							|record_id==1562|record_id==1530|record_id==1304 //8 changes
replace corr_KG=corr_KG+1 if record_id==1581|record_id==321|record_id==268|record_id==3344|record_id==120 ///
							|record_id==230|record_id==1073|record_id==85|record_id==128|record_id==17 //10 changes
replace corr_intern=corr_intern+1 if record_id==2941|record_id==2204|record_id==379|record_id==1924 //4 changes
replace corr_TH=corr_TH+1 if record_id==1268|record_id==914 //2 changes
*/
** (38) invalid - dob but missing nrn #
count if regexm(natregno,"9999")|regexm(natregno,"99") //2 (checked against electoral list)
//list record_id ddda natregno pname if regexm(natregno,"9999")|regexm(natregno,"99")
replace natregno="" if record_id==2096
replace natregno=subinstr(natregno,"21","15",.) if record_id==376 //1 change
replace natregno=subinstr(natregno,"99","14",.) if record_id==376 //1 change
replace natregno=subinstr(natregno,"99","00",.) if record_id==3081 //1 change
replace flag18=flag18+1 if record_id==2096|record_id==3081 //2 changes
//replace corr_NR=corr_NR+1 if record_id==2096 //1 change
//replace corr_AH=corr_AH+1 if record_id==3081 //1 change
** (39) invalid - female with 'male' NRN
count if sex==2 & (regex(substr(natregno,-2,1), "[1,3,5,7,9]")) & !(strmatch(strupper(natregno), "*-9999*")) //11
//list record_id ddda pname natregno sex cod* if sex==2 & (regex(substr(natregno,-2,1), "[1,3,5,7,9]")) & !(strmatch(strupper(natregno), "*-9999*"))
recode sex 2=1 if record_id==1423|record_id==1537|record_id==2335|record_id==1017|record_id==2891 //5 changes
replace flag12=flag12+1 if record_id==1423|record_id==1017|record_id==2335 //3 changes
//replace corr_AH=corr_AH+1 if record_id==1423|record_id==1017 //2 changes
//replace corr_KG=corr_KG+1 if record_id==2335 //1 change
** (40) invalid - male with 'female' NRN
count if sex==1 & regex(substr(natregno,-2,1), "[0,2,4,6,8]") //8
//list record_id ddda pname natregno sex cod* if sex==1 & regex(substr(natregno,-2,1), "[0,2,4,6,8]")
recode sex 1=2 if record_id==817|record_id==3294|record_id==3300|record_id==3311|record_id==2155|record_id==2012 //6 changes
replace flag12=flag12+1 if record_id==817|record_id==2155|record_id==2012|record_id==3294|record_id==3300|record_id==3311 //6 changes
//replace corr_AH=corr_AH+1 if record_id==817|record_id==2155|record_id==2012 //3 changes
//replace corr_KG=corr_KG+1 if record_id==3294|record_id==3300|record_id==3311 //3 changes
** (41) invalid - age vs dob(nrn)
gen dobyr=substr(natregno, 1, 2) if natregno!=""
gen dobmon=substr(natregno, 3, 2) if natregno!=""
gen dobday=substr(natregno, 5, 2) if natregno!=""
count if (agetxt!=6 & natregno!="")|regex(substr(dobyr,1,1),"[0]") //19
//list record_id age agetxt dod natregno dobyr dobmon dobday if (agetxt!=6 & natregno!="")|regex(substr(dobyr,1,1),"[0]")
replace dobyr="20"+dobyr if (agetxt!=6 & natregno!="")|regex(substr(dobyr,1,1),"[0]") //19 changes
replace dobyr="19"+dobyr if length(dobyr)==2 //3,042 changes
count if length(dobyr)>4 //0
count if dobday!="" & (dobday!="01"&dobday!="02"&dobday!="03"&dobday!="04"&dobday!="05"&dobday!="06"&dobday!="07"&dobday!="08"&dobday!="09"&dobday!="10"&dobday!="11"&dobday!="12" ///
		 &dobday!="13"&dobday!="14"&dobday!="15"&dobday!="16"&dobday!="17"&dobday!="18"&dobday!="19"&dobday!="20"&dobday!="21"&dobday!="22"&dobday!="23"&dobday!="24"&dobday!="25" ///
		 &dobday!="26"&dobday!="27"&dobday!="28"&dobday!="29"&dobday!="30"&dobday!="31") //2
/*list record_id ddda dobday natregno pname if dobday!="" & (dobday!="01"&dobday!="02"&dobday!="03"&dobday!="04"&dobday!="05"&dobday!="06"&dobday!="07"&dobday!="08"&dobday!="09"&dobday!="10"&dobday!="11"&dobday!="12" ///
		 &dobday!="13"&dobday!="14"&dobday!="15"&dobday!="16"&dobday!="17"&dobday!="18"&dobday!="19"&dobday!="20"&dobday!="21"&dobday!="22"&dobday!="23"&dobday!="24"&dobday!="25" ///
		 &dobday!="26"&dobday!="27"&dobday!="28"&dobday!="29"&dobday!="30"&dobday!="31")
*/
replace dobday="09" if record_id==1417 //1 change
replace natregno=subinstr(natregno,"90","09",.) if record_id==1417 //1 change
replace dobday="31" if record_id==2872 //1 change
replace natregno=subinstr(natregno,"32","31",.) if record_id==2872 //1 change
replace flag18=flag18+1 if record_id==1417|record_id==2872 //2 changes
//replace corr_AH=corr_AH+1 if record_id==1417 //1 change
//replace corr_KG=corr_KG+1 if record_id==2872 //1 change
count if dobmon!="" & (dobmon!="01"&dobmon!="02"&dobmon!="03"&dobmon!="04"&dobmon!="05"&dobmon!="06"&dobmon!="07"&dobmon!="08"&dobmon!="09"&dobmon!="10"&dobmon!="11"&dobmon!="12") //2
//list record_id ddda dobmon natregno pname if dobmon!="" & (dobmon!="01"&dobmon!="02"&dobmon!="03"&dobmon!="04"&dobmon!="05"&dobmon!="06"&dobmon!="07"&dobmon!="08"&dobmon!="09"&dobmon!="10"&dobmon!="11"&dobmon!="12")
replace dobmon="10" if record_id==1727 //1 change
replace natregno=subinstr(natregno,"20","10",.) if record_id==1727 //1 change
replace dobyr=subinstr(dobyr,"0","9",.) if record_id==3267 //1 change
replace dobmon=subinstr(dobmon,"9","0",.) if record_id==3267 //1 change
replace natregno=subinstr(natregno,"09","90",.) if record_id==3267 //1 change
replace flag18=flag18+1 if record_id==1727|record_id==3267 //2 changes
//replace corr_AH=corr_AH+1 if record_id==1727|record_id==3267 //2 changes
gen birthdate=dobyr+dobmon+dobday
gen dob=date(birthdate, "YMD")
format dob %tdCCYY-NN-DD
gen age2=int((dod - dob)/365.25) //now use this to assign missing age
count if age!=age2 & natregno!="" & dob!=. //79
sort record_id
//list record_id age age2 agetxt dod dob natregno if age!=age2 & natregno!=""
replace dob=dob+36525 if record_id==349
replace agetxt=6 if record_id==470|record_id==970
replace dob=dob+36528 if record_id==475
replace dob=dob+36525 if record_id==2722
replace age2=age if record_id==349|record_id==475|record_id==2722
count if age!=age2 & natregno!="" & dob!=. //76
replace age=age2 if age!=age2 & natregno!="" & dob!=. & record_id!=921 //75 changes
drop nrn dob dobday dobmon dobyr age2
rename natregno nrn


** mstatus: 1=Single 2=Married 3=Separated/Divorced 4=Widowed/Widow/Widower 99=ND: FLAG 19
** (42) missing
count if event==1 & mstatus==. //0


** occu: Text, if missing=99: FLAG 20
** (43) missing
count if event==1 & occu=="" //0
** (44) invalid 
count if event==1 & regexm(occu, "[a-z]") //8
//list record_id ddda occu if event==1 & regexm(occu, "[a-z]")
replace occu=subinstr(occu,"(minutes)","",.) if record_id==6 //1 change
replace occu=upper(occu) //7 changes
replace occu = rtrim(ltrim(itrim(occu))) //2 changes
replace flag20=flag20+1 if record_id==6|record_id==1511|record_id==2580|record_id==2198|record_id==2380 ///
						   |record_id==2399|record_id==2426|record_id==2955 //8 changes
/*replace corr_KG=corr_KG+1 if record_id==6 //1 change
replace corr_AH=corr_AH+1 if record_id==1511|record_id==2580 //2 changes
replace corr_intern=corr_intern+1 if record_id==2198|record_id==2380|record_id==2399|record_id==2426|record_id==2955 //5 changes
*/
count if event==1 & regexm(occu,"NIL")|event==1 & regexm(occu,"ND") //158 - 124 correct; 34 incorrect
//list record_id ddda occu if event==1 & regexm(occu,"NIL")|event==1 & regexm(occu,"ND")
count if event==1 & occu=="NIL"|event==1 & occu=="ND" //34
//list record_id ddda occu if event==1 & occu=="NIL"|event==1 & occu=="ND"
replace occu="99" if event==1 & occu=="NIL"|event==1 & occu=="ND" //34 changes
replace flag20=flag20+1 if record_id==610|record_id==632|record_id==636|record_id==931|record_id==984 ///
						   |record_id==987|record_id==1006|record_id==2102|record_id==2493|record_id==2496 ///
						   |record_id==2516|record_id==2548|record_id==654|record_id==664|record_id==667 ///
						   |record_id==690|record_id==710|record_id==751|record_id==791|record_id==823 ///
						   |record_id==921|record_id==1035|record_id==1058|record_id==1071|record_id==1152 ///
						   |record_id==1352|record_id==2198|record_id==2380|record_id==2399|record_id==2426 ///
						   |record_id==2648|record_id==2749|record_id==2838|record_id==2955 //34 changes
/*replace corr_NR=corr_NR+1 if record_id==610|record_id==632|record_id==636|record_id==931|record_id==984 ///
							 |record_id==987|record_id==1006|record_id==2102|record_id==2493|record_id==2496 ///
							 |record_id==2516|record_id==2548 //12 changes
replace corr_AH=corr_AH+1 if record_id==654|record_id==664|record_id==667|record_id==690|record_id==710 ///
							 |record_id==751|record_id==791|record_id==823|record_id==921|record_id==1035 ///
							 |record_id==1058|record_id==1071|record_id==1152|record_id==1352 //14 changes
replace corr_intern=corr_intern+1 if record_id==2198|record_id==2380|record_id==2399|record_id==2426|record_id==2648 ///
									 |record_id==2749|record_id==2838|record_id==2955 //8 changes
*/

** durationnum: Integer - min=0, max=99, if missing=99: FLAG 21
** (45) missing
count if event==1 & durationnum==. //0
** (46) invalid
count if durationnum==999 & durationtxt!=99 //39
//list record_id ddda durationnum durationtxt if durationnum==999 & durationtxt!=99
replace durationtxt=99 if durationnum==999 & durationtxt!=99 //39 changes
replace flag21=flag21+1 if record_id==465|record_id==477|record_id==722|record_id==1248|record_id==1366 ///
							 |record_id==1576|record_id==1787|record_id==1997|record_id==2010|record_id==2243 ///
							 |record_id==2278|record_id==2568|record_id==2623|record_id==2632|record_id==2978 ///
							 |record_id==3259|record_id==560|record_id==649|record_id==713|record_id==868 ///
							 |record_id==1463|record_id==621|record_id==1697|record_id==2213|record_id==3003 ///
							 |record_id==851|record_id==867|record_id==897|record_id==1109|record_id==1186 ///
							 |record_id==1336|record_id==1572|record_id==1584|record_id==1603|record_id==1903 ///
							 |record_id==2904|record_id==2388|record_id==2768|record_id==2845 //39 changes
/*replace corr_AH=corr_AH+1 if record_id==465|record_id==477|record_id==722|record_id==1248|record_id==1366 ///
							 |record_id==1576|record_id==1787|record_id==1997|record_id==2010|record_id==2243 ///
							 |record_id==2278|record_id==2568|record_id==2623|record_id==2632|record_id==2978 ///
							 |record_id==3259 //16 changes
replace corr_TH=corr_TH+1 if record_id==560|record_id==649|record_id==713|record_id==868|record_id==1463 //5 changes
replace corr_NR=corr_NR+1 if record_id==621|record_id==1697|record_id==2213|record_id==3003 //4 changes
replace corr_KG=corr_KG+1 if record_id==851|record_id==867|record_id==897|record_id==1109|record_id==1186 ///
							 |record_id==1336|record_id==1572|record_id==1584|record_id==1603|record_id==1903 ///
							 |record_id==2904 //11 changes
replace corr_intern=corr_intern+1 if record_id==2388|record_id==2768|record_id==2845 //3 changes
*/
count if durationnum==99 & durationtxt==99 //11
//list record_id ddda durationnum durationtxt if durationnum==99 & durationtxt==99
replace durationnum=999 if durationnum==99 & durationtxt==99 //11 changes


** durationtxt - 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 22
** (47) missing
count if durationnum!=. & durationtxt==. //133
//list record_id ddda durationnum durationtxt if durationnum!=. & durationtxt==.
replace durationnum=999 if durationnum!=. & durationtxt==. //133 changes
replace durationtxt=99 if durationnum==999 & durationtxt==. //133 changes
** (48) possibly invalid
count if durationnum!=999 & durationtxt==99 //4 - 1 incorrect; 3 correct
//list record_id ddda durationnum durationtxt onset* if durationnum!=999 & durationtxt==99
replace durationtxt=4 if record_id==3058 //1 change


** cod1a: Text, if missing=99: FLAG 23
** (49) missing
count if event==1 & cod1a=="" //0
** (50) invalid
count if event==1 & regexm(cod1a, "[a-z]") //3 - JC added in extra info in cod to redcap db field comment
//list record_id ddda cod1a onsetnumcod1a onsettxtcod1a if event==1 & regexm(cod1a, "[a-z]")
replace cod1a=subinstr(cod1a,"[< 5 min]","",.) if record_id==6 //1 change
replace onsetnumcod1a=1 if record_id==6 //1 change
replace onsettxtcod1a=1 if record_id==6 //1 change
replace cod1a=subinstr(cod1a,"(and 9 mths)","",.) if record_id==15 //1 change
replace cod1a=subinstr(cod1a,"(1 hr)","",.) if record_id==16 //1 change
replace onsettxtcod1a=1 if record_id==16 //1 change
replace cod1a=upper(cod1a) //0 changes
replace cod1a = rtrim(ltrim(itrim(cod1a))) //13 changes
replace flag23=flag23+1 if record_id==6|record_id==15|record_id==16 //3 changes
//replace corr_KG=corr_KG+1 if record_id==6|record_id==15|record_id==16 //3 changes
count if event==1 & regexm(cod1a,"NIL")|event==1 & regexm(cod1a,"ND") //226 - all correct
//list record_id ddda cod1a if event==1 & regexm(cod1a,"NIL")|event==1 & regexm(cod1a,"ND")


** onsetnumcod1a: Integer - min=0, max=99, if missing=99: FLAG 24
** (51) missing
count if event==1 & cod1a!="99" & onsetnumcod1a==. //0
** (52) possibly invalid
count if onsetnumcod1a==999 & onsettxtcod1a!=99 //72 - all correct
//list record_id ddda onsetnumcod1a onsettxtcod1a if onsetnumcod1a==999 & onsettxtcod1a!=99
count if onsetnumcod1a==99 & onsettxtcod1a==99 //5
//list record_id ddda onsetnumcod1a onsettxtcod1a if onsetnumcod1a==99 & onsettxtcod1a==99
replace onsetnumcod1a=999 if onsetnumcod1a==99 & onsettxtcod1a==99 //5 changes


** onsettxtcod1a: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 25
** (53) missing
count if onsetnumcod1a!=. & onsettxtcod1a==. //266
//list record_id ddda onsetnumcod1a onsettxtcod1a if onsetnumcod1a!=. & onsettxtcod1a==.
replace onsettxtcod1a=3 if record_id==1253
replace flag25=flag25+1 if record_id==1253
//replace corr_AH=corr_AH+1 if record_id==1253
replace onsetnumcod1a=999 if onsetnumcod1a!=. & onsettxtcod1a==. //265 changes
count if onsetnumcod1a==999 & onsettxtcod1a==. //265
replace onsettxtcod1a=99 if onsetnumcod1a==999 & onsettxtcod1a==. //265 changes
** (54) possibly invalid
count if onsetnumcod1a!=999 & onsettxtcod1a==99 //10 - all correct
//list record_id ddda onsetnumcod1a onsettxtcod1a onset* if onsetnumcod1a!=999 & onsettxtcod1a==99


** cod1b: Text, if missing=99: FLAG 26
** (55) missing
count if event==1 & cod1b=="" //0
** (56) invalid
count if event==1 & regexm(cod1b, "[a-z]") //3 - JC added in extra info in cod to redcap db field comment
//list record_id ddda cod1b onsetnumcod1b onsettxtcod1b if event==1 & regexm(cod1b, "[a-z]")
replace cod1b=subinstr(cod1b,"(yrs)","",.) if record_id==12 //1 change
replace onsettxtcod1b=4 if record_id==12 //1 change
replace cod1b=subinstr(cod1b,"(>10 yrs)","",.) if record_id==16 //1 change
replace onsetnumcod1b=10 if record_id==16 //1 change
replace onsettxtcod1b=4 if record_id==16 //1 change
replace cod1b=upper(cod1b) //1 change
replace cod1b = rtrim(ltrim(itrim(cod1b))) //8 changes
replace flag26=flag26+1 if record_id==12|record_id==16 //2 changes
//replace corr_KG=corr_KG+1 if record_id==12|record_id==16 //2 changes
count if event==1 & regexm(cod1b,"NIL")|event==1 & regexm(cod1b,"ND") //124 - all correct
//list record_id ddda cod1b if event==1 & regexm(cod1b,"NIL")|event==1 & regexm(cod1b,"ND")


** onsetnumcod1b: Integer - min=0, max=99, if missing=99: FLAG 27
** (57) missing
count if event==1 & cod1b!="99" & onsetnumcod1b==. //0
** (58) possibly invalid
count if onsetnumcod1b==999 & onsettxtcod1b!=99 //58 - all correct
//list record_id ddda onsetnumcod1b onsettxtcod1b if onsetnumcod1b==999 & onsettxtcod1b!=99
count if onsetnumcod1b==99 & onsettxtcod1b==99 //2
//list record_id ddda onsetnumcod1b onsettxtcod1b if onsetnumcod1b==99 & onsettxtcod1b==99
replace onsetnumcod1b=999 if onsetnumcod1b==99 & onsettxtcod1b==99 //2 changes


** onsettxtcod1b: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 28
** (59) missing
count if onsetnumcod1b!=. & onsettxtcod1b==. //170
//list record_id ddda onsetnumcod1b onsettxtcod1b if onsetnumcod1b!=. & onsettxtcod1b==.
replace onsetnumcod1b=999 if onsetnumcod1b!=. & onsettxtcod1b==. //170 changes
count if onsetnumcod1b==999 & onsettxtcod1b==. //170
replace onsettxtcod1b=99 if onsetnumcod1b==999 & onsettxtcod1b==. //170 changes
** (60) possibly invalid
count if onsetnumcod1b!=999 & onsettxtcod1b==99 //1 - all correct
//list record_id ddda onsetnumcod1b onsettxtcod1b onset* if onsetnumcod1b!=999 & onsettxtcod1b==99


** cod1c: Text, if missing=99: FLAG 29
** (61) missing
count if event==1 & cod1c=="" //0
** (62) invalid
count if event==1 & regexm(cod1c, "[a-z]") //2 - JC added in extra info in cod to redcap db field comment
//list record_id ddda cod1c onsetnumcod1c onsettxtcod1c if event==1 & regexm(cod1c, "[a-z]")
replace cod1c=subinstr(cod1c,"(yrs)","",.) if record_id==12 //1 change
replace onsettxtcod1c=4 if record_id==12 //1 change
replace cod1c=subinstr(cod1c,"(>10yrs)","",.) if record_id==16 //1 change
replace onsetnumcod1c=10 if record_id==16 //1 change
replace onsettxtcod1c=4 if record_id==16 //1 change
replace cod1c=upper(cod1c) //0 changes
replace cod1c = rtrim(ltrim(itrim(cod1c))) //5 changes
replace flag29=flag29+1 if record_id==12|record_id==16 //2 changes
//replace corr_KG=corr_KG+1 if record_id==12|record_id==16 //2 changes
count if event==1 & regexm(cod1c,"NIL")|event==1 & regexm(cod1c,"ND") //37 - all correct
//list record_id ddda cod1c if event==1 & regexm(cod1c,"NIL")|event==1 & regexm(cod1c,"ND")


** onsetnumcod1c: Integer - min=0, max=99, if missing=99: FLAG 30
** (63) missing
count if event==1 & cod1c!="99" & onsetnumcod1c==. //1
//list record_id ddda cod1c onsetnumcod1c onsettxtcod1c if event==1 & cod1c!="99" & onsetnumcod1c==.
replace onsetnumcod1c=999 if record_id==821 //1 change
replace onsettxtcod1c=99 if record_id==821 //1 change
replace flag30=flag30+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (64) possibly invalid
count if onsetnumcod1c==999 & onsettxtcod1c!=99 //19 - 1 incorrect; 18 correct
//list record_id ddda onsetnumcod1c onsettxtcod1c if onsetnumcod1c==999 & onsettxtcod1c!=99
replace onsettxtcod1c=99 if record_id==1239 //1 change
replace flag30=flag30+1 if record_id==1239 //1 change
//replace corr_AH=corr_AH+1 if record_id==1239 //1 change
count if onsetnumcod1c==99 & onsettxtcod1c==99 //0
//list record_id ddda onsetnumcod1c onsettxtcod1c if onsetnumcod1c==99 & onsettxtcod1c==99


** onsettxtcod1c: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 31
** (65) missing
count if onsetnumcod1c!=. & onsettxtcod1c==. //74
//list record_id ddda onsetnumcod1c onsettxtcod1c if onsetnumcod1c!=. & onsettxtcod1c==.
replace flag31=flag31+1 if record_id==1239 //1 change
//replace corr_AH=corr_AH+1 if record_id==1239 //1 change
replace onsetnumcod1c=999 if onsetnumcod1c!=. & onsettxtcod1c==. //73 changes
count if onsetnumcod1c==999 & onsettxtcod1c==. //74
replace onsettxtcod1c=99 if onsetnumcod1c==999 & onsettxtcod1c==. //74 changes
** (66) possibly invalid
count if onsetnumcod1c!=999 & onsettxtcod1c==99 //1 - all correct
//list record_id ddda onsetnumcod1c onsettxtcod1c onset* if onsetnumcod1c!=999 & onsettxtcod1c==99


** cod1d: Text, if missing=99: FLAG 32
** (67) missing
count if event==1 & cod1d=="" //1
//list record_id ddda cod1d if event==1 & cod1d==""
replace cod1d="99" if record_id==821 //1 change
replace flag32=flag32+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (68) invalid
count if event==1 & regexm(cod1d, "[a-z]") //0
//list record_id ddda cod1d onsetnumcod1d onsettxtcod1d if event==1 & regexm(cod1d, "[a-z]")
replace cod1d=upper(cod1d) //0 changes
replace cod1d = rtrim(ltrim(itrim(cod1d))) //2 changes
count if event==1 & regexm(cod1d,"NIL")|event==1 & regexm(cod1d,"ND") //3 - all correct
//list record_id ddda cod1d if event==1 & regexm(cod1d,"NIL")|event==1 & regexm(cod1d,"ND")


** onsetnumcod1d: Integer - min=0, max=99, if missing=99: FLAG 33
** (69) missing
count if event==1 & cod1d!="99" & onsetnumcod1d==. //0
//list record_id ddda cod1d onsetnumcod1d onsettxtcod1d if event==1 & cod1d!="99" & onsetnumcod1d==.
** (70) possibly invalid
count if onsetnumcod1d==999 & onsettxtcod1d!=99 //9 - all correct
//list record_id ddda onsetnumcod1d onsettxtcod1d if onsetnumcod1d==999 & onsettxtcod1d!=99
count if onsetnumcod1d==99 & onsettxtcod1d==99 //0
//list record_id ddda onsetnumcod1d onsettxtcod1d if onsetnumcod1d==99 & onsettxtcod1d==99


** onsettxtcod1d: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 34
** (71) missing
count if onsetnumcod1d!=. & onsettxtcod1d==. //11
//list record_id ddda onsetnumcod1d onsettxtcod1d if onsetnumcod1d!=. & onsettxtcod1d==.
replace onsetnumcod1d=999 if onsetnumcod1d!=. & onsettxtcod1d==. //11 changes
count if onsetnumcod1d==999 & onsettxtcod1d==. //11
replace onsettxtcod1d=99 if onsetnumcod1d==999 & onsettxtcod1d==. //11 changes
** (72) possibly invalid
count if onsetnumcod1d!=999 & onsettxtcod1d==99 //1
//list record_id ddda onsetnumcod1d onsettxtcod1d onset* if onsetnumcod1d!=999 & onsettxtcod1d==99
replace onsettxtcod1d=4 if record_id==2964 //1 change


** cod2a: Text, if missing=99: FLAG 35
** (73) missing
count if event==1 & cod2a=="" //1
//list record_id ddda cod2a if event==1 & cod2a==""
replace cod2a="99" if record_id==821 //1 change
replace flag35=flag35+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (74) invalid
count if event==1 & regexm(cod2a, "[a-z]") //3 - JC added in extra info in cod to redcap db field comment
//list record_id ddda cod2a onsetnumcod2a onsettxtcod2a if event==1 & regexm(cod2a, "[a-z]")
replace cod2a=subinstr(cod2a,"(yrs)","",.) if record_id==12 //1 change
replace onsettxtcod2a=4 if record_id==12 //1 change
replace cod2a=upper(cod2a) //2 changes
replace cod2a = rtrim(ltrim(itrim(cod2a))) //3 changes
replace flag35=flag35+1 if record_id==12 //1 change
//replace corr_KG=corr_KG+1 if record_id==12 //1 change
count if event==1 & regexm(cod2a,"NIL")|event==1 & regexm(cod2a,"ND") //58 - all correct
//list record_id ddda cod2a if event==1 & regexm(cod2a,"NIL")|event==1 & regexm(cod2a,"ND")


** onsetnumcod2a: Integer - min=0, max=99, if missing=99: FLAG 36
** (75) missing
count if event==1 & cod2a!="99" & onsetnumcod2a==. //0
//list record_id ddda cod2a onsetnumcod2a onsettxtcod2a if event==1 & cod2a!="99" & onsetnumcod2a==.
** (76) possibly invalid
count if onsetnumcod2a==999 & onsettxtcod2a!=99 //83 - all correct
//list record_id ddda onsetnumcod2a onsettxtcod2a if onsetnumcod2a==999 & onsettxtcod2a!=99
count if onsetnumcod2a==99 & onsettxtcod2a==99 //6
//list record_id ddda onsetnumcod2a onsettxtcod2a if onsetnumcod2a==99 & onsettxtcod2a==99
replace flag36=flag36+1 if record_id==1257 //1 change
//replace corr_AH=corr_AH+1 if record_id==1257 //1 change
replace onsetnumcod2a=999 if onsetnumcod2a==99 & onsettxtcod2a==99 //6 changes


** onsettxtcod2a: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 37
** (77) missing
count if onsetnumcod2a!=. & onsettxtcod2a==. //129
//list record_id ddda onsetnumcod2a onsettxtcod2a if onsetnumcod2a!=. & onsettxtcod2a==.
replace onsetnumcod2a=999 if onsetnumcod2a!=. & onsettxtcod2a==. //129 changes
count if onsetnumcod2a==999 & onsettxtcod2a==. //129
replace onsettxtcod2a=99 if onsetnumcod2a==999 & onsettxtcod2a==. //129 changes
** (78) possibly invalid
count if onsetnumcod2a!=999 & onsettxtcod2a==99 //1 - all correct
//list record_id ddda onsetnumcod2a onsettxtcod2a onset* if onsetnumcod2a!=999 & onsettxtcod2a==99


** cod2b: Text, if missing=99: FLAG 38
** (79) missing
count if event==1 & cod2b=="" //1
//list record_id ddda cod2b if event==1 & cod2b==""
replace cod2b="99" if record_id==821 //1 change
replace flag38=flag38+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (80) invalid
count if event==1 & regexm(cod2b, "[a-z]") //1 - JC added in extra info in cod to redcap db field comment
//list record_id ddda cod2b onsetnumcod2b onsettxtcod2b if event==1 & regexm(cod2b, "[a-z]")
replace cod2b=subinstr(cod2b,"(yrs)","",.) if record_id==1 //1 change
replace onsetnumcod2b=999 if record_id==1 //1 change
replace onsettxtcod2b=4 if record_id==1 //1 change
replace cod2b=upper(cod2b) //0 changes
replace cod2b = rtrim(ltrim(itrim(cod2b))) //3 changes
replace flag38=flag38+1 if record_id==1 //1 change
//replace corr_KG=corr_KG+1 if record_id==1 //1 change
count if event==1 & regexm(cod2b,"NIL")|event==1 & regexm(cod2b,"ND") //16 - all correct
//list record_id ddda cod2b if event==1 & regexm(cod2b,"NIL")|event==1 & regexm(cod2b,"ND")


** onsetnumcod2b: Integer - min=0, max=99, if missing=99: FLAG 39
** (81) missing
count if event==1 & cod2b!="99" & onsetnumcod2b==. //0
//list record_id ddda cod2b onsetnumcod2b onsettxtcod2b if event==1 & cod2b!="99" & onsetnumcod2b==.
** (82) possibly invalid
count if onsetnumcod2b==999 & onsettxtcod2b!=99 //43 - all correct
//list record_id ddda onsetnumcod2b onsettxtcod2b if onsetnumcod2b==999 & onsettxtcod2b!=99
count if onsetnumcod2b==99 & onsettxtcod2b==99 //2
//list record_id ddda onsetnumcod2b onsettxtcod2b if onsetnumcod2b==99 & onsettxtcod2b==99
replace flag39=flag39+1 if record_id==1257 //1 change
//replace corr_AH=corr_AH+1 if record_id==1257 //1 change
replace onsetnumcod2b=999 if onsetnumcod2b==99 & onsettxtcod2b==99 //2 changes


** onsettxtcod2b: 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND": FLAG 40
** (83) missing
count if onsetnumcod2b!=. & onsettxtcod2b==. //67
//list record_id ddda onsetnumcod2b onsettxtcod2b if onsetnumcod2b!=. & onsettxtcod2b==.
replace onsetnumcod2b=999 if onsetnumcod2b!=. & onsettxtcod2b==. //67 changes
count if onsetnumcod2b==999 & onsettxtcod2b==. //67
replace onsettxtcod2b=99 if onsetnumcod2b==999 & onsettxtcod2b==. //67 changes
** (84) possibly invalid
count if onsetnumcod2b!=999 & onsettxtcod2b==99 //1 - all correct
//list record_id ddda onsetnumcod2b onsettxtcod2b onset* if onsetnumcod2b!=999 & onsettxtcod2b==99


** pod: Text, if missing=99: FLAG 41
** (85) missing
count if event==1 & pod=="" //
//list record_id ddda pod if event==1 & pod==""
replace pod="99" if record_id==821 //1 change
replace flag41=flag41+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (86) invalid
count if event==1 & regexm(pod, "[a-z]") //
//list record_id ddda pod if event==1 & regexm(pod, "[a-z]")
replace pod=upper(pod) //1 change
replace pod = rtrim(ltrim(itrim(pod))) //4 changes
replace flag41=flag41+1 if record_id==2164 //1 change
//replace corr_AH=corr_AH+1 if record_id==2164 //1 change
count if event==1 & regexm(pod,"NIL")|event==1 & regexm(pod,"ND") //256 - all correct
//list record_id ddda pod if event==1 & regexm(pod,"NIL")|event==1 & regexm(pod,"ND")


** deathparish: FLAG 42
** (87) missing
count if event==1 & deathparish==. //0
//list record_id ddda deathparish if event==1 & deathparish==.
replace deathparish=99 if record_id==821 //1 change
replace flag42=flag42+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (88) invalid - see district demarcations noted below:
/*	Districts are assigned based on death parish
		District A - anything below top rock christ church and st. michael 
		District B - anything above top rock christ church and st. george
		District C - st. philip and st. john
		District D - st. thomas
		District E - st. james, st. peter, st. lucy
		District F - st. joseph, st. andrew
*/
** (88) Christ Church
count if deathparish==1 & district!=1 //249 - all correct
//list record_id ddda district pod deathparish if deathparish==1 & district!=1
** (89) St Andrew
count if deathparish==2 & district!=6 //2
//list record_id ddda deathparish district pod if deathparish==2 & district!=6
replace flag42=flag42+1 if record_id==2535 //1 change
//replace corr_NR=corr_NR+1 if record_id==2535 //1 change
replace deathparish=8 if record_id==2535 //1 change
** (90) St George
count if deathparish==3 & district!=2 //1 - incorrect district from registry (used redcapdb TF)
//list record_id ddda deathparish district pod if deathparish==3 & district!=2
** (91) St James
count if deathparish==4 & district!=5 //3
//list record_id ddda deathparish district pod if deathparish==4 & district!=5
replace flag42=flag42+1 if record_id==189|record_id==3305 //2 changes
//replace corr_KG=corr_KG+1 if record_id==189|record_id==3305 //2 changes
replace deathparish=8 if record_id==189|record_id==3305 //2 changes
** (92) St John
count if deathparish==5 & district!=3 //3
//list record_id ddda deathparish district pod if deathparish==5 & district!=3
replace flag42=flag42+1 if record_id==1579|record_id==1710|record_id==2915 //3 changes
//replace corr_AH=corr_AH+1 if record_id==1579|record_id==1710 //2 changes
//replace corr_KG=corr_KG+1 if record_id==2915 //1 change
replace deathparish=8 if record_id==1579|record_id==1710|record_id==2915 //3 changes
** (93) St Joseph
count if deathparish==6 & district!=6 //2
//list record_id ddda deathparish district pod if deathparish==6 & district!=6
replace flag42=flag42+1 if record_id==666 //1 change
//replace corr_AH=corr_AH+1 if record_id==666 //1 change
replace deathparish=8 if record_id==666 //1 change
** (94) St Joseph
count if deathparish==7 & district!=5 //1
//list record_id ddda deathparish district pod if deathparish==7 & district!=5
replace flag42=flag42+1 if record_id==54 //1 change
//replace corr_KG=corr_KG+1 if record_id==54 //1 change
replace deathparish=8 if record_id==54 //1 change
** (95) St Michael
count if deathparish==8 & district!=1 //3 - incorrect district from registry (used redcapdb TF)
//list record_id ddda deathparish district pod if deathparish==8 & district!=1
** (96) St Peter
count if deathparish==9 & district!=5 //2
//list record_id ddda deathparish district pod if deathparish==9 & district!=5
replace flag42=flag42+1 if record_id==1605|record_id==2595 //2 changes
//replace corr_KG=corr_KG+1 if record_id==1605 //1 change
//replace corr_AH=corr_AH+1 if record_id==2595 //1 change
replace deathparish=8 if record_id==1605|record_id==2595 //2 changes
** (97) St Philip
count if deathparish==10 & district!=3 //1
//list record_id ddda deathparish district pod if deathparish==10 & district!=3
replace flag42=flag42+1 if record_id==2226 //1 change
//replace corr_KG=corr_KG+1 if record_id==2226 //1 change
replace deathparish=8 if record_id==2226 //1 change
** (98) St Thomas
count if deathparish==11 & district!=4 //2 - incorrect district from registry (used redcapdb TF)
//list record_id ddda deathparish district pod if deathparish==11 & district!=4


** regdate: Y-M-D: FLAG 43
** (99) missing
count if event==1 & regdate==. //2 - field comment indicates ND for record_id 1223
//list record_id ddda dod regdate if event==1 & regdate==.
replace flag43=flag43+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (100) invalid - future date
count if event==1 & regdate!=. & regdate>today //9
sort record_id
//list record_id ddda dod regdate pname if event==1 & regdate!=. & regdate>today
replace regdate=regdate-328718 if record_id==1229|record_id==1253|record_id==1304|record_id==1312 //4 changes
replace regdate=regdate-365 if record_id==1649|record_id==1676|record_id==1812|record_id==2066|record_id==2964 //5 changes
replace flag43=flag43+1 if record_id==1229|record_id==1253|record_id==1304|record_id==1312|record_id==1649 ///
							 |record_id==2066|record_id==2964|record_id==1676|record_id==1812 //9 changes
/*replace corr_AH=corr_AH+1 if record_id==1229|record_id==1253|record_id==1304|record_id==1312|record_id==1649 ///
							 |record_id==2066|record_id==2964 //7 changes
replace corr_NR=corr_NR+1 if record_id==1676 //1 change
replace corr_intern=corr_intern+1 if record_id==1812 //1 change
*/


** certifier: Text, if missing=99: FLAG 44
** (101) missing
count if event==1 & certifier=="" //1
//list record_id ddda certifier if event==1 & certifier==""
replace certifier="99" if record_id==821 //1 change
replace flag44=flag44+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
count if certifier=="999" //1 - 2018 redcapdb had 999 as ND code in field note
replace certifier="99" if certifier=="999" //1 change
** (102) invalid
count if event==1 & regexm(certifier, "[a-z]") //1
//list record_id ddda certifier if event==1 & regexm(certifier, "[a-z]")
replace certifier=upper(certifier) //1 change
replace certifier = rtrim(ltrim(itrim(certifier))) //5 changes
replace flag44=flag44+1 if record_id==2894 //1 change
//replace corr_KG=corr_KG+1 if record_id==2894 //1 change
count if event==1 & regexm(certifier,"NIL")|event==1 & regexm(certifier,"ND") //347 - all correct
//list record_id ddda certifier if event==1 & regexm(certifier,"NIL")|event==1 & regexm(certifier,"ND")


** certifieraddr: Text, if missing=99: FLAG 45
** (103) missing
count if event==1 & certifieraddr=="" //1
//list record_id ddda certifieraddr if event==1 & certifieraddr==""
replace certifieraddr="99" if record_id==821 //1 change
replace flag45=flag45+1 if record_id==821 //1 change
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (104) invalid
count if event==1 & regexm(certifieraddr, "[a-z]") //2
//list record_id ddda certifieraddr if event==1 & regexm(certifieraddr, "[a-z]")
replace certifieraddr=upper(certifieraddr) //2 changes
replace certifieraddr = rtrim(ltrim(itrim(certifieraddr))) //16 changes
replace flag45=flag45+1 if record_id==2894|record_id==3096 //1 change
//replace corr_KG=corr_KG+1 if record_id==2894 //1 change
//replace corr_AH=corr_AH+1 if record_id==3096 //1 change
count if event==1 & regexm(certifieraddr,"NIL")|event==1 & regexm(certifieraddr,"ND") //171 - all correct
//list record_id ddda certifieraddr if event==1 & regexm(certifieraddr,"NIL")|event==1 & regexm(certifieraddr,"ND")


** namematch: readonly: FLAG 46
** (105) missing
count if event==1 & namematch==. //3,210 - already checked for duplicates above
replace namematch=2 if event==1 & namematch==. //3,210 changes
//list record_id ddda namematch if event==1 & namematch==.


** death_certificate_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete: FLAG 47
** (106) missing
count if event==1 & recstatdc==. //0
** (107) invalid - incomplete and no reason given in field comment of redcapdb
count if event==1 & recstatdc==0 //3
//list record_id ddda dddoa recstatdc if event==1 & recstatdc==0
replace recstatdc=2 if record_id==189|record_id==198|record_id==821 //3 changes
replace flag47=flag47+1 if record_id==189|record_id==198|record_id==821 //3 changes
//replace corr_KG=corr_KG+1 if record_id==189|record_id==198 //2 changes
//replace corr_AH=corr_AH+1 if record_id==821 //1 change
** (108) invalid - unverified and no reason given in field comment of redcapdb
count if event==1 & recstatdc==1 //0



*******************
** TRACKING FORM **
*******************

** tfdddoa: Y-M-D H:M, readonly: FLAG 48
** (109) missing
count if event==2 & tfdddoa==. //0


** tfddda: readonly, user logged into redcap: FLAG 49
** (110) missing
count if event==2 & tfddda==. //0


** tfregnumstart: integer: FLAG 50
** (111) missing
count if event==2 & tfregnumstart==. //0


** tfdistrictstart: letters only: FLAG 51
** (112) missing
count if event==2 & tfdistrictstart=="" //0
** (113) invalid
count if event==2 & regexm(tfdistrictstart, "[a-z]") //0
replace tfdistrictstart = rtrim(ltrim(itrim(tfdistrictstart))) //0 changes


** tfregnumend: integer: FLAG 52
** (114) missing
count if event==2 & tfregnumend==. //1
//list record_id tfddda tfregnumend if event==2 & tfregnumend==.
replace tfregnumend=9999 if event==2 & tfregnumend==. //1 change
replace flag52=flag52+1 if record_id==2065 //1 change
//replace corr_KWG=corr_KWG+1 if record_id==2065 //1 change


** tfdistrictend: letters only: FLAG 53
** (115) missing
count if event==2 & tfdistrictend=="" //1
//list record_id tfddda tfdistrictend if event==2 & tfdistrictend==""
replace tfdistrictend="B" if event==2 & tfdistrictend=="" //1 change
replace flag53=flag53+1 if record_id==2065 //1 change
//replace corr_KWG=corr_KWG+1 if record_id==2065 //1 change
** (116) invalid
count if event==2 & regexm(tfdistrictend, "[a-z]") //0
replace tfdistrictend = rtrim(ltrim(itrim(tfdistrictend))) //0 changes


** tfddtxt: FLAG 54
replace tfddtxt = rtrim(ltrim(itrim(tfddtxt))) //48 changes


** tracking_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete: FLAG 55
** (117) missing
count if event==2 & recstattf==. //0
** (118) invalid - incomplete and no reason given in field comment of redcapdb
count if event==2 & recstattf==0 //1
//list record_id tfddda tfdddoa recstattf if event==2 & recstattf==0
replace recstattf=2 if record_id==2065 //1 change
replace flag55=flag55+1 if record_id==2065 //1 change
//replace corr_KWG=corr_KWG+1 if record_id==2065 //1 change
** (119) invalid - unverified and no reason given in field comment of redcapdb
count if event==2 & recstattf==1 //0

** REMOVE dod>2018
drop if event==1 & dodyear>2018 //596

** ORDER variables according to position in DeathData REDCap database
order record_id event dddoa ddda odda certtype regnum district pname address parish ///
	  sex age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
	  cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
	  cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
	  cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
	  pod deathparish regdate certifier certifieraddr namematch recstatdc ///
	  tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddtxt recstattf

count //2,719 - 29 duplicate records + 596 '2019' deaths were dropped above

label data "BNR MORTALITY data 2008-2018"
notes _dta :These data prepared from BB national death register & BNR (Redcap) deathdata database
save "`datapath'\version01\3-output\2018_deaths_cleaned_dqi_dc" ,replace


** REMOVE variables and labels not needed in DeathData REDCap database
drop today birthdate flag*
label drop _all

** REDCap will not import H:M:S format so had to change cfdate from %tcCCYY-NN-DD_HH:MM:SS to below format
format dddoa tfdddoa %tcCCYY-NN-DD_HH:MM
	  
count //2,719 - 29 duplicate records + 596 '2019' deaths were dropped above

label data "BNR MORTALITY data 2008-2018"
notes _dta :These data prepared from BB national death register & BNR (Redcap) deathdata database
save "`datapath'\version01\3-output\2018_deaths_cleaned_export_dc" ,replace

