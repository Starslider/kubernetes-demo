# AI Agents Workshop
## Understanding Agentic AI and Modern AI Systems

A Non-Technical Introduction

---

## What We'll Explore Today

- What is Generative AI?
- Understanding Large Language Models (LLMs)
- What is Agentic AI?
- Key Differences Between These Technologies
- Real-World Applications
- The Future of AI Agents

---

## Section 1
### What is Generative AI?

---

## Before We Begin: AI in Context

**Artificial Intelligence (AI):** Technology that mimics human intelligence

**Types of AI:**
- Rule-based systems (if-then logic)
- Machine Learning (learns from data)
- **Generative AI** (creates new content)

**Today's focus:** The newest wave of AI that creates, not just analyzes

---

## What is Generative AI?

**Definition:** AI that can create new content that didn't exist before

**What it generates:**
- Text (articles, emails, code)
- Images (art, photos, designs)
- Audio (music, voices, sounds)
- Video (animations, scenes)
- 3D models and more

**Key insight:** It doesn't just classify or predict—it **creates**

---

## How Did We Get Here?

**Traditional AI (2010s):**
- "Is this a cat or dog?" (Classification)
- "Will this customer buy?" (Prediction)
- "What word comes next?" (Completion)

**Generative AI (2020s+):**
- "Write me a story about a cat"
- "Design a logo for my business"
- "Create a marketing campaign"

**The shift:** From analyzing to creating

---

## The Breakthrough: Neural Networks

**Simple analogy:**

Traditional software: Recipe (exact steps)
- If input = A, then output = B

Neural networks: Learning by example
- Show it 1000 cat pictures
- It learns what "cat-ness" looks like
- Can now recognize OR generate cats

**The magic:** Patterns learned from massive data

---

## Generative AI Examples You Know

**ChatGPT / Claude**
- Write essays, explain concepts, answer questions

**DALL-E / Midjourney / Stable Diffusion**
- Generate images from text descriptions

**GitHub Copilot**
- Write code from natural language

**Synthesia / D-ID**
- Generate video avatars that speak

---

## How Generative AI Works (Simplified)

1. **Training:** Learn patterns from billions of examples
   - Read millions of books, articles, websites
   - Study millions of images
   - Analyze millions of conversations

2. **Understanding:** Build internal "knowledge" of patterns
   - What words usually go together?
   - What makes an image look realistic?
   - How do humans structure arguments?

3. **Generating:** Create new content following those patterns
   - Not copying—creating something new
   - Following learned "rules" of good content

---

## What Generative AI Can Do

**Strengths:**
- Create content at scale and speed
- Multiple variations quickly
- Consistent quality baseline
- Available 24/7
- No creative blocks

**Limitations:**
- Can make factual errors ("hallucinations")
- No true understanding or consciousness
- Reflects biases in training data
- Limited to patterns it has seen
- Can't verify its own accuracy

---

## Section 2
### Understanding Large Language Models (LLMs)

---

## What is a Large Language Model?

**LLM:** A specific type of Generative AI focused on language

**"Large" means:**
- Trained on enormous amounts of text (internet-scale)
- Billions or trillions of parameters (adjustable values)
- Requires massive computing power

**"Language Model" means:**
- Understands and generates human language
- Predicts what text should come next
- Can translate, summarize, answer questions

---

## Popular LLMs You May Know

**GPT (Generative Pre-trained Transformer)**
- GPT-4, GPT-3.5 (powers ChatGPT)
- Created by OpenAI

**Claude**
- Created by Anthropic
- Known for longer conversations

**Gemini**
- Created by Google
- Multimodal (text, images, code)

**LLaMA**
- Created by Meta
- Open-source foundation

---

## How Do LLMs Work?

**Training Phase (Months, $$$):**
1. Feed massive text datasets
2. Learn patterns: "After 'The cat sat on the' usually comes 'mat'"
3. Build statistical model of language
4. Fine-tune for helpfulness and safety

