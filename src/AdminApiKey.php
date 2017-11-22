<?php
namespace LicenseUpdater;

class AdminApiKey {
  public function __invoke() {
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
      $dbFile = 'C:\Program Files (x86)\Zend\ZendServer\data\db\gui.db';
    }
    else {
      $dbFile = '/usr/local/zend/var/db/gui.db';
    }

    $db = new \SQLite3($dbFile);
    $results = $db->query("SELECT HASH FROM GUI_WEBAPI_KEYS WHERE NAME='admin'");

    $row = $results->fetchArray();

    return $row['HASH'];
  }
}

return new AdminApiKey();
