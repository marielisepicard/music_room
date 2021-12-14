const express = require('express');
const router = express.Router();
const logs = require('../middleware/logs')
const end = require('../middleware/end');
const playlistCtrl = require('../controllers/playlist');
const auth = require('../middleware/auth');
const socketCtrl = require('../middleware/socketIO')

router.post('/:playlistId/tracks/:trackId', auth, playlistCtrl.addTrack, logs, socketCtrl.refreshSpecificPlaylistRoom, end);
router.post('/:playlistId/changeTracksOrder', auth, playlistCtrl.changeOrderTrack, logs, socketCtrl.refreshSpecificPlaylistRoom, end);
router.delete('/:playlistId/tracks', auth, playlistCtrl.deleteTrack, logs, socketCtrl.refreshSpecificPlaylistRoom, end);
router.get('/:playlistId', auth, playlistCtrl.getPlaylist, logs, end);
router.get('/', playlistCtrl.getAllPublicPlaylists, logs, end);
router.get('/:playlistId/tracks', auth, playlistCtrl.getPlaylistTracks, logs, end);

module.exports = router;