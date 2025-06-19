// import library Flutter untuk UI
import 'package:flutter/material.dart';
// import library http untuk request API
import 'package:http/http.dart' as http;
// import library untuk decode JSON
import 'dart:convert';

// fungsi utama untuk menjalankan aplikasi
void main() => runApp(MyApp());

// kelas utama untuk aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // membuat tampilan aplikasi
    return MaterialApp(
      title: 'Random User List',// judul aplikasi
      debugShowCheckedModeBanner: false,//menghilangkan banner debug
      theme: ThemeData(primarySwatch: Colors.blue),// tema aplikasi
      home: UserListPage(),// halaman utama
    );
  }
}

// kelas untuk halaman daftar pengguna yang bersifat stateful
class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();// membuat state untuk halaman daftar pengguna
}

// kelas state untuk halaman daftar pengguna
class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];//list untuk menyimpan data pengguna
  bool isLoading = false;//variabel untuk menampilkan indicator loading

  // fungsi untuk memuat data pengguna
  @override
  void initState() {
    super.initState();
    fetchUsers();//memanggil fungsi fetchUsers saat halaman pertama kali dibuka
  }

  // fungsi untuk memuat data pengguna dari API
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;//menampilkan indicator loading
    });

    try {//melakukan request ke API
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=10'));//mengambil data pengguna dari API
      if (response.statusCode == 200) {//jika request berhasil
        final data = json.decode(response.body);//mengubah data JSON menjadi objek Dart dan disimpan dalam variabel data
        setState(() {
          users = data['results'];//menyimpan data pengguna ke dalam variabel users
        });
      } else {//jika request gagal
        throw Exception('Failed to load users');//mengeluarkan exception untuk menampilkan pesan gagal memuat
      }
    } catch (e) {//jika terjadi error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data')));//menampilkan snackbar untuk menampilkan pesan gagal memuat
    } finally {//selalu dieksekusi
      setState(() {
        isLoading = false;//menyembunyikan indicator loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchUsers,//memanggil fungsi fetchUsers saat tombol refresh diklik
            tooltip: 'Refresh Data',//teks bantuan untuk tombol refresh
          )
        ],
      ),

      body: isLoading //menampilkan indicator loading
          ? Center(child: CircularProgressIndicator()) //menampilkan icon loading sebagai tanda bahwa data sedang dimuat
          : users.isEmpty //jika tidak ada data pengguna
              ? Center(child: Text("Tidak ada data")) //menampilkan pesan bahwa tidak ada data
              : ListView.builder(// Tampilkan daftar user jika data tersedia
                  itemCount: users.length,// mengambil jumlah data pengguna
                  itemBuilder: (context, index) {
                    final user = users[index];//mengambil data pengguna pada indeks tertentu
                    return GestureDetector(//membuat widget yang dapat di klik
                      onTap: () {//jika widget diklik
                        Navigator.push(//mengarahkan ke halaman detail pengguna
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailPage(user: user),//mengirimkan data pengguna ke halaman detail
                          ),
                        );
                      },
                      child: Card( //membuat widget card untuk menampilkan data pengguna
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), //mengatur margin card
                        elevation: 4, //mengatur bayangan card
                        child: Padding( 
                          padding: const EdgeInsets.symmetric(vertical: 16),//mengatur padding card
                          child: Column(
                            children: [
                              CircleAvatar(//membuat widget untuk menampilkan foto pengguna dalam bentuk lingkaran
                                radius: 40,
                                backgroundImage: NetworkImage(user['picture']['large']),//mengambil URL gambar dari data pengguna
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${user['name']['first']} ${user['name']['last']}',//mengambil nama depan dan belakang pengguna dari data pengguna
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(user['phone']), //mengambil nomor telepon pengguna dari data pengguna
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// halaman detail pengguna
class UserDetailPage extends StatelessWidget {
  final dynamic user;// Data user dikirim dari halaman sebelumnya

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fullName = '${user['name']['title']} ${user['name']['first']} ${user['name']['last']}';
    final email = user['email'];
    final phone = user['phone'];
    final gender = user['gender'];
    final country = user['location']['country'];
    final picture = user['picture']['large'];

    return Scaffold(
      appBar: AppBar(title: Text('Detail Pengguna')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //Text rata kiri
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(//membuat widget untuk menampilkan foto pengguna dalam bentuk lingkaran
                    radius: 60,
                    backgroundImage: NetworkImage(picture),
                  ),
                  SizedBox(height: 20),
                  Text(//membuat widget untuk menampilkan nama pengguna dan mengatur style nya
                    fullName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row( // membuat widget untuk menampilkan nomor telpon pengguna
              children: [
                Icon(Icons.phone, size: 20),
                SizedBox(width: 8),
                Text('$phone', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),

            Row(// membuat widget untuk menampilkan email pengguna
              children: [
                Icon(Icons.email, size: 20),
                SizedBox(width: 8),
                Text('$email', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),

            Row(// membuat widget untuk menampilkan jenis kelamin pengguna
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 8),
                Text('$gender', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),

            Row(// membuat widget untuk menampilkan negara pengguna
              children: [
                Icon(Icons.public, size: 20),
                SizedBox(width: 8),
                Text('$country', style: TextStyle(fontSize: 16)),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

