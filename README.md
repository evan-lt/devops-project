# 🚀 DevOps Project — Full Pipeline Demo

> Flask app deployed with Docker, GitHub Actions CI/CD, Kubernetes, and Terraform.

---

## 📐 Architecture

```
┌─────────────┐     push      ┌──────────────────────────────────────┐
│  Developer  │ ─────────────▶│         GitHub Repository            │
└─────────────┘               └──────────────────────────────────────┘
                                          │
                               GitHub Actions CI/CD
                                          │
                    ┌─────────────────────┼─────────────────────┐
                    ▼                     ▼                     ▼
             🧪 Run Tests        🐳 Build & Push         🚀 Deploy
              (pytest)          (Docker Hub)          (kubectl apply)
                                                             │
                                                    ┌────────▼────────┐
                                                    │   Kubernetes    │
                                                    │  (minikube)     │
                                                    │                 │
                                                    │  ┌───────────┐  │
                                                    │  │  Pod x2   │  │
                                                    │  │  Flask    │  │
                                                    │  │  app      │  │
                                                    │  └───────────┘  │
                                                    └─────────────────┘
                                                    (provisionné par Terraform)
```

## 📁 Structure du projet

```
devops-project/
├── app/
│   ├── app.py              # Application Flask
│   ├── test_app.py         # Tests unitaires (pytest)
│   └── requirements.txt
├── docker/
│   ├── Dockerfile          # Multi-stage build
│   └── nginx.conf          # Reverse proxy config
├── k8s/
│   ├── deployment.yaml     # Kubernetes Deployment (2 replicas)
│   └── service.yaml        # NodePort Service + Namespace
├── terraform/
│   └── main.tf             # IaC : namespace + deployment + service
├── .github/
│   └── workflows/
│       └── ci-cd.yml       # Pipeline : test → build → deploy
├── docker-compose.yml      # Dev local
├── .gitignore
└── README.md
```

---

## 🛠️ Stack technique

| Outil | Rôle |
|---|---|
| **Flask** | Application web Python |
| **Docker** | Containerisation (multi-stage build) |
| **Docker Compose** | Dev local avec Nginx |
| **GitHub Actions** | CI/CD : test, build, push, deploy |
| **Kubernetes / minikube** | Orchestration des containers |
| **Terraform** | Infrastructure as Code |

---

## 🚀 Lancer le projet

### 1. En local avec Docker Compose

```bash
# Cloner le repo
git clone https://github.com/YOUR_USERNAME/devops-project.git
cd devops-project

# Lancer l'app + nginx
docker compose up --build

# Tester
curl http://localhost/
curl http://localhost/health
curl http://localhost/info
```

### 2. Tests unitaires

```bash
cd app
pip install -r requirements.txt
pytest test_app.py -v
```

### 3. Déploiement Kubernetes (minikube)

```bash
# Démarrer minikube
minikube start

# Créer le namespace et déployer
kubectl apply -f k8s/service.yaml    # namespace d'abord
kubectl apply -f k8s/deployment.yaml

# Vérifier
kubectl get pods -n devops-project
kubectl get svc -n devops-project

# Accéder à l'app
minikube service devops-demo-service -n devops-project
```

### 4. Terraform (Infrastructure as Code)

```bash
cd terraform

# Initialiser les providers
terraform init

# Voir ce qui sera créé
terraform plan

# Appliquer
terraform apply

# Détruire l'infra
terraform destroy
```

---

## ⚙️ CI/CD — GitHub Actions

La pipeline se déclenche automatiquement sur chaque `push` sur `main` :

| Étape | Déclencheur | Action |
|---|---|---|
| **Test** | Tout push | `pytest` sur l'app Flask |
| **Build** | Push sur `main` | Build image Docker + push sur Docker Hub |
| **Deploy** | Après build | `kubectl set image` + rollout |

### Secrets GitHub à configurer

Dans `Settings > Secrets and variables > Actions` :

| Secret | Valeur |
|---|---|
| `DOCKERHUB_USERNAME` | Ton username Docker Hub |
| `DOCKERHUB_TOKEN` | Token d'accès Docker Hub |
| `KUBECONFIG` | Contenu de `~/.kube/config` encodé en base64 |

---

## 🌐 Endpoints de l'API

| Route | Description |
|---|---|
| `GET /` | Message de bienvenue + hostname + version |
| `GET /health` | Health check (utilisé par k8s) |
| `GET /info` | Infos sur l'app et la stack |

---

## 👤 Auteur

- **Nom** : [Ton nom]
- **Projet** : Session 2 — DevOps Project Presentation
