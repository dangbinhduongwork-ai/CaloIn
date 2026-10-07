@echo off
echo ===========================================
echo Pushing CaloIn project to GitHub...
echo ===========================================

git init
git add .
git commit -m "feat: complete phase 1 to 6 (History analytics, fl_chart, pure-Dart aggregator, 3-tab navigation, debug 60-day sample data)"
git branch -M main
git remote remove origin 2>nul
git remote add origin https://github.com/dangbinhduongwork-ai/CaloIn.git
git push -u origin main

echo ===========================================
echo Done! Please check https://github.com/dangbinhduongwork-ai/CaloIn
echo ===========================================
pause
