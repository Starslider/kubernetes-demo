# AI Agents Workshop
## Von Generativer KI zu autonomen Agenten

Eine 30-Minuten Einführung für nicht-technische Zielgruppen

---

## Was wir heute besprechen

1. **Was ist Generative KI?** - Die Technologie hinter dem Hype
2. **Was ist ein LLM?** - Der Motor hinter allem
3. **Die Kunst des Promptens** - Warum es darauf ankommt wie man fragt
4. **Die Zukunft: KI-Agenten** - Vom Chatbot zum autonomen Assistenten
5. **Live Demo** - Ein Snake-Spiel mit KI bauen (wenn die Zeit reicht)

---

## Teil 1
### Was ist Generative KI?

---

## Der grosse Wandel in der KI

**Traditionelle KI (2010er):**
- "Ist diese E-Mail Spam?" (Klassifikation)
- "Wird diese Maschine ausfallen?" (Vorhersage)
- KI die bestehende Daten **analysiert**

**Generative KI (2020er):**
- "Schreib mir eine Marketing-E-Mail"
- "Entwirf ein Logo für mein Startup"
- "Fasse diesen 50-Seiten-Bericht in 5 Stichpunkten zusammen"
- KI die neue Inhalte **erschafft**

---

## Was kann Generative KI erschaffen?

| Art | Beispiele | Tools die ihr kennt |
|-----|-----------|---------------------|
| **Text** | Artikel, E-Mails, Code, Übersetzungen | ChatGPT, Claude |
| **Bilder** | Kunst, Produktfotos, Designs | Midjourney, DALL-E |
| **Audio** | Musik, Stimmen-Klone, Podcasts | Suno, ElevenLabs |
| **Video** | Animationen, Kurzclips, Avatare | Sora, Runway |
| **Code** | Komplette Anwendungen, Skripte, Websites | GitHub Copilot, Claude Code |

---

## Wie funktioniert das? (Die einfache Version)

**Drei Schritte:**

**1. Training** - Das Internet lesen
- Milliarden Bücher, Websites, Konversationen
- Muster lernen: welche Wörter, Pixel, Töne zusammengehören

**2. Verstehen** - Internes "Wissen" aufbauen
- Nicht auswendig lernen - Muster erkennen
- Wie eine Sprache lernen durch Eintauchen

**3. Generieren** - Etwas Neues erschaffen
- Sagt das wahrscheinlichste nächste Wort/Pixel/Note voraus
- Gesteuert durch eure Anweisungen (den "Prompt")

**Keine Magie - sehr ausgefeilte Mustererkennung in riesigem Umfang**

---

## Teil 2
### Was ist ein LLM?

---

## LLM = Large Language Model

**Stellt euch Autocomplete auf Steroiden vor:**

Ihr tippt: *"Die Katze saß auf der..."*

| | Vorhersage |
|---|---|
| **Handy-Autocomplete** | "Matte" |
| **LLM** | Schreibt euch eine komplette Geschichte über die Katze, ihre Vorgeschichte und was als nächstes passiert |

**"Large"** = Trainiert auf riesigen Textmengen, Milliarden von Parametern

**"Language Model"** = Spezialisiert auf das Verstehen und Erzeugen menschlicher Sprache

**LLMs sind eine Art Generativer KI - spezialisiert auf Sprache**

---

## Die grossen Player

**GPT-4o** (OpenAI) - Treibt ChatGPT an, am bekanntesten

**Claude** (Anthropic) - Stark bei Logik und längeren Aufgaben

**Gemini** (Google) - Eingebaut in Google-Produkte

**LLaMA / DeepSeek** (Meta / DeepSeek) - Open-Source Modelle die jeder nutzen kann

**Grok** (xAI) - Integriert in X/Twitter

Alle gemeinsam: Sagen die wahrscheinlichsten nächsten Wörter voraus, basierend auf eurer Eingabe + ihrem Training

---

## Was LLMs gut können (und was nicht)

**Stärken:**
- Fragen beantworten und komplexe Themen erklären
- Texte schreiben und bearbeiten (E-Mails, Berichte, Code)
- Zwischen Sprachen übersetzen
- Lange Dokumente zusammenfassen
- Brainstorming und kreative Arbeit

**Grenzen:**
- Können selbstbewusst Fakten erfinden ("Halluzinationen")
- Kein Wissen über Ereignisse nach dem Trainings-Stichtag
- Mathematik und exakte Logik können unzuverlässig sein
- Kein echtes Verständnis - Mustererkennung, kein Denken

