"use strict;"

function _(el){
 return document.getElementById(el);
}

function unlock_table_options(){
  document.querySelectorAll('.radio-table-filter input').forEach(elem =>{
    elem.disabled = false;
  })
}

function change_input_table_status(){
  if (_('new-table').checked){
      _('input-table-name').disabled = false;
  } else {
    _('input-table-name').disabled = true;
  }
}

function change_input_id_status(){
  if (_('localid-checkbox').checked){
      _('localid-input').disabled = true;
  } else {
    _('localid-input').disabled = false;
  }
}

window.addEventListener("load", function(evt){
  unlock_table_options();
  document.querySelectorAll('.radio-table-filter').forEach(elem => {
    elem.addEventListener("change", change_input_table_status);
  })
  document.querySelector('#localid-checkbox').addEventListener("change", change_input_id_status);
})
