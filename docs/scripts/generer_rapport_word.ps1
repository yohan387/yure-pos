# Script PowerShell pour generer le rapport Word
# Genere RAPPORT_PROGRESSION_MANAGER.docx

$outputPath = "C:\Users\bobo\projects\yure\pos-app\docs\RAPPORT_PROGRESSION_MANAGER.docx"

# Creer une instance Word
$word = New-Object -ComObject Word.Application
$word.Visible = $false

# Creer un nouveau document
$doc = $word.Documents.Add()
$selection = $word.Selection

# ===== PAGE DE GARDE =====
$selection.Font.Name = "Segoe UI"
$selection.Font.Size = 28
$selection.Font.Bold = $true
$selection.Font.Color = 0x81B900 # Vert
$selection.ParagraphFormat.Alignment = 1 # Center
$selection.TypeText("RAPPORT DE PROGRESSION")
$selection.TypeParagraph()

$selection.Font.Size = 20
$selection.Font.Color = 0x000000
$selection.TypeText("Application Mobile POS")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.ParagraphFormat.Alignment = 0 # Left
$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.Font.Color = 0x7280A0
$selection.TypeText("Date: 8 Janvier 2025")
$selection.TypeParagraph()
$selection.TypeText("Projet: YURE Mobile POS - Features Bonheur")
$selection.TypeParagraph()
$selection.TypeText("Type: Rapport managerial synthetique")
$selection.TypeParagraph()
$selection.TypeParagraph()

# Separateur
for ($i = 0; $i -lt 80; $i++) { $selection.TypeText("_") }
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== VUE D'ENSEMBLE =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0xF68206 # Orange
$selection.TypeText("VUE D'ENSEMBLE")
$selection.TypeParagraph()
$selection.TypeParagraph()

# Tableau Indicateurs Cles
$selection.Font.Size = 11
$selection.Font.Bold = $false
$selection.Font.Color = 0x000000

$table1 = $doc.Tables.Add($selection.Range, 7, 3)
$table1.Borders.Enable = $true
$table1.Style = "Grid Table 4 - Accent 1"

$table1.Cell(1, 1).Range.Text = "Metrique"
$table1.Cell(1, 2).Range.Text = "Valeur"
$table1.Cell(1, 3).Range.Text = "Statut"

$table1.Cell(2, 1).Range.Text = "Taches totales"
$table1.Cell(2, 2).Range.Text = "50"
$table1.Cell(2, 3).Range.Text = "OK"

$table1.Cell(3, 1).Range.Text = "Taches terminees"
$table1.Cell(3, 2).Range.Text = "17"
$table1.Cell(3, 3).Range.Text = "TERMINE"

$table1.Cell(4, 1).Range.Text = "Taches en cours"
$table1.Cell(4, 2).Range.Text = "0"
$table1.Cell(4, 3).Range.Text = "-"

$table1.Cell(5, 1).Range.Text = "Taches a faire"
$table1.Cell(5, 2).Range.Text = "33"
$table1.Cell(5, 3).Range.Text = "A FAIRE"

$table1.Cell(6, 1).Range.Text = "Points de blocage"
$table1.Cell(6, 2).Range.Text = "0"
$table1.Cell(6, 3).Range.Text = "AUCUN"

$table1.Cell(7, 1).Range.Text = "Progression globale"
$table1.Cell(7, 2).Range.Text = "34%"
$table1.Cell(7, 2).Range.Font.Bold = $true
$table1.Cell(7, 2).Range.Font.Size = 14
$table1.Cell(7, 3).Range.Text = "EN COURS"

$selection.EndKey(6)
$selection.TypeParagraph()
$selection.TypeParagraph()

# Budget Temps
$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.TypeText("Budget Temps")
$selection.TypeParagraph()

$table2 = $doc.Tables.Add($selection.Range, 3, 4)
$table2.Borders.Enable = $true
$table2.Style = "Grid Table 4 - Accent 1"

$table2.Cell(1, 1).Range.Text = "Categorie"
$table2.Cell(1, 2).Range.Text = "Consomme"
$table2.Cell(1, 3).Range.Text = "Total"
$table2.Cell(1, 4).Range.Text = "Pourcentage"

$table2.Cell(2, 1).Range.Text = "Heures realisees"
$table2.Cell(2, 2).Range.Text = "18.5h"
$table2.Cell(2, 3).Range.Text = "53.5h"
$table2.Cell(2, 4).Range.Text = "34.6%"

$table2.Cell(3, 1).Range.Text = "Heures restantes"
$table2.Cell(3, 2).Range.Text = "35h"
$table2.Cell(3, 3).Range.Text = "53.5h"
$table2.Cell(3, 4).Range.Text = "65.4%"

