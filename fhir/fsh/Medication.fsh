// TODO Unit System abfangen??

Profile: ProfileMedicationMedikation
Parent: https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/Medication
Id: ProfileMedicationMedikation
Title: "Profile - Medication - Medikation"
Description: "Auf der MII Medikation aufbauendes Profil zur Beschreibung eines Medikamentes (Mischungen) im POLAR Use Case."

* ^status = #draft
* obeys polar-1

* form.coding contains IFA 0..* MS
* form.coding[IFA] ^patternCoding.system = "https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_BMP_DARREICHUNGSFORM"
* form.coding[IFA].code 1..1
* form.coding[IFA].system 1..1

* ingredient obeys polar-2 and polar-3 and polar-4 and polar-5 and polar-7 and polar-8

* ingredient.isActive MS

// Substance soll nicht verwendet werden? Falls doch: Invariante polar-5 anpassen (Referenzen auf Substance abfangen und nicht prüfen)
* ingredient.item[x] only Reference(Medication) or CodeableConcept
* ingredient.itemReference MS


//Minibeispiel für Mischung mit Einheiten
// A : 30g/10ml
// B : 10ug/ 1 Stück
// C : A 5 ml/xy + B 2 Stück/ xy

//Min eine Extension(Wirkstofftyp) mit value=PIN
Invariant:  polar-1
Description: "Mindestens eine Extension Wirkstofftyp mit Wert PIN"
Expression: "ingredient.extension('https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/wirkstofftyp').exists(value.code = 'PIN')"
Severity:   #error

//Ingredients können falls notwendig und sinnvoll ebenfalls als ‚PIN‘ und ‚IN‘ definiert werden, wobei die Referenz auf eine andere Medication Ressource immer ein ‚PIN‘ darstellt.
Invariant:  polar-2
Description: "Die Referenz auf eine andere Medication Ressource stellt immer ein ‚PIN‘ dar."
Expression: "itemReference.exists() implies extension('https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/wirkstofftyp').exists(value.code = 'PIN')"
Severity:   #error

//Als ‚IN‘ markierte Ingredients sind auch hier als „entspricht“-Angaben zu verstehen und dürfen nicht auf andere Medication Ressourcen referenzieren. 
Invariant:  polar-3
Description: "Als ‚IN‘ markierte Ingredients sind auch hier als „entspricht“-Angaben zu verstehen und dürfen nicht auf andere Medication Ressourcen referenzieren."
Expression: "extension('https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/wirkstofftyp').exists(value.code = 'IN') implies itemReference.empty()"
Severity:   #error

// Der Denominator (Nenner) in der Strengthangabe ist auch bei Rezepturen über alle Ingredients innerhalb der Medication Ressource konstant zu halten und definiert die Einheit und deren Menge, auf die sich alle Zähler der Stärkeangaben beziehen.
Invariant:  polar-4
Description: "strength.denominator.code muss in allen ingredients gleich sein."
Expression: "strength.denominator.code.exists() implies strength.denominator.code.distinct().count() = 1"
Severity:   #error

//Ingredient.Strength.Numerator: Bei der Referenz des Ingredients auf eine andere Medication Ressource, muss die Einheit, mit der der Numerator (Zähler) der Strength angegeben wird, dem Denominator der Strength in der referenzierten Medication entsprechen.
Invariant:  polar-5
Description: "Bei der Referenz des Ingredients auf eine andere Medication Ressource, muss die Einheit, mit der der Numerator der Strength angegeben wird, dem Denominator der Strength in der referenzierten Medication entsprechen."
Expression: "itemReference.exists() implies (strength.numerator.code = itemReference.resolve().ingredient.strength.denominator.code.first())"
Severity:   #error

//Ingredient code: ASK gewünscht. Warning wenn kein ASK, CAS als 2. Wahl. Wenn isActive = false -> Kein ASK nötig
Invariant: polar-7
Description: "Wenn ein Inhaltsstoff nicht explizit als nicht aktiv markiert ist, soll ein ASK oder ersatzweise ein CAS Code vorhanden sein."
Expression: "(isActive = false) or itemCodeableConcept.coding.where(system = 'http://fhir.de/CodeSystem/ask' or system = 'urn:oid:2.16.840.1.113883.6.61').exists()"
Severity:   #warning

