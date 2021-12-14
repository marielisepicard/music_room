const { User } = require("../models/User");
const { Playlist } = require("../models/Playlist");
const Event = require("../models/Event");
const { musicalStylesAllowed } = require("../controllers/user");

///////////////////////
// --- CONSTANTS --- //
///////////////////////

const types = ["pseudos", "playlists", "events"];

///////////////////////////////////////
// --- ERRORS HANDLING FUNCTIONS --- //
///////////////////////////////////////

// Check if the URL parameters are valids
const UrlHandleError = (req) => {
  let parameters = ["value", "type", "limit", "musicalStyle"];
  for (parameter in req.query) {
    if (!parameters.includes(parameter))
      handleError(400, 0, "wrong parameter : " + parameter);
  }
  if (!req.query.value || req.query.value == undefined) req.query.value = "";
  if (
    !req.query.musicalStyle ||
    req.query.musicalStyle == undefined ||
    !musicalStylesAllowed.includes(req.query.musicalStyle)
  ) {
    req.query.musicalStyle = "";
  }
  if (!req.query.type) handleError(400, 2, "type must be specified");
  if (req.query.limit) {
    let limit = parseInt(req.query.limit, 10);
    if (limit != req.query.limit)
      handleError(400, 3, "limit must be an integer");
    req.query.limit = limit;
  }
  if (!types.includes(req.query.type)) {
    let typesStr = types.toString().replaceAll(",", ", ");
    handleError(400, 4, "type parameter must be one of [ " + typesStr + " ]");
  }
};

// Check if variable exists
const handleError = (statusCode, code, message) => {
  throw {
    statusCode,
    code,
    message,
  };
};

// Handle errors for the last catch in functions
const catchErrors = (error, res) => {
  console.error(error);
  if (error.code) {
    res.status(error.statusCode).json(error);
  } else {
    res.status(500).json({ error });
  }
};

/////////////////////////////
// --- SEARCH FUNCTION --- //
/////////////////////////////

//// Private functions ////

const searchFunctions = async (parameters) => {
  const searchObj = {
    pseudos: searchPseudos(parameters),
    playlists: searchPlaylists(parameters),
    events: searchEvents(parameters),
  };
  return searchObj[parameters.type];
};

var searchPseudos = async function (parameters) {
  let regexString = "^" + parameters.value;
  let regex = new RegExp(regexString, "i");
  let users;
  if (parameters.limit)
    users = await User.find(
      { "userInfo.pseudo": { $regex: regex } },
      { "userInfo.pseudo": 1 }
    ).limit(parameters.limit);
  else
    users = await User.find(
      { "userInfo.pseudo": { $regex: regex } },
      { "userInfo.pseudo": 1 }
    );
  users.sort((a, b) => {
    return a.userInfo.pseudo.localeCompare(b.pseudo, "fr", {
      ignorePunctuation: true,
    });
  });
  return users;
};

const searchPlaylists = async (parameters) => {
  let regexString = "^" + parameters.value;
  let regex = new RegExp(regexString, "i");
  let style = "";
  if (parameters.musicalStyle == "") {
    style = "^";
  } else {
    style = parameters.musicalStyle;
  }
  let styleRegex = new RegExp(style, "i");
  let playlists;
  if (parameters.limit) {
    playlists = await Playlist.find(
      {
        name: { $regex: regex },
        public: true,
        musicalStyle: { $regex: styleRegex },
      },
      { name: 1, musicalStyle: 1 }
    )
      .populate("creator")
      .limit(parameters.limit);
  } else {
    playlists = await Playlist.find(
      {
        name: { $regex: regex },
        public: true,
        musicalStyle: { $regex: styleRegex },
      },
      { name: 1, musicalStyle: 1 }
    ).populate("creator");
  }
  playlists.sort((a, b) => {
    return a.name.localeCompare(b.name, "fr", { ignorePunctuation: true });
  });
  let newPlaylist = [];
  for (let i = 0; i < playlists.length; i++) {
    newPlaylist[i] = { ...playlists[i]._doc };
    newPlaylist[i].creator = playlists[i].creator.userInfo.pseudo;
  }
  return newPlaylist;
};

const searchEvents = async (parameters) => {
  let regexString = "^" + parameters.value;
  let regex = new RegExp(regexString, "i");
  let style = "";
  if (parameters.musicalStyle == "") {
    style = "^";
  } else {
    style = parameters.musicalStyle;
  }
  let styleRegex = new RegExp(style, "i");
  let events;
  if (parameters.limit) {
    events = await Event.find(
      {
        name: { $regex: regex },
        publicFlag: true,
        musicalStyle: { $regex: styleRegex },
      },
      { name: 1, musicalStyle: 1 }
    )
      .populate("creator")
      .limit(parameters.limit);
  } else {
    events = await Event.find(
      {
        name: { $regex: regex },
        publicFlag: true,
        musicalStyle: { $regex: styleRegex },
      },
      { name: 1, musicalStyle: 1 }
    ).populate("creator");
  }
  events.sort((a, b) => {
    return a.name.localeCompare(b.name, "fr", { ignorePunctuation: true });
  });
  let newEvents = [];
  for (let i = 0; i < events.length; i++) {
    newEvents[i] = { ...events[i]._doc };
    newEvents[i].creator = events[i].creator.userInfo.pseudo;
  }
  return newEvents;
};

//// Public functions ////

// Search gloabl
exports.searchGlobal = async (req, res, next) => {
  try {
    UrlHandleError(req);
    let search = await searchFunctions(req.query);
    res.status(200).json(search);
  } catch (error) {
    catchErrors(error, res);
  }
};

// Search the track in a playlist
exports.searchTracks = (req, res, next) => {};

// Search friends of a user
exports.searchFriends = async (req, res, next) => {
  try {
    let friends = [];
    if (req.query.value == undefined) req.query.value = "";
    let regexString = "^" + req.query.value;
    let regex = new RegExp(regexString, "i");
    let user = await User.findOne(
      { _id: req.params.userId },
      { "userData.friendsId": 1 }
    ).populate("userData.friendsId", ["_id", "userInfo.pseudo"]);
    if (!user) handleError(400, 0, "Couldn't find the user!");
    for (friend of user.userData.friendsId) {
      if (friend.userInfo.pseudo.match(regex)) {
        friends.push({ _id: friend._id, pseudo: friend.userInfo.pseudo });
      }
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json(friends);
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};
