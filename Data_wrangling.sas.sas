*********************************************************************
*  Job name:      Data_wrangling.sas   
*
*                                         
*  Language:      SAS, VERSION 9.4  
*
*  Input:         MIMIC data sets
*                                                                    
********************************************************************;


%LET outdir=/folders/myshortcuts/BIOS669;

OPTIONS NODATE MPRINT MERGENOBY=WARN VARINITCHK=WARN ;

LIBNAME MIMIC "/folders/myshortcuts/BIOS669/data/MIMIC" access=read;


proc sql;
	create table C as
	select C.HADM_ID, C.ICUSTAY_ID, C.SUBJECT_ID, C.VALUE, C.VALUENUM, D.LABEL, C.CHARTTIME
		from mimic.chartevents as C, mimic.d_items as D
			where C.itemid = d.itemid;
			
	create table D as
	select C.HADM_ID, C.ICUSTAY_ID, C.SUBJECT_ID, C.CHARTTIME, C.VALUE, C.VALUENUM, C.LABEL,
			I.FIRST_CAREUNIT, I.LOS
		from C, mimic.icustayS as I
		    WHERE C.HADM_ID = I.HADM_ID and
			C.ICUSTAY_ID = I.ICUSTAY_ID anD
			C.SUBJECT_ID = I.SUBJECT_ID;
			
	create table E as
	select  D.SUbject_id, D.LABEL as Test, D.VALUE, D.VALUENUM, D.FIRST_CAREUNIT, D.LOS, 
			A.ETHNICITY, A.DIAGNOSIS, A.MARITAL_STATUS
		from D, mimic.admissions as A
		    WHERE D.HADM_ID = A.HADM_ID and
			D.SUBJECT_ID = A.SUBJECT_ID;
	
	create table Analysis as
	select  E.subject_id, E.Test, E.VALUE, E.VALUENUM, E.FIRST_CAREUNIT, E.LOS, 
			E.ETHNICITY, E.DIAGNOSIS, E.MARITAL_STATUS, Floor(((P.DOD - P.DOB)/365)) as Age, P.GENDER
		from e, mimic.patients as p
		    WHERE E.subject_id = P.subject_id;
quit;


proc export data=Analysis file="&outdir./analysis.xlsx" dbms=xlsx replace;
run;
	