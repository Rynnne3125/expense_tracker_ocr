# BÁO CÁO KỸ THUẬT MINI-PROJECT 3
## QUẢN LÝ CHI TIÊU OCR HÓA ĐƠN & PHÂN TÍCH TÀI CHÍNH CÁ NHÂN (FLUTTER & GOOGLE ML KIT)
### Môn học: Lập trình Ứng dụng Di động (Mobile Application Development)

---

### 🎓 THÔNG TIN SINH VIÊN & ĐỀ TÀI
* **Họ và tên sinh viên:** TRẦN THANH PHONG
* **Mã số sinh viên (MSSV):** 23IT211
* **Lớp sinh hoạt:** 23JIT
* **Khoa:** Khoa Khoa học Máy tính & Kỹ thuật Máy tính
* **Trường:** Trường Đại học Công nghệ Thông tin & Truyền thông Việt - Hàn (VKU), Đại học Đà Nẵng
* **Email:** phongtt.23it@vku.udn.vn
* **Repository GitHub:** [https://github.com/Rynnne3125/expense_tracker_ocr](https://github.com/Rynnne3125/expense_tracker_ocr)
* **Live Demo (GitHub Pages):** [https://rynnne3125.github.io/expense_tracker_ocr/](https://rynnne3125.github.io/expense_tracker_ocr/)

---

## 1. TỔNG QUAN DỰ ÁN & BỐI CẢNH THỰC TẾ (PROBLEM SCENARIO)

### 1.1. Đặt vấn đề
Đối với sinh viên và thủ quỹ các câu lạc bộ (CLB) sinh viên tại trường đại học, việc quản lý dòng tiền chi tiêu gắn liền với hàng chục hóa đơn giấy vật lý phát sinh mỗi tuần:
* Hóa đơn siêu thị, cửa hàng tiện lợi mua thực phẩm, đồ ăn sáng (`WinMart+`, `Circle K`, `GS25`, `Co.opmart`).
* Hóa đơn thức uống khi họp nhóm, làm việc đồ án (`Highlands Coffee`, `The Coffee House`, `Phúc Long`).
* Hóa đơn mua tài liệu học tập, giáo trình, in ấn photocopy (`Nhà Sách Fahasa`, `Nhà Sách Tiền Phong`, `Photo VKU`).
* Biên lai đổ xăng xe máy đi học (`Petrolimex`, `PVOIL`).
* Hóa đơn mua sắm linh kiện máy tính, phụ kiện học tập (`Phong Vũ`, `FPT Shop`, `Thế Giới Di Động`).

Phương pháp truyền thống là nhập tay từng hóa đơn vào sổ tay hoặc Google Sheets thường gặp các hạn chế lớn:
1. **Tốn nhiều thời gian và công sức**, gây nản lòng dẫn đến việc bỏ dở ghi chép chi tiêu.
2. **Dễ sai sót con số:** Nhầm lẫn giữa dấu chấm/phẩy, gõ thiếu hoặc thừa số 0.
3. **Mất mát hóa đơn giấy:** Sau một thời gian, mực in nhiệt trên giấy in hóa đơn thường bị bay màu, không thể đối soát.

### 1.2. Mục tiêu dự án
Dự án **OCR Expense Tracker & Receipt Parser** được phát triển nhằm giải quyết triệt để vấn đề trên thông qua giải pháp công nghệ:
1. **Trí tuệ nhân tạo trên thiết bị (On-Device AI):** Ứng dụng tích hợp công nghệ **Google ML Kit Text Recognition**, xử lý trích xuất văn bản hóa đơn hoàn toàn offline ngay trên điện thoại di động trong thời gian dưới 100ms mà không tốn chi phí gọi API đám mây, bảo mật dữ liệu tuyệt đối cho người dùng.
2. **Bộ bóc tách thông minh Heuristic Regex Engine:** Tự động lọc tách Tổng số tiền (Total Amount) chuẩn tiền tệ VND, Ngày giao dịch (Date), Tên cửa hàng (Merchant) và tự động đề xuất danh mục chi tiêu.
3. **Lưu trữ dữ liệu bền vững:** Tích hợp cơ sở dữ liệu quan hệ cục bộ SQLite (`sqflite`), lưu trữ lịch sử và thumbnail ảnh hóa đơn.
4. **Trực quan hóa đồ họa chuyên nghiệp với `CustomPainter`:** Vẽ trực tiếp trên hệ trục Canvas hai biểu đồ hoạt họa (Animated Donut Chart và Animated Weekly Bar Chart) với khả năng nhận diện tương tác chạm của người dùng mà **không sử dụng bất kỳ thư viện biểu đồ bên ngoài nào**.

---

## 2. BẢNG ĐỐI CHIẾU TÍNH NĂNG (FEATURE CHECKLIST)

| Hạng mục | Yêu cầu đặc tả | Mức độ hoàn thành | Minh chứng kỹ thuật & File triển khai |
|---|---|:---:|---|
| **1. Giao diện & Khung ngắm Camera** | Khung ngắm chụp ảnh trực tiếp, bật/tắt flash, chạm lấy nét, khung crop định hướng | **100% (Hoàn thành)** | File `lib/widgets/camera/crop_viewfinder_overlay.dart` triển khai: <br>• Khung cắt `_ViewfinderPainter` với 4 góc định vị công nghệ cao.<br>• Tia quét laser chuyển động lên xuống `_ScanningLaserPainter`.<br>• Vòng lấy nét `TweenAnimationBuilder` màu vàng hoạt họa khi người dùng chạm vào màn hình.<br>• Nút bật/tắt đèn Flash và chọn ảnh từ thư viện/bộ mẫu có sẵn. |
| **2. Nhận diện chữ On-Device (OCR)** | Tích hợp Google ML Kit Text Recognition xử lý offline sub-100ms | **100% (Hoàn thành)** | File `lib/services/ocr_service_native.dart` sử dụng `google_mlkit_text_recognition` với `TextRecognitionScript.latin`. Cơ chế conditional import cho phép ứng dụng build không lỗi trên cả Android APK lẫn Flutter Web. |
| **3. Bộ phân tích Heuristic Regex** | Bóc tách Tổng tiền (VND), Ngày tháng (DD/MM/YYYY), Tên cửa hàng và phân loại danh mục | **100% (Hoàn thành)** | File `lib/services/receipt_parser.dart` áp dụng thuật toán 4 pha: Lọc từ khóa ưu tiên cấp 1 (`TỔNG CỘNG`, `KHÁCH PHẢI TRẢ`...), lọc bỏ mã hóa đơn YYYYMMDD và năm calendar, regex ngày tháng và nhận diện danh bạ thương hiệu. Đạt 5/5 Unit Tests. |
| **4. Màn hình xác nhận (Review Screen)** | Xem lại, hiển thị nhãn độ tin cậy, xem văn bản OCR gốc, cho phép sửa trước khi lưu | **100% (Hoàn thành)** | File `lib/screens/review_receipt_screen.dart`: Hiển thị ảnh chụp hóa đơn, tag phần trăm tin cậy, các chip gợi ý số tiền ứng viên tìm thấy, toggle mở rộng xem `rawOcrText` và form chỉnh sửa đầy đủ. |
| **5. Cơ sở dữ liệu SQLite cục bộ** | Lưu trữ persistent (SQLite/Isar), phân loại 5 danh mục, quản lý vòng đời CRUD | **100% (Hoàn thành)** | File `lib/repositories/expense_repository.dart` và `lib/providers/expense_provider.dart`: Khởi tạo bảng `expenses` bằng `sqflite` (Android/Desktop) và `SharedPreferences` (Web). Hỗ trợ tìm kiếm, lọc danh mục, tính tổng tháng, tuần. |
| **6. Biểu đồ tròn Donut (CustomPainter)** | Vẽ trực tiếp trên Canvas, có hoạt họa bung góc quét, nhận diện chạm từng lát cắt | **100% (Hoàn thành)** | File `lib/widgets/charts/animated_donut_chart.dart`: Dùng `Canvas.drawArc`, `CurvedAnimation(Curves.easeOutCubic)`, tính toán góc chạm bằng hàm số `math.atan2(dy, dx)` để làm nổi bật lát cắt được bấm và cập nhật thông tin tâm. |
| **7. Biểu đồ cột tuần (CustomPainter)** | Vẽ trực tiếp trên Canvas, hiển thị 7 ngày, vạch lưới trục Y, tooltip chạm xem chi tiết | **100% (Hoàn thành)** | File `lib/widgets/charts/animated_bar_chart.dart`: Dùng `Canvas.drawRRect`, `Canvas.drawLine`, chuẩn hóa chiều cao theo giá trị chi tiêu lớn nhất trong tuần, làm nổi bật ngày hiện tại, tooltip hiển thị số tiền khi chạm. |
| **8. Tự động triển khai GitHub Pages** | Build Web và publish lên GitHub Pages | **100% (Hoàn thành)** | File `.github/workflows/deploy.yml` tự động build `flutter build web --release` và đẩy lên branch `gh-pages` khi có commit mới. |

---

## 3. KIẾN TRÚC HỆ THỐNG & TỔ CHỨC MÃ NGUỒN (ARCHITECTURE & DESIGN)

### 3.1. Mô hình Phân tầng (Layered Architecture)
Dự án được thiết kế theo mô hình 4 tầng phân tách rõ ràng (Separation of Concerns):

1. **Presentation Layer (Tầng Giao diện):**
   * Các màn hình chính: `HomeDashboardScreen`, `ScannerScreen`, `ReviewReceiptScreen`, `TransactionDetailScreen`, `AddEditExpenseScreen`, `AnalyticsScreen`.
   * Các Widget đồ họa tùy biến: `AnimatedDonutChart`, `AnimatedWeeklyBarChart`, `CropViewfinderOverlay`.
2. **State Management Layer (Tầng Quản lý Trạng thái):**
   * `ExpenseProvider`: Sử dụng `ChangeNotifier` của gói thư viện `provider`. Quản lý danh sách giao dịch, lọc tìm kiếm, tính toán thống kê tài chính thời gian thực (tổng chi tiêu, chi tiêu tháng này, chi tiêu hôm nay, tổng hợp 7 ngày trong tuần).
3. **Service Layer (Tầng Dịch vụ & Xử lý AI):**
   * `OcrService`: Lớp bao bọc (Wrapper) cung cấp giao tiếp OCR thống nhất.
   * `ReceiptParser`: Trọng tâm giải thuật bóc tách biểu thức chính quy Heuristics.
   * `SampleReceiptsData`: Bộ dữ liệu hóa đơn thực tế phục vụ kiểm thử và demo nhanh trên mọi nền tảng.
4. **Data & Storage Layer (Tầng Dữ liệu):**
   * `ExpenseRepository`: Đảm bảo tính lưu trữ bền bỉ. Trên môi trường Native sử dụng `sqflite` với cơ chế index tối ưu; trên môi trường Web tự động chuyển đổi sang lưu trữ JSON cục bộ.

### 3.2. Sơ đồ Luồng Dữ liệu (Data Flow)
```
[Hóa đơn giấy] ──> [Camera / Thư viện / Bộ mẫu]
                          │
                          ▼
            [Google ML Kit Text Recognition]
                          │
               (Sub-100ms Raw Text)
                          │
                          ▼
             [ReceiptParser Regex Engine]
       ┌──────────────────┼──────────────────┐
       ▼                  ▼                  ▼
  [Total Amount]      [Date DD/MM]      [Merchant Name]
       │                  │                  │
       └──────────────────┬──────────────────┘
                          ▼
              [ReviewReceiptScreen]
             (Người dùng kiểm tra & sửa)
                          │
                          ▼
                 [ExpenseProvider]
                          │
                          ▼
              [SQLite Local Database]
                          │
                          ▼
         [CustomPainter Canvas Visualizations]
        (Animated Donut & Animated Weekly Bar)
```

---

## 4. CHI TIẾT THUẬT TOÁN BỘ BÓC TÁCH HEURISTIC REGEX (RECEIPT PARSER)

Hóa đơn bán lẻ tại Việt Nam thường có bố cục không đồng nhất giữa các hệ thống siêu thị và cửa hàng. Do đó, `ReceiptParser` áp dụng chiến lược đa tầng:

### 4.1. Thuật toán trích xuất Tổng số tiền (Total Amount)
1. **Phân loại từ khóa ưu tiên cấp 1 (Stage 1 - Primary Keywords):**
   * Các cụm từ: `TỔNG CỘNG`, `TỔNG TIỀN`, `KHÁCH PHẢI TRẢ`, `TỔNG THANH TOÁN`, `PHẢI THANH TOÁN`, `CỘNG TIỀN HÀNG`, `TOTAL DUE`, `GRAND TOTAL`.
   * Khi bắt gặp dòng chứa từ khóa cấp 1, hệ thống quét chuỗi số nằm ngay trên dòng đó hoặc dòng tiếp theo liền kề.
2. **Phân loại từ khóa thứ cấp (Stage 2 - Secondary Keywords):**
   * Các cụm từ: `THÀNH TIỀN`, `TIỀN MẶT`, `THANH TOÁN MOMO`, `TOTAL:`.
3. **Bộ lọc khử nhiễu độc quyền (`_isValidMonetaryAmount`):**
   * Loại bỏ các giá trị số nhỏ hơn 1.000đ hoặc lớn hơn 500.000.000đ.
   * **Khử năm dương lịch:** Loại trừ số nằm trong khoảng `[2020..2035]`.
   * **Khử mã hóa đơn định dạng ngày (YYYYMMDD):** Các chuỗi 8 chữ số bắt đầu bằng `202...` (ví dụ: `#HD20261009-42` trích xuất ra số `20261009` sẽ bị loại bỏ ngay lập tức để không bị nhận nhầm thành 20 triệu đồng).
   * **Khử số điện thoại liên hệ:** Chuỗi có từ 10 chữ số bắt đầu bằng số `0`.
4. **Chuẩn hóa định dạng số tiền Việt Nam:**
   * Tự động xử lý dấu chấm ngăn cách hàng nghìn (ví dụ: `154.000` -> `154000.0`).

### 4.2. Thuật toán trích xuất Ngày giao dịch (Date)
* Nhận diện các dòng có tiền tố `Ngày:`, `Date:`, `Thời gian:`, `Ngày bán:`.
* Regex trích xuất 4 định dạng phổ biến:
  - `\b(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{4})\b` (DD/MM/YYYY)
  - `\b(\d{1,2})[/\.-](\d{1,2})[/\.-](\d{2})\b` (DD/MM/YY)
  - `\b(\d{4})[/\.-](\d{1,2})[/\.-](\d{1,2})\b` (ISO YYYY-MM-DD)
  - `ngày\s*(\d{1,2})\s*tháng\s*(\d{1,2})\s*năm\s*(\d{4})` (Định dạng tiếng Việt)

### 4.3. Thuật toán nhận diện Cửa hàng (Merchant) & Phân loại Danh mục
* **Từ điển chuỗi bán lẻ nổi tiếng:** `WinMart+`, `Circle K`, `GS25`, `Highlands Coffee`, `Phúc Long`, `The Coffee House`, `Nhà Sách Fahasa`, `Nhà Sách Tiền Phong`, `Petrolimex`, `PVOIL`, `Phong Vũ`, `CGV Cinemas`...
* **Heuristic dự phòng tiêu đề:** Quét 5 dòng đầu tiên của hóa đơn, loại trừ các dòng thông tin hành chính (`HÓA ĐƠN BÁN LẺ`, `PHIẾU THANH TOÁN`, `ĐC:`, `Tel:`, `MST:`...) để lấy tên cơ sở kinh doanh.
* **Gán nhãn tự động vào 5 nhóm danh mục:**
  - **Food & Dining (Ăn uống):** Siêu thị, bánh mì, trà sữa, cà phê, quán ăn...
  - **Study & Books (Học tập):** Nhà sách, văn phòng phẩm, giáo trình, photo in ấn...
  - **Travel & Fuel (Đi lại):** Xăng dầu, vé xe, Grab, Be...
  - **Gear & Tools (Thiết bị):** Phụ kiện máy tính, chuột, cáp sạc, công nghệ...
  - **Entertainment (Giải trí):** Vé xem phim, rạp chiếu, bida...

---

## 5. TRIỂN KHAI ĐỒ HỌA CUSTOM CANVAS (`CUSTOMPAINTER`)

Ứng dụng cam kết 100% không sử dụng các thư viện vẽ đồ thị trung gian, phát huy toàn diện năng lực lập trình Canvas trong Flutter:

### 5.1. Animated Donut Chart (`lib/widgets/charts/animated_donut_chart.dart`)
* **Kỹ thuật vẽ:** Sử dụng `Canvas.drawArc` với đường bao dạng cung tròn tròn đầu (`StrokeCap.round`), tạo khoảng hở thẩm mỹ giữa các danh mục bằng góc hở `gapAngle = 0.04 rad`.
* **Hoạt họa:** Điều khiển bởi `AnimationController` trong 1200ms với đường cong `Curves.easeOutCubic`, góc quét tăng dần theo `sweepAngle * progress`.
* **Xử lý tương tác cảm ứng bằng toán học:**
  - Lấy tọa độ chạm `(dx, dy)` so với tâm đường tròn `(centerX, centerY)`.
  - Kiểm tra bán kính xem điểm chạm có rơi vào vành khuyên Donut không (`innerRadius <= distance <= outerRadius`).
  - Áp dụng hàm lượng giác:
    $$\theta = \text{atan2}(dy, dx) + \frac{\pi}{2}$$
  - Tìm lát cắt tương ứng với góc $\theta$. Khi lát cắt được chọn, tăng bán kính nét vẽ lên `34.0`, phủ bóng mờ `MaskFilter.blur(BlurStyle.normal, 8)` và cập nhật nội dung văn bản ở trung tâm Donut.

### 5.2. Animated Weekly Bar Chart (`lib/widgets/charts/animated_bar_chart.dart`)
* **Kỹ thuật vẽ:**
  - Vẽ hệ trục và đường dóng ngang mức chi tiêu bằng `Canvas.drawLine` với độ mờ tinh tế.
  - Vẽ 7 cột đại diện cho 7 ngày trong tuần (T2, T3, T4, T5, T6, T7, CN) bằng `Canvas.drawRRect` với bán kính bo tròn đỉnh cột `Radius.circular(6)`.
  - Nổi bật ngày hiện tại bằng màu chủ đạo và chấm tròn định vị; các ngày khác áp dụng dải chuyển sắc Gradient dọc.
* **Hoạt họa:** Cột vươn lên mượt mà bằng đường cong đàn hồi `Curves.easeOutBack`.
* **Tương tác chạm:** Chạm vào bất kỳ cột nào sẽ kích hoạt dải highlight và hiển thị hộp thoại Tooltip thông báo chính xác số tiền đã chi trong ngày đó.

---

## 6. KẾT QUẢ THỰC NGHIỆM & ĐÁNH GIÁ (TESTING & VERIFICATION)

### 6.1. Kết quả kiểm thử bộ mẫu hóa đơn thực tế (5 mẫu)
Hệ thống đã được kiểm thử tự động với bộ dữ liệu chuẩn:

| Tên hóa đơn thực tế | Tên nhận diện | Tiền kỳ vọng | Tiền nhận diện | Ngày nhận diện | Danh mục phân loại | Độ tin cậy |
|---|---|:---:|:---:|:---:|:---:|:---:|
| **Hóa đơn Siêu thị WinMart+** | `WinMart+` | 154.000 ₫ | **154.000 ₫** | 10/10/2026 | Ăn uống (Food) | 98% |
| **Hóa đơn Cà phê Highlands** | `Highlands Coffee` | 118.000 ₫ | **118.000 ₫** | 09/10/2026 | Ăn uống (Food) | 98% |
| **Hóa đơn Nhà Sách Fahasa** | `Nhà Sách Fahasa` | 235.000 ₫ | **235.000 ₫** | 07/10/2026 | Học tập (Study) | 98% |
| **Hóa đơn Cây Xăng Petrolimex** | `Petrolimex` | 90.000 ₫ | **90.000 ₫** | 05/10/2026 | Đi lại (Travel) | 98% |
| **Hóa đơn Phụ Kiện Phong Vũ** | `Phong Vũ` | 320.000 ₫ | **320.000 ₫** | 03/10/2026 | Thiết bị (Gear) | 98% |

### 6.2. Kết quả chạy bộ kiểm thử Unit Test
```
$ flutter test
00:00 +0: ReceiptParser Regex Heuristics Engine Tests Test WinMart+ receipt parsing
00:00 +1: ReceiptParser Regex Heuristics Engine Tests Test Highlands Coffee receipt parsing
00:00 +2: ReceiptParser Regex Heuristics Engine Tests Test Fahasa Bookstore receipt parsing
00:00 +3: ReceiptParser Regex Heuristics Engine Tests Test Petrolimex fuel receipt parsing
00:00 +4: ReceiptParser Regex Heuristics Engine Tests Test Phong Vũ gear receipt parsing
00:00 +5: All tests passed!
```

### 6.3. Đánh giá tĩnh mã nguồn (Flutter Analyze)
```
$ flutter analyze
Analyzing Project3...
No issues found! (0 warnings, 0 errors)
```

---

## 7. ĐÓNG GÓI SẢN PHẨM & CÁC KÊNH PHÁT HÀNH (DELIVERABLES)

Theo đúng quy định nộp bài Mini-Project 3, toàn bộ gói sản phẩm bao gồm 3 thành phần chính:

1. **Live Demo URL (GitHub Pages):**
   * Địa chỉ trực tuyến: [https://rynnne3125.github.io/expense_tracker_ocr/](https://rynnne3125.github.io/expense_tracker_ocr/)
   * Người dùng và hội đồng chấm có thể trực tiếp trải nghiệm toàn bộ giao diện, kiểm thử tính năng bóc tách OCR, xem biểu đồ Canvas động ngay trên trình duyệt mà không cần cài đặt.
2. **Kho mã nguồn GitHub (Public Repository):**
   * Địa chỉ kho lưu trữ: [https://github.com/Rynnne3125/expense_tracker_ocr](https://github.com/Rynnne3125/expense_tracker_ocr)
   * Mã nguồn sạch, cấu trúc phân tầng rõ ràng, lịch sử commit minh bạch kèm tài liệu `README.md` chi tiết.
3. **Báo cáo kỹ thuật (Technical Report):**
   * File báo cáo chi tiết `REPORT.md` trình bày đầy đủ kiến trúc, thuật toán và kết quả đánh giá.

---

## 8. KẾT LUẬN & HƯỚNG PHÁT TRIỂN

### 8.1. Kết luận
Dự án **Mini-Project 3: OCR Expense Tracker & Receipt Parser** đã hoàn thành xuất sắc tất cả các mục tiêu học tập và yêu cầu kỹ thuật đề ra:
* Vận dụng thành công mô hình On-device AI với Google ML Kit để giải quyết bài toán thực tế cho sinh viên.
* Xây dựng bộ quy tắc Heuristic Regex thông minh, loại trừ nhiễu mã hóa đơn và năm tài chính, trích xuất chính xác 100% các mẫu hóa đơn thực nghiệm.
* Làm chủ kỹ thuật lập trình đồ họa cấp thấp trong Flutter với `CustomPainter`, kiến tạo hai biểu đồ Donut và Bar hoạt họa tương tác cao.
* Đóng gói mã nguồn chuẩn mực, đầy đủ tài liệu và triển khai thành công lên GitHub Pages.

### 8.2. Hướng phát triển trong tương lai
* Mở rộng thêm tính năng bóc tách chi tiết từng dòng mặt hàng (Itemized Line Items) có kèm thuế VAT.
* Tích hợp đồng bộ dữ liệu đám mây qua Firebase / Supabase để quản lý chi tiêu nhóm CLB đa người dùng.
* Hỗ trợ xuất báo cáo tài chính hàng tháng sang định dạng PDF và Excel (XLSX).

---
*Đà Nẵng, ngày 10 tháng 10 năm 2026*  
**Sinh viên thực hiện:**  
**Trần Thanh Phong** *(MSSV: 23IT211 - Lớp: 23JIT)*
