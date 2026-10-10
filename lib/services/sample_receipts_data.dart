import '../models/expense_category.dart';

class SampleReceiptItem {
  final String title;
  final String storeName;
  final String rawOcrText;
  final double expectedTotal;
  final String expectedDate;
  final ExpenseCategory expectedCategory;
  final String description;

  const SampleReceiptItem({
    required this.title,
    required this.storeName,
    required this.rawOcrText,
    required this.expectedTotal,
    required this.expectedDate,
    required this.expectedCategory,
    required this.description,
  });
}

class SampleReceiptsData {
  static const List<SampleReceiptItem> samples = [
    SampleReceiptItem(
      title: 'Hóa đơn Siêu thị WinMart+',
      storeName: 'WinMart+',
      expectedTotal: 154000,
      expectedDate: '10/10/2026',
      expectedCategory: ExpenseCategory.food,
      description: 'Hóa đơn mua thực phẩm & đồ ăn sáng sinh viên tại WinMart+ Ngũ Hành Sơn',
      rawOcrText: '''
WINMART+ DA NANG
Sieu Thi VinCommerce
Dia chi: 128 Tran Dai Nghia, Ngu Hanh Son, Da Nang
Tel: 0236.3888999
HOA DON BAN LE
Ngay: 10/10/2026  10:15:30
Thu ngan: Tran T. Phong
----------------------------------------
1. Banh Mi Sandwich Kinh Do    1    22.000
2. Sua Tuoi Vinamilk 1L        1    38.000
3. Mi Hao Hao Chua Cay (Goi)   10   44.000
4. Xuc Xich Duc CP             1    50.000
----------------------------------------
CONG TIEN HANG:                  154.000
Giam gia:                              0
TONG CONG:                       154.000 VND
TIEN MAT:                        200.000
TIEN THUA:                        46.000
----------------------------------------
CAM ON QUY KHACH VA HEN GAP LAI!
''',
    ),
    SampleReceiptItem(
      title: 'Hóa đơn Cà phê Highlands',
      storeName: 'Highlands Coffee',
      expectedTotal: 118000,
      expectedDate: '09/10/2026',
      expectedCategory: ExpenseCategory.food,
      description: 'Học nhóm CLB Công nghệ tại Highlands Coffee',
      rawOcrText: '''
HIGHLANDS COFFEE
Cong Ty Co Phan Dich Vu Ca Phe Cao Nguyen
Highlands Coffee FPT City
Hoa Don Thanh Toan: #HD20261009-42
Thoi gian: 09/10/2026 15:45
----------------------------------------
1. Phin Sua Da (L)             1    45.000
2. Tra Sen Vang (L)            1    55.000
3. Banh Chuoi Nuong            1    18.000
----------------------------------------
Tong tien:                       118.000
Thanh toan Momo:                 118.000 d
----------------------------------------
Pass Wifi: highlandscoffee2026
Cam on Quy Khach!
''',
    ),
    SampleReceiptItem(
      title: 'Hóa đơn Nhà Sách Fahasa',
      storeName: 'Nhà Sách Fahasa',
      expectedTotal: 235000,
      expectedDate: '07/10/2026',
      expectedCategory: ExpenseCategory.study,
      description: 'Mua tài liệu học thuật và giáo trình Lập trình Flutter',
      rawOcrText: '''
NHA SACH FAHASA DA NANG
Chi Nhanh Fahasa Le Duan
Dia chi: 300 Le Duan, Thanh Khe, TP Da Nang
PHIEU THANH TOAN
Date: 07/10/2026 18:20
Thu ngan: Nguyen V. B
----------------------------------------
1. Giao Trinh Lap Trinh Di Dong     1   145.000
2. So Tay Kien Thuc IT              1    45.000
3. But Bi Gel Zebra Sarasa          3    45.000
----------------------------------------
KHACH PHAI TRA:                  235.000 VND
Tien khach dua:                  250.000
Tien thoi:                        15.000
----------------------------------------
Chuc cac ban hoc tot!
''',
    ),
    SampleReceiptItem(
      title: 'Hóa đơn Cây Xăng Petrolimex',
      storeName: 'Petrolimex',
      expectedTotal: 90000,
      expectedDate: '05/10/2026',
      expectedCategory: ExpenseCategory.travel,
      description: 'Đổ xăng xe máy đi học tại VKU',
      rawOcrText: '''
TAP DOAN XANG DAU VIET NAM
PETROLIMEX - CUA HANG SO 18
Dia chi: Nam Ky Khoi Nghia, Ngu Hanh Son, Da Nang
BIEN LAI BAN XANG DAU
Ngay ban: 05/10/2026 07:10:22
Cot bom: 02 - Xang RON 95-III
Don gia: 21.800 d/lit
So luong: 4.128 lit
----------------------------------------
TONG CONG:                        90.000 VND
Hinh thuc: Tien mat
----------------------------------------
Petrolimex han hanh phuc vu quy khach!
''',
    ),
    SampleReceiptItem(
      title: 'Hóa đơn Cửa Hàng Phụ Kiện Gear',
      storeName: 'Phong Vũ',
      expectedTotal: 320000,
      expectedDate: '03/10/2026',
      expectedCategory: ExpenseCategory.gear,
      description: 'Mua chuột quang và cáp Type-C phục vụ đồ án',
      rawOcrText: '''
CONG TY CO PHAN PHONG VU
Phong Vu Da Nang - 15 Nguyen Van Linh
HOA DON BAN HANG
Ngay: 03/10/2026 14:02:11
----------------------------------------
1. Chuot May Tinh Logitech B100     1   180.000
2. Cap Sac Nhanh Type-C Baseus      1   140.000
----------------------------------------
TONG TIEN THANH TOAN:             320.000 VND
Bao hanh 12 thang chinh hang.
''',
    ),
  ];
}
