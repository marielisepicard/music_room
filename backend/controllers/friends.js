const { User } = require("../models/User");

exports.getUserFriendsList = async (req, res, next) => {
  try {
    let user = await User.findOne({ _id: req.params.userId }).populate(
      "userData.friendsId",
      "_id  userInfo.pseudo"
    );
    if (!user) throw new Error("Error: Invalid friend id!");
    let friends = [];
    for (friend of user.userData.friendsId) {
      friends.push({
        _id: friend._id,
        pseudo: friend.userInfo.pseudo,
      });
    }
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      friends: friends,
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

function parseDeleteFriendErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (
    err.message == "The friend ID specified does not match any of your friends!"
  ) {
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

function parseDeleteFriendArg(req) {
  if (
    !req.params.friendId ||
    req.params.friendId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.friendId)
  )
    throw new Error("Invalid friend id!");
}

async function deleteFriendFromUserData(userId, friendId) {
  let user = await User.findOne({ _id: userId });
  if (!user) throw new Error("Error: Invalid user!");
  if (!(await User.findOne({ _id: friendId })))
    throw new Error("Invalid friend id!");
  let friendIdx = user.userData.friendsId.indexOf(friendId);
  if (friendIdx == -1)
    throw new Error(
      "The friend ID specified does not match any of your friends!"
    );
  user.userData.friendsId.splice(friendIdx, 1);
  friendIdx = user.userData.discussions
    .map(function (e) {
      return e.recipientId;
    })
    .indexOf(friendId);
  if (friendIdx != -1) {
    user.userData.discussions.splice(friendIdx, 1);
  }
  await user.save();
}

exports.deleteFriend = async (req, res, next) => {
  try {
    parseDeleteFriendArg(req);
    await deleteFriendFromUserData(req.params.userId, req.params.friendId);
    await deleteFriendFromUserData(req.params.friendId, req.params.userId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Friend has been successfully deleted!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseDeleteFriendErrors(res, err);
  }
  next();
};

function parseInviteFriendArg(req) {
  if (
    !req.params.friendId ||
    req.params.friendId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.friendId)
  )
    throw new Error("Invalid friend id!");
  else if (req.params.userId == req.params.friendId)
    throw new Error("User cannot add himself as friend!");
}

function parseInviteFriendErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "User cannot add himself as friend!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (
    err.message == "User already has this friend in his friends list!"
  ) {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (
    err.message == "User already has a pending invitation with this friend!"
  ) {
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

async function sendInvitationToFriendData(req) {
  let user = await User.findOne({ _id: req.params.userId });
  if (!user) throw new Error("Error: Invalid user id!");
  let friend = await User.findOne({ _id: req.params.friendId });
  if (!friend) throw new Error("Invalid friend id!");
  let friendIdx = user.userData.friendsId.indexOf(req.params.friendId);
  if (friendIdx != -1)
    throw new Error("User already has this friend in his friends list!");
  if (
    friend.userData.notifications.friendsInvitations
      .map(function (e) {
        return e.user;
      })
      .indexOf(req.params.userId) != -1
  )
    throw new Error("User already has a pending invitation with this friend!");
  if (
    user.userData.notifications.friendsInvitations
      .map(function (e) {
        return e.user;
      })
      .indexOf(req.params.friendId) != -1
  )
    throw new Error("User already has a pending invitation with this friend!");
  friend.userData.notifications.friendsInvitations.push({
    user: req.params.userId,
    date: Date.now(),
  });
  await friend.save();
}

exports.invite = async (req, res, next) => {
  try {
    parseInviteFriendArg(req);
    await sendInvitationToFriendData(req);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Friend has been successfully invited!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseInviteFriendErrors(res, err);
  }
  next();
};

function parseAcceptInvitationArg(req) {
  if (
    !req.params.friendId ||
    req.params.friendId.length != 24 ||
    !/^[a-f0-9]+$/.test(req.params.friendId)
  )
    throw new Error("Invalid friend id!");
  else if (req.params.userId == req.params.friendId)
    throw new Error("User cannot add himself as friend!");
}

function parseAcceptInvitationErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "User cannot add himself as friend!") {
    res.status(400).json({
      code: "1",
      message: err.message,
    });
  } else if (
    err.message == "User already has this friend in his friends list!"
  ) {
    res.status(400).json({
      code: "2",
      message: err.message,
    });
  } else if (err.message == "There is no pending invitation from this user!") {
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

async function acceptInvitationFromUser(req) {
  let user = await User.findOne({ _id: req.params.userId });
  if (!user) throw new Error("Error: Invalid user id!");
  let friend = await User.findOne({ _id: req.params.friendId });
  if (!friend) throw new Error("Invalid friend id!");
  if (user.userData.friendsId.indexOf(req.params.friendId) != -1)
    throw new Error("User already has this friend in his friends list!");
  let friendIdx = user.userData.notifications.friendsInvitations
    .map(function (e) {
      return e.user;
    })
    .indexOf(req.params.friendId);
  if (friendIdx == -1)
    throw new Error("There is no pending invitation from this user!");
  friend.userData.friendsId.push(req.params.userId);
  user.userData.friendsId.push(req.params.friendId);
  user.userData.notifications.friendsInvitations.splice(friendIdx, 1);
  await user.save();
  await friend.save();
}

exports.acceptInvitation = async (req, res, next) => {
  try {
    parseAcceptInvitationArg(req);
    await acceptInvitationFromUser(req);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Invitation has been accepted!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseAcceptInvitationErrors(res, err);
  }
  next();
};

async function deleteInvitationFromUser(userId, friendId) {
  let user = await User.findOne({ _id: userId });
  let friend = await User.findOne({ _id: friendId });

  if (!user) throw new Error("Error:  Invalid user Id!");
  if (!friend) throw new Error("Invalid friend id!");
  let friendIdx = user.userData.notifications.friendsInvitations
    .map(function (e) {
      return e.user;
    })
    .indexOf(friendId);
  if (friendIdx == -1) throw new Error("No pending invitation from friend!");
  user.userData.notifications.friendsInvitations.splice(friendIdx);
  await user.save();
}

function parseRefuseInvitationErrors(res, err) {
  if (err.message == "Invalid friend id!") {
    res.status(400).json({
      code: "0",
      message: err.message,
    });
  } else if (err.message == "No pending invitation from friend!") {
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

exports.refuseInvitation = async (req, res, next) => {
  try {
    parseAcceptInvitationArg(req);
    await deleteInvitationFromUser(req.params.userId, req.params.friendId);
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      message: "Friend invitation has been refused successfully!",
    });
  } catch (err) {
    res.musicRoomMessage = err.message;
    parseRefuseInvitationErrors(res, err);
  }
  next();
};
