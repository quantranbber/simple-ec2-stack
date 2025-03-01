const express = require('express')
const pgp = require('pg-promise')();
const bodyParser = require('body-parser');
const cors = require('cors');
const AWS = require("aws-sdk");

const app = express()
app.use(cors());
const port = 3000
const s3 = new AWS.S3();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const db = pgp({
  host: process.env.DB_HOST,
  port: 5432,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

async function createTableIfNotExists() {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS files (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100),
      url VARCHAR(100) UNIQUE NOT NULL
    );
  `;
  
  try {
    await db.none(createTableQuery);
    console.log('Table created (if not already existed)');
  } catch (error) {
    console.error('Error creating table:', error);
  }
}

app.get('/presignedUrl', async (req, res) => {
  try {
    await createTableIfNotExists();

    const path = `/uploads/${req.body.fileName}`;
    const params = {Bucket: process.env.S3_BUCKET, Key: path};
    const signedUrl = s3.getSignedUrl('getObject', params);
    
    const result = await db.one('INSERT INTO files(name, url) VALUES($1, $2) RETURNING *', [req.body.fileName, path]);
    res.status(201).json({
      message: 'file added successfully',
      file: result,
      signedUrl,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to insert data into database' });
  }
});

app.get('/', async (_req, res) => {
  console.log('start get files')
  await createTableIfNotExists();

  const files = await db.any('SELECT id, name, url FROM files');
  res.status(200).json(
    {
      files: files || []
    }
  )
})

app.get('/health', (_req, res) => {
  res.status(200).json(
    {
      message: 'OK'
    }
  )
})

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})