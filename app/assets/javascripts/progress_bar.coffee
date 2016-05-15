class @ProgressBar
  constructor: (element) -> @bar = $(element)
  bar: @bar
  currentProgress: -> @bar.attr("aria-valuenow") * 1
  increment: (amount = 1) -> @setProgress(@currentProgress() + amount)
  hasStarted: -> @currentProgress() > 0
  isComplete: -> @currentProgress() == 100
  isIncomplete: -> @currentProgress() < 100
  setProgress: (amount) ->
    @bar.width("#{amount}%").attr("aria-valuenow", amount)
    @bar.html("#{amount}%") unless @bar.html() is ""
  markCompleted: ->
    @setProgress(100)
    @bar.removeClass('active')
  markFailed: ->
    @setProgress(100)
    @bar.removeClass('progress-bar-info progress-bar-success progress-bar-warning')
    @bar.addClass('progress-bar-danger')

