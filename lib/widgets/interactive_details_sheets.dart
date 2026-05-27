import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_card.dart';

class InteractiveDetailsSheets {
  // 1. LUBRICATION SHEET
  static void showLubricationSheet({
    required BuildContext context,
    required String vehicleType,
    required String typeAndGrade,
    required String? replacementInterval,
    required List<String> recommendedBrands,
    required List<String> benefits,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(120),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _LubricationSheetWidget(
              vehicleType: vehicleType,
              typeAndGrade: typeAndGrade,
              replacementInterval: replacementInterval,
              recommendedBrands: recommendedBrands,
              benefits: benefits,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // 2. FUEL DYNAMICS SHEET
  static void showFuelDynamicsSheet({
    required BuildContext context,
    required String vehicleType,
    required String fuelType,
    required String typeAndGrade,
    required List<String> recommendedBrands,
    required List<String> benefits,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(120),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _FuelDynamicsSheetWidget(
              vehicleType: vehicleType,
              fuelType: fuelType,
              typeAndGrade: typeAndGrade,
              recommendedBrands: recommendedBrands,
              benefits: benefits,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // 3. LONGEVITY CHECKLIST SHEET
  static void showLongevityChecklistSheet({
    required BuildContext context,
    required List<String> longevityTips,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(120),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _LongevityChecklistWidget(
              longevityTips: longevityTips,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // 4. METRIC DETAIL DIALOG
  static void showMetricDetailSheet({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String detailTitle = label;
        String explanation = '';
        List<String> insights = [];
        Color themeColor = Colors.cyan;

        if (label.toLowerCase().contains('price')) {
          themeColor = Colors.amber;
          detailTitle = 'Valuation & Showroom Price';
          explanation = 'Showroom price includes basic factory invoice, local road taxes, registration fees, and minimum mandatory insurance.';
          insights = [
            'RTO Tax: Varies between 8% to 15% across different states.',
            'Insurance: Premium comprehensive policy recommended for complete coverage.',
            'Depreciation: Vehicles lose 10% to 15% value as soon as they drive out.',
          ];
        } else if (label.toLowerCase().contains('value') || label.toLowerCase().contains('resale')) {
          themeColor = Colors.green;
          detailTitle = 'Estimated Resale Value';
          explanation = 'Resale valuation is calculated based on market demand, age, odometer mileage, engine displacement, and historical service logs.';
          insights = [
            'Maintain service records to maximize resale value up to 20%.',
            'Avoid custom modifications which generally decrease the target audience.',
            'Regular waxing and interior cleaning keep the aesthetic value premium.',
          ];
        } else if (label.toLowerCase().contains('mileage') || label.toLowerCase().contains('range')) {
          themeColor = Colors.cyan;
          detailTitle = 'Fuel Efficiency & Range';
          explanation = 'Claimed mileage is measured under standard testing conditions. Real-world mileage varies with driving styles and traffic congestion.';
          insights = [
            'Eco-Driving: Gentle acceleration increases fuel economy by up to 15%.',
            'Tire Pressure: Keep tires properly inflated to reduce road rolling resistance.',
            'Idle Consumption: Turn off engine during stops longer than 30 seconds.',
          ];
        } else if (label.toLowerCase().contains('engine') || label.toLowerCase().contains('cc')) {
          themeColor = Colors.deepPurple;
          detailTitle = 'Powertrain & Engine CC';
          explanation = 'Engine displacement (CC - Cubic Centimeters) measures the total sweep volume of pistons inside cylinders, determining peak power.';
          insights = [
            'High CC means larger volume, delivering greater horse power and torque.',
            'Smaller CC focus strictly on fuel economy and city commuting ease.',
            'Periodic throttle valve decoking maintains linear power curves.',
          ];
        } else if (label.toLowerCase().contains('capacity') || label.toLowerCase().contains('tank')) {
          themeColor = Colors.teal;
          detailTitle = 'Fuel Reservoir Capacity';
          explanation = 'Total storage capacity of fuel tank or battery packet, governing the maximum nonstop highway cruising radius.';
          insights = [
            'Never drive down to absolute empty to protect fuel pump from overheating.',
            'For EVs, standard battery capacity dictates thermal buffer reserve.',
            'Fuel vapor space: 10% volume is left blank for gas expansions.',
          ];
        } else if (label.toLowerCase().contains('transmission')) {
          themeColor = Colors.indigo;
          detailTitle = 'Transmission & Drivetrain';
          explanation = 'Transmission systems transfer rotating mechanical power from the crankshaft to wheels via gear steps or belt pulleys.';
          insights = [
            'Manual: Absolute fuel control, periodic clutch plate checking required.',
            'Automatic/CVT: Stress-free city commutes, requires transmission fluid swap every 40,000 km.',
            'EV Reduction: Single speed direct drive gear systems are virtually maintenance-free.',
          ];
        } else {
          detailTitle = label;
          explanation = 'Technical specifications captured from manufacturer blueprints and AI expert visual scanning appraisal.';
          insights = [
            'Parameter: $value',
            'Validated through verified database models.',
          ];
        }

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: themeColor.withAlpha(60), width: 1.5),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: themeColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    detailTitle,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Detected:',
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          value,
                          style: GoogleFonts.outfit(
                            color: themeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  explanation,
                  style: GoogleFonts.outfit(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Expert Diagnostic Tips:',
                  style: GoogleFonts.outfit(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...insights.map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.insights, color: themeColor, size: 14),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              insight,
                              style: GoogleFonts.outfit(
                                color: Colors.black87,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Close',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// PRIVATE WIDGETS
// ----------------------------------------------------

class _LubricationSheetWidget extends StatelessWidget {
  final String vehicleType;
  final String typeAndGrade;
  final String? replacementInterval;
  final List<String> recommendedBrands;
  final List<String> benefits;
  final ScrollController scrollController;

  const _LubricationSheetWidget({
    required this.vehicleType,
    required this.typeAndGrade,
    required this.replacementInterval,
    required this.recommendedBrands,
    required this.benefits,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isEV = vehicleType == 'EV' || typeAndGrade.toLowerCase().contains('electric');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag indicator bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEV ? Icons.electrical_services_rounded : Icons.water_drop_rounded,
                    color: Colors.amber.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEV ? 'Electric Drive System Fluid' : 'AI Lubrication Insights',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isEV ? 'Power reduction gear system' : 'Internal engine oil diagnostics',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(20),
              children: [
                // Display grade
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.withAlpha(20), Colors.amber.withAlpha(5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEV ? 'RECOMMENDED REDUCTION FLUID:' : 'ENGINE OIL SPECIFICATION:',
                        style: GoogleFonts.outfit(
                          color: Colors.amber.shade900,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        typeAndGrade,
                        style: GoogleFonts.outfit(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (replacementInterval != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.av_timer_rounded, color: Colors.amber.shade800, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Change Interval: ',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              replacementInterval!,
                              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Brand choices
                Text(
                  'Expert Selected Lubricant Brands:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: recommendedBrands.map((brand) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withAlpha(30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.amber.shade800, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            brand,
                            style: GoogleFonts.outfit(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Guide points
                Text(
                  isEV ? 'Reduction Gear Fluid Checklist:' : 'Step-by-Step Oil Level Appraisal:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                if (isEV) ...[
                  _buildStepTile(1, 'Check for underbody fluid spots', 'EV reduction fluid leaks usually leave clear gold/red fluid spots right under the drive motor.'),
                  _buildStepTile(2, 'Get coolant level inspected', 'EV electronics and battery coolant loops should be flushed according to dealer guidelines.'),
                  _buildStepTile(3, 'Listen for gear whining noises', 'A high-pitch metallic grind from front/rear indicates worn-out reduction gear lubrication.'),
                ] else ...[
                  _buildStepTile(1, 'Park on a flat level surface', 'Ensure the car engine is turned off for at least 10 minutes so oil settles back in the oil pan.'),
                  _buildStepTile(2, 'Pull the dipstick and wipe it clean', 'Wipe with a clean lint-free cloth, then re-insert it fully and draw it back out again.'),
                  _buildStepTile(3, 'Observe the fluid mark alignment', 'The oil layer must reside between the Minimum and Maximum holes/indicators.'),
                ],
                const SizedBox(height: 24),

                // Warnings section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Warning Signs to Watch Out For:',
                              style: GoogleFonts.outfit(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEV 
                                  ? '• Strange grinding whine at high speed\n• Dashboard thermal system warning light\n• Underbody fluid drops near transmission box'
                                  : '• Dark pitch-black tar-like oil color\n• Sluggish engine startup / clicking sounds\n• Burning petroleum smell when idling',
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 12,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Benefits
                Text(
                  'Key Engine Health Benefits:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(int step, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.black54, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelDynamicsSheetWidget extends StatelessWidget {
  final String vehicleType;
  final String fuelType;
  final String typeAndGrade;
  final List<String> recommendedBrands;
  final List<String> benefits;
  final ScrollController scrollController;

  const _FuelDynamicsSheetWidget({
    required this.vehicleType,
    required this.fuelType,
    required this.typeAndGrade,
    required this.recommendedBrands,
    required this.benefits,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isEV = vehicleType == 'EV' || fuelType.toLowerCase().contains('electric');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEV ? Icons.battery_charging_full_rounded : Icons.local_gas_station_rounded,
                    color: Colors.cyan.shade800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEV ? 'Power & Battery Insights' : 'Fuel Dynamics & Systems',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        isEV ? 'Cell diagnostics and network guides' : 'Combustion and filter advisory',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),
          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.all(20),
              children: [
                // Grade card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.cyan.withAlpha(20), Colors.cyan.withAlpha(5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEV ? 'RECOMMENDED CHARGING PATHWAY:' : 'RECOMMENDED COMBUSTION GRADE:',
                        style: GoogleFonts.outfit(
                          color: Colors.cyan.shade900,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        typeAndGrade,
                        style: GoogleFonts.outfit(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Brands/Networks
                Text(
                  isEV ? 'Recommended Fast Charging Networks:' : 'Premium Fuel Brands:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: recommendedBrands.map((brand) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan.withAlpha(30)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEV ? Icons.electric_bolt_rounded : Icons.local_gas_station_rounded,
                            color: Colors.cyan.shade800,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            brand,
                            style: GoogleFonts.outfit(color: Colors.cyan.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Battery care or Additive tips
                Text(
                  isEV ? 'Battery Health & Longevity Rules:' : 'Powertrain Performance Diagnostics:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                if (isEV) ...[
                  _buildBulletPoint(Icons.health_and_safety, 'Adhere to the 20-80% charging window', 'Avoid draining battery below 20% or topping up to 100% too often. Keeping cells in the mid-range halts quick chemical cell decay.'),
                  _buildBulletPoint(Icons.wb_sunny, 'Avoid intense heat immediately after charging', 'Allow battery temperatures to normalize before driving aggressive sport modes under hot sun conditions.'),
                  _buildBulletPoint(Icons.power, 'Opt for AC charging over DC fast hubs', 'AC trickle chargers protect grid components and maintain well-balanced internal cell voltages.'),
                ] else ...[
                  _buildBulletPoint(Icons.clean_hands, 'Use high octane/additives occasionally', 'Injecting specialized throttle body or injector cleaners every 5,000 km flushes out carbon sludge from pistons.'),
                  _buildBulletPoint(Icons.filter_alt, 'Replace the air filter elements on time', 'Choked air pathways lead to poor fuel-to-air combustion, which increases fuel consumption by 12% to 15%.'),
                  _buildBulletPoint(Icons.electrical_services, 'Keep spark plugs clean of black carbon', 'Wet or black-glazed spark plugs cause engine misfires, erratic idling, and poor mileage ratios.'),
                ],
                const SizedBox(height: 24),

                // Benefits
                Text(
                  'Identified Advantages:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                ...benefits.map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.cyan, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: GoogleFonts.outfit(color: Colors.black87, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.cyan.shade900, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.black54, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LongevityChecklistWidget extends StatefulWidget {
  final List<String> longevityTips;
  final ScrollController scrollController;

  const _LongevityChecklistWidget({
    required this.longevityTips,
    required this.scrollController,
  });

  @override
  State<_LongevityChecklistWidget> createState() => _LongevityChecklistWidgetState();
}

class _LongevityChecklistWidgetState extends State<_LongevityChecklistWidget> {
  late List<bool> _checkedStates;

  @override
  void initState() {
    super.initState();
    _checkedStates = List.generate(widget.longevityTips.length, (index) => false);
  }

  int get _checkedCount => _checkedStates.where((c) => c).length;
  double get _progress => widget.longevityTips.isEmpty ? 0.0 : _checkedCount / widget.longevityTips.length;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fact_check_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workshop Self-Diagnostic',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Age-specific structural checklist',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          const Divider(),

          // Interactive Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.withAlpha(20), Colors.purple.withAlpha(5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection Progress:',
                        style: GoogleFonts.outfit(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '$_checkedCount / ${widget.longevityTips.length} Inspected',
                        style: GoogleFonts.outfit(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      color: Colors.purple,
                      backgroundColor: Colors.purple.withAlpha(30),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _progress == 1.0 
                        ? 'Excellent! All longevity check points are successfully verified.' 
                        : 'Tap and check off items as you perform physical examinations on your vehicle.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.longevityTips.length,
              itemBuilder: (context, index) {
                final checked = _checkedStates[index];
                final tip = widget.longevityTips[index];

                return FadeInPoint(
                  delayMs: index * 40,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                    onTap: () {
                      setState(() {
                        _checkedStates[index] = !_checkedStates[index];
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: checked ? Colors.purple.withAlpha(15) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: checked ? Colors.purple.withAlpha(60) : Colors.black.withAlpha(10),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Custom animated checkbox
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: checked ? Colors.purple : Colors.white,
                              border: Border.all(
                                color: checked ? Colors.purple : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: checked
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              tip,
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                color: checked ? Colors.grey.shade700 : Colors.black87,
                                decoration: checked ? TextDecoration.lineThrough : null,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
