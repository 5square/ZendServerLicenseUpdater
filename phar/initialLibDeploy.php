<?php

echo "\nGetting Access Key for 'admin'...";

$adminApiKey = require 'src/AdminApiKey.php';
$hash = $adminApiKey();

echo "\nCopying ZPK file...";

$zpkTmp = sys_get_temp_dir() . '/lu.zpk';
copy(__DIR__ . '/zpk/lu.zpk', $zpkTmp);

echo "\nZPK file copied to '$zpkTmp'";

if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
    $baseCmd = '"C:\Program Files (x86)\Zend\ZendServer\bin\zs-client.bat"';
}
else {
    $baseCmd = '/usr/local/zend/bin/zs-client.sh';
}

echo "\nUsing zs-client at '$baseCmd'...";

if (!file_exists($baseCmd)) {
    echo "\nWARNING: Not sure if that file exists or not...";
}

$cmd = $baseCmd . " libraryVersionDeploy --libPackage=\"$zpkTmp\" --zskey=admin --zssecret=$hash --output-format=json";

echo "\n\nDeploying library...";
$jsonOutput = shell_exec($cmd);
echo "\nLibrary Deployment Completed, output was...\n\n";
echo $jsonOutput;
echo "\n\n";

// Look for any known errors
if (strpos($jsonOutput, 'libraryAlreadyExists') !== false) {
    echo "\nERROR: Library was already deployed!";
    exit(100);
} elseif (strpos($jsonOutput, 'errorData') !== false) {
    echo "\nERROR: Unknown error during deployment (see output)!";
    exit(101);
} else {
    // Get the response from the deployment
    $json = json_decode($jsonOutput);

    // Handle based on values
    if (!$json) {
        echo "\nERROR: Unable to get deployment information";
        exit(102);
    } else {
        echo "\n\nLICENSE MANAGER DEPLOYED";
    }
}

echo "\nOff to sleep to give that a chance to deploy...";
sleep(10);
echo "\nI'm back!";

// Get the server info
echo "\n\nRetrieving Server Info...";
$cmd = $baseCmd . " getSystemInfo --zskey=admin --zssecret=$hash --output-format=json";
$jsonOutput = shell_exec($cmd);
echo "\nServer Info Retrieved, output was...\n\n";
echo $jsonOutput;
echo "\n\n";


// Get the response from the deployment
$json = json_decode($jsonOutput);
// Handle based on values
if (!$json) {
    echo "\nERROR: Unable to get server info following deployment";
    exit(200);
} else {
    echo "\n\nSERVER INFO:";
    echo "\nZend Server Version: " . $json->responseData->systemInfo->zendServerVersion;
    echo "\nLicense Status:      " . $json->responseData->systemInfo->serverLicenseInfo->status;
    echo "\nLicense Order #:     " . $json->responseData->systemInfo->serverLicenseInfo->orderNumber;
    echo "\nLicense Expiry:      " . $json->responseData->systemInfo->serverLicenseInfo->validUntil;
}
echo "\n\nDone!";

exit(0);

