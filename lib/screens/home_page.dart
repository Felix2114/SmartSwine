import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyAnimatedApp());
}

class MyAnimatedApp extends StatelessWidget {
  const MyAnimatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Poke App",
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 243, 33, 205)),
        useMaterial3: true,
      ),
      home: const FunHomePage(),
    );
  }
}

class FunHomePage extends StatelessWidget {
  const FunHomePage({super.key});

  final Color _primaryColor = const Color.fromARGB(255, 243, 33, 205);
  final Color _secondaryGreen = const Color.fromARGB(255, 59, 201, 100); 


  final List<String> _imagePaths = const [
    "assets/image1.jpg",
    "assets/image2.png",
    "assets/image3.jpg",
    "assets/image4.jpeg",
    "assets/image5.png",
    "assets/image6.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8e8ff),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¡Hola Poke!",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _primaryColor,
                        ),
                      ),
                      Text(
                        "¿Listo para explorar?",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  ClipOval(
                    child: Image.asset(
                      "assets/logoSmartSwine.jpeg", 
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Nuestra Galería Visual",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _ImageCarouselRow(
                      title: "Vistos Recientemente",
                      imagePaths: _imagePaths.sublist(0, 3),
                      accentColor: _primaryColor,
                    ),
                    
                    _ImageCarouselRow(
                      title: "Exploraciones Populares",
                      imagePaths: _imagePaths.sublist(1, 4),
                      accentColor: _secondaryGreen,
                    ),
                    
                    _ImageCarouselRow(
                      title: "Razas mas visualizadas",
                      imagePaths: _imagePaths.sublist(2, 5),
                      accentColor: _primaryColor,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageCarouselRow extends StatelessWidget {
  final String title;
  final List<String> imagePaths;
  final Color accentColor;

  const _ImageCarouselRow({
    required this.title,
    required this.imagePaths,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const double carouselHeight = 220.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ),

        SizedBox(
          height: carouselHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: carouselHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Image.asset(
                      imagePaths[index],
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: carouselHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.red[400], size: 40),
                              const SizedBox(height: 5),
                              Text(
                                "Error al cargar imagen",
                                style: GoogleFonts.poppins(color: Colors.red[400]),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Path: ${imagePaths[index]}",
                                style: GoogleFonts.poppins(color: Colors.red[300], fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}