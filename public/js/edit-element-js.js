"use-strict;"

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

window.addEventListener("load", function(evt) {
  document.querySelectorAll('legend i').forEach(item => {
    item.addEventListener('click', start_edit);
  });
  document.querySelectorAll('th i').forEach(item => {
    item.addEventListener('click', start_edit);
  });
})
