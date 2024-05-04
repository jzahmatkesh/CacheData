extension MapExtension on Map<String, dynamic>{
  Map<String, dynamic> toLower(){
    return Map.fromEntries(entries.map((entry){
      return MapEntry(entry.key.toLowerCase(), entry.value);
    }));
  }
}