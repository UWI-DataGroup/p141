** HEADER -----------------------------------------------------
**  DO-FILE METADATA
    //  algorithm name          1b_prep_electoral.do
    //  project:                BNR
    //  analysts:               Jacqueline CAMPBELL
    //  date first created      14-APR-2022
    // 	date last modified      16-MAY-2022
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
    log using "`logpath'\1b_prep_electoral_2019+2021.smcl", replace
** HEADER -----------------------------------------------------


**********
** 2019 **
**********

***************
** DATA IMPORT  
***************
** LOAD the 2019 national electoral excel dataset

import excel using "`datapath'\version07\1-input\Register_Electoral List II.xlsx" , firstrow case(lower)

save "`datapath'\version07\2-working\2019_electoral_imported_dp" ,replace

count //508,930


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



**********
** 2021 **
**********
***************
** DATA IMPORT  
***************
** The 2021 electoral data was in a PDF version instead of excel as with previous years so Tanya Martelly converted the PDF version (as she had a fully-loaded version of Adobe) to Excel using an encrypted Sync link.
** The converted data outputted to several excel workbooks so now these need to be compiled into one excel workbook.

** LOAD each 2021 national electoral excel workbook then format and save (#1)
import excel using "`datapath'\version07\1-input\Pages from Electoral List Online_3001-3500.xlsx-2022-4-25 15.32.11.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //499
drop if surname=="SURNAME" //499 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //0
count if name=="" //3 - corrected below

count if b!="" //4
replace name=b+" "+name if id!=9691 & b!="" //3 changes
replace b="" if id!=9691 & b!=""
replace surname=surname+" "+b if id==9691 //3 changes
drop b

count if d!="" //17
replace name=name+" "+d if d!="" //17 changes
drop d

count if e!="" //89
replace name=name+" "+e if e!="" //89 changes
drop e

count if f!="" //7
replace name=name+" "+f if f!="" //7 changes
drop f

count if g!="" //329
replace name=name+" "+g if g!="" //329 changes
drop g

count if h!="" //209
replace name=name+" "+h if h!="" //209 changes
drop h

count if i!="" //62
replace name=name+" "+i if i!="" //62 changes
drop i

count if j!="" //22
replace name=name+" "+j if j!="" //22 changes
drop j

count if k!="" //14
replace name=name+" "+k if k!="" //14 changes
drop k

count if l!="" //1
replace name=name+" "+l if l!="" //1 change
drop l

count if m!="" //4
replace name=name+" "+m if m!="" //4 changes
drop m

count if n!="" //1
replace name=name+" "+n if n!="" //1 change
drop n

count if v!="" //1
replace address=address+" "+v if v!="" //1 change
drop v


count if length(nrn)>11 //0
count if length(nrn)<11 //0
count if name=="" //0

** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //21,933 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //2 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*


save "`datapath'\version07\2-working\2021_electoral_prepped_1" ,replace

clear


** LOAD each 2021 national electoral excel workbook then format and save (#2)
import excel using "`datapath'\version07\1-input\Pages from Electoral List Online_3501-4000.xlsx-2022-4-25 15.33.4.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //499
drop if surname=="SURNAME" //499 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //1
drop if id==20209 //1 deleted
count if name=="" //5 - corrected below

count if b!="" //5
replace name=b+" "+name if id!=22700 & b!="" //3 changes
replace b="" if id!=22700 & b!=""
replace surname=surname+" "+b if id==22700 //3 changes
drop b

count if d!="" //3
replace name=name+" "+d if d!="" //3 changes
drop d

count if e!="" //260
replace name=name+" "+e if e!="" //260 changes
drop e

count if f!="" //58
replace name=name+" "+f if f!="" //58 changes
drop f

count if g!="" //363
replace name=name+" "+g if g!="" //363 changes
drop g

count if h!="" //5
replace name=name+" "+h if h!="" //5 changes
drop h

count if i!="" //11
replace name=name+" "+i if i!="" //11 changes
drop i

count if j!="" //8
replace name=name+" "+j if j!="" //8 changes
drop j

count if k!="" //3
replace name=name+" "+k if k!="" //3 changes
drop k

count if l!="" //6
replace name=name+" "+l if l!="" //6 changes
drop l


count if length(nrn)>11 //0
count if length(nrn)<11 //0
count if name=="" //0

** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //22,193 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //3 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*


save "`datapath'\version07\2-working\2021_electoral_prepped_2" ,replace

clear


** LOAD each 2021 national electoral excel workbook then format and save (#3)
import excel using "`datapath'\version07\1-input\Pages from Electoral List Online_4001-4500.xlsx-2022-4-25 15.33.4.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //499
drop if surname=="SURNAME" //499 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //0
count if name=="" //0

count if b!="" //1
replace surname=surname+" "+b if id==16272 //3 changes
drop b

count if d!="" //2
replace name=name+" "+d if d!="" //2 changes
drop d

count if e!="" //29
replace name=name+" "+e if e!="" //29 changes
drop e

count if f!="" //129
replace name=name+" "+f if f!="" //129 changes
drop f

count if g!="" //52
replace name=name+" "+g if g!="" //52 changes
drop g

count if h!="" //131
replace name=name+" "+h if h!="" //131 changes
drop h

count if i!="" //27
replace name=name+" "+i if i!="" //27 changes
drop i

count if j!="" //15
replace name=name+" "+j if j!="" //15 changes
drop j

count if k!="" //3
replace name=name+" "+k if k!="" //3 changes
drop k

count if l!="" //3
replace name=name+" "+l if id==18614 & l!="" //1 change
replace nrn=l if id!=18614 & l!="" //2 changes
drop l


count if length(nrn)>11 //0
count if length(nrn)<11 //0

** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //22,377 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //0 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*


save "`datapath'\version07\2-working\2021_electoral_prepped_3" ,replace

clear


** LOAD each 2021 national electoral excel workbook then format and save (#4)
import excel using "`datapath'\version07\1-input\Pages from Electoral List Online_4501-5000.xlsx-2022-4-25 15.33.4.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //499
drop if surname=="SURNAME" //499 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //
count if name=="" //
drop if id==6145|id==8210

count if b!="" //1
replace surname=surname+" "+b if id==10923 //3 changes
drop b

count if d!="" //55
replace name=name+" "+d if d!="" //55 changes
drop d

count if e!="" //158
replace name=name+" "+e if e!="" //158 changes
drop e

count if f!="" //408
replace name=name+" "+f if f!="" //408 changes
drop f

count if g!="" //123
replace name=name+" "+g if g!="" //123 changes
drop g

count if h!="" //3
replace name=name+" "+h if h!="" //3 changes
drop h

count if i!="" //12
replace name=name+" "+i if i!="" //12 changes
drop i

count if j!="" //14
replace name=name+" "+j if j!="" //14 changes
drop j

count if k!="" //4
replace name=name+" "+k if k!="" //4 changes
drop k


count if length(nrn)>11 //0
count if length(nrn)<11 //0

** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //22,138 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //2 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*


save "`datapath'\version07\2-working\2021_electoral_prepped_4" ,replace

clear


** LOAD each 2021 national electoral excel workbook then format and save (#5)
import excel using "`datapath'\version07\1-input\Pages from Electoral List Online_5001-5520.xlsx-2022-4-25 15.33.4.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //519
drop if surname=="SURNAME" //519 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //1
count if name=="" //1
drop if id==10657

count if b!="" //1
replace surname=surname+" "+b if id==18630 //3 changes
drop b

count if d!="" //19
replace name=name+" "+d if d!="" //19 changes
drop d

count if e!="" //73
replace name=name+" "+e if e!="" //73 changes
drop e

count if f!="" //53
replace name=name+" "+f if f!="" //53 changes
drop f

count if g!="" //365
replace name=name+" "+g if g!="" //365 changes
drop g

count if h!="" //151
replace name=name+" "+h if h!="" //151 changes
drop h

count if i!="" //25
replace name=name+" "+i if i!="" //25 changes
drop i

count if j!="" //12
replace name=name+" "+j if j!="" //12 changes
drop j

count if k!="" //15
replace name=name+" "+k if k!="" //15 changes
drop k

count if l!="" //1
replace name=name+" "+l if l!="" //1 change
drop l


count if length(nrn)>11 //0
count if length(nrn)<11 //50 - 1 totals record; 1 missing NRN; 48 NRN in name field
drop if id==10657|id==24942 //2 deleted

gen namenrn = regexs(0) if regexm(name, "(([a-zA-Z]+)[ ]*([a-zA-Z]+)[ ]*([a-zA-Z]+)[ ]*([a-zA-Z]+))")
gen nrnname = subinstr(name, ",", "", .)
//ssc install moss
moss nrnname, match("([0-9]+)")  regex
gen nrn2=_match1+"-"+_match2
replace name=namenrn if length(nrn)<11
replace nrn=nrn2 if length(nrn)<11
replace nrn="" if id==1671
drop namenrn nrnname _count _match1 _pos1 _match2 _pos2 nrn2


** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //22,138 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //2 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd

** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*

save "`datapath'\version07\2-working\2021_electoral_prepped_5" ,replace

clear


** LOAD the 2021 national electoral excel dataset that I started to manually group
import excel using "`datapath'\version07\1-input\Converted Online List_20220425.xlsx" , firstrow case(lower)

** Remove records that were the column headings repeated in the excel workbook
count if surname=="SURNAME" //327
drop if surname=="SURNAME" //327 deleted

** Format the variables as the excel workbook had merged columns, etc.
gen id=_n
order id

count if surname=="" //4
count if name=="" //49

replace surname="" if id<5 //3 changes
replace name=subinstr(name,"*","",1) if id==3

count if c!="" //62
replace name=name+" "+c if c!="" //62 changes
drop c

count if d!="" //493
replace name=name+" "+d if d!="" //493 changes
drop d

count if e!="" //894
replace name=name+" "+e if e!="" //894 changes
drop e

count if f!="" //1713
replace name=name+" "+f if f!="" //1713 changes
drop f

count if g!="" //726
replace name=name+" "+g if g!="" //726 changes
drop g

count if h!="" //617
replace name=name+" "+h if h!="" //617 changes
drop h

count if i!="" //82
replace name=name+" "+i if i!="" //82 changes
drop i

count if j!="" //16
replace name=name+" "+j if j!="" //16 changes
drop j

count if k!="" //22
replace name=name+" "+k if k!="" //22 changes
drop k

count if l!="" //1
replace name=name+" "+l if l!="" //1 change
drop l

count if t!="" //1
replace address=address+" "+t if t!="" //1 change
drop t
replace address = subinstr(address,"-","",.) if id==41505


count if length(nrn)>11 //0
count if length(nrn)<11 //1

gen namenrn = regexs(0) if regexm(surname, "(([a-zA-Z]+)[ ]*([a-zA-Z]+)[ ]*([a-zA-Z]+)[ ]*([a-zA-Z]+))")
gen namenrn2 = regexs(0) if regexm(namenrn, "(([a-zA-Z]+))")
gen namenrn3 = substr(namenrn,-7,7)
gen nrnname = subinstr(surname, ",", "", .)
//ssc install moss
moss nrnname, match("([0-9]+)")  regex
gen nrn2=_match1+"-"+_match2
replace name=namenrn3 if length(nrn)<11
replace surname=namenrn2 if length(nrn)<11
replace nrn=nrn2 if length(nrn)<11
drop namenrn namenrn2 namenrn3 nrnname _count _match1 _pos1 _match2 _pos2 nrn2


** Convert names to lower case and strip possible leading/trailing blanks
replace name = upper(rtrim(ltrim(itrim(name)))) //21,275 changes
replace surname = upper(rtrim(ltrim(itrim(surname)))) //52 changes

order id nrn name surname gender dateofbirth address constituency residentialstatus pd


** Add prefix to variable names to differentiate electoral data from death data
rename * elec_*

** Add other datasets from above to this one
append using "`datapath'\version07\2-working\2021_electoral_prepped_1"
append using "`datapath'\version07\2-working\2021_electoral_prepped_2"
append using "`datapath'\version07\2-working\2021_electoral_prepped_3"
append using "`datapath'\version07\2-working\2021_electoral_prepped_4"
append using "`datapath'\version07\2-working\2021_electoral_prepped_5"

** Create pname variable for matching with death data
gen elec_pname=elec_name+" "+elec_surname

** Convert names to lower case and strip possible leading/trailing blanks
replace elec_name = upper(rtrim(ltrim(itrim(elec_name)))) //0 changes
replace elec_surname = upper(rtrim(ltrim(itrim(elec_surname)))) //0 changes
replace elec_pname = upper(rtrim(ltrim(itrim(elec_pname)))) //52 changes


** Reassign ID field
sort elec_surname elec_name
drop elec_id
gen elec_id=_n

order elec_id elec_nrn elec_name elec_surname elec_gender elec_dateofbirth elec_address elec_constituency elec_residentialstatus elec_pd

** Create labels for  the excel export below
label var elec_id "Electoral ID"
label var elec_nrn "NRN"
label var elec_name "NAME"
label var elec_surname "SURNAME"
label var elec_gender "GENDER"
label var elec_dateofbirth "DATE OF BIRTH"
label var elec_address "ADDRESS"
label var elec_constituency "CONSTITUENCY"
label var elec_residentialstatus "RESIDENTIAL STATUS"
label var elec_pd "PD"

** Create excel workbook with all electoral lists combined for CVD and Cancer teams to use
capture export_excel elec_id elec_nrn elec_name elec_surname elec_gender elec_dateofbirth elec_address elec_constituency elec_residentialstatus elec_pd using "`datapath'\version07\3-output\2021ElectoralList_20220509.xlsx", firstrow(varlabels) replace

** Erase single excel workbook datasets to conserve storage space on SharePoint
erase "`datapath'\version07\2-working\2021_electoral_prepped_1.dta"
erase "`datapath'\version07\2-working\2021_electoral_prepped_2.dta"
erase "`datapath'\version07\2-working\2021_electoral_prepped_3.dta"
erase "`datapath'\version07\2-working\2021_electoral_prepped_4.dta"
erase "`datapath'\version07\2-working\2021_electoral_prepped_5.dta"

label data "BNR ELECTORAL data 2021"
notes _dta :These data prepared from EBC register
save "`datapath'\version07\2-working\2021_electoral_prepped_dp" ,replace



*****************
**   Merging   **
** 2019 + 2021 **
**    lists    **
*****************

** JC 16may2022: Some names on the 2019 electoral list are missing from the 2021 electoral list so will merge the lists so the cancer team just has one 'master' list to check

**********************
** Format 2019 list **
**********************

use "`datapath'\version07\2-working\2019_electoral_prepped_dp" ,clear

gen elec_name=elec_firstname+" "+elec_middlename
drop elec_firstname elec_middlename
rename elec_lastname elec_surname
gen elec_address=elec_housenumber+" "+elec_address2+" "+elec_address3
drop elec_housenumber elec_address2 elec_address3
rename elec_parish elec_constituency
format elec_dateofbirth %tddmCY
gen elec_dob=string(elec_dateofbirth, "%td")
drop elec_dateofbirth
rename elec_dob elec_dateofbirth
rename elec_sex elec_gender

count //508,930
save "`datapath'\version07\2-working\2019_electoral_merge_prepped_dp" ,replace

**********************
** Format 2021 list **
**********************

use "`datapath'\version07\2-working\2021_electoral_prepped_dp" ,clear

count //264,940

** Format NRN in 2021 list to be the same as NRN in the 2019 list in prep for merging
replace elec_nrn=subinstr(elec_nrn,"-","",.)

merge m:m elec_nrn using "`datapath'\version07\2-working\2019_electoral_merge_prepped_dp"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       246,949
        from master                     1,504  (_merge==1)
        from using                    245,445  (_merge==2)

    Matched                           263,485  (_merge==3)
    -----------------------------------------
*/
drop elec_id
gen elec_id=_n
drop _merge

order elec_id elec_nrn elec_name elec_surname elec_gender elec_dateofbirth elec_address elec_constituency elec_residentialstatus elec_pd elec_pname elec_placeofbirthdesc elec_nationalitydesc

** Create excel workbook with all electoral lists combined for CVD and Cancer teams to use
capture export_excel elec_id elec_nrn elec_name elec_surname elec_gender elec_dateofbirth elec_address elec_constituency elec_residentialstatus elec_pd elec_placeofbirthdesc elec_nationalitydesc using "`datapath'\version07\3-output\2019+2021_ElectoralList_20220516.xlsx", firstrow(varlabels) replace

count //510,434

save "`datapath'\version07\3-output\2019+2021_electoral_prepped_dp" ,replace

