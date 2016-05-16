class @StatusPoller
  constructor: (@options = {}) ->
    @timer = null
    @url   = "/monitor/status.json"

  getJobStatus: (job_id, callback = null) ->

    @timer = setInterval (=>
      @getJobStatus(job_id, callback) if job_id?
    ), 1000 unless @timer?

    $.post @url, { job_id: job_id }, (response) =>
      result = false
      status = if response.status? then response.status else "Expired"

      @options["on#{response.status}"](response) if @options["on#{response.status}"]?
      callback(response) if callback?

      clearInterval(@timer) unless response.status in ["Queued", "Working"]
