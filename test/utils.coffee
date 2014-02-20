chai = require 'chai'
sinon = require 'sinon'
sinon_chai = require 'sinon-chai'

chai.use sinon_chai

should = chai.should()

Utils = require('../src/utils')


describe "Utils", ->

  describe "Format strings", ->
    
    it "should return null when string is null", ->
      should.not.exist Utils.format null

    it "should return the same string with no min length", ->
      Utils.format('sermepa').should.equal 'sermepa'

    it "should return right padded string when string is shorter", ->
      Utils.format('sermepa', 10).should.equal "sermepa   "
  
    it "should return same string when string is longer and no max is specified", ->
      Utils.format('sermepa', 3).should.equal "sermepa"
  
    it "should return a substring when string is longer and max is specified", ->
      Utils.format('sermepa', 3, 5).should.equal "serme"

    it "should return same string when string is the same as min and max", ->
      Utils.format('sermepa', 7, 7).should.equal "sermepa"

  describe "Format numbers", ->
     
   it "should return null when number is null", ->
      should.not.exist Utils.formatNumber null

    it "should return the same number with no min length", ->
      Utils.formatNumber(327).should.equal "327"

    it "should return left padded number when number is shorter", ->
      Utils.formatNumber(327, 10).should.equal "0000000327"
  
    it "should return same number when number is longer", ->
      Utils.formatNumber(327, 2).should.equal "327"
  

 
