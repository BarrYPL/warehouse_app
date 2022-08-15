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
  res.style.display = 'block';
  if(isEmpty(tab)){
    res.style.display = 'none';
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
    xhr.open("POST", "/find", true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send("phrase="+post_data);
  } else {
    updateSearchingSuggestions([]);
  }
}

window.onload = function () {
  const input = _('search-input');
  input.addEventListener('input', updateValue);
}
