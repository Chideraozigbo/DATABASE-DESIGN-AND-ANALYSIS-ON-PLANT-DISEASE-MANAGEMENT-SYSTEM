-- PROJECT OVERVIEW, AIMS, AND OBJECTIVES

/*
Project Overview:
The plant disease management system aims to provide a comprehensive solution for monitoring, detecting, and managing diseases affecting plants. It will utilize database technology to store information about plants, diseases, treatments, and monitoring activities. Users will have access to tools for data analysis, reporting, and decision-making to effectively combat plant diseases.

Aims:
1. Develop a robust database system to store and manage data related to plant diseases, including plant species, disease symptoms, treatments, and monitoring activities.
2. Implement user-friendly interfaces for various stakeholders, including farmers, researchers, and agricultural experts, to interact with the system efficiently.
3. Integrate data analysis and reporting tools to provide insights into disease trends, treatment effectiveness, and best practices for disease management.
4. Enhance collaboration and knowledge sharing among users through features such as forums, knowledge bases, and communication channels.

Objectives:
1. Design and implement a relational database schema to store plant disease-related data, ensuring data integrity and efficiency.
2. Develop user interfaces tailored to the specific needs of farmers, researchers, and agricultural experts, allowing them to input, retrieve, and analyze data seamlessly.
3. Integrate data visualization tools to present disease-related information in a clear and insightful manner, facilitating decision-making and trend analysis.
4. Incorporate features for user authentication, authorization, and role-based access control to ensure data security and privacy.
5. Provide mechanisms for data backup, recovery, and maintenance to prevent data loss and ensure system reliability.
6. Conduct user training and support to ensure effective utilization of the plant disease management system and maximize its impact on agricultural practices.
7. Continuously evaluate and improve the system based on user feedback, technological advancements, and evolving requirements in the field of plant pathology and agriculture.
*/

-- LET'S BEGIN


CREATE DATABASE IF NOT EXISTS PlantDiseaseManagementSystem;

USE PlantDiseaseManagementSystem;

CREATE TABLE IF NOT EXISTS Plant_Disease(
ID INT AUTO_INCREMENT PRIMARY KEY,
plant_disease_name VARCHAR(100),
causes VARCHAR(75),
recommendations VARCHAR(75),
predicted_score DECIMAL(3,3),
uploaded_image_path VARCHAR(75),
uploaded_time DATE,
detected_time DATE
);


-- LOAD DATA
LOAD DATA LOCAL INFILE '/Users/user/Documents/Database Project/plant_diseases.csv'
INTO TABLE Disease
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'           
LINES TERMINATED BY '\n'  
IGNORE 1 ROWS;


-- TO SEE THE NEWLY LOADED TABLE

SELECT * 
FROM Plant_Disease;


/*DATA NORMALIZATION */

CREATE TABLE Diseases(
ID INT AUTO_INCREMENT PRIMARY KEY,
plant_disease_name VARCHAR(100)
);


CREATE TABLE Causes(
ID INT AUTO_INCREMENT PRIMARY KEY,
DISEASEID INT,
CAUSES VARCHAR(75),
FOREIGN KEY (DISEASEID) REFERENCES Diseases(ID)
);

CREATE TABLE Recommendations(
ID INT AUTO_INCREMENT PRIMARY KEY,
DISEASEID INT,
RECOMMENDATIONS VARCHAR(75),
FOREIGN KEY (DISEASEID) REFERENCES Diseases(ID)
);

CREATE TABLE Images(
IMAGEID INT AUTO_INCREMENT PRIMARY KEY,
DISEASEID INT,
uploaded_image_path VARCHAR(75),
uploaded_time DATE,
FOREIGN KEY (DISEASEID) REFERENCES Diseases(ID)
);

CREATE TABLE Diseaseresult(
RESULTID INT AUTO_INCREMENT PRIMARY KEY,
DISEASEID INT,
predicted_score DECIMAL(3,3),
detected_time TIMESTAMP,
FOREIGN KEY (DiseaseID) REFERENCES Diseases(ID)
);

-- POPULATE DATA INTO THE NEWLY CREATED TABLE

-- LOADING DATA INTO THE DISEASES TABLE
INSERT INTO Diseases(plant_disease_name)
SELECT DISTINCT plant_disease_name
FROM Plant_Disease;

-- TO SEE THE LOADED DATA

SELECT *
FROM DISEASES;

-- LOADING DATA INTO THE CAUSES TABLE
INSERT INTO Causes (DiseaseID, causes)
SELECT Diseases.ID, Plant_Disease.causes
FROM Plant_Disease
JOIN Diseases ON Plant_Disease.plant_disease_name = Diseases.plant_disease_name;

