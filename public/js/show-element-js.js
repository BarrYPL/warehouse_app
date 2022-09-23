"use strict;"

function show_adding_div(){
  var div = document.querySelector('.item-form');
  div.style.zIndex = 0;
  div.style.transform = "translateY(40px)";
}

window.addEventListener("load", function(evt){
  var btn = document.querySelector('.add-item-btn');
  if (btn) { btn.addEventListener('click', show_adding_div); }
  const editElements = ["nazwa","ilosc","lokalizacja"];
  editElements.forEach(item => {
    console.log(_(item));
  });
})
