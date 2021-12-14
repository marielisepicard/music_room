const express = require('express');
const router = express.Router();
const logs = require('../middleware/logs')
const end = require('../middleware/end');
const auth = require('../middleware/auth');

const notificationsCtrl = require('../controllers/notification');

router.delete('/:notificationId', auth, notificationsCtrl.deleteNotification, end);
router.get('/playlistsInvitations', auth, notificationsCtrl.getPlaylistsInvitations, logs, end);
router.get('/friendsInvitations', auth, notificationsCtrl.getFriendsInvitations, logs, end);

module.exports = router;