-- TO SEE THE LOADED DATA

SELECT *
FROM CAUSES;

-- LOADING DATA INTO THE RECOMMENDATIONS TABLE

INSERT INTO Recommendations (DiseaseID, recommendations)
SELECT Diseases.ID, Plant_Disease.recommendations
FROM Plant_Disease
JOIN Diseases ON Plant_Disease.plant_disease_name = Diseases.plant_disease_name;

-- TO SEE THE LOADED DATA

SELECT *
FROM RECOMMENDATIONS;

-- LOADING DATA INTO THE IMAGES TABLE

INSERT INTO Images (DiseaseID, uploaded_image_path, uploaded_time)
SELECT Diseases.ID, Plant_Disease.uploaded_image_path, Plant_Disease.uploaded_time
FROM Plant_Disease
JOIN Diseases ON Plant_Disease.plant_disease_name = Diseases.plant_disease_name;

-- TO SEE THE LOADED DATA

SELECT *
FROM IMAGES;

-- LOADING DATA INTO THE IMAGES TABLE

INSERT INTO DiseaseResult (DiseaseID, predicted_score, detected_time)
SELECT Diseases.ID, Plant_Disease.predicted_score, Plant_Disease.detected_time
FROM Plant_Disease
JOIN Diseases ON Plant_Disease.plant_disease_name = Diseases.plant_disease_name;


-- TO SEE THE LOADED DATA

SELECT *
FROM DISEASERESULT;

-- DROPING THE ORIGINAL TABLE CREATED

DROP TABLE Disease;


/* CREATING VIEWS */

-- 1. What are the details of each plant disease, including its causes, recommendations, and predicted score?


CREATE VIEW PLANTDETAILS AS
SELECT d.plant_disease_name, c.causes, r.recommendations, dr.predicted_score
FROM Diseases d
JOIN DiseaseResult dr ON d.ID = dr.DiseaseID
JOIN Causes c ON d.ID = c.DiseaseID
JOIN Recommendations r ON d.ID = r.DiseaseID;

-- TO SEE THE VIEW

SELECT *
FROM PLANTDETAILS;

-- 2. Which diseases have the highest predicted scores, indicating severity?
CREATE VIEW HIGHESTPREDICTEDSCORE AS 
SELECT d.plant_disease_name, MAX(dr.predicted_score) AS maxscore
FROM Diseases d
JOIN DiseaseResult dr ON d.ID = dr.DiseaseID
GROUP BY d.plant_disease_name;

-- TO SEE THE VIEW

SELECT plant_disease_name, MAXSCORE
FROM HIGHESTPREDICTEDSCORE
WHERE MAXSCORE = (SELECT MAX(MAXSCORE) FROM HIGHESTPREDICTEDSCORE);

-- 3. What are the most common causes of plant diseases in the dataset?
CREATE VIEW COMMONCAUSE AS
SELECT c.causes, COUNT(*) AS causes_count
FROM Causes c
JOIN DiseaseResult dr ON c.DiseaseID = dr.DiseaseID
GROUP BY c.causes
ORDER BY causes_count DESC;

-- TO SEE THE VIEW
SELECT * 
FROM COMMONCAUSE;

-- 4. Which diseases have the most frequently uploaded images?
CREATE VIEW FREQUENTLYUPLOADED AS
SELECT d.plant_disease_name, COUNT(i.uploaded_image_path) AS imagecount
FROM Diseases d 
JOIN Images i ON d.ID = i.DiseaseID
GROUP BY d.plant_disease_name
ORDER BY imagecount DESC;

SELECT *
FROM FREQUENTLYUPLOADED;

-- 5. Can we identify any seasonal trends in the occurrence of specific plant diseases based on detection timestamps
CREATE VIEW SEASONALTRENDS AS
SELECT d.plant_disease_name,
       EXTRACT(YEAR FROM dr.detected_time) AS year,
       EXTRACT(MONTH FROM dr.detected_time) AS month,
       COUNT(*) AS occurrence
FROM Diseases d 
JOIN DiseaseResult dr ON d.ID = dr.DiseaseID
GROUP BY d.plant_disease_name, year, month
ORDER BY d.plant_disease_name, year, month;

-- TO SEE VIEW

SELECT * FROM
SEASONALTRENDS;


/* CREATING INDEX */

CREATE INDEX DISEASEINDEX ON Diseases(plant_disease_name);
CREATE INDEX idx_cause_disease_id ON Causes(DiseaseID);

