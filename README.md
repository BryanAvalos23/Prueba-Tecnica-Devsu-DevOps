# Prueba-Tecnica-Devsu-DevOps

## URL de acceso

https://precustodios.online/health

https://precustodios.online/api/users

## Comprobaciones de funcionamiento

### Endpoint de Health 
Se agrego endpoint de healt para validaciones de funcionamiento

![Endpoint Health](<docs/app/endpoint-health.png>)


### Endpoint users

![Endpoint Users](<docs/app/endpoint-users.png>)



## Arquitectura

![Diagrama de arquitectura](<docs/Arquitectura.png>)

## Decisiones de arquitectura
### Por qué VPC Endpoints y no NAT Gateway
Se tomo la decision de usar VPC Enpoints que NAT Gateway por los costos, normalmente se utilizan como una buena solucion pero al tener los VPC podiamos acceder a imagenes en ECR, se descargaban desde local o desde el agente de despliegue en subnet publica y se subian las imagenes al ECR para ser accedidas, con esto se minimiza costes silenciosos que suelen tener los NAT Gateway

### Por qué ALB con Ingress y no Service LoadBalancer

Porque permite manejar multiples rutas y servicios con un solo ALB, reduce costos. El service LoadBalancer crea un balanceador por cada servicio lo que lo convierte en algo mas costoso e inmanejable segun el caso, aparte el Ingress permite SSL/TLS

### Por qué Aurora PostgreSQL
Se incorpora un a migracion del aplicativo de SQLite a Postgres en un RDS Aurora postgres, esto con el objetivo de segmentar y dejar al con su respectiva responsabilidad y evitar alguna perdida de datos el algun momento en la eliminacion de algun pod de SQL o algo por el estilo, con esto tambien se logra una arqutiectura mas robusca, escalable y mantenible, se toma esta decision como una mejora operativa para la solucion

### Por qué EKS con HPA
Para el Escalado Horizontal automatico segun consumo de CPU y Memoria, sin necsidad de intervencion manual, esto permite que la aplicacion logre soportar tradfico creando mas pods y reducirlos cuando el trafico baja, optimizamos costos de esta manera

## Infraestructura (Terraform)

### VPC
![VPC](<docs/aws/vpc.png>)

### Subnets
![Subnets](<docs/aws/subnets.png>)

### Internet Gateway
![Internet Gateway](<docs/aws/internat-gateway.png>)

### Elastic IPs
![Elastic IPs](<docs/aws/ip-elasticas.png>)

### Route Tables
![Route Tables](<docs/aws/route-tables.png>)

### VPC Endpoint
![VPC Endpoint](<docs/aws/vpc-endpoint.png>)

### Security Group
![Security Group](<docs/aws/security-group.png>)

### EC2 Instances
![EC2 Instances](<docs/aws/ec2-instances.png>)

### Load Balancer
![Load Balancer](<docs/aws/load-balancer.png>)

### RDS Aurora
![RDS Aurora](<docs/aws/rds-aurora.png>)

### AWS KMS
![AWS KMS](<docs/aws/KMS.png>)

### ACM
![ACM](<docs/aws/acm.png>)

### Route 53
![Route 53](<docs/aws/route-53.png>)

### Secrets Manager
![Secrets Manager](<docs/aws/secret_manager.png>)



## Pipeline CI/CD

![Pipeline 1](<docs/pipeline/pipeline-1.png>)

![Pipeline 2](<docs/pipeline/pipeline-2.png>)

### Etapa 1 - Análisis (Test y SonarCloud)
![Pipeline Analisis](<docs/pipeline/pipeline-analisis.png>)

### Etapa 2 - Build y Push (ECR)
![Pipeline Build](<docs/pipeline/pipeline-build.png>)

### Etapa 3 - Deploy (EKS)

![Pipeline Deployment](<docs/pipeline/pipeline-deploy.png>)

### Services Connections
Se muestran los diferentes SVC creados de los cuales se usaron

![Service Connections](<docs/pipeline/service-connections.png>)

