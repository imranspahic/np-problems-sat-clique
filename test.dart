import 'dart:io';

import 'formula_3_cnf.dart';
import 'klika_indset_graf.dart';

void main() {
  final Formula3CNF formula3cnf = Formula3CNF();
  final KlikaINDSETGraf klikaINDSETGraf = KlikaINDSETGraf();

  while (true) {
    print("--------------------------");
    print("Meni:");
    print("1. Unos formule");
    print("2. Unos grafa");
    print("3. Ispunjivost formule");
    print("4. k-nezavisnih čvorova u grafu");
    print("5. k-klika u grafu");
    print("6. Verifikacija formule");
    print("7. Verifikacija skupa nezavisnih čvorova");
    print("8. Verifikacija k-klike");
    print("9. Redukcija 3-SAT-TO-INDSET");
    print("10. Redukcija 3-SAT-TO-CLIQUE");
    print("11. Izlaz");
    print("--------------------------");

    stdout.write("Izaberite opciju (1, 2, 3, 4, 5, 6, 7, 8 ili 9): ");
    String? userInput = stdin.readLineSync();

    if (userInput == null) {
      print("Pogrešan unos. Pokušajte ponovo! ❌");
      continue;
    }

    switch (userInput) {
      case '1':
        formula3cnf.UNOS_3_CNF();
        formula3cnf.ispis();
        formula3cnf.ispis_varijable();
        break;
      case '2':
        klikaINDSETGraf.UNOS_GRAFA();
        break;
      case '3':
        if (formula3cnf.formula.isEmpty) {
          print("Unesite prvo formulu sa opcijom 1 🔴");
          break;
        }
        final (ispunjiva, rjesenje) = formula3cnf.RJESENJE_3_CNF();
        if (ispunjiva) {
          formula3cnf.ispis();
          print("Formula ispunjiva za kombinaciju $rjesenje 🟢");
        } else {
          print("Formula nije ispunjiva 🟡");
        }
        break;
      case '4':
        if (klikaINDSETGraf.cvorovi.isEmpty) {
          print("Unesite prvo graf sa opcijom 2 🔴");
          break;
        }
        print("Unesite k:");
        String? userInput = stdin.readLineSync();
        try {
          if (userInput == null || userInput.isEmpty) {
            throw Exception("Pogrešan unos broja k");
          }
          int? k = int.tryParse(userInput);
          if (k == null || k <= 0) {
            throw Exception("Pogrešan unos broja k");
          }
          final (postoji, rjesenje) = klikaINDSETGraf.RJESENJE_K_INDSET(k);
          if (postoji) {
            print("U grafu postoji skup od $k nezavisnih čvorova $rjesenje 🟢");
          } else {
            print("U grafu ne postoji skup od $k nezavisnih čvorova 🟡");
          }
        } catch (e) {
          print("$e ❌");
          break;
        }

        break;
      case '5':
        if (klikaINDSETGraf.cvorovi.isEmpty) {
          print("Unesite prvo graf sa opcijom 2 🔴");
          break;
        }
        print("Unesite k:");
        String? userInput = stdin.readLineSync();
        try {
          if (userInput == null || userInput.isEmpty) {
            throw Exception("Pogrešan unos broja k");
          }
          int? k = int.tryParse(userInput);
          if (k == null || k <= 0) {
            throw Exception("Pogrešan unos broja k");
          }
          final (postoji, rjesenje) = klikaINDSETGraf.RJESENJE_K_CLIQUE(k);
          if (postoji) {
            print("U grafu postoji $k-klika $rjesenje 🟢");
          } else {
            print("U grafu ne postoji $k-klika 🟡");
          }
        } catch (e) {
          print("$e ❌");
          break;
        }
        break;
      case '6':
        if (formula3cnf.formula.isEmpty) {
          print("Unesite prvo formulu sa opcijom 1 🔴");
          break;
        }
        print(
            "Unesite pridruživanje vrijednosti logičkim varijablama (za svaku varijablu 0 ili 1, odvojeno razmakom)");
        try {
          String? userInput = stdin.readLineSync();
          if (userInput == null || userInput.isEmpty) {
            throw Exception("Pogrešan unos pridruživanja!");
          }
          List<String> vrijednosti = userInput.split(",");
          if (vrijednosti.length != formula3cnf.varijable.length) {
            throw Exception(
                "Unesite vrijednost za svaku varijablu (broj varijabli = ${formula3cnf.varijable.length})");
          }
          List<bool> pridruzivanje = vrijednosti.map((e) {
            int? vrijednost = int.tryParse(e);
            if (vrijednost == null || (vrijednost != 0 && vrijednost != 1)) {
              throw Exception("Pogrešan unos pridruživanja!");
            }
            if (vrijednost == 0) {
              return false;
            }
            return true;
          }).toList();
          bool validno = formula3cnf.VERIFIKACIJA_3_CNF(pridruzivanje);
          if (validno) {
            print("Formula je ispunjiva za pridruživanje $pridruzivanje 🟢");
          } else {
            print("Formula nije ispunjiva za pridruživanje $pridruzivanje 🟡");
          }
        } catch (e) {
          print("$e ❌");
        }

        break;
      case '7':
        if (klikaINDSETGraf.cvorovi.isEmpty) {
          print("Unesite prvo graf sa opcijom 2 🔴");
          break;
        }
        print("Unesite skup čvorova (razmaknuto zarezom)");
        try {
          String? userInput = stdin.readLineSync();
          if (userInput == null || userInput.isEmpty) {
            throw Exception("Pogrešan unos čvorova!");
          }
          List<String> cvorovi = userInput.split(",");

          Map<String, int> podskup = Map.fromIterable(
            cvorovi,
            key: (cvor) {
              if (!klikaINDSETGraf.cvorovi.containsKey(cvor)) {
                throw Exception(
                    "Pogrešan unos čvorova! Nepostojeći čvor $cvor");
              }
              return cvor;
            },
            value: (cvor) {
              return klikaINDSETGraf.cvorovi[cvor]!;
            },
          );

          bool validno = klikaINDSETGraf.VERIFIKACIJA_INDSET(podskup);
          if (validno) {
            print("Skup čvorova je nezavisan $cvorovi 🟢");
          } else {
            print("Skup čvorova nije nezavisan $cvorovi 🟡");
          }
        } catch (e) {
          print("$e ❌");
        }
        break;
      case '8':
        if (klikaINDSETGraf.cvorovi.isEmpty) {
          print("Unesite prvo graf sa opcijom 2 🔴");
          break;
        }
        print("Unesite skup čvorova (razmaknuto zarezom)");
        try {
          String? userInput = stdin.readLineSync();
          if (userInput == null || userInput.isEmpty) {
            throw Exception("Pogrešan unos čvorova!");
          }
          List<String> cvorovi = userInput.split(",");

          Map<String, int> podskup = Map.fromIterable(
            cvorovi,
            key: (cvor) {
              if (!klikaINDSETGraf.cvorovi.containsKey(cvor)) {
                throw Exception(
                    "Pogrešan unos čvorova! Nepostojeći čvor $cvor");
              }
              return cvor;
            },
            value: (cvor) {
              return klikaINDSETGraf.cvorovi[cvor]!;
            },
          );

          bool validno = klikaINDSETGraf.VERIFIKACIJA_K_CLIQUE(podskup);
          if (validno) {
            print("Skup čvorova je ${podskup.length}-klika $cvorovi 🟢");
          } else {
            print("Skup čvorova nije ${podskup.length}-klika $cvorovi 🟡");
          }
        } catch (e) {
          print("$e ❌");
        }
        break;
      case '9':
        formula3cnf.UNOS_3_CNF();
        formula3cnf.ispis();
        formula3cnf.ispis_varijable();
        final (KlikaINDSETGraf klika_indset_graf, int k) =
            formula3cnf.RED_3_SAT_TO_INDSET();
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
        break;
      case '10':
        formula3cnf.UNOS_3_CNF();
        formula3cnf.ispis();
        formula3cnf.ispis_varijable();
        final (KlikaINDSETGraf klika_indset_graf, int k) =
            formula3cnf.RED_3_SAT_TO_CLIQUE();
        final (bool formulaSolution, List<bool> formulaResult) =
            formula3cnf.RJESENJE_3_CNF();
        final (bool cliqueSolution, Map<String, int> cliqueResult) =
            klika_indset_graf.RJESENJE_K_CLIQUE(k);

        if (formulaSolution) {
          print("Formula ispunjiva za kombinaciju $formulaResult 🟢");
        } else {
          print("Formula nije ispunjiva 🟡");
        }

        if (cliqueSolution) {
          print("Graf sadrži kliku od $k čvorova $cliqueResult 🟢");
        } else {
          print("Graf ne sadrži kliku od $k čvorova 🟡");
        }
        break;
      case '11':
        print("Izlazak iz programa ...");
        return;

      default:
        print("Pogrešan unos. Pokušajte ponovo! ❌");
        break;
    }
  }
}
