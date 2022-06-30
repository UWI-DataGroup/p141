** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1a_prep_deaths.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-APR-2022
    // 	date last modified      30-JUN-2022
    //  algorithm task          Prep and format death data
    //  status                  Completed
    //  objectve                To have one dataset with cleaned 2020 death data.
    //  note                    Cleaned 2021 dataset to be merged with multi-year (2008-2020) death dataset; 
    //                          REDCap database with ALL cleaned deaths to be created.

    
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
    log using "`logpath'\1a_prep_deaths_2021.smcl", replace
** HEADER -----------------------------------------------------

** JC 30jun2022: Below records (3232 + 3233) added by KG after completion of 2021 cleaning so manually reviewed and cleaned; Included in this process in prep for cancer annual report process
import excel using "`datapath'\version07\1-input\BNRDeathData2021-Exporting32323233_DATA_2022-06-30_1337_excel.xlsx" , firstrow case(lower)
count //2
tostring cod1d cod2a cod2b ,replace


********************
** DATA PREPARATION  
********************
append using "`datapath'\version07\2-working\2021_deaths_imported_dp"

count //3,112; 3231; 3232

*******************
** DATA FORMATTING  
*******************
** PREPARE each variable according to the format and order in which they appear in DeathData REDCap database

************************
**  DEATH CERTIFICATE **
**        FORM        **
************************

** (1) record_id (auto-generated by REDCap)
label var record_id "DeathID"

** (2) redcap_event_name (auto-generated by REDCap)
gen event=.
replace event=1 if redcap_event_name=="death_data_collect_arm_1"
replace event=2 if redcap_event_name=="tracking_arm_2"

label var event "Redcap Event Name"
label define event_lab 1 "DC arm 1" 2 "TF arm 2", modify
label values event event_lab

** (3) dddoa: Y-M-D H:M, readonly
gen double dddoa2 = clock(dddoa, "YMDhm")
format dddoa2 %tcCCYY-NN-DD_HH:MM
drop dddoa
rename dddoa2 dddoa
label var dddoa "ABS DateTime"

** (4) ddda
label var ddda "ABS DA"
label define ddda_lab 4 "KG" 13 "KWG" 14 "TH" 20 "NR" 25 "AH" 98 "intern", modify
label values ddda ddda_lab

** (5) odda
if odda==. tostring odda ,replace
replace odda="" if odda=="."
label var odda "ABS Other DA"

** (6) certtype: 1=MEDICAL 2=POST MORTEM 3=CORONER 99=ND, required
label var certtype "Certificate Type"
label define certtype_lab 1 "Medical" 2 "Post Mortem" 3 "Coroner" 99 "ND", modify
label values certtype certtype_lab

** (7) regnum: integer, if missing=9999
label var regnum "Registry Dept #"

** (8) district: 1=A 2=B 3=C 4=D 5=E 6=F
/* Districts are assigned based on death parish
	District A - anything below top rock christ church and st. michael 
	District B - anything above top rock christ church and st. george
	District C - st. philip and st. john
	District D - st. thomas
	District E - st. james, st. peter, st. lucy
	District F - st. joseph, st. andrew
*/
label var district "District"
label define district_lab 1 "A" 2 "B" 3 "C" 4 "D" 5 "E" 6 "F", modify
label values district district_lab

** (9) pname: Text, if missing=99
label var pname "Deceased's Name"
replace pname = rtrim(ltrim(itrim(pname))) //5 changes

** (10) address: Text, if missing=99
label var address "Deceased's Address"
replace address = rtrim(ltrim(itrim(address))) //20 changes

** (11) parish
label var parish "Deceased's Parish"
label define parish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "ND", modify
label values parish parish_lab

** (12) sex:	1=Male 2=Female 99=ND
label var sex "Sex"
label define sex_lab 1 "Male" 2 "Female" 99 "ND", modify
label values sex sex_lab

** (13) age: Integer - min=0, max=999
label var age "Age"

** (14) agetxt
label var agetxt "Age Qualifier"
label define agetxt_lab 1 "Minutes" 2 "Hours" 3 "Days" 4 "Weeks" 5 "Months" 6 "Years" 99 "ND", modify
label values agetxt agetxt_lab

** (15) nrnnd: 1=Yes 2=No
label define nrnnd_lab 1 "Yes" 2 "No", modify
label values nrnnd nrnnd_lab
label var nrnnd "Is National ID # documented?"

** (16) nrn: dob-####, partial missing=dob-9999, if missing=.
label var nrn "National ID #"
format nrn %15.0g