### Pool de agente y agentes
Se muestra capturas de las ejecuciones en el pool de agente de Azure DevOps y los agentes remoto EC2 y local

#### Ejecuciones del pool
![Ejecuciones del pool](<docs/pipeline/ejecuciones-pool.png>)

#### Agentes del pool
![Agentes del pool](<docs/pipeline/agentes-pool.png>)



## Recursos de Kubernetes

# Cluster
kubectl get nodes -o wide

![Cluster](<docs/K8s/get-nodes.png>)

# Namespace
kubectl get namespace demo-app

![Namespace](<docs/K8s/get-namespace.png>)

# Pods
kubectl get pods -n demo-app -o wide

![Pods](<docs/K8s/get-pods.png>)

# Services
kubectl get svc -n demo-app

![Services](<docs/K8s/get-svc.png>)

# Ingress
kubectl get ingress -n demo-app

![Ingress](<docs/K8s/get-ingres.png>)

# HPA
kubectl get hpa -n demo-app

![HPA](<docs/K8s/get-hpa.png>)

# Deployment
kubectl describe deployment demo-app -n demo-app

![Deployment](<docs/K8s/describre-deploy.png>)

## Portal de Sonar

![Portal de Sonar](<docs/sonarqube/Sonarqube.png>)



## Consideraciones adicionales

### Lo que se implementó
- Migración de SQLite a PostgreSQL (Aurora) — el código base usaba SQLite,
  se migró a PostgreSQL y se ajustaron los test para cubrir la nueva conexión
- SonarCloud integrado en el pipeline para análisis de calidad del repositorio
  del aplicativo
- Certificado TLS/SSL via ACM con redirección HTTP → HTTPS
- Secrets Manager para manejo seguro de credenciales de base de datos
- HPA configurado con métricas de CPU (70%) y memoria (80%)
- VPC Endpoints para conectividad privada sin NAT Gateway
- Dominio personalizado en Route 53 como zona hospedada traido desde GoDaddy

### Decisiones por limitaciones de tiempo
- **Terraform** — la infraestructura se desplegó desde local, no se logró
  automatizar en pipeline por tiempo
- **Trivy** — se tenía contemplado agregar escaneo de seguridad de imagen
  Docker en el pipeline, no se logró incorporar por tiempo
- **IaC en SonarCloud** — el escaneo de SonarCloud aplica solo al repositorio
  del aplicativo, no al repositorio de IaC
- **ACM, Route 53 y EC2 Agente** — estos recursos se aprovisionaron manualmente
  desde la consola de AWS y no desde Terraform por limitaciones de tiempo.
  Se tiene contemplado migrarlos a IaC en una iteración futura:
  - **ACM** — certificado TLS creado y validado manualmente via DNS en Route 53
  - **Route 53** — registro tipo A con Alias hacia el ALB creado manualmente
  - **EC2 Agente** — instancia del agente de Azure DevOps aprovisionada
    manualmente con las dependencias necesarias (Docker, AWS CLI, kubectl,
    Java, Node.js, Helm, eksctl)

### Componentes aplicados fuera de manifests
Algunos componentes se instalaron directamente via kubectl/helm sin manifiesto
declarativo por ser componentes de infraestructura del cluster:
- AWS Load Balancer Controller (Helm)
- Metrics Server (kubectl)
- Namespace y Service Account para Azure DevOps (kubectl)

### Service Connections en Azure DevOps
- **EKS** — configurado via kubeconfig con Service Account y token permanente
- **SonarCloud** — configurado via Service Connection de SonarQube
- **ECR** — no se logró configurar como Service Connection estático por la
  naturaleza de los tokens de ECR (expiran cada 12 horas), se implementó
  login en tiempo de ejecución via AWS CLI en el pipeline

### Comprobación en entorno local
El aplicativo se probó en entorno local y se migró a nube. Las pruebas finales
se realizaron en nube dado que el entorno local presentó problemas de
conectividad a contenedores y hosts por restricciones del firewall de Windows.
Se adjuntan comprobantes del funcionamiento en nube.

