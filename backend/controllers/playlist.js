const { Playlist } = require("../models/Playlist");
const { User } = require("../models/User");
const { musicalStylesAllowed } = require("../controllers/user");

///////////////////////
// --- CONSTANTS --- //
///////////////////////

var CREATED = 0;
var ASSOCIATED = 1;
var FOLLOWED = 2;

///////////////////////////////////////
// --- ERRORS HANDLING FUNCTIONS --- //
///////////////////////////////////////

// Handle error for followPlaylist function
const followPlaylistHandleError = (user, playlist) => {
  if (!user) handleError(400, 0, "Couldn't find the user!");
  if (!playlist) handleError(400, 1, "Couldn't find the playlist!");
  if (!playlist.public) handleError(400, 2, "Playlist is private!");
  if (playlist.creator.equals(user._id))
    handleError(400, 3, "The user is already the creator of the playlist!");
  var userPlaylist;
  for (userPlaylist of user.userData.playlists) {
    if (
      userPlaylist.playlist.equals(playlist._id) &&
      userPlaylist.playlistType == FOLLOWED
    )
      handleError(400, 4, "The playlist is already followed!");
    if (
      userPlaylist.playlist.equals(playlist._id) &&
      userPlaylist.playlistType == ASSOCIATED
    )
      handleError(400, 5, "The playlist is already associated!");
  }
};

// Handle error for unfollowPlaylist function
const unfollowPlaylistHandleError = (user, playlist) => {
  if (!user) handleError(400, 0, "Couldn't find the user!");
  if (!playlist) handleError(400, 1, "Couldn't find the playlist!");
  var userPlaylist;
  for (userPlaylist of user.userData.playlists) {
    if (
      userPlaylist.playlist.equals(playlist._id) &&
      userPlaylist.playlistType == FOLLOWED
    )
      return userPlaylist;
  }
  handleError(400, 2, "The playlist isn't followed yet!");
};

// Handle error for sendInvitationToPlaylist function
const sendInvitationToPlaylistHandleError = (playlist, user, friend) => {
  if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
  if (!user) handleError(400, 1, "Couldn't find the user!");
  if (!friend) handleError(400, 2, "Couldn't find the friend!");
  if (!playlist.creator.equals(user._id))
    handleError(
      400,
      3,
      "You don't have the right to invite someone to this playlist!"
    );
  for (friendPlaylist of friend.userData.playlists) {
    if (
      friendPlaylist.playlist.equals(playlist._id) &&
      friendPlaylist.playlistType == ASSOCIATED
    )
      handleError(400, 4, "The friend is already associated to this playlist!");
  }
  for (friendPendingInvitation of friend.userData.notifications
    .playlistsInvitations) {
    if (
      friendPendingInvitation.playlist.equals(playlist._id) &&
      friendPendingInvitation.friend.equals(user._id)
    )
      handleError(
        400,
        5,
        "The friend has already a pending invitation to this playlist!"
      );
  }
  let isFriend = false;
  for (userFriend of user.userData.friendsId) {
    if (userFriend.equals(friend._id)) isFriend = true;
  }
  if (!isFriend) handleError(400, 6, "The friend is not in your friends list!");
};

// Handle error for acceptInvitationToPlaylist function
const acceptInvitationToPlaylistHandleError = (user, playlist) => {
  if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
  if (!user) handleError(400, 1, "Couldn't find the user!");
  let playlistInvitation = 0;
  for (userPendingInvitation of user.userData.notifications
    .playlistsInvitations) {
    if (userPendingInvitation.playlist.equals(playlist._id)) {
      playlistInvitation = 1;
      break;
    }
  }
  if (!playlistInvitation)
    handleError(
      400,
      2,
      "The user doesn't have a pending invitation to this playlist!"
    );
  for (userPlaylist of user.userData.playlists) {
    if (
      userPlaylist.playlist.equals(playlist._id) &&
      userPlaylist.playlistType == ASSOCIATED
    )
      handleError(400, 3, "The user is already associated to this playlist!");
  }
};

// Handle error for refuseInvitationToPlaylist function
const refuseInvitationToPlaylistHandleError = (user, playlist) => {
  if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
  if (!user) handleError(400, 1, "Couldn't find the user!");
  let playlistInvitation = 0;
  for (userPendingInvitation of user.userData.notifications
    .playlistsInvitations) {
    if (userPendingInvitation.playlist.equals(playlist._id)) {
      playlistInvitation = 1;
      break;
    }
  }
  if (!playlistInvitation)
    handleError(
      400,
      2,
      "The user doesn't have a pending invitation to this playlist!"
    );
};

