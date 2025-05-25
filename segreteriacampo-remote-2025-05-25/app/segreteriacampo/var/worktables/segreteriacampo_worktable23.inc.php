<?php
$_CAMILA['page']->camila_worktable = true;

$wt_id = substr($_SERVER['PHP_SELF'], 12, -4);
$wt_short_title = 'MEZZI ATTESI';
$wt_full_title = 'Mezzi attesi';

if (intval($wt_id) > 0)
    $_CAMILA['page']->camila_worktable_id = $wt_id;

function worktable_get_safe_temp_filename($name) {
    global $_CAMILA;
    return CAMILA_TMP_DIR . '/lastval_' . $_CAMILA['lang'] . '_' . preg_replace('/[^a-z]/', '', strtolower($name));
}

function worktable_get_last_value_from_file($name) {
    return file_get_contents(worktable_get_safe_temp_filename($name));
}


function worktable_get_next_autoincrement_value($table, $column) {

    global $_CAMILA;

    $result = $_CAMILA['db']->Execute('select max('.$column.') as id from ' . $table);
    if ($result === false)
        camila_error_page(camila_get_translation('camila.sqlerror') . ' ' . $_CAMILA['db']->ErrorMsg());

    return intval($result->fields['id']) + 1;

}


function worktable_parse_default_expression($expression, $form) {
    return camila_parse_default_expression($expression, $form->fields['id']->defaultvalue);
}


