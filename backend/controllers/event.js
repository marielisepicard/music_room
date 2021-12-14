const Event = require("../models/Event");
const { User } = require("../models/User");
const axios = require("axios");
const jwt = require("jsonwebtoken");
// const { errorMonitor } = require("nodemailer/lib/mailer");
// const { populate, events } = require("../models/Event");
const { musicalStylesAllowed } = require("../controllers/user");
const cron = require("node-cron");
const socketCtrl = require("../middleware/socketIO");

cron.schedule("* * * * * *", () => {
  try {
    getAllStartedEvent();
  } catch (err) {
    console.log(err.message);
  }
});

function setPlayTrackIfThereIsNot(event) {
  if (event.tracksInfo[0].timeBeginListening.getTime() == 0) {
    event.tracksInfo[0].timeBeginListening = Date.now();
    console.log("Listening new song in " + event.name);
    event.save();
    socketCtrl.refreshSpecificEventRoomFromEventId(event._id.toString());
  }
}

function checkForNextTrack(event) {
  if (event.tracksInfo.lenght > 0) {
    event.tracksInfo[0].timeBeginListening = Date.now();
    console.log("Listening new song in " + event.name);
    event.save();
  }
}
async function checkIfTrackShouldTerminate(event) {
  let endSongDate = new Date(
    event.tracksInfo[0].timeBeginListening.getTime() +
      event.tracksInfo[0].trackDuration
  );
  if (endSongDate - 2000 <= Date.now()) {
    console.log("track is finished");
    await deleteTrackFromEventData(
      event._id.toString(),
      event.tracksInfo[0].trackId
    );
    checkForNextTrack(event);
    socketCtrl.refreshSpecificEventRoomFromEventId(event._id.toString());
  }
}

async function getAllStartedEvent() {
  let events = await Event.find({
    $or: [
      { status: "started" },
      { beginDate: { $lte: Date.now() }, endDate: { $gt: Date.now() } },
    ],
  });
  for (let i = 0; i < events.length; i++) {
    await updateEventStatusIfNeeded(events[i]);
    if (events[i].status == "started") {
      if (events[i].tracksInfo.length > 0) {
        setPlayTrackIfThereIsNot(events[i]);
        await checkIfTrackShouldTerminate(events[i]);
      }
    }
  }
}

async function updateEventStatusIfNeeded(event) {
  if (event.physicalEvent == false) {
    return;
  }
  if (event.beginDate > Date.now()) {
    event.status = "notStarted";
  } else if (event.endDate < Date.now()) {
    event.status = "terminated";
  } else if (event.status != "started") {
    event.status = "started";
  } else {
    return;
  }
  console.log("update event:" + event.name + " status");
  await event.save();
  socketCtrl.refreshUserEventsRoomFromEventId(event._id.toString());
}

exports.getAllPublicEvents = async (req, res, next) => {
  try {
    let events = await Event.find({ publicFlag: "true" });
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      events: events,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
  next();
};

exports.getAllYourEditableEvents = async (req, res, next) => {
  try {
    let eventList = await addInfosOnUserEvents(req);
    if (!eventList)
      throw new Error("Internal error: should find list of events");
    for (let i = 0; eventList[i]; i++) {
      if (getUserEventAccess_noFind(req.params.userId, eventList[i]) != 2) {
        eventList.splice(i, 1);
        i--;
      }
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      events: eventList,
    });
  } catch (err) {
    console.log(err);
    res.musicRoomMessage = err.message;
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
  next();
};

function addDidUserVoteOnTrackList(eventInfo) {
  eventInfo.eventsId.tracksInfo.forEach((element) => {
    if (eventInfo.songIdVotes.indexOf(element.trackId) == -1) {
      element.userVote = false;
    } else {
      element.userVote = true;
    }
    delete element._id;
  });
}

async function addInfosOnUserEvents(req) {
  let user = await User.findOne({ _id: getUserIdFromToken(req) }).populate({
    path: "userData.events.eventsId",
    populate: {
      path: "creator guestsInfo.userId",
      select: "userInfo.pseudo",
    },
  });
  if (!user) throw new Error("Error: Invalid userId!");
  user = user.toObject();
  for (let i = 0; user.userData.events[i]; i++) {
    user.userData.events[i].eventsId.creator =
      user.userData.events[i].eventsId.creator.userInfo.pseudo;
    user.userData.events[i].eventsId.guestsInfo.forEach((element) => {
      delete element._id;
      element.pseudo = element.userId.userInfo.pseudo;
      element.userId = element.userId._id;
    });
    addDidUserVoteOnTrackList(user.userData.events[i]);
  }
  return user.userData.events.map(function (e) {
    return e.eventsId;
  });
}

exports.getAllMyEvents = async (req, res, next) => {
  try {
    let eventList = await addInfosOnUserEvents(req);
    if (!eventList)
      throw new Error("Internal error: should find list of events");
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      events: eventList,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
  next();
};

exports.getSpecifiedEvent = async (req, res, next) => {
  try {
    let event = await Event.findOne({ _id: req.params.eventId })
      .populate("guestsInfo.userId", "userInfo.pseudo")
      .populate("creator", "userInfo.pseudo");
    if (!event) throw new Error("Invalid event id!");
    if (event.publicFlag == false) {
      if (
        (await getUserEventAccess(
          getUserIdFromToken(req),
          req.params.eventId
        )) == -1
      )
        throw new Error("User cannot get private event!");
    }
    event = event.toObject();
    event.guestsInfo.forEach((element) => {
      delete element._id;
      element.pseudo = element.userId.userInfo.pseudo;
      element.userId = element.userId._id;
    });
    event.creator = event.creator.userInfo.pseudo;
    await addVotedTracksInArr(req, event);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      event: event,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    if (err.message == "Invalid event id!") {
      res.status(400).json({
        code: "0",
        message: err.message,
      });
    } else if (err.message == "User cannot get private event!") {
      res.status(400).json({
        code: "1",
        message: err.message,
      });
    } else {
      console.log(err);
      res.status(500).json({
        code: "0",
        message: "Internal error!",
      });
    }
  }
  next();
};

function parseGetUserRightFromSpecificEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
}

function parseGetUserRightFromSpecificEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else {
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.getUserRightFromSpecificEvent = async (req, res, next) => {
  try {
    parseGetUserRightFromSpecificEventArg(req);
    let userRight = await getUserEventAccess(
      req.params.userId,
      req.params.eventId
    );
    if (userRight < -1 || userRight > 2)
      throw new Error("Error: Invalid user right!");
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      userRight: userRight,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseGetUserRightFromSpecificEventErrors(res, err);
  }
  next();
};

exports.getAllUserEvents = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.events.eventsId"
    );
    let eventList = user.userData.events.map(function (e) {
      return e.eventsId;
    });
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      events: eventList,
    });
  } catch (err) {
    console.log(err);
    res.musicRoomMessage = err.message;
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
  next();
};

