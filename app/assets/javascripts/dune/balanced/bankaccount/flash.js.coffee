Dune.Dune                               ?= {}
Dune.Dune.Balanced                      ?= {}
Dune.Dune.Balanced.Bankaccount          ?= {}

Dune.Dune.Balanced.Bankaccount.Flash =
  message: (text)->
    this.remove()
    alertBox         = $('<div>', { 'class': 'alert-box error text-center', 'html':
                         $('<h5>', { 'html': text })
                       } )
    errorBoxWrapper  = $('<div>', { 'class': 'error-box large-12 columns hide', 'html': alertBox}).insertBefore('.dune-balanced-bankaccount-form .submit')
    errorBoxWrapper.fadeIn(300)

  remove: ->
    $('.error-box').remove()

