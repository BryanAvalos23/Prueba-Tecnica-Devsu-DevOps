# DemoAppNode DevOps API

API REST construida con Node.js, Express y Sequelize para la gestión de usuarios. Este repositorio fue adaptado para una estrategia más cercana a un despliegue real en contenedores y Kubernetes, incorporando cambios en base de datos, pruebas automatizadas, empaquetado y pipeline de CI/CD.

## Objetivo del repositorio

El proyecto expone endpoints para administrar usuarios y sirve como base para demostrar una solución orientada a DevOps con:

- API Node.js con Express.
- Persistencia con PostgreSQL.
- Pruebas automatizadas con Jest y Supertest.
- Imagen Docker para despliegue consistente.
- Manifiestos Kubernetes para ejecución en clúster.
- Pipeline de Azure DevOps con etapas de análisis, build y deploy.

## Cambios realizados sobre la base original

### Migración de SQLite a PostgreSQL

La implementación original estaba orientada a SQLite, con una base de datos embebida dentro del contexto de ejecución de la aplicación. En esta adaptación se migró la conexión a PostgreSQL.

La decisión de usar PostgreSQL en lugar de SQLite responde a una necesidad operativa y arquitectónica:

- SQLite acopla la persistencia al sistema de archivos local del contenedor o del pod.
- En Kubernetes, el pod debe ser efímero y reemplazable, por lo que no conviene que la base de datos dependa del ciclo de vida del mismo.
- Separar la base de datos del pod evita que la persistencia quede como responsabilidad del contenedor de aplicación.
- PostgreSQL permite operar la base como un servicio externo, más alineado con prácticas de escalabilidad, disponibilidad y administración centralizada.
- Esta decisión también facilita la separación de responsabilidades entre capa de aplicación e infraestructura de datos.

En el código actual, la conexión se construye mediante variables de entorno y el dialecto configurado es PostgreSQL.

### Ajustes en pruebas automatizadas

Las pruebas fueron modificadas para cubrir mejor el comportamiento del API sin depender de una base de datos real durante la ejecución del test.

Se incorporó un enfoque basado en mocks para:

- Simular la inicialización de Sequelize.
- Evitar que los tests levanten una conexión real a la base de datos.
- Validar los endpoints principales con Supertest.
- Mantener las pruebas enfocadas en comportamiento HTTP y flujo del controlador.

Esto permite que la etapa de validación del pipeline sea más estable y repetible.

### Contenerización y despliegue

Se agregaron artefactos para soportar el ciclo completo de entrega:

- Dockerfile para construir la imagen de la aplicación.
- docker-compose.yml para ejecutar la aplicación de forma parametrizable por variables de entorno.
- Manifiestos Kubernetes para deployment, service e ingress.
- azure-pipelines.yml para automatizar análisis, construcción y despliegue.

## Stack tecnológico

- Node.js
- Express
- Sequelize
- PostgreSQL
- Jest
- Supertest
- Docker
- Kubernetes
- Azure DevOps Pipelines
- AWS ECR y AWS EKS

## Estructura principal del repositorio

- index.js: punto de entrada de la API y registro de rutas.
- users/: módulo de usuarios con router, controlador y modelo.
- shared/database/database.js: configuración de conexión a PostgreSQL y obtención de secretos.
- shared/middleware/: middleware compartido para validación.
- shared/schema/: esquemas de validación de entrada.
- index.test.js: pruebas automatizadas del API.
- Dockerfile: construcción de imagen de la aplicación.
- docker-compose.yml: ejecución local o controlada con variables de entorno.
- k8s/: manifiestos para despliegue en Kubernetes.
- azure-pipelines.yml: pipeline de integración y despliegue continuo.

## Requisitos

- Node.js 18 o superior.
- npm.
- Acceso a una instancia de PostgreSQL.
- Variables de entorno configuradas para la conexión.

## Variables de entorno

La aplicación utiliza variables de entorno para construir la conexión a base de datos y para soportar despliegues en nube.

Variables principales:

