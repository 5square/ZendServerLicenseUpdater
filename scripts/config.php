<?php
$config = [
    'console' => [
        'router' => [ 
            'routes' => [ 
                'restartPhp' => [
                    'options' => [
                        'defaults' => [
                            'controller' => 'webapi-api-controller',
                            'action' => 'restartPhp',
                            'apiMethod' => 'post'
                        ]
                    ]
                ],
                'serverStoreLicense' => array(
                    'options' => array(
                        'defaults' => array(
                            'controller' => 'webapi-api-controller',
                            'action' => 'serverStoreLicense',
                            'apiMethod' => 'post'
                        )
                    )
                ),
            ]
        ]
    ],
    'targetConfig' => [
        'zsversion' => '9.0',
        'zsurl' => 'http://localhost:10081/ZendServer'
    ],
    'log' => [
        'writers' => [
            ['name' => 'Mock']
        ]
    ]
];

if (file_exists(__DIR__ . '/license.php')) {
    $license = require __DIR__ . '/license.php';
    if (!is_array($license)) throw new \Exception('File license.php does not return an array');
    
    $config['license'] = $license;
}

return $config;