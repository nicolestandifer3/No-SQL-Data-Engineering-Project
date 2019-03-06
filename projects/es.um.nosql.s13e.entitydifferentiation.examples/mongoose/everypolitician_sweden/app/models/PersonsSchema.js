'use strict'

var mongoose = require('mongoose');
var Identifier = require('./IdentifierSchema.js');
var Other_name = require('./Other_nameSchema.js');
var Image = require('./ImageSchema.js');
var Contact_detail = require('./Contact_detailSchema.js');
var Link = require('./LinkSchema.js');
var UnionType = require('./util/UnionType.js');

var Persons = new mongoose.Schema({
  _id: {type: String, required: true},
  birth_date: {type: String, required: true},
  contact_details: {type: [Contact_detail.schema], default: undefined},
  death_date: String,
  email: String,
  family_name: {type: String, required: true},
  gender: {type: String, required: true},
  given_name: {type: String, required: true},
  identifiers: {type: [Identifier.schema], default: undefined},
  image: {type: String, required: true},
  images: {type: [Image.schema], default: undefined},
  links: {type: [Link.schema], default: undefined},
  name: {type: String, required: true},
  other_names: {type: [Other_name.schema], default: undefined},
  sort_name: {type: String, required: true}
}, { versionKey: false, collection: 'persons'});


module.exports = mongoose.model('Persons', Persons);