async function addVotedTracksInArr(req, event) {
  let user = await User.findOne({ _id: getUserIdFromToken(req) });
  if (!user) throw new Error("Error: Invalid user id!");
  let eventIdx = user.userData.events
    .map(function (e) {
      return e.eventsId;
    })
    .indexOf(event._id);
  if (eventIdx == -1 && event.publicFlag == false)
    throw new Error("User cannot access private event!");
  event.tracksInfo.forEach((element) => {
    if (eventIdx == -1) {
      element.userVote = false;
    } else if (
      user.userData.events[eventIdx].songIdVotes.indexOf(element.trackId) == -1
    ) {
      element.userVote = false;
    } else {
      element.userVote = true;
    }
  });
  return event;
}

exports.getSortedTrackList = async (req, res, next) => {
  try {
    let event = await Event.findOne({ _id: req.params.eventId });
    if (!event) throw new Error("Invalid event id!");
    event = event.toObject();
    event.tracksInfo.sort((a, b) => {
      return b.votesNumber - a.votesNumber;
    });
    event = await addVotedTracksInArr(req, event);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      tracks: event.tracksInfo,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    if (err.message == "Invalid event id!") {
      res.status(400).json({
        code: "0",
        message: err.message,
      });
    } else {
      console.log(err);
      res.status(500).json({
        code: "0",
        message: "Internal error!",
      });
    }
  }
  next();
};

async function addEventToUserData(userId, event) {
  let user = await User.findOne({ _id: userId });

  if (!user) throw new Error("Invalid user id!");
  if (
    user.userData.events
      .map(function (e) {
        return e.eventsId;
      })
      .indexOf(event._id) != -1
  )
    throw new Error("User has already joined event!");
  user.userData.events.push({
    eventsId: event._id,
  });
  await user.save();
}

async function addUserToEvent(userId, eventId, userAccess, userRights) {
  let event = await Event.findOne({ _id: eventId });
  let user = await User.findOne({ _id: userId });

  if (!event) throw new Error("Invalid event id!");
  if (event.publicFlag == false && userAccess != 2)
    throw new Error("Cannot add user to private event!");
  if ((userRights == "superUser" || userRights == "admin") && userAccess != 2)
    throw new Error("Error: Invalid user Access!");
  if (!user) throw new Error("Invalid user id!");
  if ((await getUserEventAccess(userId, eventId)) != -1)
    throw new Error("User has already joined event!");
  event.guestsInfo.push({
    userId: userId,
    right: userRights,
  });
  event.guestsNumber++;
  await event.save();
  await addEventToUserData(userId, event);
}

