@echo off
echo ===================================================
echo 🚀 DEPLOIEMENT MANUEL VERS GITHUB
echo ===================================================

echo.
echo 1. Verification du statut Git...
git status

echo.
echo 2. Ajout des modifications...
git add .

echo.
echo 3. Commit (au cas ou)...
git commit -m "Fix: Remove web-renderer flag (CI fix)"

echo.
echo 4. Envoi vers GitHub (Push)...
echo (Une fenetre de connexion peut s'ouvrir)
git push origin main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ ERREUR DE PUSH !
    echo Verifiez votre connexion ou vos droits.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ✅ SUCCES ! Le code est envoye.
echo Regardez l'onglet 'Actions' sur GitHub dans 1 minute.
echo.
pause
