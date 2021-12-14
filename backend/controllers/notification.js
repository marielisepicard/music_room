const { User } = require("../models/User");

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

exports.getPlaylistsInvitations = async (req, res, next) => {
  try {
    let user = await User.findOne(
      { _id: req.params.userId },
      { "userData.notifications.playlistsInvitations": 1 }
    )
      .populate("userData.notifications.playlistsInvitations.friend", [
        "_id",
        "userInfo.pseudo",
      ])
      .populate("userData.notifications.playlistsInvitations.playlist", [
        "_id",
        "name",
      ]);
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let playlistsInvitations = [];
    for (playlistInvitation of user.userData.notifications
      .playlistsInvitations) {
      console.log(playlistInvitation);
      playlistsInvitations.push({
        friendId: playlistInvitation.friend._id,
        friendPseudo: playlistInvitation.friend.userInfo.pseudo,
        playlistId: playlistInvitation.playlist._id,
        playlistName: playlistInvitation.playlist.name,
        editionRight: playlistInvitation.editionRight,
        date: playlistInvitation.date,
      });
    }
    res.musicRoomMessage = "Ok";
    res
      .status(200)
      .json({ code: "0", playlistsInvitations: playlistsInvitations });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

exports.getEventsInvitations = async (req, res, next) => {
  try {
    let user = await User.findOne(
      { _id: req.params.userId },
      { "userData.notifications.eventsInvitations": 1 }
    )
      .populate("userData.notifications.eventsInvitations.friend", [
        "_id",
        "userInfo.pseudo",
      ])
      .populate("userData.notifications.eventsInvitations.event", [
        "_id",
        "name",
      ]);
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let eventsInvitations = [];
    for (eventInvitation of user.userData.notifications.eventsInvitations) {
      eventsInvitations.push({
        friendId: eventInvitation.friend._id,
        friendPseudo: eventInvitation.friend.userInfo.pseudo,
        eventId: eventInvitation.event._id,
        eventName: eventInvitation.event.name,
        userRight: eventInvitation.userRight,
        date: eventInvitation.date,
      });
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", eventsInvitations: eventsInvitations });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};

exports.getFriendsInvitations = async (req, res, next) => {
  try {
    let user = await User.findOne(
      { _id: req.params.userId },
      { "userData.notifications.friendsInvitations": 1 }
    ).populate("userData.notifications.friendsInvitations.user", [
      "_id",
      "userInfo.pseudo",
    ]);
    if (!user) handleError(400, 0, "Couldn't find the user!");
    let friendsInvitations = [];
    for (friendInvitation of user.userData.notifications.friendsInvitations) {
      friendsInvitations.push({
        userId: friendInvitation.user._id,
        pseudo: friendInvitation.user.userInfo.pseudo,
        date: friendInvitation.date,
      });
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({ code: "0", friendsInvitations: friendsInvitations });
  } catch (error) {
    res.musicRoomMessage = error.message;
    catchErrors(error, res);
  }
  next();
};
