@echo off
echo ===========================================
echo Pushing CaloIn project to GitHub...
echo ===========================================

git init
git add .
git commit -m "feat: add Open Food Facts barcode scanning with offline fallback (Phase 8)"
git branch -M main
git remote remove origin 2>nul
git remote add origin https://github.com/dangbinhduongwork-ai/CaloIn.git
git push -u origin main

echo ===========================================
echo Done! Please check https://github.com/dangbinhduongwork-ai/CaloIn
echo ===========================================
pause
