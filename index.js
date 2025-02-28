const express = require('express')
const pgp = require('pg-promise')();
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express()
app.use(cors());
const port = 3000

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
    CREATE TABLE IF NOT EXISTS users (
      id SERIAL PRIMARY KEY,
      name VARCHAR(100),
      email VARCHAR(100) UNIQUE NOT NULL
    );
  `;
  
  try {
    await db.none(createTableQuery);
    console.log('Table created (if not already existed)');
  } catch (error) {
    console.error('Error creating table:', error);
  }
}

app.post('/insert', async (req, res) => {
  console.log('start insert new user')
  const { name, email } = req.body;

  await createTableIfNotExists();

  // Validate input
  if (!name || !email) {
    return res.status(400).json({ error: 'Name and email are required' });
  }

  try {
    const result = await db.one('INSERT INTO users(name, email) VALUES($1, $2) RETURNING *', [name, email]);
    res.status(201).json({
      message: 'User added successfully',
      user: result,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to insert data into database' });
  }
  
});

app.get('/', async (_req, res) => {
  console.log('start get users')
  await createTableIfNotExists();

  const users = await db.any('SELECT id, name, email FROM users');
  res.status(200).json(
    {
      users: users || []
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