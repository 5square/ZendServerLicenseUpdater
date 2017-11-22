<?php
namespace LicenseUpdater;

class LicenseManager {
    public function __invoke($config) {
        $orderNr = getenv('ORDER_NR');
        $licenseKey = getenv('LICENSE_KEY');
        
        if (!$orderNr) {
            $orderNr = $config['license']['orderNr'];
        }
        if (!$licenseKey) {
            $licenseKey = $config['license']['licenseKey'];
        }
        
        if (!$orderNr || !$licenseKey) {
            throw new \Exception('Order Nr or License Key is missing. Please check env vars ORDER_NR and LICENSE_KEY or license.php');
        }
        
        $license = [];
        $license['licenseName'] = $license['orderNr'];
        $license['licenseValue'] = $license['licenseKey'];
        
        return [
            'licenseName' => $orderNr,
            'licenseValue' => $licenseKey
        ];
    }
}

return new LicenseManager();