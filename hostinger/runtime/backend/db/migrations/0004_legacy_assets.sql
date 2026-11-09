CREATE TABLE legacy_assets (
  source_sha256 CHAR(64) NOT NULL,
  id CHAR(36) NOT NULL,
  sha256 CHAR(64) NOT NULL,
  bytes INT UNSIGNED NOT NULL,
  content MEDIUMBLOB NOT NULL,
  PRIMARY KEY (source_sha256,id),
  FOREIGN KEY (source_sha256) REFERENCES legacy_imports(source_sha256)
) ENGINE=InnoDB;