// Handle error for removeAssociatedUserFromPlaylist function
const removeAssociatedUserFromPlaylistHandleError = (
  user,
  associatedUser,
  playlist
) => {
  if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
  if (!user) handleError(400, 1, "Couldn't find the user!");
  if (!associatedUser) handleError(400, 2, "Couldn't find the associatedUser!");
  if (
    !playlist.creator.equals(user._id) &&
    !user._id.equals(associatedUser._id)
  )
    handleError(400, 3, "The user doesn't have this right!");
  if (playlist.creator.equals(user._id) && user._id.equals(associatedUser._id))
    handleError(400, 4, "The creator must delete the playlist to leave it!");
  let isAssociated = false;
  for (playlistAssociatedUser of playlist.associatedUsers) {
    if (playlistAssociatedUser.userId.equals(associatedUser._id)) {
      isAssociated = true;
      break;
    }
  }
  if (!isAssociated)
    handleError(
      400,
      5,
      "The associatedUser is not associated to this playlist!"
    );
};

const changeEditionRightAssociatedUserHandleError = (
  playlist,
  user,
  associatedUser
) => {
  if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
  if (!user) handleError(400, 1, "Couldn't find the user!");
  if (!associatedUser) handleError(400, 2, "Couldn't find the associatedUser!");
  if (!playlist.creator.equals(user._id))
    handleError(400, 3, "The user doesn't have this right!");
  let isAssociated = false;
  for (playlistAssociatedUser of playlist.associatedUsers) {
    if (playlistAssociatedUser.userId.equals(associatedUser._id)) {
      isAssociated = true;
      break;
    }
  }
  if (!isAssociated)
    handleError(
      400,
      4,
      "The associatedUser is not associated to this playlist!"
    );
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
  if (error.code != undefined) {
    res.status(error.statusCode).json({
      code: error.code.toString(),
      message: error.message,
    });
  } else {
    res.status(500).json({ code: "0", error: error });
  }
};

///////////////////////////////
// --- GETTERS FUNCTIONS --- //
///////////////////////////////