** (17) mstatus: 1=Single 2=Married 3=Separated/Divorced 4=Widowed/Widow/Widower 99=ND
label var mstatus "Marital Status"
label define mstatus_lab 1 "Single" 2 "Married" 3 "Separated/Divorced" 4 "Widowed/Widow/Widower" 99 "ND", modify
label values mstatus mstatus_lab

** (18) occu: Text, if missing=99
label var occu "Occupation"

** (19) durationnum: Integer - min=0, max=99, if missing=99
label var durationnum "Duration of Illness"

** (20) durationtxt
label var durationtxt "Duration Qualifier"
label define durationtxt_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values durationtxt durationtxt_lab

** (21) dod: Y-M-D
format dod %tdCCYY-NN-DD
label var dod "Date of Death"

** (22) dodyear (not included in single year Redcap db but done for multi-year Redcap db)
drop dodyear
gen int dodyear=year(dod)
label var dodyear "Year of Death"

** (23) cod1a: Text, if missing=99
label var cod1a "COD 1a"

** (24) onsetnumcod1a: Integer - min=0, max=99, if missing=99
label var onsetnumcod1a "Onset Death Interval-COD 1a"

** (25) onsettxtcod1a: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1a "Onset Qualifier-COD 1a"
label define onsettxtcod1a_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1a onsettxtcod1a_lab

** (26) cod1b: Text, if missing=99
label var cod1b "COD 1b"

** (27) onsetnumcod1b: Integer - min=0, max=99, if missing=99
label var onsetnumcod1b "Onset Death Interval-COD 1b"

** (28) onsettxtcod1b: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1b "Onset Qualifier-COD 1b"
label define onsettxtcod1b_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1b onsettxtcod1b_lab

** (29) cod1c: Text, if missing=99
label var cod1c "COD 1c"

** (30) onsetnumcod1c: Integer - min=0, max=99, if missing=99
label var onsetnumcod1c "Onset Death Interval-COD 1c"

** (31) onsettxtcod1c: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1c "Onset Qualifier-COD 1c"
label define onsettxtcod1c_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1c onsettxtcod1c_lab

** (32) cod1d: Text, if missing=99
label var cod1d "COD 1d"

** (33) onsetnumcod1d: Integer - min=0, max=99, if missing=99
label var onsetnumcod1d "Onset Death Interval-COD 1d"

** (34) onsettxtcod1d: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod1d "Onset Qualifier-COD 1d"
label define onsettxtcod1d_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod1d onsettxtcod1d_lab

** (35) cod2a: Text, if missing=99
label var cod2a "COD 2a"

** (36) onsetnumcod2a: Integer - min=0, max=99, if missing=99
label var onsetnumcod2a "Onset Death Interval-COD 2a"

** (37) onsettxtcod2a: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod2a "Onset Qualifier-COD 2a"
label define onsettxtcod2a_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod2a onsettxtcod2a_lab

** (38) cod2b: Text, if missing=99
label var cod2b "COD 2b"

** (39) onsetnumcod2b: Integer - min=0, max=99, if missing=99
label var onsetnumcod2b "Onset Death Interval-COD 2b"

** (40) onsettxtcod2b: 1=DAYS 2=WEEKS 3=MONTHS 4=YEARS
label var onsettxtcod2b "Onset Qualifier-COD 2b"
label define onsettxtcod2b_lab 1 "Days" 2 "Weeks" 3 "Months" 4 "Years" 99 "ND", modify
label values onsettxtcod2b onsettxtcod2b_lab

** (41) pod: Text, if missing=99
label var pod "Place of Death"

** (42) deathparish
label var deathparish "Death Parish"
label define deathparish_lab 1 "Christ Church" 2 "St. Andrew" 3 "St. George" 4 "St. James" 5 "St. John" 6 "St. Joseph" ///
						7 "St. Lucy" 8 "St. Michael" 9 "St. Peter" 10 "St. Philip" 11 "St. Thomas" 99 "ND", modify
label values deathparish deathparish_lab

** (43) regdate: Y-M-D
label var regdate "Date of Registration"
format regdate %tdCCYY-NN-DD

** (44) certifier: Text, if missing=99
label var certifier "Name of Certifier"

** (45) certifieraddr: Text, if missing=99
label var certifieraddr "Address of Certifier"

** (46) namematch: readonly
label var namematch "Name Match"
label define namematch_lab 1 "names match but different person" 2 "no name match", modify
label values namematch namematch_lab

