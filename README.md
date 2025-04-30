# Cashier

## Intuitive Cashier Helper

Cashier is a simple, robust Flutter app designed for fast and accurate GST-compliant billing. It helps small businesses and shops manage products, generate invoices, and maintain billing history with ease.

---

## Features

- **Product Management:**  
  Add, edit, and view products with price and GST rate (5%, 12%, 18%, 28%).

- **Billing Screen:**  
  - Search and add products to the bill.
  - Adjust quantities and see GST (CGST/SGST) breakdown per item.
  - Auto-calculated totals and GST.
  - Generate and save invoices instantly.

- **Invoice History:**  
  - View and search past invoices.
  - Tap any invoice for a detailed breakdown.
  - Export invoices as PDF for sharing or printing.

- **Data Persistence:**  
  All products and invoices are stored locally for offline access.

- **Fast & Intuitive:**  
  Clean UI, minimal steps, and responsive performance.

---

## Getting Started

1. **Install dependencies:**  
   ```
   flutter pub get
   ```

2. **Run the app:**  
   ```
   flutter run
   ```

---

## Tech Stack

- Flutter (Dart)
- Provider (state management)
- sqflite (local database)
- pdf, share_plus (PDF export & sharing)

---

## License

MIT
