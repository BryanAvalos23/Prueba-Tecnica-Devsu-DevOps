import sequelize from './shared/database/database.js'
import { usersRouter } from "./users/router.js"
import express from 'express'

const app = express()
const PORT = process.env.PORT || 8000

app.use(express.json())

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP'
  })
})

app.use('/api/users', usersRouter)

let server

if (process.env.NODE_ENV !== 'test') {
  sequelize.sync()
    .then(() => {
      console.log('db is ready')

      server = app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`)
      })
    })
    .catch((error) => {
      console.error('Database connection failed:', error)
      process.exit(1)
    })
}

export { app, server }