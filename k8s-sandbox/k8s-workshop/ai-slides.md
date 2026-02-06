# AI Agents Workshop
## From Generative AI to Autonomous Agents

A 30-Minute Introduction for Non-Technical Audiences

---

## What We'll Cover Today

1. **What is Generative AI?** - The technology behind the hype
2. **What is an LLM?** - The engine that powers it all
3. **The Art of Prompting** - Why how you ask matters
4. **The Future: AI Agents** - From chatbot to autonomous assistant
5. **Live Demo** - Building a Snake game with AI (if time permits)

---

## Part 1
### What is Generative AI?

---

## The Big Shift in AI

**Traditional AI (2010s):**
- "Is this email spam?" (Classification)
- "Will this machine break down?" (Prediction)
- AI that **analyzes** existing data

**Generative AI (2020s):**
- "Write me a marketing email"
- "Design a logo for my startup"
- "Summarize this 50-page report in 5 bullet points"
- AI that **creates** new content

---

## What Can Generative AI Create?

| Type | Examples | Tools You Might Know |
|------|----------|---------------------|
| **Text** | Articles, emails, code, translations | ChatGPT, Claude |
| **Images** | Art, product photos, designs | Midjourney, DALL-E |
| **Audio** | Music, voice clones, podcasts | Suno, ElevenLabs |
| **Video** | Animations, short clips, avatars | Sora, Runway |
| **Code** | Full applications, scripts, websites | GitHub Copilot, Claude Code |

---

## How Does It Work? (The Simple Version)

**Three steps:**

**1. Training** - Read the internet
- Billions of books, websites, conversations
- Learn patterns: what words, pixels, sounds go together

**2. Understanding** - Build internal "knowledge"
- Not memorizing - recognizing patterns
- Like learning a language by immersion

**3. Generating** - Create something new
- Predicts the most likely next word/pixel/note
- Guided by your instructions (the "prompt")

**Not magic - very sophisticated pattern matching at massive scale**

---

## Part 2
### What is an LLM?

---

## LLM = Large Language Model

**Think of it as autocomplete on steroids:**

You type: *"The cat sat on the..."*

| | Prediction |
|---|---|
| **Phone autocomplete** | "mat" |
| **LLM** | Writes you a full story about the cat, its backstory, and what happens next |

**"Large"** = Trained on enormous text data, billions of parameters

**"Language Model"** = Specialized in understanding and generating human language

**LLMs are a type of Generative AI - focused specifically on language**

---

## The Big Players

**GPT-4o** (OpenAI) - Powers ChatGPT, most well-known

**Claude** (Anthropic) - Strong at reasoning and longer tasks

**Gemini** (Google) - Built into Google products

**LLaMA / DeepSeek** (Meta / DeepSeek) - Open-source models anyone can run

**Grok** (xAI) - Integrated into X/Twitter

All of them: Predict the most likely next words based on your input + their training

---

## What LLMs Are Great At (And Not)

**Strengths:**
- Answering questions and explaining complex topics
- Writing and editing text (emails, reports, code)
- Translating between languages
- Summarizing long documents
- Brainstorming and creative work

**Limitations:**
- Can confidently make up facts ("hallucinations")
- No real-world knowledge after training cutoff
- Math and precise logic can be unreliable
- No true understanding - pattern matching, not thinking

**Rule of thumb:** Great assistant, but always verify important outputs

---

## Part 3
### The Art of Prompting

---

## Why Prompting Matters

**The same AI, completely different results:**

| Prompt | Result |
|--------|--------|
| "Write something about sales" | Generic, vague, useless paragraph |
| "Write a 3-paragraph email to our B2B clients announcing our new pricing model. Tone: professional but friendly. Mention the 15% early-bird discount." | Exactly what you needed, ready to send |

**The quality of the output is directly tied to the quality of your input**

Your prompt is the steering wheel - the AI is the engine.

---

## What is Prompt Engineering?

**Prompt Engineering** = The skill of writing instructions that get the best results from AI

**It's not programming - it's clear communication.**

**The 5 building blocks of a good prompt:**

1. **Role** - Who should the AI be? *"You are a senior marketing expert"*
2. **Task** - What exactly should it do? *"Write a product description"*
3. **Context** - What background info does it need? *"For our B2B SaaS product..."*
4. **Format** - How should the output look? *"3 bullet points, max 50 words each"*
5. **Constraints** - What to avoid? *"No jargon, no emojis, formal tone"*

---

## Bad vs. Good Prompts - Live Examples

**Vague prompt:**
> "Help me with a presentation"

