const http = require('http');
const fs = require('fs');

const version = 'v2.0.0';

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end(`Hello, World! This is version: ${version}`);
});

server.listen(3000, '0.0.0.0', () => {
    console.log(`Server running at http://0.0.0.0:3000/ - Version: ${version}`);
});
