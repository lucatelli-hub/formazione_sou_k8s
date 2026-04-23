formazione_sou_k8s

Progetto DevOps end-to-end che automatizza il provisioning di un ambiente locale Kubernetes con Jenkins, build Docker, deploy Helm e validazione tramite API Kubernetes.

Architettura
Ansible
 ├── Role Minikube
 │    ├── avvia cluster Kubernetes locale
 │    ├── crea namespace formazione-sou
 │    └── installa ingress nginx
 │
 └── Role Jenkins
      ├── build custom Jenkins image
      ├── avvia container Jenkins
      ├── configura kubectl/helm
      └── collega Jenkins al cluster Minikube


Jenkins Pipeline
 ├── build immagine Flask
 ├── push DockerHub
 └── deploy Helm


Kubernetes
 ├── Deployment
 ├── Service
 ├── Ingress
 ├── ServiceAccount
 ├── ClusterRoleBinding
 └── API validation script
Track completate
Track 1 — Ansible + Jenkins + Minikube

Automazione completa tramite Ansible:

Role minikube
verifica stato minikube
avvia cluster se spento
aggiorna kube context
crea namespace formazione-sou
abilita ingress nginx
Role jenkins
build immagine custom Jenkins
avvio container Jenkins
installazione:
docker cli
kubectl
helm
configurazione kubeconfig per comunicazione con minikube

Avvio:

ansible-playbook -i inventories/hosts deploy.yml
Track 2 — Jenkins pipeline Docker build

Applicazione Flask semplice:

return "hello world"

Pipeline Jenkins dichiarativa:

clone repository
build Docker image
push DockerHub

Tag strategy:

latest → branch main/master
develop-<commit_sha> → branch develop
git tag → stesso tag git
Track 3 — Helm Chart

Chart custom presente in:

charts/flask-chart

Deploya:

Deployment
Service
Ingress

Configurazioni principali in:

charts/flask-chart/values.yaml

Sono stati aggiunti:

replicas
readinessProbe
livenessProbe
requests
limits
Track 4 — Helm Deploy

Deploy applicazione:

helm upgrade --install flask-release ./charts/flask-chart -n formazione-sou

Verifica:

kubectl get pods -n formazione-sou
kubectl get svc -n formazione-sou
kubectl get ingress -n formazione-sou
Track 5 — Kubernetes API validation

Creato:

ServiceAccount
ClusterRoleBinding

Permette accesso in sola lettura al cluster.

File:

k8s-rbac/
├── service-account.yaml
└── cluster-role-binding.yaml

Script di validazione:

scripts/check-deployment.sh

Lo script:

autentica tramite ServiceAccount
chiama API Kubernetes
verifica presenza di:

 readinessProbe
 livenessProbe
 requests
 limits

Esempio:

./check-deployment.sh

Output:

Deployment configuration valid
Track 6 — Bonus Ingress

Installazione ingress nginx:

minikube addons enable ingress

Host configurato:

formazionesou.local

Su macOS con driver Docker è necessario usare:

minikube service ingress-nginx-controller -n ingress-nginx --url

Verifica finale:

curl -H "Host: formazionesou.local" http://<generated-url>

Output:

hello world

Stack utilizzato
Ansible
Jenkins
Docker
Minikube
Kubernetes
Helm
NGINX Ingress Controller
Flask
Risultato finale

Pipeline completa:

Code → Jenkins → Docker Image → Helm → Kubernetes → API Validation → Ingress