**Generation Phase (Seconds):**
1. You provide a prompt: "Explain photosynthesis"
2. Model predicts next most likely words
3. Continues until it forms complete response
4. Applies safety filters

**Not magic:** Very sophisticated pattern matching at massive scale

---

## Tokens: The Currency of LLMs

**Token:** A chunk of text (roughly 4 characters or 3/4 of a word)

**Example:**
- "Hello, world!" = ~4 tokens
- This slide = ~50 tokens

**Why it matters:**
- LLMs have token limits (e.g., 128K tokens = ~100K words)
- Costs often based on tokens processed
- More tokens = more context but higher cost

**Think of it as:** Word budget for AI conversations

---

## What LLMs Excel At

**Natural Language Tasks:**
- Answering questions
- Summarizing documents
- Writing content (emails, reports, stories)
- Translation between languages
- Explaining complex topics simply
- Brainstorming ideas

**Code and Technical:**
- Writing and debugging code
- Explaining technical concepts
- Data analysis and formatting
- API documentation

---

## What LLMs Struggle With

**Current Limitations:**
- **Hallucinations:** Making up facts confidently
- **No real-time data:** Knowledge cutoff dates
- **Math/Logic:** Can make calculation errors
- **Consistency:** May contradict itself
- **Context limits:** Can't remember everything
- **No true understanding:** Pattern matching, not reasoning

**Important:** Always verify critical information!

---

## LLM Capabilities Explosion (2022-2025)

**2022:** GPT-3.5 (ChatGPT launch)
- Basic conversations
- Simple tasks

**2023:** GPT-4, Claude 2, Gemini
- Better reasoning
- Longer context
- Multimodal (images + text)

**2024:** Claude 3.5, GPT-4o
- Near-human performance on many tasks
- 200K+ token context windows
- Real-time interactions

**2025:** Agentic capabilities emerge

---

## Section 3
### What is Agentic AI?

---

## From Tools to Agents

**Traditional Software:**
- You tell it every step
- It follows instructions exactly
- No decision-making

**Generative AI / LLMs:**
- You ask it questions
- It generates responses
- Still requires your guidance

**Agentic AI:**
- You give it goals
- It figures out the steps
- Takes actions autonomously

---

## What is an AI Agent?

**Definition:** An AI system that can:
1. Understand a goal
2. Plan steps to achieve it
3. Take actions autonomously
4. Learn from results
5. Adapt its approach

**Key difference:** Agency = ability to act independently

**Analogy:**
- LLM = Expert consultant (gives advice)
- Agent = Employee (does the work)

---

## Anatomy of an AI Agent

**Core Components:**

**1. Perception**
- Understand environment and goals
- Read inputs, context, data

**2. Reasoning**
- Plan approach to achieve goals
- Decide what to do next

**3. Action**
- Use tools and APIs
- Execute tasks in the real world

**4. Memory**
- Remember past interactions
- Learn from experience

---

## Agent vs Non-Agent: Examples

**You ask: "I need to book a restaurant for Friday"**

**LLM (Non-Agent):**
- "I'd recommend checking OpenTable. Consider Italian restaurants in your area. Would you like me to suggest some?"
- **You** still do all the work

**Agent:**
- Checks your calendar for Friday
- Searches OpenTable for Italian restaurants
- Finds one with good reviews near you
- Makes reservation for your party size
- Adds it to your calendar
- **Agent** does the work

---

## Real-World Agent Examples

**Customer Service Agents**
- Understand customer issues
- Search knowledge bases
- Generate solutions
- Escalate when needed

**Research Agents**
- Given a topic, research it
- Read multiple sources
- Synthesize findings
- Create reports

**Coding Agents**
- Understand feature request
- Design solution
- Write code
- Test it
- Fix bugs

---

## Types of AI Agents

**Single-Purpose Agents**
- Focused on one task (e.g., email sorting)
- Highly specialized

**Multi-Purpose Agents**
- Can handle various tasks
- General-purpose assistants

**Multi-Agent Systems**
- Multiple agents working together
- Each with specialized role
- Coordinate to solve complex problems

