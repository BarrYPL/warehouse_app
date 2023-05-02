"use strict;"

var editIcon = true;

function show_adding_div(){
  var div = document.querySelector('.adding-item-form');
  div.style.zIndex = 0;
  div.style.transform = "translateY(40px)";
}

function start_edit(e){
  let textTarget = document.querySelector('.' + e.target.id);
  let innerText;
  let inputName;
  if (textTarget == _('anchor-holder'))
  {
    textTarget = _('old-link');
    if (textTarget){
      innerText = textTarget.href;
    } else {
      innerText = "";
      textTarget = _('anchor-holder');
    }
    inputName = "datasheet-input";
  } else {
    if (textTarget) {
    inputName = textTarget.className + "-input";
    innerText = textTarget.innerHTML;
    }
  }
  if (textTarget){
    const inputText = document.createElement('input');
    inputText.innerHTML = "";
    inputText.value = innerText;
    inputText.setAttribute('class', "created-input");
    inputText.setAttribute('name', inputName);
    textTarget.parentNode.replaceChild(inputText, textTarget);
  }
}

function get_id_name(element){
  let retId;

  const map = {
    'nazwa' : 'name',
    'ilosc' : 'quantity',
    'lokalizacja' : 'location',
    'opis' : 'description',
    'nota' : 'datasheet',
    'wartosc' : 'value'
  };

  retId = map[element] ?? 'error';
  return retId;
}

function open_editor(){
  if (editIcon){
    let innerText = "";
    let domElem;
    const editElements = ["nazwa","ilosc","lokalizacja","opis","nota","wartosc"];
    editElements.forEach(item => {
      domElem = _(item);
      innerText = domElem.innerHTML + " <i class=\"fa-solid fa-pen-to-square\" id=\""+get_id_name(item)+"\"></i>"
      domElem.innerHTML = innerText;
    });
    document.querySelectorAll('legend i').forEach(item => {
      item.addEventListener('click', start_edit);
    });
    document.querySelectorAll('th i').forEach(item => {
      item.addEventListener('click', start_edit);
    });
    document.querySelector('.additional-tab').style.display = 'block';
  }
  editIcon = false;
}

function block_deleting(e){
  var delLink = document.getElementById('del-button');
  e.preventDefault();
  if (e.target.id === delLink.id) {
    if(window.confirm("Na pewno chcesz usunąć element?")){
      window.location = e.currentTarget.href;
    }
  }
}

window.addEventListener("load", function(evt){
  var delLink = _('del-button');
  if (delLink) { delLink.addEventListener('click', block_deleting); }
})