- DATABASE_NAME: nombre de la base de datos.
- DATABASE_USER: usuario de la base de datos.
- DATABASE_PASSWORD: contraseña de la base de datos cuando no se usa secreto externo.
- DATABASE_HOST: host de PostgreSQL.
- DATABASE_PORT: puerto de PostgreSQL.
- NODE_ENV: entorno de ejecución.
- DB_SECRET_NAME: nombre del secreto en AWS Secrets Manager, si aplica.
- AWS_REGION: región de AWS para resolver secretos.
- AWS_ACCESS_KEY_ID: credencial de AWS para despliegues o lectura de secretos.
- AWS_SECRET_ACCESS_KEY: credencial secreta de AWS.
- PORT: puerto de la aplicación, por defecto 8000.

## Instalación

Instalar dependencias:

```bash
npm install
```

## Ejecución local

Con las variables de entorno configuradas y una base PostgreSQL disponible:

```bash
npm run start
```

La aplicación expone:

- Health check en http://localhost:8000/health
- API de usuarios en http://localhost:8000/api/users

## Ejecución de pruebas

Para correr las pruebas automatizadas:

```bash
npm run test
```

La suite genera reporte de cobertura en la carpeta coverage/.

## Endpoints disponibles

### GET /health

Permite verificar que la aplicación está levantada.

Respuesta esperada:

```json
{
    "status": "UP"
}
```

### GET /api/users

Obtiene el listado de usuarios.

Respuesta esperada:

```json
[
    {
        "id": 1,
        "dni": "1234567890",
        "name": "Test"
    }
]
```

### GET /api/users/:id

Obtiene un usuario por identificador.

Respuesta exitosa:

```json
{
    "id": 1,
    "dni": "1234567890",
    "name": "Test"
}
```

Si el usuario no existe:

```json
{
    "error": "User not found: 1"
}
```

### POST /api/users

Crea un nuevo usuario.

Payload:

```json
{
    "dni": "1234567890",
    "name": "Test"
}
```

Respuesta exitosa:

```json
{
    "id": 1,
    "dni": "1234567890",
    "name": "Test"
}
```

Si el usuario ya existe:

```json
{
    "error": "User already exists: 1234567890"
}
```

## Docker

El Dockerfile permite empaquetar la aplicación en una imagen lista para ejecución en cualquier entorno compatible con contenedores.

Su propósito es:

- Estandarizar el runtime.
- Facilitar promoción entre ambientes.
- Integrarse con pipelines y registros de imágenes.

## Docker Compose

El archivo docker-compose.yml permite levantar la aplicación inyectando la configuración de base de datos por variables de entorno.

Su propósito es:

- Simplificar pruebas de ejecución en entorno contenedorizado.
- Reproducir de forma consistente la configuración del servicio.

## Kubernetes

La carpeta k8s/ contiene los manifiestos necesarios para publicar la aplicación en un clúster:

- deployment.yml: define réplicas, imagen, recursos y variables de entorno del contenedor.
- services.yml: expone la aplicación dentro del clúster mediante un Service tipo ClusterIP.
- ingress.yml: publica rutas externas usando un Ingress con ALB.

Su incorporación permite separar claramente:

- La definición de ejecución del contenedor.
- La exposición interna del servicio.
- La publicación externa del tráfico.

## Pipeline de Azure DevOps

El archivo azure-pipelines.yml implementa una estrategia de CI/CD compuesta por tres etapas principales:

### 1. Análisis

Incluye:

- Instalación de dependencias.
- Ejecución de pruebas.
- Generación de cobertura.
- Análisis de calidad con SonarCloud.

### 2. Build

Incluye:

- Autenticación contra AWS ECR.
- Construcción de la imagen Docker.
- Publicación de la imagen en el repositorio remoto.

### 3. Deploy

Incluye:

- Reemplazo de tokens en manifiestos.
- Validación de conectividad con el clúster EKS.
- Aplicación de deployment, service e ingress.
- Verificación posterior del estado de pods.

Con esto, el repositorio ya no solo contiene código de aplicación, sino también la automatización necesaria para analizar, construir y desplegar el servicio.

## Resumen de la decisión arquitectónica

La migración a PostgreSQL fue clave para desacoplar la persistencia del ciclo de vida del pod. En un entorno orquestado como Kubernetes, la aplicación debe ser reemplazable sin comprometer la integridad de los datos. Usar SQLite dentro del pod trasladaba la responsabilidad del almacenamiento al contenedor; usar PostgreSQL externo permite que el pod se enfoque únicamente en ejecutar la API.

## Licencia

Copyright © 2023 Devsu. All rights reserved.
