# AI Agents Workshop
## Von Generativer KI zu autonomen Agenten

---

## Was wir heute besprechen

1. **Was ist Generative KI?** - Die Technologie hinter dem Hype
2. **Was ist ein LLM?** - Der Motor hinter allem
3. **Die Kunst des Promptens** - Warum es darauf ankommt wie man fragt
4. **Die Zukunft: KI-Agenten** - Vom Chatbot zum autonomen Assistenten
5. **Live Demo** - Ein Snake-Spiel mit KI bauen

---

## Teil 1
### Was ist Generative KI?

---

## Der grosse Wandel in der KI

**Traditionelle KI (2010er):**
- "Ist diese E-Mail Spam?" → Klassifikation
- "Wird diese Maschine ausfallen?" → Vorhersage
- KI die bestehende Daten **analysiert**

**Generative KI (2020er):**
- "Schreib mir eine Marketing-E-Mail"
- "Fasse diesen 50-Seiten-Bericht zusammen"
- KI die neue Inhalte **erschafft**

---

## Was kann Generative KI erschaffen?

| Art | Beispiele | Tools |
|-----|-----------|-------|
| **Text** | Artikel, E-Mails, Code | ChatGPT, Claude |
| **Bilder** | Kunst, Designs, Fotos | Midjourney, DALL-E |
| **Audio** | Musik, Stimmen-Klone | Suno, ElevenLabs |
| **Video** | Animationen, Clips | Sora, Runway |
| **Code** | Apps, Skripte, Websites | Copilot, Claude Code |

---

## Wie funktioniert das?

**1. Training** - Milliarden Bücher, Websites, Konversationen lesen

**2. Verstehen** - Muster erkennen (nicht auswendig lernen)

**3. Generieren** - Das wahrscheinlichste nächste Wort/Pixel/Note vorhersagen

**Keine Magie - ausgefeilte Mustererkennung in riesigem Umfang**

---

## Teil 2
### Was ist ein LLM?

---

## LLM = Large Language Model

**Autocomplete auf Steroiden:**

Ihr tippt: *"Die Katze saß auf der..."*

| | Vorhersage |
|---|---|
| **Handy-Autocomplete** | "Matte" |
| **LLM** | Schreibt eine komplette Geschichte über die Katze und was als nächstes passiert |

**"Large"** = Milliarden Parameter, trainiert auf riesigen Datenmengen

**"Language Model"** = Spezialisiert auf menschliche Sprache

---

## Die grossen Player

**GPT-5** (OpenAI) - Treibt ChatGPT an

**Claude 4.6** (Anthropic) - Stark bei Logik und komplexen Aufgaben

**Gemini 3** (Google) - Eingebaut in Google-Produkte

**Llama 4 / DeepSeek R1** (Meta / DeepSeek) - Open-Source

**Grok 4** (xAI) - Integriert in X/Twitter

Alle sagen die wahrscheinlichsten nächsten Wörter voraus basierend auf Eingabe + Training

---

## Stärken & Grenzen

**Gut darin:**
- Komplexe Themen erklären
- Texte schreiben und bearbeiten (E-Mails, Berichte, Code)
- Übersetzen und Zusammenfassen
- Brainstorming und kreative Arbeit

**Aufpassen bei:**
- Selbstbewusstes Erfinden von Fakten ("Halluzinationen")
- Kein Wissen nach dem Trainings-Stichtag
- Mathematik und exakte Logik können versagen
- Mustererkennung, kein echtes Verständnis

**Toller Assistent - wichtige Aussagen immer prüfen**

---

## Teil 3
### Die Kunst des Promptens

---

## Warum Prompting so wichtig ist

**Dieselbe KI, komplett andere Ergebnisse:**

| Prompt | Ergebnis |
|--------|----------|
| "Schreib mir eine Kunden-E-Mail" | Generisch, ohne Richtung, unbrauchbar |
| "Schreib eine 3-Absatz E-Mail an unsere B2B-Kunden zum neuen Preismodell. Ton: professionell aber freundlich. Erwähne den 15% Frühbucher-Rabatt und schließe mit einem Call-to-Action für eine Demo-Buchung." | Versandfertig, markenkonform, umsetzbar |

**Qualität der Ausgabe = Qualität der Eingabe**

---

## Die 5 Bausteine

1. **Rolle** - *"Du bist ein erfahrener Marketing-Experte"*
2. **Aufgabe** - *"Schreib eine Produktbeschreibung"*
3. **Kontext** - *"Für unser B2B SaaS-Produkt..."*
4. **Format** - *"3 Stichpunkte, max. 50 Wörter pro Punkt"*
5. **Einschränkungen** - *"Kein Fachjargon, formeller Ton"*

**Prompt Engineering ist klare Kommunikation, kein Programmieren**

---

## Schlechte vs. gute Prompts

**Vage:**
> "Hilf mir bei einer Präsentation"

