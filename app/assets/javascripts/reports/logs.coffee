#= require components/datatables

ready = ->
  $('#reports-logs-table').DataTable
    deferRender:    true
    order:          [[1, 'desc']]
    ajax:
      url: $("#reports-logs-table").data("source"),
      dataSrc: ""
      cache: false
    initComplete: ->
      $(".logtable").css("visibility", "visible")
      @api().columns().every ->
        [column, header] = [@, $(@.header())]
        footer = $(column.footer()).empty()
        if header.hasClass('string')
          node = $('<select><option value=""></option></select>')
          select = node.appendTo(footer).on('change', ->
            val = $.fn.dataTable.util.escapeRegex($(this).val())
            column.search((if val then '^' + val + '$' else ''), true, false).draw()
          )
          column.data().unique().sort().each (d, j) ->
            select.append '<option value="' + d + '">' + d + '</option>'

    footerCallback: (tfoot, data, start, end, display) ->
      api = @api()

      api.columns().every ->
        [column, index, header] = [@, @[0][0], $(@.header())]

        data = api.column(index, filter: 'applied').data()
        totals = $(column.footer()).parents('tfoot').find("tr.totals th:eq(#{index})")
        averages = $(column.footer()).parents('tfoot').find("tr.averages th:eq(#{index})")

        sum = avg = "-"

        if header.hasClass('numeric')
          sum = data.reduce (a,b) ->
            a = parseFloat((if !!a then a else 0).toString().replace(",", ''))
            b = parseFloat((if !!b then b else 0).toString().replace(",", ''))
            a + b
          , 0
          avg = parseFloat((sum / data.length).toFixed(2))
          avg = if sum > 0 then avg else 0
        else if header.hasClass('duration')
          sum = data.reduce (a,b) ->
            a = a.durationToSeconds() unless jQuery.isNumeric(a)
            a + b.durationToSeconds()
          , "00:00:00"
          avg = parseFloat((sum / data.length).toFixed(2)).toString().toHHMMSS()
          avg = if sum > 0 then avg else "00:00:00"
          sum = sum.toString().toHHMMSS()

        [sum, avg] = [ "-", "#{avg} %" ] if header.hasClass('percentage')
        [sum, avg] = [ "Totals", "Averages" ] if header.hasClass('primary')
        [sum, avg] = [ "#{data.length} Runs", "" ] if header.hasClass('counter')

        # console.log "Sum for #{header.text()}: #{sum}"
        # console.log "Avg for #{header.text()}: #{avg}"

        totals.html(sum) and averages.html(avg)

$(document).ready(ready)
$(document).on('page:load', ready)
