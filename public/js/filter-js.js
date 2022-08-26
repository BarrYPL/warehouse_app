"use strict";

function _(el){
 return document.getElementById(el);
}

function loadFilters(){
  let filtersDiv = _('filters-div');
  const filtersButton = $('.filter-button');
  filtersDiv.style.display = 'block';
  filtersButton.attr('onclick', 'hideFilters()');
}

function hideFilters(){
  let filtersDiv = _('filters-div');
  const filtersButton = $('.filter-button');
  filtersDiv.style.display = 'none';
  filtersButton.attr('onclick', 'loadFilters()');
}

function listenCheckbox(e){
  updatefilters(e.target);
}

function updatefilters(e){
  let eventCause = document.querySelectorAll('.' + e.className + ' input');
  if(e.checked){
    eventCause.forEach(item => {
      item.disabled = false;
      if (item.value == "others"){
        item.disabled = true;
      }
    })
  } else {
    eventCause.forEach(item => {
      item.disabled = true;
      if (item.type == "text"){
        item.value = '';
      }
      if (item.value == "others"){
        item.disabled = true;
      }
    })
  }
}

function clearFilters(){
  document.querySelectorAll('legend input[type="checkbox"]').forEach(item => {
    item.checked = false;
    updatefilters(item);
  })
}

window.addEventListener("load", function(evt) {
  document.querySelectorAll('legend input').forEach(item => {
    item.addEventListener('change', listenCheckbox);
  })
  document.querySelector('#clear-filters').addEventListener('click', clearFilters);
})
