<?php
$config = require __DIR__ . '/zpk.config.php';

$srcRoot = __DIR__;
$buildRoot = __DIR__ . "/../build";

@mkdir($buildRoot, 0777, true);

$phar = new Phar(
  $buildRoot . "/S2HubLic.phar",
	FilesystemIterator::CURRENT_AS_FILEINFO | FilesystemIterator::KEY_AS_FILENAME,
  "S2HubLic.phar"
);
$phar["initialLibDeploy.php"] = file_get_contents($srcRoot . "/initialLibDeploy.php");
$phar["src/AdminApiKey.php"] = file_get_contents($srcRoot . "/../src/AdminApiKey.php");

$phar["zpk/lu.zpk"] = file_get_contents($srcRoot . "/../" . $config['zpk']);

$phar->setStub($phar->createDefaultStub("initialLibDeploy.php"));
