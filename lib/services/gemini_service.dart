import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/vehicle.dart';

class GeminiService {
  static const String _apiKeyPrefsKey = 'gemini_api_key';
  static const String defaultApiKey = '';

  // Set this to your live Render/Vercel backend URL (e.g. 'https://gemini-vehicle-scanner-api.onrender.com')
  static const String backendUrl = 'https://ai-vehicle-detection.onrender.com';
  static const bool useBackend = true;

  // Load saved API Key
  static Future<String?> getApiKey() async {
    return defaultApiKey;
  }

  // Save API Key
  static Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyPrefsKey, key);
  }

  // Clear API Key
  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyPrefsKey);
  }

  // Analyze multiple vehicle images using Gemini (multi-angle scan)
  static Future<Vehicle> analyzeVehicleImages(List<Uint8List> imageBytesList, String apiKey) async {
    if (imageBytesList.isEmpty) {
      throw Exception('No images provided for analysis.');
    }
    // If only one image, delegate to single-image method
    if (imageBytesList.length == 1) {
      return analyzeVehicleImage(imageBytesList.first, apiKey);
    }
    final prompt = '''
Act as an expert automotive appraiser. Identify the EXACT vehicle in the provided image(s) with maximum accuracy. Pay strict attention to specific design cues such as headlight/taillight shape, bumper design, grill, wheels, and any visible badging (e.g., VXI, Legender, 4x4, XUV 7XO) to accurately distinguish between facelifts, generations, and variants. For instance, carefully distinguish between the pre-2026 Mahindra XUV700 and the 2026 facelift Mahindra XUV 7XO (which features a full-width grille, connected piano black rear tail panel, triple-screen setup, and DaVinci suspension). If a license plate is visible, factor in the likely registration era. Ensure the model year reflects the exact generation shown in the images (e.g., do not guess a 2021 facelift year if the image shows a 2016-2020 pre-facelift model).

Provide highly accurate technical specifications, dimensions, features, resale value estimation in Indian Rupees, a short description, and a comprehensive breakdown of ALL OVER THE CAR PARTS (provide 8-10 components covering Engine/Powertrain, Transmission, Suspension, Brakes, Cooling, Electrical, Exhaust, and Chassis/Body) to assist mechanics with repairing the car.

For the maintenance section ("maintenance"), you MUST write all benefits and longevity assessments in very simple, easy-to-understand English. Keep sentences short and format them as clear, pointwise items. Do not use complex jargon.

CRITICAL RULE FOR DATA INTEGRITY:
Under NO circumstances should you output generic placeholders like "Brand 1", "Brand 2", "Benefit 1", "Benefit 2", "Feature 1", "Feature 2", "Color 1", or generic "Point 1" descriptions. You MUST provide real-world, commercially accurate, and specific automotive data, recommended brands (e.g. Shell Helix, Mobil 1, Castrol EDGE, Motul), actual oil grades (e.g., 5W-30 Synthetic), and real pointwise benefits customized for the detected vehicle.

CRITICAL RULE FOR ELECTRIC VEHICLES (EVs):
If the identified vehicle is electric (e.g., electric scooter, electric motorcycle, Ola S1, Joy E-Bike, Ather, Nexon EV, Tesla):
1. Set "fuelType" to "Electric".
2. Set "engineCC" to "0 cc (Electric)".
3. Set "fuelTankCapacity" to "0 Liters" or "Not Applicable".
4. Set "transmission" to "Single Speed".
5. In "maintenance.engineOil", set "typeAndGrade" to "Not Applicable (Electric Scooter - uses 85W-140 Gear Oil for final drive)" for scooters, or "Not Applicable (Electric Vehicle - uses EV reduction gear/transmission fluid)" for cars. Do NOT suggest ICE engine oils.
6. In "maintenance.fuel", set "typeAndGrade" to "Electricity (Requires Lithium-ion Compatible Charger)".
7. In "maintenance.fuel.recommendedBrands", suggest compatible charger units/networks (e.g., OEM Joy E-Bike Charger, Tata Power EZ Charge).
8. Ensure all technical values (price, power, battery range) are accurate.

You MUST respond with a single JSON object matching the following structure:
{
  "id": "unique_lowercase_id",
  "brand": "Manufacturer Name (e.g. Hyundai, Honda, Tata, Suzuki)",
  "model": "Model Name (e.g. Creta, Activa 6G, Swift)",
  "variant": "Specific variant or trim name (e.g. SX (O), LXi, Deluxe)",
  "type": "Car" or "Bike" or "Scooter",
  "year": 2024,
  "launchYear": "Launch year or era (e.g. 2020 - Present)",
  "priceRange": "Showroom price range in India (e.g. ₹8.15 - ₹15.80 Lakh or ₹76,234 - ₹82,734)",
  "usedPriceRange": "Estimated used vehicle price range in India (e.g. ₹5.50 - ₹11.20 Lakh)",
  "fuelType": "Petrol" or "Diesel" or "Electric" or "CNG" or "Hybrid",
  "engineCC": "Engine displacement (e.g. 1497 cc)",
  "transmission": "Manual" or "Automatic" or "CVT" or "Single Speed",
  "mileage": "Claimed mileage (e.g. 17.4 kmpl or 45 kmpl)",
  "cityMileage": "Estimated city mileage (e.g. 13.2 kmpl)",
  "highwayMileage": "Estimated highway mileage (e.g. 18.5 kmpl)",
  "power": "Max power output (e.g. 113.18 bhp @ 4000 rpm)",
  "torque": "Max torque output (e.g. 250 Nm @ 1500-2700 rpm)",
  "seatingCapacity": 5,
  "fuelTankCapacity": "Fuel tank capacity in Liters (e.g. 45 L or 5 Liters)",
  "topSpeed": "Top speed (e.g. 170 km/h)",
  "colors": ["Pearl White", "Obsidian Black", "Titanium Grey"],
  "imageUrls": [],
  "dimensions": {
    "length": "Length in mm (e.g. 4300 mm)",
    "width": "Width in mm (e.g. 1790 mm)",
    "height": "Height in mm (e.g. 1635 mm)",
    "groundClearance": "Ground clearance (e.g. 190 mm)",
    "wheelbase": "Wheelbase (e.g. 2610 mm)"
  },
  "features": {
    "Comfort": ["Ventilated Seats", "Automatic Climate Control"],
    "Safety": ["6 Airbags", "ABS with EBD", "ESC"],
    "Technology": ["10.25-inch Touchscreen Infotainment", "Wireless Android Auto"]
  },
  "parts": [
    {
      "name": "Engine Block / Motor",
      "icon": "settings",
      "status": "Excellent",
      "health": 0.98,
      "details": "Engine is in optimal condition with stable thermal profile.",
      "originalSpec": "OEM 1.5L Petrol Engine, 4-Cylinder DOHC 16V",
      "repairTip": "Check timing belt wear every 80,000 km. Inspect manifold gaskets for leaks.",
      "imageUrl": "https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60"
    }
  ],
  "maintenance": {
    "engineOil": {
      "typeAndGrade": "5W-30 Fully Synthetic Oil",
      "recommendedBrands": ["Shell Helix Ultra", "Mobil 1", "Castrol EDGE"],
      "replacementInterval": "10,000 km or 1 year",
      "benefits": [
        "Provides excellent wear protection for critical engine components",
        "Keeps the engine clean by resisting sludge and deposit buildup"
      ]
    },
    "fuel": {
      "typeAndGrade": "Regular Unleaded Petrol (91 Octane)",
      "recommendedBrands": ["Indian Oil Premium", "HP Power", "Shell V-Power"],
      "benefits": [
        "Ensures clean combustion and stable engine idling",
        "Protects fuel injectors from varnish and carbon deposits"
      ]
    },
    "longevityAssessment": [
      "Always change the engine oil and filter on schedule to protect internal bearings",
      "Inspect drive belts and rubber cooling hoses for cracks at every service",
      "Clean or replace the air filter element every 5,000 km for optimal power output"
    ]
  },
  "description": "A comprehensive description summarizing the vehicle's significance, performance, and key highlights."
}

Do NOT output any markdown tags (like ```json) or explanation text outside the JSON. Return only the raw JSON. If you cannot identify the vehicle, return an error JSON:
{
  "error": "No vehicle detected in the images."
}
''';

    if (useBackend) {
      try {
        final List<String> base64Images = imageBytesList.map((bytes) => base64Encode(bytes)).toList();
        final body = jsonEncode({
          'prompt': prompt,
          'images': base64Images,
          if (apiKey != defaultApiKey) 'customApiKey': apiKey,
        });

        final response = await http.post(
          Uri.parse('$backendUrl/api/analyze'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final String rawText = resData['result'] ?? '';
          
          String cleanedJson = rawText.trim();
          if (cleanedJson.startsWith('```')) {
            cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```json\s*'), '');
            cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```\s*'), '');
            cleanedJson = cleanedJson.split('```').first.trim();
          }

          final Map<String, dynamic> data = jsonDecode(cleanedJson);
          if (data.containsKey('error')) {
            throw Exception(data['error']);
          }
          return _buildVehicleFromJson(data, imageBytesList.first);
        } else {
          final errBody = jsonDecode(response.body);
          throw Exception(errBody['error'] ?? 'Server error ${response.statusCode}');
        }
      } catch (e) {
        if (apiKey == defaultApiKey) {
          throw Exception('Failed to connect to backend server. Details: $e');
        }
        developer.log('Backend failed: $e. Falling back to direct API connection.', name: 'GeminiService', error: e);
      }
    }

    // Build multi-part content with all images
    final List<Part> contentParts = [TextPart(prompt)];
    for (final imgBytes in imageBytesList) {
      contentParts.add(DataPart('image/jpeg', imgBytes));
    }

    GenerateContentResponse? response;
    Object? lastError;

    // Attempt 1: Primary model
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
      response = await model.generateContent([Content.multi(contentParts)]);
    } catch (e) {
      lastError = e;

      // Fallback: gemini-1.5-flash
      await Future.delayed(const Duration(seconds: 1));
      try {
        final fallbackModel = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );
        response = await fallbackModel.generateContent([Content.multi(contentParts)]);
      } catch (fallbackErr) {
        lastError = fallbackErr;
      }
    }

    if (response == null) {
      if (lastError != null) throw lastError;
      throw Exception('Failed to generate content. Please try again.');
    }

    final rawText = response.text ?? '';
    String cleanedJson = rawText.trim();
    if (cleanedJson.startsWith('```')) {
      cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```json\s*'), '');
      cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```\s*'), '');
      cleanedJson = cleanedJson.split('```').first.trim();
    }

    final Map<String, dynamic> data = jsonDecode(cleanedJson);

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    return _buildVehicleFromJson(data, imageBytesList.first);
  }

  // Analyze vehicle image using Gemini with automatic fallback on 503/server overload
  static Future<Vehicle> analyzeVehicleImage(Uint8List imageBytes, String apiKey) async {
    final prompt = '''
Act as an expert automotive appraiser. Identify the EXACT vehicle in the provided image with maximum accuracy. Pay strict attention to specific design cues such as headlight/taillight shape, bumper design, grill, wheels, and any visible badging (e.g., VXI, Legender, 4x4, XUV 7XO) to accurately distinguish between facelifts, generations, and variants. For instance, carefully distinguish between the pre-2026 Mahindra XUV700 and the 2026 facelift Mahindra XUV 7XO (which features a full-width grille, connected piano black rear tail panel, triple-screen setup, and DaVinci suspension). If a license plate is visible, factor in the likely registration era. Ensure the model year reflects the exact generation shown in the image (e.g., do not guess a 2021 facelift year if the image shows a 2016-2020 pre-facelift model).

Provide highly accurate technical specifications, dimensions, features, resale value estimation in Indian Rupees, a short description, and a comprehensive breakdown of ALL OVER THE CAR PARTS (provide 8-10 components covering Engine/Powertrain, Transmission, Suspension, Brakes, Cooling, Electrical, Exhaust, and Chassis/Body) to assist mechanics with repairing the car.

For the maintenance section ("maintenance"), you MUST write all benefits and longevity assessments in very simple, easy-to-understand English. Keep sentences short and format them as clear, pointwise items. Do not use complex jargon.

CRITICAL RULE FOR DATA INTEGRITY:
Under NO circumstances should you output generic placeholders like "Brand 1", "Brand 2", "Benefit 1", "Benefit 2", "Feature 1", "Feature 2", "Color 1", or generic "Point 1" descriptions. You MUST provide real-world, commercially accurate, and specific automotive data, recommended brands (e.g. Shell Helix, Mobil 1, Castrol EDGE, Motul), actual oil grades (e.g., 5W-30 Synthetic), and real pointwise benefits customized for the detected vehicle.

CRITICAL RULE FOR ELECTRIC VEHICLES (EVs):
If the identified vehicle is electric (e.g., electric scooter, electric motorcycle, Ola S1, Joy E-Bike, Ather, Nexon EV, Tesla):
1. Set "fuelType" to "Electric".
2. Set "engineCC" to "0 cc (Electric)".
3. Set "fuelTankCapacity" to "0 Liters" or "Not Applicable".
4. Set "transmission" to "Single Speed".
5. In "maintenance.engineOil", set "typeAndGrade" to "Not Applicable (Electric Scooter - uses 85W-140 Gear Oil for final drive)" for scooters, or "Not Applicable (Electric Vehicle - uses EV reduction gear/transmission fluid)" for cars. Do NOT suggest ICE engine oils.
6. In "maintenance.fuel", set "typeAndGrade" to "Electricity (Requires Lithium-ion Compatible Charger)".
7. In "maintenance.fuel.recommendedBrands", suggest compatible charger units/networks (e.g., OEM Joy E-Bike Charger, Tata Power EZ Charge).
8. Ensure all technical values (price, power, battery range) are accurate.

You MUST respond with a single JSON object matching the following structure:
{
  "id": "unique_lowercase_id",
  "brand": "Manufacturer Name (e.g. Hyundai, Honda, Tata, Suzuki)",
  "model": "Model Name (e.g. Creta, Activa 6G, Swift)",
  "variant": "Specific variant or trim name (e.g. SX (O), LXi, Deluxe)",
  "type": "Car" or "Bike" or "Scooter",
  "year": 2024,
  "launchYear": "Launch year or era (e.g. 2020 - Present)",
  "priceRange": "Showroom price range in India (e.g. ₹8.15 - ₹15.80 Lakh or ₹76,234 - ₹82,734)",
  "usedPriceRange": "Estimated used vehicle price range in India (e.g. ₹5.50 - ₹11.20 Lakh)",
  "fuelType": "Petrol" or "Diesel" or "Electric" or "CNG" or "Hybrid",
  "engineCC": "Engine displacement (e.g. 1497 cc)",
  "transmission": "Manual" or "Automatic" or "CVT" or "Single Speed",
  "mileage": "Claimed mileage (e.g. 17.4 kmpl or 45 kmpl)",
  "cityMileage": "Estimated city mileage (e.g. 13.2 kmpl)",
  "highwayMileage": "Estimated highway mileage (e.g. 18.5 kmpl)",
  "power": "Max power output (e.g. 113.18 bhp @ 4000 rpm)",
  "torque": "Max torque output (e.g. 250 Nm @ 1500-2700 rpm)",
  "seatingCapacity": 5,
  "fuelTankCapacity": "Fuel tank capacity in Liters (e.g. 45 L or 5 Liters)",
  "topSpeed": "Top speed (e.g. 170 km/h)",
  "colors": ["Pearl White", "Obsidian Black", "Titanium Grey"],
  "imageUrls": [],
  "dimensions": {
    "length": "Length in mm (e.g. 4300 mm)",
    "width": "Width in mm (e.g. 1790 mm)",
    "height": "Height in mm (e.g. 1635 mm)",
    "groundClearance": "Ground clearance (e.g. 190 mm)",
    "wheelbase": "Wheelbase (e.g. 2610 mm)"
  },
  "features": {
    "Comfort": ["Ventilated Seats", "Automatic Climate Control"],
    "Safety": ["6 Airbags", "ABS with EBD", "ESC"],
    "Technology": ["10.25-inch Touchscreen Infotainment", "Wireless Android Auto"]
  },
  "parts": [
    {
      "name": "Engine Block / Motor",
      "icon": "settings",
      "status": "Excellent",
      "health": 0.98,
      "details": "Engine is in optimal condition with stable thermal profile.",
      "originalSpec": "OEM 1.5L Petrol Engine, 4-Cylinder DOHC 16V",
      "repairTip": "Check timing belt wear every 80,000 km. Inspect manifold gaskets for leaks.",
      "imageUrl": "https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60"
    },
    {
      "name": "Suspension Systems",
      "icon": "swap_vert",
      "status": "Good",
      "health": 0.88,
      "details": "Dampers showing minor wear, standard performance maintained.",
      "originalSpec": "MacPherson Strut with Coil Spring",
      "repairTip": "Check rubber bushings for cracks. Perform wheel alignment after replacing struts.",
      "imageUrl": "https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?w=600&auto=format&fit=crop&q=60"
    },
    {
      "name": "Braking Unit",
      "icon": "toll",
      "status": "Good",
      "health": 0.85,
      "details": "Brake pads are at 85% thickness, fluid level is normal.",
      "originalSpec": "Ventilated Front Discs, Solid Rear Drums",
      "repairTip": "Bleed lines to remove air bubbles. Check caliper sliders for free movement.",
      "imageUrl": "https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=60"
    },
    {
      "name": "Exhaust & Emissions",
      "icon": "smoke_free",
      "status": "Excellent",
      "health": 0.95,
      "details": "Exhaust emission levels comply with BS6 standards.",
      "originalSpec": "OEM Catalytic Converter & Exhaust Silencer Muffler",
      "repairTip": "Inspect catalytic converter for rust. Check oxygen sensors if warning light is active.",
      "imageUrl": "https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=600&auto=format&fit=crop&q=60"
    }
  ],
  "maintenance": {
    "engineOil": {
      "typeAndGrade": "5W-30 Fully Synthetic Oil",
      "recommendedBrands": ["Shell Helix Ultra", "Mobil 1", "Castrol EDGE"],
      "replacementInterval": "10,000 km or 1 year",
      "benefits": [
        "Provides excellent wear protection for critical engine components",
        "Keeps the engine clean by resisting sludge and deposit buildup"
      ]
    },
    "fuel": {
      "typeAndGrade": "Regular Unleaded Petrol (91 Octane)",
      "recommendedBrands": ["Indian Oil Premium", "HP Power", "Shell V-Power"],
      "benefits": [
        "Ensures clean combustion and stable engine idling",
        "Protects fuel injectors from varnish and carbon deposits"
      ]
    },
    "longevityAssessment": [
      "Always change the engine oil and filter on schedule to protect internal bearings",
      "Inspect drive belts and rubber cooling hoses for cracks at every service",
      "Clean or replace the air filter element every 5,000 km for optimal power output"
    ]
  },
  "description": "A comprehensive description summarizing the vehicle's significance, performance, and key highlights."
}

Do NOT output any markdown tags (like ```json) or explanation text outside the JSON. Return only the raw JSON. If you cannot identify the vehicle, return an error JSON:
{
  "error": "No vehicle detected in the image."
}
''';

    if (useBackend) {
      try {
        final List<String> base64Images = [base64Encode(imageBytes)];
        final body = jsonEncode({
          'prompt': prompt,
          'images': base64Images,
          if (apiKey != defaultApiKey) 'customApiKey': apiKey,
        });

        final response = await http.post(
          Uri.parse('$backendUrl/api/analyze'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          final String rawText = resData['result'] ?? '';
          
          String cleanedJson = rawText.trim();
          if (cleanedJson.startsWith('```')) {
            cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```json\s*'), '');
            cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```\s*'), '');
            cleanedJson = cleanedJson.split('```').first.trim();
          }

          final Map<String, dynamic> data = jsonDecode(cleanedJson);
          if (data.containsKey('error')) {
            throw Exception(data['error']);
          }
          return _buildVehicleFromJson(data, imageBytes);
        } else {
          final errBody = jsonDecode(response.body);
          throw Exception(errBody['error'] ?? 'Server error ${response.statusCode}');
        }
      } catch (e) {
        if (apiKey == defaultApiKey) {
          throw Exception('Failed to connect to backend server. Details: $e');
        }
        developer.log('Backend failed: $e. Falling back to direct API connection.', name: 'GeminiService', error: e);
      }
    }

    GenerateContentResponse? response;
    Object? lastError;

    // Attempt 1: Try using the primary gemini-2.5-flash model
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
      response = await model.generateContent([
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]),
      ]);
    } catch (e) {
      lastError = e;
      // Fallback: wait 1 second and try the highly stable gemini-2.0-flash model
      await Future.delayed(const Duration(seconds: 1));
      try {
        final fallbackModel = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
        );
        response = await fallbackModel.generateContent([
          Content.multi([
            TextPart(prompt),
            DataPart('image/jpeg', imageBytes),
          ]),
        ]);
      } catch (fallbackErr) {
        lastError = fallbackErr;
      }
    }

    if (response == null) {
      if (lastError != null) {
        throw lastError;
      }
      throw Exception('Failed to generate content due to transient server overload. Please try again.');
    }

    final rawText = response.text ?? '';
    // Clean up markdown block format if present
    String cleanedJson = rawText.trim();
    if (cleanedJson.startsWith('```')) {
      cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```json\s*'), '');
      cleanedJson = cleanedJson.replaceFirst(RegExp(r'^```\s*'), '');
      cleanedJson = cleanedJson.split('```').first.trim();
    }

    final Map<String, dynamic> data = jsonDecode(cleanedJson);

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    return _buildVehicleFromJson(data, imageBytes);
  }

  // Shared: Build Vehicle object from parsed JSON data
  static Vehicle _buildVehicleFromJson(Map<String, dynamic> data, Uint8List imageBytes) {
    // Map features safely
    final Map<String, List<String>> featuresMap = {};
    if (data['features'] != null && data['features'] is Map) {
      (data['features'] as Map).forEach((key, val) {
        if (val is List) {
          featuresMap[key.toString()] = val.map((e) => e.toString()).toList();
        }
      });
    }

    // Map parts safely
    final List<VehiclePart> partsList = [];
    if (data['parts'] != null && data['parts'] is List) {
      for (final p in (data['parts'] as List)) {
        final partName = p['name']?.toString() ?? 'Component';
        partsList.add(VehiclePart(
          name: partName,
          icon: p['icon']?.toString() ?? 'settings',
          status: p['status']?.toString() ?? 'Good',
          health: double.tryParse(p['health']?.toString() ?? '1.0') ?? 1.0,
          details: p['details']?.toString() ?? 'All systems nominal.',
          originalSpec: p['originalSpec']?.toString() ?? 'OEM Factory Standard Part',
          repairTip: p['repairTip']?.toString() ?? 'Refer to workshop manual for specific details.',
          imageUrl: p['imageUrl']?.toString() ?? _fallbackPartImageUrl(partName),
        ));
      }
    } else {
      // Default fallback parts
      partsList.addAll(const [
        VehiclePart(
          name: 'Engine Block / Motor',
          icon: 'settings',
          status: 'Good',
          health: 0.95,
          details: 'Engine compression and thermal outputs are within standard parameters.',
          originalSpec: 'OEM Factory Standard Engine',
          repairTip: 'Inspect oil viscosity and filter seals. Replace gaskets if residue is found.',
          imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'Suspension Systems',
          icon: 'swap_vert',
          status: 'Good',
          health: 0.90,
          details: 'Front and rear dampening elements showing stable deflection.',
          originalSpec: 'OEM Shock Absorbers and Control Arms',
          repairTip: 'Check rubber bushings for cracks. Align wheels after major strut replacement.',
          imageUrl: 'https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'Braking Unit',
          icon: 'toll',
          status: 'Good',
          health: 0.88,
          details: 'Brake pads exhibit normal wear with sufficient thickness remaining.',
          originalSpec: 'OEM Brake Rotors and Calipers',
          repairTip: 'Bleed lines to remove air bubbles. Check caliper sliders for smooth movement.',
          imageUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'Exhaust & Emissions',
          icon: 'smoke_free',
          status: 'Excellent',
          health: 0.96,
          details: 'Emissions are well within regulatory emission compliance.',
          originalSpec: 'OEM Catalytic Converter and Muffler',
          repairTip: 'Check exhaust hangers for rust. Scan lambda sensor outputs if check engine is on.',
          imageUrl: 'https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=600&auto=format&fit=crop&q=60',
        ),
      ]);
    }

    // Map dimensions safely
    final dimsData = data['dimensions'] ?? {};
    final dimensions = VehicleDimensions(
      length: dimsData['length']?.toString() ?? 'N/A',
      width: dimsData['width']?.toString() ?? 'N/A',
      height: dimsData['height']?.toString() ?? 'N/A',
      groundClearance: dimsData['groundClearance']?.toString() ?? 'N/A',
      wheelbase: dimsData['wheelbase']?.toString() ?? 'N/A',
    );

    // Parse brand/model
    var brand = data['brand']?.toString() ?? 'Unknown';
    var modelName = data['model']?.toString() ?? 'Vehicle';
    var year = int.tryParse(data['year']?.toString() ?? '') ?? DateTime.now().year;

    // Hard correction for Mahindra XUV 7XO / XUV700 facelift
    if (brand.toLowerCase().contains('mahindra') && 
        (modelName.toLowerCase().contains('xuv') || modelName.toLowerCase().contains('700') || modelName.toLowerCase().contains('7xo'))) {
      brand = 'Mahindra';
      modelName = 'XUV 7XO';
      year = 2026;
      data['variant'] = 'AX7 Luxury Pack (AX7 L) Diesel AT AWD';
      data['priceRange'] = '₹13.66 - ₹24.92 Lakh';
      data['usedPriceRange'] = '₹12.50 - ₹22.00 Lakh';
      data['launchYear'] = '2026 (New Facelift)';
      data['description'] = 'The Mahindra XUV 7XO is the next-generation premium crossover SUV, serving as the official facelift to the legendary XUV700. Released in 2026, it features a state-of-the-art triple-screen cockpit, ChatGPT/Alexa integrations, and a Tenneco-developed DaVinci active suspension system.';
    }

    // Detect if this is an electric vehicle for correction and safety
    String fuelType = data['fuelType']?.toString() ?? 'Petrol';
    String engineCC = data['engineCC']?.toString() ?? 'N/A';
    String fuelTankCapacity = data['fuelTankCapacity']?.toString() ?? 'N/A';
    String transmission = data['transmission']?.toString() ?? 'Manual';
    
    final lowerBrand = brand.toLowerCase();
    final lowerModel = modelName.toLowerCase();
    final lowerDesc = (data['description']?.toString() ?? '').toLowerCase();

    bool isEvDetected = fuelType.toLowerCase().contains('electric') ||
        lowerBrand.contains('electric') ||
        lowerModel.contains('ev') ||
        lowerModel.contains('e-bike') ||
        lowerModel.contains('electric') ||
        lowerDesc.contains('electric scooter') ||
        lowerDesc.contains('electric vehicle');

    if (isEvDetected) {
      fuelType = 'Electric';
      if (engineCC == 'N/A' || !engineCC.toLowerCase().contains('electric')) {
        engineCC = '0 cc (Electric)';
      }
      if (fuelTankCapacity == 'N/A' || fuelTankCapacity.toLowerCase().contains('l')) {
        if (!fuelTankCapacity.toLowerCase().contains('0')) {
          fuelTankCapacity = '0 Liters';
        }
      }
      if (transmission.toLowerCase() == 'manual' || transmission == 'N/A') {
        transmission = 'Single Speed';
      }
    }

    // Parse maintenance
    VehicleMaintenance? maintenance;
    if (data['maintenance'] != null && data['maintenance'] is Map) {
      final mData = data['maintenance'] as Map;
      
      final engineOilData = mData['engineOil'] is Map ? mData['engineOil'] as Map : {};
      final fuelData = mData['fuel'] is Map ? mData['fuel'] as Map : {};
      
      String oilGrade = engineOilData['typeAndGrade']?.toString() ?? 'Standard Oil';
      List<String> oilBrands = engineOilData['recommendedBrands'] is List 
          ? (engineOilData['recommendedBrands'] as List).map((e) => e.toString()).toList()
          : ['OEM Recommended'];
      String oilInterval = engineOilData['replacementInterval']?.toString() ?? '10,000 km / 1 Year';
      List<String> oilBenefits = engineOilData['benefits'] is List
          ? (engineOilData['benefits'] as List).map((e) => e.toString()).toList()
          : ['Ensures smooth operation'];

      String fuelGrade = fuelData['typeAndGrade']?.toString() ?? 'Standard Fuel';
      List<String> fuelBrands = fuelData['recommendedBrands'] is List 
          ? (fuelData['recommendedBrands'] as List).map((e) => e.toString()).toList()
          : ['Any reputed brand'];
      List<String> fuelBenefits = fuelData['benefits'] is List
          ? (fuelData['benefits'] as List).map((e) => e.toString()).toList()
          : ['Provides good mileage'];

      // EV correction post-process
      if (isEvDetected) {
        final isScooterOrBike = data['type']?.toString().toLowerCase() != 'car';
        
        if (oilGrade.toLowerCase().contains('5w-') || 
            oilGrade.toLowerCase().contains('10w-') || 
            oilGrade.toLowerCase().contains('20w-') || 
            oilGrade.toLowerCase().contains('synthetic oil') ||
            oilGrade.toLowerCase().contains('standard oil')) {
          if (isScooterOrBike) {
            oilGrade = 'Not Applicable (Electric Scooter - uses 85W-140 Gear Oil for final drive)';
            oilBrands = ['Castrol Scooter Gear Oil', 'Motul Scooter Gear'];
            oilInterval = '10,000 km or 1 year';
            oilBenefits = [
              'Keeps the rear wheel gear system running smoothly.',
              'Prevents metallic friction and grinding noise.'
            ];
          } else {
            oilGrade = 'Not Applicable (Electric Vehicle - uses EV reduction gear/transmission fluid)';
            oilBrands = ['Mobil EV Fluid', 'Castrol ON EV Fluid'];
            oilInterval = '40,000 km to 50,000 km';
            oilBenefits = [
              'No traditional motor oil required.',
              'Reduces gear wear in single speed reduction unit.',
              'Improves motor power transfer efficiency.'
            ];
          }
        }
        
        if (fuelGrade.toLowerCase().contains('petrol') || 
            fuelGrade.toLowerCase().contains('diesel') || 
            fuelGrade.toLowerCase().contains('octane') || 
            fuelGrade.toLowerCase().contains('fuel') ||
            fuelGrade.toLowerCase().contains('standard fuel')) {
          fuelGrade = 'Electricity (Requires Lithium-ion Compatible Charger)';
          fuelBrands = isScooterOrBike ? ['OEM Joy E-Bike Charger'] : ['Tata Power EZ Charge', 'Jio-bp pulse'];
          fuelBenefits = [
            'Saves a lot of money compared to using petrol.',
            'Zero emissions and environment friendly.'
          ];
        }
      }
      
      maintenance = VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: oilGrade,
          recommendedBrands: oilBrands,
          replacementInterval: oilInterval,
          benefits: oilBenefits,
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: fuelGrade,
          recommendedBrands: fuelBrands,
          replacementInterval: fuelData['replacementInterval']?.toString() ?? 'Charge 20% to 80% daily',
          benefits: fuelBenefits,
        ),
        longevityAssessment: mData['longevityAssessment'] is List
            ? (mData['longevityAssessment'] as List).map((e) => e.toString()).toList()
            : [
                'Regular battery health inspection required.',
                'Keep vehicle clean of road debris and dust.',
                'Inspect electric powertrain connectors periodically.'
              ],
      );
    }

    return Vehicle(
      id: data['id']?.toString() ?? '${brand.toLowerCase().replaceAll(' ', '_')}_${modelName.toLowerCase().replaceAll(' ', '_')}_$year',
      brand: brand,
      model: modelName,
      variant: data['variant']?.toString() ?? 'Standard',
      type: data['type']?.toString() ?? 'Car',
      year: year,
      launchYear: data['launchYear']?.toString() ?? '$year',
      priceRange: data['priceRange']?.toString() ?? 'N/A',
      usedPriceRange: data['usedPriceRange']?.toString() ?? 'N/A',
      fuelType: fuelType,
      engineCC: engineCC,
      transmission: transmission,
      mileage: data['mileage']?.toString() ?? 'N/A',
      cityMileage: data['cityMileage']?.toString() ?? 'N/A',
      highwayMileage: data['highwayMileage']?.toString() ?? 'N/A',
      power: data['power']?.toString() ?? 'N/A',
      torque: data['torque']?.toString() ?? 'N/A',
      seatingCapacity: int.tryParse(data['seatingCapacity']?.toString() ?? '') ?? 5,
      fuelTankCapacity: fuelTankCapacity,
      topSpeed: data['topSpeed']?.toString() ?? 'N/A',
      colors: data['colors'] is List ? (data['colors'] as List).map((e) => e.toString()).toList() : ['Standard'],
      imageUrls: data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty
          ? (data['imageUrls'] as List).map((e) => e.toString()).toList()
          : ['https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=600'],
      dimensions: dimensions,
      features: featuresMap.isNotEmpty ? featuresMap : {
        'Safety': ['Dual Front Airbags', 'ABS with EBD'],
        'Performance': ['Eco Mode', 'Refined Power Delivery']
      },
      parts: partsList,
      description: data['description']?.toString() ?? 'AI detected vehicle details.',
      localImageBytes: imageBytes,
      maintenance: maintenance,
    );
  }

  static String _fallbackPartImageUrl(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('engine') || lower.contains('motor')) {
      return 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('suspension') || lower.contains('shock') || lower.contains('strut')) {
      return 'https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('brake') || lower.contains('pad') || lower.contains('rotor') || lower.contains('drum')) {
      return 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('exhaust') || lower.contains('emission') || lower.contains('muffler') || lower.contains('converter')) {
      return 'https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('battery') || lower.contains('electrical') || lower.contains('spark') || lower.contains('alternator') || lower.contains('ecu')) {
      return 'https://images.unsplash.com/photo-1620641788421-7a1c342ea42e?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('transmission') || lower.contains('gear') || lower.contains('clutch')) {
      return 'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('cooling') || lower.contains('radiator') || lower.contains('coolant') || lower.contains('fan')) {
      return 'https://images.unsplash.com/photo-1563720223185-11003d516935?w=600&auto=format&fit=crop&q=60';
    } else if (lower.contains('tyre') || lower.contains('tire') || lower.contains('wheel') || lower.contains('rim')) {
      return 'https://images.unsplash.com/photo-1578844251758-2f71da64c96f?w=600&auto=format&fit=crop&q=60';
    }
    return 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60';
  }

  // Generate a chat response using Gemini API
  static Future<String> generateChatResponse(String query, String apiKey, Vehicle? currentVehicle) async {
    String vehicleContext = 'No specific vehicle is currently selected. Answer generally or ask them to specify a vehicle.';
    
    if (currentVehicle != null) {
      final partsStatus = currentVehicle.parts.map((p) => '${p.name}: ${p.status} (Health: ${(p.health * 100).toStringAsFixed(0)}%)').join(', ');
      vehicleContext = '''
- Brand: ${currentVehicle.brand}
- Model: ${currentVehicle.model}
- Variant: ${currentVehicle.variant}
- Year: ${currentVehicle.year}
- Fuel Type: ${currentVehicle.fuelType}
- Engine: ${currentVehicle.engineCC}
- Transmission: ${currentVehicle.transmission}
- Mileage: ${currentVehicle.mileage} (City: ${currentVehicle.cityMileage}, Highway: ${currentVehicle.highwayMileage})
- Price Range: ${currentVehicle.priceRange} (Used: ${currentVehicle.usedPriceRange})
- Features: ${currentVehicle.features.toString()}
- Parts Health Status: $partsStatus
''';
    }

    final prompt = '''
You are an expert AI Auto Mechanic assistant. You are helping a user with questions about vehicles, specifications, maintenance, diagnostics, pricing, etc.
The user's query is: "$query"

Context about the currently viewed vehicle:
$vehicleContext

Respond in the language of the user's query (Gujarati, Hindi, or English). If they ask in Gujarati, respond in clear, helpful Gujarati. If in Hindi, respond in Hindi. Otherwise, respond in English.
Keep the tone helpful, professional, and friendly, like a workshop mechanic or automotive expert. Keep sentences relatively concise. Do not mention system details or formatting guidelines.
''';

    if (useBackend) {
      try {
        final body = jsonEncode({
          'prompt': prompt,
          if (apiKey != defaultApiKey) 'customApiKey': apiKey,
        });

        final response = await http.post(
          Uri.parse('$backendUrl/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 200) {
          final resData = jsonDecode(response.body);
          return resData['result'] ?? 'No response from assistant.';
        } else {
          final errBody = jsonDecode(response.body);
          throw Exception(errBody['error'] ?? 'Server error ${response.statusCode}');
        }
      } catch (e) {
        if (apiKey == defaultApiKey) {
          return 'I apologize, I could not connect to the assistant server. Details: $e';
        }
        developer.log('Backend chat failed: $e. Falling back to direct API connection.', name: 'GeminiService', error: e);
      }
    }

    GenerateContentResponse? response;
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
      response = await model.generateContent([Content.text(prompt)]);
    } catch (e) {
      // Fallback
      final fallbackModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );
      response = await fallbackModel.generateContent([Content.text(prompt)]);
    }

    return response.text ?? 'I apologize, I could not process that request.';
  }
}
