"""Module avec quelques fonctions de calcul."""


def celsius_vers_fahrenheit(celsius):
    """Convertit une température de Celsius vers Fahrenheit."""
    return celsius * 9 / 5 + 32


def moyenne(nombres):
    """Calcule la moyenne d'une liste de nombres."""
    if not nombres:
        raise ValueError("La liste ne peut pas être vide")
    return sum(nombres) / len(nombres)
