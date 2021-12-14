const express = require('express');
const eventCtrl = require('../controllers/event');
const auth = require('../middleware/auth');
const socketCtrl = require('../middleware/socketIO')
const logs = require('../middleware/logs');
const end = require('../middleware/end');

const router = express.Router();

router.get('/', eventCtrl.getAllPublicEvents, logs, end);
router.post('/', auth, eventCtrl.createEvent, logs, socketCtrl.refreshUserEventsRoom, end);
router.delete('/:eventId', auth, eventCtrl.deleteEvent, logs, socketCtrl.refreshSpecificEventRoom, socketCtrl.refreshUserEventsRoom, end);
router.post('/:eventId/setStatus', auth, eventCtrl.setEventStatus, logs, end);
router.post('/:eventId/tracks/:trackId', auth, eventCtrl.addTrackToEvent, logs, socketCtrl.refreshSpecificEventRoom, end);
router.delete('/:eventId/tracks/:trackId', auth, eventCtrl.deleteTrackFromEvent, logs, socketCtrl.refreshSpecificEventRoom, end);
router.post('/:eventId/tracks/:trackId/vote', auth, eventCtrl.voteTrackEvent, logs, socketCtrl.refreshSpecificEventRoom, end);
router.post('/:eventId/tracks/:trackId/unvote', auth, eventCtrl.unvoteTrackEvent, logs, socketCtrl.refreshSpecificEventRoom, end);
router.get('/:eventId/tracks', auth, eventCtrl.getSortedTrackList, logs, end);
router.post('/:eventId', auth, eventCtrl.updateEvent, logs, socketCtrl.refreshSpecificEventRoom, socketCtrl.refreshUserEventsRoom, end);

module.exports = router;