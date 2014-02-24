Description
===========
RedSys (http://www.redsys.es) Node.js gateway implementation.


Usage
=====

    var redsys = new Redsys({
      "merchant": {
        "code": "MERCHANT_CODE",
        "terminal": "1",
        "titular": "TITULAR",
        "name": "NAME",
        "secret": "qwertyasdf0123456789"
      },
      "language": "auto",
      "test": true
    });
    
    form_data = redsys.create_payment({
      total: ORDER_TOTAL,
      currency: "EUR",
      order: "ORDER ID",
      description: "ORDER DESCRIPTION",
      data: "CART DATA",
      transaction_type: 0,
      redirect_urls: {
        callback: "CALLBACK URL",
        return_url: "OK URL",
        cancel_url: "KO URL"
      }
    });
 


Test
====
    grunt test
    

Fake credit card (test only)
============================

	Number: 4548812049400004
	Date: 12/12
	CVV2: 123
	CIP: 123456
