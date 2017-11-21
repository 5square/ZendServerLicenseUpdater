<?php
namespace LicenseUpdater;

class ApiKey {
    
    const API_KEY_NAME = 'admin';
    
    public function __invoke() {
        $db = new \SQLite3('/usr/local/zend/var/db/gui.db');
        $results = $db->query("SELECT HASH FROM GUI_WEBAPI_KEYS WHERE NAME='" . self::API_KEY_NAME . "'");
        
        $row = $results->fetchArray();
        
        return new \ZendServerWebApi\Model\ApiKey(self::API_KEY_NAME, $row['HASH']);
    }
}

return new ApiKey();