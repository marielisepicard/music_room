const express = require("express");
const userCtrl = require("../controllers/user");
const eventCtrl = require("../controllers/event");
const playlistCtrl = require("../controllers/playlist");
const friendCtrl = require("../controllers/friends");
const notificationCtrl = require("../controllers/notification");
const playerCtrl = require("../controllers/player");
const socketCtrl = require("../middleware/socketIO");
const searchCtrl = require("../controllers/search");
const auth = require("../middleware/auth");
const end = require("../middleware/end");
const logs = require("../middleware/logs");

const router = express.Router();

//----- User Informations ------//
router.put("/:userId", auth, userCtrl.updateUserInformation, logs, end);
router.post("/:userId/password", auth, userCtrl.resetPassword, logs, end);
router.get(
  "/:userId/targetUser/:targetUserId",
  auth,
  userCtrl.getTargetUserProfile,
  logs,
  end
);
router.post(
  "/:userId/attachGoogleAccount",
  auth,
  userCtrl.attachGoogleAccount,
  logs,
  end
);

//----- Vrac old roots  -----//
//Friends manager roots
router.get("/:userId/friends/", auth, friendCtrl.getUserFriendsList, logs, end);
router.delete(
  "/:userId/friends/:friendId",
  auth,
  friendCtrl.deleteFriend,
  logs,
  end
);
router.post(
  "/:userId/friends/:friendId/invite",
  auth,
  friendCtrl.invite,
  logs,
  end
);
router.post(
  "/:userId/friends/:friendId/acceptInvitation",
  auth,
  friendCtrl.acceptInvitation,
  logs,
  end
);
router.delete(
  "/:userId/friends/:friendId/refuseInvitation",
  auth,
  friendCtrl.refuseInvitation,
  logs,
  end
);

//----- Events requests ------//
router.get("/:userId/events", auth, eventCtrl.getAllUserEvents, logs, end);
router.get(
  "/:userId/events/editableEvents",
  auth,
  eventCtrl.getAllYourEditableEvents,
  logs,
  end
);
router.get(
  "/:userId/events/:eventId",
  auth,
  eventCtrl.getSpecifiedEvent,
  logs,
  end
);
router.get(
  "/:userId/events/:eventId/userRight",
  auth,
  eventCtrl.getUserRightFromSpecificEvent,
  logs,
  end
);
router.post(
  "/:userId/events/:eventId/join",
  auth,
  eventCtrl.joinEvent,
  logs,
  socketCtrl.refreshSpecificEventRoom,
  socketCtrl.refreshUserEventsRoom,
  end
);
router.delete(
  "/:userId/events/:eventId/leave",
  auth,
  eventCtrl.leaveEvent,
  logs,
  socketCtrl.refreshSpecificEventRoom,
  socketCtrl.refreshUserEventsRoom,
  end
);
router.post(
  "/:userId/events/:eventId/invite/friends/:friendId",
  auth,
  eventCtrl.inviteFriend,
  logs,
  end
);
router.post(
  "/:userId/events/:eventId/acceptInvitation/friends/:friendId",
  auth,
  eventCtrl.acceptInvitation,
  logs,
  socketCtrl.refreshSpecificEventRoom,
  end
);
router.delete(
  "/:userId/events/:eventId/refuseInvitation/friends/:friendId",
  auth,
  eventCtrl.refuseInvitation,
  logs,
  socketCtrl.refreshSpecificEventRoom,
  end
);
router.post(
  "/:userId/events/:eventId/updateParticipantRight/participants/:participantId",
  auth,
  eventCtrl.updateParticipantRight,
  logs,
  socketCtrl.refreshSpecificEventRoom,
  socketCtrl.refreshUserEventsRoom,
  end
);
router.delete(
  "/:userId/events/:eventId/deleteParticipant/participants/:participantId",
  auth,
  eventCtrl.deleteParticipant,
  logs,
  end
);

//---- Playlists requests ----//
router.post("/:userId/playlists", auth, playlistCtrl.createPlaylist, logs, end);
router.delete(
  "/:userId/playlists/:playlistId",
  auth,
  playlistCtrl.deletePlaylist,
  logs,
  end
);

router.put(
  "/:userId/playlists/:playlistId/changeMusicalStyle",
  auth,
  playlistCtrl.changeMusicalStyle,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/public",
  auth,
  playlistCtrl.setPlaylistPublic,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/private",
  auth,
  playlistCtrl.setPlaylistPrivate,
  logs,
  end
);
router.put(
  "/:userId/playlists/:playlistId/switchEditionRight",
  auth,
  playlistCtrl.switchEditionRight,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/associatedUser/:associatedUserId/switchEditionRight",
  auth,
  playlistCtrl.switchEditionRightAssociatedUser,
  logs,
  end
);

router.get(
  "/:userId/playlists",
  auth,
  playlistCtrl.getAllUserPlaylists,
  logs,
  end
);
router.get(
  "/:userId/followedPlaylists",
  auth,
  playlistCtrl.getUserFollowedPlaylists,
  logs,
  end
);
router.get(
  "/:userId/associatedPlaylists",
  auth,
  playlistCtrl.getUserAssociatedPlaylists,
  logs,
  end
);
router.get(
  "/:userId/createdPlaylists",
  auth,
  playlistCtrl.getUserCreatedPlaylists,
  logs,
  end
);
router.get(
  "/:userId/publicPlaylists",
  playlistCtrl.getUserPublicPlaylists,
  logs,
  end
);

router.post(
  "/:userId/playlists/:playlistId/invite/friend/:friendId",
  auth,
  playlistCtrl.sendInvitationToPlaylist,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/acceptInvitation",
  auth,
  playlistCtrl.acceptInvitationToPlaylist,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/refuseInvitation",
  auth,
  playlistCtrl.refuseInvitationToPlaylist,
  logs,
  end
);
router.delete(
  "/:userId/playlists/:playlistId/associatedUser/:associatedUserId",
  auth,
  playlistCtrl.removeAssociatedUserFromPlaylist,
  logs,
  end
);

router.post(
  "/:userId/playlists/:playlistId/follow",
  auth,
  playlistCtrl.followPlaylist,
  logs,
  end
);
router.post(
  "/:userId/playlists/:playlistId/unfollow",
  auth,
  playlistCtrl.unfollowPlaylist,
  logs,
  end
);

//---- Notifications requests ----//
router.get(
  "/:userId/playlistsInvitations",
  auth,
  notificationCtrl.getPlaylistsInvitations,
  logs,
  end
);
router.get(
  "/:userId/eventsInvitations",
  auth,
  notificationCtrl.getEventsInvitations,
  logs,
  end
);
router.get(
  "/:userId/friendsInvitations",
  auth,
  notificationCtrl.getFriendsInvitations,
  logs,
  end
);

//---- Player requests ----//
router.post(
  "/:userId/player/switchRandom",
  auth,
  playerCtrl.switchRandom,
  logs,
  end
);
router.post(
  "/:userId/player/refreshPlayer",
  auth,
  playerCtrl.refreshPlayer,
  logs,
  end
);
router.post(
  "/:userId/player/getNextTrack",
  auth,
  playerCtrl.getNextTrack,
  logs,
  end
);
router.post(
  "/:userId/player/getPreviousTrack",
  auth,
  playerCtrl.getPreviousTrack,
  logs,
  end
);

//---- Search requests ----//
router.get("/:userId/searchFriends", auth, searchCtrl.searchFriends, logs, end);

module.exports = router;
