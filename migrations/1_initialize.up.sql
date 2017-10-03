CREATE TABLE IF NOT EXISTS measurements (id INT(11) NOT NULL AUTO_INCREMENT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, lux INT, drewpoint DECIMAL(8,2), humidity DECIMAL(8,3), temp DECIMAL(8,2), soil DECIMAL(8,2), bar DECIMAL(8,3), PRIMARY KEY (id)) ENGINE=InnoDB