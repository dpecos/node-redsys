crypto = require 'crypto'

Utils = require './utils'

currency_mapping =
  'EUR': 978
  'USD': 840

language_mapping =
  'auto': 0
  'es': 1
  'en': 2

class Sermepa
  constructor: (@config = {}) ->
    @form_url = "https://sis.redsys.es/sis/realizarPago"
    @form_url = "https://sis-t.redsys.es:25443/sis/realizarPago" if @config.test

    @config.language = @convert_language(@config.language)

  build_payload: (data) ->
    str = "" +
      data.total +
      data.order +
      @config.merchant.code +
      data.currency

    str += data.transaction_type if typeof(data.transaction_type) != 'undefined'
    str += data.redirect_urls?.callback if data.redirect_urls?.callback

    str += @config.merchant.secret

    str

  sign: (data) =>
    shasum = crypto.createHash 'sha1'
    shasum.update @build_payload data
    shasum.digest 'hex'

  convert_currency: (currency) ->
    currency_mapping[currency] || "Unknown!"

  convert_language: (language) ->
    if typeof language_mapping[language] is 'undefined'
      "Unknown!"
    else
      language_mapping[language]

  normalize: (data) ->
    if Math.floor(data.total) isnt data.total
      data.total *= 100

    data.currency = @convert_currency(data.currency)

    normalize_data =
      total: data.total
      currency: data.currency
      order: Utils.format data.order, 4, 12
      description: Utils.format data.description, 125
      titular: Utils.format @config.merchant.titular, 60
      merchant_code: Utils.formatNumber @config.merchant.code, 9
      merchant_url: Utils.format data.redirect_urls?.callback, 250
      merchant_url_ok: Utils.format data.redirect_urls?.return_url, 250
      merchant_url_ko: Utils.format data.redirect_urls?.cancel_url, 250
      merchant_name: Utils.format @config.merchant.name, 25
      language: Utils.formatNumber @config.language, 3
      signature: Utils.format @sign(data), 40
      terminal: Utils.formatNumber @config.merchant.terminal, 3
      transaction_type: data.transaction_type
    normalize_data.authorization_code = Utils.formatNumber data.authorization_code, 6 if data.authorization_code
    normalize_data.data = Utils.format data.data, 1024 if data.data

    normalize_data


  create_payment: (order_data) =>
    sermepa_data = @normalize(order_data)

    form_data =
      URL: @form_url
      Ds_Merchant_Amount: sermepa_data.total
      Ds_Merchant_Currency: sermepa_data.currency
      Ds_Merchant_Order: sermepa_data.order
      Ds_Merchant_ProductDescription: sermepa_data.description
      Ds_Merchant_Titular: sermepa_data.titular
      Ds_Merchant_MerchantCode: sermepa_data.merchant_code
      Ds_Merchant_MerchantURL: sermepa_data.merchant_url
      Ds_Merchant_UrlOK: sermepa_data.merchant_url_ok
      Ds_Merchant_UrlKO: sermepa_data.merchant_url_ko
      Ds_Merchant_MerchantName: sermepa_data.merchant_name
      Ds_Merchant_ConsumerLanguage: sermepa_data.language
      Ds_Merchant_MerchantSignature: sermepa_data.signature
      Ds_Merchant_Terminal: sermepa_data.terminal
      Ds_Merchant_TransactionType: sermepa_data.transaction_type

    form_data.Ds_Merchant_AuthorisationCode = sermepa_data.authorization_code if sermepa_data.authorization_code
    form_data.Ds_Merchant_MerchantData = sermepa_data.data if sermepa_data.data

    form_data
    

module.exports =
  Sermepa: Sermepa
