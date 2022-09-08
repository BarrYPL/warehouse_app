"use strict;"

function _(el){
 return document.getElementById(el);
}

function unlock_table_options(){
  document.querySelectorAll('.radio-table-filter input').forEach(elem =>{
    elem.disabled = false;
  })
}

function change_input_table_status(e){
  document.querySelectorAll('.radio-table-filter input').forEach(elem => {
    if (elem.value != e.target.value){
      elem.checked = false;
    }
    if (e.target.value == 'create-table'){
      _('input-table-name').disabled = false;
      _('input-table-name').style.cursor = "auto";
    } else {
      _('input-table-name').disabled = true;
      _('input-table-name').value = '';
      _('input-table-name').style.cursor = "not-allowed";
    }
  })
}

function change_input_id_status(){
  if (_('localid-checkbox').checked){
      _('localid-input').disabled = true;
      _('localid-input').style.cursor = "not-allowed";
  } else {
    _('localid-input').disabled = false;
    _('localid-input').value = '';
    _('localid-input').style.cursor = "auto";
  }
}

window.addEventListener("load", function(evt){
  unlock_table_options();
  document.querySelectorAll('.radio-table-filter').forEach(elem => {
    elem.addEventListener("change", change_input_table_status);
  })
  document.querySelector('#localid-checkbox').addEventListener("change", change_input_id_status);
})