**Faustregel:** Toller Assistent, aber wichtige Aussagen immer prüfen

---

## Teil 3
### Die Kunst des Promptens

---

## Warum Prompting so wichtig ist

**Dieselbe KI, komplett andere Ergebnisse:**

| Prompt | Ergebnis |
|--------|----------|
| "Schreib was über Vertrieb" | Generischer, vager, nutzloser Absatz |
| "Schreib eine 3-Absatz E-Mail an unsere B2B-Kunden zur Ankündigung unseres neuen Preismodells. Ton: professionell aber freundlich. Erwähne den 15% Frühbucher-Rabatt." | Genau was man braucht, versandfertig |

**Die Qualität des Ergebnisses hängt direkt von der Qualität eurer Eingabe ab**

Euer Prompt ist das Lenkrad - die KI ist der Motor.

---

## Was ist Prompt Engineering?

**Prompt Engineering** = Die Fähigkeit, Anweisungen zu schreiben die das Beste aus der KI herausholen

**Das ist kein Programmieren - das ist klare Kommunikation.**

**Die 5 Bausteine eines guten Prompts:**

1. **Rolle** - Wer soll die KI sein? *"Du bist ein erfahrener Marketing-Experte"*
2. **Aufgabe** - Was genau soll sie tun? *"Schreib eine Produktbeschreibung"*
3. **Kontext** - Welche Hintergrundinfo braucht sie? *"Für unser B2B SaaS-Produkt..."*
4. **Format** - Wie soll die Ausgabe aussehen? *"3 Stichpunkte, max. 50 Wörter pro Punkt"*
5. **Einschränkungen** - Was vermeiden? *"Kein Fachjargon, keine Emojis, formeller Ton"*

---

## Schlechte vs. gute Prompts - Beispiele

**Vager Prompt:**
> "Hilf mir bei einer Präsentation"

**Engineered Prompt:**
> "Erstelle eine Gliederung für eine 10-Folien-Präsentation über unsere Q4-Ergebnisse. Zielgruppe: C-Level Führungskräfte. Enthalten: Umsatzwachstum (+12%), Neukunden (8) und 3 zentrale Herausforderungen. Stil: datengetrieben, prägnant, eine Kernaussage pro Folie."

**Warum das funktioniert:**
- KI kennt die **Zielgruppe** (Führungskräfte, nicht Praktikanten)
- KI kennt den **Umfang** (10 Folien, Q4)
- KI kennt die **Daten** die rein sollen
- KI kennt den **Stil** dem sie folgen soll

**Prompt Engineering ist die Schlüsselkompetenz für die Arbeit mit KI**

---

## Schnelle Prompting-Tipps

**Einfach anfangen, dann verfeinern:**
- Der erste Versuch wird nicht perfekt sein - und das ist okay
- Sagt "mach es kürzer", "formeller", "füge Beispiele hinzu"
- Behandelt es wie ein Gespräch, nicht wie einen einmaligen Befehl

**Zeigt Beispiele von dem was ihr wollt:**
- "Schreib es in diesem Stil: [Beispiel einfügen]"
- Zeigt das Format das ihr erwartet

**Sagt was die KI NICHT tun soll:**
- "Keine Buzzwords verwenden"
- "Keine Statistiken erfinden"
- "Nicht jeden Satz mit 'In der heutigen Zeit...' beginnen"

**Nutzt KI als Sparringspartner:**
- "Was fehlt in diesem Plan?"
- "Spiel den Advocatus Diaboli bei dieser Idee"
- "Welche Fragen würde ein skeptischer Kunde stellen?"

---

## Teil 4
### Die Zukunft: KI-Agenten

---

## Vom Chatbot zum Agenten

**LLM (heutiger Chatbot):**
- Ihr: "Finde mir einen Flug nach Berlin für nächsten Freitag"
- ChatGPT: *"Ich empfehle Lufthansa oder booking.com zu prüfen..."*
- **Ihr macht noch die ganze Arbeit selbst**

**KI-Agent (der nächste Schritt):**
- Ihr: "Buche mir einen Flug nach Berlin für nächsten Freitag"
- Agent: *Prüft euren Kalender > Sucht Flüge > Vergleicht Preise > Bucht die beste Option > Trägt es in euren Kalender ein > Schickt euch Bestätigung*
- **Der Agent erledigt die Arbeit für euch**

**Der Wandel: Vom Berater zum Mitarbeiter**

---

## Was einen Agenten anders macht

**Ein KI-Agent kann:**