---

## Agent Capabilities: What They Can Do

**Tool Use:**
- Call APIs and web services
- Query databases
- Run calculations
- Send emails/messages

**Reasoning:**
- Break down complex problems
- Chain thoughts together
- Evaluate options

**Planning:**
- Create multi-step plans
- Adapt when plans fail
- Optimize approaches

**Learning:**
- Improve from feedback
- Remember preferences
- Refine strategies

---

## The Agent Loop

**Typical agent workflow:**

1. **Observe:** What's the current situation?
2. **Think:** What should I do next?
3. **Act:** Execute an action using tools
4. **Reflect:** Did that work? What did I learn?
5. **Repeat:** Continue until goal achieved

**This is the "agentic" behavior:** Acting autonomously toward a goal

---

## Section 4
### Key Differences: Generative AI vs LLMs vs Agents

---

## Comparison Overview

| Aspect | Generative AI | LLMs | Agentic AI |
|--------|---------------|------|------------|
| **Scope** | Creates content | Focuses on language | Takes actions |
| **Interaction** | One-off generation | Conversation | Goal-oriented |
| **Agency** | None | Low | High |
| **Tools** | No external tools | Limited | Full tool access |
| **Planning** | No planning | Basic | Advanced |

---

## Generative AI: The Foundation

**What it is:**
- Broad category of AI that creates content
- Includes image, audio, video, text generation

**How you use it:**
- Provide a prompt
- Get a result
- No multi-step interaction needed

**Examples:**
- Generate an image
- Create a music track
- Write a single paragraph

**Think of it as:** A creative tool

---

## LLMs: The Conversationalist

**What it is:**
- Specialized generative AI for language
- Can have multi-turn conversations

**How you use it:**
- Ask questions
- Get explanations
- Refine through dialogue

**Examples:**
- ChatGPT answering questions
- Claude explaining concepts
- Gemini helping with research

**Think of it as:** An intelligent assistant who talks

---

## Agentic AI: The Doer

**What it is:**
- AI that takes autonomous actions toward goals
- Uses LLMs + tools + planning + memory

**How you use it:**
- State your goal
- Agent figures out how
- Takes actions on your behalf

**Examples:**
- Research agent gathering information
- Coding agent building features
- Booking agent making reservations

**Think of it as:** An AI employee

---

## Evolution Timeline

**Phase 1: Generative AI (2020-2022)**
- "Generate an image of a sunset"
- Single output, no iteration

**Phase 2: LLMs (2022-2024)**
- "Help me brainstorm vacation ideas"
- Conversational, iterative refinement

**Phase 3: Agentic AI (2024+)**
- "Plan my vacation to Japan next summer"
- Agent books flights, hotels, creates itinerary

**The progression:** Creation → Conversation → Action

---

## The Stack: How They Relate

**Bottom Layer: Generative AI**
- Core technology for creating content
- Foundational capability

**Middle Layer: LLMs**
- Specialized for language understanding/generation
- Powers conversations

**Top Layer: Agentic AI**
- Uses LLMs for reasoning
- Adds tools, planning, memory
- Takes autonomous actions

**They're not separate:** Agents are built **on top of** LLMs, which are **a type of** Generative AI

---

## When to Use What?

**Use Generative AI when:**
- You need a single creative output
- Quick generation is the goal
- No iteration needed

**Use LLMs when:**
- You need explanations or advice
- Conversational refinement helps
- No actions required

**Use Agentic AI when:**
- You have a goal, not just a question
- Multiple steps needed
- You want autonomous execution
- Tool/API access required

---

## Section 5
### Real-World Applications

---

## Agents in Customer Support

**The Problem:**
- Customers need help 24/7
- Questions are repetitive
- Human agents are expensive

**The Agent Solution:**
- Understands customer questions
- Searches knowledge base
- Provides personalized answers
- Escalates complex issues
- Learns from interactions

**Impact:** 70% of queries handled autonomously

---

