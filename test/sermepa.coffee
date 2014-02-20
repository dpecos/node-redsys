chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'

chai.use sinon_chai

should = chai.should()

Sermepa = require('../src/sermepa').Sermepa

describe "Sermepa API", ->

  before ->
    @sermepa = new Sermepa
      test: true
      merchant:
        code: '201920191'
        secret: 'h2u282kMks01923kmqpo'
      urls: {}

  describe "Setup", ->

    it "should point to test environment when test mode enabled", ->
      @sermepa.form_url.should.equal "https://sis-t.redsys.es:25443/sis/realizarPago"

    it "should point to real environment when test mode disabled", ->
      sermepa = new Sermepa
      sermepa.form_url.should.equal "https://sis.redsys.es/sis/realizarPago"

  describe "Sign", ->
    
    it "build payload correctly", ->
      @sermepa.build_payload
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal '123529292929201920191978h2u282kMks01923kmqpo'

    it "should sign correctly", ->
      @sermepa.sign
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'


    it "should sign an order correctly", ->
      form = @sermepa.create_payment
        total: 12.35
        order: '29292929'
        currency: 'EUR'
      form['Ds_Merchant_MerchantSignature'].should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'


