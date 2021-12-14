const mongoose = require('mongoose');
const { stringify } = require('querystring');
const objectId = mongoose.Schema.Types.ObjectId;

//----Definition of associatedUsers schema part----//
const associatedUsers = mongoose.Schema({
	userId: { type: objectId, ref: 'User', required: true },
	editionRight: { type: Boolean, default: 0 },
});

//----Definition of track schema part----//
const trackSchema = mongoose.Schema({
	trackId: { type: String, required: true },
	duration: { type: Number, required: true }, 
});

//----Definition of playlist schema part----//
const playlistSchema = mongoose.Schema({
	name: { type: String, required: true },
	creator: { type: objectId, ref: 'User', required: true },
	associatedUsers: { type: [associatedUsers] },
	followers: [{ type: objectId, ref: 'User' }],
	tracks: { type: [trackSchema] },
	public: { type: Boolean, default: 1 },
	editionRight: { type: Boolean, default: 1},
	totalDuration: { type: Number, required: true },
	musicalStyle: { type: String, default: 'none' },
});

module.exports = {
	AssociatedUsers: mongoose.model('UserInfos', associatedUsers),
	Track: mongoose.model('Track', trackSchema),
	Playlist: mongoose.model('Playlist', playlistSchema),
};