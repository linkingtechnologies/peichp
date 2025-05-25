<?php
$_CAMILA['page']->camila_worktable = true;

$wt_id = substr($_SERVER['PHP_SELF'], 12, -4);
$wt_short_title = 'VOLONTARI';
$wt_full_title = 'Volontari';

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


if (camila_form_in_update_mode('segreteriacampo_worktable18')) {

    

    $form = new dbform('segreteriacampo_worktable18', 'id');

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

    
    new form_textbox($form, 'organizzazione', 'ORGANIZZAZIONE', true, 30, 255, 'uppercase');

    
    new form_textbox($form, 'provincia', 'PROVINCIA', true, 30, 2, '');

    
    new form_textbox($form, 'cognome', 'COGNOME', true, 30, 255, 'uppercase');

    
    new form_textbox($form, 'nome', 'NOME', true, 30, 255, 'uppercase');

    
    new form_textbox($form, 'codicefiscale', 'CODICE FISCALE', false, 30, 255, 'uppercase');

if (is_object($form->fields['codicefiscale'])) $form->fields['codicefiscale']->autofocus = true;
    
    new form_date($form, 'datadinascita', 'DATA DI NASCITA', false, '');

    
    new form_static_listbox($form, 'mansione', 'MANSIONE', 'OPERATORE LOGISTICO,OPERATORE IDROGEOLOGICO,OPERATORE MOVIMENTO TERRA,OPERATORE INSACCHETTAMENTO,OPERATORE MOTOSEGA,OPERATORE SUB,OPERATORE CINOFILO,OPERATORE SEGRETERIA,OPERATORE SALA OPERATIVA,OPERATORE RADIO,OPERATORE NAUTICO,ELETTRICISTA,MURATORE,IDRAULICO,OPERATORE SANITARIO,OPERATORE CUCINA,OPERATORE ANTINCENDIO,OPERATORE A CAVALLO,OPERATORE SUBACQUEO', false, '');

    
    new form_textbox($form, 'servizio', 'SERVIZIO', false, 30, 255, '');
if (is_object($form->fields['servizio'])) $form->fields['servizio']->defaultvalue = worktable_parse_default_expression('IN ATTESA DI SERVIZIO', $form);

    
    new form_static_listbox($form, 'responsabile', 'RESPONSABILE', 'NO,SI', false, '');
if (is_object($form->fields['responsabile'])) $form->fields['responsabile']->help = 'Responsabile operativo (es. caposquadra) o responsabile di missione o funzione.';
if (is_object($form->fields['responsabile'])) $form->fields['responsabile']->defaultvalue = worktable_parse_default_expression('N', $form);

    
    new form_textbox($form, 'cellulare', 'CELLULARE', false, 30, 255, '');
if (is_object($form->fields['cellulare'])) $form->fields['cellulare']->help = 'Preferibile indicare un recapito telefonico per ogni responsabile.';

    
    new form_static_listbox($form, 'autista', 'AUTISTA', 'n.d.,NO,SI', false, '');
if (is_object($form->fields['autista'])) $form->fields['autista']->help = 'Indicare se autista di uno dei mezzi in servizio.';

    
    new form_static_listbox($form, 'pranzo', 'PRANZO', 'n.d.,NO,SI', false, '');

    
    new form_static_listbox($form, 'cena', 'CENA', 'n.d.,NO,SI', false, '');

    
    new form_static_listbox($form, 'pernottamento', 'PERNOTTAMENTO', 'n.d.,NO,SI', false, '');

    
    new form_static_listbox($form, 'beneficidilegge', 'BENEFICI DI LEGGE', 'n.d.,NO,SI', false, '');
if (is_object($form->fields['beneficidilegge'])) $form->fields['beneficidilegge']->help = 'Indicare se intende usufruire dei "benefici di legge".';
if (is_object($form->fields['beneficidilegge'])) $form->fields['beneficidilegge']->defaultvalue = worktable_parse_default_expression('N', $form);

    
    new form_integer($form, 'numggbenlegge', 'NUM. GG. BEN. LEGGE', false, 5, 255, '');

    
    new form_textbox($form, 'codiceorganizzazione', 'CODICE ORGANIZZAZIONE', false, 30, 255, '');

    
    new form_textbox($form, 'turno', 'TURNO', false, 30, 255, '');
if (is_object($form->fields['turno'])) $form->fields['turno']->defaultvalue = worktable_get_last_value_from_file('TURNO');
if (is_object($form->fields['turno'])) $form->fields['turno']->write_value_to_file = worktable_get_safe_temp_filename('TURNO');

    
    new form_textbox($form, 'codicebadge', 'CODICE BADGE', false, 30, 255, '');
if (is_object($form->fields['codicebadge'])) $form->fields['codicebadge']->defaultvalue = worktable_parse_default_expression('${prefissocodiceabarre}${codice riga}', $form);

    
    new form_textbox($form, 'codicevolontario', 'CODICE VOLONTARIO', false, 30, 255, '');

    
    new form_date($form, 'datainizioattestato', 'DATA INIZIO ATTESTATO', true, '');
if (is_object($form->fields['datainizioattestato'])) $form->fields['datainizioattestato']->defaultvalue = date('Y-m-d');

    
    new form_date($form, 'datafineattestato', 'DATA FINE ATTESTATO', false, '');

    
    new form_datetime($form, 'dataoraregistrazione', 'DATA/ORA REGISTRAZIONE', false, '');
if (is_object($form->fields['dataoraregistrazione'])) $form->fields['dataoraregistrazione']->hslots = 60;
if (is_object($form->fields['dataoraregistrazione'])) $form->fields['dataoraregistrazione']->defaultvalue = date('Y-m-d H:i:s');

    
    new form_datetime($form, 'dataorauscitadefinitiva', 'DATA/ORA USCITA DEFINITIVA', false, '');
if (is_object($form->fields['dataorauscitadefinitiva'])) $form->fields['dataorauscitadefinitiva']->hslots = 60;

    
    new form_textbox($form, 'note', 'NOTE', false, 30, 255, '');

    
    new form_textbox($form, 'nomecampo', 'NOME CAMPO', false, 30, 255, '');
if (is_object($form->fields['nomecampo'])) $form->fields['nomecampo']->defaultvalue = worktable_parse_default_expression('${nomecampo}', $form);

    

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

	$form->recordReadOnlyIfNotNullFields = Array('dataorauscitadefinitiva');
	
    if (is_object($form->fields['organizzazione']))
{
$form->fields['organizzazione']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['organizzazione']->autosuggest_field = 'organizzazione';
$form->fields['organizzazione']->autosuggest_idfield = 'id';
$form->fields['organizzazione']->autosuggest_infofields = 'provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note';
$form->fields['organizzazione']->autosuggest_pickfields = 'provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note';
$form->fields['organizzazione']->autosuggest_destfields = 'provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note';
}
if (is_object($form->fields['provincia']))
{
$form->fields['provincia']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['provincia']->autosuggest_field = 'provincia';
$form->fields['provincia']->autosuggest_idfield = 'id';
$form->fields['provincia']->autosuggest_infofields = 'cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione';
$form->fields['provincia']->autosuggest_pickfields = 'cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione';
$form->fields['provincia']->autosuggest_destfields = 'cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione';
}
if (is_object($form->fields['cognome']))
{
$form->fields['cognome']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['cognome']->autosuggest_field = 'cognome';
$form->fields['cognome']->autosuggest_idfield = 'id';
$form->fields['cognome']->autosuggest_infofields = 'nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia';
$form->fields['cognome']->autosuggest_pickfields = 'nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia';
$form->fields['cognome']->autosuggest_destfields = 'nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia';
}
if (is_object($form->fields['nome']))
{
$form->fields['nome']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['nome']->autosuggest_field = 'nome';
$form->fields['nome']->autosuggest_idfield = 'id';
$form->fields['nome']->autosuggest_infofields = 'codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome';
$form->fields['nome']->autosuggest_pickfields = 'codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome';
$form->fields['nome']->autosuggest_destfields = 'codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome';
}
if (is_object($form->fields['codicefiscale']))
{
$form->fields['codicefiscale']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['codicefiscale']->autosuggest_field = 'codicefiscale';
$form->fields['codicefiscale']->autosuggest_idfield = 'id';
$form->fields['codicefiscale']->autosuggest_infofields = 'datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
$form->fields['codicefiscale']->autosuggest_pickfields = 'datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
$form->fields['codicefiscale']->autosuggest_destfields = 'datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
}
if (is_object($form->fields['datadinascita']))
{
$form->fields['datadinascita']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['datadinascita']->autosuggest_field = 'datadinascita';
$form->fields['datadinascita']->autosuggest_idfield = 'id';
$form->fields['datadinascita']->autosuggest_infofields = 'codicefiscale,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
$form->fields['datadinascita']->autosuggest_pickfields = 'codicefiscale,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
$form->fields['datadinascita']->autosuggest_destfields = 'codicefiscale,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome';
}
if (is_object($form->fields['mansione']))
{
$form->fields['mansione']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['mansione']->autosuggest_field = 'mansione';
$form->fields['mansione']->autosuggest_idfield = 'id';
$form->fields['mansione']->autosuggest_infofields = 'responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita';
$form->fields['mansione']->autosuggest_pickfields = 'responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita';
$form->fields['mansione']->autosuggest_destfields = 'responsabile,cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita';
}
if (is_object($form->fields['responsabile']))
{
$form->fields['responsabile']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['responsabile']->autosuggest_field = 'responsabile';
$form->fields['responsabile']->autosuggest_idfield = 'id';
$form->fields['responsabile']->autosuggest_infofields = 'cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione';
$form->fields['responsabile']->autosuggest_pickfields = 'cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione';
$form->fields['responsabile']->autosuggest_destfields = 'cellulare,codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione';
}
if (is_object($form->fields['cellulare']))
{
$form->fields['cellulare']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['cellulare']->autosuggest_field = 'cellulare';
$form->fields['cellulare']->autosuggest_idfield = 'id';
$form->fields['cellulare']->autosuggest_infofields = 'codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile';
$form->fields['cellulare']->autosuggest_pickfields = 'codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile';
$form->fields['cellulare']->autosuggest_destfields = 'codiceorganizzazione,codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile';
}
if (is_object($form->fields['codiceorganizzazione']))
{
$form->fields['codiceorganizzazione']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['codiceorganizzazione']->autosuggest_field = 'codiceorganizzazione';
$form->fields['codiceorganizzazione']->autosuggest_idfield = 'id';
$form->fields['codiceorganizzazione']->autosuggest_infofields = 'codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare';
$form->fields['codiceorganizzazione']->autosuggest_pickfields = 'codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare';
$form->fields['codiceorganizzazione']->autosuggest_destfields = 'codicevolontario,note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare';
}
if (is_object($form->fields['codicevolontario']))
{
$form->fields['codicevolontario']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['codicevolontario']->autosuggest_field = 'codicevolontario';
$form->fields['codicevolontario']->autosuggest_idfield = 'id';
$form->fields['codicevolontario']->autosuggest_infofields = 'note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione';
$form->fields['codicevolontario']->autosuggest_pickfields = 'note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione';
$form->fields['codicevolontario']->autosuggest_destfields = 'note,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione';
}
if (is_object($form->fields['note']))
{
$form->fields['note']->autosuggest_table = 'segreteriacampo_worktable22';
$form->fields['note']->autosuggest_field = 'note';
$form->fields['note']->autosuggest_idfield = 'id';
$form->fields['note']->autosuggest_infofields = 'organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario';
$form->fields['note']->autosuggest_pickfields = 'organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario';
$form->fields['note']->autosuggest_destfields = 'organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,responsabile,cellulare,codiceorganizzazione,codicevolontario';
}


    $form->process();
    
    $form->draw();

} else {
      $report_fields = 'id,cf_bool_is_special,cf_bool_is_selected,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,servizio,responsabile,cellulare,autista,pranzo,cena,pernottamento,beneficidilegge,numggbenlegge,codiceorganizzazione,turno,codicebadge,codicevolontario,datainizioattestato,datafineattestato,dataoraregistrazione,dataorauscitadefinitiva,note,nomecampo,created,created_by,created_by_surname,created_by_name,last_upd,last_upd_by,last_upd_by_surname,last_upd_by_name,mod_num, uuid';
	  //$admin_report_fields = '';
      $default_fields = 'cf_bool_is_special,cf_bool_is_selected,organizzazione,provincia,cognome,nome,codicefiscale,datadinascita,mansione,servizio,responsabile,cellulare,autista,pranzo,cena,pernottamento,beneficidilegge,numggbenlegge,codiceorganizzazione,turno,codicebadge,codicevolontario,datainizioattestato,datafineattestato,dataoraregistrazione,dataorauscitadefinitiva,note,nomecampo';

      if (isset($_REQUEST['camila_rest'])) {
          $report_fields = str_replace('cf_bool_is_special,', '', $report_fields);
          $report_fields = str_replace('cf_bool_is_selected,', '', $report_fields);
          $default_fields = $report_fields;
      }
	  
	  //if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
		//  $default_fields = $admin_report_fields;

      if ($_CAMILA['page']->camila_exporting())
          $mapping = 'created=Data creazione#last_upd=Ultimo aggiornamento#last_upd_by=Utente ult. agg.#last_upd_src=Sorgente Ult. agg.#last_upd_by_name=Nome Utente ult. agg.#last_upd_by_surname=Cognome Utente ult. agg.#mod_num=Num. mod.#id=Cod. riga#created_by=Utente creaz.#created_src=Sorgente creaz.#created_by_surname=Cognome Utente creaz.#created_by_name=Nome Utente creaz.#cf_bool_is_special=contrassegnati come speciali#cf_bool_is_selected=selezionati#organizzazione=ORGANIZZAZIONE#provincia=PROVINCIA#cognome=COGNOME#nome=NOME#codicefiscale=CODICE FISCALE#datadinascita=DATA DI NASCITA#mansione=MANSIONE#servizio=SERVIZIO#responsabile=RESPONSABILE#cellulare=CELLULARE#autista=AUTISTA#pranzo=PRANZO#cena=CENA#pernottamento=PERNOTTAMENTO#beneficidilegge=BENEFICI DI LEGGE#numggbenlegge=NUM. GG. BEN. LEGGE#codiceorganizzazione=CODICE ORGANIZZAZIONE#turno=TURNO#codicebadge=CODICE BADGE#codicevolontario=CODICE VOLONTARIO#datainizioattestato=DATA INIZIO ATTESTATO#datafineattestato=DATA FINE ATTESTATO#dataoraregistrazione=DATA/ORA REGISTRAZIONE#dataorauscitadefinitiva=DATA/ORA USCITA DEFINITIVA#note=NOTE#nomecampo=NOME CAMPO';
      else
          $mapping = 'created=Data creazione#last_upd=Ultimo aggiornamento#last_upd_by=Utente ult. agg.#last_upd_src=Sorgente Ult. agg.#last_upd_by_name=Nome Utente ult. agg.#last_upd_by_surname=Cognome Utente ult. agg.#mod_num=Num. mod.#id=Cod. riga#created_by=Utente creaz.#created_src=Sorgente creaz.#created_by_surname=Cognome Utente creaz.#created_by_name=Nome Utente creaz.#cf_bool_is_special=contrassegnati come speciali#cf_bool_is_selected=selezionati#organizzazione=ORGANIZZAZIONE#provincia=PROVINCIA#cognome=COGNOME#nome=NOME#codicefiscale=CODICE FISCALE#datadinascita=DATA DI NASCITA#mansione=MANSIONE#servizio=SERVIZIO#responsabile=RESP.#cellulare=CELLULARE#autista=AUTISTA#pranzo=PRANZO#cena=CENA#pernottamento=PERN.#beneficidilegge=BENEFICI DI LEGGE#numggbenlegge=NUM. GG. BEN. LEGGE#codiceorganizzazione=COD. ORGANIZZAZIONE#turno=TURNO#codicebadge=CODICE BADGE#codicevolontario=COD. VOLONTARIO#datainizioattestato=DATA INIZIO ATTEST.#datafineattestato=DATA FINE ATTEST.#dataoraregistrazione=DATA/ORA REG.#dataorauscitadefinitiva=DATA/ORA USCITA#note=NOTE#nomecampo=NOME CAMPO';

      $filter = '';

      if ($_CAMILA['user_visibility_type']=='personal')
          $filter= ' where created_by='.$_CAMILA['db']->qstr($_CAMILA['user']);
	  
	  if ($_CAMILA['user_visibility_type']=='group')
          $filter= ' where grp='.$_CAMILA['db']->qstr($_CAMILA['user_group']);

	  //if ($_CAMILA['adm_user_group'] == CAMILA_ADM_USER_GROUP)
	//	  $stmt = 'select ' . $admin_report_fields . ' from segreteriacampo_worktable18';
	  //else
		  $stmt = 'select ' . $report_fields . ' from segreteriacampo_worktable18';
      
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


	  $report->recordReadOnlyIfNotNullFields = Array('dataorauscitadefinitiva');

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