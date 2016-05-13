#= require dropzone

ready = ->
  Dropzone.autoDiscover = false

  html = "<div class='alert alert-dismissable' role='alert'></div>"
  button = "<button type='button' class='close' data-dismiss='alert'><span aria-hidden='true'>×</span><span class='sr-only'>Close</span></button>"

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

  $("#import-dropzone").dropzone
    # restrict image size to a maximum 1MB
    maxFilesize: 20
    # changed the passed param to one accepted by our rails app
    paramName: "file"
    # show remove links on each image upload
    addRemoveLinks: false

    init: ->
      message  = "Drop CSV file containing your run logs here!<br/>"
      message += "Or, click to browse for your file here!<br/><br/>"
      message += "Feel free to upload the same file multiple times!<br/>"
      message += "We won't import already imported logs!<br/><br/>"
      message += "The file you need to upload will be named as:<br/>"
      message += "<strong>&lt;your_sw_user_id&gt;-runs.csv</strong>"
      $(".dz-default.dz-message span").html message
      $('.container-fluid').prepend(html) if $(".alert").length < 1

      @on 'addedfile', (file) =>
        getIcon(file, @files[@files.length - 1].previewElement)
        $('.alert').removeClass('alert-danger alert-success').addClass('alert-warning')
        $('.alert').html(button + "Importing runs...")

      @on 'success', (file, message) =>
        html  = button + "#{message.total} Runs Imported Successfully!<br/>"
        html += "#{message.saved} saved, while #{message.existing} runs were already imported."
        html += " Failed to import #{message.faulty} runs!<br/>"
        html += "Redirecting you to view logs in about 5 seconds!"

        $('.alert').removeClass('alert-danger alert-warning').addClass('alert-success')
        $('.alert').html(html).show('slow')
        # setTimeout (-> window.location = '/logs'), 5000

      @on 'error', (file, message) ->
        html  = button + "File could not be imported!<br/>"
        html += "Are you sure this is a valid CSV exported by SWProxy RunLogger?<br/>"
        html += "Error encountered: #{message.error}"

        $('.alert').removeClass('alert-success alert-warning').addClass('alert-danger')
        $('.alert').html(html).show('slow')
        window.location = '/users/sign_in' if file.xhr.status is 401

$(document).ready(ready)
$(document).on('page:load', ready)
