#!/usr/bin/env node
/**
 * FreshVeg — Firestore Data Seeder
 *
 * Seeds sample vegetable data so you can test the app immediately.
 *
 * Usage:
 *   1. Install: npm install firebase-admin
 *   2. Download your Firebase service-account key from:
 *      Firebase Console → Project Settings → Service Accounts → Generate new private key
 *   3. Run:
 *        SERVICE_ACCOUNT=./serviceAccount.json node scripts/seed_firestore.js
 *
 * WARNING: This overwrites existing vegetable data. Only run once on a fresh project.
 */

const admin = require('firebase-admin');
const path = require('path');

const serviceAccountPath = process.env.SERVICE_ACCOUNT || './serviceAccount.json';

admin.initializeApp({
  credential: admin.credential.cert(require(path.resolve(serviceAccountPath))),
});

const db = admin.firestore();

const vegetables = [
  { name: 'Tomato',       pricePerKg: 35,  availableQuantityKg: 20, unit: 'kg',     category: 'General',        isAvailable: true },
  { name: 'Spinach',      pricePerKg: 25,  availableQuantityKg: 10, unit: 'bunch',  category: 'Leafy Greens',   isAvailable: true },
  { name: 'Carrot',       pricePerKg: 40,  availableQuantityKg: 15, unit: 'kg',     category: 'Root Vegetables', isAvailable: true },
  { name: 'Onion',        pricePerKg: 30,  availableQuantityKg: 25, unit: 'kg',     category: 'Root Vegetables', isAvailable: true },
  { name: 'Potato',       pricePerKg: 20,  availableQuantityKg: 30, unit: 'kg',     category: 'Root Vegetables', isAvailable: true },
  { name: 'Capsicum',     pricePerKg: 60,  availableQuantityKg: 8,  unit: 'kg',     category: 'General',        isAvailable: true },
  { name: 'Brinjal',      pricePerKg: 30,  availableQuantityKg: 12, unit: 'kg',     category: 'General',        isAvailable: true },
  { name: 'Coriander',    pricePerKg: 15,  availableQuantityKg: 5,  unit: 'bunch',  category: 'Herbs & Spices', isAvailable: true },
  { name: 'Bitter Gourd', pricePerKg: 45,  availableQuantityKg: 7,  unit: 'kg',     category: 'Gourds & Melons', isAvailable: true },
  { name: 'Beans',        pricePerKg: 55,  availableQuantityKg: 6,  unit: 'kg',     category: 'Beans & Pods',   isAvailable: true },
  { name: 'Cabbage',      pricePerKg: 22,  availableQuantityKg: 18, unit: 'piece',  category: 'Leafy Greens',   isAvailable: true },
  { name: 'Cauliflower',  pricePerKg: 35,  availableQuantityKg: 14, unit: 'piece',  category: 'Leafy Greens',   isAvailable: true },
  { name: 'Cucumber',     pricePerKg: 25,  availableQuantityKg: 20, unit: 'kg',     category: 'Gourds & Melons', isAvailable: true },
  { name: 'Garlic',       pricePerKg: 120, availableQuantityKg: 3,  unit: 'kg',     category: 'Herbs & Spices', isAvailable: true },
  { name: 'Ginger',       pricePerKg: 100, availableQuantityKg: 4,  unit: 'kg',     category: 'Herbs & Spices', isAvailable: true },
  { name: 'Peas',         pricePerKg: 70,  availableQuantityKg: 5,  unit: 'kg',     category: 'Beans & Pods',   isAvailable: true },
  { name: 'Mushroom',     pricePerKg: 150, availableQuantityKg: 3,  unit: 'kg',     category: 'Exotic',         isAvailable: true },
  { name: 'Baby Corn',    pricePerKg: 90,  availableQuantityKg: 4,  unit: 'kg',     category: 'Exotic',         isAvailable: true },
];

async function seed() {
  console.log(`Seeding ${vegetables.length} vegetables...`);
  const batch = db.batch();
  const col = db.collection('vegetables');

  vegetables.forEach((veg) => {
    const ref = col.doc();
    batch.set(ref, {
      ...veg,
      imageUrl: null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`✅ Seeded ${vegetables.length} vegetables successfully!`);
  console.log('You can now launch the app and log in as a vendor to manage them.');
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Seed failed:', err);
  process.exit(1);
});
