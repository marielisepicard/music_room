const express = require('express');
const auth = require('../middleware/auth');
const eventCtrl = require('../controllers/event');
const userCtrl = require('../controllers/user');
const discussionCtrl = require('../controllers/discussion')
const logs = require('../middleware/logs');
const end = require('../middleware/end');

const router = express.Router();

//------ Events requests ------//
router.get('/', auth, userCtrl.getMyProfile, logs, end);
router.get('/events', auth, eventCtrl.getAllMyEvents, logs, end);
router.get('/discussions', auth, discussionCtrl.getAllMyDiscussions, logs, end);

module.exports = router;