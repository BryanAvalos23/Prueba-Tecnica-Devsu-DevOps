process.env.NODE_ENV = 'test'

jest.mock('./shared/database/database', () => ({
  authenticate: jest.fn(),
  sync: jest.fn().mockResolvedValue(),
  close: jest.fn()
}))

jest.mock('./users/model.js', () => ({
  findAll: jest.fn(),
  findByPk: jest.fn(),
  findOne: jest.fn(),
  create: jest.fn()
}))

import request from 'supertest'

let app
let server
let User

beforeAll(async () => {
  const mod = await import('./index.js')
  const userMod = await import('./users/model.js')

  app = mod.app
  server = mod.server
  User = userMod.default
})

afterAll(() => {
  if (server && server.close) server.close()
})

describe('User API', () => {
  let data

  beforeEach(() => {
    data = {
      dni: "1234567890",
      name: "Test"
    }
    jest.clearAllMocks()
  })

  test('GET /api/users', async () => {
    User.findAll.mockResolvedValue([data])

    const res = await request(app).get('/api/users')

    expect(res.status).toBe(200)
  })

  test('GET /api/users/:id', async () => {
    User.findByPk.mockResolvedValue({ ...data, id: 1 })

    const res = await request(app).get('/api/users/1')

    expect(res.status).toBe(200)
  })

  test('POST /api/users', async () => {
    User.findOne.mockResolvedValue(null)
    User.create.mockResolvedValue({ ...data, id: 1 })

    const res = await request(app)
      .post('/api/users')
      .send(data)

    expect(res.status).toBe(201)
  })
})