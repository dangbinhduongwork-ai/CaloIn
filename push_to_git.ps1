Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Pushing CaloIn project to GitHub..." -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

git init
git add .
git commit -m "feat: complete phase 1 to 6 (History analytics, fl_chart, pure-Dart aggregator, 3-tab navigation, debug 60-day sample data)"
git branch -M main
try {
    git remote remove origin 2>$null
} catch {}
git remote add origin https://github.com/dangbinhduongwork-ai/CaloIn.git
git push -u origin main

Write-Host "===========================================" -ForegroundColor Green
Write-Host "Done! Please check https://github.com/dangbinhduongwork-ai/CaloIn" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
