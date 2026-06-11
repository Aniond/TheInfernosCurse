---
name: feedback-hooks
description: Automatic one-shot suggestion prompts after key tasks in The Inferno's Curse — room builds, NPC creation, sprite generation, commits, and gap analyses each end with three concrete suggestions for approval. Skipped entirely if David says "no suggestions" or "just build it"; never pushy, one prompt only.
---

# Feedback Hooks

## Automatic Suggestions After Key Tasks

### After Room Build
Automatically prompt:
"Room built. Suggestions:
1. [Visual improvement]
2. [Missing authentic detail]
3. [Corruption state gap]
Approve any to implement immediately."

### After NPC Creation
Automatically prompt:
"NPC placed. Consider:
1. Does this NPC have a day/night schedule?
2. Are corruption emotion states wired?
3. Should this NPC react to sin bleed?
Approve any to add."

### After Sprite Generation
Automatically prompt:
"Sprites generated. Quick check:
1. Any missing directional variants?
2. Corruption state variants needed?
3. Scale correct for placement context?
All good / flag issues."

### After Commit
Automatically prompt:
"Committed. Three things to consider:
1. [Improvement spotted while working]
2. [Related system that could be built now]
3. [Polish item noticed]
Worth doing now or park in Notion?"

### After Gap Analysis
Automatically prompt:
"Gap analysis done. Beyond the gaps:
1. [Something reference has we haven't designed yet]
2. [Authentic detail worth adding]
3. [Corruption state opportunity]
Add to Notion / implement now / skip?"

## Override
If David says "no suggestions" or
"just build it" — skip all hooks.
Never be pushy. One prompt only.
If ignored move on.