**Engineered:**
> "Erstelle eine 10-Folien-Gliederung für Q4-Ergebnisse. Zielgruppe: C-Level. Enthalten: Umsatzwachstum (+12%), Neukunden (8), 3 Herausforderungen. Stil: datengetrieben, eine Kernaussage pro Folie."

**Tipps:**
- Einfach anfangen, dann iterativ verfeinern
- Zeigt Beispiele von dem was ihr wollt
- Sagt was die KI NICHT tun soll
- Nutzt KI als Sparringspartner

---

## Teil 4
### Die Zukunft: KI-Agenten

---

## Vom Chatbot zum Agenten

**LLM (Chatbot):**
- Ihr: "Finde mir einen Flug nach Berlin für Freitag"
- KI: *"Ich empfehle Lufthansa oder booking.com..."*
- **Ihr macht die ganze Arbeit selbst**

**KI-Agent:**
- Ihr: "Buche mir einen Flug nach Berlin für Freitag"
- Agent: *Prüft Kalender > Sucht Flüge > Vergleicht Preise > Bucht > Bestätigt*
- **Der Agent erledigt die Arbeit**

**Der Wandel: Vom Berater zum Mitarbeiter**

---

## Was einen Agenten anders macht

1. **Ziele verstehen** - Nicht nur Fragen, sondern Aufgaben
2. **Pläne machen** - Komplexe Aufgaben in Schritte aufteilen
3. **Werkzeuge nutzen** - Web durchsuchen, APIs aufrufen, E-Mails senden
4. **Autonom handeln** - Ausführen ohne bei jedem Schritt zu fragen
5. **Anpassen** - Vorgehen ändern wenn etwas nicht klappt

**LLM = Berater der Ratschläge gibt**
**Agent = Mitarbeiter der Dinge erledigt**

---

## Die Agenten-Schleife

**Beobachten** - Was ist die aktuelle Situation?

**Denken** - Was sollte ich als nächstes tun?

**Handeln** - Ein Werkzeug nutzen, etwas schreiben

**Reflektieren** - Hat es funktioniert?

**Wiederholen** - Bis das Ziel erreicht ist

Genau so funktioniert Claude Code - Ziel vorgeben, es plant, schreibt Code, testet, behebt Fehler und liefert.

---

## Agenten in Aktion

**Coding Agents** - Schreiben, testen und debuggen Code selbstständig
*Claude Code, GitHub Copilot Workspace*

**Research Agents** - Dutzende Quellen durchsuchen, Berichte erstellen
*Deep Research, Perplexity*

**Business Agents** - Rechnungen verarbeiten, Systeme überwachen, Berichte erstellen

---

## Wohin die Reise geht

**Was kommt:**
- Multi-Agenten-Teams (einer recherchiert, einer schreibt, einer prüft)
- Agenten integriert in jedes Software-Tool
- Persönliche KI-Assistenten die eure Vorlieben kennen
- KI die komplette Workflows übernimmt

**Was bleibt:**
- Menschliches Urteilsvermögen bei wichtigen Entscheidungen
- Kreativität und Empathie bleiben einzigartig menschlich

**Die Zukunft ist Mensch + KI, nicht Mensch gegen KI**

---

## Die wichtigsten Erkenntnisse

**Der KI-Stack:**
**Generative KI** &rarr; **LLMs** &rarr; **KI-Agenten**
Jede Ebene baut auf der darunter auf

**Fangt heute an:**
1. Probiert ChatGPT oder Claude für tägliche Aufgaben
2. Übt bessere Prompts zu schreiben
3. Prüft wichtige Ausgaben immer gegen
4. Teilt was funktioniert mit eurem Team

**Wer lernt mit KI zu arbeiten, wird einen deutlichen Vorteil haben**

---

## Fragen?

**Vielen Dank!**

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
Ziel verstehen &rarr; Planen &rarr; Code schreiben &rarr; Testen &rarr; Liefern

---

## Bonus: Kostenloses Hosting für eure Projekte
### Einfach online stellen - kostenlos!

| Plattform | Ideal für | Gratis-Angebot |
|-----------|-----------|----------------|
| **Vercel** | Next.js, React, statische Seiten | Unbegrenzt Seiten, Serverless Functions |
| **Netlify** | Statische Seiten, JAMstack | 100 GB Bandbreite/Monat |
| **GitHub Pages** | Statische Seiten, Docs | Unbegrenzt für öffentliche Repos |
| **Cloudflare Pages** | Jedes Frontend, globales CDN | Unbegrenzte Bandbreite |
| **Railway** | Backend-Apps, Datenbanken | $5 Gratis-Guthaben/Monat |
| **Fly.io** | Container, Full-Stack-Apps | 3 Shared VMs kostenlos |

**Mit KI etwas gebaut? Stellt es heute online - keine Kreditkarte nötig!**
