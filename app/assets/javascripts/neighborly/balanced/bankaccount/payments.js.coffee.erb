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
    this.$('#payment_routing_number').bind('blur', this.showBankName)

  validate: =>

  submit: (event) =>
    event.preventDefault()

  showBankName: (e)=>
    number = $.trim(this.$('#payment_routing_number').val())
    if number.length is 9
      $.getJSON $('[data-routing-number-path]').data('routing-number-path').replace('id', number), (response) =>
        if response.ok
          this.$('#payment_bank_name').val($.trim(response.bank_name))
          return true
        else
          this.$('#payment_bank_name').val('')
    else
      this.$('#payment_bank_name').val('')
