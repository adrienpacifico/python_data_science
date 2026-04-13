"""Chargement des datasets du cours pandas. Une seule source de vérité.

Ne jamais mettre d'URL en dur dans un notebook — toujours passer par ce module.

Datasets disponibles
--------------------
- Accidents corporels de la route 2024 (data.gouv.fr) — 4 tables :
    CARACTERISTIQUES  (une ligne par accident)   → load_accidents_caracteristiques()
    LIEUX             (une ligne par accident)   → load_accidents_lieux()
    VEHICULES         (une ligne par véhicule)   → load_accidents_vehicules()
    USAGERS           (une ligne par usager)     → load_accidents_usagers()
    Table fusionnée (caracteristiques + lieux)  → load_accidents()

- Palmer Penguins (seaborn)                     → load_penguins()

Schéma rapide des clés
-----------------------
    CARACTERISTIQUES ──┐
                        ├── Num_Acc (clé principale)
    LIEUX ─────────────┘
    VEHICULES ─────────── Num_Acc + num_veh + id_vehicule
    USAGERS ───────────── Num_Acc + num_veh + id_vehicule + id_usager

Colonnes notables
-----------------
CARACTERISTIQUES :
    Num_Acc  identifiant unique de l'accident
    an       année (ex : 2024)
    mois     mois (1-12)
    jour     jour du mois (1-31)
    hrmn     heure:minute au format "HH:MM" (str)
    dep      code département (int, ex : 75)
    lum      conditions de luminosité (1=plein jour … 5=nuit sans éclairage)
    atm      conditions atmosphériques (1=normale … 8=autres)
    col      type de collision (1=deux véhicules-frontale … 7=sans collision)
    lat/long coordonnées GPS (str, décimale)

LIEUX :
    catr     catégorie de route (1=autoroute … 9=autre)
    surf     état de la surface (1=normale … 9=autre)
    circ     régime de circulation (1=sens unique … 4=variable)
    vma      vitesse maximale autorisée (km/h)

VEHICULES :
    catv     catégorie de véhicule (1=bicyclette … 99=autre)
    manv     manœuvre avant accident
    motor    motorisation (1=hydrocarbures … 5=électrique)

USAGERS :
    catu     catégorie d'usager (1=conducteur, 2=passager, 3=piéton)
    grav     gravité (1=indemne, 2=tué, 3=blessé hospitalisé, 4=blessé léger)
    sexe     sexe (1=masculin, 2=féminin)
    an_nais  année de naissance
    trajet   motif du déplacement (1=domicile-travail … 9=autre)
"""
from __future__ import annotations

import pandas as pd
import seaborn as sns

# URLs stables data.gouv.fr — 4 tables, année 2024
# Source : https://www.data.gouv.fr/datasets/bases-de-donnees-annuelles-des-accidents-corporels-de-la-circulation-routiere-annees-de-2005-a-2024
ACCIDENTS_CARACTERISTIQUES_URL = "https://www.data.gouv.fr/fr/datasets/r/83f0fb0e-e0ef-47fe-93dd-9aaee851674a"  # caract-2024.csv
ACCIDENTS_LIEUX_URL            = "https://www.data.gouv.fr/fr/datasets/r/228b3cda-fdfb-4677-bd54-ab2107028d2d"  # lieux-2024.csv
ACCIDENTS_VEHICULES_URL        = "https://www.data.gouv.fr/fr/datasets/r/fd30513c-6b11-4a56-b6dc-5ac87728794b"  # vehicules-2024.csv
ACCIDENTS_USAGERS_URL          = "https://www.data.gouv.fr/fr/datasets/r/f57b1f58-386d-4048-8f78-2ebe435df868"  # usagers-2024.csv


def load_accidents_caracteristiques() -> pd.DataFrame:
    """Circonstances générales de l'accident (une ligne par accident).

    Colonnes clés : Num_Acc, an, mois, jour, hrmn, dep, lum, atm, col, lat, long.
    """
    return pd.read_csv(ACCIDENTS_CARACTERISTIQUES_URL, sep=";", low_memory=False)


def load_accidents_lieux() -> pd.DataFrame:
    """Lieu principal de l'accident (une ligne par accident).

    Colonnes clés : Num_Acc, catr, surf, circ, nbv, prof, vma.
    """
    return pd.read_csv(ACCIDENTS_LIEUX_URL, sep=";", low_memory=False)


def load_accidents_vehicules() -> pd.DataFrame:
    """Véhicules impliqués (une ligne par véhicule dans un accident).

    Colonnes clés : Num_Acc, id_vehicule, num_veh, catv, manv, motor.
    """
    return pd.read_csv(ACCIDENTS_VEHICULES_URL, sep=";", low_memory=False)


def load_accidents_usagers() -> pd.DataFrame:
    """Usagers impliqués (une ligne par usager dans un accident).

    Colonnes clés : Num_Acc, id_usager, id_vehicule, num_veh,
    catu (1=conducteur, 2=passager, 3=piéton),
    grav (1=indemne, 2=tué, 3=blessé hospitalisé, 4=blessé léger),
    sexe (1=masculin, 2=féminin), an_nais, trajet.
    """
    return pd.read_csv(ACCIDENTS_USAGERS_URL, sep=";", low_memory=False)


def load_accidents() -> pd.DataFrame:
    """Table unique = caracteristiques + lieux mergés sur Num_Acc (left join).

    Point d'entrée simplifié pour les notebooks qui n'ont pas encore vu les jointures
    (notebooks 1, 3, 5, 6, 7, 8, 9). Les notebooks de merge (4.1) appellent directement
    les 4 loaders ci-dessus pour travailler sur les vraies tables séparées.

    Résultat : toutes les colonnes de CARACTERISTIQUES + toutes les colonnes de LIEUX
    (sauf Num_Acc dupliqué).
    """
    caract = load_accidents_caracteristiques()
    lieux = load_accidents_lieux()
    return caract.merge(lieux, on="Num_Acc", how="left")


def load_penguins() -> pd.DataFrame:
    """Palmer Penguins (seaborn). Petit dataset propre pour démos courtes.

    Colonnes : species, island, bill_length_mm, bill_depth_mm,
    flipper_length_mm, body_mass_g, sex.
    """
    return sns.load_dataset("penguins")
