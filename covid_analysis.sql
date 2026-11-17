CREATE DATABASE covid_project;
USE covid_project;

CREATE TABLE covid_data (
    USMER INT,
    MEDICAL_UNIT INT,
    SEX INT,
    PATIENT_TYPE INT,
    DATE_DIED VARCHAR(20),
    INTUBED INT,
    PNEUMONIA INT,
    AGE INT,
    PREGNANT INT,
    DIABETES INT,
    COPD INT,
    ASTHMA INT,
    INMSUPR INT,
    HIPERTENSION INT,
    OTHER_DISEASE INT,
    CARDIOVASCULAR INT,
    OBESITY INT,
    RENAL_CHRONIC INT,
    TOBACCO INT,
    CLASIFFICATION_FINAL INT,
    ICU INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Covid Data.csv'
INTO TABLE covid_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


CREATE VIEW cleaned_covid_data AS
SELECT 
    -- Convert Gender codes to readable text
    CASE 
        WHEN SEX = 1 THEN 'Female'
        WHEN SEX = 2 THEN 'Male'
        ELSE 'Unknown'
    END AS Gender,

-- patients are admited in a hospitol or at home 
    CASE 
        WHEN PATIENT_TYPE = 1 THEN 'Home/Returned'
        WHEN PATIENT_TYPE = 2 THEN 'Hospitalized'
        ELSE 'Unknown'
    END AS Patient_Location,

   --  Patients are died or alive (9999-99- logic)
    CASE 
        WHEN DATE_DIED = '9999-99-99' THEN 'Alive'
        ELSE 'Died'
    END AS Survival_Status,

    
    AGE AS Age,

    -- Was the patient on a ventilator (97, 99  will be considered unkonwn)
    CASE 
        WHEN INTUBED = 1 THEN 'Yes'
        WHEN INTUBED = 2 THEN 'No'
        ELSE 'Unknown'
    END AS On_Ventilator,

--     Disease status (1 = Yes, 2 = No, All others Unknown)
    CASE WHEN PNEUMONIA = 1 THEN 'Yes' WHEN PNEUMONIA = 2 THEN 'No' ELSE 'Unknown' END AS Has_Pneumonia,
    CASE WHEN DIABETES = 1 THEN 'Yes' WHEN DIABETES = 2 THEN 'No' ELSE 'Unknown' END AS Has_Diabetes,
    CASE WHEN HIPERTENSION = 1 THEN 'Yes' WHEN HIPERTENSION = 2 THEN 'No' ELSE 'Unknown' END AS Has_Hypertension,
    CASE WHEN OBESITY = 1 THEN 'Yes' WHEN OBESITY = 2 THEN 'No' ELSE 'Unknown' END AS Is_Obese,
    CASE WHEN TOBACCO = 1 THEN 'Yes' WHEN TOBACCO = 2 THEN 'No' ELSE 'Unknown' END AS Smoker,

   --  Was the patient in the ICU
    CASE 
        WHEN ICU = 1 THEN 'Yes'
        WHEN ICU = 2 THEN 'No'
        ELSE 'Unknown'
    END AS In_ICU

FROM covid_data;

select 
   Survival_Status,
   count(*) as Total_Patient,
   round((count(*)/(select count(*)from cleaned_covid_data))*100.0,2) as Percentage
from cleaned_covid_data
group by Survival_Status;

select 
   In_ICU,
   avg(age) as Average_age,
   sum( case when In_ICU ='Yes' then 1 else 0 end) as total_in_icu,
   sum(case when In_ICU = 'Yes' and On_Ventilator = 'Yes' then 1 else 0 end) as Icu_on_Ventilator
from cleaned_covid_data
where In_ICU = 'Yes'
group by In_ICU;

select Has_Diabetes, Survival_Status,
Count(*) as Total_Patient,
count(*)/ SUM(COUNT(*)) over(partition by Has_Diabetes) * 100 as percentage
from cleaned_covid_data
where Has_Diabetes in('Yes', 'No')
group by Has_Diabetes, Survival_Statusn;

