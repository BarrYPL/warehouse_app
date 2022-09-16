function start_edit(e){
  let textTarget = document.querySelector('.' + e.target.id);
  let tagName = textTarget.tagName;
  let innerText;
  switch(tagName) {
    case "A":
      innerText = textTarget.href;
      break;
    case "P":
      innerText = textTarget.innerHTML;
      break;
    default:
    console.log(tagName);
  }
  console.log(textTarget);
  textTarget.remove();
  //https://www.javascripttutorial.net/dom/manipulating/replace-a-dom-element/
}

window.addEventListener("load", function(evt) {
  document.querySelectorAll('legend i').forEach(item => {
    item.addEventListener('click', start_edit);
  })
})
