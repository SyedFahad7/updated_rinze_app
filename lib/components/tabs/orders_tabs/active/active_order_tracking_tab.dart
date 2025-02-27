import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../utils/string_utils.dart';
import '../../../order_timeline_tile.dart';

class ActiveOrderTrackingTab extends StatefulWidget {
  const ActiveOrderTrackingTab({
    super.key,
    required this.orderStatuses,
    required this.currentStatus,
    required this.serviceTitles,
  });

  final List<dynamic> orderStatuses;
  final List<dynamic> serviceTitles;
  final String currentStatus;

  @override
  State<ActiveOrderTrackingTab> createState() => _ActiveOrderTrackingTabState();
}

class _ActiveOrderTrackingTabState extends State<ActiveOrderTrackingTab> {
  late List<dynamic> backendStatuses;

  List statuses = [
    'confirmed',
    'readyForPickup',
    'orderPickedUp',
    'reachedCollectionCentre',
    'readyForDelivery',
    'outForDelivery',
    'delivered',
  ];

  List<String?> _generateServiceStatuses(List<dynamic> serviceTitles) {
    return serviceTitles
        .map((title) {
          switch (title.toLowerCase()) {
            case 'washing':
              return 'inWashing';
            case 'ironing':
              return 'inIroning';
            case 'washing and ironing':
              return 'inWashing&Ironing';
            case 'dry cleaning':
              return 'inDryCleaning';
            case 'deep cleaning':
              return 'inDeepCleaning';
            default:
              return null; // If the service title doesn't match any known status
          }
        })
        .where((status) => status != null)
        .toList(); // Remove null values
  }

  @override
  void initState() {
    print("hello world");
    super.initState();
    backendStatuses = widget.orderStatuses;
  }

  // Call this method whenever backendStatuses changes
  void updateStatuses(List<dynamic> newStatuses) {
    setState(() {
      backendStatuses = newStatuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    backendStatuses = widget.orderStatuses;

    // Generate service-related statuses dynamically
    final serviceStatuses = _generateServiceStatuses(widget.serviceTitles);

    // Combine all statuses
    final allStatuses = [
      ...statuses.sublist(0, 4),
      ...serviceStatuses,
      ...statuses.sublist(4),
    ];

    print("All Statuses: $allStatuses");

    final currentStatusIndex = allStatuses.indexOf(widget.currentStatus);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.halfWhite,
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
            border: Border.all(
              color: AppColors.black.withOpacity(0.06),
              width: 2.0,
            ),
          ),
          child: ListView.builder(
            itemCount: allStatuses.length,
            itemBuilder: (context, index) {
              final status = allStatuses[index];
              final isPast = index <= currentStatusIndex;
              final backendStatus = backendStatuses.firstWhere(
                (s) => s['status'] == status,
                orElse: () => null,
              );
              final dateTime = backendStatus != null
                  ? DateTime.parse(backendStatus['updatedAt'])
                  : null;
              final formattedDateTime = dateTime != null
                  ? '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}  ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}'
                  : 'Pending';

              // Determine the image to show based on the status
              String imagePath;
              switch (status) {
                case 'confirmed':
                  imagePath = 'assets/images/confirmed.png';
                  break;
                case 'readyForPickup':
                  imagePath = 'assets/images/ready_for_pickup.png';
                  break;
                case 'orderPickedUp':
                  imagePath = 'assets/images/order_picked_up.png';
                  break;
                case 'reachedCollectionCentre':
                  imagePath = 'assets/images/reached_collection_centre.png';
                  break;
                case 'readyForDelivery':
                  imagePath = 'assets/images/ready_for_delivery.png';
                  break;
                case 'outForDelivery':
                  imagePath = 'assets/images/out_for_delivery.png';
                  break;
                case 'delivered':
                  imagePath = 'assets/images/delivered.png';
                  break;
                default:
                  imagePath = 'assets/images/default_status.png';
              }

              return OrderTimelineTile(
                isFirst: index == 0,
                isLast: index == allStatuses.length - 1,
                isPast: isPast,
                title: capitalize(splitString(status)),
                dateTime: formattedDateTime,
                imagePath: imagePath, // Pass the image path to the tile
                showImage: index ==
                    currentStatusIndex, // Show image only for current status
              );
            },
          ),
        ),
      ),
    );
  }
}
