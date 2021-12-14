const mongoose = require('mongoose');
const objectId = mongoose.Schema.Types.ObjectId;


const eventSchema = mongoose.Schema({
	name: { type: String, required: true },
	creator: { type: objectId, ref: 'User', required: true },
	status: { type: String, required: true},
	place: { type: String },
	geoLoc: {
		lat: { type: Number },
		long: { type : Number }
	},
	beginDate: { type: Date },
	endDate: { type: Date },
	publicFlag: { type: Boolean, required: true, default: true }, //public keyword is reserved for system
	votingPrerequisites: { type: Boolean, required: true, default: false },
	musicalStyle: { type: String, required: true, default: 'none'},
	physicalEvent: { type: Boolean, required: true, default: false },
	guestsInfo: [{
		userId: { type: objectId, ref: 'User', required: true },
		right: { type: String, required: true}
	}],
	guestsNumber: { type: Number, required: true, default: 0 },
	tracksInfo: [
		{
			trackId: { type: String, required: true },
			trackDuration: {type: Number, required: true, default: 0},
			timeBeginListening: {type: Date, required: true, default: 0},
			votesNumber: {type: Number, required: true }
		}
	]
});

module.exports = mongoose.model('Event', eventSchema);