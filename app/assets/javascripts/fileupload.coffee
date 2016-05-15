#= require dropzone
#= require status_poller
#= require progress_bar

ready = ->
  Dropzone.autoDiscover = false

  getIcon = (file, elem) ->
    ext = file.name.split(".")
    ext = ext[ext.length - 1]
    ext = if ext is "json" then "js" else ext
    icon = "https://cdn3.iconfinder.com/data/icons/lexter-flat-colorfull-file-formats/56/#{ext}-128.png"
    fall = "https://cdn3.iconfinder.com/data/icons/lexter-flat-colorfull-file-formats/56/blank-128.png"
    $.get(icon).done(->
      $(elem).find('img').attr('src', icon)
    ).fail(->
      $(elem).find('img').attr('src', fall)
    )

  $(".continue-import").on 'click', -> window.location = "/logs"

  $("#import-dropzone").dropzone
    # restrict image size to a maximum 1MB
    maxFilesize: 20
    # changed the passed param to one accepted by our rails app
    paramName: "file"
    # show remove links on each image upload
    addRemoveLinks: false

    init: ->
      queueBar     = new ProgressBar("#progress-queue")
      parseBar     = new ProgressBar("#progress-parse")
      uploadBar    = new ProgressBar("#progress-upload")
      migrationBar = new ProgressBar("#progress-migration")
      bars = [queueBar, parseBar, uploadBar, migrationBar]

      modalEl = $(".modal.imports-progress")

      html = "<div class='alert alert-dismissable hidden' role='alert'></div>"
      button = "<button type='button' class='close' data-dismiss='alert'><span aria-hidden='true'>×</span><span class='sr-only'>Close</span></button>"

      message  = "Drop CSV file containing your run logs here! "
      message += "Or, click to browse for your file here!<br/>"
      message += "Feel free to upload the same file multiple times! "
      message += "We won't import already imported logs!<br/>"
      message += "The file you need to upload will be named as: "
      message += "<strong>&lt;your_sw_user_id&gt;-runs.csv</strong>"

      $(".dz-default.dz-message span").html message
      $('.container-fluid').prepend(html) if $(".alert").length < 1

      @on 'addedfile', (file) =>
        modalEl.modal backdrop: 'static', keyboard: false

      @on 'success', (file, message) =>
        new StatusPoller().getJobStatus message.job_id, (response) ->
          if response.percent?
            migrationBar.bar.html("0%") if migrationBar.bar.html() is ""
            migrationBar.setProgress(response.percent)

          if response.status is "Queued"
            queueBar.increment()
          else if response.status is "Working"
            queueBar.markCompleted()
            parseBar.increment()
          else if response.status is "Complete"
            [bar.markCompleted() for bar in [queueBar, parseBar, migrationBar]]
            message  = "Imported #{response.saved} runs from a total of #{response.total} runs in the uploaded file.<br/>"
            message += "#{response.existing} runs were skipped, as they were already present in our database.<br/>" if response.existing * 1 > 0
            message += "#{response.faulty} runs were skipped, as they had inconsistent/wrong/unparseable data!" if response.faulty * 1 > 0
            $(".modal-title").html("Import Successful!")
            $(".title-migration").append("<p>#{message}</p>")
            $(".continue-import").removeClass('hidden')
          else if response.status is "Failed"
            [bar.markFailed() for bar in [queueBar, parseBar, uploadBar, migrationBar]]
            modalEl.find(".modal-title").html("Import Failed - #{response.error}")
            $(".error-description").removeClass('hidden')

          if response.upload_job_id? and !uploadBar.hasStarted() and uploadBar.isIncomplete()
            new StatusPoller().getJobStatus response.upload_job_id, (response) ->
              uploadBar.setProgress(20)  if response.status is "Queued"
              uploadBar.setProgress(50) if response.status is "Working" and uploadBar.currentProgress() < 50
              uploadBar.increment() if uploadBar.currentProgress() > 50
              uploadBar.markCompleted() if response.status is "Complete"
              uploadBar.markFailed() if response.status is "Failed"

              html = " <strong><a href='#{response.github_url}' target=\'_blank\''>View</a></strong>"
              $(".title-upload p").append(html) if response.github_url?


      @on 'error', (file, message) ->
        window.location = '/users/sign_in' if file.xhr.status is 401

        [bar.markFailed() for bar in [queueBar, parseBar, uploadBar, migrationBar]]
        modalEl.find(".modal-title").html("Import Failed - File could not be uploaded!")
        $(".error-description").removeClass('hidden')

$(document).ready(ready)
$(document).on('page:load', ready)
