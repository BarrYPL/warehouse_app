"use strict";
function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

function _(el){
 return document.getElementById(el);
}

function updateInput(e){
  let input_data = e.target.innerHTML;
  let input = _('search-input');
  if (Object.keys(input_data).length === 0)
  {
    input_data = e.target.alt;
  }
  input.value = input_data;
  updateSearchingSuggestions([]);
}

function updateSearchingSuggestions(tab){
  let res = _('result-div');
  let list = '';
  res.innerHTML = '';
  for (var i=0; i<tab.length; i++) {
    list += '<li class="searching-suggestion">' + tab[i] + '</li>';
  }
  res.innerHTML = '<ul>' + list + '</ul>';
  suggestionsDivAppear(true);
  if(isEmpty(tab)){
    suggestionsDivAppear(false);
  }
  //Adding class event listener
  document.querySelectorAll('.searching-suggestion').forEach(item => {
    item.addEventListener('click', updateInput);
  })
}

function updateValue(e) {
  let post_data = e.target.value;
  const xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      const obj = JSON.parse(xhr.responseText);
      let terms = [];
      obj.forEach(obj => {
          Object.entries(obj).forEach(([key, value]) => {
            terms.push(value);
          });
        });
        updateSearchingSuggestions(terms);
    }
  }
  xhr.addEventListener('error', (event) => {
    alert('Oops! Something went wrong.');
  });
  if(!isEmpty(post_data)){
    xhr.open("POST", "/quick-find", true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send("phrase="+post_data);
  } else {
    updateSearchingSuggestions([]);
  }
}

function suggestionsDivAppear(x){
  let res = _('result-div');
  let inp = _('search-input');
  if (x === true){
    res.style.display = 'block';
    inp.style.borderRadius = "0px 10px 0px 0px";
  } else {
    res.style.display = 'none';
    inp.style.borderRadius = "0px 10px 10px 0px";
  }
}

function hideMenu(){
  const menuButton = $('#menu-icon');
  _('menu-div').style.transform = 'rotate(0deg)';
  _('pedoEasterEgg').style.transform = 'rotate(0deg)';
  menuButton.attr('onclick', 'showMenu()');
}

window.addEventListener("load", function(evt) {
  const input = _('search-input');
  input.addEventListener('input', updateValue);
  document.onclick = function(e){
    if (e.target.id != 'search-input'){
      suggestionsDivAppear(false);
    }
    if (!((e.target.id == 'menu-icon') || (e.target.className == 'menu-block'))){
      hideMenu();
    }
  }
})
