import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'interactive_details_sheets.dart';
import 'glass_card.dart';


class MaintenanceAdvisorView extends StatefulWidget {
  const MaintenanceAdvisorView({super.key});

  @override
  State<MaintenanceAdvisorView> createState() => _MaintenanceAdvisorViewState();
}

class _MaintenanceAdvisorViewState extends State<MaintenanceAdvisorView> {
  String _vehicleType = 'Car';
  String _fuelType = 'Petrol';
  int _modelYear = 2020;
  final int _currentYear = 2026;

  @override
  void initState() {
    super.initState();
  }

  int get _vehicleAge => _currentYear - _modelYear;

  String get _ageLabel {
    final age = _vehicleAge;
    if (age <= 0) return 'Brand New / Fresh';
    if (age <= 3) return '$age ${age == 1 ? 'Year' : 'Years'} Old (Modern)';
    if (age <= 9) return '$age Years Old (Mid-Age)';
    return '$age Years Old (High Mileage / Older)';
  }

  // Updates fuel type automatically if EV is selected
  void _selectVehicleType(String type) {
    setState(() {
      _vehicleType = type;
      if (type == 'EV') {
        _fuelType = 'Electric';
      } else if (_fuelType == 'Electric') {
        _fuelType = 'Petrol';
      }
    });
  }

