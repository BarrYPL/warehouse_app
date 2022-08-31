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
    })
  } else {
    eventCause.forEach(item => {
      item.disabled = true;
      if (item.type == "text"){
        item.value = '';
      }
    })
  }
}

function clearFilters(){
  document.querySelectorAll('legend input[type="checkbox"]').forEach(item => {
    item.checked = false;
    updatefilters(item);
  })
  _('asc-sort').checked = true;
}

function updateSorting(e){
  document.querySelectorAll('.sort-radio').forEach(item => {
    if(item.className != e.target.className) {
      item.checked = false;
    }
  })
}

function scrollUp(){
  document.getElementById('solid-results-div').scrollTo({top: 0, behavior: 'smooth'});
}

function scrollWe(){
  if (_('solid-results-div').scrollTop > 100) {
    _('arrow-up').style.display = "block";
  } else {
    _('arrow-up').style.display = "none";
  }
}

window.addEventListener("load", function(evt) {
  document.querySelectorAll('legend input').forEach(item => {
    item.addEventListener('change', listenCheckbox);
  })
  document.querySelectorAll('.sort-radio').forEach(item => {
    item.addEventListener('change', updateSorting);
  })
  const upButton = _('arrow-up');
  const resultsHeader = _('solid-results-div');
  upButton.addEventListener('click', scrollUp);
  resultsHeader.addEventListener('scroll', scrollWe);
  document.querySelector('#clear-filters').addEventListener('click', clearFilters);
})
