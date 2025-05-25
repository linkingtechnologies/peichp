<?php
require_once('../../camila/autoloader.inc.php');
require('../../camila/config.inc.php');
require('../../camila/i18n.inc.php');
require('../../camila/camila_hawhaw.php');
require('../../camila/database.inc.php');

define('LOCALE', '%%LOCALE%%');
define('PLUGIN_NAMES', '%%PLUGIN_NAMES%%');

$camilaApp = new CamilaApp();
$db = NewADOConnection(CAMILA_DB_DSN);

global $_CAMILA;
$_CAMILA['worktable_configurator_force_lang'] = 'it';

$camilaApp->db = $db;
$camilaApp->lang = LOCALE;
$camilaApp->resetTables(CAMILA_TABLES_DIR);
$pluginArray = array_map('trim', explode(',', PLUGIN_NAMES));
foreach ($pluginArray as $plugin) {
	$camilaApp->resetTables(CAMILA_APP_PATH . '/plugins/'.$plugin.'/tables');
	$camilaApp->resetWorkTables(CAMILA_APP_PATH . '/plugins/'.$plugin.'/tables');
}
$db->Close();
?>