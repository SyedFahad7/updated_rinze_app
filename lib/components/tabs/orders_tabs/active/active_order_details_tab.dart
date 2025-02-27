import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rinze/components/order_details_card.dart';
import 'package:rinze/screens/home_navigation_screen.dart';
import 'package:rinze/utils/string_utils.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../../../../constants/app_colors.dart';
import '../../../../constants/app_fonts.dart';
import 'package:share_plus/share_plus.dart'; // Add this import
import 'package:path_provider/path_provider.dart'; // Add this import

class ActiveOrderDetailsTab extends StatefulWidget {
  const ActiveOrderDetailsTab({
    super.key,
    required this.ordersList,
    required this.orderNumber,
    required this.totalItems,
    required this.paymentStatus,
    required this.pickupData,
    required this.deliveryData,
    required this.addressData,
    required this.orderId,
    required this.orderStatuses,
  });

  final List<dynamic> ordersList;
  final List<dynamic> orderStatuses;
  final Map<String, dynamic> pickupData;
  final Map<String, dynamic> deliveryData;
  final Map<String, dynamic> addressData;
  final String orderNumber;
  final int totalItems;
  final String paymentStatus;
  final String orderId;

  @override
  State<ActiveOrderDetailsTab> createState() => _ActiveOrderDetailsTabState();
}

class _ActiveOrderDetailsTabState extends State<ActiveOrderDetailsTab> {
  final List paymentStatuses = [
    "awaitingPayment",
    "partiallyPaid",
    "paid",
    "refunded",
  ];

  String pickupDate = '';
  String pickupTime = '';
  String pickupType = '';
  String pickupAgentId = '';
  String pickupAgentName = '';
  String pickupAgentMobileNumber = '';
  String deliveryDate = '';
  String deliveryTime = '';
  String deliveryType = '';
  String deliveryAgentId = '';
  String deliveryAgentName = '';
  String deliveryAgentMobileNumber = '';
  String formattedAddress = '';
  String? cancelReasonError;

  final TextEditingController _cancelOrderTextController =
      TextEditingController();

  List<Color> checkPaymentStatus() {
    if (widget.paymentStatus == 'paid') {
      return [
        AppColors.retroLime.withValues(alpha: 0.3),
        AppColors.green,
      ];
    } else if (widget.paymentStatus == 'refunded') {
      return [
        AppColors.lightRed.withValues(alpha: 0.3),
        AppColors.fadeRed,
      ];
    }
    return [
      AppColors.lightYellow.withValues(alpha: 0.3),
      AppColors.darkYellow,
    ];
  }

  Future<Uint8List> svgToPng(String assetPath,
      {int width = 100, int height = 100}) async {
    // Load the SVG file
    final svgString = await rootBundle.loadString(assetPath);

    // Create a PictureInfo from the SVG string
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);

    // Create a canvas to render the SVG
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawPicture(pictureInfo.picture);

