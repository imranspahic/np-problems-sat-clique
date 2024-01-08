import 'dart:io';

class KlikaINDSETGraf<T> {
  Map<String, int> cvorovi = {};
  List<List<bool>> graf = [];

  /// Pomoćna metoda koja obavlja unos čvorova u mapu [cvorovi].
  void _UNOS_CVOROVA() {
    print("Unesite čvorove grafa (u jednoj liniji sa zarezom kao razmak): ");
    while (true) {
      try {
        String? input = stdin.readLineSync();
        if (input == null || input.isEmpty || input == "\n") {
          break;
        }
        List<String> c = input.split(",");
        for (int i = 0; i < c.length; i++) {
          if (cvorovi.containsKey(c[i].trim())) {
            continue;
          }
          cvorovi[c[i].trim()] = i;
        }
        break;
      } on Exception catch (e) {
        print('Error: $e ❌');
      }
    }
    print("Čvorovi = $cvorovi");
    _kreirajGraf();
  }

  /// Metoda koja dodaje postavlja čvorove grafa na proslijeđeni parametar [cvorovi].
  /// Nakon postavljanja čvorova kreira graf sa [_kreirajGraf].
  void dodajCvorove(Map<String, int> cvorovi) {
    this.cvorovi = cvorovi;
    _kreirajGraf();
  }

  /// Pomoćna metoda koja obavlja unos grana u graf ažuriranjem matrice susjedstva [graf].
  void _UNOS_GRANA() {
    print("Unesite grane grafa (2 vrijednosti sa zarezom kao razmak): ");
    while (true) {
      try {
        String? input = stdin.readLineSync();
        if (input == null || input.isEmpty) {
          break;
        }
        List<String> cvoroviGrane = input.split(",");
        if (cvoroviGrane.length != 2) {
          throw Exception(
              "Pogrešan format, unesite 2 čvora razmaknuta zarezom!");
        }

        final String prviCvor = cvoroviGrane[0].trim();
        final String drugiCvor = cvoroviGrane[1].trim();

        int? indeksPrviCvor = cvorovi[prviCvor];
        int? indeksDrugiCvor = cvorovi[drugiCvor];

        if (indeksPrviCvor == null) {
          throw Exception(
              "Čvorov $prviCvor ne postoji. Unesite ispravan čvor!");
        }
        if (indeksDrugiCvor == null) {
          throw Exception(
              "Čvorov $drugiCvor ne postoji. Unesite ispravan čvor!");
        }
        graf[indeksPrviCvor][indeksDrugiCvor] = true;
        graf[indeksDrugiCvor][indeksPrviCvor] = true;
      } on Exception catch (e) {
        print('Error: $e ❌');
      }
    }
  }

  /// Metoda koja dodaje [grane] proslijeđene kao parametar u graf.
  void dodajGrane(List<(int, int)> grane) {
    for ((int, int) grana in grane) {
      graf[grana.$1][grana.$2] = true;
      graf[grana.$2][grana.$1] = true;
    }
  }

  /// Pomoćna metoda koja kreira matricu susjedstva grafa [graf].
  /// Nakon unosa čvorova sa metodom [_UNOS_CVOROVA] ili nakon postavljanja čvorova sa [dodajCvorove].
  void _kreirajGraf() {
    graf = [];
    graf.addAll(cvorovi.keys
        .map((e) => <bool>[]..addAll(cvorovi.keys.map((e) => false))));
  }

  /// Pomoćna metoda koja generiše sve kombinacije / podskupove čvorova
  void generateSubsets(List<Map<String, int>> current,
      List<Map<String, int>> rezultat, int start, int remaining) {
    if (remaining == 0) {
      Map<String, int> subsetMap = {};
      current.forEach((element) {
        subsetMap.addAll(element);
      });
      rezultat.add(Map.from(subsetMap));
      return;
    }

    for (int i = start; i < cvorovi.length; i++) {
      current.add({cvorovi.keys.elementAt(i): cvorovi.values.elementAt(i)});
      generateSubsets(current, rezultat, i + 1, remaining - 1);
      current.removeLast();
    }
  }

  /// Metoda koja obavlja unos grafa.
  void UNOS_GRAFA() {
    _UNOS_CVOROVA();
    _UNOS_GRANA();
  }

  /// Metoda koja provjerava da li u grafu postoji nezavisan skup čvorova veličine barem [k].
  (bool, Map<String, int>) RJESENJE_K_INDSET(int k) {
    List<Map<String, int>> podskupovi = [];

    for (int i = k; i <= cvorovi.length; i++) {
      generateSubsets([], podskupovi, 0, i);
    }

    Map<String, int> trenutniPodskup = {};
    bool ispunjivo = podskupovi.any((podskup) {
      trenutniPodskup = podskup;
      return VERIFIKACIJA_INDSET(podskup);
    });
    return (ispunjivo, trenutniPodskup);
  }

  /// Metoda koja verifikuje da li je proslijeđeni podskup čvorova [podskupCvorova] nezavisan skup čvorova.
  bool VERIFIKACIJA_INDSET(Map<String, int> podskupCvorova) {
    var entries = podskupCvorova.entries.toList();
    bool indset = true;
    for (int i = 0; i < entries.length; i++) {
      for (int j = 0; j < entries.length; j++) {
        if (i == j) {
          continue;
        }

        int indeksCvoraI = entries[i].value;
        int indeksCvoraJ = entries[j].value;

        if (graf[indeksCvoraI][indeksCvoraJ]) {
          i = podskupCvorova.length;
          indset = false;
          break;
        }
      }
    }

    return indset;
  }

  /// Metoda koja provjerava da li u grafu postoji klika veličine barem k.
  (bool, Map<String, int>) RJESENJE_K_CLIQUE(int k) {
    List<Map<String, int>> podskupovi = [];

    for (int i = k; i <= cvorovi.length; i++) {
      generateSubsets([], podskupovi, 0, i);
    }

    Map<String, int> trenutniPodskup = {};
    bool ispunjivo = podskupovi.any((podskup) {
      trenutniPodskup = podskup;
      return VERIFIKACIJA_K_CLIQUE(podskup);
    });
    return (ispunjivo, trenutniPodskup);
  }

  /// Metoda koja verifikuje da li je proslijeđeni podskup čvorova [podskupCvorova] klika.
  bool VERIFIKACIJA_K_CLIQUE(Map<String, int> podskupCvorova) {
    var entries = podskupCvorova.entries.toList();
    bool clique = true;
    for (int i = 0; i < entries.length; i++) {
      for (int j = 0; j < entries.length; j++) {
        if (i == j) {
          continue;
        }

        int indeksCvoraI = entries[i].value;
        int indeksCvoraJ = entries[j].value;

        if (!graf[indeksCvoraI][indeksCvoraJ]) {
          i = podskupCvorova.length;
          clique = false;
          break;
        }
      }
    }

    return clique;
  }
}

void main() {
  try {
    final KlikaINDSETGraf graf = KlikaINDSETGraf();
    graf.UNOS_GRAFA();

    final (bool indset, Map<String, dynamic> rjesenje) =
        graf.RJESENJE_K_CLIQUE(3);

    print("Clique = $indset, rjesenje = $rjesenje");
  } catch (e) {
    print("Error = $e ❌");
  }
}