**Engineered prompt:**
> "Create an outline for a 10-slide presentation about our Q4 results. Audience: C-level executives. Include: revenue growth (+12%), new client wins (8), and 3 key challenges. Style: data-driven, concise, one key message per slide."

**Why this works:**
- AI knows the **audience** (executives, not interns)
- AI knows the **scope** (10 slides, Q4)
- AI knows the **data** to include
- AI knows the **style** to follow

**Prompt engineering is the #1 skill for working with AI effectively**

---

## Quick Prompting Tips

**Start simple, then refine:**
- First attempt won't be perfect - and that's fine
- Say "make it shorter", "more formal", "add examples"
- Treat it like a conversation, not a one-shot command

**Give examples of what you want:**
- "Write it in this style: [paste example]"
- Show it the format you expect

**Tell it what NOT to do:**
- "Don't use buzzwords"
- "Don't make up statistics"
- "Don't start every sentence with 'In today's world...'"

**Use it as a thinking partner:**
- "What am I missing in this plan?"
- "Play devil's advocate on this idea"
- "What questions would a skeptical customer ask?"

---

## Part 4
### The Future: AI Agents

---

## From Chatbot to Agent

**LLM (today's chatbot):**
- You: "Find me a flight to Berlin for next Friday"
- ChatGPT: *"I'd recommend checking Lufthansa or booking.com..."*
- **You still do all the work**

**AI Agent (the next step):**
- You: "Book me a flight to Berlin for next Friday"
- Agent: *Checks your calendar > Searches flights > Compares prices > Books the best option > Adds to your calendar > Sends you confirmation*
- **The agent does the work for you**

**The shift: From advisor to employee**

---

## What Makes an Agent Different?

**An AI Agent can:**

1. **Understand goals** - Not just questions, but objectives
2. **Make plans** - Break complex tasks into steps
3. **Use tools** - Browse the web, call APIs, send emails, write files
4. **Act autonomously** - Execute without asking for every step
5. **Learn and adapt** - Adjust when something doesn't work

**Analogy:**
- LLM = Expert consultant who gives advice
- Agent = Employee who gets things done

---

## The Agent Loop

**How agents work - a continuous cycle:**

**Observe** - What's the current situation?

**Think** - What should I do next?

**Act** - Use a tool, make a call, write something

**Reflect** - Did it work? What changed?

**Repeat** - Until the goal is achieved

This is exactly how Claude Code works - you give it a goal, it plans, writes code, tests it, fixes bugs, and delivers.

---

## Agents in Action - Real Examples

**Coding Agents (available now):**
- Understand feature requests in plain language
- Write, test, and debug code autonomously
- Example: Claude Code, GitHub Copilot Workspace

**Research Agents:**
- Given a topic, search dozens of sources
- Synthesize findings into structured reports
- Fact-check across multiple references

**Business Process Agents:**
- Process invoices and expense reports
- Monitor systems and alert on issues
- Generate weekly reports from raw data

---

## Where This Is Heading (2026-2028)

**What's coming:**
- Agents that manage your calendar and email
- Multi-agent teams (one researches, one writes, one reviews)
- Agents integrated into every software tool
- Personal AI assistants that truly know your preferences
- AI that handles entire workflows end-to-end

**What stays the same:**
- Human judgment for important decisions
- Creativity and empathy remain uniquely human
- "Human-in-the-loop" for high-stakes actions

**The future is human + AI, not human vs. AI**

---

## Part 5
### Key Takeaways

---

## The AI Stack in One Picture

**Generative AI** = The foundation - AI that creates content
&darr;
**LLMs** = Specialized for language - powers conversations
&darr;
**AI Agents** = The next level - AI that takes autonomous action

**Each layer builds on the one below**

---

## What You Can Do Today

**Start experimenting:**
1. Try ChatGPT or Claude for daily tasks
2. Use AI to draft emails, summarize documents, brainstorm
3. Always verify important outputs
4. Share what works with your team

**Think about your work:**
- What tasks are repetitive?
- Where do you spend time on routine work?
- What would you do with 2 extra hours per day?

**The people who learn to work with AI will have a significant advantage**

---

## Questions?

**Thank you for your time!**

Let's discuss how AI might impact your work.

**Try it yourself:**
- claude.ai - Try Claude
- chatgpt.com - Try ChatGPT
- midjourney.com - Try image generation

---

## Bonus: Live Demo
### Building a Snake Game with Claude Code

*Let's see an AI agent in action!*

One prompt. One AI agent. A fully playable Snake game - built live in under 2 minutes.

**Watch for the agent loop:**
Understand goal > Plan approach > Write code > Test > Deliver
