chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'

chai.use sinon_chai

should = chai.should()

Redsys = require('../src/redsys').Redsys

describe "Redsys API", ->

  before ->
    @redsys = new Redsys
      test: true
      merchant:
        code: '201920191'
        secret: 'h2u282kMks01923kmqpo'
      urls: {}

  describe "Setup", ->

    it "should point to test environment when test mode enabled", ->
      @redsys.form_url.should.equal "https://sis-t.redsys.es:25443/sis/realizarPago"

    it "should point to real environment when test mode disabled", ->
      redsys = new Redsys
      redsys.form_url.should.equal "https://sis.redsys.es/sis/realizarPago"

  describe "Sign", ->
    
    it "build payload correctly", ->
      @redsys.build_payload
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal '123529292929201920191978h2u282kMks01923kmqpo'

    it "should sign correctly", ->
      @redsys.sign
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'


    it "should sign an order correctly", ->
      form = @redsys.create_payment
        total: 12.35
        order: '29292929'
        currency: 'EUR'
      form['Ds_Merchant_MerchantSignature'].should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'


