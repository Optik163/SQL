-- Tính tổng lượng đơn và doanh thu theo mã tỉnh đi							
SELECT							
MaTinhDi,							
COUNT(MaDon) AS TongLuongDon,							
SUM(CuocPhi) AS TongDoanhThu							
FROM							
Bang1							
GROUP BY							
MaTinhDi							
ORDER BY							
MaTinhDi;							
							
-- Tính tổng số lượng khách hàng, lượng đơn và doanh thu theo vùng							
SELECT							
t.TenVung AS Vung,							
COUNT(DISTINCT dh.MaKhachHang) AS TongSoLuongKhachHang,							
COUNT(dh.MaDon) AS TongLuongDon,							
SUM(dh.CuocPhi) AS TongDoanhThu							
FROM							
Bang1 dh							
JOIN							
Bang2 t ON dh.MaTinhDi = t.MaTinh							
GROUP BY							
t.TenVung							
ORDER BY							
t.TenVung;							
							
-- Tính tổng số lượng khách hàng và doanh thu theo mức xếp hạng và vùng							
SELECT							
x.XepHang AS MucXepHang,							
t.TenVung AS Vung,							
COUNT(DISTINCT dh.MaKhachHang) AS TongSoLuongKhachHang,							
SUM(dh.CuocPhi) AS TongDoanhThu							
FROM							
Bang1 dh							
JOIN							
Bang2 t ON dh.MaTinhDi = t.MaTinh							
JOIN							
Bang3 x ON dh.MaKhachHang = x.MaKhachHang AND dh.Thang = x.Thang							
GROUP BY							
x.XepHang,							
t.TenVung							
ORDER BY							
x.XepHang,							
t.TenVung;							
							
-- Tính số lượng khách hàng và doanh thu theo phân loại khách hàng							
SELECT							
CASE							
WHEN x.XepHang = 'A' THEN N'Khách hàng lớn'							
WHEN x.XepHang IN ('B', 'C') THEN N'Khách hàng vừa và nhỏ'							
ELSE N'Khách hàng lẻ'							
END AS PhanLoaiKhachHang,							
COUNT(DISTINCT dh.MaKhachHang) AS TongSoLuongKhachHang,							
SUM(dh.CuocPhi) AS TongDoanhThu							
FROM							
Bang1 dh							
JOIN							
Bang3 x ON dh.MaKhachHang = x.MaKhachHang AND dh.Thang = x.Thang							
GROUP BY							
CASE							
WHEN x.XepHang = 'A' THEN N'Khách hàng lớn'							
WHEN x.XepHang IN ('B', 'C') THEN N'Khách hàng vừa và nhỏ'							
ELSE N'Khách hàng lẻ'							
END							
ORDER BY							
PhanLoaiKhachHang;							
							
-- Tính tổng lượng đơn và doanh thu của mỗi khách hàng công nợ thuộc nhóm khách hàng lớn							
SELECT							
dh.MaKhachHang,							
COUNT(dh.MaDon) AS TongLuongDon,							
SUM(dh.CuocPhi) AS TongDoanhThu							
FROM							
Bang1 dh							
JOIN							
Bang3 x ON dh.MaKhachHang = x.MaKhachHang AND dh.Thang = x.Thang							
JOIN							
Bang4 cndn ON dh.MaKhachHang = cndn.MaKhachHang AND dh.Thang = cndn.Thang							
WHERE							
x.XepHang = 'A'							
GROUP BY							
dh.MaKhachHang							
ORDER BY							
TongDoanhThu DESC;							
							
-- Tìm các đơn hàng có mã tỉnh đi và đến khác nhau thuộc các vùng khác nhau							
SELECT							
dh.MaDon,							
dh.MaTinhDi,							
di.TenVung AS VungDi,							
dh.MaTinhDen,							
den.TenVung AS VungDen,							
dh.CuocPhi							
FROM							
Bang1 dh							
JOIN							
Bang2 di ON dh.MaTinhDi = di.MaTinh							
JOIN							
Bang2 den ON dh.MaTinhDen = den.MaTinh							
WHERE							
di.TenVung <> den.TenVung							
ORDER BY							
dh.MaDon;							
							
-- Tìm các khách hàng có đơn hàng từ các tỉnh đi khác nhau thuộc cùng một vùng và đến chung một tỉnh							
WITH KhachHangVaTinh AS (							
SELECT							
dh.MaKhachHang,							
di.TenVung AS VungDi,							
dh.MaTinhDen AS MaTinhDen,							
COUNT(DISTINCT dh.MaTinhDi) AS SoTinhDi							
FROM							
Bang1 dh							
JOIN							
Bang2 di ON dh.MaTinhDi = di.MaTinh							
JOIN							
Bang2 den ON dh.MaTinhDen = den.MaTinh							
GROUP BY							
dh.MaKhachHang,							
di.TenVung,							
dh.MaTinhDen							
)							
-- Lọc các khách hàng có đơn hàng từ các tỉnh đi khác nhau thuộc cùng một vùng và đến chung một tỉnh							
SELECT							
MaKhachHang,							
VungDi,							
MaTinhDen,							
SoTinhDi							
FROM							
KhachHangVaTinh							
WHERE							
SoTinhDi > 1							
ORDER BY							
MaKhachHang, VungDi, MaTinhDen;							
							
--Tính tổng doanh thu tích lũy cho mỗi tỉnh đến, phân theo vùng							
WITH DoanhThuTichLuy AS (							
SELECT							
dh.MaTinhDen,							
den.TenVung AS VungDen,							
SUM(dh.CuocPhi) AS DoanhThu,							
SUM(SUM(dh.CuocPhi)) OVER (PARTITION BY den.TenVung ORDER BY dh.Thang ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TongDoanhThuTichLuy							
FROM							
Bang1 dh							
JOIN							
Bang2 den ON dh.MaTinhDen = den.MaTinh							
GROUP BY							
dh.MaTinhDen,							
den.TenVung,							
dh.Thang							
)							
SELECT							
MaTinhDen,							
VungDen,							
DoanhThu,							
TongDoanhThuTichLuy							
FROM							
DoanhThuTichLuy							
ORDER BY							
VungDen, MaTinhDen;							