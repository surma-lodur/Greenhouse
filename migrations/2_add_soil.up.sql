ALTER TABLE `measurements` 
CHANGE COLUMN `soil` `soil1` DECIMAL(8,2) NOT NULL DEFAULT 0.0 ,
ADD COLUMN `soil2` DECIMAL(8,2) NOT NULL DEFAULT 0.0 AFTER `soil1`,
ADD COLUMN `soil3` DECIMAL(8,2) NOT NULL DEFAULT 0.0 AFTER `soil2`,
ADD COLUMN `soil4` DECIMAL(8,2) NOT NULL DEFAULT 0.0 AFTER `soil3`;