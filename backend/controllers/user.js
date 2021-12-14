const { User } = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");

const CLIENT_ID =
  "856970011632-pvjlo12sq8ld2vltvbjbqjsoipmdhc19.apps.googleusercontent.com";

const musicalStylesAllowed = [
  "none",
  "blues",
  "country",
  "disco",
  "folk",
  "funk",
  "jazz",
  "raï",
  "rap",
  "raggae",
  "rock",
  "salsa",
  "soul",
  "techno",
];

exports.musicalStylesAllowed = musicalStylesAllowed;

function getUserIdFromToken(req) {
  const token = req.headers.authorization.split(" ")[1];
  const decodedToken = jwt.verify(token, "RANDOM_TOKEN_SECRET");
  return decodedToken.userId;
}

exports.getMyProfile = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: getUserIdFromToken(req) });
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      userProfile: user,
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

async function getUsersRelation(userId, targetId) {
  let targetUser = await User.findOne({ _id: targetId });

  if (!targetUser) throw new Error("Invalid profile id!");
  if (targetUser.userData.friendsId.indexOf(userId) != -1) return 1;
  return 0;
}

async function getRestrictedUserProfile(userId, targetId) {
  let user = await User.findOne({ _id: userId });
  let targetUser = await User.findOne({ _id: targetId })
    .select(
      "userInfo.firstName userInfo.lastName userInfo.pseudo\
		 userData.friendsId userData.playlists userData.events userInfo.musicalPreferences"
    )
    .populate("userData.friendsId", "userInfo.pseudo")
    .populate("userData.events.eventsId", "name publicFlag")
    .populate("userData.playlists.playlist", "name public");
  if (!user) throw new Error("Error: Invalid user id!");
  if (!targetUser) throw new Error("Invalid target user id!");
  targetUser = targetUser.toObject();
  targetUser.userData.events.forEach(function (v) {
    delete v._id;
    delete v.songIdVotes;
  });
  targetUser.userData.playlists.forEach(function (v) {
    delete v._id;
    delete v.playlistType;
  });
  for (let i = 0; i < targetUser.userData.events.length; i++) {
    if (targetUser.userData.events[i].eventsId.publicFlag == false) {
      if (
        user.userData.events
          .map(function (e) {
            return e.eventsId;
          })
          .indexOf(targetUser.userData.events[i].eventsId._id) == -1
      )
        targetUser.userData.events.splice(i--, 1);
    }
  }
  for (let i = 0; i < targetUser.userData.playlists.length; i++) {
    if (targetUser.userData.playlists[i].playlist.public == false) {
      if (
        user.userData.playlists
          .map(function (e) {
            return e.playlist;
          })
          .indexOf(targetUser.userData.playlists[i].playlist._id) == -1
      )
        targetUser.userData.playlists.splice(i--, 1);
    }
  }
  return targetUser;
}

async function getPublicUserProfile(userId, targetId) {
  let user = await User.findOne({ _id: userId });
  let targetUser = await User.findOne({ _id: targetId })
    .select(
      "userInfo.pseudo userData.events userData.playlists userInfo.musicalPreferences -_id"
    )
    .populate("userData.events.eventsId", "name publicFlag")
    .populate("userData.playlists.playlist", "name public");
  if (!targetUser) throw new Error("Invalid target user id!");
  if (!user) throw new Error("Error: Invalid user id!");
  targetUser = targetUser.toObject();
  targetUser.userData.events.forEach(function (v) {
    delete v._id;
    delete v.songIdVotes;
  });
  targetUser.userData.playlists.forEach(function (v) {
    delete v._id;
    delete v.playlistType;
  });
  for (let i = 0; i < targetUser.userData.events.length; i++) {
    if (targetUser.userData.events[i].eventsId.publicFlag == false) {
      if (
        user.userData.events
          .map(function (e) {
            return e.eventsId;
          })
          .indexOf(targetUser.userData.events[i].eventsId._id) == -1
      )
        targetUser.userData.events.splice(i--, 1);
    }
  }
  for (let i = 0; i < targetUser.userData.playlists.length; i++) {
    if (targetUser.userData.playlists[i].playlist.public == false) {
      if (
        user.userData.playlists
          .map(function (e) {
            return e.playlist;
          })
          .indexOf(targetUser.userData.playlists[i].playlist._id) == -1
      )
        targetUser.userData.playlists.splice(i--, 1);
    }
  }
  return targetUser;
}

