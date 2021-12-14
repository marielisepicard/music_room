const {User} = require('../models/User');
const Event = require('../models/Event');
const {Playlist} = require('../models/Playlist');


///////////////////////////////////////
// --- ERRORS HANDLING FUNCTIONS --- //
///////////////////////////////////////

// Check if variable exists
const handleError = (statusCode, code, message) => {
	throw {
		statusCode,
		code,
		message
	};
}

// Handle errors for the last catch in functions
const catchErrors = (error, res) => {
	console.error(error);
	if (error.code != undefined) {
		res.status(error.statusCode).json({ 
			code: error.code.toString(),
			message: error.message
		 });
	} else {
		res.status(500).json({ code: '0', error: error});
	}
}

// RefreshPlayer handle error for params
const checkParamsRefreshPlayer = (req) => {
	let types = ['none', 'event', 'playlist']
	if (req.body.type === undefined)
		req.body.type = 'none'
	if (req.body.type != 'none' && req.body.typeId === undefined)
		handleError(400, 0, "typeId isn't defined!");
	if (!types.includes(req.body.type))
		handleError(400, 1, "type must be 'none' or 'event' or 'playlist'!");
	if (req.params.userId === undefined)
		handleError(400, 2, "userId isn't defined!");
	if (req.body.trackId === undefined)
		handleError(400, 3, "trackId isn't defined!");
}


const handleErrorEvent = (trackId, event) => {
	if (!event)
		handleError(400, 4, "Couldn't find the event!")
	for (let i = 0; i < event.tracksInfo.length; i++) {
		if (event.tracksInfo[i].trackId === trackId) {
			return i;
		}
	}
	handleError(400, 5, "The track ID isn't in this event!")
}

const handleErrorPlaylist = (trackId, playlist) => {
	if (!playlist)
		handleError(400, 6, "Couldn't find the playlist!")
	for (let i = 0; i < playlist.tracks.length; i++) {
		if (playlist.tracks[i].trackId === trackId) {
			return i;
		}
	}
	handleError(400, 7, "The track ID isn't in this playlist!")
}



///////////////////////////////////////
/// ---  PLAYER FUNCTIONALITIES --- ///
///////////////////////////////////////

//// Private function ////

// Shuffle an array
const shuffle = (array) => {
	array.sort(() => Math.random() - 0.5);
  }

// Get the reading list for an event
const getTracksEvent = (event, index, random) => {
	let eventTracks = [];
	readingList = {index: index, tracksArray: []}
	if (random) {
		readingList.tracksArray.push(event.tracksInfo[index].trackId);
		readingList.index = 0;
		event.tracksInfo.splice(index, 1)
		eventTracks = event.tracksInfo;
		shuffle(eventTracks);
	} else {
		eventTracks = event.tracksInfo;
	}
	for (let i = 0; i < eventTracks.length; i ++)
		readingList.tracksArray.push(eventTracks[i].trackId)
	return (readingList)
}

// Get the reading list for a playlist
const getTracksPlaylist = (playlist, index, random) => {
	let playlistTracks = [];
	readingList = {index: index, tracksArray: []}
	if (random) {
		readingList.tracksArray.push(playlist.tracks[index].trackId);
		readingList.index = 0;
		playlist.tracks.splice(index, 1);
		playlistTracks = playlist.tracks;
		shuffle(playlistTracks);
	} else {
		playlistTracks = playlist.tracks;
	}
	for (let i = 0; i < playlistTracks.length; i ++)
		readingList.tracksArray.push(playlistTracks[i].trackId)
	return (readingList)
}

// Get the reading list wheter the context is an event, a playlist, or a single track
const getReadingList = async (req, user) => {
	let trackId = req.body.trackId;
	let random = user.userData.player.random;
	if (req.body.type == 'none') {
		return [trackId]
	} else if (req.body.type === 'event') {
		let event = await Event.findOne({_id: req.body.typeId});
		let index = handleErrorEvent(trackId, event);
		return getTracksEvent(event, index, random);
	} else if (req.body.type === 'playlist') {
		let playlist = await Playlist.findOne({_id: req.body.typeId});
		let index = handleErrorPlaylist(trackId, playlist);
		return getTracksPlaylist(playlist, index, random);
	}
}



//// Routes functions ////

// Switch the random parameter of the player
exports.switchRandom = async (req, res, next) => {
	try {
		let user = await User.findOne({ _id: req.params.userId });
		if (!user)
			handleError(400, 0, "Couldn't find the user!");
		await User.updateOne({ _id: req.params.userId }, {$set: {'userData.player.random': !user.userData.player.random}})
		res.musicRoomMessage = "Ok"
		if (user.userData.player.random)
			res.status(200).json({ code: '0', message: "Random player set to 'false'!", random: 0});
		else
			res.status(200).json({ code: '1', message: "Random player set to 'true'!", random: 1});
	} catch(error) {
        res.musicRoomMessage = error.message
		catchErrors(error, res);
	}
	next()
}

// Create a new reading list for the player, with the good index
exports.refreshPlayer = async (req, res, next) => {
	try {
		checkParamsRefreshPlayer(req);
		let user = await User.findOne({ _id: req.params.userId });
		if (!user)
			handleError(400, 8, "Couldn't find the user!");
		let readingList = await getReadingList(req, user);
		user.userData.player.index = readingList.index;
		user.userData.player.tracksId =  readingList.tracksArray;
		await user.save();
		res.musicRoomMessage = "Ok"
		res.status(200).json({ code: '0', tracksId: user.userData.player.tracksId, index: user.userData.player.index });
	} catch(error) {
        res.musicRoomMessage = error.message
		catchErrors(error, res);
	}
	next()
}

// Get the next track in the reading list and incremente the index
exports.getNextTrack = async (req, res, next) => {
	try {
		let user = await User.findOne({ _id: req.params.userId });
		if (!user)
			handleError(400, 0, "Couldn't find the user!");
		user.userData.player.index+=1;
		if (user.userData.player.index == user.userData.player.tracksId.length)
			user.userData.player.index = 0;
		await user.save();
		res.musicRoomMessage = "Ok"
		res.status(200).json({ code: '0', trackId: user.userData.player.tracksId[user.userData.player.index] });
	} catch(error) {
        res.musicRoomMessage = error.message
		catchErrors(error, res);
	}
	next()
}

// Get the previous track in the reading list and decremente the index
exports.getPreviousTrack = async (req, res, next) => {
	try {
		let user = await User.findOne({ _id: req.params.userId });
		if (!user)
			handleError(400, 0, "Couldn't find the user!");
		user.userData.player.index-=1;
		if (user.userData.player.index < 0)
			user.userData.player.index = 0;
		await user.save();
		res.musicRoomMessage = "Ok"
		res.status(200).json({ code: '0', trackId: user.userData.player.tracksId[user.userData.player.index] });
	} catch(error) {
        res.musicRoomMessage = error.message
		catchErrors(error, res);
	}
	next()
}