  void _selectFuelType(String fuel) {
    if (_vehicleType == 'EV' && fuel != 'Electric') return;
    setState(() {
      _fuelType = fuel;
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculateSuggestions();
    final isEV = _vehicleType == 'EV' || _fuelType == 'Electric';


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(16),
        child: FadeInPoint(
          delayMs: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Title Header
            Text(
              'Smart Maintenance Advisor',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Input vehicle details to get precise oil, fuel, and long-term care recommendations.',
              style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Step 1: Vehicle Type Selector
            Text(
              '1. Select Vehicle Type',
              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildVehicleTypeCard('Car', Icons.directions_car),
                const SizedBox(width: 8),
                _buildVehicleTypeCard('Bike', Icons.motorcycle),
                const SizedBox(width: 8),
                _buildVehicleTypeCard('Scooter', Icons.moped),
                const SizedBox(width: 8),
                _buildVehicleTypeCard('EV', Icons.electric_car),
              ],
            ),
            const SizedBox(height: 20),

            // Step 2: Fuel Type Selector
            Text(
              '2. Select Fuel Type',
              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFuelChip('Petrol'),
                const SizedBox(width: 8),
                _buildFuelChip('Diesel'),
                const SizedBox(width: 8),
                _buildFuelChip('CNG'),
                const SizedBox(width: 8),
                _buildFuelChip('Electric'),
              ],
            ),
            const SizedBox(height: 20),

            // Step 3: Model Year / Age Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3. Model Year & Age',
                  style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_modelYear ($_ageLabel)',
                  style: GoogleFonts.outfit(color: Colors.cyan.shade800, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(150),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withAlpha(15)),
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.cyan,
                  inactiveTrackColor: Colors.cyan.withAlpha(35),
                  thumbColor: Colors.cyan,
                  overlayColor: Colors.cyan.withAlpha(40),
                  valueIndicatorColor: Colors.cyan,
                ),
                child: Slider(
                  value: _modelYear.toDouble(),
                  min: 2000,
                  max: 2026,
                  divisions: 26,
                  label: _modelYear.toString(),
                  onChanged: (val) {
                    setState(() {
                      _modelYear = val.toInt();
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results Divider
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.cyan, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Recommended Actions',
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Divider(
                    color: Colors.black.withAlpha(20),
                    thickness: 1,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Result 1: Engine Oil Advice
            // Result 1: Engine Oil Advice
            AnimatedGlassCard(
              glowColor: Colors.amber,
              onTap: () {
                InteractiveDetailsSheets.showLubricationSheet(
                  context: context,
                  vehicleType: _vehicleType,
                  typeAndGrade: result.oilGrade,
                  replacementInterval: result.oilInterval,
                  recommendedBrands: result.oilBrands,
                  benefits: result.oilBenefits,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEV ? Icons.electric_bolt_rounded : Icons.water_drop_rounded,
                        color: Colors.amber.shade700,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEV ? 'Electric Drive System Fluid' : 'Engine Lubrication Suggestion',
                                style: GoogleFonts.outfit(
                                  color: Colors.amber.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.oilGrade,
                            style: GoogleFonts.outfit(
                              color: Colors.black87,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Lifespan/Change interval
                          Row(
                            children: [
                              Icon(Icons.update_rounded, color: Colors.amber.shade700, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isEV ? 'Service Interval: ' : 'Change Interval: ',
                                style: GoogleFonts.outfit(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  result.oilInterval,
                                  style: GoogleFonts.outfit(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
  
                          // Recommended Brands
                          Text(
                            isEV ? 'Referred Fluid Brands:' : 'Recommended Oil Brands:',
                            style: GoogleFonts.outfit(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: result.oilBrands.map((brand) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.amber.withAlpha(50), width: 1),
                                ),
                                child: Text(
                                  brand,
                                  style: GoogleFonts.outfit(
                                    color: Colors.amber.shade900,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
  
                          Text(
                            isEV ? 'Fluid & System Safety Benefits:' : 'Key Lubrication Benefits:',
                            style: GoogleFonts.outfit(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(result.oilBenefits.length, (index) {
                            return _buildCheckBenefitPoint(result.oilBenefits[index], Colors.amber, index);
                          }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result 2: Fuel/Filter Recommendation
            AnimatedGlassCard(
              glowColor: Colors.cyan,
              onTap: () {
                InteractiveDetailsSheets.showFuelDynamicsSheet(
                  context: context,
                  vehicleType: _vehicleType,
                  fuelType: _fuelType,
                  typeAndGrade: result.fuelGrade,
                  recommendedBrands: result.fuelBrands,
                  benefits: result.fuelBenefits,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withAlpha(35),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isEV ? Icons.battery_charging_full_rounded : Icons.local_gas_station_rounded,
                        color: Colors.cyan.shade700,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isEV ? 'Power & Battery Suggestion' : 'Fuel & System Recommendation',
                                style: GoogleFonts.outfit(
                                  color: Colors.cyan.shade900,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Icon(Icons.info_outline_rounded, color: Colors.cyan, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            result.fuelGrade,
                            style: GoogleFonts.outfit(
                              color: Colors.black87,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
  
                          // Service / Charging advice
                          Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: Colors.cyan.shade700, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isEV ? 'Charging Advice: ' : 'Filter / System Service: ',
                                style: GoogleFonts.outfit(
                                  color: Colors.black54,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  result.fuelInterval,
                                  style: GoogleFonts.outfit(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
  
                          // Recommended Brands
                          Text(
                            isEV ? 'Recommended Networks:' : 'Referred Brands:',
                            style: GoogleFonts.outfit(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: result.fuelBrands.map((brand) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.cyan.withAlpha(50), width: 1),
                                ),
                                child: Text(
                                  brand,
                                  style: GoogleFonts.outfit(
                                    color: Colors.cyan.shade900,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
  
                          Text(
                            isEV ? 'Electric Drive Advantages:' : 'Performance Advantages:',
                            style: GoogleFonts.outfit(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(result.fuelBenefits.length, (index) {
                            return _buildCheckBenefitPoint(result.fuelBenefits[index], Colors.cyan, index);
                          }),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result 3: Age Specific Longevity Checklist
            Text(
              isEV ? 'EV Longevity & Safety Assessment' : 'Age-Specific Longevity Checklist',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedGlassCard(
              glowColor: Colors.purple,
              onTap: () {
                InteractiveDetailsSheets.showLongevityChecklistSheet(
                  context: context,
                  longevityTips: result.longevityTips,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEV ? 'EV Diagnostic Checklist Guidelines' : 'Diagnostic Checklist Guidelines',
                          style: GoogleFonts.outfit(
                            color: Colors.purple.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.fact_check_outlined, color: Colors.purple, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(result.longevityTips.length, (index) {
                      final tip = result.longevityTips[index];
                      return FadeInPoint(
                        delayMs: index * 80,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.health_and_safety_rounded, color: Colors.purple, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: GoogleFonts.outfit(
                                    color: Colors.black87,
                                    fontSize: 13.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildVehicleTypeCard(String type, IconData icon) {
    final isSelected = _vehicleType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectVehicleType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Colors.cyan, Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withAlpha(150),
            border: Border.all(
              color: isSelected ? Colors.cyan.shade600 : Colors.black.withAlpha(20),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.cyan.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 6,
                    )
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black54,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                type,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelChip(String fuel) {
    final isSelected = _fuelType == fuel;
    final isEV = _vehicleType == 'EV';
    final isDisabled = isEV && fuel != 'Electric';

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled ? null : () => _selectFuelType(fuel),
        child: Opacity(
          opacity: isDisabled ? 0.35 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white.withAlpha(150),
              border: Border.all(
                color: isSelected ? Colors.purple.shade400 : Colors.black.withAlpha(20),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.purple.withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 4,
                      )
                    ],
            ),
            child: Center(
              child: Text(
                fuel,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBenefitPoint(String text, Color accentColor, int index) {
    return FadeInPoint(
      delayMs: index * 80,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: accentColor,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dynamic Suggestion Calculation Engine
  AdvisorResult _calculateSuggestions() {
    final age = _vehicleAge;

    // EV logic
    if (_vehicleType == 'EV' || _fuelType == 'Electric') {
      return AdvisorResult(
        oilGrade: 'Electric Drive System Fluid',
        oilBrands: ['OEM Genuine EV Drive Fluid', 'Mobil EV Fluid', 'Castrol ON EV'],
        oilInterval: '40,000 km to 50,000 km',
        oilBenefits: [
          'Engine oil is not used in electric vehicles.',
          'Provides lubrication to the reduction gear unit.',
          'Reduces mechanical drag for optimal battery range.',
        ],
        fuelGrade: 'Electricity (Lithium battery)',
        fuelBrands: ['Tata Power EZ Charge', 'Jio-bp pulse', 'ChargeZone'],
        fuelInterval: 'Charge 20% to 80% daily',
        fuelBenefits: [
          'Zero tailpipe emissions and completely silent drive.',
          'Instant motor torque response.',
          'Avoids battery degradation by stopping at 80%.',
        ],
        longevityTips: [
          'Limit fast DC charging to extend battery lifespan.',
          'Get battery coolant inspected every 2 years.',
          'Inspect orange high-voltage insulation shielding yearly.',
          'Maintain tire pressure for less resistance and maximum range.',
        ],
      );
    }

    // CARS
    if (_vehicleType == 'Car') {
      if (age <= 3) {
        if (_fuelType == 'Diesel') {
          return AdvisorResult(
            oilGrade: '5W-30 C2/C3 Fully Synthetic Oil',
            oilBrands: ['Shell Helix Ultra', 'Castrol EDGE', 'Mobil 1 ESP'],
            oilInterval: '10,000 km or 1 year',
            oilBenefits: [
              'Protects high-tech emissions equipment like DPF.',
              'Ensures excellent startup protection in winters.',
              'Safeguards turbochargers from carbon deposits.',
            ],
            fuelGrade: 'Premium Low-Sulfur BS6 Diesel',
            fuelBrands: ['Indian Oil ExtraPremium', 'Shell V-Power Diesel'],
            fuelInterval: 'Change fuel filter every 20,000 km',
            fuelBenefits: [
              'Protects expensive common-rail injectors.',
              'Prevents early DPF filter choking.',
              'Improves fuel burn efficiency.',
            ],
            longevityTips: [
              'Always idle the engine for 30 seconds before shutoff to cool the turbo.',
              'Follow the official service calendar to protect your warranty.',
              'Inspect engine coolant concentration level.',
            ],
          );
        } else {
          // Petrol / CNG
          return AdvisorResult(
            oilGrade: '0W-20 or 5W-30 Fully Synthetic Oil',
            oilBrands: ['Mobil 1', 'Shell Helix Ultra', 'Castrol Magnatec'],
            oilInterval: '10,000 km or 1 year',
            oilBenefits: [
              'Delivers maximum fuel economy.',
              'Reduces internal friction inside modern tight engines.',
              'Prevents sludge buildup during city trips.',
            ],
            fuelGrade: _fuelType == 'CNG' ? 'CNG + Regular unleaded' : 'Regular Unleaded Petrol (91 Octane)',
            fuelBrands: ['IOCL ExtraPremium', 'HP Power', 'Speed (BPCL)'],
            fuelInterval: 'Clean throttle body every 20,000 km',
            fuelBenefits: [
              'Maintains throttle valve response.',
              'Burns clean with low engine deposits.',
            ],
            longevityTips: [
              'Use only genuine OEM filters for oil and air swap.',
              'Rotate all 4 tires every 10,000 km.',
              'Clean cabin AC filter for healthy indoor airflow.',
            ],
          );
        }
      } else if (age <= 9) {
        if (_fuelType == 'Diesel') {
          return AdvisorResult(
            oilGrade: '5W-40 Synthetic Blend or Semi-Synthetic',
            oilBrands: ['Castrol Magnatec Diesel', 'Shell Helix HX8', 'Valvoline All Climate'],
            oilInterval: '8,000 km to 10,000 km',
            oilBenefits: [
              'Stronger fluid film guards slightly worn internal valves.',
              'Controls sludge and carbon soot buildup.',
              'Resists heat thinning during long summer drives.',
            ],
            fuelGrade: 'Regular BS6 Diesel',
            fuelBrands: ['BPCL', 'HPCL', 'Indian Oil'],
            fuelInterval: 'Replace fuel filter at every alternate service',
            fuelBenefits: [
              'Ensures standard engine power.',
              'Maintains normal emission levels.',
            ],
            longevityTips: [
              'Get EGR (Exhaust Gas Recirculation) valve cleaned to avoid soot build.',
              'Check brake pads wear percentage and slider pins lubrication.',
              'Inspect suspension bushing rubbers for cracks.',
            ],
          );
        } else {
          // Petrol / CNG
          return AdvisorResult(
            oilGrade: '5W-30 or 5W-40 Semi-Synthetic Oil',
            oilBrands: ['Shell Helix HX7', 'Castrol Magnatec', 'Servo Futura'],
            oilInterval: '8,000 km to 10,000 km',
            oilBenefits: [
              'Provides reliable everyday engine defense.',
              'Reduces valve noise and vibration.',
              'Affordable maintenance cost.',
            ],
            fuelGrade: _fuelType == 'CNG' ? 'Regular CNG + Unleaded Petrol' : 'Regular Unleaded Petrol (91 Octane)',
            fuelBrands: ['Indian Oil', 'HPCL', 'BPCL'],
            fuelInterval: 'Replace air filter every 10,000 km',
            fuelBenefits: [
              'Optimal combustion matching city driving.',
              'Maintains spark plug health.',
            ],
            longevityTips: [
              'Check drive belt tension and inspect for cracking.',
              'Perform wheel alignment and balancing regularly.',
              'Replace spark plugs if they have run above 30,000 km.',
            ],
          );
        }
      } else {
        // Older Cars (10+ years)
        return AdvisorResult(
          oilGrade: '10W-40 or 15W-40 High Mileage Oil (Synthetic Blend)',
          oilBrands: ['Castrol GTX SUV', 'Shell Helix High Mileage', 'Mobil Super 1000'],
          oilInterval: '5,000 km to 7,500 km or 6 months',
          oilBenefits: [
            'Thicker grade seals piston ring gaps to restore compression.',
            'Contains seal conditioners to reduce active oil leaks.',
            'Reduces engine ticking and valve tapping noise.',
          ],
          fuelGrade: _fuelType == 'Diesel' ? 'Regular Diesel + Injector Additive' : 'Regular Petrol + Fuel Additive',
          fuelBrands: ['Liqui Moly Injector Cleaner', 'System G / System D Additive'],
          fuelInterval: 'Add fuel injector cleaner every 5,000 km',
          fuelBenefits: [
            'Cleans years of carbon deposit from fuel injectors.',
            'Ensures easier cold engine starts.',
          ],
          longevityTips: [
            'Check coolant rubber hoses for stiffness or leaks to prevent cooking the engine.',
            'Inspect engine rubber mounts; older engines shake more.',
            'Monitor engine oil dipstick level every 1,500 km.',
            'Flush gearbox fluid and differential oils if not done in 5 years.',
          ],
        );
      }
    }

    // BIKES
    if (_vehicleType == 'Bike') {
      if (age <= 3) {
        return AdvisorResult(
          oilGrade: '10W-30 or 10W-40 MA2 Synthetic Bike Oil',
          oilBrands: ['Motul 7100 4T', 'Shell Advance Ultra', 'Castrol Power1 Ultimate'],
          oilInterval: '3,000 km to 5,000 km',
          oilBenefits: [
            'Prevents wet-clutch slippage under acceleration.',
            'Delivers crisp, smooth gear shifts.',
            'Controls high-heat breakdown in air-cooled engines.',
          ],
          fuelGrade: 'Regular Petrol (91 Octane)',
          fuelBrands: ['Any premium fuel station'],
          fuelInterval: 'Inspect fuel pump screen every 10,000 km',
          fuelBenefits: [
            'Ensures clean combustion and stable engine idling.',
            'Protects sensitive fuel injectors on BS6 bikes.',
          ],
          longevityTips: [
            'Clean, lube and adjust chain tension every 500-800 km.',
            'Keep tire pressure at 28 PSI (Front) and 34 PSI (Rear).',
            'Avoid high pressure water spray directly on electrical nodes.',
          ],
        );
      } else if (age <= 9) {
        return AdvisorResult(
          oilGrade: '10W-40 MA2 Semi-Synthetic Bike Oil',
          oilBrands: ['Motul 5100 4T', 'Shell Advance AX7', 'Castrol Power1'],
          oilInterval: '3,000 km',
          oilBenefits: [
            'Balanced protection for daily office commutes.',
            'Ensures consistent wet-clutch response.',
            'Combats engine wear in bumper-to-bumper traffic.',
          ],
          fuelGrade: 'Regular Petrol',
          fuelBrands: ['HP', 'BP', 'Indian Oil'],
          fuelInterval: 'Clean carburetor or fuel injector nozzle every 12,000 km',
          fuelBenefits: [
            'Restores engine responsiveness.',
            'Maintains standard highway fuel economy.',
          ],
          longevityTips: [
            'Clean the air filter element every 4,000 km.',
            'Lube control cables (throttle, clutch) to keep them light.',
            'Check brake shoe thickness to ensure strong stopping power.',
          ],
        );
      } else {
        // Older bikes (10+ years)
        return AdvisorResult(
          oilGrade: '20W-40 or 20W-50 MA2 High Viscosity Mineral Oil',
          oilBrands: ['Castrol Activ 4T', 'Gulf Pride 4T', 'Servo 4T Zoom'],
          oilInterval: '2,000 km to 2,500 km',
          oilBenefits: [
            'Thicker layer protects worn gears and clutch plates.',
            'Minimizes oil leakage from dry rubber seals.',
            'Dampens engine vibrations.',
          ],
          fuelGrade: 'Regular Petrol + Injector/Carb Cleaner',
          fuelBrands: ['Standard Fuel Stations'],
          fuelInterval: 'Clean fuel tank and fuel cock filter every 10,000 km',
          fuelBenefits: [
            'Removes rust flakes from aging steel fuel tanks.',
            'Ensures clean fuel delivery.',
          ],
          longevityTips: [
            'Replace dry, cracked fuel delivery pipes immediately.',
            'Clean spark plug tip and adjust gap spacing every 3,000 km.',
            'Inspect wheel spokes, rims, and wheel bearings for side play.',
            'Get engine valve clearances (tappets) set if noisy.',
          ],
        );
      }
    }

    // SCOOTERS
    if (_vehicleType == 'Scooter') {
      if (age <= 3) {
        return AdvisorResult(
          oilGrade: '10W-30 MB Semi-Synthetic Scooter Oil',
          oilBrands: ['Honda Genuine 4T Scooter Oil', 'Castrol Activ Scooter', 'Motul Scooter'],
          oilInterval: '3,000 km or 6 months',
          oilBenefits: [
            'Designed for dry clutch gearless automatic scooters.',
            'Reduces engine friction to save fuel.',
            'Ensures quick start response in winter.',
          ],
          fuelGrade: 'Regular Petrol',
          fuelBrands: ['IOCL', 'HPCL', 'BPCL'],
          fuelInterval: 'Inspect fuel injector every 10,000 km',
          fuelBenefits: [
            'Maintains flat, smooth acceleration curves.',
          ],
          longevityTips: [
            'Inspect CVT drive belt and slide rollers every 10,000 km.',
            'Replace foam/paper air filter every 12,000 km.',
            'Verify front telescopic suspension seals are leak-free.',
          ],
        );
      } else if (age <= 9) {
        return AdvisorResult(
          oilGrade: '10W-30 or 20W-40 MB Scooter Oil',
          oilBrands: ['Suzuki Genuine Oil', 'Shell Advance Scooter', 'Gulf Pride Scooter'],
          oilInterval: '3,000 km',
          oilBenefits: [
            'Good thermal tolerance in dense city rides.',
            'Maintains optimal compression.',
          ],
          fuelGrade: 'Regular Petrol',
          fuelBrands: ['Any local bunk'],
          fuelInterval: 'Check fuel hose condition every 8,000 km',
          fuelBenefits: [
            'Consistent mileage output.',
          ],
          longevityTips: [
            'Change transmission final gear oil every 10,000 km.',
            'Clean front/rear drum brakes to avoid screeching noise.',
            'Keep air-cooling fan shroud clean of leaves or mud.',
          ],
        );
      } else {
        // Older Scooters (10+ years)
        return AdvisorResult(
          oilGrade: '20W-40 MB High Viscosity Scooter Oil',
          oilBrands: ['Castrol Activ Scooter', 'Servo Scooter 4T', 'Shell Advance AX5'],
          oilInterval: '2,000 km to 2,500 km',
          oilBenefits: [
            'Thicker film stops oil burning in high mileage engines.',
            'Protects older bearings and piston walls.',
          ],
          fuelGrade: 'Regular Petrol',
          fuelBrands: ['Standard station'],
          fuelInterval: 'Clean carburetor jet pin every 10,000 km',
          fuelBenefits: [
            'Fixes engine stalling and erratic idling.',
          ],
          longevityTips: [
            'Change CVT drive belt immediately if showing visible cracks.',
            'Inspect rubber engine mounts and suspension links.',
            'Lube front brake link pivots and clean cables.',
            'Check exhaust pipe for rust holes and exhaust leaks.',
          ],
        );
      }
    }

    return AdvisorResult(
      oilGrade: '10W-40 Semi-Synthetic Oil',
      oilBrands: ['Castrol Magnatec', 'Shell Helix'],
      oilInterval: '8,000 km',
      oilBenefits: ['Protects older components.', 'Keeps engine clean.'],
      fuelGrade: 'Regular Fuel',
      fuelBrands: ['IOCL'],
      fuelInterval: 'At every service',
      fuelBenefits: ['Ensures standard drive.'],
      longevityTips: ['Check details during service.'],
    );
  }
}

class AdvisorResult {
  final String oilGrade;
  final List<String> oilBrands;
  final String oilInterval;
  final List<String> oilBenefits;
  final String fuelGrade;
  final List<String> fuelBrands;
  final String fuelInterval;
  final List<String> fuelBenefits;
  final List<String> longevityTips;

  AdvisorResult({
    required this.oilGrade,
    required this.oilBrands,
    required this.oilInterval,
    required this.oilBenefits,
    required this.fuelGrade,
    required this.fuelBrands,
    required this.fuelInterval,
    required this.fuelBenefits,
    required this.longevityTips,
  });
}