function parseCreateEventArg(req) {
  if (!req.body.name || !/^[a-z0-9éèàêô,'! -]+$/i.test(req.body.name))
    throw new Error("Invalid name format!");
  else if (
    req.body.visibility &&
    req.body.visibility != "public" &&
    req.body.visibility != "private"
  )
    throw new Error("Invalid visibility format!");
  else if (
    req.body.votingPrerequisites &&
    req.body.votingPrerequisites != "true" &&
    req.body.votingPrerequisites != "false"
  )
    throw new Error("Invalid votingPrerequisites format!");
  else if (
    req.body.physicalEvent &&
    req.body.physicalEvent != "true" &&
    req.body.physicalEvent != "false"
  )
    throw new Error("Invalid physicalEvent format!");
  else if (req.body.musicalStyle) {
    let musicalPrefArr = req.body.musicalStyle.split(",");
    for (let i = 0; i < musicalPrefArr.length; i++) {
      for (let j = 0; j < musicalStylesAllowed.length; j++) {
        if (musicalPrefArr[i] == musicalStylesAllowed[j]) break;
        if (j == musicalStylesAllowed.length - 1)
          throw new Error("Invalid musical preferences!");
      }
    }
    req.body.musicalPreferences = musicalPrefArr;
  }
  if (req.body.physicalEvent && req.body.physicalEvent == "true") {
    if (!req.body.place || !/^[a-zéèàêô0-9,' -]+$/i.test(req.body.place))
      throw new Error("Invalid place format!");
    else if (
      !req.body.beginDate ||
      !/(^\d{4}-([0]\d|1[0-2])-([0-2]\d|3[01])$)|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/.test(
        req.body.beginDate
      )
    )
      throw new Error("Invalid beginDate format!");
    else if (
      !req.body.endDate ||
      !/(^\d{4}-([0]\d|1[0-2])-([0-2]\d|3[01])$)|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/.test(
        req.body.endDate
      )
    )
      throw new Error("Invalid endDate format!");
  }
}

function parseCreateEventErrors(res, err) {
  if (err.message == "Invalid name format!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid visibility format!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid votingPrerequisites format!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "Invalid physicalEvent format!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (err.message == "Invalid place format!") {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "Cannot find place location!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else if (err.message == "Invalid beginDate format!") {
    res.status(400).json({
      code: "6",
      message: err.message,
    });
  } else if (err.message == "Invalid endDate format!") {
    res.status(400).json({
      code: "7",
      message: err.message,
    });
  } else if (err.message == "End date must be after begin date!") {
    res.status(400).json({
      code: "8",
      message: err.message,
    });
  } else if (err.message == "Invalid musical preferences!") {
    res.status(400).json({
      code: "9",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

function copyBodyParamsToPhysicalEvent(req) {
  let event = new Event({
    name: req.body.name,
    creator: getUserIdFromToken(req),
    status: "notStarted",
    musicalStyle: req.body.musicalStyle,
    place: req.body.place,
    beginDate: req.body.beginDate,
    endDate: req.body.endDate,
  });
  event.geoLoc.lat = req.body.lat;
  event.geoLoc.long = req.body.long;
  event.beginDate -= 3600000;
  event.endDate -= 3600000;
  return event;
}

function copyBodyParamsToNumericalEvent(req) {
  let event = new Event({
    name: req.body.name,
    creator: getUserIdFromToken(req),
    status: "notStarted",
    musicalStyle: req.body.musicalStyle,
  });
  return event;
}

async function createEventFromBody(req) {
  let event;

  if (req.body.physicalEvent == "true") {
    event = copyBodyParamsToPhysicalEvent(req);
    if (event.endDate <= event.beginDate)
      throw new Error("End date must be after begin date!");
  } else event = copyBodyParamsToNumericalEvent(req);
  if (req.body.visibility && req.body.visibility == "private")
    event.publicFlag = false;
  if (req.body.physicalEvent && req.body.physicalEvent == "true")
    event.physicalEvent = true;
  if (req.body.votingPrerequisites && req.body.votingPrerequisites == "true")
    event.votingPrerequisites = true;
  await event.save();
  await addUserToEvent(getUserIdFromToken(req), event._id, 2, "admin");
  event = await Event.findOne({ _id: event._id });
  if (!event) throw new Error("Error: Invalid event id!");
  return event;
}

async function convertAddressToGeoLoc(req) {
  const { data } = await axios({
    url: "https://nominatim.openstreetmap.org/search?",
    method: "get",
    params: {
      q: req.body.place,
      format: "json",
    },
  });
  if (!data[0]) throw new Error("Cannot find place location!");
  req.body.lat = data[0].lat;
  req.body.long = data[0].lon;
}

exports.createEvent = async (req, res, next) => {
  try {
    parseCreateEventArg(req);
    if (req.body.physicalEvent == "true") await convertAddressToGeoLoc(req);
    const event = await createEventFromBody(req);
    res.musicRoomMessage = "Ok";
    res.status(201).json({
      code: "0",
      event: event,
    });
    req.params.eventId = event._id;
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseCreateEventErrors(res, err);
  }
  next();
};

function parseSetStatusEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  if (
    !req.body.eventStatus ||
    (req.body.eventStatus != "notStarted" &&
      req.body.eventStatus != "started" &&
      req.body.eventStatus != "terminated")
  )
    throw new Error("Invalid event status!");
}

function parseSetStatusEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid event status!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "User should be admin to set event status!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else {
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.setEventStatus = async (req, res, next) => {
  try {
    parseSetStatusEventArg(req);
    if (
      (await getUserEventAccess(getUserIdFromToken(req), req.params.eventId)) !=
      2
    )
      throw new Error("User should be admin to set event status!");
    let event = await Event.findOne({ _id: req.params.eventId });
    if (!event) throw new Error("Error: Invalid eventId!");
    event.status = req.body.eventStatus;
    await event.save();
    res.musicRoomMessage = "Ok";
    res.status(201).json({
      code: "0",
      message: "Successfully updated event status!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseSetStatusEventErrors(res, err);
  }
  next();
};

function parseJoinEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Cannot add user to private event!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "User has already joined event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

function parseJoinEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
}

exports.joinEvent = async (req, res, next) => {
  try {
    parseJoinEventArg(req);
    await addUserToEvent(req.params.userId, req.params.eventId, 0, "guest");
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Successfully joined event!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseJoinEventErrors(res, err);
  }
  next();
};

function parseLeaveEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
}

async function deleteEventFromUserData(userId, eventId) {
  let user = await User.findOne({ _id: userId });

  if (!user) throw new Error("Invalid user id!");
  let eventPos = user.userData.events
    .map(function (e) {
      return e.eventsId;
    })
    .indexOf(eventId);
  if (eventPos == -1) throw new Error("Invalid event id!");
  user.userData.events.splice(eventPos, 1);
  await user.save();
}

async function deleteUserFromEvent(userId, eventId) {
  let event = await Event.findOne({ _id: eventId });

  if (!event) throw new Error("Invalid event id!");
  let userPos = event.guestsInfo
    .map(function (e) {
      return e.userId;
    })
    .indexOf(userId);
  if (userPos == -1) throw new Error("User is not in the event!");
  event.guestsInfo.splice(userPos, 1);
  event.guestsNumber--;
  await event.save();
  await deleteEventFromUserData(userId, eventId);
}

async function getNumberOfEventAdmin(eventId) {
  let event = await Event.findOne({ _id: eventId });

  if (!event) throw new Error("Invalid event id!");
  usersRights = event.guestsInfo.map(function (e) {
    return e.right;
  });
  let nbAdmin = 0;
  let idx = usersRights.indexOf("admin");
  while (idx != -1) {
    idx = usersRights.indexOf("admin", idx + 1);
    nbAdmin++;
  }
  return nbAdmin;
}

function parseLeaveEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Admin user cannot leave the event!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "User is not in the event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.leaveEvent = async (req, res, next) => {
  try {
    parseLeaveEventArg(req);
    if (
      (await getUserEventAccess(req.params.userId, req.params.eventId)) == 2
    ) {
      if ((await getNumberOfEventAdmin(req.params.eventId)) == 1)
        throw new Error("Admin user cannot leave the event!");
    }
    await deleteUserFromEvent(req.params.userId, req.params.eventId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Event left successfully!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseLeaveEventErrors(res, err);
  }
  next();
};

function parseInviteFriendErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Cannot invite yourself to event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (
    err.message == "User should be admin to invite friend to private event!"
  ) {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (
    err.message == "Users must be friends to invite each other to the event!"
  ) {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (
    err.message == "Friend already has a pending invitation for this event!"
  ) {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else if (err.message == "Friend has already joined event!") {
    res.status(400).json({
      code: "6",
      message: err.message,
    });
  } else if (err.message == "Invalid friend right!") {
    res.status(400).json({
      code: "7",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

function parseInviteFriendEventArg(req) {
  if (
    !req.params.friendId ||
    req.params.friendId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.friendId)
  )
    throw new Error("Invalid friend id!");
  else if (req.params.friendId == req.params.userId)
    throw new Error("Cannot invite yourself to event!");
  else if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (
    req.body.friendRight &&
    req.body.friendRight != "guest" &&
    req.body.friendRight != "superUser" &&
    req.body.friendRight != "admin"
  )
    throw new Error("Invalid friend right!");
}

function getUserEventAccess_noFind(userId, event) {
  if (!event) throw new Error("Invalid event id!");
  const userPos = event.guestsInfo
    .map(function (e) {
      return e.userId.toString();
    })
    .indexOf(userId);
  if (userPos == -1) return -1;
  else if (event.guestsInfo[userPos].right == "guest") return 0;
  else if (event.guestsInfo[userPos].right == "superUser") return 1;
  else if (event.guestsInfo[userPos].right == "admin") return 2;
  else throw new Error("Error: Invalid event user right!");
}

async function getUserEventAccess(userId, eventId) {
  let event = await Event.findOne({ _id: eventId });

  if (!event) throw new Error("Invalid event id!");
  const userPos = event.guestsInfo
    .map(function (e) {
      return e.userId;
    })
    .indexOf(userId);
  if (userPos == -1) return -1;
  else if (event.guestsInfo[userPos].right == "guest") return 0;
  else if (event.guestsInfo[userPos].right == "superUser") return 1;
  else if (event.guestsInfo[userPos].right == "admin") return 2;
  else throw new Error("Error: Invalid event user right!");
}

async function inviteFriendToEvent(
  userId,
  friendId,
  eventId,
  userAccess,
  friendRight
) {
  let event = await Event.findOne({ _id: eventId });
  let friend = await User.findOne({ _id: friendId });

  if (!event) throw new Error("Invalid event id!");
  if (event.publicFlag == false && userAccess != 2)
    throw new Error("User should be admin to invite friend to private event!");
  if (!friend) throw new Error("Invalid friend id!");
  if (friend.userData.friendsId.indexOf(userId) == -1)
    throw new Error("Users must be friends to invite each other to the event!");
  if (userAccess < 2 && friendRight && friendRight != "guest")
    throw new Error("Invalid friend right!");
  if (!friendRight) friendRight = "guest";
  if (
    friend.userData.notifications.eventsInvitations
      .map(function (e) {
        return e.event;
      })
      .indexOf(eventId) != -1
  )
    throw new Error("Friend already has a pending invitation for this event!");
  if (
    friend.userData.events
      .map(function (e) {
        return e.eventsId;
      })
      .indexOf(eventId) != -1
  )
    throw new Error("Friend has already joined event!");
  friend.userData.notifications.eventsInvitations.push({
    event: eventId,
    userRight: friendRight,
    friend: userId,
    date: Date.now(),
  });
  await friend.save();
}

exports.inviteFriend = async (req, res, next) => {
  try {
    parseInviteFriendEventArg(req);
    let userAccess = await getUserEventAccess(
      req.params.userId,
      req.params.eventId
    );
    await inviteFriendToEvent(
      req.params.userId,
      req.params.friendId,
      req.params.eventId,
      userAccess,
      req.body.friendRight
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Friend has been successfully invited to the event!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseInviteFriendErrors(res, err);
  }
  next();
};

function parseAcceptInvitationEventErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Cannot accept invitation from yourself!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "There is no pending invitation from this user!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (err.message == "Cannot add user to private event!") {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "User has already joined event!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

async function acceptInvitationToEvent(
  userId,
  friendId,
  eventId,
  friendAccess
) {
  let friend = await User.findOne({ _id: friendId });
  let event = await Event.findOne({ _id: eventId });
  let user = await User.findOne({ _id: userId });

  if (!user) throw new Error("Error: Invalid user id!");
  if (!friend) throw new Error("Invalid friend id!");
  if (!event) throw new Error("Invalid event id!");
  let eventInvitationIdx = user.userData.notifications.eventsInvitations
    .map(function (e) {
      return e.event;
    })
    .indexOf(eventId);
  if (
    eventInvitationIdx == -1 ||
    user.userData.notifications.eventsInvitations[eventInvitationIdx].friend !=
      friendId
  )
    throw new Error("There is no pending invitation from this user!");
  let userRight =
    user.userData.notifications.eventsInvitations[eventInvitationIdx].userRight;
  await addUserToEvent(userId, eventId, friendAccess, userRight);
  user = await User.findOne({ _id: userId });
  if (!user) throw new Error("Error: Invalid user id!");
  user.userData.notifications.eventsInvitations.splice(eventInvitationIdx, 1);
  await user.save();
}

function parseAcceptInvitationEventArg(req) {
  if (
    !req.params.friendId ||
    req.params.friendId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.friendId)
  )
    throw new Error("Invalid friend id!");
  else if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (req.params.userId == req.params.friendId)
    throw new Error("Cannot accept invitation from yourself!");
}

exports.acceptInvitation = async (req, res, next) => {
  try {
    parseAcceptInvitationEventArg(req);
    let friendAccess = await getUserEventAccess(
      req.params.friendId,
      req.params.eventId
    );
    await acceptInvitationToEvent(
      req.params.userId,
      req.params.friendId,
      req.params.eventId,
      friendAccess
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Invitation to event has been accepted!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseAcceptInvitationEventErrors(res, err);
  }
  next();
};

async function refuseInvitationToEvent(userId, eventId, friendId) {
  let user = await User.findOne({ _id: userId });
  let friend = await User.findOne({ _id: friendId });
  let event = await Event.findOne({ _id: eventId });

  if (!user) throw new Error("Error: Invalid user id!");
  if (!friend) throw new Error("Invalid friend id!");
  if (!event) throw new Error("Invalid event id!");
  let eventIdx = user.userData.notifications.eventsInvitations
    .map(function (e) {
      return e.event;
    })
    .indexOf(eventId);
  if (
    eventIdx == -1 ||
    user.userData.notifications.eventsInvitations[eventIdx].friend != friendId
  )
    throw new Error("No pending invitation from this user to event!");
  user.userData.notifications.eventsInvitations.splice(eventIdx, 1);
  await user.save();
}

function parseRefuseInvitationEventErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "No pending invitation from this user to event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.refuseInvitation = async (req, res, next) => {
  try {
    parseAcceptInvitationEventArg(req);
    await refuseInvitationToEvent(
      req.params.userId,
      req.params.eventId,
      req.params.friendId
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Event invitations has been deleted from user notifications!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseRefuseInvitationEventErrors(res, err);
  }
  next();
};

function parseDeleteEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
}

async function deleteAllUsersFromEvent(eventId) {
  let event = await Event.findOne({ _id: eventId });

  if (!event) throw new Error("Invalid event id!");
  for (let i = 0; i < event.guestsInfo.length; i++) {
    await deleteEventFromUserData(event.guestsInfo[i].userId, eventId);
  }
  await Event.deleteOne({ _id: eventId });
}

function parseDeleteEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "User should be admin to delete the event!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.deleteEvent = async (req, res, next) => {
  try {
    parseDeleteEventArg(req);
    if (
      (await getUserEventAccess(getUserIdFromToken(req), req.params.eventId)) !=
      2
    )
      throw new Error("User should be admin to delete the event!");
    await deleteAllUsersFromEvent(req.params.eventId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Event successfully deleted!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseDeleteEventErrors(res, err);
  }
  next();
};

function parseAddTrackToEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (!req.params.trackId) throw new Error("Invalid track id!");
  else if (!/^[0-9]+$/.test(req.body.trackDuration)) {
    throw new Error("Invalid track duration");
  }
}

async function findTrackInEvent(eventId, trackId) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  return event.tracksInfo
    .map(function (e) {
      return e.trackId;
    })
    .indexOf(trackId);
}

function sortTrackInEvent(event) {
  event.tracksInfo.sort((a, b) => {
    return b.votesNumber - a.votesNumber;
  });
  for (let i = 0; i < event.tracksInfo.length; i++) {
    if (event.tracksInfo[i].timeBeginListening.getTime() != 0) {
      if (i != 0) {
        let tmpTrack = event.tracksInfo[i];
        event.tracksInfo.splice(i, 1);
        event.tracksInfo.unshift(tmpTrack);
      }
      break;
    }
  }
}

async function addTrackToEventData(eventId, trackId, trackDuration) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  if ((await findTrackInEvent(eventId, trackId)) != -1)
    throw new Error("The track has already been added to the event!");
  event.tracksInfo.push({
    trackId: trackId,
    trackDuration: parseInt(trackDuration, 10),
    timeBeginListening: 0,
    votesNumber: 0,
  });
  sortTrackInEvent(event);
  await event.save();
}

function parseAddTrackToEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid track id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "User should be admin to add track to the event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "The track has already been added to the event!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

function getUserIdFromToken(req) {
  const token = req.headers.authorization.split(" ")[1];
  const decodedToken = jwt.verify(token, "RANDOM_TOKEN_SECRET");
  return decodedToken.userId;
}

exports.getUserIdFromToken = getUserIdFromToken;

exports.addTrackToEvent = async (req, res, next) => {
  try {
    parseAddTrackToEventArg(req);
    if (
      (await getUserEventAccess(getUserIdFromToken(req), req.params.eventId)) !=
      2
    )
      throw new Error("User should be admin to add track to the event!");
    await addTrackToEventData(
      req.params.eventId,
      req.params.trackId,
      req.body.trackDuration
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Track successfully added to the event!",
    });
    next();
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseAddTrackToEventErrors(res, err);
  }
  next();
};

function parseDeleteTrackFromEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (!req.params.trackId)
    //Have to check what is the Spotify trackId format. And if backend can do a validation of track existence in spotify. ()
    throw new Error("Invalid track id!");
}

async function deleteTrackFromUserData(eventId, trackId) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  for (let i = 0; i < event.guestsInfo.length; i++) {
    let user = await User.findOne({ _id: event.guestsInfo[i].userId });
    if (!user) throw new Error("Error: An user should have been found!");
    let eventIndex = user.userData.events
      .map(function (e) {
        return e.eventsId;
      })
      .indexOf(eventId);
    if (eventIndex == -1)
      throw new Error("Error: An event should have been found!");
    let trackIndex =
      user.userData.events[eventIndex].songIdVotes.indexOf(trackId);
    if (trackIndex != -1) {
      user.userData.events[eventIndex].songIdVotes.splice(trackIndex, 1);
      await user.save();
    }
  }
}

async function deleteTrackFromEventData(eventId, trackId) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  let trackIndex = event.tracksInfo
    .map(function (e) {
      return e.trackId;
    })
    .indexOf(trackId);
  if (trackIndex == -1) throw new Error("The track is not in the event!");
  event.tracksInfo.splice(trackIndex, 1);
  await event.save();
  await deleteTrackFromUserData(eventId, trackId);
}

function parseDeleteTrackFromEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "The track is not in the event!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (
    err.message == "User should be admin to delete track from the event!"
  ) {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.deleteTrackFromEvent = async (req, res, next) => {
  try {
    parseDeleteTrackFromEventArg(req);
    if (
      (await getUserEventAccess(getUserIdFromToken(req), req.params.eventId)) !=
      2
    )
      throw new Error("User should be admin to delete track from the event!");
    await deleteTrackFromEventData(req.params.eventId, req.params.trackId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Track successfully deleted from the event!",
    });
    next();
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseDeleteTrackFromEventErrors(res, err);
  }
  next();
};

function parseVoteTrackEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid track id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid coordinates format!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (
    err.message == "User should join event before voting for tracks!"
  ) {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (
    err.message ==
    "User should get special right to vote for tracks in this event!"
  ) {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "User must be located at the event to vote!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else if (err.message == "Event must have started before user can vote!") {
    res.status(400).json({
      code: "6",
      message: err.message,
    });
  } else if (err.message == "Event is terminated!") {
    res.status(400).json({
      code: "7",
      message: err.message,
    });
  } else if (err.message == "Track is not in the event!") {
    res.status(400).json({
      code: "8",
      message: err.message,
    });
  } else if (err.message == "User has already voted for this track!") {
    res.status(400).json({
      code: "9",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

function parseVoteTrackEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (!req.params.trackId) throw new Error("Invalid track id!");
  else if (
    req.body.lat &&
    !/^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$/.test(req.body.lat)
  )
    throw new Error("Invalid coordinates format!");
  else if (
    req.body.long &&
    !/^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/.test(req.body.long)
  )
    throw new Error("Invalid coordinates format!");
}

async function addTrackVoteToUserData(userId, eventId, trackId) {
  let user = await User.findOne({ _id: userId });
  if (!user) throw new Error("Invalid user id!");
  let eventPos = user.userData.events
    .map(function (e) {
      return e.eventsId;
    })
    .indexOf(eventId);
  if (eventPos == -1)
    throw new Error("User should join event before voting for tracks!");
  if (user.userData.events[eventPos].songIdVotes.indexOf(trackId) != -1)
    throw new Error("User has already voted for this track!");
  user.userData.events[eventPos].songIdVotes.push(trackId);
  await user.save();
}

async function addTrackVoteToEventData(eventId, userId, trackId) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  let trackIndex = await findTrackInEvent(eventId, trackId);
  if (trackIndex == -1) throw new Error("Track is not in the event!");
  await addTrackVoteToUserData(userId, eventId, trackId);
  event.tracksInfo[trackIndex].votesNumber++;
  sortTrackInEvent(event);
  await event.save();
}

async function getUserDistanceFromEvent(req) {
  let event = await Event.findOne({ _id: req.params.eventId });

  if (!event) throw new Error("Invalid event id!");
  if (!req.body.lat || !req.body.long)
    throw new Error("Invalid coordinates format!");
  if (!event.geoLoc.lat || !event.geoLoc.long)
    throw new Error("Error: Invalid event coordinates format!");
  let lat1 = event.geoLoc.lat;
  let lon1 = event.geoLoc.long;
  let lat2 = req.body.lat;
  let lon2 = req.body.long;

  var p = 0.017453292519943295;
  var c = Math.cos;
  var a =
    0.5 -
    c((lat2 - lat1) * p) / 2 +
    (c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p))) / 2;

  return 12742 * Math.asin(Math.sqrt(a));
}

async function checkUserVotingPrerequisitesEvent(eventId, userId, req) {
  let userRight = await getUserEventAccess(userId, eventId);

  if (userRight == -1)
    throw new Error("User should join event before voting for tracks!");
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  if (event.votingPrerequisites && userRight < 1)
    throw new Error(
      "User should get special right to vote for tracks in this event!"
    );
  if (event.status != "started") {
    throw new Error("Event should start before participants can vote!");
  }
  if (event.physicalEvent) {
    if ((await getUserDistanceFromEvent(req)) > 0.25)
      throw new Error("User must be located at the event to vote!");
    if (!event.beginDate || !event.endDate)
      throw new Error("Error: Invalid event date format!");
    if (Date.now() < event.beginDate)
      throw new Error("Event must have started before user can vote!");
    if (Date.now() > event.endDate) throw new Error("Event is terminated!");
  }
}

exports.voteTrackEvent = async (req, res, next) => {
  try {
    parseVoteTrackEventArg(req);
    await checkUserVotingPrerequisitesEvent(
      req.params.eventId,
      getUserIdFromToken(req),
      req
    );
    await addTrackVoteToEventData(
      req.params.eventId,
      getUserIdFromToken(req),
      req.params.trackId
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Track successfully vote!",
    });
    next();
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseVoteTrackEventErrors(res, err);
  }
  next();
};

function parseUnvoteTrackEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (!req.params.trackId)
    //Have to check what is the Spotify trackId format. And if backend can do a validation of track existence in spotify. ()
    throw new Error("Invalid track id!");
  else if (
    req.body.lat &&
    !/^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)$/.test(req.body.lat)
  )
    throw new Error("Invalid coordinates format!");
  else if (
    req.body.long &&
    !/^[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/.test(req.body.long)
  )
    throw new Error("Invalid coordinates format!");
}

async function deleteTrackVoteToUserData(userId, eventId, trackId) {
  let user = await User.findOne({ _id: userId });
  if (!user) throw new Error("Invalid user id!");
  let eventPos = user.userData.events
    .map(function (e) {
      return e.eventsId;
    })
    .indexOf(eventId);
  if (eventPos == -1)
    throw new Error("User should join event before voting for tracks!");
  let trackIdx = user.userData.events[eventPos].songIdVotes.indexOf(trackId);
  if (trackIdx == -1)
    throw new Error("User did not vote for this track before!");
  user.userData.events[eventPos].songIdVotes.splice(trackIdx, 1);
  await user.save();
}

async function deleteTrackVoteToEventData(eventId, userId, trackId) {
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  let trackIndex = await findTrackInEvent(eventId, trackId);
  if (trackIndex == -1) throw new Error("Track is not in the event!");
  await deleteTrackVoteToUserData(userId, eventId, trackId);
  event.tracksInfo[trackIndex].votesNumber--;
  sortTrackInEvent(event);
  await event.save();
}

function parseUnvoteTrackEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid track id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid coordinates format!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (
    err.message == "User should join event before voting for tracks!"
  ) {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (
    err.message ==
    "User should get special right to vote for tracks in this event!"
  ) {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "User must be located at the event to vote!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else if (err.message == "Event must have started before user can vote!") {
    res.status(400).json({
      code: "6",
      message: err.message,
    });
  } else if (err.message == "Event is terminated!") {
    res.status(400).json({
      code: "7",
      message: err.message,
    });
  } else if (err.message == "Track is not in the event!") {
    res.status(400).json({
      code: "8",
      message: err.message,
    });
  } else if (err.message == "User did not vote for this track before!") {
    res.status(400).json({
      code: "9",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.unvoteTrackEvent = async (req, res, next) => {
  try {
    parseUnvoteTrackEventArg(req);
    await checkUserVotingPrerequisitesEvent(
      req.params.eventId,
      getUserIdFromToken(req),
      req
    );
    await deleteTrackVoteToEventData(
      req.params.eventId,
      getUserIdFromToken(req),
      req.params.trackId
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Track vote successfully deleted!",
    });
    next();
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseUnvoteTrackEventErrors(res, err);
  }
  next();
};

function parseUpdateEventArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (req.body.name && !/^[a-z0-9éèàêô,'! -]+$/i.test(req.body.name))
    throw new Error("Invalid name format!");
  else if (
    req.body.visibility &&
    req.body.visibility != "public" &&
    req.body.visibility != "private"
  )
    throw new Error("Invalid visibility format!");
  else if (
    req.body.votingPrerequisites &&
    req.body.votingPrerequisites != "true" &&
    req.body.votingPrerequisites != "false"
  )
    throw new Error("Invalid votingPrerequisites format!");
  else if (
    req.body.physicalEvent &&
    req.body.physicalEvent != "true" &&
    req.body.physicalEvent != "false"
  )
    throw new Error("Invalid physicalEvent format!");
  else if (req.body.musicalStyle) {
    let musicalPrefArr = req.body.musicalStyle.split(",");
    for (let i = 0; i < musicalPrefArr.length; i++) {
      for (let j = 0; j < musicalStylesAllowed.length; j++) {
        if (musicalPrefArr[i] == musicalStylesAllowed[j]) break;
        if (j == musicalStylesAllowed.length - 1)
          throw new Error("Invalid musical preferences!");
      }
    }
    req.body.musicalPreferences = musicalPrefArr;
  } else if (
    req.body.status &&
    req.body.status != "notStarted" &&
    req.body.status != "started" &&
    req.body.status != "terminated"
  ) {
    throw new Error("Invalid status format!");
  }
  if (req.body.physicalEvent && req.body.physicalEvent == "true") {
    if (!req.body.place || !/^[a-zéèàêô0-9,' -]+$/i.test(req.body.place)) {
      throw new Error("Invalid place format!");
    } else if (
      !req.body.beginDate ||
      !/(^\d{4}-([0]\d|1[0-2])-([0-2]\d|3[01])$)|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/.test(
        req.body.beginDate
      )
    )
      throw new Error("Invalid beginDate format!");
    else if (
      !req.body.endDate ||
      !/(^\d{4}-([0]\d|1[0-2])-([0-2]\d|3[01])$)|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/.test(
        req.body.endDate
      )
    )
      throw new Error("Invalid endDate format!");
  }
}

function parseUpdateEventErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid name format!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid visibility format!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "Invalid votingPrerequisites format!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (err.message == "Invalid physicalEvent format!") {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "Invalid place format!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else if (err.message == "Cannot find place location!") {
    res.status(400).json({
      code: "6",
      message: err.message,
    });
  } else if (err.message == "Invalid beginDate format!") {
    res.status(400).json({
      code: "7",
      message: err.message,
    });
  } else if (err.message == "Invalid endDate format!") {
    res.status(400).json({
      code: "8",
      message: err.message,
    });
  } else if (err.message == "End date must be after begin date!") {
    res.status(400).json({
      code: "9",
      message: err.message,
    });
  } else if (err.message == "Invalid musical preferences!") {
    res.status(400).json({
      code: "10",
      message: err.message,
    });
  } else if (err.message == "Invalid status format!") {
    res.status(400).json({
      code: "11",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

async function updateEventFromArg(req) {
  let event = await Event.findOne({ _id: req.params.eventId });

  if (!event) throw new Error("Invalid event id!");
  if (req.body.name) event.name = req.body.name;
  if (req.body.visibility)
    event.publicFlag = req.body.visibility == "public" ? true : false;
  if (req.body.votingPrerequisites)
    event.votingPrerequisites = req.body.votingPrerequisites;
  if (req.body.musicalStyle) event.musicalStyle = req.body.musicalStyle;
  if (req.body.physicalEvent && req.body.physicalEvent == "false") {
    if (req.body.status) {
      event.status = req.body.status;
    }
    event.physicalEvent = false;
    event.place = undefined;
    event.geoLoc = undefined;
    event.beginDate = undefined;
    event.endDate = undefined;
  }
  if (req.body.physicalEvent && req.body.physicalEvent == "true") {
    await convertAddressToGeoLoc(req);
    event.physicalEvent = true;
    event.place = req.body.place;
    event.geoLoc.lat = req.body.lat;
    event.geoLoc.long = req.body.long;
    event.beginDate = req.body.beginDate;
    event.endDate = req.body.endDate;
    event.beginDate -= 3600000;
    event.endDate -= 3600000;
    if (event.endDate <= event.beginDate)
      throw new Error("End date must be after begin date!");
    await updateEventStatusIfNeeded(event);
  }
  event.save();
  return event;
}

exports.updateEvent = async (req, res, next) => {
  try {
    parseUpdateEventArg(req);
    let event = await updateEventFromArg(req);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      event: event,
    });
    next();
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseUpdateEventErrors(res, err);
  }
  next();
};

function parseChangeParticipantRightArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (
    !req.params.participantId ||
    req.params.participantId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.participantId)
  )
    throw new Error("Invalid participant id!");
  else if (
    !req.body.participantRight ||
    (req.body.participantRight != "delete" &&
      req.body.participantRight != "guest" &&
      req.body.participantRight != "superUser" &&
      req.body.participantRight != "admin")
  )
    throw new Error("Invalid participant right!");
  else if (req.params.userId == req.params.participantId)
    throw new Error("Cannot change user own right!");
}

function parseChangeParticipantRightErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid participant id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid participant right!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "Cannot change user own right!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (
    err.message == "User should be admin to change others participants right!"
  ) {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "Participant is not in the event!") {
    res.status(400).json({
      code: "5",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

async function changeParticipantRightInEvent(
  eventId,
  userId,
  participantId,
  participantRight
) {
  let participant = await User.findOne({ _id: participantId });
  if (!participant) throw new Error("Invalid participant id!");
  let event = await Event.findOne({ _id: eventId });
  if (!event) throw new Error("Invalid event id!");
  let participantIdx = event.guestsInfo
    .map(function (e) {
      return e.userId;
    })
    .indexOf(participantId);
  if (participantIdx == -1) throw new Error("Participant is not in the event!");
  if (participantRight == "delete")
    await deleteUserFromEvent(participantId, eventId);
  else event.guestsInfo[participantIdx].right = participantRight;
  await event.save();
}

exports.updateParticipantRight = async (req, res, next) => {
  try {
    parseChangeParticipantRightArg(req);
    if ((await getUserEventAccess(req.params.userId, req.params.eventId)) != 2)
      throw new Error(
        "User should be admin to change others participants right!"
      );
    await changeParticipantRightInEvent(
      req.params.eventId,
      req.params.userId,
      req.params.participantId,
      req.body.participantRight
    );
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Participant right successfully updated!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseChangeParticipantRightErrors(res, err);
  }
  next();
};

function parseDeleteParticipantArg(req) {
  if (
    !req.params.eventId ||
    req.params.eventId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.eventId)
  )
    throw new Error("Invalid event id!");
  else if (
    !req.params.participantId ||
    req.params.participantId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.participantId)
  )
    throw new Error("Invalid participant id!");
  else if (req.params.userId == req.params.participantId)
    throw new Error("Cannot delete yourself from event!");
}

function parseDeleteParticipantErrors(res, err) {
  if (err.message == "Invalid event id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid participant id!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Cannot delete yourself from event!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (
    err.message == "User should be admin to delete participants from event!"
  ) {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (err.message == "User is not in the event!") {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

exports.deleteParticipant = async (req, res, next) => {
  try {
    parseDeleteParticipantArg(req);
    if ((await getUserEventAccess(req.params.userId, req.params.eventId)) != 2)
      throw new Error(
        "User should be admin to delete participants from event!"
      );
    await deleteUserFromEvent(req.params.participantId, req.params.eventId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Participant successfully deleted from event!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseDeleteParticipantErrors(res, err);
  }
  next();
};
