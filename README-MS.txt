QR RESTAURANT MANAGER — PANDUAN SETUP

Apa yang disediakan
- Menu pelanggan untuk dine-in dan takeaway.
- Pesanan masuk ke cloud database.
- Paparan dashboard jualan tunai dan QR yang telah disahkan.
- Rekod duit keluar.
- Daily closing dengan perbandingan tunai dan QR.
- Status pesanan: New, Preparing, Ready, Completed, Cancelled.
- Audit log asas.

PENTING
Ini ialah starter system untuk diuji, bukan sistem kewangan yang sudah diaudit atau payment gateway.
QR DuitNow manual: pelanggan membuat bayaran, cashier menyemak transaksi bank dan menekan "Sahkan bayaran".
Jangan anggap screenshot resit sebagai bukti wang sudah masuk.
Akaun staff bersama mengurangkan ketepatan audit individu. Minta pekerja pilih nama setiap kali rekod duit keluar/closing.

SETUP CLOUD (Supabase)
1. Buka https://supabase.com dan cipta projek baru.
2. Di SQL Editor, jalankan keseluruhan fail schema.sql.
3. Pergi ke Project Settings > API. Salin Project URL dan anon public key.
4. Buka index.html melalui hosting HTTPS (contoh GitHub Pages/Netlify) atau localhost.
5. Masukkan URL dan anon key pada skrin sambungan.
6. Di Authentication > Users, cipta akaun admin dan akaun staff.
7. Di Table Editor > profiles, tambah satu rekod bagi setiap auth user:
   id = UUID pengguna daripada Authentication > Users
   display_name = Admin / Nama Staff
   role = admin atau staff
8. Masukkan menu melalui tab Menu selepas login.
9. Untuk QR pelanggan, host laman ini dan gunakan URL halaman pelanggan sebagai destinasi QR. Versi ini menggunakan paparan pelanggan dalam app; untuk QR berasingan awam, buat pautan pelanggan khusus selepas deployment.

PENGIRAAN CLOSING
Tunai dijangka = jualan tunai yang status paid - perbelanjaan tunai.
QR dijangka = jualan QR yang status paid - perbelanjaan QR.
Varians = jumlah sebenar - jumlah dijangka.
Nilai negatif menunjukkan kekurangan berbanding rekod; ia bukan bukti siapa mengambil wang.

SEBELUM OPERASI SEBENAR
- Tukar polisi RLS permisif dalam schema.sql kepada polisi berasaskan role.
- Jadikan pelanggan hanya boleh create order, tidak boleh update order atau payment.
- Hadkan pengesahan bayaran kepada admin/cashier yang dibenarkan.
- Tambah nombor meja/QR unik, cetakan dapur, backup, eksport laporan dan pemulihan.
- Untuk pengesahan QR automatik, daftar payment gateway yang menyokong DuitNow QR dinamik dan webhook.
- Uji semua aliran: order, pembatalan, refund, expenses, closing dan internet terputus.
