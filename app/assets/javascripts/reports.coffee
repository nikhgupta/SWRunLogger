#= require progress_bar

ready = ->
  loading = $("#reports-loading")
  reports = $(".reports-area")
  return unless loading.length > 0

  loadBar = new ProgressBar("#reports-loading .progress-bar")
  job_id  = loading.data("job-id")

  if reports.length > 0
    loading.addClass 'hidden'
    reports.removeClass 'hidden'
  else
    new StatusPoller().getJobStatus job_id, (response) ->
      if response.status is "Queued"
        loadBar.increment()
        loadBar.addClass("progress-bar-info")
      else if response.status is "Working"
        loadBar.increment(2)
        loadBar.bar.removeClass('progress-bar-info').addClass('progress-bar-warning')
      else if response.status is "Complete"
        loadBar.markCompleted()
        loadBar.bar.removeClass('progress-bar-warning').addClass('progress-bar-success')
        setTimeout (-> location.reload()), 400

$(document).ready(ready)
$(document).on('page:load', ready)
