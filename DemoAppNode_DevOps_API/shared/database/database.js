import * as dotenv from 'dotenv'
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager'
import { Sequelize } from 'sequelize'

dotenv.config()

const getDbPassword = async () => {
  if (process.env.DB_SECRET_NAME) {
    const client = new SecretsManagerClient({ region: process.env.AWS_REGION || 'us-east-1' })
    const response = await client.send(
      new GetSecretValueCommand({ SecretId: process.env.DB_SECRET_NAME })
    )
    const secret = JSON.parse(response.SecretString)
    return secret.password
  }

  return process.env.DATABASE_PASSWORD
}

const password = await getDbPassword()

const sequelize = new Sequelize(
  process.env.DATABASE_NAME,
  process.env.DATABASE_USER,
  password,
  {
    dialect: 'postgres',
    host: process.env.DATABASE_HOST,
    port: process.env.DATABASE_PORT,
    logging: false
  }
)

export default sequelize