<?php
namespace LicenseUpdater;

use Zend\ServiceManager\ServiceManager;
use Zend\Mvc\Service;
use ZendServerWebApi\Model\ZendServer;
use Zend\Log\Logger;
use ZendServerWebApi\Model\Http;

class ApiManager {
    
    public static function factory($config) {
        $configObj = new Service\ServiceManagerConfig($config);
        $serviceManager = new ServiceManager($configObj);
        
        $serviceManager->setService('Config', $config);
        
        $serviceManager->setService('targetZendServer', 
            ZendServer::factory($config['targetConfig'])
        );
        
        $serviceManager->setService('log', 
            new Logger(['writers' => $config['log']['writers']])
        );
        
        $serviceManager->setService('zendServerClient', 
            new Http\Client(null, ['\ZendServerWebApi\Model\Http\Adapter\Socket'])
        );
        
        $apiKey = require_once __DIR__ . '/ApiKey.php';
        $serviceManager->setService('defaultApiKey', $apiKey());
        
        $licenseManager = require_once __DIR__ . '/LicenseManager.php';
        $serviceManager->setService('license', $licenseManager($config));
        
        $apiManager = new class() extends \ZendServerWebApi\Model\ApiManager {

            public function restartPhp() {
                return parent::restartPhp([true]);
            }
            
            public function serverStoreLicense() {
                $license = $this->getServiceLocator()->get('license');
                
                return parent::serverStoreLicense($license);
            }
        };
        $apiManager->setServiceLocator($serviceManager);
        
        return $apiManager;
    }
}

chdir(zend_deployment_library_path('ZendServerSDK'));
include "phar://zs-client.phar/vendor/autoload.php";

return ApiManager::factory(require __DIR__ . '/config.php');