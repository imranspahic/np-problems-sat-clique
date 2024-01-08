import 'dart:io';

import 'klika_indset_graf.dart';

class Formula3CNF {
  List<List<int>> formula = [];
  List<int> varijable = [];

  /// Pomoćna metoda za ispis formule.
  void ispis() {
    String formulaString = "F = ";
    for (List<int> klauzula in formula) {
      formulaString = formulaString + "(";

      for (int literal in klauzula) {
        if (literal < 0) {
          formulaString = formulaString + "¬X${literal.abs()}";
        } else {
          formulaString = formulaString + "X$literal";
        }
        formulaString = formulaString + " v ";
      }
      formulaString = formulaString.substring(0, formulaString.length - 3);

      formulaString = formulaString + ") ∧ ";
    }
    formulaString = formulaString.substring(0, formulaString.length - 2);
    print(formulaString);
  }

  /// Pomoćna metoda za ispis varijabli u formuli.
  void ispis_varijable() {
    String varijableString = "VARIJABLE = ";
    for (int varijabla in varijable) {
      varijableString = varijableString + "X$varijabla";
      varijableString = varijableString + ", ";
    }
    varijableString = varijableString.substring(0, varijableString.length - 2);
    print(varijableString);
  }

  /// Metoda koja obavlja unos formule u [formula] kao i varijabli u [varijable].
  void UNOS_3_CNF() {
    print("Unesite formulu: ");
    while (true) {
      try {
        String? input = stdin.readLineSync();
        if (input == null || input.isEmpty) {
          break;
        }
        List<String> numbers = input.split(',');
        if (numbers.length != 3) {
          throw FormatException('Invalid input format');
        }
        List<int> row = numbers.map(int.parse).toList();
        for (int varijabla in row) {
          varijable.add(varijabla.abs());
        }
        formula.add(row);
      } on FormatException catch (e) {
        print('Error: ${e.message} ❌');
      } on Exception catch (e) {
        print('Error: $e ❌');
      }
    }
    varijable.sort();
    varijable = varijable.toSet().toList();
  }

  /// Metoda koja provjerava da li je [formula] ispunjiva za vrijednosti varijabli iz [arg].
  bool VERIFIKACIJA_3_CNF(List<bool> arg) {
    if (arg.length != varijable.length) {
      throw Exception("Argumenti nisu proslijeđeni za sve varijable");
    }
    return formula.every(
      (klauzula) => klauzula.any(
        (literal) {
          if (literal < 0) {
            return !arg[literal.abs() - 1];
          }
          return arg[literal - 1];
        },
      ),
    );
  }

  /// Metoda koja vraća da li je [formula] ispunjiva.
  /// Provjerava sve moguće kombinacije generisane sa metodom [generisi_kombinacije_varijablie],
  /// dok se ne pronađe zadovoljavajuća kombinacija.
  (bool, List<bool>) RJESENJE_3_CNF() {
    List<List<bool>> kombinacije = generisi_kombinacije_varijablie();
    List<bool> trenutnaKombinacija = [];
    bool ispunjivo = kombinacije.any((kombinacija) {
      trenutnaKombinacija = kombinacija;
      return VERIFIKACIJA_3_CNF(kombinacija);
    });
    return (ispunjivo, trenutnaKombinacija);
  }

  /// Pomoćna metoda koja generiše i vraća sve kombinacije logičkih vrijednosti za [varijable].
  List<List<bool>> generisi_kombinacije_varijablie() {
    final int n = varijable.length;
    final int max = 1 << n;
    final List<List<bool>> result = [];
    for (int i = 0; i < max; i++) {
      final List<bool> combination = [];
      for (int j = 0; j < n; j++) {
        combination.add((i & (1 << j)) != 0);
      }
      result.add(combination);
    }
    return result;
  }

  /// Metoda koja vrši redukciju CNF (SAT) problema na INDSET problem.
  /// Kreira graf te vraća graf i broj klauzula u formuli.
  (KlikaINDSETGraf, int) RED_3_SAT_TO_INDSET() {
    final KlikaINDSETGraf klikaINDSETGraf = KlikaINDSETGraf();

    Map<String, int> cvorovi = {};
    List<(int, int)> grane = [];

    int index = 0;
    // Kreiranje čvorova u formatu: "c0_1_1"
    // c0 - indeks čvora, drugi broj je varijabla, treći broj je znak (1 - pozitivno, 0 negativno).
    for (List<int> klauzula in formula) {
      int var1 = klauzula[0];
      int var2 = klauzula[1];
      int var3 = klauzula[2];

      cvorovi["c${index}_${var1.abs()}_${var1 > 0 ? 1 : 0}"] = index;
      cvorovi["c${index + 1}_${var2.abs()}_${var2 > 0 ? 1 : 0}"] = index + 1;
      cvorovi["c${index + 2}_${var3.abs()}_${var3 > 0 ? 1 : 0}"] = index + 2;
      grane.add((index, index + 1));
      grane.add((index + 1, index + 2));
      grane.add((index + 2, index));
      index += 3;
    }

    klikaINDSETGraf.dodajCvorove(cvorovi);
    klikaINDSETGraf.dodajGrane(grane);
    grane = [];

    for (var entry1 in cvorovi.entries) {
      for (var entry2 in cvorovi.entries) {
        if (entry1 == entry2) {
          continue;
        }

        List<String> entry1Splitted = entry1.key.split("_");
        List<String> entry2Splitted = entry2.key.split("_");

        // Dodaj granu između komplementarnih vrijednosti
        if (entry1Splitted[1] == entry2Splitted[1] &&
            entry1Splitted[2] != entry2Splitted[2]) {
          grane.add((entry1.value, entry2.value));
        }
      }
    }

    klikaINDSETGraf.dodajGrane(grane);
    return (klikaINDSETGraf, formula.length);
  }

