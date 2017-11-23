# ZendServerLicenseUpdater

ZendServerLicenseUpdater provides a Zend Server library which updates the Zend Server license when being deployed. Additionaly it restarts the Zend Server so that the new license takes effect.

## Building the Library
The library is a standard Zend Server library. For your convenience a PHP script ```create-zpk.php``` has been created which allows to build the library. Call 
```
php create-zpk.php
```
to create the zpk file. This script will download the zs-client.phar file which is responsible for validating and creating the package.
For Demo purposes two library packages have already be created and can be found in the ```zpk``` folder. 

### License
As the license information is part of the package, one has to modify the values in ```license.php```accordingly, before creating the zpk.

### Update
One benefitial feature of Zend Server is the ability to check for new versions of a library, which means in our case checking for a new license.
New versions are exposed through JSON formatted data - the URL which is being checked has to be set in ```deployment.xml```.
For demo purposes there is a json file available (```update.json```) that can be downloaded through github pages from the Zend Server Library update mechanism.
  
## Deployment
In genereal the zpk file can be deployed via the Zend Server UI or via the WebAPI. 

### CLI Deployment preparation  
In order to make the initial deployment process hazzle free, a phar file that contains the WebAPI script and the actual zpk file, can be created. Call 
```
php -d phar.readonly=0 phar/create-phar.php
```
and a LicenseUpdate.phar file will be created in the ```build```directory.

### Initial CLI Deployment
The ```LicenseUpdate.phar``` file just has to be executed with the php binary on the target system. For the best experience one-liners have been tested on Windows and Linux which are downloading the phar file and execute it immediately. 

Linux:
```
LICENSE_UPDATER="https://github.com/5square/ZendServerLicenseUpdater/blob/master/build/LicenseUpdater.phar?raw=true"; php -r '$p=sys_get_temp_dir()."/LicenseUpdater.phar"; file_put_contents($p,file_get_contents(getenv("LICENSE_UPDATER")));echo shell_exec($_SERVER["_"] . " $p");'
```

Windows:
```
php -r "$phar='https://github.com/5square/ZendServerLicenseUpdater/blob/master/build/LicenseUpdater.phar?raw=true';$p=sys_get_temp_dir().'/LicenseUpdater.phar'; file_put_contents($p,file_get_contents($phar));echo shell_exec('php ' . $p);"
```

Of course the LICENSE_UPDATER env var resp. the $phar var has to be modified so that the correct phar file can be downloaded.

### Updates / new license
The Zend Server UI allows to check for available updates by downloading the json file specified in the deployment.xml (see above). If a new version can be found it is being downloaded and deployed automatically. 
However, the same process as being described in 'Initial CLI Deployment' paragraph can be executed, too.  