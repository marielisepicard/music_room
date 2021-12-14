const http = require('http');
const app =  require('./app');
const messageCtrl = require('./controllers/discussion')

const port = 45559;
 
app.set('port', port);

const errorHandler = error => {
	if (error.syscall !== 'listen') {
		throw error;
	}
	const address = server.address();
	const bind = typeof address === 'string' ? 'pipe' + address : 'port ' + port;
	switch (error.code) {
		case 'EACCES':
			console.error(bind + ' require elevated privileges.');
			process.exit(1);
			break;
		case 'EADDRINUSE':
			console.error(bind + ' is already in use.');
			process.exit(1);
			break;
		default:
			throw error;
	}
};

const server = http.createServer(app);
const io = require('socket.io')(server)

server.on('error', errorHandler);
server.on('listening', () => {
	const address = server.address();
	const bind = typeof address === 'string' ? 'pipe ' + address : 'port ' + port;
	console.log('Listening on ' + bind);
});

io.on('connection', (socket) => {
	console.log(`Connecte au client ${socket.id}`)
	socket.on("joinRoom", (roomId, callback) => {
			// console.log("Room " + roomId + " successfuly joined!");
			socket.join(roomId);
			callback("OK");
	})
	socket.on("leaveRoom", (roomId, callback) => {
			// console.log("Room " + roomId + " successfuly leaved!");
			socket.leave(roomId);
			callback("OK")
	})
	socket.on('disconnect', function(data) {
			console.log('Disconnect event received!');
	})
    socket.on('sendMsg', function(data) {
        // console.log("new Message received!")
        messageCtrl.receiveMsg(data.ownerId, data.ownerPseudo, data.recipientId, data.content)
    })

	// Control Delegation
	socket.on('controlDelegInviteFriend', function(data) {
		io.sockets.in(data.friendId).emit("controlDelegInviteFriend", {roomId: data.roomId, friendId: data.friendId, friendPseudo: data.friendPseudo, pseudo: data.pseudo, userId: data.userId, roomFriendsId: data.roomFriendsId, roomFriendsPseudo: data.roomFriendsPseudo});
	})
	socket.on('controlDelegJoinRoom', (data) => {
		socket.join(data.roomId);
		io.sockets.in(data.roomId).emit("controlDelegJoinRoom", {roomId: data.roomId, friendId: data.friendId, friendPseudo: data.friendPseudo, roomFriendsId: data.roomFriendsId, roomFriendsPseudo: data.roomFriendsPseudo, userId: data.userId});
	})
	socket.on('controlDelegLeaveRoom', (data) => {
		io.sockets.in(data.roomId).emit("controlDelegLeaveRoom", {friendId: data.friendId});
	})

	// Player
	socket.on('controlDelegInitPlayer', function(data) {
		io.sockets.in(data.roomId).emit("controlDelegInitPlayer", {userId: data.userId, tracks: data.tracks, unshuffledTracks: data.unshuffledTracks, index: data.index, readingListContext: data.readingListContext, position: data.position, isShuffling: data.isShuffling, isPlaying: data.isPlaying});
	})

})

server.listen(port, '0.0.0.0');

exports.io = io
