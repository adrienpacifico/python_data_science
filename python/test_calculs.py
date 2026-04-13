"""Tests pour le module calculs."""
import pytest
from calculs import celsius_vers_fahrenheit, moyenne


def test_celsius_vers_fahrenheit_eau_gele():
    assert celsius_vers_fahrenheit(0) == 32


def test_celsius_vers_fahrenheit_eau_bout():
    assert celsius_vers_fahrenheit(100) == 212


def test_moyenne_simple():
    assert moyenne([10, 20, 30]) == 20


def test_moyenne_un_seul_element():
    assert moyenne([42]) == 42


def test_moyenne_liste_vide_leve_erreur():
    with pytest.raises(ValueError):
        moyenne([])
