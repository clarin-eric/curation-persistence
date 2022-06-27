# This script creates a linkchecker database as it is assumed by this mysql implementation of the rasa-api
# author: Wolfgang Walter SAUER (wowasa) <clarin@wowasa.com>
# date: July 2022

#DROP DATABASE  IF EXISTS `linkchecker`;
CREATE DATABASE  IF NOT EXISTS `linkchecker` CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `linkchecker`;

CREATE TABLE IF NOT EXISTS `providerGroup` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ukey_providerGroup_name` (`name`)
);


CREATE TABLE IF NOT EXISTS `context` (
  `id` int NOT NULL AUTO_INCREMENT,
  `source` varchar(256) DEFAULT NULL,
  `record` varchar(256) DEFAULT NULL,
  `providerGroup_id` int DEFAULT NULL,
  `expectedMimeType` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ukey_context_record_providerGroup_id_expectedMimeType_source` (`record`, `providerGroup_id`, `expectedMimeType`, `source`),
  KEY `key_providerGroup_id` (`providerGroup_id`),
  CONSTRAINT `fkey_context_providerGroup_id` FOREIGN KEY `key_providerGroup_id` (`providerGroup_id`) REFERENCES `providerGroup` (`id`)
);



CREATE TABLE IF NOT EXISTS `url` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `groupKey` varchar(128) DEFAULT NULL,
  `valid` boolean DEFAULT NULL, 
  PRIMARY KEY (`id`),
  UNIQUE KEY `ukey_url_url` (`url`),
  KEY `key_url_host` (`groupKey`)
);


CREATE TABLE IF NOT EXISTS `url_context` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url_id` int NOT NULL,
  `context_id` int NOT NULL,
  `ingestionDate` datetime NOT NULL DEFAULT NOW(),
  `active` boolean NOT NULL DEFAULT false,
  PRIMARY KEY (`id`),
  KEY `key_url_context_url_id_active_context_id` (`url_id`, `active`, `context_id`),
  KEY `key_url_context_context_id_active_url_id` (`context_id`, `active`, `url_id`),
  UNIQUE KEY `ukey_url_context_url_id_context_id` (`url_id`, `context_id`),
  CONSTRAINT `fkey_url_context_url_id` FOREIGN KEY `key_url_context_url_id_active_context_id` (`url_id`) REFERENCES `url` (`id`),
  CONSTRAINT `fkey_url_context_context_id` FOREIGN KEY `key_url_context_context_id_active_url_id` (`context_id`) REFERENCES `context` (`id`)
);


CREATE TABLE IF NOT EXISTS `status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url_id` int NOT NULL,
  `statusCode` int DEFAULT NULL,
  `message` varchar(1024) NOT NULL,
  `category` varchar(25) NOT NULL,
  `method` varchar(10) DEFAULT NULL,
  `contentType` varchar(256) DEFAULT NULL,
  `byteSize` bigint DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `checkingDate` datetime NOT NULL,
  `redirectCount` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ukey_status_url_id` (`url_id`),
  KEY `key_status_category` (`category`),
  CONSTRAINT `fkey_status_url_id` FOREIGN KEY `ukey_status_url_id` (`url_id`) REFERENCES `url` (`id`)
);


CREATE TABLE IF NOT EXISTS `history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `status_id` int NOT NULL,
  `url_id` int DEFAULT NULL,
  `statusCode` int DEFAULT NULL,
  `message` varchar(256),
  `category` varchar(25) NOT NULL,
  `method` varchar(10) NOT NULL,
  `contentType` varchar(256) DEFAULT NULL,
  `byteSize` int DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `checkingDate` datetime NOT NULL,
  `redirectCount` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ukey_history_url_id_ceckingDate` (`url_id`,`checkingDate`)
);

CREATE TABLE IF NOT EXISTS `obsolete` (
  `url` varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `source` varchar(256) DEFAULT NULL,
  `providerGroupName` varchar(256) DEFAULT NULL,
  `record` varchar(256) DEFAULT NULL,
  `expectedMimeType` varchar(256) DEFAULT NULL,
  `ingestionDate` datetime DEFAULT NULL,
  `statusCode` int DEFAULT NULL,
  `message` varchar(1024) DEFAULT NULL,
  `category` varchar(25) NOT NULL,
  `method` varchar(10) DEFAULT NULL,
  `contentType` varchar(256) DEFAULT NULL,
  `byteSize` bigint DEFAULT NULL,
  `duration` int DEFAULT NULL,
  `checkingDate` datetime NOT NULL,
  `redirectCount` int DEFAULT NULL,
  `deletionDate` datetime NOT NULL DEFAULT NOW()
);

CREATE VIEW IF NOT EXISTS `aggregatedStatus` AS
 SELECT p.name, s.category, COUNT(s.id) AS number, AVG(s.duration) AS avg_duration, MAX(s.duration) AS max_duration
 FROM url_context uc
 JOIN (status s, context c)
 ON (uc.url_id=s.url_id AND uc.context_id=c.id)
 JOIN providerGroup p
 ON (p.id=c.providerGroup_id)
 WHERE uc.active=true
 GROUP BY p.name, s.category;
