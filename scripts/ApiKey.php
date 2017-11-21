<?php
namespace LicenseUpdater;

class ApiKey {
    
    const API_KEY_NAME = 'admin';
    
    public function __invoke() {
        #$db = new \SQLite3('/usr/local/zend/var/db/gui.db');
        #$results = $db->query("SELECT HASH FROM GUI_WEBAPI_KEYS WHERE NAME='" . self::API_KEY_NAME . "'");
        
        #$row = $results->fetchArray();
        
        $row['HASH'] = '601dda8c147db4f7188e9ff36160a8c23da68652ff735fdda102d9839e378fa8';
        
        return new \ZendServerWebApi\Model\ApiKey(self::API_KEY_NAME, $row['HASH']);
    }
}

return new ApiKey();