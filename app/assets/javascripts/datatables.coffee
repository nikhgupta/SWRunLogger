#= require moment
#= require dataTables/jquery.dataTables
#= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
#= require datetime-moment
#= require_self
#= require logs/index
#= require reports/comparison

String::toHHMMSS = ->
  sec_num = parseInt(this, 10)
  hours = Math.floor(sec_num / 3600)
  minutes = Math.floor((sec_num - (hours * 3600)) / 60)
  seconds = sec_num - (hours * 3600) - (minutes * 60)
  hours = '0' + hours if hours < 10
  minutes = '0' + minutes if minutes < 10
  seconds = '0' + seconds if seconds < 10
  hours + ':' + minutes + ':' + seconds

String::durationToSeconds = ->
  a = this.split(":")
  if !!a then (+a[0]) * 3600 + (+a[1]) * 60 + (+a[2]) else 0

ready = ->
  $.fn.dataTable.moment('HH:mm MMM D, YYYY')

$(document).ready(ready)
$(document).on('page:load', ready)