if (camila_form_in_update_mode('segreteriacampo_worktable23')) {

    

    $form = new dbform('segreteriacampo_worktable23', 'id');

    if ($_CAMILA['adm_user_group'] != CAMILA_ADM_USER_GROUP)
    {
        $form->caninsert = true;
        $form->candelete = true;
        $form->canupdate = true;
    }
    else
    if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
    {
        $form->caninsert = true;
        $form->candelete = true;
        $form->canupdate = true;
    }

    $form->drawrules = true;
    $form->drawheadersubmitbutton = true;

    new form_textbox($form, 'id', camila_get_translation('camila.worktable.field.id'));
    if (is_object($form->fields['id'])) {
        if ($_REQUEST['camila_update'] == 'new' && !isset($_REQUEST['camila_phpform_sent'])) {
            $_CAMILA['db_genid'] = $_CAMILA['db']->GenID(CAMILA_APPLICATION_PREFIX.'worktableseq', 100000);
            $form->fields['id']->defaultvalue = $_CAMILA['db_genid'];
        }
        $form->fields['id']->updatable = false;
        $form->fields['id']->forcedraw = true;
    }
	
	new form_textbox($form, 'uuid', camila_get_translation('camila.worktable.field.uuid'));
	if (defined('CAMILA_APPLICATION_UUID_ENABLED') && CAMILA_APPLICATION_UUID_ENABLED === true) {
        if ($_REQUEST['camila_update'] == 'new' && !isset($_REQUEST['camila_phpform_sent'])) {
            $form->fields['uuid']->defaultvalue = camila_generate_uuid();
        }
		if (is_object($form->fields['uuid'])) {
			$form->fields['uuid']->updatable = false;
			$form->fields['uuid']->forcedraw = true;
		}		
	}

    
    new form_textbox($form, 'organizzazione', 'ORGANIZZAZIONE', false, 30, 255, '');

    
    new form_textbox($form, 'provincia', 'PROVINCIA', false, 30, 255, '');

    
    new form_textbox($form, 'codiceinventario', 'CODICE INVENTARIO', false, 30, 255, '');

    
    new form_textbox($form, 'targa', 'TARGA', false, 30, 255, '');

    
    new form_static_listbox($form, 'categoria', 'CATEGORIA', 'Non assegnata,Imbarcazioni,Mezzi aerei,Mezzi speciali,Rimorchi,Veicoli', false, '');

    
    new form_static_listbox($form, 'tipologia', 'TIPOLOGIA', 'Non assegnata,--Imbarcazioni,Barca,Gommone,Hovercraft,Moto d\'acqua,--Mezzi aerei,Aeroplano,Drone,Elicottero, Idrovolante,ULM (ultraleggero motorizzato),--Mezzi speciali,Battipista,Bobcat,Escavatore,Listo spazzola,Motoslitta,Muletto,Sollevatore idraulico,Spargi sabbia e sale,Spazzaneve,Terna,--Rimorchi,Biga,Carrello,Carrello Appendice,Rimorchio,Roulotte,Semirimorchio, --Veicoli,Ambulanza,Autobotte,Autobus,Autocarro,Autogru,Autoidroschiuma,Automedica,Autopompa serbatoio (APS),Autoscala,Autovettura,Camper,Carro attrezzi,Fuoristrada,Furgone,Motociclo,Motrice,Trattore agricolo,Trattore stradale', false, '');

    
    new form_textbox($form, 'marca', 'MARCA', false, 30, 255, '');

    
    new form_textbox($form, 'modello', 'MODELLO', false, 30, 255, '');

    
    new form_textbox($form, 'note', 'NOTE', false, 30, 255, '');

    
    new form_textbox($form, 'servizio', 'SERVIZIO', false, 30, 255, '');

    
    new form_textbox($form, 'turno', 'TURNO', false, 30, 255, '');

    
    new form_textbox($form, 'nomereferente', 'NOME REFERENTE', false, 30, 255, '');

    
    new form_textbox($form, 'numerotelefonoreferente', 'NUMERO TELEFONO REFERENTE', false, 30, 255, '');

    
    new form_textbox($form, 'proprietario', 'PROPRIETARIO', false, 30, 255, '');

    
    new form_textbox($form, 'codiceorganizzazione', 'CODICE ORGANIZZAZIONE', false, 30, 255, '');

    
    new form_textbox($form, 'codiceinventarioregionale', 'CODICE INVENTARIO REGIONALE', false, 30, 255, '');

    
    new form_textbox($form, 'provenienza', 'PROVENIENZA', false, 30, 255, '');

    
    new form_textarea($form, 'noteulteriori', 'NOTE ULTERIORI', false, 10, 80, 1000, '');

    

    if (CAMILA_WORKTABLE_SPECIAL_ICON_ENABLED || $_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
        new form_static_listbox($form, 'cf_bool_is_selected', camila_get_translation('camila.worktable.field.selected'), camila_get_translation('camila.worktable.options.noyes'));

    if (CAMILA_WORKTABLE_SELECTED_ICON_ENABLED || $_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
        new form_static_listbox($form, 'cf_bool_is_special', camila_get_translation('camila.worktable.field.special'), camila_get_translation('camila.worktable.options.noyes'));

    if ($_REQUEST['camila_update'] != 'new') {

    new form_datetime($form, 'created', camila_get_translation('camila.worktable.field.created'));
    if (is_object($form->fields['created'])) $form->fields['created']->updatable = false;

    new form_textbox($form, 'created_by', camila_get_translation('camila.worktable.field.created_by'));
    if (is_object($form->fields['created_by'])) $form->fields['created_by']->updatable = false;

    new form_textbox($form, 'created_by_surname', camila_get_translation('camila.worktable.field.created_by_surname'));
    if (is_object($form->fields['created_by_surname'])) $form->fields['created_by_surname']->updatable = false;

    new form_textbox($form, 'created_by_name', camila_get_translation('camila.worktable.field.created_by_name'));
    if (is_object($form->fields['created_by_name'])) $form->fields['created_by_name']->updatable = false;

    new form_static_listbox($form, 'created_src', camila_get_translation('camila.worktable.field.created_src'), camila_get_translation('camila.worktable.options.recordmodsrc'));
    if (is_object($form->fields['created_src'])) $form->fields['created_src']->updatable = false;

    new form_datetime($form, 'last_upd', camila_get_translation('camila.worktable.field.last_upd'));
    if (is_object($form->fields['last_upd'])) $form->fields['last_upd']->updatable = false;

    new form_textbox($form, 'last_upd_by', camila_get_translation('camila.worktable.field.last_upd_by'));
    if (is_object($form->fields['last_upd_by'])) $form->fields['last_upd_by']->updatable = false;

    new form_textbox($form, 'last_upd_by_surname', camila_get_translation('camila.worktable.field.last_upd_by_surname'));
    if (is_object($form->fields['last_upd_by_surname'])) $form->fields['last_upd_by_surname']->updatable = false;

    new form_textbox($form, 'last_upd_by_name', camila_get_translation('camila.worktable.field.last_upd_by_name'));
    if (is_object($form->fields['last_upd_by_name'])) $form->fields['last_upd_by_name']->updatable = false;

    new form_textbox($form, 'last_upd_by_name', camila_get_translation('camila.worktable.field.last_upd_by_name'));
    if (is_object($form->fields['last_upd_by_name'])) $form->fields['last_upd_by_name']->updatable = false;

    new form_static_listbox($form, 'last_upd_src', camila_get_translation('camila.worktable.field.last_upd_src'), camila_get_translation('camila.worktable.options.recordmodsrc'));
    if (is_object($form->fields['last_upd_src'])) $form->fields['last_upd_src']->updatable = false;

    new form_textbox($form, 'mod_num', camila_get_translation('camila.worktable.field.mod_num'));
    if (is_object($form->fields['mod_num'])) $form->fields['mod_num']->updatable = false;


}

	
	
    if (is_object($form->fields['organizzazione']))
{
$form->fields['organizzazione']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['organizzazione']->autosuggest_field = 'organizzazione';
$form->fields['organizzazione']->autosuggest_idfield = 'id';
$form->fields['organizzazione']->autosuggest_infofields = '';
$form->fields['organizzazione']->autosuggest_pickfields = '';
$form->fields['organizzazione']->autosuggest_destfields = '';
}


    $form->process();
    
    $form->draw();

} else {
      $report_fields = 'id,cf_bool_is_special,cf_bool_is_selected,organizzazione,provincia,codiceinventario,targa,categoria,tipologia,marca,modello,note,servizio,turno,nomereferente,numerotelefonoreferente,proprietario,codiceorganizzazione,codiceinventarioregionale,provenienza,noteulteriori,created,created_by,created_by_surname,created_by_name,last_upd,last_upd_by,last_upd_by_surname,last_upd_by_name,mod_num, uuid';
	  //$admin_report_fields = '';
      $default_fields = 'cf_bool_is_special,cf_bool_is_selected,organizzazione,provincia,codiceinventario,targa,categoria,tipologia,marca,modello,note,servizio,turno,nomereferente,numerotelefonoreferente,proprietario,codiceorganizzazione,codiceinventarioregionale,provenienza,noteulteriori';

      if (isset($_REQUEST['camila_rest'])) {
          $report_fields = str_replace('cf_bool_is_special,', '', $report_fields);
          $report_fields = str_replace('cf_bool_is_selected,', '', $report_fields);
          $default_fields = $report_fields;
      }
	  
	  //if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
		//  $default_fields = $admin_report_fields;

      if ($_CAMILA['page']->camila_exporting())
          $mapping = 'created=Data creazione#last_upd=Ultimo aggiornamento#last_upd_by=Utente ult. agg.#last_upd_src=Sorgente Ult. agg.#last_upd_by_name=Nome Utente ult. agg.#last_upd_by_surname=Cognome Utente ult. agg.#mod_num=Num. mod.#id=Cod. riga#created_by=Utente creaz.#created_src=Sorgente creaz.#created_by_surname=Cognome Utente creaz.#created_by_name=Nome Utente creaz.#cf_bool_is_special=contrassegnati come speciali#cf_bool_is_selected=selezionati#organizzazione=ORGANIZZAZIONE#provincia=PROVINCIA#codiceinventario=CODICE INVENTARIO#targa=TARGA#categoria=CATEGORIA#tipologia=TIPOLOGIA#marca=MARCA#modello=MODELLO#note=NOTE#servizio=SERVIZIO#turno=TURNO#nomereferente=NOME REFERENTE#numerotelefonoreferente=NUMERO TELEFONO REFERENTE#proprietario=PROPRIETARIO#codiceorganizzazione=CODICE ORGANIZZAZIONE#codiceinventarioregionale=CODICE INVENTARIO REGIONALE#provenienza=PROVENIENZA#noteulteriori=NOTE ULTERIORI';
      else
          $mapping = 'created=Data creazione#last_upd=Ultimo aggiornamento#last_upd_by=Utente ult. agg.#last_upd_src=Sorgente Ult. agg.#last_upd_by_name=Nome Utente ult. agg.#last_upd_by_surname=Cognome Utente ult. agg.#mod_num=Num. mod.#id=Cod. riga#created_by=Utente creaz.#created_src=Sorgente creaz.#created_by_surname=Cognome Utente creaz.#created_by_name=Nome Utente creaz.#cf_bool_is_special=contrassegnati come speciali#cf_bool_is_selected=selezionati#organizzazione=ORGANIZZAZIONE#provincia=PROVINCIA#codiceinventario=COD. INV.#targa=TARGA#categoria=CATEGORIA#tipologia=TIPOLOGIA#marca=MARCA#modello=MODELLO#note=NOTE#servizio=SERVIZIO#turno=TURNO#nomereferente=NOME REFERENTE#numerotelefonoreferente=NUM. TEL. REFERENTE#proprietario=PROPRIETARIO#codiceorganizzazione=COD. ORGANIZZAZIONE#codiceinventarioregionale=COD. INV. REG.#provenienza=PROVENIENZA#noteulteriori=NOTE ULTERIORI';

      $filter = '';

      if ($_CAMILA['user_visibility_type']=='personal')
          $filter= ' where created_by='.$_CAMILA['db']->qstr($_CAMILA['user']);
	  
	  if ($_CAMILA['user_visibility_type']=='group')
          $filter= ' where grp='.$_CAMILA['db']->qstr($_CAMILA['user_group']);

	  //if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
	//	  $stmt = 'select ' . $admin_report_fields . ' from segreteriacampo_worktable23';
	  //else
		  $stmt = 'select ' . $report_fields . ' from segreteriacampo_worktable23';
      
      $report = new report($stmt.$filter, '', 'organizzazione', 'asc', $mapping, null, 'id', $default_fields, '', (isset($_REQUEST['camila_rest'])) ? false : true, (isset($_REQUEST['camila_rest'])) ? false : true);
	  
	  switch ($wt_short_title) {

	case 'VOLONTARI':
		$funzioniCustom = [
			'servizio' => function($row, $val, $record) {
				$firstLabel = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->label : $row->column[0]->label;

				if ($firstLabel == 'SCHEDA') {
					$url = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->url : $row->column[0]->url;
					$parsed_url = parse_url($url);
					parse_str($parsed_url['query'], $params);
					$camila_update = urldecode($params['camila_update']);
					$data = unserialize($camila_update);
					$camilakey_id = $data['camilakey_id'] ?? null;
					
					$service = $row->column[($row->number_of_columns)-1]->text;
					$link = "index.php?dashboard=02&service=".urlencode($service).'&id='.urlencode($camilakey_id);
					$l = new CHAW_link('Movimenta', $link);
					if (is_array($row->column[0]))
						$row->column[0][] = $l;
					else
						$row->column[0] =[$row->column[0],$l];
				}
			}
		];
		$report->customFunctions = $funzioniCustom;
		break;

	case 'MEZZI':
		$funzioniCustom = [
			'servizio' => function($row, $val, $record) {
				$firstLabel = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->label : $row->column[0]->label;

				if ($firstLabel == 'SCHEDA') {
					$url = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->url : $row->column[0]->url;
					$parsed_url = parse_url($url);
					parse_str($parsed_url['query'], $params);
					$camila_update = urldecode($params['camila_update']);
					$data = unserialize($camila_update);
					$camilakey_id = $data['camilakey_id'] ?? null;
					
					$service = $row->column[($row->number_of_columns)-1]->text;
					$link = "index.php?dashboard=04&service=".urlencode($service).'&id='.urlencode($camilakey_id);
					$l = new CHAW_link('Movimenta', $link);
					if (is_array($row->column[0]))
						$row->column[0][] = $l;
					else
						$row->column[0] =[$row->column[0],$l];
				}
			}
		];
		$report->customFunctions = $funzioniCustom;
		break;

	case 'MATERIALI':
		$funzioniCustom = [
			'servizio' => function($row, $val, $record) {
				$firstLabel = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->label : $row->column[0]->label;

				if ($firstLabel == 'SCHEDA') {
					$url = (is_array($row->column[0])) ? $row->column[0][array_key_first($row->column[0])]->url : $row->column[0]->url;
					$parsed_url = parse_url($url);
					parse_str($parsed_url['query'], $params);
					$camila_update = urldecode($params['camila_update']);
					$data = unserialize($camila_update);
					$camilakey_id = $data['camilakey_id'] ?? null;
					
					$service = $row->column[($row->number_of_columns)-1]->text;
					$link = "index.php?dashboard=03&service=".urlencode($service).'&id='.urlencode($camilakey_id);
					$l = new CHAW_link('Movimenta', $link);
					if (is_array($row->column[0]))
						$row->column[0][] = $l;
					else
						$row->column[0] =[$row->column[0],$l];
				}
			}
		];
		$report->customFunctions = $funzioniCustom;
		break;
}


	  

      if (true && !isset($_REQUEST['camila_rest'])) {
          $report->additional_links = Array(camila_get_translation('camila.report.insertnew') => basename($_SERVER['PHP_SELF']) . '?camila_update=new');

          $myImage1 = new CHAW_image(CAMILA_IMG_DIR . 'wbmp/add.wbmp', CAMILA_IMG_DIR . 'png/add.png', '-');
		  $report->additional_links_css_classes = Array(camila_get_translation('camila.report.insertnew') => 'btn '.CAMILA_UI_DEFAULT_BTN_SIZE.' btn-default btn-primary button is-primary is-small');

          if (($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP) || CAMILA_WORKTABLE_IMPORT_ENABLED)          
          $report->additional_links[camila_get_translation('camila.worktable.import')] = 'cf_worktable_wizard_step4.php?camila_custom=' . $wt_id . '&camila_returl=' . urlencode($_SERVER['PHP_SELF']);
      }

      if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP) {
          $report->additional_links[camila_get_translation('camila.worktable.rebuild')] = 'cf_worktable_admin.php?camila_custom=' . $wt_id . '&camila_worktable_op=rebuild' . '&camila_returl=' . urlencode($_SERVER['PHP_SELF']);
          $report->additional_links[camila_get_translation('camila.worktable.reconfig')] = 'cf_worktable_wizard_step2.php?camila_custom=' . $wt_id . '&camila_returl=' . urlencode($_SERVER['PHP_SELF']);
      }

      if (CAMILA_WORKTABLE_CONFIRM_VIA_MAIL_ENABLED) {
          $report->additional_links[camila_get_translation('camila.worktable.confirm')] = basename($_SERVER['PHP_SELF']) . '?camila_visible_cols_only=y&camila_worktable_export=dataonly&camila_pagnum=-1&camila_export_filename=WORKTABLE&camila_export_action=sendmail&hidden=camila_xls&camila_export_format=camila_xls&camila_xls=Esporta';

          $myImage1 = new CHAW_image(CAMILA_IMG_DIR . 'wbmp/accept.wbmp', CAMILA_IMG_DIR . 'png/accept.png', '-');
          $report->additional_links_images[camila_get_translation('camila.worktable.confirm')]=$myImage1;

      }

      $report->formulas=Array();
      $report->queries=Array();

      

      $report->process();
      $report->draw();

}
?>