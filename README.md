# formazione_sou_k8s

## Scopo del laboratorio

Questo laboratorio ha l'obiettivo di simulare una pipeline DevOps end-to-end partendo da una semplice applicazione Flask fino al deploy su Kubernetes locale.

Gli obiettivi principali sono:

* Comprendere le basi dei container tramite Docker
* Automatizzare installazioni tramite Ansible
* Installare e configurare Jenkins come CI tool
* Creare una pipeline dichiarativa Jenkins per build e push di immagini Docker
* Utilizzare Kubernetes in locale tramite Minikube
* Creare un Helm Chart custom per il deploy applicativo
* Effettuare controlli sulle best practices di deployment Kubernetes

Il laboratorio riproduce un flusso tipico:

GitHub → Jenkins → Docker → DockerHub → Kubernetes → Helm

---

## Requisiti

Ambiente utilizzato:

* macOS (Apple Silicon M1/M2/M3)
* Docker Desktop
* Git
* Python 3
* Homebrew

Tool richiesti:

### Docker

Installazione tramite Docker Desktop:

[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

Verifica:

```bash
docker --version
docker ps
```

---

### Ansible

```bash
brew install ansible
```

Verifica:

```bash
ansible --version
```

---

### Kubectl

```bash
brew install kubectl
```

Verifica:

```bash
kubectl version --client
```

---

### Minikube

Utilizzato al posto di Kind per semplicità nella gestione locale del cluster Kubernetes.

```bash
brew install minikube
```

Avvio cluster:

```bash
minikube start --driver=docker
```

Verifica:

```bash
kubectl get nodes
kubectl get pods -A
```

---

### Helm

```bash
brew install helm
```

Verifica:

```bash
helm version
```

---

## Struttura del progetto

```bash
formazione_sou_k8s/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── ansible/
│   ├── inventory
│   ├── deploy.yml
│   └── roles/
│
├── charts/
│   └── flask-chart/
│
├── Jenkinsfile
│
└── README.md
```

---

## Track 1 - Setup infrastruttura locale

### Applicazione Flask

Creazione di una semplice applicazione Flask che espone:

```text
hello world
```

Test locale:

```bash
docker build -t flask-test ./app
docker run -p 5000:5000 flask-test
```

---

### Installazione Jenkins tramite Ansible

Ansible viene utilizzato per automatizzare il deploy di Jenkins tramite container Docker.

Responsabilità:

* installazione dipendenze
* avvio container Jenkins
* gestione persistenza volume
* esposizione porte

Jenkins viene esposto su:

```text
http://localhost:8080
```

---

## Track 2 - CI Pipeline Jenkins

Pipeline dichiarativa Jenkins:

* checkout repository GitHub
* build immagine Docker
* push su DockerHub

Logica tagging:

* branch `main/master` → tag `latest`
* branch `develop` → tag `develop-<git-sha>`
* git tag → stesso nome del tag Git

Pipeline name:

```text
flask-app-example-build
```

Output finale:

Immagine pubblicata su DockerHub.

---

## Track 3 - Helm Chart

Creazione Helm chart custom:

```bash
helm create flask-chart
```

Successivamente modificato per:

* usare immagine Docker custom
* supportare tag dinamici
* configurare correttamente containerPort
* configurare readinessProbe
* configurare livenessProbe

Deploy:

```bash
helm install flask-release ./charts/flask-chart -n formazione-sou
```

---

## Namespace Kubernetes

Il namespace richiesto dal lab era:

```text
formazione_sou
```

Tuttavia Kubernetes non accetta underscore nei namespace.

Namespace utilizzato:

```text
formazione-sou
```

Creazione:

```bash
kubectl create namespace formazione-sou
```

---

## Track 4 - CD Pipeline

Pipeline Jenkins dedicata al deploy:

* recupera Helm chart da Git
* esegue deploy su Kubernetes

Comando principale:

```bash
helm upgrade --install flask-release ./charts/flask-chart -n formazione-sou
```

---

## Track 5 - Deployment Best Practices

Script Bash/Python per validare il deployment Kubernetes.

Controlli richiesti:

* readiness probe
* liveness probe
* resource requests
* resource limits

Lo script deve fallire se questi parametri non sono presenti.

---

## Bonus Track

Installazione Ingress NGINX:

* deploy Ingress Controller
* esposizione applicazione via hostname locale

Endpoint finale:

```text
http://formazionesou.local
```

---
