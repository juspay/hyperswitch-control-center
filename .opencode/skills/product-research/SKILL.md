---
name: product-research
description: Conduct deep product research on any topic using web search with citations. Triggered by the command /product. Provides comprehensive research results with URLs from trusted sources. Use this skill when the user wants to research products, technologies, services, market trends, or any topic requiring authoritative information with proper citations.
command: /product
---

# Product Research Skill

Conduct comprehensive, well-sourced research on any product, technology, service, or market topic. This skill leverages deep web search to gather information from trusted sources and provides results with proper citations.

## Workflow

### Step 1: Parse Research Query

Extract the research topic from the user's command:

- Command format: `/product <research topic>`
- Extract everything after `/product` as the research query
- If the query is ambiguous, ask for clarification before proceeding

### Step 2: Define Research Scope

Based on the query, identify:

- **Primary topic**: What is the main subject?
- **Research dimensions**: What aspects to cover? (features, pricing, competitors, reviews, market position, technical specs, etc.)
- **Source preferences**: Industry-specific trusted sources, if applicable

### Step 3: Execute Deep Web Search

Use `websearch_web_search_exa` tool to perform comprehensive searches.

**Search Strategy** (execute multiple searches in parallel):

1. **Overview search**: General information about the topic

   ```
   "<topic> overview features benefits"
   ```

2. **Comparison search**: Alternatives and competitors

   ```
   "<topic> vs alternatives comparison"
   ```

3. **Expert review search**: Professional evaluations

   ```
   "<topic> review expert analysis 2024"
   ```

4. **Technical/market search**: Specifications or market data
   ```
   "<topic> specifications pricing market share"
   ```

**Parameters**:

- `numResults`: 10-15 per search (aim for comprehensive coverage)
- `type`: "auto" for balanced results
- `livecrawl`: "preferred" for fresh content

### Step 4: Synthesize Research Findings

Organize findings into a structured report:

#### Report Structure:

```markdown
# Product Research: [Topic]

## Executive Summary

2-3 sentence overview of key findings

## Overview

- What it is
- Primary use cases
- Key value proposition

## Key Features & Capabilities

- Feature 1: Description [1]
- Feature 2: Description [2]
- ...

## Pricing & Plans (if applicable)

- Plan tiers
- Key differentiators

## Competitive Landscape

- Main competitors
- Positioning vs alternatives

## Pros & Cons

**Pros:**

- Pro 1 [3]
- Pro 2 [4]

**Cons:**

- Con 1 [5]
- Con 2 [6]

## Expert Opinions & Reviews

- Summary of professional evaluations
- Common praise and criticisms

## Market Position & Trends

- Current market standing
- Recent developments
- Future outlook

## Bottom Line

Concise recommendation or conclusion

---

## Sources

[1] [Title](URL) - Source Name
[2] [Title](URL) - Source Name
[3] [Title](URL) - Source Name
...
```

### Step 5: Citations Requirement

**MANDATORY**: Every factual claim must have a citation:

1. **Inline citations**: Use superscript numbers [1], [2], etc.
2. **Source list**: At the end, list all sources with:
   - Full URL (clickable)
   - Article/page title
   - Publication/source name
   - Date (if available)

3. **Source quality prioritization**:
   - ✅ Official documentation/websites
   - ✅ Reputable tech publications (TechCrunch, The Verge, Ars Technica, etc.)
   - ✅ Industry analysts (Gartner, Forrester, IDC)
   - ✅ Academic papers
   - ✅ Established review sites
   - ⚠️ Forums/Reddit (only for user sentiment, clearly labeled)

### Step 6: Deliver Results

Present the research report to the user with:

- Clear, scannable structure
- All citations linked
- Source list at the bottom
- Brief summary at the top

## Example Usage

**User**: `/product vector databases for AI applications`

**Response**:

```markdown
# Product Research: Vector Databases for AI Applications

## Executive Summary

Vector databases have become essential infrastructure for AI applications, with Pinecone, Weaviate, and Milvus leading the market. These specialized databases enable efficient similarity search on high-dimensional embeddings.[1]

## Overview

...

## Sources

[1] [The Rise of Vector Databases](https://example.com/article) - TechCrunch, 2024
...
```

## Best Practices

1. **Be exhaustive**: Search multiple angles, not just the first result
2. **Cross-verify**: When possible, confirm facts across multiple sources
3. **Stay current**: Prioritize recent information (last 1-2 years for tech)
4. **Acknowledge gaps**: If information is missing or unclear, say so
5. **Avoid speculation**: Stick to what sources say; don't infer beyond the evidence
6. **Diverse sources**: Don't rely on a single publication; spread citations across sources

## Error Handling

- **No results**: Try alternative search terms or broader queries
- **Conflicting information**: Present both perspectives with citations
- **Paywalled sources**: Note if key information is behind paywalls
- **Outdated info**: Prioritize recent sources; note publication dates