$selection.EndKey(6)
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== NOUVELLE PAGE =====
$selection.InsertBreak(7) # Page break

# ===== PROGRESSION PAR PRIORITE =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0xF68206
$selection.TypeText("PROGRESSION PAR PRIORITE")
$selection.TypeParagraph()
$selection.TypeParagraph()

$table3 = $doc.Tables.Add($selection.Range, 6, 5)
$table3.Borders.Enable = $true
$table3.Style = "Grid Table 4 - Accent 1"

$table3.Cell(1, 1).Range.Text = "Priorite"
$table3.Cell(1, 2).Range.Text = "Completees"
$table3.Cell(1, 3).Range.Text = "Total"
$table3.Cell(1, 4).Range.Text = "% Acheve"
$table3.Cell(1, 5).Range.Text = "Heures"

$table3.Cell(2, 1).Range.Text = "CRITIQUE"
$table3.Cell(2, 2).Range.Text = "1"
$table3.Cell(2, 3).Range.Text = "1"
$table3.Cell(2, 4).Range.Text = "100%"
$table3.Cell(2, 5).Range.Text = "3h/3h"
$table3.Cell(2, 4).Range.Shading.BackgroundPatternColor = 0xCCFFCC

$table3.Cell(3, 1).Range.Text = "HAUTE"
$table3.Cell(3, 2).Range.Text = "12"
$table3.Cell(3, 3).Range.Text = "34"
$table3.Cell(3, 4).Range.Text = "35%"
$table3.Cell(3, 5).Range.Text = "12h/34h"
$table3.Cell(3, 4).Range.Shading.BackgroundPatternColor = 0xFFEECC

$table3.Cell(4, 1).Range.Text = "MOYENNE"
$table3.Cell(4, 2).Range.Text = "2"
$table3.Cell(4, 3).Range.Text = "8"
$table3.Cell(4, 4).Range.Text = "25%"
$table3.Cell(4, 5).Range.Text = "2.5h/9h"
$table3.Cell(4, 4).Range.Shading.BackgroundPatternColor = 0xFFEECC

$table3.Cell(5, 1).Range.Text = "UX"
$table3.Cell(5, 2).Range.Text = "1"
$table3.Cell(5, 3).Range.Text = "4"
$table3.Cell(5, 4).Range.Text = "25%"
$table3.Cell(5, 5).Range.Text = "1h/5h"
$table3.Cell(5, 4).Range.Shading.BackgroundPatternColor = 0xFFEECC

$table3.Cell(6, 1).Range.Text = "CONFIG"
$table3.Cell(6, 2).Range.Text = "1"
$table3.Cell(6, 3).Range.Text = "3"
$table3.Cell(6, 4).Range.Text = "33%"
$table3.Cell(6, 5).Range.Text = "1h/2.5h"
$table3.Cell(6, 4).Range.Shading.BackgroundPatternColor = 0xFFEECC

$selection.EndKey(6)
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== JAUGE DE PROGRESSION =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0xF68206
$selection.TypeText("JAUGE DE PROGRESSION")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 14
$selection.Font.Bold = $false
$selection.Font.Color = 0x000000
$selection.TypeText("Progression visuelle:")
$selection.TypeParagraph()

# Barre de progression textuelle
$selection.Font.Size = 12
$selection.Font.Name = "Courier New"
$selection.Font.Color = 0x81B900
$selection.TypeText("[")
for ($i = 0; $i -lt 34; $i++) { $selection.TypeText("=") }
$selection.TypeText(">")
$selection.Font.Color = 0xCCCCCC
for ($i = 0; $i -lt 66; $i++) { $selection.TypeText("-") }
$selection.Font.Color = 0x000000
$selection.TypeText("]")
$selection.TypeParagraph()

$selection.Font.Size = 16
$selection.Font.Bold = $true
$selection.Font.Name = "Segoe UI"
$selection.Font.Color = 0x81B900
$selection.TypeText("34% complete")
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== NOUVELLE PAGE =====
$selection.InsertBreak(7)

# ===== TACHES COMPLETEES =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0x81B900
$selection.TypeText("TACHES COMPLETEES (17)")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.Font.Color = 0x000000

# Securite
$selection.Font.Bold = $true
$selection.Font.Size = 13
$selection.TypeText("Securite (1 tache)")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 11
$selection.TypeText("  - APP-017 : Cles d'idempotence (prevention doublons paiements)")
$selection.TypeParagraph()
$selection.TypeParagraph()