    // Convert the canvas to an image
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);

    // Convert the image to PNG bytes
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();
    _parseData();
  }

  void _parseData() {
    pickupDate =
        widget.pickupData['pickupDate'].split('T')[0] ?? 'To be assigned';
    pickupTime = widget.pickupData['pickupTime'] ?? 'To be assigned';
    pickupType = widget.pickupData['pickupType'] ?? 'None';
    pickupAgentId = widget.pickupData['pickup_agent']?['profile']?['profileRef']
            ?['agentId'] ??
        'To be assigned';
    pickupAgentName =
        widget.pickupData['pickup_agent']?['fullName'] ?? 'To be assigned';
    pickupAgentMobileNumber =
        widget.pickupData['pickup_agent']?['mobileNumber'] ?? 'To be assigned';
    deliveryDate =
        widget.deliveryData['deliveryDate'].split('T')[0] ?? 'To be assigned';
    deliveryTime = widget.deliveryData['deliveryTime'] ?? 'To be assigned';
    deliveryType = widget.deliveryData['deliveryType'] ?? 'None';
    deliveryAgentId = widget.deliveryData['delivery_agent']?['profile']
            ?['profileRef']?['agentId'] ??
        'To be assigned';
    deliveryAgentName =
        widget.deliveryData['delivery_agent']?['fullName'] ?? 'To be assigned';
    deliveryAgentMobileNumber = widget.deliveryData['delivery_agent']
            ?['mobileNumber'] ??
        'To be assigned';
    formattedAddress = widget.addressData['addressComponents']
            ['formatted_address'] ??
        'To be assigned';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Number',
                            style: TextStyle(
                              color: AppColors.black.withValues(alpha: 0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize12,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            widget.orderNumber,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Status',
                            style: TextStyle(
                              color: AppColors.black.withValues(alpha: 0.6),
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize12,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: checkPaymentStatus()[0],
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              capitalize(splitString(widget.paymentStatus)),
                              style: TextStyle(
                                color: checkPaymentStatus()[1],
                                fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                                fontSize: AppFonts.fontSize12,
                                fontWeight: AppFonts.fontWeightRegular,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: TextStyle(
                          color: AppColors.black.withValues(alpha: 0.6),
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize12,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        capitalize(formattedAddress),
                        style: const TextStyle(
                          color: AppColors.black,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            OrderDetailsCard(
              agentType: 'Pickup',
              pickupType: pickupType,
              date: pickupDate,
              time: pickupTime,
              agentId: pickupAgentId,
              agentName: pickupAgentName,
              agentMobileNumber: pickupAgentMobileNumber,
            ),
            const SizedBox(height: 24.0),
            OrderDetailsCard(
              agentType: 'Delivery',
              pickupType: deliveryType,
              date: deliveryDate,
              time: deliveryTime,
              agentId: deliveryAgentId,
              agentName: deliveryAgentName,
              agentMobileNumber: deliveryAgentMobileNumber,
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Order',
                    style: TextStyle(
                      color: AppColors.black,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize18,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/hanger.svg',
                      ),
                      const SizedBox(width: 2.0),
                      Text(
                        '${widget.totalItems} Items',
                        style: const TextStyle(
                          color: AppColors.hintBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightRegular,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.ordersList.length,
                itemBuilder: (context, index) {
                  final services = widget.ordersList[index];
                  final serviceTitle = services['service']['serviceTitle'];
                  final laundryByKG = services['order']['laundryByKG'] ?? {};
                  final laundryPerPiece =
                      services['order']['laundryByPiece']?['products'] ?? {};

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (laundryPerPiece != null)
                        if (laundryPerPiece.isNotEmpty) ...[
                          Text(
                            capitalize('$serviceTitle by Piece'),
                            style: const TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize14,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      if (laundryPerPiece != null)
                        ...laundryPerPiece.entries.map((entry) {
                          final category = entry.key;
                          final details = entry.value;

                          if (details is! Map ||
                              !details.containsKey('products')) {
                            return const SizedBox.shrink();
                          }

                          final products = details['products'] as List<dynamic>;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            padding: const EdgeInsets.all(0.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 0.0,
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, index) {
                              final product = products[index];
                              final productName = product['product_name'];
                              final quantity = product['quantity'];
                              final imageUrl = product['image_url'];

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    imageUrl,
                                    width: 64.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formatStringToMultiline(
                                            capitalize(category)),
                                        style: TextStyle(
                                          color: AppColors.hintBlack
                                              .withValues(alpha: 0.6),
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight:
                                              AppFonts.fontWeightSemiBold,
                                        ),
                                      ),
                                      Text(
                                        capitalize(formatStringToMultiline(
                                            productName)),
                                        style: const TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight:
                                              AppFonts.fontWeightSemiBold,
                                        ),
                                      ),
                                      Text(
                                        'x$quantity',
                                        style: const TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight: AppFonts.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      if (laundryByKG != null) const SizedBox(height: 0.0),
                      if (laundryByKG != null)
                        if (laundryByKG.isNotEmpty) ...[
                          Text(
                            capitalize('$serviceTitle by KG'),
                            style: const TextStyle(
                              color: AppColors.hintBlack,
                              fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                              fontSize: AppFonts.fontSize12,
                              fontWeight: AppFonts.fontWeightMedium,
                            ),
                          ),
                        ],
                      ...laundryByKG.entries.map((entry) {
                        final category = entry.key;
                        final details = entry.value;

                        if (category == 'photos' || details is! Map) {
                          return const SizedBox.shrink();
                        }

                        if (details.containsKey('products') &&
                            details['products'] is List) {
                          final products = details['products'] as List<dynamic>;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.0,
                              mainAxisSpacing: 0.0,
                              childAspectRatio: 1.6,
                            ),
                            itemBuilder: (context, productIndex) {
                              final product = products[productIndex];
                              final productName = product['id']['product_name'];
                              final quantity = product['quantity'];
                              final imageUrl = product['id']['image_url'];

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.network(
                                    imageUrl,
                                    width: 64.0,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formatStringToMultiline(
                                            capitalize(category)),
                                        style: TextStyle(
                                          color: AppColors.hintBlack
                                              .withValues(alpha: 0.6),
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize16,
                                          fontWeight:
                                              AppFonts.fontWeightSemiBold,
                                        ),
                                      ),
                                      Text(
                                        formatStringToMultiline(
                                            capitalize(productName)),
                                        style: const TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize14,
                                          fontWeight:
                                              AppFonts.fontWeightSemiBold,
                                        ),
                                      ),
                                      Text(
                                        'x$quantity',
                                        style: const TextStyle(
                                          color: AppColors.hintBlack,
                                          fontFamily: AppFonts
                                              .fontFamilyPlusJakartaSans,
                                          fontSize: AppFonts.fontSize12,
                                          fontWeight: AppFonts.fontWeightMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }).toList(),
                      const SizedBox(height: 0.0),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0),
            GestureDetector(
              onTap: downloadPdf,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/download_icon.svg'),
                  const SizedBox(width: 4.0),
                  const Text(
                    'Get Invoice',
                    style: TextStyle(
                      color: AppColors.darkerBlue,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            GestureDetector(
              onTap: () {
                showBottomSheet(widget.orderStatuses);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/bin.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.lightRed,
                      BlendMode.srcIn,
                    ),
                    height: 12.0,
                  ),
                  const SizedBox(width: 2.0),
                  const Text(
                    'Cancel Order',
                    style: TextStyle(
                      color: AppColors.lightRed,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<pw.Document> generatePdf() async {
    final pdf = pw.Document();

    // Convert SVG logo to PNG
    final logoPngBytes = await rootBundle
        .load('assets/images/rinze_logo.png')
        .then((data) => data.buffer.asUint8List());
    final logoImage = pw.MemoryImage(logoPngBytes);

    // Preload images
    final List<Map<String, dynamic>> preloadedImages = [];
    for (var service in widget.ordersList) {
      final laundryPerPiece =
          service['order']['laundryByPiece']?['products'] ?? {};
      final laundryByKG = service['order']['laundryByKG'] ?? {};

      for (var entry in laundryPerPiece.entries) {
        final products = entry.value['products'] as List<dynamic>;
        for (var product in products) {
          final imageUrl = product['image_url'];
          final imageBytes = await networkImageToByte(imageUrl);
          preloadedImages.add({
            'product_name': product['product_name'],
            'quantity': product['quantity'],
            'image': pw.MemoryImage(imageBytes),
          });
        }
      }

      for (var entry in laundryByKG.entries) {
        if (entry.key == 'photos' || entry.value is! Map) continue;
        final products = entry.value['products'] as List<dynamic>;
        for (var product in products) {
          final imageUrl = product['id']['image_url'];
          final imageBytes = await networkImageToByte(imageUrl);
          preloadedImages.add({
            'product_name': product['id']['product_name'],
            'quantity': product['quantity'],
            'image': pw.MemoryImage(imageBytes),
          });
        }
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Company Logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Invoice',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Image(logoImage,
                        width: 100, height: 100), // Company Logo
                  ],
                ),

                // Order Details
                pw.SizedBox(height: 16),
                pw.Text('Order Number: ${widget.orderNumber}'),
                pw.Text(
                    'Payment Status: ${capitalize(splitString(widget.paymentStatus))}'),
                pw.SizedBox(height: 16),
                pw.Text('Pickup Details:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: $pickupDate'),
                pw.Text('Time: $pickupTime'),
                pw.Text('Type: $pickupType'),
                pw.Text('Agent Name: $pickupAgentName'),
                pw.Text('Agent Mobile: $pickupAgentMobileNumber'),
                pw.SizedBox(height: 16),
                pw.Text('Delivery Details:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Date: $deliveryDate'),
                pw.Text('Time: $deliveryTime'),
                pw.Text('Type: $deliveryType'),
                pw.Text('Agent Name: $deliveryAgentName'),
                pw.Text('Agent Mobile: $deliveryAgentMobileNumber'),
                pw.SizedBox(height: 16),
                pw.Text('Address:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(formattedAddress),
                pw.SizedBox(height: 16),
                pw.Text('Order Details:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: preloadedImages.map((product) {
                    return pw.Container(
                      width: 150,
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 64,
                            height: 64,
                            child: pw.Image(product['image']),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(capitalize(product['product_name'])),
                              pw.Text('x${product['quantity']}'),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  Future<Uint8List> networkImageToByte(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> downloadPdf() async {
    // Generate PDF
    final pdf = await generatePdf();
    final bytes = await pdf.save();

    // Get the app's documents directory (better for iOS)
    final tempDir = await getApplicationDocumentsDirectory();
    final tempFile = File('${tempDir.path}/invoice.pdf');

    // Save the PDF to the documents directory
    await tempFile.writeAsBytes(bytes);

    // Check if the file exists
    if (await tempFile.exists()) {
      print('PDF file exists at: ${tempFile.path}');
    } else {
      print('PDF file does not exist at: ${tempFile.path}');
      return;
    }

    // Share the PDF file
    try {
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Get Invoice',
        subject: 'Invoice from Rinze',
      );
      print('PDF shared successfully');
    } catch (e) {
      print('Failed to share PDF: $e');
    }
  }

  void showBottomSheet(List<dynamic> orderStatuses) {
    String cancellationText = '';

    if (orderStatuses.isEmpty) {
      print('No status data available');
      return;
    }

    orderStatuses.sort((a, b) {
      return DateTime.parse(a['updatedAt'])
          .compareTo(DateTime.parse(b['updatedAt']));
    });

    final latestStatus = orderStatuses.last['status'];
    print('Latest Status: $latestStatus');

    if (latestStatus == 'confirmed' || latestStatus == 'readyForPickup') {
      cancellationText = 'No cancellation fees will be applied.';
    } else if (latestStatus == 'orderPickedUp' ||
        latestStatus == 'reachedCollectionCentre') {
      cancellationText = '20% cancellation fees will be applied to your order.';
    } else if ([
      'inWashing',
      'inIroning',
      'readyForDelivery',
      'outForDelivery',
      'delivered'
    ].contains(latestStatus)) {
      cancellationText = 'Cancellation not possible.';
    } else {
      print('Unknown status.');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppColors.baseWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            spacing: 12.0,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'This is an irreversible action. \nAre you sure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightRed,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize22,
                  fontWeight: AppFonts.fontWeightSemiBold,
                ),
              ),
              Text(
                cancellationText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.black,
                  fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                  fontSize: AppFonts.fontSize14,
                  fontWeight: AppFonts.fontWeightBlack,
                ),
              ),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 2.0,
                    children: [
                      Text(
                        'Reason for order cancellation',
                        style: TextStyle(
                          color: AppColors.hintBlack,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          color: AppColors.lightRed,
                          fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                          fontSize: AppFonts.fontSize14,
                          fontWeight: AppFonts.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  TextSelectionTheme(
                    data: TextSelectionThemeData(
                      selectionColor: Colors.blue,
                      selectionHandleColor:
                          AppColors.hintBlack.withValues(alpha: 0.6),
                    ),
                    child: TextField(
                      controller: _cancelOrderTextController,
                      cursorColor: AppColors.hintBlack.withValues(alpha: 0.6),
                      cursorRadius: const Radius.circular(10.0),
                      decoration: InputDecoration(
                        errorText: cancelReasonError,
                        fillColor: AppColors.lightWhite,
                        filled: true,
                        contentPadding: const EdgeInsets.all(12.0),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: AppColors.black.withValues(alpha: 0.06),
                            width: 1.0,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateFields,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightRed,
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Confirm Cancellation',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.fontFamilyPlusJakartaSans,
                      fontSize: AppFonts.fontSize16,
                      fontWeight: AppFonts.fontWeightSemiBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void validateFields() {
    setState(() {
      cancelReasonError = _cancelOrderTextController.text.isEmpty
          ? 'Please enter a cancellation reason!'
          : null;
    });

    if (cancelReasonError == null) {
      cancelOrder();
    }
  }

  void cancelOrder() async {
    final String cancelUrl =
        '${dotenv.env['API_URL']}/orders/${widget.orderId}/cancel';
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? storedToken = await secureStorage.read(key: 'Rin8k1H2mZ');
    final requestBody = {
      'note': _cancelOrderTextController.text,
    };

    try {
      final response = await http.delete(
        Uri.parse(cancelUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $storedToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Order canceled successfully: ${response.body}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeBottomNavigation(
              selectedIndex: 0,
            ),
          ),
        );
      } else {
        print('Failed to cancel order. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error canceling order: $error');
    }
  }
}
