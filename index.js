import sequelize from './shared/database/database.js'
import { usersRouter } from "./users/router.js"
import express from 'express'

const app = express()
const PORT = process.env.PORT || 8000

sequelize.sync({ force: true }).then(() => console.log('db is ready'))

app.use(express.json())
app.use('/api/users', usersRouter)

app.get('/healthz', (_, res) => {
    sequelize.authenticate().then(() => {
        res.status(200).send('up')
    }).catch(err => {
        console.error('Error de conexion a bd')
        console.error(err)
        res.status(500).send('down')
    })
})

const server = app.listen(PORT, () => {
    console.log('Server running on port PORT', PORT)
})

export { app, server }