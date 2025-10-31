# Changelog

All notable changes to the Menu.ca Frontend Build will be documented in this file.

## [Unreleased]

### Added
- Documentation restructure for LLM agent efficiency
- Master README.md with clear navigation
- Organized docs/ folder with logical hierarchy

## [2025-10-31] - Documentation Restructure

### Added
- LLM-optimized documentation structure
- Clear navigation paths for agents
- Status badges and metadata
- Cross-references between related docs

### Changed
- Moved all docs to centralized `docs/` folder
- Renamed folders to lowercase (audits, handoffs, tickets)
- Consolidated duplicate documentation
- Improved file naming conventions

### Deprecated
- Multiple entry points (START_HERE.md, etc.)
- Documentation scattered across multiple locations

## [2025-10-31] - Yelp Integration

### Added
- Yelp Fusion API integration
- Fetch restaurant reviews from Yelp
- Store reviews in restaurant_reviews table
- Scripts for importing Yelp data

See: `docs/02-features/reviews/yelp-integration.md`

## [2025-10-31] - Operational Data

### Changed
- AI search now uses real delivery times
- AI search now uses real delivery fees
- Restaurant data pulled from database tables

See: `customer-app/HANDOFF.md`

## [2025-10-29] - SMS Authentication

### Added
- SMS-based authentication for customers
- Phone number verification
- SMS OTP for login

See: `docs/02-features/authentication/sms-auth.md`

## [2025-10-28] - AI-Powered Search

### Added
- OpenAI GPT-4 integration
- Natural language restaurant search
- Semantic understanding of queries
- Smart fallback to keyword matching

See: `docs/02-features/search/ai-search.md`

---

**Format:** Based on [Keep a Changelog](https://keepachangelog.com/)
