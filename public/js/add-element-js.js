"use strict;"

function _(el){
 return document.getElementById(el);
}

function unlock_type_options(){
  document.querySelectorAll('.radio-type-filter input').forEach(elem =>{
    elem.disabled = false;
  })
}

function change_input_type_status(e){
  document.querySelectorAll('.radio-type-filter input').forEach(elem => {
    if (elem.value != e.target.value){
      elem.checked = false;
    }
    if (e.target.value == 'create-type'){
      _('input-type-name').disabled = false;
      _('input-type-name').style.cursor = "auto";
    } else {
      _('input-type-name').disabled = true;
      _('input-type-name').value = '';
      _('input-type-name').style.cursor = "not-allowed";
    }
  })
}

function change_input_id_status(){
  if (_('localid-checkbox').checked){
      _('localid-input').disabled = true;
      _('localid-input').style.cursor = "not-allowed";
      _('localid-input').value = '';
  } else {
    _('localid-input').disabled = false;
    _('localid-input').style.cursor = "auto";
  }
}

function change_input_unit_status(){
  if (_('unit-checkbox').checked){
      _('unit-input').disabled = true;
      _('unit-input').style.cursor = "not-allowed";
      _('unit-input').value = '';
  } else {
    _('unit-input').disabled = false;
    _('unit-input').style.cursor = "auto";
  }
}

function change_new_input_name(){
  const nameInput = document.getElementsByName("new-item-name")[0];
  if (nameInput.value.length > 30) {
    nameInput.style.background = "#fa0200";
    nameInput.style.color = "#f1f1f1";
  } else {
    nameInput.style.background = "#f1f1f1";
    nameInput.style.color = "#f20200";
  }
//Need to add append error div
}

window.addEventListener("load", function(evt){
  unlock_type_options();
  document.querySelectorAll('.radio-type-filter').forEach(elem => {
    elem.addEventListener("change", change_input_type_status);
  })
  document.querySelector('[name="new-item-name"]').addEventListener("input", change_new_input_name);
  document.querySelector('#localid-checkbox').addEventListener("change", change_input_id_status);
  document.querySelector('#unit-checkbox').addEventListener("change", change_input_unit_status);
})