## Agents in Software Development

**The Problem:**
- Writing code is time-consuming
- Bugs need debugging
- Documentation often lacking

**The Agent Solution:**
- Understands feature requests in plain language
- Writes code in multiple languages
- Runs tests automatically
- Fixes bugs
- Generates documentation

**Examples:** GitHub Copilot, Cursor, Claude Code

---

## Agents in Research

**The Problem:**
- Information overload
- Need to synthesize multiple sources
- Time-consuming to read everything

**The Agent Solution:**
- Given a research topic
- Searches multiple sources
- Reads and analyzes papers/articles
- Synthesizes findings
- Creates comprehensive reports

**Impact:** Days of research → Hours

---

## Agents in Business Operations

**Finance Agents:**
- Process expense reports
- Categorize transactions
- Flag anomalies
- Generate financial reports

**HR Agents:**
- Screen resumes
- Schedule interviews
- Answer employee questions
- Onboard new hires

**Marketing Agents:**
- Research competitors
- Generate campaign ideas
- Create content variations
- Analyze performance

---

## Agents in Personal Productivity

**Email Agents:**
- Sort and prioritize emails
- Draft responses
- Schedule meetings
- Follow up on action items

**Calendar Agents:**
- Find meeting times
- Book appointments
- Optimize schedules
- Send reminders

**Travel Agents:**
- Research destinations
- Compare prices
- Book flights and hotels
- Create itineraries

---

## Multi-Agent Systems

**Concept:** Multiple specialized agents working together

**Example: Content Creation Pipeline**
1. **Research Agent:** Gathers information on topic
2. **Writing Agent:** Creates first draft
3. **Editing Agent:** Improves clarity and style
4. **Fact-Checking Agent:** Verifies accuracy
5. **SEO Agent:** Optimizes for search engines

**Why it works:** Specialization + coordination = better results

---

## Emerging Agent Platforms

**Consumer Platforms:**
- ChatGPT with plugins (OpenAI)
- Claude with tools (Anthropic)
- Gemini with extensions (Google)
- Personal AI assistants

**Enterprise Platforms:**
- AutoGPT (autonomous research)
- LangChain (agent frameworks)
- Semantic Kernel (Microsoft)
- BabyAGI (task management)

**Development Tools:**
- Agent SDKs and frameworks
- Pre-built agent templates
- Agent orchestration platforms

---

## Section 6
### Capabilities and Limitations

---

## What Agents Can Do Today

**✅ Highly Effective:**
- Information gathering and synthesis
- Content creation with tools
- Process automation with clear rules
- Data analysis and reporting
- Code generation and debugging
- Structured problem-solving

**Why:** Well-defined tasks with clear success criteria

---

## What Agents Struggle With

**⚠️ Current Limitations:**
- Complex decision-making requiring judgment
- Tasks needing deep domain expertise
- Situations with ambiguous goals
- Truly novel problem-solving
- Understanding context and nuance
- Ethical reasoning
- Long-term strategic planning

**Why:** Lack true understanding, rely on patterns

---

## The Hallucination Problem

**What are hallucinations?**
- AI confidently stating false information
- Making up facts, citations, or data
- Generating plausible but incorrect content

**Why it happens:**
- LLMs predict likely text, not truth
- No built-in fact-checking
- Can't distinguish known from unknown

**Mitigation:**
- Give agents tools to verify facts
- Require citations from sources
- Human review of critical outputs
- Confidence scoring systems

---

## Safety and Control

**Concerns:**

**Autonomy Risk:**
- Agents taking unintended actions
- Making mistakes at scale
- Following instructions too literally

**Privacy:**
- Agents accessing sensitive data
- Remembering more than they should

**Reliability:**
- Unexpected failures
- Inconsistent behavior
- "Drift" over time

**Mitigation:** Guardrails, monitoring, human oversight

---

## The Human-in-the-Loop Approach

**Full Autonomy:**
- Agent acts without oversight
- Fast but risky

