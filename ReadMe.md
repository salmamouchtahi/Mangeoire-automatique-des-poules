# Mangeoire Intelligente Connectée – IoT & Intelligence Artificielle

## 1. Présentation du projet

Ce projet consiste à concevoir et réaliser une mangeoire intelligente destinée à automatiser la surveillance de l'alimentation des volailles grâce aux technologies de l'Internet des Objets (IoT) et de l'Intelligence Artificielle.

Le système permet de surveiller le niveau de nourriture, de détecter automatiquement la présence de rats à l'aide d'un modèle de détection basé sur YOLOv8 et de suivre l'état de la mangeoire à distance via une application mobile.

Des notifications sont générées en temps réel lorsqu'un rat est détecté ou lorsque le niveau de nourriture devient insuffisant.

## 2. Objectifs du projet

- Automatiser la surveillance des mangeoires.
- Mesurer le niveau de nourriture en temps réel.
- Détecter automatiquement la présence de rats grâce à l'intelligence artificielle.
- Permettre la surveillance à distance depuis une application mobile.
- Informer l'utilisateur en cas de situation anormale grâce aux notifications.
- Réduire les pertes de nourriture et les risques de contamination.

## 3. Fonctionnalités principales

- Surveillance visuelle à l'aide d'une caméra ESP32-CAM.
- Mesure du niveau de nourriture avec un capteur ultrasonique.
- Détection des rats par vision par ordinateur avec YOLOv8.
- Transmission des données via Wi-Fi.
- Traitement des données à travers un serveur FastAPI.
- Affichage du niveau de nourriture et de l'état de la mangeoire.
- Visualisation du flux vidéo en temps réel.
- Notifications en cas de détection d'un rat ou de niveau de nourriture insuffisant.

## 4. Architecture du système

Le système repose sur l'interaction entre plusieurs composants matériels et logiciels :

| Composant | Rôle |
|---|---|
| ESP32-CAM | Capture des images et surveillance visuelle |
| Capteur ultrasonique | Mesure du niveau de nourriture |
| YOLOv8 | Détection automatique des rats |
| FastAPI | Traitement et gestion des données |
| Flutter | Développement de l'application mobile |
| Wi-Fi | Communication entre les composants |

## 5. Technologies utilisées

**Internet des Objets (IoT)**
- ESP32
- ESP32-CAM
- Capteur ultrasonique

**Intelligence Artificielle**
- Python
- YOLOv8
- Deep Learning
- Computer Vision

**Développement Backend**
- FastAPI

**Développement Mobile**
- Flutter

**Communication**
- Wi-Fi
- Notifications en temps réel

## 6. Fonctionnement général

1. La caméra ESP32-CAM capture les images de l'environnement de la mangeoire.
2. Le modèle YOLOv8 analyse les images afin de détecter la présence éventuelle de rats.
3. Le capteur ultrasonique mesure le niveau de nourriture disponible.
4. Les données collectées sont transmises au serveur FastAPI pour traitement.
5. L'application mobile Flutter affiche les informations relatives à l'état de la mangeoire.
6. Une notification est envoyée à l'utilisateur lorsqu'un rat est détecté ou lorsque le niveau de nourriture devient inférieur au seuil prédéfini.

## 7. Perspectives d'amélioration

- Ajouter un système de distribution automatique de nourriture.
- Intégrer plusieurs mangeoires dans une seule application.
- Enregistrer l'historique des mesures et des détections.
- Ajouter un tableau de bord statistique.
- Améliorer les performances du modèle de détection.



**Établissement :** Faculté des Sciences Aïn Chock – Université Hassan II de Casablanca

**Année universitaire :** 2025–2026
