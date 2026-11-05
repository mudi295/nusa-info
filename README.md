# NusaInfo

Aplikasi Flutter sederhana untuk membaca, melihat detail, dan membuat pengumuman
menggunakan API [JSONPlaceholder](https://jsonplaceholder.typicode.com) dan package `http`.

## Fitur
- Daftar pengumuman (`GET /posts`) dengan `FutureBuilder` + `ListView.builder`, loading, pesan error, tombol "Coba Lagi", dan pull-to-refresh.
- Detail pengumuman + komentar (`GET /posts/{id}/comments`).
- Tambah pengumuman (`POST /posts`) dengan validasi form (`GlobalKey<FormState>`).
- `SnackBar` di Home setelah pengumuman berhasil dibuat.

## Struktur
```
lib/
├── models/post.dart
├── services/post_service.dart
├── screens/{home_screen,detail_screen,add_post_screen}.dart
└── main.dart
```

## Menjalankan
```
flutter pub get
flutter run
```

## Screenshot
| Home | Detail | Tambah |
|------|--------|--------|
| ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) | ![Tambah](screenshots/add.png) |

| Error (internet mati) | SnackBar berhasil |
|-----------------------|-------------------|
| ![Error](screenshots/error.png) | ![Snackbar](screenshots/snackbar.png) |
