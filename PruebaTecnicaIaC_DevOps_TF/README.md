# Prueba Técnica IaC / DevOps con Terraform

## Tabla de contenido

1. [Resumen](#resumen)
2. [Objetivo de la solución](#objetivo-de-la-solución)
3. [Arquitectura implementada](#arquitectura-implementada)
4. [Configuración actual detectada en el repositorio](#configuración-actual-detectada-en-el-repositorio)
5. [Estructura del repositorio](#estructura-del-repositorio)
6. [Descripción de módulos](#descripción-de-módulos)
7. [Backend remoto de Terraform](#backend-remoto-de-terraform)
8. [Requisitos para ejecutar la solución](#requisitos-para-ejecutar-la-solución)
9. [Cómo desplegar](#cómo-desplegar)
10. [Validación recomendada](#validación-recomendada)
11. [Manifiestos Kubernetes incluidos](#manifiestos-kubernetes-incluidos)
12. [Pipeline CI/CD](#pipeline-cicd)
13. [Outputs actuales](#outputs-actuales)
14. [Hallazgos técnicos del estado actual](#hallazgos-técnicos-del-estado-actual)
15. [Fortalezas de la propuesta](#fortalezas-de-la-propuesta)
16. [Mejoras recomendadas para llevarla a un nivel más productivo](#mejoras-recomendadas-para-llevarla-a-un-nivel-más-productivo)
17. [Siguientes pasos sugeridos para la prueba técnica](#siguientes-pasos-sugeridos-para-la-prueba-técnica)
18. [Conclusión](#conclusión)

## Resumen

Este repositorio contiene una solución de infraestructura como código en AWS orientada a una aplicación tipo microservicios desplegada sobre EKS, con persistencia en Aurora PostgreSQL, registro de imágenes en ECR y componentes de red dedicados para operación privada y segura.

La implementación está organizada en módulos de Terraform y cubre el aprovisionamiento de:

- VPC y subredes por capas.
- Internet Gateway y tablas de ruteo.
- VPC Endpoints para servicios clave de AWS.
- Security Groups para aplicación y base de datos.
- Clave KMS para cifrado.
- Clúster Aurora PostgreSQL.
- Repositorio ECR.
- Roles IAM para EKS.
- Clúster EKS y node group.

Además, el repositorio incluye manifiestos de Kubernetes y un archivo de pipeline de Azure DevOps como punto de partida.

> Estado actual del repositorio: la infraestructura Terraform está bastante avanzada, pero todavía hay deuda operativa importante en seguridad, outputs y automatización CI/CD.

## Objetivo de la solución

El objetivo técnico de esta propuesta es demostrar una base de plataforma cloud desplegable y modular para una aplicación empresarial, separando responsabilidades de red, seguridad, datos, cómputo y gobierno de acceso.

La topología implementada sigue una idea clara:

- La capa pública expone entradas externas.
- La capa privada aloja workloads de Kubernetes.
- La capa de base de datos aísla Aurora en subredes dedicadas.
- Los VPC Endpoints reducen dependencia de salida pública para servicios AWS consumidos desde la VPC.

## Arquitectura implementada

### Componentes principales

- **Networking**: VPC con DNS hostnames y DNS support habilitados, 6 subredes distribuidas en 2 AZ, 1 Internet Gateway y 3 tablas de ruteo para capas pública, privada y base de datos.
- **Conectividad privada a AWS**: interface endpoints para EC2, ECR API, ECR DKR, STS, Elastic Load Balancing, Auto Scaling, CloudWatch Logs y Secrets Manager; además de un gateway endpoint para S3.
- **Seguridad**: security group para aplicación en EKS, security group para Aurora y regla de acceso desde aplicación hacia la base de datos por puerto dedicado.
- **Base de datos**: Aurora PostgreSQL con 1 instancia writer, 1 reader, cifrado con KMS y subnet group dedicado.
- **Contenedores y cómputo**: repositorio ECR, clúster EKS con endpoint público y privado, y managed node group con escalamiento base de 1 a 2 nodos.
- **Identidad y acceso**: rol IAM para control plane de EKS, rol IAM para nodos y rol administrativo adicional para acceso al clúster.

## Flujo lógico de la plataforma

```text
Usuarios / Clientes
        |
        v
Ingress / Load Balancer Kubernetes
        |
        v
Servicios desplegados en EKS
        |
        v
Aurora PostgreSQL

EKS y nodos consumen además:
- ECR para imágenes
- STS para identidad
- Logs para observabilidad
- Secrets Manager para secretos administrados
- S3 mediante endpoint gateway
```

## Configuración actual detectada en el repositorio

Los valores de ejemplo para el entorno de desarrollo actualmente presentes en `Terraform/dev.tfvars` son:

| Parámetro | Valor actual |
|---|---|
| Región AWS | `us-east-1` |
| Nombre del proyecto | `devsu-demo-app` |
| CIDR VPC | `10.0.0.0/16` |
| Zonas de disponibilidad | `us-east-1a`, `us-east-1b` |
| Motor de BD | `aurora-postgresql` |
| Versión de engine | `16.13` |
| Clase de instancia | `db.t3.medium` |
| Puerto de BD | `15432` |
| Ventana de borrado KMS | `7 días` |

### Distribución de subredes

| Tipo | Nombre | CIDR | AZ |
|---|---|---|---|
| Pública | `sbn-public-z1` | `10.0.10.0/24` | `us-east-1a` |
| Pública | `sbn-public-z2` | `10.0.11.0/24` | `us-east-1b` |
| Privada | `sbn-private-z1` | `10.0.20.0/24` | `us-east-1a` |
| Privada | `sbn-private-z2` | `10.0.21.0/24` | `us-east-1b` |
| Database | `sbn-db-z1` | `10.0.30.0/24` | `us-east-1a` |
| Database | `sbn-db-z2` | `10.0.31.0/24` | `us-east-1b` |

## Estructura del repositorio

```text
.
|-- azure-pipelines.yml
|-- README.md
`-- Terraform/
	|-- .terraform/
	|-- .terraform.lock.hcl
	|-- backend.tf
	|-- dev.tfplan
	|-- dev.tfvars
	|-- main.tf
	|-- output.tf
	|-- provider.tf
	|-- variables.tf
	|-- manifiestos/
	|   `-- kubeconfig.yml
	`-- modules/
		|-- ECR/
		|-- EKS/
		|-- IAM/
		|-- kms/
		|-- networking/
		|   |-- internet-gateway/
		|   |-- route-tables/
		|   |-- subnets/
		|   |-- vpc/
		|   `-- vpc-endpoint/
		|-- rds/
		|   `-- aurora/
		`-- security/
```

### Lectura rápida de la estructura

- [Terraform/main.tf](Terraform/main.tf) compone toda la solución.
- [Terraform/variables.tf](Terraform/variables.tf) define las entradas del root module.
- [Terraform/dev.tfvars](Terraform/dev.tfvars) contiene la parametrización del entorno de desarrollo.
- [Terraform/backend.tf](Terraform/backend.tf) define el backend remoto del state.
- [Terraform/modules](Terraform/modules) concentra la implementación modular por dominio.
- [Terraform/manifiestos/kubeconfig.yml](Terraform/manifiestos/kubeconfig.yml) contiene configuración sensible de acceso al clúster.

## Descripción de módulos

### Root module

El archivo `Terraform/main.tf` orquesta todos los módulos de infraestructura y define el ensamblaje completo de la plataforma.

### Módulos de networking

- **networking/vpc**: crea la VPC principal y habilita DNS interno necesario para varios componentes de EKS.
- **networking/subnets**: crea subredes según un mapa tipado y aplica tags para integración con Kubernetes como `kubernetes.io/role/elb`, `kubernetes.io/role/internal-elb` y `kubernetes.io/cluster/<cluster-name>`.
- **networking/internet-gateway**: crea el Internet Gateway asociado a la VPC.
- **networking/route-tables**: crea y asocia tablas de ruteo para capas pública, privada y base de datos.
- **networking/vpc-endpoint**: implementa endpoints privados hacia servicios AWS requeridos por EKS y workloads, además de un security group dedicado para tráfico TLS interno por puerto 443.

### Módulos de seguridad

- **security**: crea SG de aplicación y SG de base de datos, y permite acceso TCP al puerto de BD desde la capa de aplicación.

### Módulos de datos

- **kms**: crea una KMS Key con rotación habilitada y publica un alias específico para el proyecto.
- **rds/aurora**: crea el subnet group de base de datos, despliega el clúster Aurora PostgreSQL cifrado, crea una instancia writer y una reader, y utiliza contraseña administrada por AWS Secrets Manager mediante `manage_master_user_password = true`.

### Módulos de cómputo e imágenes

- **ECR**: crea el repositorio `pruebatecnica/demo-app`, habilita scanning on push y define lifecycle policy para expirar imágenes antiguas.
- **IAM**: crea el rol del clúster EKS y el rol del node group, adjuntando políticas administradas mínimas para operación base de EKS y acceso read-only a ECR.
- **EKS**: crea el clúster, habilita endpoint público y privado, restringe el acceso público del API server a una CIDR permitida específica, crea un managed node group con instancias `t3.medium` y configura acceso administrativo adicional con `aws_eks_access_entry` y `aws_eks_access_policy_association`.

## Backend remoto de Terraform

El estado remoto está configurado en S3:

| Propiedad | Valor |
|---|---|
| Bucket | `devsu-demo-app-iac` |
| Key | `environments/dev.tfstate` |
| Región | `us-east-1` |
| Cifrado | `true` |

> Nota: no se observa configuración de locking de estado con DynamoDB. Para trabajo colaborativo sería recomendable agregarla.

## Requisitos para ejecutar la solución

### Herramientas

- Terraform 1.x
- AWS CLI autenticado contra la cuenta objetivo
- Permisos suficientes para crear recursos de VPC, EKS, IAM, ECR, KMS y RDS
- kubectl, si se desea operar el cluster luego del despliegue

### Proveedores

La solución utiliza:

- `hashicorp/aws` versión `~> 6.0`

## Cómo desplegar

Desde la carpeta `Terraform/`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file="dev.tfvars" -out="dev.tfplan"
terraform apply "dev.tfplan"
```

### Secuencia operativa sugerida

1. Configurar credenciales AWS para la cuenta objetivo.
2. Revisar y sanear [Terraform/dev.tfvars](Terraform/dev.tfvars) antes de ejecutar cualquier plan.
3. Inicializar el backend con `terraform init`.
4. Validar formato y sintaxis.
5. Generar plan contra el archivo de variables del ambiente.
6. Aplicar únicamente después de revisar los cambios esperados.

### Destrucción

```bash
terraform destroy -var-file="dev.tfvars"
```

## Validación recomendada

Comandos mínimos para validar cambios de infraestructura:

```bash
terraform fmt -recursive
terraform validate
terraform plan -var-file="dev.tfvars"
```

## Manifiestos Kubernetes incluidos

### `Terraform/manifiestos/kubeconfig.yml`

Se incluye un kubeconfig con endpoint, certificado y token embebidos.

Esto **no debe versionarse** en un repositorio real. Debe considerarse sensible y rotarse si corresponde.

Observación: en el estado actual del workspace no se detecta un manifiesto de Ingress versionado. Si existió en una revisión anterior, hoy ya no forma parte del árbol disponible.

## Pipeline CI/CD

Existe el archivo `azure-pipelines.yml`, pero actualmente está vacío. Esto sugiere que el repositorio contempla integración con Azure DevOps, aunque el pipeline todavía no fue implementado.

Una evolución razonable para esta prueba sería:

1. Validar formato y sintaxis Terraform.
2. Ejecutar `terraform plan` en PR.
3. Publicar el plan como artefacto.
4. Aprobar y aplicar a ambiente objetivo.
5. Desplegar workloads a EKS una vez creada la infraestructura.

## Outputs actuales

### Outputs disponibles en módulos internos

La solución sí expone outputs útiles dentro de varios módulos, por ejemplo:

- IDs de subredes.
- IDs de route tables.
- ARN de roles IAM.
- ARN de la clave KMS.
- IDs de security groups.

### Output del root module

El archivo `Terraform/output.tf` existe, pero actualmente está vacío. Esto significa que, al aplicar el root module, no se exponen salidas finales consolidadas como:

- endpoint del cluster EKS
- nombre del cluster
- ARN del repositorio ECR
- endpoint writer/reader de Aurora
- IDs principales de red

Agregar estos outputs mejoraría mucho la operabilidad del proyecto.

## Hallazgos técnicos del estado actual

La solución ya tiene una base sólida, pero hay varios puntos importantes a considerar para una evaluación técnica seria:

1. **Hay material sensible versionado**
   `Terraform/dev.tfvars` contiene una contraseña en texto plano y `Terraform/manifiestos/kubeconfig.yml` contiene credenciales/token.

2. **La contraseña de RDS se declara pero no se usa realmente**
   El módulo root pasa `master_password` al módulo Aurora, pero el recurso `aws_rds_cluster` usa `manage_master_user_password = true`. En la práctica, la credencial queda administrada por AWS y no se observa uso efectivo del valor plano en el recurso final.

3. **No hay outputs consolidados del root module**
   Esto dificulta integración con pipelines, observabilidad operativa y consumo por otros stacks.

4. **El pipeline aún no está implementado**
   El archivo existe, pero no contiene lógica.

5. **Se versionó un archivo de plan**
   `Terraform/dev.tfplan` parece ser un artefacto generado y normalmente no se recomienda versionarlo.

6. **El Ingress no está listo para aplicar tal como está**
   La referencia ya no coincide con el estado real del repositorio, lo que indica documentación o artefactos desalineados entre revisiones.

7. **No se observa locking de estado**
   En ambientes compartidos, esto puede provocar carreras sobre el state.

## Fortalezas de la propuesta

Desde una óptica de prueba técnica, este proyecto ya muestra varias buenas decisiones:

- Modularización clara por dominio.
- Separación de capas de red.
- Integración de EKS con tagging correcto de subredes.
- Uso de VPC Endpoints para reducir dependencia de internet pública.
- Cifrado de base de datos con KMS.
- Lifecycle policy y scanning en ECR.
- Uso de acceso administrado para EKS.

## Mejoras recomendadas para llevarla a un nivel más productivo

1. Mover secretos a AWS Secrets Manager o SSM Parameter Store.
2. Eliminar kubeconfig y credenciales del repositorio y rotarlas.
3. Exponer outputs finales del root module.
4. Implementar `azure-pipelines.yml` con validación, plan y apply controlado.
5. Agregar locking del state con DynamoDB.
6. Completar manifiestos Kubernetes productivos.
7. Incorporar políticas de tags globales, naming convention y ambientes separados.
8. Agregar documentación de operación post-deploy para EKS y Aurora.

## Siguientes pasos sugeridos para la prueba técnica

Si esta prueba técnica se quisiera elevar un nivel más, la secuencia natural sería:

1. Endurecer seguridad del repositorio.
2. Completar outputs del root module.
3. Implementar pipeline CI/CD.
4. Añadir despliegue de workloads de ejemplo sobre EKS.
5. Incorporar observabilidad y gestión de secretos end-to-end.

## Conclusión

La base del repositorio es buena: ya existe una plataforma modular en AWS con networking por capas, EKS, Aurora, ECR, IAM y KMS. Para una prueba técnica, el proyecto transmite criterio de arquitectura, separación de responsabilidades y entendimiento del ciclo de vida de infraestructura.

Lo que más elevaría su nivel no es agregar más recursos, sino cerrar los aspectos operativos y de seguridad que hoy están visibles: secretos en repo, outputs faltantes, pipeline vacío y manifiestos incompletos.