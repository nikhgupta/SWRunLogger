ready = ->
  $('#reports-comparison ul.nav a').click (e) ->
    e.preventDefault()
    $(@).tab 'show'

  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    window.location.hash = e.target.hash
    scrollTo 0, 0
    html = $(@).parent().remove()
    $("#reports-comparison ul.nav-tabs.tabs-left").prepend(html)

    $.fn.dataTable.tables(
      visible: true
      api: true
    ).columns.adjust()

  $('table.table').DataTable
    paging: false
    searching: false
    initComplete: ->
      $(".logtable").css("visibility", "visible")

  if window.location.hash? && $("#reports-comparison").length > 0
    hash = window.location.hash.substring(1)
    $("#reports-comparison ul.nav a[href='##{hash}']").tab 'show'

$(document).ready(ready)
$(document).on('page:load', ready)

