'use strict';

const express = require('express');
const app = express();

const bodyParser = require('body-parser');

const index = require('../upload/index');

app.use(bodyParser.json());

app.post('/*', function (req, res) {
    index.beaver(req, res);
});

app.listen(3000, function () {
    console.log('Example server listening on port 3000!');
});