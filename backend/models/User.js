const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator')
const { stringify } = require('querystring');
const objectId = mongoose.Schema.Types.ObjectId;

//----Definition of userInfo schema part----//
const loginSchema = mongoose.Schema({
	lastLoginDate: { type: Date },
	tryPasswordTimes: { type: Number }
});

const userInfoSchema = mongoose.Schema({
	firstName: { type: String, required: true },
	lastName: { type: String, required: true },
	pseudo: { type: String, required: true, unique: true},
	email: { type: String, required: true, unique: true },
	secondaryEmail: { type: String },
	password: { type: String, required: true},
	birthDate: { type: Date, default: null},
	registrationDate: { type: Date, required: true},
	active: { type: Boolean, default: false},
	login: { type: loginSchema },
	musicalPreferences: { type: [String] }
});

const activateAccountSchema = mongoose.Schema({
	userId: { type: String, required: true },
	randomKey: { type: String, required: true }
});

const objectMsg = mongoose.Schema({
	content: { type: String, required: true },
	ownerId: { type: objectId, required: true},
	date: { type: Date, required: true }
})

//----Definition of playlistSchema schema part----//
// playlistType : 0 -> creator, 1 -> associated, 2 -> followed
const playlistSchema = mongoose.Schema({
	playlist: { type: objectId, ref: 'Playlist'},
	playlistType: { type: Number, required: true}
});

const userDataSchema = mongoose.Schema({
	playlists: { type: [playlistSchema] },
	events: [{
		eventsId: { type: objectId, ref: 'Event' },
		songIdVotes: { type: [String] }
	}],
	friendsId: [{ type: objectId, ref: 'User' }],
	notifications: {
		playlistsInvitations: [{
			playlist: { type: objectId, ref: 'Playlist' },
			friend: { type: objectId, ref: 'User' },
			editionRight: { type: Boolean, default: false },
			date: { type: Date }
		}],
		friendsInvitations: [{
			user: { type: objectId, ref: 'User' },
			date: { type: Date }
		}],
		eventsInvitations: [{
			event: { type: objectId, ref: 'Event' },
			userRight: { type: String, default: 'guest'},
			friend: { type: objectId, ref: 'User' },
			date: { type: Date }
		}],
	},
	discussions: [{
		recipientId: { type: objectId, required: true, ref: 'User' },
		messages: { type: [objectMsg], required: true}
	}],
	player: {
		index: { type: Number, default: 0 },
		tracksId: [{ type: [String] }],
		random: { type: Boolean, default: false}
	}
});

//----Definition of global user Schema----//
const userSchema = mongoose.Schema({
	userInfo: { type: userInfoSchema, required: true },
	userData:  { type: userDataSchema, required: true }
});

// userSchema.plugin(uniqueValidator);

module.exports = {
	User: mongoose.model('User', userSchema),
	UserInfo: mongoose.model('UserInfo', userInfoSchema),
	UserData: mongoose.model('UserData', userDataSchema),
	ActivateAccount: mongoose.model('ActivateAccount', activateAccountSchema),
	LoginObject:  mongoose.model('LoginObject', loginSchema),
	ObjectMsg: mongoose.model('ObjectMsg', objectMsg)
};