// Get a playlist based on its _id
exports.getPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId })
      .populate("creator", ["_id", "userInfo.pseudo"])
      .populate("followers", ["_id", "userInfo.pseudo"])
      .populate("associatedUsers.userId", ["_id", "userInfo.pseudo"]);
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    let newPlaylist = { ...playlist._doc };
    let newCreator = {
      userId: playlist.creator._id,
      userPseudo: playlist.creator.userInfo.pseudo,
    };
    let newAssociatedUsers = [];
    for (associatedUser of playlist.associatedUsers) {
      newAssociatedUsers.push({
        userId: associatedUser.userId._id,
        userPseudo: associatedUser.userId.userInfo.pseudo,
        editionRight: associatedUser.editionRight,
      });
    }
    let newFollowers = [];
    for (follower of playlist.followers) {
      newFollowers.push({
        userId: follower._id,
        userPseudo: follower.userInfo.pseudo,
      });
    }
    newPlaylist.creator = newCreator;
    newPlaylist.associatedUsers = newAssociatedUsers;
    newPlaylist.followers = newFollowers;
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlist: newPlaylist });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all tracks of a playlist
exports.getPlaylistTracks = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne(
      { _id: req.params.playlistId },
      { "tracks.trackId": 1 }
    );
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    let trackArray = [];
    for (let i = 0; i < playlist.tracks.length; i++) {
      trackArray.push(playlist.tracks[i].trackId);
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", tracks: trackArray });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all public playlists
exports.getAllPublicPlaylists = async (req, res, next) => {
  try {
    let playlists = await Playlist.find({ public: true });
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: playlists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all playlists of a user
exports.getAllUserPlaylists = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate({
      path: "userData.playlists.playlist",
      populate: { path: "creator", select: ["_id", "userInfo.pseudo"] },
    });
    user.userData.playlists.sort((a, b) => {
      return a.playlist.name.localeCompare(b.playlist.name, "fr", {
        ignorePunctuation: true,
      });
    });
    if (!user) handleError(400, 0, "Couldn't find the user!");
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: user.userData.playlists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all followed playlists of a user
exports.getUserFollowedPlaylists = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.playlists.playlist"
    );
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let followedPlaylists = [];
    for (userPlaylist of user.userData.playlists) {
      if (userPlaylist.playlistType == FOLLOWED)
        followedPlaylists.push(userPlaylist);
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: followedPlaylists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all associated playlists of a user
exports.getUserAssociatedPlaylists = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.playlists.playlist"
    );
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let associatedPlaylists = [];
    for (userPlaylist of user.userData.playlists) {
      if (userPlaylist.playlistType == ASSOCIATED)
        associatedPlaylists.push(userPlaylist);
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: associatedPlaylists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get all created playlists of a user
exports.getUserCreatedPlaylists = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.playlists.playlist"
    );
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let createdPlaylists = [];
    for (userPlaylist of user.userData.playlists) {
      if (userPlaylist.playlistType == CREATED)
        createdPlaylists.push(userPlaylist);
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: createdPlaylists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Get public playlists of a user
exports.getUserPublicPlaylists = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.playlists.playlist"
    );
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let publicPlaylists = [];
    for (userPlaylist of user.userData.playlists) {
      if (userPlaylist.playlist.public == true)
        publicPlaylists.push(userPlaylist);
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", playlists: publicPlaylists });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

///////////////////////////////////
// --- USERS FUNCTIONALITIES --- //
///////////////////////////////////

// The user follows the public playlist
exports.followPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    followPlaylistHandleError(user, playlist);
    user.userData.playlists.push({
      playlist: playlist._id,
      playlistType: FOLLOWED,
    });
    playlist.followers.push(user._id);
    await Promise.all([playlist, user].map((m) => m.save()));
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Playlist followed!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// The user unfollows the playlist
exports.unfollowPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    let userPlaylist = unfollowPlaylistHandleError(user, playlist);
    userPlaylist.remove();
    playlist.followers.pull(user._id);
    await Promise.all([playlist, user].map((m) => m.save()));
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Playlist unfollowed!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Sends invitation to a playlist to a friend
exports.sendInvitationToPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    let friend = await User.findOne({ _id: req.params.friendId });
    sendInvitationToPlaylistHandleError(playlist, user, friend);
    let playlistInvitation = {
      playlist: req.params.playlistId,
      friend: req.params.userId,
      date: Date.now(),
    };
    let editionRight = false;
    if (req.body.editionRight)
      editionRight =
        req.body.editionRight == "true" || req.body.editionRight == 1;
    playlistInvitation.editionRight = editionRight;
    friend.userData.notifications.playlistsInvitations.push(playlistInvitation);
    await friend.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Invitation to the playlist sent to the friend!",
    });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

const getPendingInvitation = (playlist, user) => {
  for (userPendingInvitation of user.userData.notifications
    .playlistsInvitations) {
    if (userPendingInvitation.playlist.equals(playlist._id)) {
      return userPendingInvitation;
    }
  }
};

const removeFromFollowers = (playlist, user) => {
  for (userPlaylist of user.userData.playlists) {
    if (
      userPlaylist.playlist.equals(playlist._id) &&
      userPlaylist.playlistType == FOLLOWED
    ) {
      userPlaylist.remove();
      playlist.followers.pull(user._id);
    }
  }
};

// The user accepts the invitation to the playlist
exports.acceptInvitationToPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    acceptInvitationToPlaylistHandleError(user, playlist);
    let pendingInvitation = getPendingInvitation(playlist, user);
    user.userData.playlists.push({
      playlist: playlist._id,
      playlistType: ASSOCIATED,
    });
    playlist.associatedUsers.push({
      userId: user._id,
      editionRight: pendingInvitation.editionRight,
    });
    user.userData.notifications.playlistsInvitations.pull(
      pendingInvitation._id
    );
    removeFromFollowers(playlist, user);
    await Promise.all([playlist, user].map((m) => m.save()));
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Invitation accepted!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// The user refuses the invitation to the playlist
exports.refuseInvitationToPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    refuseInvitationToPlaylistHandleError(user, playlist);
    let pendingInvitation = getPendingInvitation(playlist, user);
    user.userData.notifications.playlistsInvitations.pull(
      pendingInvitation._id
    );
    await user.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Invitation refused!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Remove the associated user from the playlist
exports.removeAssociatedUserFromPlaylist = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    let associatedUser = await User.findOne({
      _id: req.params.associatedUserId,
    });
    removeAssociatedUserFromPlaylistHandleError(user, associatedUser, playlist);
    for (userPlaylist of associatedUser.userData.playlists) {
      if (userPlaylist.playlist.equals(playlist._id)) {
        associatedUser.userData.playlists.pull(userPlaylist._id);
        break;
      }
    }
    for (playlistAssociatedUser of playlist.associatedUsers) {
      if (playlistAssociatedUser.userId.equals(associatedUser._id)) {
        playlistAssociatedUser.remove();
        break;
      }
    }
    await Promise.all([playlist, associatedUser].map((m) => m.save()));
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Associated user removed!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

exports.switchEditionRight = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    if (playlist.creator != req.params.userId)
      handleError(
        400,
        1,
        "The user doesn't have the rights to change the edition's right!"
      );
    if (playlist.public == false && playlist.editionRight == false)
      handleError(400, 2, "The playlist is private!");
    await Playlist.updateOne(
      { _id: req.params.playlistId },
      { $set: { editionRight: !playlist.editionRight } }
    );
    res.musicRoomMessage = "Ok";
    if (playlist.editionRight)
      res.status(200).json({
        code: "0",
        message: "Edition right set to 'false'!",
        editionRight: 0,
      });
    else
      res.status(200).json({
        code: "1",
        message: "Edition right set to 'true'!",
        editionRight: 1,
      });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Change the edition right of the associated user
exports.switchEditionRightAssociatedUser = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.params.userId });
    let associatedUser = await User.findOne({
      _id: req.params.associatedUserId,
    });
    changeEditionRightAssociatedUserHandleError(playlist, user, associatedUser);
    for (playlistAssociatedUser of playlist.associatedUsers) {
      if (playlistAssociatedUser.userId.equals(associatedUser._id)) {
        playlistAssociatedUser.editionRight =
          !playlistAssociatedUser.editionRight;
        associatedUserEditionRight = playlistAssociatedUser.editionRight;
      }
    }
    await playlist.save();
    res.musicRoomMessage = "Ok";
    if (!associatedUserEditionRight)
      res.status(200).json({
        code: "0",
        message: "Edition right of the associated set to 'false'!",
        editionRight: "0",
      });
    else
      res.status(200).json({
        code: "1",
        message: "Edition right of the associated set to 'true'!",
        editionRight: "1",
      });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Set a playlist public