function parseGetTargetUserProfileErrors(res, err) {
  if (err.message == "Invalid target user id!") {
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

exports.getTargetUserProfile = async (req, res, next) => {
  try {
    let targetUser = await User.findOne({ _id: req.params.targetUserId });
    let user = await User.findOne({ _id: req.params.userId });
    let returnedProfile;

    if (!targetUser) throw new Error("Invalid target user id!");
    if (!user) throw new Error("Error: Invalid user id!");
    if (await getUsersRelation(req.params.userId, req.params.targetUserId)) {
      returnedProfile = await getRestrictedUserProfile(
        req.params.userId,
        req.params.targetUserId
      );
      res.musicRoomMessage = "Ok";
      res.status(200).json({
        code: "1",
        targetUser: returnedProfile,
      });
    } else {
      returnedProfile = await getPublicUserProfile(
        req.params.userId,
        req.params.targetUserId
      );
      res.musicRoomMessage = "Ok";
      res.status(200).json({
        code: "0",
        targetUser: returnedProfile,
      });
    }
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseGetTargetUserProfileErrors(res, err);
  }
  next();
};

function parseUpdateUserInformationArg(req) {
  if (req.body.firstName && !/^[a-zéèê -]+$/i.test(req.body.firstName)) {
    throw new Error("Invalid firstName format!");
  } else if (req.body.lastName && !/^[a-zéèê -]+$/i.test(req.body.lastName)) {
    throw new Error("Invalid lastName format!");
  } else if (req.body.pseudo && !/^[a-z0-9]+$/i.test(req.body.pseudo)) {
    throw new Error("Invalid pseudo format!");
  } else if (
    req.body.birthDate &&
    !/(^\d{4}-([0]\d|1[0-2])-([0-2]\d|3[01])$)|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/.test(
      req.body.birthDate
    )
  ) {
    throw new Error("Invalid birthDate format!");
  } else if (req.body.musicalPreferences) {
    req.body.musicalPrefArr = req.body.musicalPreferences.split(",");
    for (let i = 0; i < req.body.musicalPrefArr.length; i++) {
      for (let j = 0; j < musicalStylesAllowed.length; j++) {
        if (req.body.musicalPrefArr[i] == musicalStylesAllowed[j]) break;
        if (j == musicalStylesAllowed.length - 1) {
          console.log("error");
          throw new Error("Invalid musical preferences!");
        }
      }
    }
  }
}

function parseUpdateUserInformationErrors(res, err) {
  if (err.message == "Invalid firstName format!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid lastName format!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (err.message == "Invalid pseudo format!") {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "Invalid birthDate format!") {
    res.status(400).json({
      code: "3",
      message: err.message,
    });
  } else if (err.message == "Invalid musical preferences!") {
    res.status(400).json({
      code: "4",
      message: err.message,
    });
  } else if (err.message == "Invalid pseudo format!") {
    res.status(400).json({
      code: "5",
      message: "Pseudo already exists!",
    });
  } else {
    console.log(err);
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
}

async function copyParamsToUserInfo(req, user) {
  if (req.body.firstName) user.userInfo.firstName = req.body.firstName;
  if (req.body.lastName) user.userInfo.lastName = req.body.lastName;
  if (req.body.pseudo) {
    if (req.body.pseudo != user.userInfo.pseudo) {
      let otherUser = await User.findOne({
        "userInfo.pseudo": req.body.pseudo,
      });
      if (otherUser)
        throw new Error(
          "Pseudo has already been used by another musicRoom user!"
        );
    }
    user.userInfo.pseudo = req.body.pseudo;
  }
  if (req.body.birthDate) user.userInfo.birthDate = req.body.birthDate;
  if (req.body.musicalPreferences != null) {
    if (req.body.musicalPreferences == "") {
      user.userInfo.musicalPreferences = [];
    } else {
      user.userInfo.musicalPreferences = req.body.musicalPreferences;
    }
  }
  await user.save();
}

exports.updateUserInformation = async (req, res, next) => {
  try {
    parseUpdateUserInformationArg(req);
    let user = await User.findOne({ _id: req.params.userId });
    if (!user) throw new Error("Error: Invalid user id!");
    await copyParamsToUserInfo(req, user);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: user,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseUpdateUserInformationErrors(res, err);
  }
  next();
};

function parseResetPasswordArg(req) {
  if (!req.body.currentPassword) throw new Error("Invalid current password!");
  else if (
    !req.body.newPassword ||
    req.body.newPassword.length < 5 ||
    !/^[a-z0-9éèàêô,'!@# -]+$/i.test(req.body.newPassword)
  )
    throw new Error("Invalid new password format!");
}

function parseResetPasswordErrors(res, err) {
  if (err.message == "Invalid current password!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "Invalid new password format!") {
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

exports.resetPassword = async (req, res, next) => {
  try {
    parseResetPasswordArg(req);
    let user = await User.findOne({ _id: req.params.userId });
    if (!user) throw new Error("Error: Invalid user id!");
    if (
      !(await bcrypt.compare(req.body.currentPassword, user.userInfo.password))
    )
      throw new Error("Invalid current password!");
    let newPassword = await bcrypt.hash(req.body.newPassword, 10);
    user.userInfo.password = newPassword;
    await user.save();
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Password successfully updated!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseResetPasswordErrors(res, err);
  }
  next();
};

async function verifyGoogleToken(req) {
  if (!req.body.token || !req.body.MusicRoom_ID)
    throw new Error("Missing token or MusicRoom_ID field!");
  const client = new OAuth2Client(CLIENT_ID);
  const ticket = await client
    .verifyIdToken({
      idToken: req.body.token,
      audience: req.body.MusicRoom_ID,
    })
    .catch((err) => {
      throw new Error("Auth with Google failed, invalid token or client id!");
    });
  return ticket.getPayload();
}

async function addGoogleEmailToSecondaryEmail(req) {
  let user = await User.findOne({ _id: req.params.userId });
  if (!user) throw new Error("Error: Invalid user id!");
  const payload = await verifyGoogleToken(req);
  user.userInfo.secondaryEmail = payload.email;
  await user.save();
  return user;
}

function parseAttachGoogleAccountArg(req) {
  if (!req.body.token || !req.body.MusicRoom_ID)
    throw new Error("Missing token or MusicRoom_ID field!");
}

function parseAttachGoogleAccountErrors(res, err) {
  console.log(err);
  if (err.message == "Missing token or MusicRoom_ID field!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (
    err.message == "Auth with Google failed, invalid token or client id!"
  ) {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else {
    res.status(500).json({
      code: "0",
      message: "Internal error",
    });
  }
}

exports.attachGoogleAccount = async (req, res, next) => {
  try {
    parseAttachGoogleAccountArg(req);
    let user = await addGoogleEmailToSecondaryEmail(req);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      user: user,
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseAttachGoogleAccountErrors(res, err);
  }
  next();
};
