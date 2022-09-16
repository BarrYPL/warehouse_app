function start_edit(e){
  let textTarget = document.querySelector('.' + e.target.id);
  let tagName = textTarget.tagName;
  let innerText;
  let inputName;
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
    console.log(tagName);
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
  })
})
