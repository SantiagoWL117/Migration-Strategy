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

## [2025-10-31] - Yelp Integration Complete ✅

### Added
- **Yelp Fusion API Integration** - Complete review import system
  - Import script with rate limiting: `scripts/fetch-yelp-reviews.ts`
  - TypeScript type definitions: `scripts/yelp-types.ts`
  - Verification tool: `scripts/verify-reviews.ts`
  - Integration test: `scripts/test-ai-search-data.ts`
  - **Results:** 394 real reviews imported from 86 restaurants (56.6% match rate)
  - Average rating: 3.55 stars

- **Database Schema Updates**
  - Extended `restaurant_reviews` table with 6 Yelp-specific columns
  - Made `user_id` nullable for external reviews
  - Added index on `yelp_business_id` for fast lookups

- **AI Search Integration**
  - Real Yelp ratings displayed for 54.7% of restaurants (41/75)
  - In-memory rating aggregation with 5-minute cache
  - Graceful fallback for restaurants without reviews

### Changed
- AI search now returns real Yelp ratings instead of null/hardcoded values
- Updated `app/api/ai-search/route.ts` to fetch and aggregate review ratings

### Documentation
- [Yelp Integration Guide](docs/02-features/reviews/yelp-integration.md) - Complete implementation
- [Handoff Document](handoffs/2025-10-31-yelp-integration-handoff.md) - Session summary
- [Reviews Overview](docs/02-features/reviews/README.md) - System overview

See: `docs/02-features/reviews/`

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
