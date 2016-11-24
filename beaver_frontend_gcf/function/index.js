'use strict';

const spawn = require('child_process').spawn;
const http = require('http');
const url = require('url');

exports.beaver = function beaver(req, res) {
    console.log(req);

    const server = spawnHttpServer();

    const path = (isGCF(req) ? "/" + process.env.FUNCTION_NAME : "") + req.originalUrl;
    const url = req.protocol + "://" + req.get('host') + path;
    spawnDartVM(url, req.headers, req.body, function (response) {
        res.send(response);
    }, function () {
        server.close(function () {});
    });
};

function isGCF(req) {
    return req.get('host').indexOf('cloudfunctions.net') !== -1;
}

function spawnHttpServer() {
    const server = http.createServer(function (req, res) {
        const urlObj = url.parse(req.url, true, false);
        if (urlObj.pathname != '/ssh') {
            res.writeHead(404);
            res.end();
            return;
        }

        spawnSsh(urlObj.query.host, function (err) {
            if (err) {
                res.writeHead(500);
                res.end(err);
                return;
            }
            res.writeHead(200);
            res.end();
        });
    });
    server.listen(8080);
    return server;
}

function spawnDartVM(url, headers, body, callback1, callback2) {
    const child = spawn('./third_party/dart-linux-x64/dart',
        [
            'beaver_ci.dart.snapshot',
            url,
            JSON.stringify(headers),
            JSON.stringify(body)
        ]
    );

    const RESPONSE_PREFIX = 'response:';
    const RESPONSE_PREFIX_LENGTH = RESPONSE_PREFIX.length;
    child.stdout.on('data', (data) => {
        data = String(data);
        console.log(`dartVM - stdout: ${data}`);
        if (data.startsWith(RESPONSE_PREFIX)) {
            const response = data.substring(RESPONSE_PREFIX_LENGTH + 1);
            callback1(response);
        }
    });

    child.stderr.on('data', (data) => {
        data = String(data);
        console.log(`dartVM - stderr: ${data}`);
    });

    child.on('exit', (code) => {
        console.log(`dartVM - child process exited with code ${code}`);
        callback2();
    });
}

function spawnSsh(host, callback) {
    console.log('host: ' + host);
    const commands = [
        'sudo apt-get update',
        'sudo apt-get -y install apt-transport-https',
        "sudo sh -c 'curl https://dl-ssl.google.com/linux/linux_signing_key.pub | tac | apt-key add -'",
        "sudo sh -c 'curl https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'",
        'sudo apt-get update',
        'sudo apt-get -y --force-yes install dart',
        'sudo apt-get -y install git',
        'git clone https://github.com/fluidic/beaver',
        'cd beaver/beaver_task',
        '/usr/lib/dart/bin/pub get',
        "sh -c 'nohup dart bin/beaver_task_server.dart > foo.out 2> foo.err < /dev/null &'"
    ];
    const args = [
        '-T',
        '-o',
        'StrictHostKeyChecking=no',
        '-o',
        'UserKnownHostsFile=/dev/null',
        '-i',
        '/tmp/id_rsa',
        host
    ];
    const child = spawn('./third_party/ssh', args);

    commands.forEach(function (command) {
        child.stdin.write(command + '\n');
    });
    child.stdin.end();

    child.stdout.on('data', (data) => {
        data = String(data);
        console.log(`ssh - stdout: ${data}`);
    });

    var err;
    child.stderr.on('data', (data) => {
        data = String(data);
        console.log(`ssh - stderr: ${data}`);
        if (data.includes('Connection timed out') || data.includes('Connection refused')) {
            err = data;
        }
    });

    child.on('exit', (code) => {
        console.log(`ssh - child process exited with code ${code}`);
        callback(err);
    });
}