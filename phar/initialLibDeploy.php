<?php

$adminApiKey = require 'src/AdminApiKey.php';
$hash = $adminApiKey();

$zpkTmp = sys_get_temp_dir() . '/lu.zpk';
copy(__DIR__ . '/zpk/lu.zpk', $zpkTmp);

echo "ZPK file copied to $zpkTmp\n";

if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    $cmd = '"C:\Program Files (x86)\Zend\ZendServer\bin\zs-client.bat"';
}
else {
    $cmd = '/usr/local/zend/bin/zs-client';
}

$cmd .= " libraryVersionDeploy --libPackage=\"$zpkTmp\" --zskey=admin --zssecret=$hash";

echo "Deploying library... \n\n";
echo shell_exec($cmd);