** (47) death_certificate_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete
rename death_certificate_complete recstatdc
label var recstatdc "Record Status-DC Form"
label define recstatdc_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values recstatdc recstatdc_lab


*******************
** TRACKING FORM **
*******************

** (48) tfdddoa: Y-M-D H:M, readonly
format tfdddoa %tdCCYY-NN-DD
label var tfdddoa "TF Date"

** (49) tfdddoatstart: HH:MM
format tfdddoatstart %tcHH:MM
label var tfdddoatstart "TF Time-Start"

** (50) tfddda: readonly, user logged into redcap
gen tfddda1=.
replace tfddda1=25 if tfddda=="ashley.henry" //using codebook tfddda to see all possible entries in this field
replace tfddda1=25 if tfddda=="ashleyhenry"
replace tfddda1=4 if tfddda=="karen.greene"
replace tfddda1=4 if tfddda=="kg"
replace tfddda1=13 if tfddda=="kirt.gill"
replace tfddda1=20 if tfddda=="nicolette.roachford"
replace tfddda1=14 if tfddda=="tamisha.hunte"
replace tfddda1=98 if tfddda=="t.g"
replace tfddda1=98 if tfddda=="ivanna.bascombe"
replace tfddda1=98 if tfddda=="ib"
replace tfddda1=98 if tfddda=="asia.blackman"
replace tfddda1=98 if tfddda=="ab"
replace tfddda1=98 if tfddda=="shay.morrisdoty"
rename tfddda tfddda2
rename tfddda1 tfddda

label var tfddda "TF DA"
label define tfddda_lab 4 "KG" 13 "KWG" 14 "TH" 20 "NR" 25 "AH" 98 "intern", modify
label values tfddda tfddda_lab

** (51) tfregnumstart: integer
label var tfregnumstart "Registry #-Start"

** (52) tfdistrictstart: letters only
label var tfdistrictstart "District-Start"

** (53) tfregnumend: integer
label var tfregnumend "Registry #-End"

** (54) tfdistrictend: letters only
label var tfdistrictend "District-End"

** (55) tfdddoaend: Y-M-D
format tfdddoaend %tdCCYY-NN-DD
label var tfdddoaend "TF Date-End"

** (56) tfdddoatend: HH:MM
format tfdddoatend %tcHH:MM
label var tfdddoatend "TF Time-End"

** (57) tfddelapsedh: integer (imported to Stata as byte)
recast int tfddelapsedh
label var tfddelapsedh "Time Elpased (hrs)"

** (58) tfddelapsedm: integer
label var tfddelapsedm "Time Elpased (mins)"

** (59) tfddtxt
label var tfddtxt "TF Comments"

** (60) tracking_complete (auto-generated by REDCap): 0=Incomplete 1=Unverified 2=Complete
rename tracking_complete recstattf
label var recstattf "Record Status-TF Form"
label define recstattf_lab 0 "Incomplete" 1 "Unverified" 2 "Complete", modify
label values recstattf recstattf_lab
//drop if recstattf==0 & record_id!=2739 //2 deleted

//drop tfddda2 - don't remove as this will be used in 2_clean_deaths.do

order record_id event dddoa ddda odda certtype regnum district pname address parish sex ///
      age agetxt nrnnd nrn mstatus occu durationnum durationtxt dod dodyear ///
      cod1a onsetnumcod1a onsettxtcod1a cod1b onsetnumcod1b onsettxtcod1b ///
      cod1c onsetnumcod1c onsettxtcod1c cod1d onsetnumcod1d onsettxtcod1d ///
      cod2a onsetnumcod2a onsettxtcod2a cod2b onsetnumcod2b onsettxtcod2b ///
      pod deathparish regdate certifier certifieraddr namematch cleaned recstatdc ///
      tfdddoa tfddda tfregnumstart tfdistrictstart tfregnumend tfdistrictend tfddelapsedh tfddelapsedm tfddtxt recstattf

count //2695; 3231; 3232; 3233

label data "BNR MORTALITY data 2021"
notes _dta :These data prepared from BB national death register & Redcap deathdata database
save "`datapath'\version07\2-working\2021_deaths_prepped_dp" ,replace

** Create dataset to add record_id 3232 (entered post cleaning) to the prepared cancer dataset in dofile 2b_clean_all_deaths
keep if record_id==3232|record_id==3233
tostring nrn ,replace
save "`datapath'\version07\2-working\2021_deaths_prepped_dp_3232+3233" ,replace
