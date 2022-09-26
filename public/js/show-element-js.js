"use strict;"

function show_adding_div(){
  var div = document.querySelector('.adding-item-form');
  div.style.zIndex = 0;
  div.style.transform = "translateY(40px)";
}

function start_edit(e){
  let textTarget = document.querySelector('.' + e.target.id);
  let innerText;
  let inputName;
  let bypass = false;
  if(!textTarget){
    textTarget = _('anchor-holder');
    bypass = true;
  }
  let tagName = textTarget.tagName;
  switch(tagName) {
    case "A":
      innerText = textTarget.href;
      inputName = textTarget.className + "-input";
      textTarget = _('anchor-holder');
      break;
    case "P":
      innerText = textTarget.innerHTML;
      inputName = textTarget.className + "-input";
      break;
    default:
  }
  if(bypass){
    innerText = "";
    inputName = "datasheet-input";
  }
  const inputText = document.createElement('input');
  inputText.innerHTML = "";
  inputText.value = innerText;
  inputText.setAttribute('class', "created-input");
  inputText.setAttribute('name', inputName);
  textTarget.parentNode.replaceChild(inputText, textTarget);
}

function open_editor(){
  console.log("im clicked");
  document.querySelectorAll('legend i').forEach(item => {
    item.addEventListener('click', start_edit);
  });
  document.querySelectorAll('th i').forEach(item => {
    item.addEventListener('click', start_edit);
  });
}

window.addEventListener("load", function(evt){
  var btn = document.querySelector('.add-item-btn');
  if (btn) { btn.addEventListener('click', show_adding_div); }
  const editElements = ["nazwa","ilosc","lokalizacja","opis","link"];
  editElements.forEach(item => {
    console.log(_(item));
  });
})
