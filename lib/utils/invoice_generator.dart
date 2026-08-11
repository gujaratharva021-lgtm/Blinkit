// Generates a "Tax Invoice / Bill of Supply" PDF in the same layout style
// used by marketplace invoices (seller block, Bill To/Ship To, item table
// with HSN/GST columns, totals, footer notes, QR code).
//
// All seller/company details below are PLACEHOLDERS. Update them with your
// real registered business details before using this for actual orders.
import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/order_model.dart';
import 'download_notification_service.dart';

/// Edit these with GoFresh's real registered business details.
class InvoiceSellerConfig {
  static const String sellerName = 'GoFresh Sellers Private Limited';
  static const String sellerAddress =
      'Warehouse No 1, Logistics Park, Sector 20, Your City, State - 000000';
  static const String sellerGstin = '00AAAAA0000A1Z0'; // placeholder
  static const String sellerFssai = '00000000000000'; // placeholder

  static const String platformName = 'GOFRESH MARKETPLACE PRIVATE LIMITED';
  static const String platformAddress =
      'Head Office Address, City, State, India - 000000';
  static const String platformFssai = '00000000000000'; // placeholder
  static const String supportEmail = 'support@gofresh.app';
}

class InvoiceItem {
  final String name;
  final String hsn;
  final int qty;
  final double mrp;
  final double discountPercent;
  final double taxableAmount;
  final double cgstPercent;
  final double sgstPercent;
  final double cessPercent;

  InvoiceItem({
    required this.name,
    required this.qty,
    required this.mrp,
    this.hsn = '-',
    this.discountPercent = 0,
    required this.taxableAmount,
    this.cgstPercent = 0,
    this.sgstPercent = 0,
    this.cessPercent = 0,
  });

  double get cgstAmount => taxableAmount * cgstPercent / 100;
  double get sgstAmount => taxableAmount * sgstPercent / 100;
  double get cessAmount => taxableAmount * cessPercent / 100;
  double get totalAmount =>
      taxableAmount + cgstAmount + sgstAmount + cessAmount;
}

class InvoiceGenerator {
  /// Builds invoice line items from an [Order]. Since per-product HSN/GST
  /// data isn't tracked in the order model yet, this defaults HSN to '-'
  /// and GST to 0% (matching how most everyday grocery items are billed).
  /// Wire in real HSN/GST fields from the backend later if needed.
  static List<InvoiceItem> _itemsFromOrder(Order order) {
    return order.items.map((item) {
      final taxable = (item.price * item.quantity).toDouble();
      return InvoiceItem(
        name: item.name,
        qty: item.quantity,
        mrp: item.price.toDouble(),
        taxableAmount: taxable,
      );
    }).toList();
  }

  static Future<Uint8List> buildInvoicePdf({
    required Order order,
    required String customerName,
    String? placeOfSupply,
  }) async {
    final items = _itemsFromOrder(order);
    final doc = pw.Document();

    final itemTotal = items.fold<double>(0, (sum, i) => sum + i.taxableAmount);
    final cgstTotal = items.fold<double>(0, (sum, i) => sum + i.cgstAmount);
    final sgstTotal = items.fold<double>(0, (sum, i) => sum + i.sgstAmount);
    final cessTotal = items.fold<double>(0, (sum, i) => sum + i.cessAmount);
    final invoiceValue = itemTotal + cgstTotal + sgstTotal + cessTotal;

    final invoiceNo = 'INV${order.id.padLeft(6, '0')}${order.date.millisecondsSinceEpoch % 1000}';
    final dateStr = DateFormat('dd-MM-yyyy').format(order.date);
    final qrData =
        'Invoice:$invoiceNo|Order:${order.id}|Amount:${invoiceValue.toStringAsFixed(2)}|Date:$dateStr';

    pw.Widget cell(String text, {pw.Alignment align = pw.Alignment.centerLeft, bool bold = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(4),
        alignment: align,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 7,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          // Seller header + QR
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Seller Name: ${InvoiceSellerConfig.sellerName}',
                        style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 4),
                    pw.Text(InvoiceSellerConfig.sellerAddress, style: const pw.TextStyle(fontSize: 9)),
                    pw.SizedBox(height: 6),
                    pw.Text('GSTIN: ${InvoiceSellerConfig.sellerGstin}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('FSSAI: ${InvoiceSellerConfig.sellerFssai}',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: qrData,
                width: 70,
                height: 70,
              ),
            ],
          ),
          pw.SizedBox(height: 10),

