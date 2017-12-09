<?php
namespace LicenseUpdater;

chdir(zend_deployment_library_path('ZendServerSDK'));
include "phar://zs-client.phar/vendor/autoload.php";
require "phar://zs-client.phar/vendor/zenddevops/webapi/src/ZendServerWebApi/Model/ApiManager.php";


use Zend\ServiceManager\ServiceManager;
use Zend\Mvc\Service;
use ZendServerWebApi\Model\ZendServer;
use Zend\Log\Logger;
use ZendServerWebApi\Model\Http;

class ApiManagerFactory {
    
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
        
        $adminApiKey = require_once __DIR__ . '/AdminApiKey.php';
        
        $apiKey = require_once __DIR__ . '/ApiKey.php';
        $serviceManager->setService('defaultApiKey', $apiKey($adminApiKey));
        
        $licenseManager = require_once __DIR__ . '/LicenseManager.php';
        $serviceManager->setService('license', $licenseManager($config));
        
        $apiManager = new ApiManager();
        $apiManager->setServiceLocator($serviceManager);
        
        return $apiManager;
    }
}

class ApiManager extends \ZendServerWebApi\Model\ApiManager {

    public function restartPhp() {
        return parent::restartPhp([true]);
    }

    public function serverStoreLicense() {
        $license = $this->getServiceLocator()->get('license');

        return parent::serverStoreLicense($license);
    }

}

return ApiManagerFactory::factory(require __DIR__ . '/config.php');