**Human-in-the-Loop:**
- Agent proposes actions
- Human approves before execution
- Slower but safer

**Best Practice:**
- Low-risk tasks: Autonomous
- Medium-risk: Human review
- High-risk: Human decision-making

**Goal:** Right balance of speed and safety

---

## Measuring Agent Success

**Metrics to Track:**

**Performance:**
- Task completion rate
- Time to completion
- Error rate

**Quality:**
- Accuracy of outputs
- User satisfaction
- Need for human intervention

**Efficiency:**
- Cost per task
- Resource utilization
- Scalability

---

## Section 7
### The Future of AI Agents

---

## Current State (2025)

**Where we are:**
- Agents handle well-defined tasks
- Require clear instructions
- Limited tool use
- Short-term memory
- Narrow domain expertise

**Reality check:** Very capable assistants, not AGI

**Analogy:** Smart interns, not experienced managers

---

## Near-Term Future (2025-2027)

**Expected advances:**
- Better reasoning and planning
- Longer memory (remember entire projects)
- More reliable tool use
- Multi-modal capabilities (text, image, video, audio)
- Improved fact-checking
- Seamless multi-agent collaboration

**Impact:** Handle more complex workflows autonomously

---

## Agent Specialization

**Trend:** Move from generalist to specialist agents

**Industry-Specific Agents:**
- Legal: Contract review, case research
- Medical: Diagnostic assistance, research
- Finance: Risk analysis, compliance
- Engineering: Design, simulation, testing

**Why:** Better accuracy in specialized domains

---

## Agents + Internet of Things (IoT)

**Vision:** Agents controlling physical world

**Examples:**
- Smart home agents managing energy, security, comfort
- Industrial agents optimizing manufacturing
- Agricultural agents monitoring crops
- Healthcare agents tracking patient vitals

**Requirement:** Better safety and reliability

---

## The Agent Economy

**Emerging concept:** Agents as workers

**How it could work:**
- Agents perform tasks for payment
- Marketplace of specialized agents
- Agents hiring other agents
- Reputation systems for agents

**Questions:**
- How do we value agent work?
- Who's liable for agent mistakes?
- How do humans compete?

---

## Ethical Considerations

**Key Questions:**

**Autonomy:** How much should we trust agents?

**Accountability:** Who's responsible for agent actions?

**Transparency:** Should agents disclose they're AI?

**Bias:** How do we prevent discrimination?

**Job Impact:** What happens to displaced workers?

**Control:** Can we maintain oversight at scale?

---

## Paths to More Capable Agents

**Technical Improvements:**
- Better reasoning models
- Improved memory systems
- More reliable tool use
- Better planning algorithms
- Enhanced safety mechanisms

**Infrastructure:**
- Faster, cheaper compute
- Better agent frameworks
- Standardized tool interfaces
- Agent monitoring systems
- Evaluation benchmarks

---

## What to Expect in Your Work

**Short-term (Now - 2026):**
- AI assistants for routine tasks
- Copilots for complex work
- Automation of repetitive processes

**Medium-term (2026-2028):**
- Agents handling entire workflows
- Personalized AI teammates
- Significant productivity gains

**Adaptation needed:**
- Learn to work alongside agents
- Focus on uniquely human skills
- Supervise and guide agent work

---

## Skills for the Agent Era

**Technical Skills:**
- Prompt engineering
- Agent configuration
- Tool integration
- Basic understanding of AI capabilities/limits

**Human Skills:**
- Creative problem-solving
- Emotional intelligence
- Ethical judgment
- Strategic thinking
- Critical evaluation of AI outputs

**Hybrid Skills:**
- Knowing when to use AI vs human judgment
- Effective human-agent collaboration

---

## Opportunities and Challenges

**Opportunities:**
- Massive productivity gains
- New creative possibilities
- Democratization of expertise
- Solving previously intractable problems
- New jobs and industries

**Challenges:**
- Workforce disruption
- Privacy and security risks
- Dependence on AI systems
- Bias and fairness concerns
- Need for governance and regulation

---