//Als Einheit für den Nenner (denominator) sollen möglichst UCUM-Einheiten verwendet werden.
Invariant: polar-8
Description: "Als Einheit für den Nenner (denominator) sollen möglichst UCUM-Einheiten verwendet werden."
Expression: "strength.denominator.system = 'http://unitsofmeasure.org'"
Severity:   #warning

Profile: ProfileMedicationAdministration
Parent: https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationAdministration
Id: ProfileMedicationAdministration
Title: "Profile - MedicationAdministration - Medikation"
Description: "Auf der MII Medikation aufbauendes Profil zur Beschreibung einer MedicationAdministration im POLAR Use Case."

* ^status = #draft
* obeys polar-6

Profile: ProfileMedicationStatement
Parent: https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationStatement
Id: ProfileMedicationStatement
Title: "Profile - MedicationStatement - Medikation"
Description: "Auf der MII Medikation aufbauendes Profil zur Beschreibung eines MedicationStatement im POLAR Use Case."

* ^status = #draft
* obeys polar-6


// Die Dosis (dose und rateQuantity oder rateRatio.numerator) in MedicationAdministration und MedicationStatement muss den gleichen Bezug, wie der Denominator in der Strength der ingredients haben. 
//Technischer Kommentar: FHIRPath prüfen, ob der Vergleich klappt (wg. primitive vs collection)
Invariant:  polar-6
Description: "Die Dosis (dose und rateQuantity oder rateRatio.numerator) in MedicationAdministration und MedicationStatement muss die gleiche Einheit wie der Denominator in der Strength der ingredients haben."
Expression: "medicationReference.exists() implies (dosage.dose.code | rateQuantity.code | rateRatio.numerator.code) = medicationReference.resolve().ingredient.strength.denominator.code"
Severity:   #error


Profile: ProfileMedicationFertigarzneimittel
Parent: ProfileMedicationMedikation
Id: ProfileMedicationFertigarzneimittel
Title: "Profile - Medication - Fertigarzneimittel"
Description: "Auf der MII Medikation aufbauendes Profil zur Beschreibung eines normierten Fertigarzneimittels (bzw. Bestandteil von der Stange) im POLAR Use Case."

* ^status = #draft
* obeys polar-9 and polar-10



// Gibt es eiene ander IFA URL (intl.)?
// Wenn kein IFA warning
Invariant:  polar-9
Description: "Für alle Fertigarzneimittel soll ein IFA Code für die Darreichungsform angegeben werden."
Expression: "form.coding.where(system = 'https://fhir.kbv.de/CodeSystem/KBV_CS_SFHIR_BMP_DARREICHUNGSFORM').exists()"
Severity:   #warning

// Wenn weder atcDe noch PZN - Warning
Invariant:  polar-10
Description: "Für alle Fertigarzneimittel soll ein ATC Code (DE) und/oder eine PZN angegeben werden."
Expression: "code.coding.where(system='http://fhir.de/CodeSystem/dimdi/atc' or system='http://fhir.de/CodeSystem/ifa/pzn').exists()"
Severity:   #warning


// WIP: List für Aufnahme- und Entlassmedikation

Profile: ProfileListMedikationsliste
Parent: http://hl7.org/fhir/StructureDefinition/List
Id: ProfileListMedikationsliste
Title: "Profile - List- Medikationsliste"
Description: "Liste mit MedicationStatments zur Dokumentation der Aufnahme- oder Entlassmedikation."

* ^status = #draft
* mode = #snapshot
* code = http://terminology.hl7.org/CodeSystem/list-example-use-codes#medications "Medication List"
* subject only Reference(Patient)
* entry.flag 0..0
* entry.deleted 0..0
* entry.date 0..0
* entry.item only Reference(https://www.medizininformatik-initiative.de/fhir/core/modul-medikation/StructureDefinition/MedicationStatement)