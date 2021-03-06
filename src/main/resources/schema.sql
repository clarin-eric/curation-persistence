

CREATE TABLE IF NOT EXISTS `providergroup` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(256) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`)
);

CREATE TABLE IF NOT EXISTS `client` (
   `id` INT NOT NULL AUTO_INCREMENT,
   `username` VARCHAR(256) NOT NULL,
   `email` VARCHAR(256) NOT NULL,
   `token` VARCHAR(36) NOT NULL,
   `quota` INT DEFAULT NULL, 
   PRIMARY KEY (`id`),
   UNIQUE KEY (`username`),
   INDEX (`username`, `token`)  
);


CREATE TABLE IF NOT EXISTS `context` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `client_id` INT NOT NULL,
  `origin` VARCHAR(256) NOT NULL,
  `providergroup_id` INT DEFAULT NULL,
  `expected_mime_type` VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),  
  UNIQUE KEY (`origin`, `providergroup_id`, `expected_mime_type`, `client_id`),
  INDEX (`providergroup_id`),
  FOREIGN KEY (`providergroup_id`) REFERENCES `providergroup` (`id`),
  INDEX (`client_id`),
  FOREIGN KEY (`client_id`) REFERENCES `client` (`id`)
);



CREATE TABLE IF NOT EXISTS `url` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(1024) NOT NULL,
  `group_key` VARCHAR(128) DEFAULT NULL,
  `valid` boolean DEFAULT NULL, 
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`),
  INDEX (`group_key`)
);


CREATE TABLE IF NOT EXISTS `url_context` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_id` INT NOT NULL,
  `context_id` INT NOT NULL,
  `ingestion_date` DATETIME NOT NULL,
  `active` BOOLEAN NOT NULL,
  PRIMARY KEY (`id`),
  INDEX (`url_id`, `active`, `context_id`),
  INDEX (`context_id`, `active`, `url_id`),
  UNIQUE KEY (`url_id`, `context_id`),
  FOREIGN KEY (`url_id`) REFERENCES `url` (`id`),
  FOREIGN KEY (`context_id`) REFERENCES `context` (`id`)
);


CREATE TABLE IF NOT EXISTS `status` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_id` INT NOT NULL,
  `status_code` INT DEFAULT NULL,
  `message` VARCHAR(1024) NOT NULL,
  `category` VARCHAR(25) NOT NULL,
  `method` VARCHAR(10) DEFAULT NULL,
  `content_type` VARCHAR(256) DEFAULT NULL,
  `content_length` bigint DEFAULT NULL,
  `duration` INT DEFAULT NULL,
  `checking_date` DATETIME NOT NULL,
  `redirect_count` INT DEFAULT NULL,
  `recheck` BOOLEAN DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`url_id`),
  INDEX (`category`),
  INDEX (`checking_date`),
  FOREIGN KEY (`url_id`) REFERENCES `url` (`id`)
  ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS `history` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_id` INT DEFAULT NULL,
  `status_code` INT DEFAULT NULL,
  `message` VARCHAR(256) DEFAULT NULL,
  `category` VARCHAR(25) NOT NULL,
  `method` VARCHAR(10) DEFAULT NULL,
  `content_type` VARCHAR(256) DEFAULT NULL,
  `content_length` INT DEFAULT NULL,
  `duration` INT DEFAULT NULL,
  `checking_date` DATETIME NOT NULL,
  `redirect_count` INT DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`url_id`,`checking_date`),
  FOREIGN KEY (`url_id`) REFERENCES `url` (`id`)
  ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS `obsolete` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_name` VARCHAR(512) NOT NULL,
  `client_email` int DEFAULT NULL,
  `providergroup_name` VARCHAR(256) DEFAULT NULL,
  `origin` VARCHAR(256) DEFAULT NULL,
  `expected_mime_type` VARCHAR(256) DEFAULT NULL,
  `ingestion_date` DATETIME DEFAULT NULL,
  `status_code` INT DEFAULT NULL,
  `message` VARCHAR(1024) DEFAULT NULL,
  `category` VARCHAR(25) NOT NULL,
  `method` VARCHAR(10) DEFAULT NULL,
  `content_type` VARCHAR(256) DEFAULT NULL,
  `content_length` bigint DEFAULT NULL,
  `duration` INT DEFAULT NULL,
  `checking_date` DATETIME NOT NULL,
  `redirect_count` INT DEFAULT NULL,
  `deletion_date` DATETIME NOT NULL,
   PRIMARY KEY (`id`)
);


CREATE VIEW IF NOT EXISTS `aggregated_status` AS
 SELECT p.name, s.category, COUNT(s.id) AS number, AVG(s.duration) AS avg_duration, MAX(s.duration) AS max_duration
 FROM url_context uc
 JOIN (status s)
 ON (uc.url_id=s.url_id)
 JOIN (context c)
 ON (uc.context_id=c.id)
 JOIN providergroup p
 ON (p.id=c.providergroup_id)
 WHERE uc.active=true
 GROUP BY p.name, s.category;
