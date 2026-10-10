# Script tự động Build & Deploy lên GitHub Pages
# Tác giả: Trần Thanh Phong (23IT211 - 23JIT)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " 1. Building OCR Expense Tracker for Web..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

flutter build web --release --base-href "/expense_tracker_ocr/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build Web thất bại!" -ForegroundColor Red
    exit 1
}

# Tạo tệp .nojekyll để tránh Jekyll trên GitHub Pages
"# Disable Jekyll processing for GitHub Pages" | Out-File -FilePath "build/web/.nojekyll" -Encoding utf8

Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host " 2. Đẩy nhánh gh-pages lên GitHub..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

git -C build/web init
git -C build/web checkout -B gh-pages
git -C build/web add -A
git -C build/web commit -m "deploy: update GitHub Pages build for Tran Thanh Phong (23IT211)"
git -C build/web remote add origin https://github.com/Rynnne3125/expense_tracker_ocr.git
git -C build/web push -f origin gh-pages
Remove-Item -Recurse -Force build/web/.git

Write-Host "`nDeploy thành công lên nhánh gh-pages!" -ForegroundColor Green
Write-Host "Truy cập Live Demo: https://rynnne3125.github.io/expense_tracker_ocr/" -ForegroundColor Yellow
