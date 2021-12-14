const express = require('express');
const authCtrl = require('../controllers/auth');

const router = express.Router();

router.post('/signup', authCtrl.signup);
router.post('/signup/google', authCtrl.signup);
router.post('/signup/facebook', authCtrl.signup);
router.post('/login', authCtrl.login);
router.post('/login/google', authCtrl.login);
router.post('/login/facebook', authCtrl.login);
router.post('/password', authCtrl.sendMailResetPassword)
router.get('/activate/:userId/:hashId', authCtrl.activate);

module.exports = router;