-- QUERY TO SHOW INDEX

SELECT 
    TABLE_NAME, 
    INDEX_NAME, 
    COLUMN_NAME, 
    NON_UNIQUE, 
    SEQ_IN_INDEX, 
    INDEX_TYPE
FROM 
    information_schema.STATISTICS
WHERE 
    TABLE_SCHEMA = 'PlantDiseaseManagementSystem';
    
    
/* CREATING TRIGGERS */


-- THIS LOGS CHANGES MADE ON THE PREDICTED SCORE

CREATE TABLE DiseaseResult_Audit (
    AuditID INT AUTO_INCREMENT PRIMARY KEY,
    ResultID INT,
    OldPredictedScore DECIMAL(4,3),
    NewPredictedScore DECIMAL(4,3),
    ChangeTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER Before_DiseaseResult_Update
BEFORE UPDATE ON DiseaseResult
FOR EACH ROW
BEGIN
    INSERT INTO DiseaseResult_Audit (ResultID, OldPredictedScore, NewPredictedScore)
    VALUES (OLD.ResultID, OLD.predicted_score, NEW.predicted_score);
END;
//

DELIMITER ;


SELECT *
FROM DiseaseResult_Audit;

-- TO UPDATE PREDICTED SCORE IN DISEASE RESULT TABLE TO SEE IF IT WORKS

-- QUERY BEFORE UPDATE
SELECT *
FROM Diseaseresult
WHERE RESULTID = 291;

UPDATE Diseaseresult
SET predicted_score = 0.84
WHERE RESULTID = 291;

-- QUERY AFTER UPDATE
SELECT *
FROM Diseaseresult
WHERE RESULTID = 291;

-- TO SEE THE AUDIT TABLE AFTER CHANGES MADE

SELECT *
FROM DiseaseResult_Audit;

-- TRIGGER TO ENSURE THE PREDICTED SCORE IS BETWEEN 0.00 TO 1.0

DELIMITER //

CREATE TRIGGER before_insert_diseaseresult
BEFORE INSERT ON DiseaseResult
FOR EACH ROW
BEGIN
    IF NEW.predicted_score < 0.000 OR NEW.predicted_score > 1.000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'predicted_score must be between 0.000 and 1.000';
    END IF;
END;
//

CREATE TRIGGER before_update_diseaseresult
BEFORE UPDATE ON DiseaseResult
FOR EACH ROW
BEGIN
    IF NEW.predicted_score < 0.000 OR NEW.predicted_score > 1.000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'predicted_score must be between 0.000 and 1.000';
    END IF;
END;
//

DELIMITER ;

-- USER MANAGEMENT AND PRIVILEGES
/* 
The next step is to create users, manage them, and grant privileges to the users. User management is important because they play a 
vital role in ensuring the security, integrity, and efficiency of a database system. They enforce access control, limiting database 
interactions to authorized individuals and preventing unauthorized access.

The following users and access would be given:
- Admin: The user should be able to perform all actions on the database from creating, querying, changing, and deleting instructors, 
		 members, bookings, facilities, etc.
- Facilitator: The facilitator should be able to check and query the facilitator and facilities tables and should be able to 
	     update their personal details on the facilitator table. They should also be able to view booking details and 
         bookings for the week.
- Member: Members should be able to check and update their details on the membership table. Members should be able to view available 
	     bookings, make bookings, and view their own weekly bookings.
*/ 


-- For Admin
CREATE USER IF NOT EXISTS "plant_admin"@'localhost'
IDENTIFIED BY "";

-- For Researcher
CREATE USER IF NOT EXISTS "plant_researcher"@'localhost'
IDENTIFIED BY "";

-- For Farmer
CREATE USER IF NOT EXISTS "plant_farmer"@'localhost'
IDENTIFIED BY "";

-- Granting user access and privileges

-- For Admin
GRANT ALL PRIVILEGES 
ON plant_disease_db.*
TO "plant_admin"@'localhost';

-- For Researcher
GRANT SELECT, INSERT, UPDATE, DELETE 
ON plant_disease_db.*
TO "plant_researcher"@'localhost';

-- For Farmer
GRANT SELECT 
ON plant_disease_db.*
TO "plant_farmer"@'localhost';

-- To ensure privileges are correctly assigned
SHOW GRANTS FOR "plant_admin"@'localhost';
SHOW GRANTS FOR "plant_researcher"@'localhost';
SHOW GRANTS FOR "plant_farmer"@'localhost';

/* TO MAKE A BACKUP OF THE DATA*/

mysqldump -u root -p plant_disease_db > backup.sql




