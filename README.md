### Python pour la data science

Ce repository est une collection de notebooks et de ressources utiles pour débuter en data science.
Chaque section est séparé dans un dossier:
1. Python:   
Ce dossier reprends des bases et des notions allant de débutant à intermédiaire en python.
2. Pandas:  
Ce dossier contient une collection de notebook constituant une introduction à pandas.  
3. plot:  
Ce dossier contient quelques éléments pour réaliser des plot pandas et les backends matplotlib et plotly, soit directement via ces libraires.

**Consulter le cours en ligne** : [https://adrienpacifico.github.io/python_data_science/](https://adrienpacifico.github.io/python_data_science/)

Lancez les notebooks via Binder en cliquant sur :  [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/adrienpacifico/python_data_science/HEAD?urlpath=lab)


### Lancer le cours en local

#### Via uv (recommandé)

Installer [uv](https://docs.astral.sh/uv/getting-started/installation/) puis :

```bash
uv sync
uv run jupyter lab
```

#### Via repo2Docker

Il est nécessaire d'avoir `Docker` d'installé sur son ordinateur, puis d'installer `repo2docker` ( via `python3 -m pip install jupyter-repo2docker` )

Ensuite il suffit de se placer à la racine de ce repo puis d'exécuter via son terminal: 
`jupyter-repo2docker --editable .` 

Si `make` est installé sur votre machine, vous pouvez à la place lancer la commande `make  start-repo-2-docker-editable`.

#### Via Docker

```bash
docker build -t python_data_science .
docker run -it -v "${PWD}":/home/docker/app -p 8888:8888 python_data_science
```

---

### Site Quarto (navigation web du cours)

Les notebooks sont également disponibles sous forme de site web navigable grâce à [Quarto](https://quarto.org/).

**Site déployé** : [https://adrienpacifico.github.io/python_data_science/](https://adrienpacifico.github.io/python_data_science/)

Le site est automatiquement mis à jour via GitHub Actions à chaque push sur `main`. La configuration se trouve dans `_quarto.yml`.

#### Prévisualiser en local

Installer Quarto : https://quarto.org/docs/get-started/

```bash
quarto preview
```

#### Générer le site statique

```bash
quarto render
```

Le site est généré dans le dossier `_site/`.
