<?php
$zsClientUrl = 'https://github.com/zend-patterns/ZendServerSDK/raw/master/bin/zs-client.phar';
$zsClientFile = __DIR__ . '/zs-client.phar';

if (!is_file($zsClientFile)) {
    echo "Downloading zs-client\n";
    file_put_contents($zsClientFile, file_get_contents($zsClientUrl));
    chmod($zsClientFile, 0544);
}

$dir = __DIR__;
$cmd = $zsClientFile . " packZpk --folder=$dir --destination=$dir/zpk";

echo "Creating ZPK file: \n";
echo shell_exec($cmd);