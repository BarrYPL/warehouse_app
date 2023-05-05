"use strict;"

var divUp = false;

function isEmpty(obj) {
    return Object.keys(obj).length === 0;
}

function _(el){
 return document.getElementById(el);
}

function block_deleting(e){
  e.preventDefault();
  if(window.confirm("Na pewno chcesz usunąć element?")){
    window.location = e.currentTarget.href;
  }
}

function blur_background(value){
  var innerDiv = document.querySelector(".inner-width");
  innerDiv.style.filter = "blur(" + value + "px)";
}

function spawnDiv(value, infoJSON){
  const modalDiv = _("modal-div");
  //console.log(infoJSON.name);
  if(value){
    modalDiv.style.display = "flex";
    _('modal-div-title').innerHTML = infoJSON.name;
    _('modal-div-name').value = infoJSON.name;
    _('modal-div-description').value = infoJSON.description;
    _('modal-div-id').value = infoJSON.id;
  } else {
    modalDiv.style.display = "none";
  }
}

function edit_loc(name){
  const xhr = new XMLHttpRequest();
  xhr.onreadystatechange = function() {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      const responseObj = JSON.parse(xhr.responseText);
      //console.log(responseObj);
      spawnDiv(true, responseObj);
      blur_background(5);
      divUp = true;
    }
  }
  xhr.addEventListener('error', (event) => {
    alert('Oops! Something went wrong.');
  });
  if(!isEmpty(name)){
    xhr.open("GET", "/api/locations/" + name, true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send();
  }
}

window.addEventListener("load", function(evt){
  document.querySelectorAll('#del-button').forEach(item => {
    item.addEventListener('click', block_deleting);
  })

  document.onclick = function(e){
    const modalDiv = _("modal-div");
    if(divUp){
      if (!((e.target.id == 'modal-div') || (e.target.id == 'modal-div-name')
    || (e.target.id == 'modal-div-parentname') || (e.target.id == 'modal-div-description')
    || (e.target.id == 'modal-div-title') || (e.target.className == 'modal-inner-div')
    || (e.target.className == 'modal-form'))){
        console.log(e.target);
        spawnDiv(false, {});
        blur_background(0);
        divUp = false;
      }
    }
  }
})
