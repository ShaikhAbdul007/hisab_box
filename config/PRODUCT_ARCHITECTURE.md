# HisabBox — Product Architecture & Vision
> Created: May 2026  
> Status: Planning Phase  
> Author: HisabBox Team

---

## 1. Product Vision

HisabBox ek **multi-shop-type business management app** hai jo har tarah ke business ke liye kaam kare — inventory, billing, reports, aur shop-specific features sab ek jagah.

**Core Principle:** Ek app download karo, apna shop type select karo — poora experience automatically us shop ke hisaab se configure ho jaaye.

---

## 2. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        HISABBOX ECOSYSTEM                       │
│                                                                 │
│  ┌──────────────────────────┐   ┌──────────────────────────┐   │
│  │     HisabBox (App 1)     │   │  HisabBox Connect (App 2) │   │
│  │                          │   │                           │   │
│  │  • Doctor / Vet          │   │  • Patient                │   │
│  │  • Pet Shop Owner        │   │  • Pet Owner              │   │
│  │  • Clothing Shop         │   │  • Appointment booking    │   │
│  │  • Spare Parts Shop      │   │  • Medical history view   │   │
│  │  • Hardware Shop         │   │  • Prescription view      │   │
│  │  • Garage Shop           │   │                           │   │
│  │  • Mobile Shop           │   │  (Lightweight — 5 screens)│   │
│  └────────────┬─────────────┘   └─────────────┬─────────────┘  │
│               │                               │                 │
│               └───────────────┬───────────────┘                 │
│                               │                                 │
│              ┌────────────────▼────────────────┐                │
│              │        hisabbox_core             │                │
│              │      (Shared Flutter Package)    │                │
│              │                                  │                │
│              │  • Models (ProductModel, etc.)   │                │
│              │  • API calls (REST)              │                │
│              │  • Supabase client               │                │
│              │  • Common widgets                │                │
│              │  • ShopConfig system             │                │
│              └────────────────┬────────────────┘                │
│                               │                                 │
│              ┌────────────────▼────────────────┐                │
│              │         Shared Backend           │                │
│              │                                  │                │
│              │  • Supabase (PostgreSQL)         │                │
│              │  • REST API                      │                │
│              │  • Realtime sync                 │                │
│              │  • Firebase (notifications)      │                │
│              └──────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Monorepo Structure (Flutter)

```
hisabbox/                          ← Single Git repository
│
├── packages/
│   └── hisabbox_core/             ← Shared package (dono apps use karein)
│       ├── lib/
│       │   ├── models/            ← UserModel, ProductModel, AppointmentModel
│       │   ├── api/               ← All REST API calls
│       │   ├── supabase/          ← Supabase client + realtime
│       │   ├── shop_config/       ← ShopType enum + ShopConfig map
│       │   └── common_widgets/    ← Shared UI components
│       └── pubspec.yaml
│
├── apps/
│   ├── hisabbox/                  ← App 1: Doctor/Owner (existing app)
│   │   ├── lib/
│   │   │   ├── module/            ← All 33 existing modules
│   │   │   └── main.dart
│   │   └── pubspec.yaml           ← depends on hisabbox_core
│   │
│   └── hisabbox_connect/          ← App 2: Patient/Pet Owner (new)
│       ├── lib/
│       │   ├── screens/
│       │   │   ├── login/
│       │   │   ├── appointments/
│       │   │   ├── history/
│       │   │   ├── prescriptions/
│       │   │   └── profile/
│       │   └── main.dart
│       └── pubspec.yaml           ← depends on hisabbox_core
│
└── README.md
```

---

## 4. Shop Types — Features Matrix

