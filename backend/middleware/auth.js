const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
	try {
		if (!req.headers.authorization)
			throw 'Token must be specified!';
		const token = req.headers.authorization.split(' ')[1];
		const decodedToken = jwt.verify(token, 'RANDOM_TOKEN_SECRET');
		const userId = decodedToken.userId;
		if (req.params.userId && req.params.userId !== userId) {
			throw 'Unvalid user ID!';
		} else {
			next();
		}
	} catch (error) {
		console.log(error)
		res.status(401).json({ error })
	}
}	