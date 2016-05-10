ready = ->
  $('#compare-tables ul.nav a').click (e) ->
    e.preventDefault()
    $(@).tab 'show'

  $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    $.fn.dataTable.tables(
      visible: true
      api: true
    ).columns.adjust()

  $('table.table').DataTable
    paging: false
    searching: false
    initComplete: ->
      $(".logtable").css("visibility", "visible")

$(document).ready(ready)
$(document).on('page:load', ready)

