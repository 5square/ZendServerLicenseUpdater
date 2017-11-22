<?php
namespace LicenseUpdater;

class ApiKey {
    
    const API_KEY_NAME = 'admin';
    
    public function __invoke(AdminApiKey $adminApiKey) {
        $hash = $adminApiKey();
        
        return new \ZendServerWebApi\Model\ApiKey(self::API_KEY_NAME, $hash);
    }
}

return new ApiKey();