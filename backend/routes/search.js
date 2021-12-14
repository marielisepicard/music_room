const express = require("express");
const router = express.Router();
const end = require("../middleware/end");
const searchCtrl = require("../controllers/search");

router.get("/", searchCtrl.searchGlobal);

router.get("/tracks", searchCtrl.searchTracks, end);

module.exports = router;
