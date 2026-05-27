import '../models/vehicle.dart';

class VehicleDatabase {
  static final List<Vehicle> vehicles = [
    Vehicle(
      id: 'mahindra_xuv_7xo_2026',
      brand: 'Mahindra',
      model: 'XUV 7XO',
      variant: 'AX7 Luxury Pack (AX7 L) Diesel AT AWD',
      type: 'Car',
      year: 2026,
      launchYear: '2026 (New Facelift)',
      priceRange: '₹13.66 - ₹24.92 Lakh',
      usedPriceRange: '₹12.50 - ₹22.00 Lakh',
      fuelType: 'Diesel',
      engineCC: '2198 cc',
      transmission: '6-Speed Automatic',
      mileage: '15.57 kmpl',
      cityMileage: '12.40 kmpl',
      highwayMileage: '16.50 kmpl',
      power: '182 bhp @ 3500 rpm',
      torque: '450 Nm @ 1750-2800 rpm',
      seatingCapacity: 7,
      fuelTankCapacity: '60 L',
      topSpeed: '200 km/h',
      colors: ['Everest White', 'Midnight Black', 'Dazzling Silver', 'Red Rage', 'Forest Green'],
      imageUrls: [
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '4695 mm',
        width: '1890 mm',
        height: '1755 mm',
        groundClearance: '200 mm',
        wheelbase: '2750 mm',
      ),
      features: {
        'Safety': [
          '7 Airbags (including driver knee airbag)',
          'Advanced Driver Assistance Systems (ADAS) Level 2',
          'Electronic Stability Program (ESP)',
          '360-Degree Surround View Camera with Blind View Monitor',
          'ABS with EBD and Brake Assist',
          'ISOFIX Child Seat Mounts'
        ],
        'Comfort & Convenience': [
          'Triple 12.3-inch Screen Layout (Instrument Cluster, Infotainment, Passenger Screen)',
          'Panoramic Sunroof (Skyroof) with Voice Assisted control',
          'Sony 3D Sound System (12 Speakers with subwoofer)',
          'Ventilated Front Seats with Driver Memory Function',
          'Dual Zone Automatic Climate Control',
          'Wireless Charging & Wireless Android Auto/CarPlay'
        ],
        'Exterior & Styling': [
          'Full-Width Front Grille with Slim C-shaped LED DRLs',
          'Bi-LED Projector Headlamps & Sequential Turn Indicators',
          '19-inch Diamond Cut Alloy Wheels',
          'Smoked Honeycomb LED Tail Lamps with Connected Piano Black Panel'
        ]
      },
      parts: [
        VehiclePart(
          name: '2.2L mHawk I4 Turbo Diesel',
          icon: 'settings',
          status: 'Excellent',
          health: 0.98,
          details: 'mHawk common-rail direct injection system operating at optimal pressures. VGT (Variable Geometry Turbocharger) spooling normally.',
          originalSpec: 'OEM 2.2L mHawk Turbo Diesel, 4-Cylinder DOHC',
          repairTip: 'Inspect oil viscosity and coolant levels. Check timing chain wear every 100,000 km.',
          imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: '6-Speed Torque Converter',
          icon: 'toll',
          status: 'Excellent',
          health: 0.96,
          details: 'Aisin 6-speed automatic transmission. Shift timing and hydraulic pressure match factory specs. Zero slip detected in lock-up clutch.',
          originalSpec: '6-Speed Aisin Torque Converter Automatic',
          repairTip: 'Replace transmission fluid at 80,000 km. Verify electronic control unit (TCU) for fault codes.',
          imageUrl: 'https://images.unsplash.com/photo-1506015391300-4802dc74de2e?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'DaVinci Suspension',
          icon: 'swap_vert',
          status: 'Excellent',
          health: 0.97,
          details: 'High-performance DaVinci suspension developed with Tenneco. Dampers and sway bars have 100% seal integrity and excellent response.',
          originalSpec: 'Tenneco-developed DaVinci Active Suspension System',
          repairTip: 'Check suspension link bushings for tears. Perform multi-link wheel alignment if vehicle pulls to one side.',
          imageUrl: 'https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'Braking System',
          icon: 'adjust',
          status: 'Very Good',
          health: 0.92,
          details: 'Ventilated disc brakes on all four wheels. ESP and ABS hydraulic modulators check completed successfully. Brake pad depth: 9.5mm.',
          originalSpec: '4-Wheel Ventilated Disc Brakes with ABS and EBD',
          repairTip: 'Bleed brake lines to maintain firm pedal pressure. Replace brake pads when they wear down to 3mm.',
          imageUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop&q=60',
        ),
        VehiclePart(
          name: 'Exhaust & Emissions',
          icon: 'smoke_free',
          status: 'Excellent',
          health: 0.95,
          details: 'Selective Catalytic Reduction (SCR) with AdBlue injection. DPF soot level: negligible. BS6 Phase-2 OBD compliance checks passed.',
          originalSpec: 'SCR Exhaust System with DPF & AdBlue Dosing',
          repairTip: 'Keep AdBlue (DEF) tank topped up. Avoid short drives that prevent active DPF regeneration cycles.',
          imageUrl: 'https://images.unsplash.com/photo-1616422285623-13ff0162193c?w=600&auto=format&fit=crop&q=60',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '5W-30 BS6-Compliant Diesel Engine Oil (C3 Grade)',
          recommendedBrands: ['Shell Helix Ultra ECT', 'Castrol EDGE Turbo Diesel', 'Mobil 1 ESP'],
          replacementInterval: '10,000 km or 1 year',
          benefits: [
            'Protects the mHawk engine from wear under high load conditions.',
            'Low SAPS formula protects the Diesel Particulate Filter (DPF) from ash buildup.',
            'Provides outstanding soot control and engine cleanliness.'
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Premium Ultra-Low Sulfur Diesel (BS6 Compliant)',
          recommendedBrands: ['Indian Oil XtraGreen', 'HP Power Diesel', 'Shell V-Power Diesel'],
          benefits: [
            'Protects high-pressure common rail (CRDi) fuel injectors.',
            'Ensures clean combustion and minimizes soot emissions.',
            'Increases engine responsiveness and fuel economy.'
          ],
        ),
        longevityAssessment: [
          'Regularly top up and monitor AdBlue (DEF) level to avoid engine restart locks.',
          'Change fuel filter assembly every 20,000 km to protect the injection pump.',
          'Service the automatic transmission fluid (ATF) at 80,000 km intervals.',
          'Inspect the DaVinci active suspension components for any fluid leaks or bushing damage.',
          'Rotate the 19-inch tyres every 10,000 km for balanced tread wear.'
        ],
      ),
      description: 'The Mahindra XUV 7XO is the next-generation premium crossover SUV, serving as the official facelift to the legendary XUV700. Released in 2026, it elevates the luxury segment with a state-of-the-art triple-screen cockpit, ChatGPT/Alexa integrations, and a Tenneco-developed DaVinci active suspension system, offering world-class ride dynamics and luxury features.',
    ),
    Vehicle(
      id: 'tata_nexon_2024',
      brand: 'Tata',
      model: 'Nexon',
      variant: 'Creative + 1.2L Turbo Petrol',
      type: 'Car',
      year: 2024,
      launchYear: '2023 (Facelift)',
      priceRange: '₹8.15 - ₹15.80 Lakh',
      usedPriceRange: '₹7.50 - ₹12.00 Lakh',
      fuelType: 'Petrol',
      engineCC: '1199 cc',
      transmission: '6-Speed Manual / 7-Speed DCA',
      mileage: '17.44 kmpl',
      cityMileage: '13.50 kmpl',
      highwayMileage: '18.20 kmpl',
      power: '118 bhp @ 5500 rpm',
      torque: '170 Nm @ 1750-4000 rpm',
      seatingCapacity: 5,
      fuelTankCapacity: '44 L',
      topSpeed: '180 km/h',
      colors: ['Fearless Purple', 'Creative Ocean', 'Pure Grey', 'Atlas White', 'Flame Red'],
      imageUrls: [
        'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=800&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '3995 mm',
        width: '1804 mm',
        height: '1620 mm',
        groundClearance: '208 mm',
        wheelbase: '2498 mm',
      ),
      features: {
        'Safety': [
          '6 Airbags (Standard)',
          'ABS with EBD',
          'Electronic Stability Program (ESP)',
          'TPMS (Tyre Pressure Monitoring)',
          'ISOFIX Child Seat Mounts',
          '360 Degree Camera'
        ],
        'Comfort & Convenience': [
          '10.25-inch Touchscreen Infotainment',
          'Fully Digital Instrument Cluster',
          'Wireless Apple CarPlay & Android Auto',
          'Voice Assisted Electric Sunroof',
          'Automatic Climate Control',
          'Wireless Smartphone Charger'
        ],
        'Exterior & Styling': [
          'Sequential LED DRLs',
          'LED Headlamps & Fog Lamps',
          '16-inch Diamond Cut Alloy Wheels',
          'Shark Fin Antenna'
        ]
      },
      parts: [
        VehiclePart(
          name: '1.2L Revotron Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.95,
          details: 'Turbocharger functioning perfectly. Carbon deposits: negligible. Oil level: 100%. No cylinder compression issues detected.',
        ),
        VehiclePart(
          name: 'Brake System',
          icon: 'adjust',
          status: 'Good',
          health: 0.85,
          details: 'Front disc pad thickness: 8.5mm (approx 85%). Rear drum shoes in good shape. ABS sensor calibration check passed.',
        ),
        VehiclePart(
          name: 'Suspension',
          icon: 'swap_vert',
          status: 'Good',
          health: 0.80,
          details: 'Independent McPherson struts. Minor bushing wear on left front arm, but shock absorbers have 100% dampening seal integrity.',
        ),
        VehiclePart(
          name: 'Wheels & Tyres',
          icon: 'blur_circular',
          status: 'Very Good',
          health: 0.88,
          details: 'Bridgestone Ecopia 215/60 R16. Tread depth: 6.2mm. Wheel alignment checked: correct.',
        ),
        VehiclePart(
          name: 'Exhaust & Emissions',
          icon: 'smoke_free',
          status: 'Excellent',
          health: 0.98,
          details: 'Catalytic converter clean. BS6 Phase-2 compliance verification complete. Lambda sensor outputs active grid.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '5W-30 Fully Synthetic Oil',
          recommendedBrands: ['Castrol Magnatec', 'Mobil 1', 'Shell Helix'],
          replacementInterval: '10,000 km or 1 year',
          benefits: [
            'Keeps the turbo engine clean and cool.',
            'Improves fuel economy and engine response.',
            'Protects key engine parts from wear and tear.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Regular Unleaded Petrol (91 Octane)',
          recommendedBrands: ['Indian Oil', 'HP Power', 'Bharat Petroleum'],
          benefits: [
            'Keeps fuel injectors clean.',
            'Ensures smooth engine firing.',
            'Produces less exhaust smoke.',
          ],
        ),
        longevityAssessment: [
          'Change the engine oil on time to protect the turbocharger.',
          'Clean or replace the air filter every 5,000 km for better airflow.',
          'Flush and replace the engine coolant every 2 years.',
          'Rotate tires every 10,000 km for even tread wear.',
        ],
      ),
      description: 'The Tata Nexon is a highly popular compact SUV in India. It is well-known for its robust build quality, holding a 5-star Global NCAP safety rating. The 2024 facelift brings a futuristic, aerospace-inspired interior and split-headlamp visual design.',
    ),
    Vehicle(
      id: 'hyundai_creta_2024',
      brand: 'Hyundai',
      model: 'Creta',
      variant: 'SX (O) 1.5L CRDi Diesel',
      type: 'Car',
      year: 2024,
      launchYear: '2024 (Facelift)',
      priceRange: '₹11.00 - ₹20.15 Lakh',
      usedPriceRange: '₹10.50 - ₹17.50 Lakh',
      fuelType: 'Diesel',
      engineCC: '1493 cc',
      transmission: '6-Speed Automatic / Torque Converter',
      mileage: '19.10 kmpl',
      cityMileage: '15.20 kmpl',
      highwayMileage: '21.00 kmpl',
      power: '114 bhp @ 4000 rpm',
      torque: '250 Nm @ 1500-2750 rpm',
      seatingCapacity: 5,
      fuelTankCapacity: '50 L',
      topSpeed: '185 km/h',
      colors: ['Robust Emerald Pearl', 'Ranger Khaki', 'Abyss Black', 'Atlas White', 'Titan Grey'],
      imageUrls: [
        'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=800&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '4330 mm',
        width: '1790 mm',
        height: '1635 mm',
        groundClearance: '190 mm',
        wheelbase: '2610 mm',
      ),
      features: {
        'Safety': [
          '6 Airbags (Standard)',
          'Hyundai SmartSense Level 2 ADAS',
          'Electronic Stability Control (ESC)',
          'All 4 Disc Brakes',
          'Hill Start Assist Control',
          'Blind View Monitor'
        ],
        'Comfort & Convenience': [
          'Dual Zone Automatic Climate Control',
          'Panoramic Sunroof (Voice Enabled)',
          'Bose Premium 8-Speaker Sound System',
          'Ventilated Front Seats',
          '8-way Power Driver Seat',
          '10.25-inch Dual Screen Layout'
        ],
        'Exterior & Styling': [
          'Parametric Black Chrome Grille',
          'Horizon LED DRLs spanning the width',
          '17-inch Diamond Cut Alloys',
          'Connecting LED Tail Lamps'
        ]
      },
      parts: [
        VehiclePart(
          name: '1.5L CRDi U2 Diesel Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.96,
          details: 'CRDi common-rail injection system fully pressurized. Glow plugs operating at standard parameters. Turbocharger wastegate operates cleanly.',
        ),
        VehiclePart(
          name: 'Automatic Gearbox',
          icon: 'toll',
          status: 'Excellent',
          health: 0.94,
          details: '6-Speed torque converter shift speed: <250ms. Fluid pressure matching factory standards. Torque converter lock-up clutch has 0% slip.',
        ),
        VehiclePart(
          name: 'Suspension & Steering',
          icon: 'swap_vert',
          status: 'Good',
          health: 0.88,
          details: 'Coupled Torsion Beam Axle rear suspension. No leaks in front dampers. Electronic Power Steering motor calibrated and responsive.',
        ),
        VehiclePart(
          name: 'Brakes (4-Wheel Disc)',
          icon: 'adjust',
          status: 'Very Good',
          health: 0.91,
          details: 'Premium multi-disc setup. Rotor surface roughness: minimal. Pad depth: 9.0mm front, 7.5mm rear. Brake booster responsive.',
        ),
        VehiclePart(
          name: 'ADAS Radar & Sensors',
          icon: 'radar',
          status: 'Excellent',
          health: 0.97,
          details: 'Front bumper radar, windshield camera, and side mirror cameras aligned. Auto emergency braking and lane keep assist successfully tested.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '5W-30 C2/C3 Diesel Engine Oil',
          recommendedBrands: ['Shell Helix Ultra', 'Castrol EDGE', 'Valvoline'],
          replacementInterval: '10,000 km or 1 year',
          benefits: [
            'Protects the Diesel Particulate Filter (DPF).',
            'Prevents soot and sludge buildup in engine.',
            'Ensures smooth cold starts in winter.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Premium Low-Sulfur Diesel',
          recommendedBrands: ['Indian Oil Premium Diesel', 'Shell V-Power Diesel'],
          benefits: [
            'Protects high-pressure common rail injectors.',
            'Prevents fuel filter clogging.',
            'Improves fuel mileage and engine life.',
          ],
        ),
        longevityAssessment: [
          'Always use recommended diesel fuel to avoid DPF blockage.',
          'Change the fuel filter every 20,000 km.',
          'Get the automatic transmission fluid checked at 80,000 km.',
          'Clean brake pads and service calipers every 10,000 km.',
        ],
      ),
      description: 'The Hyundai Creta is India\'s undisputed king of mid-size SUVs. Highly coveted for its smooth engine options, extensive feature checklist, comfortable ride quality, and excellent resale value. The 2024 update introduces Level 2 ADAS and a bold rectangular exterior aesthetic.',
    ),
    Vehicle(
      id: 'maruti_swift_2024',
      brand: 'Maruti Suzuki',
      model: 'Swift',
      variant: 'ZXi+ 1.2L Z-Series Petrol',
      type: 'Car',
      year: 2024,
      launchYear: '2024 (New Gen)',
      priceRange: '₹6.49 - ₹9.64 Lakh',
      usedPriceRange: '₹6.00 - ₹8.50 Lakh',
      fuelType: 'Petrol',
      engineCC: '1197 cc',
      transmission: '5-Speed Manual / 5-Speed AGS',
      mileage: '24.80 kmpl',
      cityMileage: '20.10 kmpl',
      highwayMileage: '25.75 kmpl',
      power: '80.4 bhp @ 5700 rpm',
      torque: '111.7 Nm @ 4300 rpm',
      seatingCapacity: 5,
      fuelTankCapacity: '37 L',
      topSpeed: '165 km/h',
      colors: ['Luster Blue', 'Novel Orange', 'Sizzling Red', 'Splendid Silver', 'Pearl Arctic White'],
      imageUrls: [
        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800&auto=format&fit=crop&q=60',
        'https://images.unsplash.com/photo-1525609004556-c46c7d6cf0a3?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '3860 mm',
        width: '1735 mm',
        height: '1520 mm',
        groundClearance: '163 mm',
        wheelbase: '2450 mm',
      ),
      features: {
        'Safety': [
          '6 Airbags (Standard across variants)',
          'ABS with EBD and Brake Assist',
          'ESP (Electronic Stability Program)',
          'Hill Hold Assist',
          'Reverse Parking Sensors & Camera'
        ],
        'Comfort & Convenience': [
          '9-inch SmartPlay Pro+ Infotainment',
          'Wireless Charger',
          'Rear AC Vents',
          'Suzuki Connect Telematics (40+ features)',
          'Push Button Start/Stop',
          'Cruise Control'
        ],
        'Exterior & Styling': [
          'LED Projector Headlamps with L-shaped DRLs',
          'Precision Cut 15-inch Alloy Wheels',
          'Glossy Black Front Grille with Chrome Accent'
        ]
      },
      parts: [
        VehiclePart(
          name: 'Z12E 3-Cylinder Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.98,
          details: 'New ultra-efficient 3-cylinder engine. Idle stability is smooth. Idle speed: 750 rpm. Thermal efficiency optimized.',
        ),
        VehiclePart(
          name: 'Transmission (Manual)',
          icon: 'sync',
          status: 'Excellent',
          health: 0.96,
          details: 'Short-throw 5-speed shifter. Clutch pedal weight: light. Gear engagement crisp and positive.',
        ),
        VehiclePart(
          name: 'Suspension',
          icon: 'swap_vert',
          status: 'Very Good',
          health: 0.90,
          details: 'Front MacPherson strut, rear torsion beam. Optimized for city roads, absorbing small speedbumps easily.',
        ),
        VehiclePart(
          name: 'Electricals & Battery',
          icon: 'flash_on',
          status: 'Excellent',
          health: 0.95,
          details: 'Alternator charging rate: 14.2V under load. Battery health indicator: 100%. Infotainment wiring intact.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '0W-16 Ultra Low Viscosity Oil',
          recommendedBrands: ['Ecstar (Maruti Genuine)', 'Mobil 1', 'Castrol Magnatec'],
          replacementInterval: '10,000 km or 1 year',
          benefits: [
            'Designed specifically for Maruti Z-series engines.',
            'Gives maximum fuel mileage (up to 24.8 kmpl).',
            'Reduces internal engine friction.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Regular Petrol (91 Octane)',
          recommendedBrands: ['BPCL', 'HPCL', 'Indian Oil'],
          benefits: [
            'Perfect match for daily city driving.',
            'Provides clean burn and low carbon deposits.',
            'Cost-effective and reliable.',
          ],
        ),
        longevityAssessment: [
          'Use Maruti Genuine Parts (MGP) for any replacements.',
          'Change the spark plugs every 40,000 km.',
          'Inspect the drive belt condition at every service.',
          'Keep tire pressure at 32 PSI for best ride comfort and mileage.',
        ],
      ),
      description: 'The Maruti Suzuki Swift is a legendary hatchback in the Indian market. Now in its fourth generation, it sports a highly efficient Z-Series 3-cylinder engine making it one of the most fuel-efficient petrol cars in India. Loved for its sporty handling and city-friendly footprint.',
    ),
    Vehicle(
      id: 'honda_activa_6g',
      brand: 'Honda',
      model: 'Activa 6G',
      variant: 'Deluxe Keyless H-Smart',
      type: 'Scooter',
      year: 2023,
      launchYear: '2023',
      priceRange: '₹76,234 - ₹82,734 (Ex-Showroom)',
      usedPriceRange: '₹55,000 - ₹70,000',
      fuelType: 'Petrol',
      engineCC: '109.51 cc',
      transmission: 'CVT (V-Matic)',
      mileage: '50.0 kmpl',
      cityMileage: '47.0 kmpl',
      highwayMileage: '53.0 kmpl',
      power: '7.73 bhp @ 8000 rpm',
      torque: '8.90 Nm @ 5500 rpm',
      seatingCapacity: 2,
      fuelTankCapacity: '5.3 L',
      topSpeed: '85 km/h',
      colors: ['Decent Blue Metallic', 'Rebel Red Metallic', 'Black', 'Pearl Precious White', 'Matte Axis Grey'],
      imageUrls: [
        'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '1833 mm',
        width: '697 mm',
        height: '1156 mm',
        groundClearance: '162 mm',
        wheelbase: '1260 mm',
      ),
      features: {
        'Safety & Smart Tech': [
          'Smart Key System (H-Smart)',
          'Smart Find (Locates scooter with flashing lights)',
          'Smart Unlock & Smart Start keyless',
          'Combi Brake System (CBS) with Equalizer'
        ],
        'Comfort & Convenience': [
          'External Fuel Fill lid (One click open)',
          'Double Lid Clog-Free Storage under-seat (20L)',
          'Engine Start/Stop Switch',
          'Telescopic Front Suspension'
        ],
        'Mechanical & Efficiency': [
          'eSP (Enhanced Smart Power) technology',
          'ACG Silent Start System',
          'Programmed Fuel Injection (PGM-Fi)'
        ]
      },
      parts: [
        VehiclePart(
          name: '110cc PGM-Fi Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.97,
          details: 'Silent start ACG motor works flawlessly. Throttle body clean. Idle RPM: 1400. Spark plug gap correct.',
        ),
        VehiclePart(
          name: 'V-Matic CVT Gearbox',
          icon: 'cached',
          status: 'Good',
          health: 0.85,
          details: 'CVT drive belt shows normal wear, no cracking. Roller weights slide smoothly. Clutch spring stiffness within limits.',
        ),
        VehiclePart(
          name: 'Telescopic Front Suspension',
          icon: 'straighten',
          status: 'Very Good',
          health: 0.92,
          details: 'Oil seals intact on both stanchions. Rebound dampening smooth. Rear 3-step adjustable spring is functional.',
        ),
        VehiclePart(
          name: 'Combi Brake System',
          icon: 'adjust',
          status: 'Good',
          health: 0.88,
          details: 'Rear drum cable adjusted. Front drum pads: 75% thickness left. Equalizer distributing forces correctly.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '10W-30 MA Scooter Oil',
          recommendedBrands: ['Honda Genuine 4T Oil', 'Castrol Activ Scooter', 'Motul Scooter'],
          replacementInterval: '3,000 km or 6 months',
          benefits: [
            'Keeps the compact 110cc engine running cool.',
            'Ensures smooth working of the automatic clutch.',
            'Provides quick engine start in mornings.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Regular Petrol',
          recommendedBrands: ['Any local fuel station (IOCL, HP, BPCL)'],
          benefits: [
            'Ensures smooth fuel flow through injectors.',
            'Prevents engine knocking.',
          ],
        ),
        longevityAssessment: [
          'Change engine oil every 3,000 km without fail.',
          'Replace transmission gear oil every 10,000 km.',
          'Clean the air filter element every 4,000 km.',
          'Inspect the CVT drive belt every 12,000 km for cracks.',
        ],
      ),
      description: 'The Honda Activa is the highest-selling scooter in Indian history. The Activa 6G brings BS6 Phase 2 compliance and the H-Smart keyless entry system. Known for bulletproof reliability, an extremely smooth engine, and a robust metal body.',
    ),
    Vehicle(
      id: 'suzuki_access_125',
      brand: 'Suzuki',
      model: 'Access 125',
      variant: 'Special Edition Disc Bluetooth',
      type: 'Scooter',
      year: 2024,
      launchYear: '2023',
      priceRange: '₹79,899 - ₹90,500 (Ex-Showroom)',
      usedPriceRange: '₹60,000 - ₹78,000',
      fuelType: 'Petrol',
      engineCC: '124 cc',
      transmission: 'CVT',
      mileage: '48.0 kmpl',
      cityMileage: '45.0 kmpl',
      highwayMileage: '52.0 kmpl',
      power: '8.6 bhp @ 6750 rpm',
      torque: '10 Nm @ 5500 rpm',
      seatingCapacity: 2,
      fuelTankCapacity: '5.0 L',
      topSpeed: '92 km/h',
      colors: ['Metallic Royal Bronze', 'Matte Blue', 'Pearl Mirage White', 'Metallic Matte Black'],
      imageUrls: [
        'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '1870 mm',
        width: '690 mm',
        height: '1160 mm',
        groundClearance: '160 mm',
        wheelbase: '1265 mm',
      ),
      features: {
        'Safety & Braking': [
          'Front Disc Brake (Premium variants)',
          'Combined Brake System (CBS)',
          'Side Stand Interlock (Safety Cut-off)'
        ],
        'Smart Features': [
          'Bluetooth Enabled Digital Console',
          'Turn-by-Turn Navigation alerts',
          'Call, SMS & WhatsApp notifications',
          'Phone Battery Level Indicator'
        ],
        'Comfort & Utility': [
          'Premium Retro Seat (Leatherette)',
          'USB Charging Port near Front Pocket',
          'LED Headlamp with Chrome Bezel',
          'One-push Central Lock'
        ]
      },
      parts: [
        VehiclePart(
          name: '125cc SEP Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.96,
          details: 'Suzuki Eco Performance (SEP) engine. Smooth throttle response. Valve clearance checked. Compression index: optimal.',
        ),
        VehiclePart(
          name: 'Brake System (Disc-Drum)',
          icon: 'adjust',
          status: 'Very Good',
          health: 0.90,
          details: 'Front disc calipers operating correctly. Brake fluid level: full. Rear drum shoes show moderate wear.',
        ),
        VehiclePart(
          name: 'Suspension',
          icon: 'swap_vert',
          status: 'Excellent',
          health: 0.94,
          details: 'Front telescopic forks operate with 0 stiction. Rear swingarm pivot lubricated and quiet.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '10W-30 MB Scooter Oil',
          recommendedBrands: ['Suzuki Genuine Oil', 'Motul Scooter Expert', 'Shell Advance'],
          replacementInterval: '3,500 km or 6 months',
          benefits: [
            'Optimizes the Suzuki Eco Performance (SEP) engine.',
            'Provides excellent heat resistance at high speeds.',
            'Lowers engine vibration.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Regular Petrol',
          recommendedBrands: ['Any reliable fuel station'],
          benefits: [
            'Provides clean burning.',
            'Maintains stable engine idling.',
          ],
        ),
        longevityAssessment: [
          'Change engine oil every 3,500 km.',
          'Clean the spark plug and adjust gap every 4,000 km.',
          'Replace air filter cartridge every 12,000 km.',
          'Lubricate throttle cables and brake levers regularly.',
        ],
      ),
      description: 'The Suzuki Access 125 is the segment leader in 125cc family scooters. It combines classic retro looks with modern features like Bluetooth console connectivity, chrome highlights, and a punchy 125cc engine that provides great mid-range acceleration.',
    ),
    Vehicle(
      id: 'hero_splendor_plus',
      brand: 'Hero',
      model: 'Splendor Plus',
      variant: 'XTEC i3S',
      type: 'Bike',
      year: 2024,
      launchYear: '2022',
      priceRange: '₹75,441 - ₹78,286 (Ex-Showroom)',
      usedPriceRange: '₹50,000 - ₹65,000',
      fuelType: 'Petrol',
      engineCC: '97.2 cc',
      transmission: '4-Speed Manual',
      mileage: '65.0 - 70.0 kmpl',
      cityMileage: '62.0 kmpl',
      highwayMileage: '72.0 kmpl',
      power: '7.91 bhp @ 8000 rpm',
      torque: '8.05 Nm @ 6000 rpm',
      seatingCapacity: 2,
      fuelTankCapacity: '9.8 L',
      topSpeed: '87 km/h',
      colors: ['Black with Sports Red', 'Black with Silver', 'Matte Shield Gold', 'Black with Purple'],
      imageUrls: [
        'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=800&auto=format&fit=crop&q=60',
      ],
      dimensions: VehicleDimensions(
        length: '2000 mm',
        width: '720 mm',
        height: '1052 mm',
        groundClearance: '165 mm',
        wheelbase: '1236 mm',
      ),
      features: {
        'Smart Tech & Console': [
          'Full Digital Meter Console',
          'Bluetooth Connectivity (Call & SMS Alerts)',
          'Real-Time Mileage Indicator (RTMI)',
          'Low Fuel Indicator'
        ],
        'Efficiency & Safety': [
          'i3S Technology (Idle Start-Stop System)',
          'Side Stand Engine Cut-Off',
          'Bank Angle Sensor (Shuts engine off on fall)',
          'Integrated Braking System (IBS)'
        ],
        'Utility': [
          'USB Charger Port',
          'High Intensity Halogen Headlight with LED DRL strip',
          'Signature Chrome Crash Guard'
        ]
      },
      parts: [
        VehiclePart(
          name: '97.2cc APDV Sloper Engine',
          icon: 'settings',
          status: 'Excellent',
          health: 0.99,
          details: 'The legendary horizontal single cylinder engine. Bulletproof durability. Fuel injector cleaned. Spark timing correct.',
        ),
        VehiclePart(
          name: '4-Speed Clutch & Gearbox',
          icon: 'sync',
          status: 'Very Good',
          health: 0.93,
          details: 'All-up shift pattern is positive. Clutch plate condition has 90% friction material remaining. Gear oil level normal.',
        ),
        VehiclePart(
          name: 'Brakes & Suspension',
          icon: 'adjust',
          status: 'Good',
          health: 0.86,
          details: 'Front 130mm drum and rear 130mm drum. IBS linkage adjusted. Twin hydraulic shock absorbers on swingarm functioning.',
        ),
      ],
      maintenance: VehicleMaintenance(
        engineOil: MaintenanceDetail(
          typeAndGrade: '10W-30 MA2 Motorcycle Oil',
          recommendedBrands: ['Hero 4T Plus', 'Castrol Activ 4T', 'Gulf Pride 4T'],
          replacementInterval: '3,000 km or 6 months',
          benefits: [
            'Protects engine, wet clutch, and gearbox together.',
            'Ensures very smooth gear shifting.',
            'Maintains high engine mileage.',
          ],
        ),
        fuel: MaintenanceDetail(
          typeAndGrade: 'Regular Petrol',
          recommendedBrands: ['Any standard petrol bunk'],
          benefits: [
            'Burns cleanly for maximum mileage.',
            'Maintains stable engine firing.',
          ],
        ),
        longevityAssessment: [
          'Clean, lubricate, and adjust the drive chain every 1,000 km.',
          'Change engine oil every 3,000 km to prevent internal wear.',
          'Clean air filter element every 3,000 km.',
          'Inspect and adjust brake shoes for proper stopping power.',
        ],
      ),
      description: 'The Hero Splendor is an absolute icon and India\'s highest selling motorcycle for decades. Renowned for its unparalleled mileage, low maintenance costs, and high durability. The XTEC variant adds a digital instrument console, Bluetooth, and modern graphics.',
    ),
  ];
}