# Authentification
$selection.Font.Bold = $true
$selection.Font.Size = 13
$selection.TypeText("Authentification (12 taches)")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 11

$authTasks = @(
    "APP-001 : Ecran connexion email/mot de passe",
    "APP-002 : Envoi OTP",
    "APP-003 : Validation OTP",
    "APP-004 : Gestion OTP invalide",
    "APP-005 : Gestion OTP expire",
    "APP-006 : Renvoyer OTP",
    "APP-007 : Selection terminal",
    "APP-008 : Creation code PIN",
    "APP-009 : Confirmation PIN",
    "APP-010 : Ignorer creation PIN",
    "APP-011 : Ecran saisie PIN au demarrage",
    "APP-012 : Validation PIN"
)

foreach ($task in $authTasks) {
    $selection.TypeText("  - $task")
    $selection.TypeParagraph()
}
$selection.TypeParagraph()

# Format
$selection.Font.Bold = $true
$selection.Font.Size = 13
$selection.TypeText("Format & Affichage (1 tache)")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 11
$selection.TypeText("  - APP-016 : Affichage montants en XOF")
$selection.TypeParagraph()
$selection.TypeParagraph()

# Paiements
$selection.Font.Bold = $true
$selection.Font.Size = 13
$selection.TypeText("Paiements (2 taches)")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 11
$selection.TypeText("  - APP-PAY-001 : Ecran paiement principal")
$selection.TypeParagraph()
$selection.TypeText("  - APP-PAY-002 : Selection mode de paiement")
$selection.TypeParagraph()
$selection.TypeParagraph()

# UX & Config
$selection.Font.Bold = $true
$selection.Font.Size = 13
$selection.TypeText("UX & Configuration (2 taches)")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 11
$selection.TypeText("  - APP-UI-001 : Design coherent")
$selection.TypeParagraph()
$selection.TypeText("  - APP-SETTINGS-001 : Ecran parametres")
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== NOUVELLE PAGE =====
$selection.InsertBreak(7)

# ===== PROCHAINES ETAPES =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0x0682F6
$selection.TypeText("PROCHAINES ETAPES")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.Font.Color = 0x000000

$selection.Font.Bold = $true
$selection.TypeText("Priorite 1: Finaliser l'Authentification")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.TypeText("  - 3 taches restantes (PIN invalide, Code oublie, Changement terminal)")
$selection.TypeParagraph()
$selection.TypeText("  - Impact: Securisation complete de l'acces")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Bold = $true
$selection.TypeText("Priorite 2: KYC Mobile")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.TypeText("  - 20 taches a realiser")
$selection.TypeParagraph()
$selection.TypeText("  - Impact critique: Conformite reglementaire")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Bold = $true
$selection.TypeText("Priorite 3: Workflows Paiements")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.TypeText("  - 5 taches restantes")
$selection.TypeParagraph()
$selection.TypeText("  - Impact: Experience utilisateur complete")
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== POINTS DE BLOCAGE =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0x81B900
$selection.TypeText("POINTS DE BLOCAGE")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 14
$selection.Font.Bold = $true
$selection.Font.Color = 0x81B900
$selection.TypeText("AUCUN BLOCAGE IDENTIFIE")
$selection.TypeParagraph()
$selection.Font.Bold = $false
$selection.Font.Size = 12
$selection.Font.Color = 0x7280A0
$selection.TypeText("Developpement fluide")
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== RECOMMANDATIONS =====
$selection.Font.Size = 18
$selection.Font.Bold = $true
$selection.Font.Color = 0x0682F6
$selection.TypeText("RECOMMANDATIONS")
$selection.TypeParagraph()
$selection.TypeParagraph()

$selection.Font.Size = 12
$selection.Font.Bold = $false
$selection.Font.Color = 0x000000
$selection.TypeText("1. Accelerer le KYC: 20 taches critiques pour conformite reglementaire")
$selection.TypeParagraph()
$selection.TypeText("2. Excellent rythme: Authentification quasi terminee (80% complete)")
$selection.TypeParagraph()
$selection.TypeText("3. Momentum positif: 34% du projet realise en phase initiale")
$selection.TypeParagraph()
$selection.TypeParagraph()

# ===== FOOTER =====
$selection.TypeParagraph()
$selection.Font.Size = 10
$selection.Font.Color = 0xA0A8B0
$selection.Font.Italic = $true
$selection.ParagraphFormat.Alignment = 1
$selection.TypeText("Rapport genere automatiquement | YURE POS Mobile")

# Sauvegarder le document
$doc.SaveAs([ref]$outputPath)
$doc.Close()
$word.Quit()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "Rapport Word genere avec succes: $outputPath" -ForegroundColor Green
