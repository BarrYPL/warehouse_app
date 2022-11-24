"use strict";

function _(el){
 return document.getElementById(el);
}

function deleteItems(){
  let chBxArray = []
  let checkBoxes = document.querySelectorAll('td input');
  checkBoxes.forEach(item => {
    if(item.checked == true){
      chBxArray.push(item.value);
    }
  })
  if(window.confirm("Na pewno chcesz usunąć zaznaczone elementy?")){
    var form = $('<form action="/multiple_delete" method="post">' +
    '<input type="text" name="items_to_delete" value="' +chBxArray + '" />' + '</form>');
    $('body').append(form);
    form.submit();
  }
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
  const deleteBtn = _('delete-button');
  const clearFilterBtn = document.querySelector('#clear-filters');
  if (upButton){
    upButton.addEventListener('click', scrollUp);
  }
  if (clearFilterBtn){
    clearFilterBtn.addEventListener('click', clearFilters);
  }
  if (deleteBtn){
    deleteBtn.addEventListener('click', deleteItems);
  }
  resultsHeader.addEventListener('scroll', scrollWe);
})
