class Favourtie {
  String? image;
  String? name;
  String? desc;
  String? nfact;
  String? benefits;
  String? sideEffects;
  Favourtie({
    this.image,
    this.name,
    this.desc,
    this.nfact,
    this.benefits,
    this.sideEffects,
  });

  //reciving data from server
  factory Favourtie.fromMap(map) {
    return Favourtie(
      image: map['image'],
      name: map['name'],
      desc: map['desc'],
      nfact: map['nfact'],
      benefits: map['benefits'],
      sideEffects: map['sideEffects'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'name': name,
      'desc': desc,
      'nfact': nfact,
      'benefits': benefits,
      'sideEffects': sideEffects,
    };
  }
}
