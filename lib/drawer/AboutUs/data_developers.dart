class About {
  String name;
  String mail;
  String role;
  String image;
  String address;
  About(
      {required this.name,
      required this.mail,
      required this.role,
      required this.image,
      required this.address});
}

List<About> devList = [
  About(
      name: 'Nutri Tracker',
      mail: 'nutri.tracker@gmail.com',
      role: 'Nutrition provider',
      image: 'assets/dev/Nutri_trac.jpeg',
      address:
          'Government college of engineering\nAurangabad\nPin code:431001'),
  About(
      name: 'Dinesh Das',
      mail: 'dinesh.das@gmail.com',
      role: 'Flutter developer',
      image: 'assets/dev/dinesh.jpg',
      address:
          'Government college of engineering\nAurangabad\nPin code:431001'),
  About(
      name: 'Ashutosh Deshmukh',
      mail: 'ashutosh.deshmukh@gmail.com',
      role: 'Flutter developer',
      image: 'assets/dev/ashutosh.jpg',
      address:
          'Government college of engineering\nAurangabad\nPin code:431001'),
  About(
      name: 'Sachin Bormale',
      mail: 'sachin.bormale@gmail.com',
      role: 'Flutter developer',
      image: 'assets/dev/sachin.jpeg',
      address:
          'Government college of engineering\nAurangabad\nPin code:431001'),
  About(
      name: 'Laxman Adkune',
      mail: 'laxman.adkune01@gmail.com',
      role: 'Flutter developer',
      image: 'assets/dev/laxman.jpeg',
      address: 'Government college of engineering\nAurangabad\nPin code:431001')
];
