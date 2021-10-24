CREATE TABLE IF NOT EXISTS `renzu_stancer` (
  `plate` varchar(64) NOT NULL DEFAULT '',
  `setting` longtext NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;