const { User, ObjectMsg } = require("../models/User");
const socketIO = require("../server");
const eventCtrl = require("./event");

function sendMsg(ownerId, ownerPseudo, recipientId, content) {
  socketIO.io.sockets.in(recipientId).emit("receiveMsg", {
    ownerId: ownerId,
    ownerPseudo: ownerPseudo,
    content: content,
  });
}

async function receiveMsg(ownerId, ownerPseudo, recipientId, content) {
  sendMsg(ownerId, ownerPseudo, recipientId, content);
  let owner = await User.findOne({ _id: ownerId });
  let recipient = await User.findOne({ _id: recipientId });
  if (!owner) {
    throw new Error("Invalid ownerId");
  } else if (!recipient) {
    throw new Error("Invalid recipientId");
  }
  storeMsgInOwnerDB(owner, recipient, content);
  storeMsgInRecipientDB(owner, recipient, content);
}

exports.receiveMsg = receiveMsg;

async function storeMsgInOwnerDB(owner, recipient, content) {
  let discussionIdx = owner.userData.discussions
    .map(function (e) {
      return e.recipientId;
    })
    .indexOf(recipient._id);
  if (discussionIdx == -1) {
    owner.userData.discussions.unshift({ recipientId: recipient._id });
    discussionIdx = 0;
  }
  let newMessage = new ObjectMsg({
    content: content,
    ownerId: owner._id,
    date: Date.now(),
  });
  owner.userData.discussions[discussionIdx].messages.push(newMessage);
  owner.save();
}

async function storeMsgInRecipientDB(owner, recipient, content) {
  let discussionIdx = recipient.userData.discussions
    .map(function (e) {
      return e.recipientId;
    })
    .indexOf(owner._id);
  if (discussionIdx == -1) {
    recipient.userData.discussions.unshift({ recipientId: owner._id });
    discussionIdx = 0;
  }
  let newMessage = new ObjectMsg({
    content: content,
    ownerId: owner._id,
    date: Date.now(),
  });
  recipient.userData.discussions[discussionIdx].messages.push(newMessage);
  recipient.save();
}

exports.getAllMyDiscussions = async (req, res, next) => {
  try {
    let user = await User.findOne({
      _id: eventCtrl.getUserIdFromToken(req),
    }).populate("userData.discussions.recipientId", "userInfo.pseudo");
    if (!user) {
      throw new Error("Invalid userId!");
    }
    user = user.toObject();
    user.userData.discussions.forEach((element) => {
      let recipient = {
        id: element.recipientId._id,
        pseudo: element.recipientId.userInfo.pseudo,
      };
      element.recipient = recipient;
      delete element.recipientId;
      delete element._id;
    });
    res.musicRoomMessage = "Ok";
    res.status(200).json({
      code: "0",
      discussions: user.userData.discussions,
    });
  } catch (error) {
    res.musicRoomMessage = error.message;
    res.status(500).json({
      code: "0",
      message: "Internal error!",
    });
  }
  next();
};
