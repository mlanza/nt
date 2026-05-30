# Note

**Note** is a command line tool for managing text content — skills, commands, prompts, rules, knowledge, whatever the flavor — in a local [Logseq](https://logseq.com) repo.  Unlike MCP, CLIs are ephemeral, composeable and available to humans 🧔🏼 and agents 🤖 alike.

<p align="center">
  <img src="./images/logo.png" style="width: 300px; max-width: 100%;" />
</p>

Your local-first commonplace book 📖 is memory scaffolding, a near perfect spot for accessing and keeping the information and instructions an agent needs to thrive — all in an ubiquitous language of your making.  How better to align with and teach an agent your craft than by sharing your second 🧠 with it.

nt keeps that knowledge modular and portable. Each Logseq page becomes a reusable chunk of instruction, a term you can drop into a prompt, and a reminder of how you prefer to work. The tool mediates between you and your agent, transmits that craft without surprises.

I built it to minimize ceremony, to compose, and to mind the Unix philosophy.  That’s why subcommands frequently take the primary operand directly or receive it via stdin.

<details>
  <summary><code>nt --help</code></summary>

```console
Usage:   nt
Version: 1.0.0-beta

Description:

  A general-purpose tool for interacting with Logseq content.

   📨 = supply primary argument directly or pipe them in
   📥 = pipeline-only operations

Options:

  -h, --help     - Show this help.
  -V, --version  - Show the version number for this program.

Commands:

  pages                                   - List pages
  page, p         [name|datestamp]        - Get page 📨
  post            [name] [content]        - Sends content to page or, if omitted, to today's journal entry 📥
  write           <name>                  - Write page from stdin
  wipe            [name]                  - Wipe content, but not properties, from a page
  export          <name>                  - Export page content to destination
  tags, t         [tags...]               - List pages with all the given tags 📨
  has, h          [prop] [vals...]        - List pages having a given prop with value(s) 📨
  prereq          [name]                  - Recursively list page prerequisites 📨
  path            [name]                  - The path to the page file 📨
  props           [name] [properties...]  - Get page properties 📨
  search, s       [term]                  - Search pages 📨
  name, n         [id|name]               - Get page name as cased from page ID or case-insensitive name. 📨
  alias           [alias]                 - Get page name from alias 📨
  backlinks, b    [name]                  - List pages that link to a given page 📨
  query, q        <query> [args...]       - Run Datalog query supplying args 📨
  list, l         [item...]               - List items
  day, d          [offset]                - Find date from offset 📨
  skills                                  - List skills and their descriptions
  about, a        [name...]               - Retrieves information about a topic including prequisites
  prompt                                  - Expands wikilinks in a prompt, ignoring fenced code blocks 📨
  prop            📥                      - Rewrite page properties
  parse           📥                      - Convert flat markdown to structured blocks
  stringify, str  📥                      - Convert structured blocks back to markdown
  seen            📥                      - Filters to seen lines
  exists          📥                      - Filters paths for existing files
  links           📥                      - Extracts links from content
  wikilinks       📥                      - Extracts wikilinks from content
  sections        📥                      - Filter content by Markdown section names
  clean           📥                      - Clean invisible and zero-width control characters
  config                                  - Show configuration
```

</details>

## Conjuring and Composing Context

You gain a suite of commands for retrieving and reusing carefully-crafted context:

```zsh
nt page Atomic
```

Those commands make your ubiquitous language — the concepts, rules, workflows, and skills you’re always refining — portable.  Your context travels with you *wherever you are*, whether in Pi, OpenCode, Gemini, or Claude Code.  Conjure it into conversations.

Slip wikilinks into prompts and, once prompt expansion is installed, the Pi adapter expands them automatically.  Try this:

```md
You are [[Coding]] a Sokoban game using [[Atomic]].
```

The adapter pulls in the Coding page, the Atomic page, and the prerequisites of both — recursively.  That turns Logseq into a first-class, local-first retrieval system you can control.

> 💡 As a rule of thumb, I name skills using gerunds — sometimes a single word like Coding or Debugging, other times a more specific gerund phrase like Writing Documentation or Planning Releases. I treat skills as recurring activities or modes of work: practices worth refining and reusing.

**Prerequisites** are the backbone, a lightweight form of inheritance.  Concepts build on other concepts, recursively pulling in the necessary context.  Prompting, in turn, becomes an act of composition: combining modular pieces of language, craft, and instruction deliberately.

Unlike some [RAG](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) systems, things are kept transparent and predictable.  You’re not guessing what system prompt or retrieval process an agent is using.  You’re designing pages and their connections so that in every chat context combines in predictable ways.  You decide exactly what enters the conversation.

You engineer the blocks, define their prerequisites, so that when you type a prompt it expands into the instructions you meant to give.  This feels powerful, like uttering an incantation.  Thus the word: **conjure**.

## Getting Started

Install it in a preferred location:

```zsh
git clone https://github.com/mlanza/nt.git ~/.local/share/nt
```

Set `nt` on path in your profile:

```zsh
export PATH="$HOME/.local/share/nt/bin:$PATH"
```

Set these env vars:

* **LOGSEQ_REPO** - path to the Logseq repo
* **LOGSEQ_ENDPOINT** - HTTP API endpoint (default is http://127.0.0.1:12315/api)
* **LOGSEQ_TOKEN** - a token you configured for the HTTP API
* **NOTE_CONFIG** - path to optional config (e.g., `~/.config/nt/config.toml`)

The config file, in addition to providing an alternate means to setting `repo`, `endpoint`, and `token`, is useful for [content filtering](#content-filtering).

```toml
# config.toml
[logseq]
repo = '~/Documents/notes' # on Windows: 'D:\notes'
endpoint = 'http://127.0.0.1:12315/api'
token = 'mellon'
```

Ensure `pwsh` and `deno` are installed.

Run Logseq in Developer Mode.  Flip it on under `Settings > Advanced`.  Then enable the local HTTP API via the button in the upper right. You must [set up a token](https://wiki.jamesravey.me/books/software-misc/page/logseq-http-api).  This setup and tooling transforms Logseq into a lightweight MCP server.

## Going Deeper

Think of Logseq as the local-first hub where you compose engineered chunks — pages, prerequisites, filters, skill descriptors. `nt` provides the plumbing that lets you drop the right term into a prompt and expect the context you engineered to arrive. Prompt expansion is the lever that delivers that.

### Prompt Expansion

Install the feature, and every wikilink you drop into a prompt expands into the pages you engineered, their prerequisites, and the prerequisites of those prerequisites. The result are predictable.

#### Pi (π)

Point the agent at your `nt` installation:

```zsh
pi install ~/.local/share/nt/adapters/pi/nt.js
```

### Generating `AGENTS.md`

You don’t have to write an epic `AGENTS.md`. If your Logseq pages are modular, conjure context when an activity comes up. I keep my `AGENTS.md` to the essentials:

```md
# Agent Instructions
prerequisites:: [[Ubiquitous Language]], [[Director]]
Your chief aim is aligning yourself with and serving the [[Director]].  It helps to understand his values and methodology.  Recognizing and looking up the [[Ubiquitous Language]] by which he communicates aids this.
```

I refresh it now and then so I don’t have to repeat the basics:

```zsh
nt about "Agent Instructions" | nt document --para | cat -s
```

The ubiquitous language I mention are the terms and phrases in my catalog of Logseq pages. The page about **Ubiquitous Language**, for instance, links to a prerequisite skill that tells the agent how to navigate terms using `nt`.

While I code routinely, I don’t mention **Coding** inside `AGENTS.md`.  When it’s time to code, the mere mention of the word — like the one in the intro — conjures context tailor-made to the activity:

```md
# Coding
tags:: AI, Skill, [[Command Line]], [[Atomic Way]]
prerequisites:: [[Designing for Validation]], [[Keeping a Notepad]], [[Ensuring Reversibility]], [[Delivering in Baby Steps]], [[Core Docs]]
description:: Use when developing or debugging a program or an app.
You are [[Keeping a Notepad]] and [[Ensuring Reversibility]] while [[Delivering in Baby Steps]].
```

Each piece of that prompt links to some recursively-expanded skill or context.  **Ensuring Reversibility** explains using `git` as a safety net for all filesystem changes.

Forget tracking skills in the filesystem the way most agent runtimes prescribe.  Logseq subsumes skills, commands and most other jobs since everything agents do, more or less, relies on putting the right context in front of them at the right time.

### Progressive Disclosure

Want to show the capabilities at your disposal? Create a Logseq page called `Skill`, define pages, tag them `Skill`, and add a `description` property.

Once you have a handful in place, list them with:

```zsh
nt skills
```

To see what a specific skill brings, look at its properties:

```zsh
nt props Coding
```

```md
# Coding
tags:: AI, Skill, [[Command Line]], [[Atomic Way]]
prerequisites:: [[Designing for Validation]], [[Keeping a Notepad]], [[Ensuring Reversibility]], [[Delivering in Baby Steps]], [[Core Docs]]
description:: Use when developing or debugging a program or an app.
```

The `description` cues an agent into the contexts in which a skill becomes useful.  By handing an agent a skill for accessing Logseq content via `nt`, it decides when to read up and employ needed skills.

### Prerequisites

Prerequisites are how you engineer context once and rely on it everywhere. Every page that needs supporting concepts links to them with a `prerequisites` property, so when `nt about` or prompt expansion runs, the required layers arrive automatically. No guessing what background the agent needs; you define it once and prompt expansion conjures it for every session.

The `nt prompt` command provides in the shell what the adapter provides in Pi:

```zsh
nt prompt "You are [[Coding]] a Sokoban game using [[Atomic]]."
```

You can also supply one or more `--skill` flags, and `nt` crafts a prompt like `You are [[Extracting Wisdom]] and [[Taking Notes]].`

```zsh
nt prompt --skill "Extracting Wisdom" --skill "Taking Notes"
```

The command recognizes terms. If it merely listed pages it’d call:

```zsh
nt list Coding Atomic | nt page
```

You’d only get the two pages. But `nt about` goes farther:

```zsh
nt list Coding Atomic | nt about
```

It recursively expands each page’s prerequisites.  That’s the linchpin to delivering engineered context.

### Content Filtering

The default way to read a page is `nt page`:
```zsh
nt page Atomic
```

My Logseq repo mixes [PKM](https://en.wikipedia.org/wiki/Personal_knowledge_management) notes with [GTD](https://en.wikipedia.org/wiki/Getting_Things_Done) tasks, links, and project instructions. Not every block should reach an agent. It’s not about secrecy; it’s about not confusing it with context it was never meant to see.

`nt` filters at the block level. A filtered block brings its children along. If a block is on your no-go list, so is everything it nests.

Here are a couple quick tweaks:

```zsh
nt page Atomic --less '^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)'
```

```zsh
nt page Atomic --only '^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)'
```

Stacking filters by hand gets old fast. Define filter tables in your config. The default table is `agent`, so I set it up like this:

```toml
[agent]
props = "^[^\\s:]+::"
tasks = "^(TODO|DOING|DONE|LATER|NOW|CANCELED|WAITING)"
links = "^\\s*(?:https?:\\/\\/\\S+|\\[[^\\]\\r\\n]+\\]\\(\\s*https?:\\/\\/[^\\s)]+(?:\\s+\"[^\"\\r\\n]*\")?\\s*\\))\\s*$"
```

Then I can throw my keys at it:
```zsh
nt page Atomic --less tasks
```
or
```zsh
nt page Atomic --only tasks
```

Or combine them:
```zsh
nt page Atomic --less tasks --less links
```

The CLI’s own help examples already expect these definitions.

Need the human view?
```zsh
nt page Atomic --only
```
Need only the agent-friendly version?
```zsh
nt page Atomic --less
```

`about` uses those filters too, so every hand-off stays clean.

These flags make the audience explicit:
```zsh
nt page Atomic --human # i.e., only
nt page Atomic --agent # i.e., less
```

Need a different vibe? Define another filter table and point `--filter` to it:
```zsh
nt page Atomic --only --filter=public
nt page Atomic --less --filter=public
```

### Querying via Datalog

Logseq's superpower is its [DataScript](https://github.com/tonsky/datascript) spine. `nt query` (`nt q`) puts Datalog inside reach so you can build whatever queries or custom commands you like. The ability to define and use custom queries is one reason I still prefer Logseq over similar apps.

```zsh
nt q '[:find (pull ?p [*]) :where [?p :block/original-name "$1"]]' Atomic
```

Drop named queries into your config to call them by name:

```toml
[query]
page = '[:find (pull ?p [*]) :where [?p :block/original-name "$1"]]'
```

```zsh
nt q page Atomic
```

Add as many as you need:

```toml
between = """
[:find (pull ?b [*])
  :in $ ?start ?end
  :where
  [?b :block/content ?blockcontent]
  [?b :block/page ?page]
  [?page :block/name ?name]
  [?b :block/scheduled ?scheduled]
  [(>= ?scheduled ?start)]
  [(<= ?scheduled ?end)]]
"""
```

```zsh
nt q between 20260501 20260601
```

These calls return JSON.

Any hiccups probably come from the HTTP API implementation, not `nt`. When you need to see what the API accepts, hit it with `curl`. If, for example, you get

```zsh
Error: Missing rules var '%' in :in
```

it usually means the syntax you’re using is too advanced for this endpoint.

Need help writing queries? Start with this builder: [https://adxsoft.github.io/logseqadvancedquerybuilder/](https://adxsoft.github.io/logseqadvancedquerybuilder/)

## License
[MIT](./LICENSE.md)
