class Dashing.CiBlame extends Dashing.Widget
  constructor: ->
    super

  onData: (data)->
    @updateStatus(data.status, @node)

  ready: (node)->
    status = $(node).find('.status').text()
    @updateStatus(status, node)

  updateStatus: (status, node)->
    if status != 'Passing'
      $(node).removeClass('green').addClass('red')
    else
      $(node).removeClass('red').addClass('green')
