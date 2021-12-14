const mongoose = require('mongoose');

const rightsSchema = mongoose.Schema({
	id: {type: Number, required: true },
	right: {type: String, required: true }
});

module.exports = {
	Rights: mongoose.model('Rights', rightsSchema)
};
