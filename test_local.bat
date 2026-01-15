@echo off
echo ===================================================
echo 🚀 Preparation du test local de Mon Assistant IA Mobile
echo ===================================================

echo.
echo 0. Nettoyage du projet...
call flutter clean
call flutter pub get

echo.
echo 1. Construction de l'application web...
echo (Cela peut prendre une minute)
call flutter build web --release --base-href "/"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ ERREUR DE BUILD !
    echo Verifiez les erreurs ci-dessus.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo 2. Lancement du serveur local...
echo Le navigateur va s'ouvrir automatiquement.
echo.
echo APPUYEZ SUR CTRL+C POUR ARRETER LE SERVEUR
echo.

start http://localhost:8000
python -m http.server 8000 --directory build/web
