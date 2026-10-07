Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Pushing CaloIn project to GitHub..." -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan

git init
git add .
git commit -m "feat: complete phase 1, 2, and 3 for CaloIn"
git branch -M main
try {
    git remote remove origin 2>$null
} catch {}
git remote add origin https://github.com/dangbinhduongwork-ai/CaloIn.git
git push -u origin main

Write-Host "===========================================" -ForegroundColor Green
Write-Host "Done! Please check https://github.com/dangbinhduongwork-ai/CaloIn" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
