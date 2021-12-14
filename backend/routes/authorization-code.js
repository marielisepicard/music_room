const express = require('express'); // Express web server framework
const router = express.Router();
const request = require('request'); // "Request" library

var client_id = '6b7e5095f2824006b9c487f48b9d779a'; // Your client id
var client_secret = '5eb34021a9a24cac92c57ee0f429eb15'; // Your secret
var redirect_uri = 'musicroom://login'; // Your redirect uri


router.post('/access_token', function(req, res) {
	// your application requests refresh and access tokens
	// after checking the state parameter

	var code = req.body.code || null;
	var authOptions = {
		url: 'https://accounts.spotify.com/api/token',
		form: {
			code: code,
			redirect_uri: redirect_uri,
			grant_type: 'authorization_code'
		},
		headers: {
			'Authorization': 'Basic ' + (Buffer.from(client_id + ':' + client_secret).toString('base64'))
		},
		json: true
	};

	request.post(authOptions, function(error, response, body) {
		if (!error && response.statusCode === 200) {
			res.status(200).json(
				response.body
			);
		} else {
			res.status(400).json({
				error: 'invalid_token'
			})
		}
	});
});

router.post('/refresh_token', function(req, res) {
  	// requesting access token from refresh token
  	var refresh_token = req.body.refresh_token;
	var authOptions = {
		url: 'https://accounts.spotify.com/api/token',
		headers: { 'Authorization': 'Basic ' + (Buffer.from(client_id + ':' + client_secret).toString('base64')) },
		form: {
			grant_type: 'refresh_token',
			refresh_token: refresh_token
		},
		json: true
	};

	request.post(authOptions, function(error, response, body) {
		if (!error && response.statusCode === 200) {
			res.status(200).json(
				response.body
			);
		} else {
			res.status(400).json({
				error: 'invalid_token'
			})
		}
	});
});

module.exports = router;