exports.setPlaylistPublic = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    if (playlist.creator != req.params.userId)
      handleError(
        400,
        1,
        "The user doesn't have the rights to set this playlist public!"
      );
    if (playlist.public == true)
      handleError(400, 2, "The playlist is already public!");
    await Playlist.updateOne(
      { _id: req.params.playlistId },
      { $set: { public: true } }
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Playlist set public!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Set a playlist private
exports.setPlaylistPrivate = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    if (playlist.creator != req.params.userId)
      handleError(
        400,
        1,
        "The user doesn't have the rights to set this playlist private!"
      );
    if (playlist.public == false)
      handleError(400, 2, "The playlist is already private!");
    await Promise.all([
      Playlist.updateOne(
        { _id: req.params.playlistId },
        { $set: { public: false, followers: [], editionRight: false } }
      ),
      User.updateMany(
        {},
        {
          $pull: {
            "userData.playlists": {
              playlist: req.params.playlistId,
              playlistType: FOLLOWED,
            },
          },
        }
      ),
    ]);
    res.status(200).json({ code: "0", message: "Playlist set private!" });
  } catch (error) {
    catchErrors(error, res);
  }
};

// Change musical style of the playlist
exports.changeMusicalStyle = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    if (playlist.creator != req.params.userId)
      handleError(
        400,
        1,
        "The user doesn't have the rights to change the musical rights!"
      );
    if (
      !req.body.musicalStyle ||
      !musicalStylesAllowed.includes(req.body.musicalStyle)
    )
      handleError(400, 2, "The musical style isn't valid!");
    playlist.musicalStyle = req.body.musicalStyle;
    await playlist.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Playlist musical style changed!",
      musicalStyle: playlist.musicalStyle,
    });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

/////////////////////////////////////
// --- CREATE/DELETE FUNCTIONS --- //
/////////////////////////////////////

