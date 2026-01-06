const express = require('express')
const app = express()
const port = 3000

require('dotenv').config()

app.get('/', (req, res) => res.send('My secret number is : ' + process.env.MY_SECRET_NUMBER))

app.listen(port, () => console.log(`Example app listening on port ${port}!`))