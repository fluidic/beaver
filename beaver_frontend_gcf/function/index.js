'use strict';

const spawn = require('child_process').spawn;

exports.beaver = function beaver(req, res) {
    const child = spawn('./third_party/dart-linux-x64/dart',
        [
            'beaver_ci.dart.snapshot',
            req.path,
            JSON.stringify(req.headers),
            // FIXME: req.body can be empty.
            JSON.stringify(req.body)
        ],
        {
            env: {LD_LIBRARY_PATH: './third_party/glibc-2.15-lib'}
        }
    );

    const RESPONSE_PREFIX = 'response:';
    const RESPONSE_PREFIX_LENGTH = RESPONSE_PREFIX.length;
    child.stdout.on('data', (data) => {
        data = String(data);
        console.log(`stdout: ${data}`);
        if (data.startsWith(RESPONSE_PREFIX)) {
            const response = data.substring(RESPONSE_PREFIX_LENGTH + 1);
            res.send(response);
        }
    });

    child.stderr.on('data', (data) => {
        data = String(data);
        console.log(`stderr: ${data}`);
        res.send({'status': 'failure', 'reason': data});
    });

    child.on('exit', (code) => {
        console.log(`child process exited with code ${code}`);
        res.status(200).end();
    });
};
