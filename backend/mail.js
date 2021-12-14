const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
	port: 465,
	host: "smtp.gmail.com",
	auth: {
		user: 'musicroom42mjt@gmail.com',
		pass: '42suricates'
	},
	secure: true,
});

module.exports = transporter;