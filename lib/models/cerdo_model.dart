class Cerdo {
  final int id;
  final String nombre;
  final String raza;
  final DateTime fechaNacimiento;

  Cerdo({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.fechaNacimiento,
  });

 
  Cerdo.vacio()
      : id = 0,
        nombre = '',
        raza = '',
        fechaNacimiento = DateTime.now();


  @override
  String toString() {
    return 'Cerdo(id: $id, nombre: $nombre, raza: $raza, fechaNacimiento: $fechaNacimiento)';
  }
}


