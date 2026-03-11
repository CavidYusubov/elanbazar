import 'ad_create_city.dart';

class AdCreateMetaStore {
  final bool canPostAsStore;
  final int? id;
  final String? name;
  final String? status;

  const AdCreateMetaStore({
    required this.canPostAsStore,
    this.id,
    this.name,
    this.status,
  });

  factory AdCreateMetaStore.fromJson(Map<String, dynamic> json) {
    final store = json['store'];
    return AdCreateMetaStore(
      canPostAsStore: json['can_post_as_store'] == true,
      id: store == null ? null : (store['id'] as num).toInt(),
      name: store == null ? null : store['name']?.toString(),
      status: store == null ? null : store['status']?.toString(),
    );
  }
}

class AdCreateMetaContact {
  final String? name;
  final String? email;
  final String? phone;

  const AdCreateMetaContact({
    this.name,
    this.email,
    this.phone,
  });

  factory AdCreateMetaContact.fromJson(Map<String, dynamic> json) {
    return AdCreateMetaContact(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class AdCreateMeta {
  final AdCreateMetaContact contact;
  final AdCreateMetaStore store;
  final List<AdCreateCity> cities;
  final List<String> currencies;
  final List<String> conditions;
  final List<String> contactMethods;

  const AdCreateMeta({
    required this.contact,
    required this.store,
    required this.cities,
    required this.currencies,
    required this.conditions,
    required this.contactMethods,
  });

  factory AdCreateMeta.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map);

    return AdCreateMeta(
      contact: AdCreateMetaContact.fromJson(
        Map<String, dynamic>.from(data['contact'] as Map? ?? {}),
      ),
      store: AdCreateMetaStore.fromJson(
        Map<String, dynamic>.from(data['store'] as Map? ?? {}),
      ),
      cities: (data['cities'] as List? ?? [])
          .map((e) => AdCreateCity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      currencies: (data['currencies'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      conditions: (data['conditions'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      contactMethods: (data['contact_methods'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}