enum Location {
  bangkok,
  phuket,
  pattaya,
  chiangMai,
  samui,
  nationwide,
}

enum AssetClass { realEstate, business, financial }

enum PropertyKind {
  bangkokCondo,
  phuketVilla,
  pattayaApartment,
  commercial,
  hotel,
  resort,
  mixedUse,
}

enum BusinessKind { restaurant, wellness, tourismCompany, boatRental }

enum SecurityKind { bond, reit, dividendStock }

enum OwnershipStructure { condoFreehold, leasehold, jointVenture, spv }

enum RiskLevel { low, medium, high }

enum EventTone { positive, neutral, negative }

enum LoanKind { mortgage, bankLoan, investorCapital }

enum GamePhase { title, playing, ended }

extension LocationLabel on Location {
  String get label => switch (this) {
        Location.bangkok => 'Bangkok',
        Location.phuket => 'Phuket',
        Location.pattaya => 'Pattaya',
        Location.chiangMai => 'Chiang Mai',
        Location.samui => 'Koh Samui',
        Location.nationwide => 'Thailand',
      };
}

extension RiskLabel on RiskLevel {
  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.medium => 'Medium Risk',
        RiskLevel.high => 'High Risk',
      };
}

extension OwnershipLabel on OwnershipStructure {
  String get label => switch (this) {
        OwnershipStructure.condoFreehold => 'Condominium Freehold',
        OwnershipStructure.leasehold => 'Leasehold (30 years)',
        OwnershipStructure.jointVenture => 'Joint Venture',
        OwnershipStructure.spv => 'SPV Company',
      };

  String get summary => switch (this) {
        OwnershipStructure.condoFreehold =>
          'Foreign freehold within the legal condo quota.',
        OwnershipStructure.leasehold =>
          '30-year lease. Capital value decays and renewal is not guaranteed.',
        OwnershipStructure.jointVenture =>
          'Shared economic and voting rights. Partner conflict risk.',
        OwnershipStructure.spv =>
          'Company-owned structure with financing advantages and compliance cost.',
      };
}