```
                    │ Pet  │Cloth │Doctor│Spare │Garage│Mobile│
────────────────────┼──────┼──────┼──────┼──────┼──────┼──────┤
Inventory           │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │
Billing / POS       │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │
Barcode Scan        │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │
Reports             │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │
Customer Mgmt       │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │  ✅  │
Loose Stock         │  ✅  │  ❌  │  ❌  │  ❌  │  ❌  │  ❌  │
GR Stock            │  ❌  │  ✅  │  ❌  │  ❌  │  ❌  │  ❌  │
Expiry Tracking     │  ✅  │  ❌  │  ✅  │  ❌  │  ❌  │  ❌  │
Appointments        │  ❌  │  ❌  │  ✅  │  ❌  │  ✅  │  ❌  │
Patient History     │  ❌  │  ❌  │  ✅  │  ❌  │  ❌  │  ❌  │
Referral Calc       │  ❌  │  ❌  │  ✅  │  ❌  │  ❌  │  ❌  │
Medicine Tracking   │  ❌  │  ❌  │  ✅  │  ❌  │  ❌  │  ❌  │
Service Jobs        │  ❌  │  ❌  │  ❌  │  ❌  │  ✅  │  ❌  │
IMEI Tracking       │  ❌  │  ❌  │  ❌  │  ❌  │  ❌  │  ✅  │
```

---

## 5. Shop Type — Product Fields

Har shop type ke liye product form mein alag fields honge. Ye `ShopConfig` se dynamically render honge.

```
Pet Shop
  └── product name, animal category, weight, flavour,
      selling price, purchase price, stock, expiry date

Clothing Shop
  └── product name, size category, color, brand,
      selling price, purchase price, stock

Doctor / Vet Clinic
  └── medicine name, category, dosage, medicine type,
      selling price, purchase price, stock, expiry date

Spare Parts Shop
  └── part name, vehicle type, part number, brand,
      vehicle model, selling price, purchase price, stock

Garage Shop
  └── part/service name, service type, vehicle no,
      service hours, selling price, stock

Mobile Shop
  └── product name, brand, model, IMEI, RAM,
      storage, color, selling price, purchase price, stock
```

---

## 6. Config-Driven Architecture (ShopConfig System)

```
┌─────────────────────────────────────────────────────┐
│                  ShopConfig System                  │
│                                                     │
│  ShopType (enum)                                    │
│  ├── petShop                                        │
│  ├── clothingShop                                   │
│  ├── doctorClinic          ← new                    │
│  ├── sparePartsShop        ← new                    │
│  ├── garageShop            ← new                    │
│  └── mobileShop            ← new                    │
│                                                     │
│  ShopConfig (model)                                 │
│  ├── supportsLooseStock: bool                       │
│  ├── supportsGRStock: bool                          │
│  ├── supportsExpiry: bool                           │
│  ├── supportsAppointments: bool    ← new            │
│  ├── supportsPatientHistory: bool  ← new            │
│  ├── supportsReferral: bool        ← new            │
│  ├── categoryLabel: String                          │
│  ├── productFields: List<ProductFieldConfig>  ← new │
│  ├── reportColumns: List<String>              ← new │
│  └── invoiceSubtitleBuilder: Function         ← new │
│                                                     │
│  ProductFieldConfig (new model)                     │
│  ├── fieldKey: String      ("weight", "imei")       │
│  ├── label: String         ("Weight", "IMEI")       │
│  ├── isRequired: bool                               │
│  ├── inputType: enum       (text/number/dropdown)   │
│  └── dropdownSource: String? ("animalCategory")     │
│                                                     │
│  shopConfigs Map<ShopType, ShopConfig>              │
│  └── Single source of truth — ek jagah sab define  │
└─────────────────────────────────────────────────────┘
```

**Naya shop type add karna = sirf `shopConfigs` map mein ek entry add karo. Koi aur file touch nahi karni.**

---

## 7. Doctor Clinic — Dual Role Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Doctor Clinic Flow                       │
│                                                             │
│  DOCTOR (HisabBox App)          PATIENT (Connect App)       │
│  ┌─────────────────────┐        ┌─────────────────────┐    │
│  │ • Inventory          │        │ • Book Appointment   │    │
│  │   (medicines)        │        │ • View My History    │    │
│  │ • Billing            │        │ • View Prescription  │    │
│  │ • Appointments list  │◄──────►│ • Profile            │    │
│  │ • Patient history    │        └─────────────────────┘    │
│  │ • Referral calc      │                                    │
│  │ • Reports            │        Shared Backend             │
│  └─────────────────────┘        (same Supabase DB)          │
└─────────────────────────────────────────────────────────────┘