  /// Metoda koja vrši redukciju CNF (SAT) problema na CLIQUE problem.
  /// Kreira graf te vraća graf i broj klauzula u formuli.
  (KlikaINDSETGraf, int) RED_3_SAT_TO_CLIQUE() {
    final KlikaINDSETGraf klikaINDSETGraf = KlikaINDSETGraf();

    Map<String, int> cvorovi = {};
    List<(int, int)> grane = [];

    int cvorIndex = 0;
    int klasterIndex = 0;
    // Kreiranje čvorova u formatu: "k0_c0_1_1"
    // k0 - indeks klauzule/klastera, c0 - indeks čvora, drugi broj je varijabla, treći broj je znak (1 - pozitivno, 0 negativno).
    for (List<int> klauzula in formula) {
      int var1 = klauzula[0];
      int var2 = klauzula[1];
      int var3 = klauzula[2];

      cvorovi["k${klasterIndex}_c${cvorIndex}_${var1.abs()}_${var1 > 0 ? 1 : 0}"] =
          cvorIndex;
      cvorovi["k${klasterIndex}_c${cvorIndex + 1}_${var2.abs()}_${var2 > 0 ? 1 : 0}"] =
          cvorIndex + 1;
      cvorovi["k${klasterIndex}_c${cvorIndex + 2}_${var3.abs()}_${var3 > 0 ? 1 : 0}"] =
          cvorIndex + 2;

      cvorIndex += 3;
      klasterIndex++;
    }

    klikaINDSETGraf.dodajCvorove(cvorovi);

    for (var entry1 in cvorovi.entries) {
      for (var entry2 in cvorovi.entries) {
        if (entry1 == entry2) {
          continue;
        }

        List<String> entry1Splitted = entry1.key.split("_");
        List<String> entry2Splitted = entry2.key.split("_");

        // Ako su dva čvora komplementarna, preskoči.
        if (entry1Splitted[2] == entry2Splitted[2] &&
            entry1Splitted[3] != entry2Splitted[3]) {
          continue;
        }

        // Dodaj granu između svaka dva čvora osim između čvorova sa istim klasterom (iz iste klauzule).
        if (entry1Splitted[0] != entry2Splitted[0]) {
          grane.add((entry1.value, entry2.value));
        }
      }
    }

    klikaINDSETGraf.dodajGrane(grane);
    return (klikaINDSETGraf, formula.length);
  }
}

void main() {
  try {
    final Formula3CNF formula3cnf = Formula3CNF();
    formula3cnf.UNOS_3_CNF();
    formula3cnf.ispis();
    formula3cnf.ispis_varijable();

    final (KlikaINDSETGraf klika_indset_graf, int k) =
        formula3cnf.RED_3_SAT_TO_INDSET();

    // bool rezultat1 = formula3cnf.VERIFIKACIJA_3_CNF([true, true, true]);
    // bool rezultat2 = formula3cnf.VERIFIKACIJA_3_CNF([false, false, false]);

    final (bool formulaSolution, List<bool> formulaResult) =
        formula3cnf.RJESENJE_3_CNF();
    final (bool indsetSolution, Map<String, int> indsetResult) =
        klika_indset_graf.RJESENJE_K_INDSET(k);

    if (formulaSolution) {
      print("Formula ispunjiva za kombinaciju $formulaResult 🟢");
    } else {
      print("Formula nije ispunjiva 🟡");
    }

    if (indsetSolution) {
      print("Graf sadrži nezavisan skup od $k čvorova $indsetResult 🟢");
    } else {
      print("Graf ne sadrži nezavisan skup od $k 🟡");
    }

    final (KlikaINDSETGraf klika_indset_graf_2, int k2) =
        formula3cnf.RED_3_SAT_TO_CLIQUE();

    final (bool cliqueSolution, Map<String, int> cliqueResult) =
        klika_indset_graf_2.RJESENJE_K_CLIQUE(k2);

    if (cliqueSolution) {
      print("Graf sadrži kliku od $k2 čvorova $cliqueResult 🟢");
    } else {
      print("Graf ne sadrži kliku od $k2 čvorova 🟡");
    }
  } catch (e) {
    print("Error = $e ❌");
  }
}
