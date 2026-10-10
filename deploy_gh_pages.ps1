# Script deploy lên GitHub Pages tự động cho dự án
# Tác giả: Trần Thanh Phong (23IT211 - 23JIT)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Building OCR Expense Tracker for Web... " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

flutter build web --release --base-href "/expense_tracker_ocr/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build Web failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nBuild thành công! Thư mục build/web đã sẵn sàng." -ForegroundColor Green
Write-Host "GitHub Actions (.github/workflows/deploy.yml) sẽ tự động deploy lên GitHub Pages khi bạn push mã nguồn lên nhánh main." -ForegroundColor Yellow
Write-Host "Hoặc bạn có thể chọn Settings -> Pages -> Deploy from a branch trên GitHub." -ForegroundColor Yellow