Appointment Flow:
Patient books → Doctor gets notification → Doctor confirms →
Patient gets confirmation → Visit happens → Doctor adds notes/prescription →
Patient can view in Connect app
```

---

## 8. HisabBox Connect (Patient App) — Screens

```
HisabBox Connect
├── 1. Login / OTP          ← same auth system as HisabBox
├── 2. Home                 ← upcoming appointments
├── 3. Book Appointment     ← select doctor, date, time slot
├── 4. My Appointments      ← past + upcoming
├── 5. Medical History      ← visit notes, prescriptions
└── 6. Profile              ← personal details
```

**Total: 6 screens. Estimated: 1-2 weeks development** (because models + API already in `hisabbox_core`)

---

## 9. Implementation Roadmap

```
Phase 1 — Foundation (Existing App Refactor)
  ├── ShopConfig extend karo (productFields, reportColumns, etc.)
  ├── ProductFieldConfig model banao
  ├── DynamicProductForm widget banao
  ├── product_view + product_detail_view switch hatao
  ├── Invoice + Reports dynamic karo
  └── Cache generalize karo
  Status: NEXT UP

Phase 2 — Simple New Shop Types
  ├── Spare Parts Shop config add karo
  ├── Mobile Shop config add karo
  └── Hardware Shop config add karo
  Status: After Phase 1

Phase 3 — Garage Shop
  ├── Service job management module
  ├── Vehicle tracking
  └── Service billing
  Status: After Phase 2

Phase 4 — Doctor / Vet Clinic (HisabBox)
  ├── Appointment module (doctor side)
  ├── Patient/Pet history module
  ├── Medicine tracking
  └── Referral calculation
  Status: After Phase 3

Phase 5 — HisabBox Connect (Patient App)
  ├── New Flutter app setup
  ├── hisabbox_core package extract
  ├── 6 screens implement
  └── Play Store publish
  Status: Parallel with Phase 4
```

---

## 10. Why 2 Apps, 1 Backend

| Factor | 1 App (Role-based) | 2 Apps (Recommended) |
|---|---|---|
| Development speed | Slow — role checks everywhere | Fast — focused scope per app |
| UX quality | Compromised for both users | Clean for each user type |
| App size | Heavy for patient | Lightweight patient app |
| Maintenance | One change can break both | Isolated, independent |
| Play Store | One listing | Two products, two growth paths |
| Industry standard | No | Yes (Practo, Zoho, Clinikk) |
| Scalability | Limited | High |

**Verdict: 2 Apps, 1 Backend, 1 Shared Flutter Package**

---

## 11. Technology Stack

```
Frontend
├── Flutter (existing)
├── GetX — state management (existing)
├── hisabbox_core — shared package (new)
└── flutter_screenutil, get_storage, hive (existing)

Backend
├── Supabase (PostgreSQL + Realtime) — existing
├── REST API (hisab-box.softwaresnip.com) — existing
└── Firebase (push notifications) — existing

New Backend Requirements (Phase 4)
├── appointments table (Supabase)
├── patient_history table (Supabase)
├── prescriptions table (Supabase)
└── referral_records table (Supabase)
```

---

## 12. Key Decisions Log

| Decision | Reason |
|---|---|
| 2 apps instead of 1 | Patient UX fundamentally different from doctor/owner UX |
| Monorepo | Shared code easy to maintain, one source of truth |
| Config-driven shop types | Adding new shop type = 1 config entry, no new files |
| Supabase as primary DB | Already integrated, realtime support, RLS for data security |
| Phase-wise delivery | Existing app must not break while new features are added |

---

> **Last Updated:** May 2026  
> **Next Action:** Phase 1 — Existing app config-driven refactor spec banana