## Section 8
### Practical Takeaways

---

## Understanding the Landscape

**Remember:**

**Generative AI** = Technology that creates content
- Broad category, many applications

**LLMs** = AI that understands and generates language
- Conversational, helpful for explanations

**Agentic AI** = AI that takes autonomous actions
- Goal-oriented, uses tools, multi-step

**They build on each other:** Agents use LLMs, LLMs are generative AI

---

## Getting Started with AI

**For Individuals:**
1. Experiment with ChatGPT, Claude, or Gemini
2. Use AI for daily tasks (writing, research, learning)
3. Learn prompt engineering basics
4. Understand limitations and verify outputs

**For Teams:**
1. Identify repetitive, time-consuming tasks
2. Pilot AI tools for specific use cases
3. Train team on effective AI use
4. Establish guidelines for AI usage

---

## Best Practices for Using AI Agents

**Do:**
- Start with well-defined tasks
- Provide clear goals and constraints
- Review agent outputs critically
- Iterate and refine prompts
- Use human judgment for important decisions

**Don't:**
- Blindly trust agent outputs
- Use for high-stakes decisions without review
- Share sensitive information unnecessarily
- Expect perfect accuracy
- Replace human oversight entirely

---

## Staying Informed

**The field moves fast:**
- New models every few months
- Capabilities constantly improving
- Best practices evolving

**How to keep up:**
- Follow AI news sources
- Experiment with new tools
- Join AI communities
- Take online courses
- Learn from use cases in your industry

---

## Questions to Consider

**For Your Role:**
- How could AI agents help with your daily work?
- What tasks are repetitive and rule-based?
- Where do you need to maintain human judgment?

**For Your Organization:**
- What processes could benefit from agents?
- What are the risks and how to mitigate them?
- How do we prepare our workforce?

**For Society:**
- How do we ensure fair and ethical AI use?
- How do we adapt education and training?

---

## The Bottom Line

**AI Agents represent a new paradigm:**

From: **Tools you use**
To: **Assistants that work with you**
To: **Agents that work for you**

**They're not replacing humans (yet):**
- Augmenting human capabilities
- Handling routine work
- Freeing time for higher-value tasks

**Success requires:**
- Understanding capabilities and limits
- Effective collaboration
- Continuous learning

---

## Key Messages to Remember

1. **Generative AI creates**, LLMs converse, Agents act
2. **Agents are still early** but evolving rapidly
3. **Not magic** - sophisticated pattern matching at scale
4. **Human oversight remains essential**
5. **Opportunities outweigh risks** with proper safeguards
6. **The technology is here to stay** - best to engage thoughtfully

---

## Resources for Learning More

**Interactive Learning:**
- ChatGPT / Claude - experiment directly
- Google AI Experiments
- Hugging Face demos

**Courses:**
- DeepLearning.AI (Andrew Ng)
- Fast.ai
- Coursera AI courses

**Communities:**
- AI-focused LinkedIn groups
- Twitter/X AI community
- Reddit r/artificial

**News:**
- The Batch (DeepLearning.AI)
- Import AI newsletter
- AI industry blogs

---

## Questions?

**Thank you for participating in the AI Agents Workshop!**

Key Takeaway: We're at the beginning of the Agent Era—
understanding these technologies now will help you
navigate and thrive in this transformation.

**Let's discuss your questions and explore real-world scenarios**

---

## Bonus: Glossary

**AGI (Artificial General Intelligence):** AI with human-level intelligence across all domains (not yet achieved)

**API (Application Programming Interface):** How software talks to other software

**Context Window:** How much text an LLM can process at once

**Fine-tuning:** Training a model further on specific data

**Hallucination:** When AI generates false information

**Parameters:** The "knobs" AI adjusts during learning (more = more capable)

**Prompt:** The instruction you give to AI

**RAG (Retrieval Augmented Generation):** Giving AI access to external knowledge

**Temperature:** Setting for creativity vs consistency

**Token:** Unit of text processing (≈0.75 words)
