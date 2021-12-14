const socketIO = require("../server");

exports.refreshSpecificEventRoom = (req, res, next) => {
  try {
    socketIO.io.sockets.in(req.params.eventId).emit("refreshSpecificEventData");
    next();
  } catch (error) {
    console.log(error);
  }
};

exports.refreshUserEventsRoom = (req, res, next) => {
  try {
    socketIO.io.sockets.in(req.params.eventId).emit("refreshUserEventData");
    next();
  } catch (error) {
    console.log(error);
  }
};

exports.refreshSpecificEventRoomFromEventId = (eventId) => {
  try {
    socketIO.io.sockets.in(eventId).emit("refreshSpecificEventData");
  } catch (error) {
    console.log(error);
  }
};

exports.refreshUserEventsRoomFromEventId = (eventId) => {
  try {
    socketIO.io.sockets.in(eventId).emit("refreshUserEventData");
  } catch (error) {
    console.log(error);
  }
};

exports.refreshSpecificPlaylistRoom = (req, res, next) => {
  try {
    socketIO.io.sockets
      .in(req.params.playlistId)
      .emit("refreshSpecificPlaylist");
    next();
  } catch (error) {
    console.log(error);
  }
};
