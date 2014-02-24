Neighborly.Neighborly                               ?= {}
Neighborly.Neighborly.Balanced                      ?= {}
Neighborly.Neighborly.Balanced.Bankaccount          ?= {}
Neighborly.Neighborly.Balanced.Bankaccount.Payments ?= {}

Neighborly.Neighborly.Balanced.Bankaccount.Payments.New = Backbone.View.extend
  el: '.neighborly-balanced-bankaccount-form'

  initialize: ->
    _.bindAll(this, 'validate', 'submit')

    $.getScript 'https://js.balancedpayments.com/v1/balanced.js', ->
      balancedMarketplaceID = $('[data-balanced-bankaccount-form]').attr('data-balanced-marketplace-id')
      balanced.init("/v1/marketplaces/#{balancedMarketplaceID}")

    this.$button = this.$('input[type=submit]')
    this.$form = this.$('form')
    this.$form.bind('submit', this.submit)

  validate: =>

  submit: (event) =>
    event.preventDefault()