// Create a playlist
exports.createPlaylist = async (req, res, next) => {
  try {
    let public = true;
    let editionRight = true;
    let musicalStyle = "none";
    if (req.body.public)
      public = req.body.public == "true" || req.body.public == 1;
    if (req.body.editionRight)
      editionRight =
        req.body.editionRight == "true" || req.body.editionRight == 1;
    if (!public) editionRight = false;
    if (
      req.body.musicalStyle &&
      musicalStylesAllowed.includes(req.body.musicalStyle)
    )
      musicalStyle = req.body.musicalStyle;
    if (!req.body.name || req.body.name == undefined || req.body.name == "")
      handleError(400, 1, "The name of the playlist must be specified!");
    let user = await User.findOne({ _id: req.params.userId });
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let playlist = new Playlist({
      name: req.body.name,
      creator: req.params.userId,
      totalDuration: 0,
      public: public,
      editionRight: editionRight,
      musicalStyle: musicalStyle,
    });
    user.userData.playlists.push({
      playlist: playlist._id,
      playlistType: CREATED,
    });
    await Promise.all([playlist, user].map((m) => m.save()));
    res.musicRoomMessage = "Ok";
    res.status(201).json({
      code: "0",
      message: "Playlist created!",
      playlistId: playlist._id,
    });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Delete a playlist
exports.deletePlaylist = async (req, res, ext) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    if (!playlist) handleError(400, 0, "Couldn't find the playlist!");
    if (playlist.creator != req.params.userId)
      handleError(
        400,
        1,
        "The user doesn't have the rights to delete this playlist!"
      );
    await Promise.all([
      Playlist.deleteOne({ _id: req.params.playlistId }),
      User.updateMany({
        $pull: { "userData.playlists": { playlist: req.params.playlistId } },
      }),
    ]);
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Playlist deleted!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

//////////////////////////////
// --- TRACKS FUNCTIONS --- //
//////////////////////////////

//// Public functions ////

// Add the track to the playlist
exports.addTrack = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.body.userId });
    if (!user) handleError(400, 0, "Couldn't find the user!");
    if (!playlist) handleError(400, 1, "Couldn't find the playlist!");
    let associatedUserEditionRight = false;
    for (playlistAssociatedUser of playlist.associatedUsers) {
      if (playlistAssociatedUser.userId.equals(user._id))
        associatedUserEditionRight = playlistAssociatedUser.editionRight;
    }
    if (
      playlist.editionRight != 1 &&
      !playlist.creator.equals(user._id) &&
      !associatedUserEditionRight
    )
      handleError(
        400,
        2,
        "The user doesn't have the rights to add track in this playlist!"
      );
    for (playlistTrack of playlist.tracks) {
      if (playlistTrack.trackId == req.params.trackId)
        handleError(400, 3, "Track already in playlist!");
    }
    let track = {
      trackId: req.params.trackId,
      duration: parseInt(req.body.duration, 10),
    };
    playlist.tracks.push(track);
    playlist.totalDuration += track.duration;
    await playlist.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Track added!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

function array_move(arr, old_index, new_index) {
  if (new_index >= arr.length) {
    var k = new_index - arr.length + 1;
    while (k--) {
      arr.push(undefined);
    }
  }
  arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
  return arr;
}

exports.changeOrderTrack = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.body.userId });
    if (!user) handleError(400, 0, "Couldn't find the user!");
    if (!playlist) handleError(400, 1, "Couldn't find the playlist!");
    let associatedUserEditionRight = false;
    for (playlistAssociatedUser of playlist.associatedUsers) {
      if (playlistAssociatedUser.userId.equals(user._id))
        associatedUserEditionRight = playlistAssociatedUser.editionRight;
    }
    if (
      playlist.editionRight != 1 &&
      !playlist.creator.equals(user._id) &&
      !associatedUserEditionRight
    )
      handleError(
        400,
        2,
        "The user doesn't have the rights to add track in this playlist!"
      );
    if (req.body.oldIndex < 0 || req.body.oldIndex >= playlist.tracks.length)
      handleError(400, 3, "Old index out of range!");
    if (req.body.newIndex < 0 || req.body.newIndex >= playlist.tracks.length)
      handleError(400, 4, "New index out of range!");
    array_move(playlist.tracks, req.body.oldIndex, req.body.newIndex);
    await playlist.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Track moved!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

// Delete the track from the playlist
exports.deleteTrack = async (req, res, next) => {
  try {
    let playlist = await Playlist.findOne({ _id: req.params.playlistId });
    let user = await User.findOne({ _id: req.query.userId });
    if (!user) handleError(400, 0, "Couldn't find the user!");
    if (!playlist) handleError(400, 1, "Couldn't find the playlist!");
    associatedUserEditionRight = false;
    for (playlistAssociatedUser of playlist.associatedUsers) {
      if (playlistAssociatedUser.userId.equals(user._id))
        associatedUserEditionRight = playlistAssociatedUser.editionRight;
    }
    if (
      playlist.editionRight != 1 &&
      !playlist.creator.equals(user._id) &&
      !associatedUserEditionRight
    )
      handleError(
        400,
        2,
        "The user doesn't have the rights to delete track in this playlist!"
      );
    if (req.query.index < 0 || req.query.index >= playlist.tracks.length)
      handleError(400, 3, "Index out of range!");
    playlist.totalDuration -= playlist.tracks[req.query.index].duration;
    playlist.tracks.splice(req.query.index, 1);
    await playlist.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", message: "Track deleted!" });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};
