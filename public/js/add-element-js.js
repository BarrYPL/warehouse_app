"use strict;"

let errorVar = 0;

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
  const errorDiv = document.getElementsByClassName("js-error-div")[0];
  let p = document.createElement("p");
  p.innerHTML = "Nazwa nie może być dłuższa niż 30 znaków!";
  p.id = "errortext";
  if (nameInput.value.length > 30) {
    nameInput.style.background = "#fa0200";
    nameInput.style.color = "#f1f1f1";
    if (errorVar < 1)
    {
      _('js-error-div').style.backgroundColor = "rgb(12,12,12,0.8)";
      errorDiv.append(p);
    }
    errorVar++;
    if (errorVar > 20)
    {
      _('errortext').innerHTML = "Jebany downie!";
      _('js-error-div').style.fontSize = "xxx-large";
      _('js-error-div').style.height = "70px";
    }
  } else {
    errorVar = 0;
    _('js-error-div').textContent = '';
    _('js-error-div').style.fontSize = "x-large";
    _('js-error-div').style.height = "50px";
    _('js-error-div').style.backgroundColor = "transparent";
    nameInput.style.background = "#f1f1f1";
    nameInput.style.color = "#f20200";
  }
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
