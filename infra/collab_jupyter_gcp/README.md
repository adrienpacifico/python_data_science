# JupyterLab collaboratif sur GCP

Cette infra crée une VM GCP simple avec :

- une IP publique statique
- une VM Spot `e2-standard-2` avec 8 Go de RAM et 2 vCPU
- JupyterLab lancé en mode collaboratif sur le port `8888`
- un token partagé pour l'accès

## Pré-requis côté GCP

1. Avoir un projet GCP avec la facturation activée.
2. Authentifier `gcloud` :

```bash
gcloud auth login
gcloud auth application-default login
```

3. Activer l'API Compute Engine :

```bash
gcloud services enable compute.googleapis.com --project YOUR_PROJECT_ID
```

## Préparer la config

Copier le fichier d'exemple :

```bash
cp collaborative_jupyter.env.example collaborative_jupyter.env
```

Puis renseigner au minimum :

- `GCP_PROJECT_ID`
- `JUPYTER_TOKEN`

Le reste peut rester tel quel si tu veux une VM en `e2-standard-2` dans `europe-west9-b`.

Par défaut, `SPOT_INSTANCE="true"` pour réduire le coût. La contrepartie est que GCP peut arrêter la VM à tout moment.

## Commandes

Depuis la racine du repo :

```bash
./collaborative_jupyter.sh deploy
./collaborative_jupyter.sh status
./collaborative_jupyter.sh stop
./collaborative_jupyter.sh start
./collaborative_jupyter.sh destroy
```

## URL d'accès

Le script affiche une URL de cette forme :

```text
http://IP_PUBLIQUE:8888/lab?token=TON_TOKEN
```

## Déposer des notebooks

Le répertoire servi par JupyterLab sur la VM est :

```text
/srv/collab-notebooks
```

Tu peux :

- uploader un notebook directement depuis l'interface JupyterLab
- te connecter en SSH à la VM pour copier des fichiers

## Note pratique

Le mode collaboratif fonctionne si tout le monde ouvre le même notebook dans le même JupyterLab. Les participants partageront alors le document et son exécution dans le navigateur.
