# AI Agents Workshop
## From Generative AI to Autonomous Agents

---

## What We'll Cover Today

1. **What is Generative AI?** - The technology behind the hype
2. **What is an LLM?** - The engine that powers it all
3. **The Art of Prompting** - Why how you ask matters
4. **The Future: AI Agents** - From chatbot to autonomous assistant
5. **Live Demo** - Building a Snake game with AI

---

## Part 1
### What is Generative AI?

---

## The Big Shift in AI

**Traditional AI (2010s):**
- "Is this email spam?" → Classification
- "Will this machine break?" → Prediction
- AI that **analyzes** existing data

**Generative AI (2020s):**
- "Write me a marketing email"
- "Summarize this 50-page report"
- AI that **creates** new content

---

## What Can Generative AI Create?

| Type | Examples | Tools |
|------|----------|-------|
| **Text** | Articles, emails, code | ChatGPT, Claude |
| **Images** | Art, designs, photos | Midjourney, DALL-E |
| **Audio** | Music, voice clones | Suno, ElevenLabs |
| **Video** | Animations, clips | Sora, Runway |
| **Code** | Apps, scripts, websites | Copilot, Claude Code |

---

## How Does It Work?

**1. Training** - Read billions of books, websites, conversations

**2. Understanding** - Recognize patterns (not memorizing)

**3. Generating** - Predict the most likely next word/pixel/note

**Not magic - sophisticated pattern matching at massive scale**

---

## Part 2
### What is an LLM?

---

## LLM = Large Language Model

**Autocomplete on steroids:**

You type: *"The cat sat on the..."*

| | Prediction |
|---|---|
| **Phone autocomplete** | "mat" |
| **LLM** | Writes a full story about the cat and what happens next |

**"Large"** = Billions of parameters trained on enormous data

**"Language Model"** = Specialized in human language

---

## The Big Players

**GPT-4o** (OpenAI) - Powers ChatGPT

**Claude** (Anthropic) - Strong at reasoning and longer tasks

**Gemini** (Google) - Built into Google products

**LLaMA / DeepSeek** (Meta / DeepSeek) - Open-source

**Grok** (xAI) - Integrated into X/Twitter

All predict the most likely next words based on input + training

---

## Strengths & Limitations

**Great at:**
- Explaining complex topics
- Writing and editing (emails, reports, code)
- Translating and summarizing
- Brainstorming and creative work

**Watch out for:**
- Confident fabrications ("hallucinations")
- No knowledge after training cutoff
- Math and precise logic can fail
- Pattern matching, not true understanding

**Great assistant - always verify important outputs**

---

## Part 3
### The Art of Prompting

---

## Why Prompting Matters

**Same AI, completely different results:**

| Prompt | Result |
|--------|--------|
| "Write something about sales" | Generic, vague, useless |
| "Write a 3-paragraph email to B2B clients about our new pricing. Professional but friendly. Mention the 15% early-bird discount." | Ready to send |

**Output quality = Input quality**

---

## The 5 Building Blocks

1. **Role** - *"You are a senior marketing expert"*
2. **Task** - *"Write a product description"*
3. **Context** - *"For our B2B SaaS product..."*
4. **Format** - *"3 bullet points, max 50 words each"*
5. **Constraints** - *"No jargon, formal tone"*

**Prompt engineering is clear communication, not programming**

---

## Bad vs. Good Prompts

**Vague:**
> "Help me with a presentation"

**Engineered:**
> "Create a 10-slide outline for Q4 results. Audience: C-level. Include: revenue growth (+12%), new clients (8), 3 challenges. Style: data-driven, one message per slide."

**Pro tips:**
- Start simple, then refine iteratively
- Give examples of what you want
- Tell it what NOT to do
- Use it as a thinking partner

---

## Part 4
### The Future: AI Agents

---

## From Chatbot to Agent

**LLM (chatbot):**
- You: "Find me a flight to Berlin for Friday"
- AI: *"I'd recommend checking Lufthansa..."*
- **You still do all the work**

**AI Agent:**
- You: "Book me a flight to Berlin for Friday"
- Agent: *Checks calendar > Searches flights > Compares prices > Books > Confirms*
- **The agent does the work**

**The shift: From advisor to employee**

---

## What Makes an Agent Different?

1. **Understand goals** - Not just questions, but objectives
2. **Make plans** - Break complex tasks into steps
3. **Use tools** - Browse web, call APIs, send emails
4. **Act autonomously** - Execute without asking every step
5. **Adapt** - Adjust when something doesn't work

**LLM = Consultant who gives advice**
**Agent = Employee who gets things done**

---

## The Agent Loop

**Observe** - What's the situation?

**Think** - What should I do next?

**Act** - Use a tool, write something

**Reflect** - Did it work?

**Repeat** - Until the goal is achieved

This is exactly how Claude Code works - give it a goal, it plans, codes, tests, fixes, and delivers.

---

## Agents in Action

**Coding Agents** - Write, test, and debug code autonomously
*Claude Code, GitHub Copilot Workspace*

**Research Agents** - Search dozens of sources, synthesize reports
*Deep Research, Perplexity*

**Business Agents** - Process invoices, monitor systems, generate reports

---

## Where This Is Heading

**Coming soon:**
- Multi-agent teams (one researches, one writes, one reviews)
- Agents integrated into every software tool
- Personal AI assistants that know your preferences
- AI handling entire workflows end-to-end

**What stays:**
- Human judgment for important decisions
- Creativity and empathy remain uniquely human

**The future is human + AI, not human vs. AI**

---

## Key Takeaways

**The AI Stack:**
**Generative AI** &rarr; **LLMs** &rarr; **AI Agents**
Each layer builds on the one below

**Start today:**
1. Try ChatGPT or Claude for daily tasks
2. Practice writing better prompts
3. Always verify important outputs
4. Share what works with your team

**People who learn to work with AI will have a significant advantage**

---

## Questions?

**Thank you!**

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
Understand goal &rarr; Plan &rarr; Write code &rarr; Test &rarr; Deliver
