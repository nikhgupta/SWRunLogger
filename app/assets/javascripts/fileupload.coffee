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

      @on 'addedfile', (file) =>
        getIcon(file, @files[@files.length - 1].previewElement)
        $('.alert').slideUp('fast')
      @on 'success', (file, message) =>
        $('.container-fluid').prepend(html) if $(".alert").length < 1
        $('.alert').removeClass('alert-danger').addClass('alert-success')
        $('.alert').html(button + "File Imported Successfully!")
        $('.alert').show('slow')
        # $("#log-table").dataTable().api().ajax.reload()
        # setTimeout (-> $('.alert').slideUp (-> $('.dropzone').hide())), 5000
        window.location = '/logs'
      @on 'error', (file, message) ->
        $('.container-fluid').prepend(html) if $(".alert").length < 1
        $('.alert').removeClass('alert-success').addClass('alert-danger')
        $('.alert').html(button + "File could not be imported!")
        $('.alert').show('slow')
        window.location = '/users/sign_in' if file.xhr.status is 401

$(document).ready(ready)
$(document).on('page:load', ready)
