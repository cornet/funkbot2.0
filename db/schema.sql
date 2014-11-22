CREATE TABLE store (
	`id` INT NOT NULL AUTO_INCREMENT,
	`plugin` varchar(255) NOT NULL,
	`key` varchar(255) NOT NULL,
	`value` text NOT NULL,
	PRIMARY KEY (`id`),
	INDEX plugin_key_idx (`plugin`,`key`)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8;

