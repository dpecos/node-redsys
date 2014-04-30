chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'

chai.use sinon_chai

should = chai.should()

Redsys = require('../src/redsys').Redsys
redsys = null

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
      @redsys.form_url.should.equal "https://sis-t.redsys.es:25443/sis/"

    it "should point to real environment when test mode disabled", ->
      redsys = new Redsys
      redsys.form_url.should.equal "https://sis.redsys.es/sis/"

  describe "Sign", ->
    
    it "build payload correctly", ->
      @redsys.build_payload
        total: 1235
        order: '29292929'
        currency: 978
      .should.equal '123529292929201920191978h2u282kMks01923kmqpo'

    it "should sign correctly", ->
      data = @redsys.build_payload
        total: 1235
        order: '29292929'
        currency: 978

      @redsys.sign(data).should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'

     it "should sign an order correctly", ->
      form = @redsys.create_payment
        total: 12.35
        order: '29292929'
        currency: 'EUR'
      form['Ds_Merchant_MerchantSignature'].should.equal 'c8392b7874e2994c74fa8bea3e2dff38f3913c46'

    describe "Transaction Type L", ->
      before ->
        redsys = @redsys
        @redsys = new Redsys
          test: true
          merchant:
            code: '123456789'
            secret: 'qwertyasdf0123456789'

      after ->
        @redsys = redsys

      it "should sign correctly", ->
     
        data = @redsys.build_payload
          total: 100
          order: '1404291227'
          currency: 978
          transaction_type: Redsys.TransactionTypes.CARD_IN_ARCHIVE_INITIAL
          redirect_urls:
            callback: 'http://www.sermepa.es'

        @redsys.sign(data).should.equal '3134754014D50F4F29534D2929D2161E623BF1E6'.toLowerCase()

      it "should sign an order correctly", ->
        form = @redsys.create_payment
          total: 100
          order: '1404291227XX'
          currency: 'EUR'
          transaction_type: Redsys.TransactionTypes.CARD_IN_ARCHIVE_INITIAL
          redirect_urls:
            callback: 'http://www.sermepa.es'

        form['Ds_Merchant_MerchantSignature'].should.equal '3134754014D50F4F29534D2929D2161E623BF1E6'.toLowerCase()

  describe "Transaction types", ->

    it "should generate a max 12 chars order if transaction type is '0'", ->
      data = @redsys.normalize
        total: 1235
        currency: 978
        order: '123456789ABCDEFGHIJKL'
        transaction_type: Redsys.TransactionTypes.STANDAR_PAYMENT

      data.order.length.should.equal 12

    it "should generate a exactly 12 chars order if transaction type is 'M'", ->
      data = @redsys.normalize
        total: 1235
        currency: 978
        order: '123456789ABCDEFGHIJKL'
        transaction_type: Redsys.TransactionTypes.CARD_IN_ARCHIVE

      data.order.length.should.equal 12

    it "should generate a max 10 chars order if transaction type is 'L'", ->
      data = @redsys.normalize
        total: 1235
        currency: 978
        order: '123456789ABCDEFGHIJKL'
        transaction_type: Redsys.TransactionTypes.CARD_IN_ARCHIVE_INITIAL

      data.order.length.should.equal 10

  describe "Response validation", ->

    it "should validate a response", ->
      response_data =
        Ds_Date: '24/02/2014'
        Ds_Hour: '14:05'
        Ds_SecurePayment: '1'
        Ds_Card_Country: '724'
        Ds_Amount: '73300'
        Ds_Currency: '978'
        Ds_Order: '1160HH140224'
        Ds_MerchantCode: 'xxxxxxxxx'
        Ds_Terminal: '001'
        Ds_Signature: '6eb213c8b2a259b22468f2a22fe3579e9dd0f71b'
        Ds_Response: '0000'
        Ds_MerchantData: ''
        Ds_TransactionType: '0'
        Ds_ConsumerLanguage: '1'
        Ds_AuthorisationCode: '404701'
      
      @redsys.config.merchant =
        secret: "qwertyasdf0123456789"

      @redsys.validate_response(response_data).should.be.true