          // Title bar
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(width: 1), bottom: pw.BorderSide(width: 1)),
            ),
            alignment: pw.Alignment.center,
            child: pw.Text('TAX INVOICE/BILL OF SUPPLY',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ),

          // Invoice meta
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice No.: $invoiceNo', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      pw.Text('Order No.: ${order.id}', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Place Of Supply : ${placeOfSupply ?? '-'}', style: const pw.TextStyle(fontSize: 9)),
                      pw.SizedBox(height: 2),
                      pw.Text('Date : $dateStr', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bill To / Ship To
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 1)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(customerName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text(order.address, style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Ship To', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(order.address, style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),

          // Items table
          pw.Table(
            border: pw.TableBorder.all(width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.5),
              1: pw.FlexColumnWidth(2.2),
              2: pw.FlexColumnWidth(1.1),
              3: pw.FlexColumnWidth(0.9),
              4: pw.FlexColumnWidth(0.5),
              5: pw.FlexColumnWidth(1.1),
              6: pw.FlexColumnWidth(0.8),
              7: pw.FlexColumnWidth(1.2),
              8: pw.FlexColumnWidth(0.8),
              9: pw.FlexColumnWidth(0.8),
              10: pw.FlexColumnWidth(0.9),
              11: pw.FlexColumnWidth(0.9),
              12: pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFEFEF)),
                children: [
                  cell('SR\nNo', bold: true, align: pw.Alignment.center),
                  cell('Item &\nDescription', bold: true),
                  cell('Unit\nMRP/RSP', bold: true, align: pw.Alignment.center),
                  cell('HSN', bold: true, align: pw.Alignment.center),
                  cell('Qty', bold: true, align: pw.Alignment.center),
                  cell('Product\nRate', bold: true, align: pw.Alignment.center),
                  cell('Disc.', bold: true, align: pw.Alignment.center),
                  cell('Taxable\nAmt.', bold: true, align: pw.Alignment.center),
                  cell('CGST', bold: true, align: pw.Alignment.center),
                  cell('S/UT\nGST', bold: true, align: pw.Alignment.center),
                  cell('CGST\nAmt.', bold: true, align: pw.Alignment.center),
                  cell('S/UT GST\nAmt.', bold: true, align: pw.Alignment.center),
                  cell('Total\nAmt.', bold: true, align: pw.Alignment.center),
                ],
              ),
              for (var i = 0; i < items.length; i++)
                pw.TableRow(
                  children: [
                    cell('${i + 1}', align: pw.Alignment.center),
                    cell(items[i].name),
                    cell(items[i].mrp.toStringAsFixed(2), align: pw.Alignment.center),
                    cell(items[i].hsn, align: pw.Alignment.center),
                    cell('${items[i].qty}', align: pw.Alignment.center),
                    cell(items[i].mrp.toStringAsFixed(2), align: pw.Alignment.center),
                    cell('${items[i].discountPercent.toStringAsFixed(2)}%', align: pw.Alignment.center),
                    cell(items[i].taxableAmount.toStringAsFixed(2), align: pw.Alignment.center),
                    cell('${items[i].cgstPercent.toStringAsFixed(2)}%', align: pw.Alignment.center),
                    cell('${items[i].sgstPercent.toStringAsFixed(2)}%', align: pw.Alignment.center),
                    cell(items[i].cgstAmount.toStringAsFixed(2), align: pw.Alignment.center),
                    cell(items[i].sgstAmount.toStringAsFixed(2), align: pw.Alignment.center),
                    cell(items[i].totalAmount.toStringAsFixed(2), align: pw.Alignment.center),
                  ],
                ),
              pw.TableRow(
                children: [
                  cell(''),
                  cell(''),
                  cell(''),
                  cell(''),
                  cell(''),
                  cell(''),
                  cell(''),
                  cell(itemTotal.toStringAsFixed(2), bold: true, align: pw.Alignment.center),
                  cell(''),
                  cell(''),
                  cell(cgstTotal.toStringAsFixed(2), bold: true, align: pw.Alignment.center),
                  cell(sgstTotal.toStringAsFixed(2), bold: true, align: pw.Alignment.center),
                  cell(invoiceValue.toStringAsFixed(2), bold: true, align: pw.Alignment.center),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 10),

          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Item Total', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(itemTotal.toStringAsFixed(2), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Divider(height: 12, thickness: 0.6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Invoice Value', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(invoiceValue.toStringAsFixed(2), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Text('Whether GST is payable on reverse-charge - No.', style: const pw.TextStyle(fontSize: 8)),
          pw.Text('For IMEI / Serial number information, please refer to packaging / warranty slip.',
              style: const pw.TextStyle(fontSize: 8)),

          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Order Delivered From -', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text(InvoiceSellerConfig.sellerName, style: const pw.TextStyle(fontSize: 8)),
                    pw.SizedBox(height: 4),
                    pw.Text(InvoiceSellerConfig.sellerAddress, style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('FSSAI: ${InvoiceSellerConfig.sellerFssai}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('E-commerce Platform (FBO) Information -',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text(InvoiceSellerConfig.platformName, style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(InvoiceSellerConfig.platformAddress, style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('FSSAI Lic. No: ${InvoiceSellerConfig.platformFssai}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('Email: ${InvoiceSellerConfig.supportEmail}', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// Generates the invoice PDF and actually saves it to the phone's public
  /// Downloads folder (Android), showing a "Download complete" notification
  /// that opens the file on tap — instead of only opening a share sheet.
  ///
  /// On platforms without a public Downloads folder (iOS/desktop), it falls
  /// back to the share/print sheet so the user can save it wherever they like.
  ///
  /// Returns the saved file's path (or a content URI / filename fallback).
  static Future<String> downloadInvoice({
    required Order order,
    required String customerName,
    String? placeOfSupply,
  }) async {
    final bytes = await buildInvoicePdf(
      order: order,
      customerName: customerName,
      placeOfSupply: placeOfSupply,
    );
    final fileName = 'GoFresh_Invoice_${order.id}.pdf';

    if (Platform.isAndroid) {
      // media_store_plus needs the file to exist somewhere first (e.g. app's
      // temp folder); it then copies it into the public Downloads folder via
      // MediaStore and deletes nothing on our side — we clean up ourselves.
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes, flush: true);

      final mediaStore = MediaStore();
      SaveInfo? saveInfo;
      try {
        saveInfo = await mediaStore.saveFile(
          tempFilePath: tempFile.path,
          dirType: DirType.download,
          dirName: DirName.download,
        );
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }

      if (saveInfo == null) {
        throw Exception('Could not save invoice to Downloads');
      }

      // Try to resolve a real filesystem path so tapping the notification
      // can open the file directly with open_filex.
      final filePath = await mediaStore.getFilePathFromUri(
        uriString: saveInfo.uri.toString(),
      );
      final openablePath = filePath ?? saveInfo.uri.toString();

      await DownloadNotificationService.showDownloadComplete(
        fileName: saveInfo.name,
        filePath: openablePath,
      );

      return openablePath;
    } else {
      await Printing.sharePdf(bytes: bytes, filename: fileName);
      return fileName;
    }
  }
}
