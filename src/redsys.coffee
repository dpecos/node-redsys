crypto = require 'crypto'
_ = require 'lodash'

Utils = require './utils'

currency_mapping =
  'EUR': 978
  'USD': 840

language_mapping =
  'auto': 0
  'es': 1
  'en': 2

class Redsys
  @TransactionTypes:
    STANDAR_PAYMENT: '0'
    CARD_IN_ARCHIVE_INITIAL: 'L'
    CARD_IN_ARCHIVE: 'M'

  constructor: (@config = {}) ->
    @form_url = "https://sis.redsys.es/sis/"
    @form_url = "https://sis-t.redsys.es:25443/sis/" if @config.test

    @config.language = @convert_language(@config.language)

  build_payload: (data) ->
    str = "" +
      data.total +
      data.order +
      @config.merchant.code +
      data.currency

    if data.transaction_type != Redsys.TransactionTypes.STANDAR_PAYMENT
      str += data.transaction_type if typeof(data.transaction_type) != 'undefined'

    str += data.redirect_urls?.callback if data.redirect_urls?.callback
    str += @config.merchant.secret

    str

  build_response_payload: (data) ->
    str = "" +
      data.Ds_Amount +
      data.Ds_Order +
      data.Ds_MerchantCode +
      data.Ds_Currency +
      data.Ds_Response +
      @config.merchant.secret

    str

  sign: (data) =>
    shasum = crypto.createHash 'sha1'
    shasum.update data
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
      description: Utils.format data.description, 125
      titular: Utils.format @config.merchant.titular, 60
      merchant_code: Utils.formatNumber @config.merchant.code, 9
      merchant_url: Utils.format data.redirect_urls?.callback, 250
      merchant_url_ok: Utils.format data.redirect_urls?.return_url, 250
      merchant_url_ko: Utils.format data.redirect_urls?.cancel_url, 250
      merchant_name: Utils.format @config.merchant.name, 25
      language: Utils.formatNumber @config.language, 3
      signature: Utils.format @sign(@build_payload data), 40
      terminal: Utils.formatNumber @config.merchant.terminal, 3
      transaction_type: data.transaction_type

    if data.transaction_type is "L"
      normalize_data.order = Utils.format data.order, 4, 10
    else
      normalize_data.order = Utils.format data.order, 4, 12

    normalize_data.authorization_code = Utils.formatNumber data.authorization_code, 6 if data.authorization_code
    normalize_data.data = Utils.format data.data, 1024 if data.data

    normalize_data


  create_payment: (order_data) =>
    tpv_data = @normalize(order_data)

    form_data =
      URL: @form_url + "realizarPago"
      Ds_Merchant_Amount: tpv_data.total
      Ds_Merchant_Currency: tpv_data.currency
      Ds_Merchant_Order: tpv_data.order
      Ds_Merchant_MerchantCode: tpv_data.merchant_code
      Ds_Merchant_ConsumerLanguage: tpv_data.language
      Ds_Merchant_MerchantSignature: tpv_data.signature
      Ds_Merchant_Terminal: tpv_data.terminal
      Ds_Merchant_TransactionType: tpv_data.transaction_type

    if tpv_data.transaction_type isnt "L"
      _.extend form_data,
        Ds_Merchant_Titular: tpv_data.titular
        Ds_Merchant_ProductDescription: tpv_data.description
        Ds_Merchant_MerchantURL: tpv_data.merchant_url
        Ds_Merchant_UrlOK: tpv_data.merchant_url_ok
        Ds_Merchant_UrlKO: tpv_data.merchant_url_ko
        Ds_Merchant_MerchantName: tpv_data.merchant_name

      form_data.Ds_Merchant_AuthorisationCode = tpv_data.authorization_code if tpv_data.authorization_code
      form_data.Ds_Merchant_MerchantData = tpv_data.data if tpv_data.data

    form_data
    
  validate_response: (response) =>
    signature = @sign(@build_response_payload response)
    response.Ds_Signature.toLowerCase() is signature

module.exports =
  Redsys: Redsys