1. **Ziele verstehen** - Nicht nur Fragen, sondern Aufgaben
2. **Pläne machen** - Komplexe Aufgaben in Schritte aufteilen
3. **Werkzeuge nutzen** - Im Web suchen, APIs aufrufen, E-Mails senden, Dateien schreiben
4. **Autonom handeln** - Ausführen ohne bei jedem Schritt zu fragen
5. **Lernen und anpassen** - Vorgehen ändern wenn etwas nicht klappt

**Vergleich:**
- LLM = Experten-Berater der Ratschläge gibt
- Agent = Mitarbeiter der Dinge erledigt

---

## Die Agenten-Schleife

**Wie Agenten arbeiten - ein stetiger Kreislauf:**

**Beobachten** - Was ist die aktuelle Situation?

**Denken** - Was sollte ich als nächstes tun?

**Handeln** - Ein Werkzeug nutzen, etwas aufrufen, etwas schreiben

**Reflektieren** - Hat es funktioniert? Was hat sich geändert?

**Wiederholen** - Bis das Ziel erreicht ist

Genau so funktioniert Claude Code - ihr gebt ein Ziel vor, es plant, schreibt Code, testet, behebt Fehler und liefert.

---

## Agenten in Aktion - Echte Beispiele

**Coding Agents (schon heute verfügbar):**
- Verstehen Feature-Anfragen in normaler Sprache
- Schreiben, testen und debuggen Code selbstständig
- Beispiele: Claude Code, GitHub Copilot Workspace

**Research Agents:**
- Bekommen ein Thema, durchsuchen Dutzende Quellen
- Fassen Ergebnisse in strukturierten Berichten zusammen
- Prüfen Fakten über mehrere Referenzen

**Business-Prozess Agents:**
- Verarbeiten Rechnungen und Spesenabrechnungen
- Überwachen Systeme und melden Probleme
- Erstellen Wochenberichte aus Rohdaten

---

## Wohin die Reise geht (2026-2028)

**Was kommt:**
- Agenten die euren Kalender und E-Mails verwalten
- Multi-Agenten-Teams (einer recherchiert, einer schreibt, einer prüft)
- Agenten integriert in jedes Software-Tool
- Persönliche KI-Assistenten die eure Vorlieben wirklich kennen
- KI die komplette Workflows von Anfang bis Ende übernimmt

**Was bleibt:**
- Menschliches Urteilsvermögen bei wichtigen Entscheidungen
- Kreativität und Empathie bleiben einzigartig menschlich
- "Human-in-the-Loop" bei kritischen Aktionen

**Die Zukunft ist Mensch + KI, nicht Mensch gegen KI**

---

## Teil 5
### Die wichtigsten Erkenntnisse

---

## Der KI-Stack auf einen Blick

**Generative KI** = Das Fundament - KI die Inhalte erschafft
&darr;
**LLMs** = Spezialisiert auf Sprache - treibt Konversationen an
&darr;
**KI-Agenten** = Die nächste Stufe - KI die autonom handelt

**Jede Ebene baut auf der darunter auf**

---

## Was ihr heute schon tun könnt

**Fangt an zu experimentieren:**
1. Probiert ChatGPT oder Claude für tägliche Aufgaben
2. Nutzt KI um E-Mails zu entwerfen, Dokumente zusammenzufassen, Ideen zu sammeln
3. Prüft wichtige Ausgaben immer gegen
4. Teilt was funktioniert mit eurem Team

**Denkt über eure Arbeit nach:**
- Welche Aufgaben sind repetitiv?
- Wo verbringt ihr Zeit mit Routine-Arbeit?
- Was würdet ihr mit 2 Extra-Stunden pro Tag machen?

**Wer lernt mit KI zu arbeiten, wird einen deutlichen Vorteil haben**

---

## Fragen?

**Vielen Dank für eure Zeit!**

Lasst uns besprechen wie KI eure Arbeit verändern könnte.

**Probiert es selbst aus:**
- claude.ai - Claude ausprobieren
- chatgpt.com - ChatGPT ausprobieren
- midjourney.com - Bildgenerierung ausprobieren

---

## Bonus: Live Demo
### Ein Snake-Spiel bauen mit Claude Code

*Lasst uns einen KI-Agenten in Aktion sehen!*

Ein Prompt. Ein KI-Agent. Ein komplett spielbares Snake-Spiel - live gebaut in unter 2 Minuten.

**Achtet auf die Agenten-Schleife:**
Ziel verstehen > Ansatz planen > Code schreiben > Testen > Liefern
