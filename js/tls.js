var tls = require('tls'),
    fs = require('fs'),

    PORT = 1337,
    HOST = '127.0.0.1',
    value = null;

var options = {
    key: fs.readFileSync('public/key.pem'),
    cert: fs.readFileSync('public/cert.pem'),
    rejectUnauthorized: false
};

var server = tls.createServer(options, function (socket) {
    socket.on('data', function (data) {
        console.log('\nReceived: %s ',
            data.toString().replace(/(\n)/gm, ""));
    });

    socket.on('data', function (chunk) {
        console.log(`Data received from client: ${chunk.toString()}`)
    });

    socket.on('end', function () {
        console.log('Closing connection with the client');
    });

    socket.on('error', function (err) {
        console.log(`Error: ${err}`);
    });
});

server.listen(PORT, HOST, function () {
    console.log("I'm listening at %s, on port %s", HOST, PORT);
});