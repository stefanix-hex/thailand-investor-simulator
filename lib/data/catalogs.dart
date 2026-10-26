import '../models/enums.dart';
import '../models/market.dart';

class EventBlueprint {
  const EventBlueprint({
    required this.id,
    required this.title,
    required this.body,
    required this.tone,
    required this.duration,
    this.location,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String body;
  final EventTone tone;
  final int duration;
  final Location? location;
  final List<String> tags;
}

class Catalogs {
  static const condos = [
    'Sukhumvit Loft 32',
    'Sathorn River Residence',
    'Asoke Sky Garden',
    'Ari Courtyard',
    'Silom Heritage Tower',
    'Thonglor House',
  ];

  static const villas = [
    'Cherngtalay Pavilion',
    'Kamala Ridge Villa',
    'Bang Tao Palm Court',
    'Surin Hill House',
    'Nai Harn Horizon',
  ];

  static const apartments = [
    'Jomtien Breeze',
    'Wongamat Studio Court',
    'Central Pattaya Walk',
    'Naklua Harbor Flats',
  ];

  static const commercials = [
    'Ratchada Retail Pod',
    'Phuket Town Shophouse Row',
    'Pattaya Second Road Plaza',
    'Chiang Mai Nimman Corner',
  ];

  static const hotels = [
    'Riverside 48 Hotel',
    'Kata Tide Inn',
    'Pattaya Palm Suites',
    'Old City Lantern Hotel',
  ];

  static const resorts = [
    'Andaman Canopy Resort',
    'Samui Coral Sands',
    'Khao Lak Quiet Bay',
    'Phang Nga Cliff Spa',
  ];

  static const mixed = [
    'Lat Phrao Mixed Block',
    'Chalong Harbor Mix',
    'East Pattaya Live-Work',
  ];

  static const restaurants = [
    'Isaan Grill Ari',
    'Boat Noodle Yaowarat',
    'Seafood Walk Jomtien',
    'Garden Khao Soi',
  ];

  static const wellness = [
    'Silom Breath Studio',
    'Rawai Salt House',
    'Nimman Recovery Lab',
  ];

  static const tourism = [
    'Gulf Day Tours Co.',
    'Old Capital Walking Co.',
    'Island Transfer Desk',
  ];

  static const boats = [
    'Andaman Longtail Fleet',
    'Samui Catamaran Share',
    'Pattaya Speedboat Desk',
  ];

  static const partners = [
    'Khun Anong Property',
    'Siam Coast Partners',
    'Lanna Capital JV',
    'Gulf Hospitality Ltd',
    'Chao Phraya Holdings',
  ];

  static const events = <EventBlueprint>[
    EventBlueprint(
      id: 'tourism_growth',
      title: 'Tourism rebound',
      body:
          'Arrivals rise across beach and city markets. Hospitality occupancy and tourism businesses benefit for several quarters.',
      tone: EventTone.positive,
      duration: 4,
      tags: ['tourism_up'],
    ),
    EventBlueprint(
      id: 'new_airport',
      title: 'Airport expansion',
      body:
          'A capacity upgrade at a regional airport improves access. Property values in the affected market grind higher.',
      tone: EventTone.positive,
      duration: 8,
      location: Location.phuket,
      tags: ['infra', 'phuket_up'],
    ),
    EventBlueprint(
      id: 'infra',
      title: 'Infrastructure investment',
      body:
          'Rail and road works lift Bangkok commercial and mixed-use demand, with construction costs also ticking up.',
      tone: EventTone.positive,
      duration: 6,
      location: Location.bangkok,
      tags: ['bangkok_up', 'build_cost_up'],
    ),
    EventBlueprint(
      id: 'tax_incentive',
      title: 'Tax incentive window',
      body:
          'A temporary incentive improves after-tax yields on qualifying property companies and SPVs.',
      tone: EventTone.positive,
      duration: 4,
      tags: ['tax_cut'],
    ),
    EventBlueprint(
      id: 'stable',
      title: 'Stable market',
      body: 'No shock this quarter. Pricing, rates, and tourism drift with the cycle.',
      tone: EventTone.neutral,
      duration: 1,
      tags: ['stable'],
    ),
    EventBlueprint(
      id: 'fx_stable',
      title: 'Currency stabilization',
      body: 'EUR/THB volatility cools. Thai asset values in euro terms are less noisy.',
      tone: EventTone.neutral,
      duration: 3,
      tags: ['fx_calm'],
    ),
    EventBlueprint(
      id: 'seasonal',
      title: 'Seasonal variation',
      body:
          'High season or monsoon weighting shifts occupancy. Beach markets move more than Bangkok condos.',
      tone: EventTone.neutral,
      duration: 1,
      tags: ['seasonal'],
    ),
    EventBlueprint(
      id: 'flood',
      title: 'Flooding',
      body:
          'Seasonal flooding damages access and insurance terms. Occupancy and values dip in the affected city.',
      tone: EventTone.negative,
      duration: 3,
      location: Location.bangkok,
      tags: ['flood'],
    ),
    EventBlueprint(
      id: 'recession',
      title: 'Economic recession',
      body:
          'Credit tightens, tourism slows, and asset values reprice. Banks become more conservative on LTV and DSCR.',
      tone: EventTone.negative,
      duration: 6,
      tags: ['recession'],
    ),
    EventBlueprint(
      id: 'foreign_rules',
      title: 'Foreign ownership review',
      body:
          'Regulators tighten scrutiny of condo quotas and nominee structures. Legal costs rise; some deals stall.',
      tone: EventTone.negative,
      duration: 5,
      tags: ['regulation'],
    ),
    EventBlueprint(
      id: 'rate_hike',
      title: 'Interest rate increase',
      body:
          'Policy rates move up. Mortgage pricing follows and leveraged cash flow compresses.',
      tone: EventTone.negative,
      duration: 4,
      tags: ['rates_up'],
    ),
    EventBlueprint(
      id: 'tourism_down',
      title: 'Tourism decline',
      body:
          'Arrivals disappoint. Hotels, resorts, boats, and restaurants feel it first; condos lag.',
      tone: EventTone.negative,
      duration: 4,
      tags: ['tourism_down'],
    ),
    EventBlueprint(
      id: 'construction_shock',
      title: 'Construction cost spike',
      body: 'Steel, labor, and import costs jump. Developments overrun and delays become likely.',
      tone: EventTone.negative,
      duration: 4,
      tags: ['build_cost_up'],
    ),
    EventBlueprint(
      id: 'pattaya_boom',
      title: 'Eastern seaboard demand',
      body: 'Pattaya apartments and commercial stock tighten as domestic demand improves.',
      tone: EventTone.positive,
      duration: 5,
      location: Location.pattaya,
      tags: ['pattaya_up'],
    ),
  ];

  static MarketEvent instantiate(EventBlueprint b, String suffix) {
    return MarketEvent(
      id: '${b.id}_$suffix',
      title: b.title,
      body: b.body,
      tone: b.tone,
      quartersRemaining: b.duration,
      location: b.location,
      tags: b.tags,
    );
  }
}
