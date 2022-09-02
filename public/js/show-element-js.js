"use strict;"

function _(el){
 return document.getElementById(el);
}

function show_adding_div(){
  console.log("Im called");
  var div = document.querySelector('.item-form');
  div.style.zIndex = 0;
  div.style.transform = "translateY(40px)";
}

window.addEventListener("load", function(evt){
  var btn = document.querySelector('.add-item-btn')
  if (btn) { btn.addEventListener('click', show_adding_div); }
})
