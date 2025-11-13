# 📁 DOCUMENTATION YURE MOBILE POS

> Organisation de la documentation du projet YURE Mobile POS

---

## 📂 Structure des Dossiers

### 📊 `rapports/`
Rapports officiels générés pour l'équipe managériale et technique

**Contenu :**
- `RAPPORT_PROGRESSION_MANAGER.*` - Rapport de progression des features (Markdown, Word, PDF)
- `RAPPORT_TESTS_UNITAIRES.*` - Rapport d'initiative tests TDD (Markdown, Word, PDF)

**Usage :** Présentations managériales, revues de projet, documentation qualité

---

### 🔧 `scripts/`
Scripts d'automatisation pour la génération de rapports

**Contenu :**
- `generer_rapport_word.ps1` - Script PowerShell pour générer le rapport de progression en Word
- `generer_rapport_tests_word.ps1` - Script PowerShell pour générer le rapport tests en Word

**Usage :** Régénérer les rapports Word à partir des Markdown

**Exemple d'exécution :**
```powershell
powershell -ExecutionPolicy Bypass -File "docs/scripts/generer_rapport_word.ps1"
```

---

### 📋 `suivi-projet/`
Documents de suivi et planification du projet

**Contenu :**
- `MOBILE_FEATURES_TRACKER.md` - Tracker complet des 50 features mobiles
- `Plan_Correction_avec_resume.xlsx` - Plan Excel avec suivi détaillé

**Usage :** Suivi quotidien, planification sprints, gestion backlog

---

### 📦 `donnees-brutes/`
Données brutes et exports temporaires

**Contenu :**
- `full_excel_output.txt` - Export brut du fichier Excel de planification
- Autres fichiers temporaires ou dumps de données

**Usage :** Archivage, debugging, référence technique

---

### 🏗️ `features/`
Documentation détaillée par feature (architecture existante)

**Contenu :**
- Documentation technique spécifique à chaque feature
- Spécifications fonctionnelles
- Diagrammes et schémas

**Usage :** Référence développeurs, onboarding équipe

---

## 📖 Comment Utiliser Cette Documentation

### Pour les Managers
1. Consultez `rapports/` pour les rapports de progression
2. Utilisez `suivi-projet/MOBILE_FEATURES_TRACKER.md` pour le suivi global

### Pour les Développeurs
1. Référez-vous à `features/` pour la documentation technique
2. Consultez `rapports/RAPPORT_TESTS_UNITAIRES.md` pour comprendre la stratégie TDD

### Pour Régénérer les Rapports
1. Modifiez les fichiers Markdown dans `rapports/`
2. Exécutez les scripts depuis `scripts/`
3. Les nouveaux fichiers Word/PDF seront générés dans `rapports/`

---

## 🔄 Maintenance

**Fréquence de mise à jour :**
- `rapports/` : Hebdomadaire ou à chaque milestone
- `suivi-projet/` : Quotidien ou après chaque feature complétée
- `scripts/` : Maintenir lors de changements de format
- `donnees-brutes/` : Nettoyer mensuellement

---

## 📝 Conventions de Nommage

**Rapports :**
- Format : `RAPPORT_[TYPE]_[OPTIONNEL].[ext]`
- Exemple : `RAPPORT_PROGRESSION_MANAGER.docx`

**Scripts :**
- Format : `generer_[objet]_[format].ps1`
- Exemple : `generer_rapport_word.ps1`

**Tracking :**
- Format : `[OBJET]_TRACKER.md` ou `Plan_[Description].xlsx`
- Exemple : `MOBILE_FEATURES_TRACKER.md`

---

## 📞 Support

Pour toute question sur la documentation :
1. Vérifiez ce README
2. Consultez les fichiers Markdown pour les détails
3. Référez-vous au CLAUDE.md à la racine du projet pour l'architecture globale

---

**Dernière mise à jour :** 8 Janvier 2025
**Projet :** YURE Mobile POS
**Équipe :** Développement YURE
